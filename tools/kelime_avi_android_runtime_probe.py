#!/usr/bin/env python3
"""Capture and verify the installed standalone APK on an Android emulator."""

from pathlib import Path
import re
import subprocess
import time
import xml.etree.ElementTree as ET


PACKAGE = "com.zmilastudio.kelimeavi"
REPORTS = Path("reports/kelime_avi_runtime")
REPORTS.mkdir(parents=True, exist_ok=True)


def adb(*args: str, binary: bool = False):
    return subprocess.check_output(["adb", *args], text=not binary)


def capture(name: str) -> ET.Element:
    time.sleep(2)
    (REPORTS / f"{name}.png").write_bytes(
        adb("exec-out", "screencap", "-p", binary=True)
    )
    adb("shell", "uiautomator", "dump", "/sdcard/window.xml")
    xml = adb("exec-out", "cat", "/sdcard/window.xml")
    (REPORTS / f"{name}.xml").write_text(xml)
    return ET.fromstring(xml)


def tap_label(root: ET.Element, label: str) -> None:
    for node in root.iter("node"):
        value = " ".join(
            (node.attrib.get("text", ""), node.attrib.get("content-desc", ""))
        )
        if label.casefold() not in value.casefold():
            continue
        bounds = re.match(
            r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]",
            node.attrib.get("bounds", ""),
        )
        if bounds:
            left, top, right, bottom = map(int, bounds.groups())
            adb("shell", "input", "tap", str((left + right) // 2), str((top + bottom) // 2))
            return
    raise AssertionError(f"Android accessibility tree has no {label!r} control")


def assert_no_flutter_errors() -> None:
    log = adb("logcat", "-d", "-s", "flutter:I", "Flutter:I")
    (REPORTS / "flutter_logcat.txt").write_text(log)
    for error in (
        "Unable to load asset",
        "Asset not found",
        "A RenderFlex overflowed",
        "RIGHT OVERFLOWED",
        "EXCEPTION CAUGHT BY",
    ):
        if error in log:
            raise AssertionError(f"Runtime Flutter error: {error}")


def main() -> None:
    apk = "apps/kelime_avi_standalone/build/app/outputs/flutter-apk/app-debug.apk"
    adb("install", "-r", apk)
    adb("shell", "wm", "size", "360x800")
    adb("shell", "wm", "density", "160")
    adb("logcat", "-c")
    adb("shell", "am", "force-stop", PACKAGE)
    adb("shell", "monkey", "-p", PACKAGE, "-c", "android.intent.category.LAUNCHER", "1")
    time.sleep(6)

    home = capture("01_standalone_start")
    tap_label(home, "Oyna")
    hub = capture("02_home_hub")
    tap_label(hub, "Rotalar")
    routes = capture("03_route_selector")
    tap_label(routes, "Başlangıç Limanı")
    capture("04_starter_route")

    # The accepted 720x1280 master art has a transparent level-1 hitbox at
    # (136, 305). It is fitted by width into the 360 px Android viewport.
    # On this emulator the status/nav bars leave 752 px for the 640 px scene.
    adb("shell", "input", "tap", "68", "232")
    gameplay = capture("05_first_level_gameplay")
    assert any(
        "KALEM" in node.attrib.get("text", "")
        for node in gameplay.iter("node")
    ), "First gameplay screen did not open"
    assert_no_flutter_errors()
    (REPORTS / "PASS.txt").write_text(
        "Installed debug APK: start, hub, route selector, starter route, "
        "first gameplay screen; no asset or layout errors in Flutter logcat.\n"
    )


if __name__ == "__main__":
    try:
        main()
    finally:
        # Preserve useful evidence even if an intermediate screen assertion fails.
        try:
            assert_no_flutter_errors()
        except AssertionError:
            raise
