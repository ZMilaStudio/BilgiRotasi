#!/usr/bin/env python3
"""Capture actual installed APK at two Android sizes and two harbor segments."""

from pathlib import Path
import subprocess
import time
import xml.etree.ElementTree as ET
import re

PACKAGE = "com.zmilastudio.kelimeavi"
REPORTS = Path("reports/kelime_avi_runtime")
REPORTS.mkdir(parents=True, exist_ok=True)


def adb(*args: str, binary: bool = False):
    return subprocess.check_output(["adb", *args], text=not binary)


def capture(name: str, expected: str) -> ET.Element:
    for _ in range(15):
        adb("shell", "uiautomator", "dump", "/sdcard/window.xml")
        xml = adb("exec-out", "cat", "/sdcard/window.xml")
        root = ET.fromstring(xml)
        if any(expected.casefold() in (
            node.attrib.get("text", "") + " " + node.attrib.get("content-desc", "")
        ).casefold() for node in root.iter("node")):
            break
        time.sleep(1)
    else:
        (REPORTS / f"{name}.xml").write_text(xml)
        raise AssertionError(f"Expected {expected!r} not visible in {name}")
    (REPORTS / f"{name}.xml").write_text(xml)
    time.sleep(1)
    (REPORTS / f"{name}.png").write_bytes(adb("exec-out", "screencap", "-p", binary=True))
    return root


def tap_segment(root: ET.Element, segment: int) -> None:
    for node in root.iter("node"):
        label = node.attrib.get("text", "") + " " + node.attrib.get("content-desc", "")
        if f"Segment {segment}" not in label or node.attrib.get("clickable") != "true":
            continue
        bounds = re.match(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", node.attrib.get("bounds", ""))
        if bounds:
            left, top, right, bottom = map(int, bounds.groups())
            adb("shell", "input", "tap", str((left + right) // 2), str((top + bottom) // 2))
            return
    raise AssertionError(f"No clickable Segment {segment} in Android accessibility tree")



def verify_spacing(root: ET.Element, first: int, second: int, label: str) -> str:
    """Verify real Android accessible hitboxes and tap both independently."""
    def target(level: int) -> tuple[int, int, int, int]:
        candidates = []
        for node in root.iter("node"):
            text = node.attrib.get("text", "") + " " + node.attrib.get("content-desc", "")
            if f"Bölüm {level}," not in text or node.attrib.get("clickable") != "true":
                continue
            bounds = re.match(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]",
                              node.attrib.get("bounds", ""))
            if bounds:
                candidates.append(tuple(map(int, bounds.groups())))
        if len(candidates) != 1:
            raise AssertionError(f"{label}: expected one clickable L{level}, got {candidates}")
        left, top, right, bottom = candidates[0]
        if right - left < 48 or bottom - top < 48:
            raise AssertionError(f"{label}: L{level} hitbox <48dp: {candidates[0]}")
        return candidates[0]

    a = target(first)
    b = target(second)
    overlap = a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]
    if overlap:
        raise AssertionError(f"{label}: overlapping L{first}/L{second}: {a}, {b}")
    for left, top, right, bottom in (a, b):
        adb("shell", "input", "tap", str((left + right) // 2),
            str((top + bottom) // 2))
    return f"{label}: L{first}={a}; L{second}={b}; 48dp and separate taps PASS"


def verify_logcat() -> None:
    logs = adb("logcat", "-d", "-s", "flutter:I", "Flutter:I")
    (REPORTS / "harbor_flutter_logcat.txt").write_text(logs)
    for error in ("Unable to load asset", "Asset not found", "A RenderFlex overflowed",
                  "RIGHT OVERFLOWED", "EXCEPTION CAUGHT BY"):
        if error in logs:
            raise AssertionError(f"Flutter runtime error: {error}")


def main() -> None:
    apk = "apps/kelime_avi_standalone/build/app/outputs/flutter-apk/app-debug.apk"
    adb("install", "-r", apk)
    adb("logcat", "-c")
    spacing_evidence = []
    for width, height in ((360, 800), (412, 915)):
        adb("shell", "wm", "size", f"{width}x{height}")
        adb("shell", "wm", "density", "160")
        adb("shell", "am", "force-stop", PACKAGE)
        adb("shell", "monkey", "-p", PACKAGE, "-c", "android.intent.category.LAUNCHER", "1")
        time.sleep(4)
        segment2 = capture(f"harbor_{width}x{height}_segment2", "Bölüm 20")
        spacing_evidence.append(verify_spacing(
            segment2, 13, 14, f"{width}x{height} / Segment 2"
        ))
        tap_segment(segment2, 3)
        segment3 = capture(f"harbor_{width}x{height}_segment3", "Bölüm 30")
        spacing_evidence.append(verify_spacing(
            segment3, 23, 24, f"{width}x{height} / Segment 3"
        ))
    (REPORTS / "harbor_spacing_bounds.txt").write_text(
        "\n".join(spacing_evidence) + "\n"
    )
    verify_logcat()
    (REPORTS / "HARBOR_PASS.txt").write_text(
        "Installed visual-proof debug APK: approved clean Segment 2 and 3 scenes, "
        "live nodes, 360x800 and 412x915; Flutter asset/overflow log scan PASS. "
        "Owner real-device visual acceptance still required.\n"
    )


if __name__ == "__main__":
    try:
        main()
    finally:
        verify_logcat()