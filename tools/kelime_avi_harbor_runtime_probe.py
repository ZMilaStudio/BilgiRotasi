#!/usr/bin/env python3
"""Capture deterministic Segment 2 and 3 evidence from the installed debug APK."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import struct
import subprocess
import time
import traceback
import xml.etree.ElementTree as ET


PACKAGE = "com.zmilastudio.kelimeavi"
APK = Path("apps/kelime_avi_standalone/build/app/outputs/flutter-apk/app-debug.apk")
REPORTS = Path("reports/kelime_avi_runtime")
REPORTS.mkdir(parents=True, exist_ok=True)

FAILURES: list[str] = []
ACCESSIBILITY: list[str] = []
SEMANTICS_AGGREGATED: list[str] = []
CAPTURES: list[str] = []


def adb(*args: str, binary: bool = False) -> str | bytes:
    return subprocess.check_output(
        ["adb", *args],
        text=not binary,
        stderr=subprocess.STDOUT,
    )


def record_failure(label: str, error: object) -> None:
    message = f"{label}: {error}"
    FAILURES.append(message)
    print(f"FAIL: {message}")


def node_text(node: ET.Element) -> str:
    return " ".join(
        part
        for part in (
            node.attrib.get("text", ""),
            node.attrib.get("content-desc", ""),
        )
        if part
    )


def bounds(node: ET.Element) -> tuple[int, int, int, int]:
    match = re.fullmatch(
        r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]",
        node.attrib.get("bounds", ""),
    )
    if not match:
        raise AssertionError(f"Invalid Android bounds: {node.attrib}")
    return tuple(map(int, match.groups()))


def overlaps(
    first: tuple[int | float, int | float, int | float, int | float],
    second: tuple[int | float, int | float, int | float, int | float],
) -> bool:
    return (
        first[0] < second[2]
        and second[0] < first[2]
        and first[1] < second[3]
        and second[1] < first[3]
    )


def capture(name: str, expected_terms: tuple[str, ...]) -> ET.Element:
    """Save raw XML and PNG before reporting readiness/assertion failures."""
    xml = ""
    root: ET.Element | None = None
    ready = False
    for _ in range(20):
        try:
            adb("shell", "uiautomator", "dump", "/sdcard/window.xml")
            xml = str(adb("exec-out", "cat", "/sdcard/window.xml"))
            root = ET.fromstring(xml)
            visible = " ".join(node_text(node) for node in root.iter("node")).casefold()
            if all(term.casefold() in visible for term in expected_terms):
                ready = True
                break
        except (subprocess.CalledProcessError, ET.ParseError) as error:
            record_failure(f"{name} accessibility capture attempt", error)
        time.sleep(1)

    (REPORTS / f"{name}.xml").write_text(xml, encoding="utf-8")
    try:
        screenshot = adb("exec-out", "screencap", "-p", binary=True)
        assert isinstance(screenshot, bytes)
        (REPORTS / f"{name}.png").write_bytes(screenshot)
        CAPTURES.append(f"{name}.png")
    except (subprocess.CalledProcessError, OSError, AssertionError) as error:
        record_failure(f"{name} screenshot", error)

    if root is None:
        raise AssertionError(f"{name}: no parseable UIAutomator XML")
    if not ready:
        raise AssertionError(
            f"{name}: expected accessibility terms not visible: {expected_terms}"
        )
    return root


def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if len(data) < 24 or data[:8] != b"\x89PNG\r\n\x1a\n":
        raise AssertionError(f"Invalid PNG: {path}")
    return struct.unpack(">II", data[16:24])


def level_nodes(root: ET.Element, level: int) -> list[ET.Element]:
    token = f"bölüm {level},"
    return [
        node
        for node in root.iter("node")
        if token in node_text(node).casefold()
        and re.fullmatch(
            r"\[\d+,\d+\]\[\d+,\d+\]",
            node.attrib.get("bounds", ""),
        )
    ]


def verify_accessibility(
    root: ET.Element,
    scenario: str,
    width: int,
    height: int,
) -> None:
    expected_clickable = {
        level: scenario == "l20_playable" or level <= 15
        for level in range(11, 21)
    }
    expected_labels = {
        11: "1 yıldız",
        12: "2 yıldız",
        13: "3 yıldız",
        15: "2 yıldız" if scenario == "l20_playable" else "0 yıldız",
        20: "0 yıldız",
    }
    rectangles: dict[int, tuple[int, int, int, int]] = {}
    for level in range(11, 21):
        matches = level_nodes(root, level)
        if len(matches) != 1:
            raise AssertionError(
                f"{scenario} {width}x{height}: L{level} expected one Android node, "
                f"got {len(matches)}"
            )
        node = matches[0]
        rect = bounds(node)
        left, top, right, bottom = rect
        if not (0 <= left < right <= width and 0 <= top < bottom <= height):
            raise AssertionError(f"L{level}: clipped/outside screen: {rect}")
        if right - left < 48 or bottom - top < 48:
            raise AssertionError(f"L{level}: touch bounds below 48dp: {rect}")
        clickable = node.attrib.get("clickable") == "true"
        if clickable != expected_clickable[level]:
            raise AssertionError(
                f"L{level}: clickable={clickable}, expected={expected_clickable[level]}"
            )
        label = node_text(node).casefold()
        expected_state = "açık" if expected_clickable[level] else "kilitli"
        if expected_state not in label:
            raise AssertionError(f"L{level}: missing state {expected_state!r}: {label}")
        if level in expected_labels and expected_labels[level] not in label:
            raise AssertionError(
                f"L{level}: missing {expected_labels[level]!r}: {label}"
            )
        rectangles[level] = rect

    for level in range(11, 21):
        for other in range(level + 1, 21):
            if overlaps(rectangles[level], rectangles[other]):
                raise AssertionError(
                    f"L{level}/L{other}: Android hitbox overlap: "
                    f"{rectangles[level]}, {rectangles[other]}"
                )

    challenge_nodes = [
        node
        for node in root.iter("node")
        if "meydan okuma" in node_text(node).casefold()
        and re.fullmatch(
            r"\[\d+,\d+\]\[\d+,\d+\]",
            node.attrib.get("bounds", ""),
        )
    ]
    if scenario == "l20_playable":
        if not challenge_nodes:
            raise AssertionError("L20 challenge accessibility label is missing")
        distinct = [node for node in challenge_nodes if bounds(node) != rectangles[20]]
        if not distinct:
            marker = f"{width}x{height}: L20 SEMANTICS_AGGREGATED {rectangles[20]}"
            SEMANTICS_AGGREGATED.append(marker)
            ACCESSIBILITY.append(marker)
        elif len(distinct) == 1:
            plaque = bounds(distinct[0])
            if not (
                0 <= plaque[0] < plaque[2] <= width
                and 0 <= plaque[1] < plaque[3] <= height
            ):
                raise AssertionError(f"L20 distinct semantics clipped: {plaque}")
            if plaque[1] <= rectangles[20][3]:
                raise AssertionError(f"L20 distinct plaque not below hitbox: {plaque}")
            for level in range(11, 20):
                if overlaps(plaque, rectangles[level]):
                    raise AssertionError(f"L20 distinct plaque overlaps L{level}")
            ACCESSIBILITY.append(
                f"{width}x{height}: L20 distinct challenge semantics={plaque}"
            )
        else:
            raise AssertionError(
                "L20 challenge has multiple distinct semantics nodes: "
                f"{[bounds(node) for node in distinct]}"
            )

    ACCESSIBILITY.append(
        f"{width}x{height} {scenario}: "
        + "; ".join(f"L{level}={rectangles[level]}" for level in rectangles)
        + "; 48dp+, state and non-overlap PASS"
    )


def verify_segment3(root: ET.Element, width: int, height: int) -> None:
    """Retain all ten Segment 3 nodes, L30 challenge and independent L23/24 taps."""
    rectangles = {}
    for level in range(21, 31):
        matches = level_nodes(root, level)
        if len(matches) != 1:
            raise AssertionError(f"L{level}: expected one Android node, got {len(matches)}")
        node = matches[0]
        rect = bounds(node)
        if not (0 <= rect[0] < rect[2] <= width and 0 <= rect[1] < rect[3] <= height):
            raise AssertionError(f"L{level}: clipped/outside screen: {rect}")
        if rect[2] - rect[0] < 48 or rect[3] - rect[1] < 48:
            raise AssertionError(f"L{level}: touch bounds below 48dp: {rect}")
        expected_open = level <= 29
        if (node.attrib.get("clickable") == "true") != expected_open:
            raise AssertionError(f"L{level}: incorrect clickable state")
        label = node_text(node).casefold()
        if ("açık" if expected_open else "kilitli") not in label:
            raise AssertionError(f"L{level}: incorrect accessibility state: {label}")
        stars = level % 3 + 1 if level <= 28 else 0
        if f"{stars} yıldız" not in label:
            raise AssertionError(f"L{level}: incorrect fixture stars: {label}")
        if level == 30 and "meydan okuma" not in label:
            raise AssertionError("L30 challenge semantics missing")
        rectangles[level] = rect
    for level in range(21, 31):
        for other in range(level + 1, 31):
            if overlaps(rectangles[level], rectangles[other]):
                raise AssertionError(f"L{level}/L{other}: Android hitbox overlap")
    badges = [node for node in root.iter("node")
              if "meydan okuma" in node_text(node).casefold()]
    if not badges:
        raise AssertionError("L30 challenge accessibility label missing")
    distinct = [node for node in badges if bounds(node) != rectangles[30]]
    if len(distinct) > 1:
        raise AssertionError("L30 challenge has multiple distinct semantics nodes")
    # Aggregated semantics do not describe the plaque's RenderBox. The same
    # strict below-hitbox, containment and overlap geometry checks run for L30.
    for node in badges:
        plaque = bounds(node)
        if plaque != rectangles[30]:
            if not (0 <= plaque[0] < plaque[2] <= width and
                    rectangles[30][3] < plaque[1] < plaque[3] <= height):
                raise AssertionError(f"L30 distinct plaque clipped/not below: {plaque}")
            for level in range(21, 30):
                if overlaps(plaque, rectangles[level]):
                    raise AssertionError(f"L30 plaque overlaps L{level}")
    for level in (23, 24):
        left, top, right, bottom = rectangles[level]
        adb("shell", "input", "tap", str((left + right) // 2), str((top + bottom) // 2))
    ACCESSIBILITY.append(f"{width}x{height} Segment 3: all ten nodes, stars, locks, "
                         "48dp+, non-overlap, L30 challenge, L23/L24 taps PASS")


def verify_segment4(root: ET.Element, scenario: str, width: int, height: int) -> None:
    """Exact deterministic Segment 4 state; real Android accessibility evidence."""
    if scenario not in ("segment4_mixed", "l40_playable"):
        raise AssertionError(f"Unknown Segment 4 scenario: {scenario}")
    completed = 33 if scenario == "segment4_mixed" else 39
    rectangles = {}
    for level in range(31, 41):
        matches = level_nodes(root, level)
        if len(matches) != 1:
            raise AssertionError(f"L{level}: expected one Android node")
        node = matches[0]
        rect = bounds(node)
        if not (0 <= rect[0] < rect[2] <= width and 0 <= rect[1] < rect[3] <= height):
            raise AssertionError(f"L{level}: clipped/outside screen: {rect}")
        if rect[2] - rect[0] < 48 or rect[3] - rect[1] < 48:
            raise AssertionError(f"L{level}: touch bounds below 48dp")
        opened = level <= completed + 1
        if (node.attrib.get("clickable") == "true") != opened:
            raise AssertionError(f"L{level}: incorrect clickable state")
        stars = (level - 31) % 3 + 1 if level <= completed else 0
        label = node_text(node).casefold()
        if ("açık" if opened else "kilitli") not in label or f"{stars} yıldız" not in label:
            raise AssertionError(f"L{level}: incorrect fixture state/stars: {label}")
        if level == 40 and "meydan okuma" not in label:
            raise AssertionError("L40 challenge semantics missing")
        rectangles[level] = rect
    for level in range(31, 41):
        for other in range(level + 1, 41):
            if overlaps(rectangles[level], rectangles[other]):
                raise AssertionError(f"L{level}/L{other}: Android hitbox overlap")
    ACCESSIBILITY.append(f"{width}x{height} {scenario}: ten nodes, stars, locks, 48dp+, non-overlap PASS")


def tap_info(root: ET.Element, width: int) -> None:
    matches = [
        node
        for node in root.iter("node")
        if "bilgi" in node_text(node).casefold()
        and node.attrib.get("clickable") == "true"
    ]
    if len(matches) == 1:
        left, top, right, bottom = bounds(matches[0])
        adb(
            "shell",
            "input",
            "tap",
            str((left + right) // 2),
            str((top + bottom) // 2),
        )
        return
    record_failure("Info accessibility target", f"expected one node, got {len(matches)}")
    adb("shell", "input", "tap", str(width - 28), "54")


def collect_geometry(logs: str) -> list[dict[str, object]]:
    marker = "[HARBOR_PROOF_GEOMETRY]"
    records: list[dict[str, object]] = []
    for line in logs.splitlines():
        if marker not in line:
            continue
        payload = line.split(marker, 1)[1].strip()
        try:
            record = json.loads(payload)
        except json.JSONDecodeError as error:
            record_failure("Flutter geometry JSON", f"{error}: {payload}")
            continue
        records.append(record)
    (REPORTS / "harbor_geometry.json").write_text(
        json.dumps(records, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return records


def rect_from(record: dict[str, object]) -> tuple[float, float, float, float]:
    rect = record["rect"]
    assert isinstance(rect, dict)
    return (
        float(rect["left"]),
        float(rect["top"]),
        float(rect["right"]),
        float(rect["bottom"]),
    )


def verify_geometry(records: list[dict[str, object]]) -> None:
    grouped: dict[tuple[str, int, int], dict[str, dict[str, object]]] = {}
    for record in records:
        scenario = str(record.get("scenario", ""))
        width = round(float(record.get("logicalWidth", 0)))
        height = round(float(record.get("logicalHeight", 0)))
        key = str(record.get("key", ""))
        grouped.setdefault((scenario, width, height), {})[key] = record

    summaries: list[str] = []
    for width, height in ((360, 800), (412, 915)):
        for scenario in ("mixed", "l20Playable", "segment3", "segment4Mixed", "l40Playable"):
            segment = 4 if scenario in ("segment4Mixed", "l40Playable") else 3 if scenario == "segment3" else 2
            first, last = (segment - 1) * 10 + 1, segment * 10
            proof_key = (scenario, width, height)
            evidence = grouped.get(proof_key)
            if evidence is None:
                raise AssertionError(f"Missing Flutter geometry evidence: {proof_key}")
            required = {
                f"word_hunt_harbor_scene_{segment}",
                f"word_hunt_harbor_medallion_{last}",
                *(f"word_hunt_harbor_level_{level}" for level in range(first, last + 1)),
            }
            if scenario != "mixed":
                required.add(f"word_hunt_harbor_challenge_{last}")
            if segment == 4:
                last_open = 34 if scenario == "segment4Mixed" else 40
                required.update(f"word_hunt_harbor_stars_{level}"
                                for level in range(31, last_open + 1))
            missing = sorted(required - evidence.keys())
            if missing:
                raise AssertionError(f"{proof_key}: missing RenderBox keys: {missing}")

            scene = rect_from(evidence[f"word_hunt_harbor_scene_{segment}"])
            hitboxes = {
                level: rect_from(evidence[f"word_hunt_harbor_level_{level}"])
                for level in range(first, last + 1)
            }
            for level, rect in hitboxes.items():
                rect_width = rect[2] - rect[0]
                rect_height = rect[3] - rect[1]
                if abs(rect_width - 68) > 0.1 or abs(rect_height - 68) > 0.1:
                    raise AssertionError(
                        f"{proof_key}: L{level} RenderBox is not 68dp: {rect}"
                    )
                if not (
                    scene[0] <= rect[0] < rect[2] <= scene[2]
                    and scene[1] <= rect[1] < rect[3] <= scene[3]
                ):
                    raise AssertionError(
                        f"{proof_key}: L{level} RenderBox clipped: {rect}"
                    )
            for level in range(first, last + 1):
                for other in range(level + 1, last + 1):
                    if overlaps(hitboxes[level], hitboxes[other]):
                        raise AssertionError(
                            f"{proof_key}: L{level}/L{other} RenderBox overlap"
                        )
            if segment == 4:
                for level in range(31, last_open + 1):
                    stars = rect_from(evidence[f"word_hunt_harbor_stars_{level}"])
                    if not (scene[0] <= stars[0] < stars[2] <= scene[2]
                            and scene[1] <= stars[1] < stars[3] <= scene[3]):
                        raise AssertionError(f"{proof_key}: L{level} stars clipped")
                    for other, rect in hitboxes.items():
                        if other != level and overlaps(stars, rect):
                            raise AssertionError(f"{proof_key}: L{level} stars overlap L{other}")

            medallion = rect_from(evidence[f"word_hunt_harbor_medallion_{last}"])
            if not (
                scene[0] <= medallion[0] < medallion[2] <= scene[2]
                and scene[1] <= medallion[1] < medallion[3] <= scene[3]
            ):
                raise AssertionError(
                    f"{proof_key}: L{last} medallion clipped: {medallion}"
                )

            if scenario != "mixed":
                plaque = rect_from(evidence[f"word_hunt_harbor_challenge_{last}"])
                if not (
                    scene[0] <= plaque[0] < plaque[2] <= scene[2]
                    and scene[1] <= plaque[1] < plaque[3] <= scene[3]
                ):
                    raise AssertionError(
                        f"{proof_key}: L{last} plaque clipped: {plaque}"
                    )
                if plaque[1] < hitboxes[last][3] - 0.1:
                    raise AssertionError(
                        f"{proof_key}: L{last} plaque not below hitbox: "
                        f"{plaque}, {hitboxes[last]}"
                    )
                center_x = lambda rect: (rect[0] + rect[2]) / 2
                if abs(center_x(plaque) - center_x(hitboxes[last])) > 0.1:
                    raise AssertionError(f"{proof_key}: L{last} plaque is not centered")
                if abs(center_x(medallion) - center_x(hitboxes[last])) > 0.1:
                    raise AssertionError(
                        f"{proof_key}: L{last} medallion is not centered"
                    )
                for level in range(first, last):
                    if overlaps(plaque, hitboxes[level]):
                        raise AssertionError(
                            f"{proof_key}: L{last} plaque overlaps L{level}"
                        )
            elif f"word_hunt_harbor_challenge_{last}" in evidence:
                raise AssertionError(
                    f"{proof_key}: locked L{last} unexpectedly shows challenge plaque"
                )

            summaries.append(
                f"{width}x{height} {scenario}: scene={scene}; "
                f"L{last}={hitboxes[last]}; medallion={medallion}; RenderBox PASS"
            )

    (REPORTS / "harbor_geometry.txt").write_text(
        "\n".join(summaries) + "\n",
        encoding="utf-8",
    )


def collect_diagnostics() -> str:
    diagnostics = {
        "harbor_flutter_logcat.txt": (
            "logcat",
            "-d",
            "-s",
            "flutter:I",
            "Flutter:I",
        ),
        "harbor_full_logcat.txt": ("logcat", "-d"),
        "harbor_activity.txt": ("shell", "dumpsys", "activity", "activities"),
        "harbor_window.txt": ("shell", "dumpsys", "window", "windows"),
        "harbor_package.txt": ("shell", "dumpsys", "package", PACKAGE),
    }
    outputs: dict[str, str] = {}
    for filename, command in diagnostics.items():
        try:
            output = str(adb(*command))
        except subprocess.CalledProcessError as error:
            output = error.output or str(error)
            record_failure(filename, error)
        (REPORTS / filename).write_text(output, encoding="utf-8")
        outputs[filename] = output
    full = outputs["harbor_full_logcat.txt"]
    crash_patterns = (
        "FATAL EXCEPTION",
        f"ANR in {PACKAGE}",
        f"am_crash.*{re.escape(PACKAGE)}",
        f"am_anr.*{re.escape(PACKAGE)}",
        f"Process {re.escape(PACKAGE)} .*has died",
    )
    for pattern in crash_patterns:
        if re.search(pattern, full, flags=re.IGNORECASE):
            record_failure("Android crash/ANR/process-death", pattern)
    flutter = outputs["harbor_flutter_logcat.txt"]
    for error in (
        "Unable to load asset",
        "Asset not found",
        "A RenderFlex overflowed",
        "RIGHT OVERFLOWED",
        "EXCEPTION CAUGHT BY",
    ):
        if error in flutter:
            record_failure("Flutter runtime error", error)
    return flutter


def run() -> None:
    if not APK.is_file():
        raise AssertionError(f"Debug proof APK missing: {APK}")
    adb("install", "-r", str(APK))
    adb("logcat", "-c")

    for width, height in ((360, 800), (412, 915)):
        adb("shell", "wm", "size", f"{width}x{height}")
        adb("shell", "wm", "density", "160")
        display = (
            f"requested={width}x{height}@160dpi\n"
            f"{adb('shell', 'wm', 'size')}"
            f"{adb('shell', 'wm', 'density')}"
        )
        (REPORTS / f"harbor_{width}x{height}_display.txt").write_text(
            display,
            encoding="utf-8",
        )

        adb("shell", "am", "force-stop", PACKAGE)
        adb(
            "shell",
            "monkey",
            "-p",
            PACKAGE,
            "-c",
            "android.intent.category.LAUNCHER",
            "1",
        )
        time.sleep(4)

        mixed_name = f"harbor_{width}x{height}_mixed"
        mixed: ET.Element | None = None
        try:
            mixed = capture(mixed_name, ("Bölüm 20", "kilitli"))
            actual_size = png_size(REPORTS / f"{mixed_name}.png")
            if actual_size != (width, height):
                raise AssertionError(
                    f"{mixed_name}: screenshot dimensions are {actual_size}"
                )
            verify_accessibility(mixed, "mixed", width, height)
        except Exception as error:  # continue to all six captures
            record_failure(mixed_name, error)

        if mixed is not None:
            try:
                tap_info(mixed, width)
            except Exception as error:
                record_failure(f"{mixed_name} scenario toggle", error)
        else:
            try:
                adb("shell", "input", "tap", str(width - 28), "54")
            except subprocess.CalledProcessError as error:
                record_failure(f"{mixed_name} fallback scenario toggle", error)
        time.sleep(2)

        l20 = None
        l20_name = f"harbor_{width}x{height}_l20_playable"
        try:
            l20 = capture(l20_name, ("Bölüm 20", "açık", "meydan okuma"))
            actual_size = png_size(REPORTS / f"{l20_name}.png")
            if actual_size != (width, height):
                raise AssertionError(
                    f"{l20_name}: screenshot dimensions are {actual_size}"
                )
            verify_accessibility(l20, "l20_playable", width, height)
            for level in (13, 14):
                matches = level_nodes(l20, level)
                if len(matches) != 1 or matches[0].attrib.get("clickable") != "true":
                    raise AssertionError(f"L{level}: independent tap target missing")
                left, top, right, bottom = bounds(matches[0])
                adb("shell", "input", "tap", str((left + right) // 2),
                    str((top + bottom) // 2))
        except Exception as error:  # continue to the next viewport
            record_failure(l20_name, error)

        segment3_name = f"harbor_{width}x{height}_segment3"
        segment3 = None
        try:
            if l20 is None:
                raise AssertionError("No L20 accessibility tree for Segment 3 transition")
            tap_info(l20, width)
            segment3 = capture(segment3_name, ("Bölüm 30", "kilitli", "meydan okuma"))
            if png_size(REPORTS / f"{segment3_name}.png") != (width, height):
                raise AssertionError(f"{segment3_name}: incorrect screenshot dimensions")
            verify_segment3(segment3, width, height)
        except Exception as error:
            record_failure(segment3_name, error)

        previous = segment3
        for scenario in ("segment4_mixed", "l40_playable"):
            name = f"harbor_{width}x{height}_{scenario}"
            try:
                if previous is None:
                    raise AssertionError("Missing preceding scenario accessibility tree")
                tap_info(previous, width)
                state = "kilitli" if scenario == "segment4_mixed" else "açık"
                current = capture(name, (f"Bölüm 40, meydan okuma, {state}, 0 yıldız",))
                previous = current
                if png_size(REPORTS / f"{name}.png") != (width, height):
                    raise AssertionError(f"{name}: incorrect screenshot dimensions")
                verify_segment4(current, scenario, width, height)
            except Exception as error:
                record_failure(name, error)


def write_result() -> None:
    expected = {f"harbor_{w}x{h}_{s}.png"
                for w, h in ((360, 800), (412, 915))
                for s in ("mixed", "l20_playable", "segment3", "segment4_mixed", "l40_playable")}
    if set(CAPTURES) != expected:
        record_failure("Capture inventory", f"expected={sorted(expected)}, actual={sorted(CAPTURES)}")
    result = {
        "status": "PASS" if not FAILURES else "FAIL",
        "sourceSha": os.environ.get("PROOF_SOURCE_SHA", os.environ.get("GITHUB_SHA", "LOCAL")),
        "captures": sorted(CAPTURES),
        "semanticsAggregated": SEMANTICS_AGGREGATED,
        "failures": FAILURES,
    }
    (REPORTS / "harbor_accessibility_bounds.txt").write_text(
        "\n".join(ACCESSIBILITY) + ("\n" if ACCESSIBILITY else ""),
        encoding="utf-8",
    )
    (REPORTS / "HARBOR_RESULT.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    lines = [
        f"RESULT={result['status']}",
        f"SOURCE_SHA={result['sourceSha']}",
        f"CAPTURE_COUNT={len(CAPTURES)}",
        f"SEMANTICS_AGGREGATED_COUNT={len(SEMANTICS_AGGREGATED)}",
        f"FAILURE_COUNT={len(FAILURES)}",
        *[f"SEMANTICS={entry}" for entry in SEMANTICS_AGGREGATED],
        *[f"FAILURE={entry}" for entry in FAILURES],
    ]
    (REPORTS / "HARBOR_RESULT.txt").write_text(
        "\n".join(lines) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    try:
        run()
    except Exception as error:
        record_failure("Unhandled runtime probe failure", error)
        (REPORTS / "harbor_probe_traceback.txt").write_text(
            traceback.format_exc(),
            encoding="utf-8",
        )
    finally:
        try:
            flutter_logs = collect_diagnostics()
            try:
                geometry = collect_geometry(flutter_logs)
                verify_geometry(geometry)
            except Exception as error:
                record_failure("Flutter RenderBox geometry", error)
        except Exception as error:
            record_failure("Runtime diagnostics", error)
        try:
            adb("shell", "wm", "size", "reset")
            adb("shell", "wm", "density", "reset")
        except subprocess.CalledProcessError as error:
            record_failure("Display reset", error)
        write_result()
    raise SystemExit(1 if FAILURES else 0)
