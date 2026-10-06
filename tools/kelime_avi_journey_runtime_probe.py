"""Real no-define standalone Journey Android runtime proof (not a fixture)."""
from pathlib import Path
import os
import re
import subprocess
import time
import xml.etree.ElementTree as ET

PACKAGE = "com.zmilastudio.kelimeavi"
REPORTS = Path("reports/kelime_avi_runtime/journey-default")
ERRORS = ("Unable to load asset", "Asset not found", "RenderFlex overflow",
          "A RenderFlex overflowed", "RIGHT OVERFLOWED", "EXCEPTION CAUGHT BY",
          "FATAL EXCEPTION", "ANR in " + PACKAGE)


def adb(*args, binary=False):
    return subprocess.check_output(["adb", *args], text=not binary)


def label(node):
    return (node.get("text", "") + " " + node.get("content-desc", "")).strip()


def control(root, text):
    for node in root.iter("node"):
        if text.casefold() in label(node).casefold() and node.get("clickable") == "true":
            match = re.fullmatch(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", node.get("bounds", ""))
            if match:
                a, b, c, d = map(int, match.groups())
                if c > a and d > b:
                    return ((a + c) // 2, (b + d) // 2)
    raise AssertionError(f"Missing clickable Journey control: {text}")


def require_home(root):
    control(root, "DEVAM ET")
    control(root, "HARİTAYI AÇ")
    assert any("Bölüm 1" in (n.get("text"), n.get("content-desc"))
               for n in root.iter("node")), "Not fresh Journey home"


def require_gameplay(root):
    # Canonical real L1 targets, not map labels or a synthetic level screen.
    for word in ("KALEM", "MASA", "OYUN", "ROTA", "BİLGİ", "SİLGİ"):
        assert any(word in n.get("content-desc", "") for n in root.iter("node")), word


def require_clean_log(log):
    for error in ERRORS:
        assert error.casefold() not in log.casefold(), f"Runtime error: {error}"


def capture(name, check):
    xml = ""
    for _ in range(15):
        adb("shell", "uiautomator", "dump", "/sdcard/window.xml")
        xml = adb("exec-out", "cat", "/sdcard/window.xml")
        root = ET.fromstring(xml)
        try:
            check(root)
            break
        except AssertionError:
            time.sleep(1)
    else:
        (REPORTS / f"{name}.xml").write_text(xml, encoding="utf-8")
        check(root)
    (REPORTS / f"{name}.xml").write_text(xml, encoding="utf-8")
    (REPORTS / f"{name}.png").write_bytes(adb("exec-out", "screencap", "-p", binary=True))
    return root


def tap(root, text):
    x, y = control(root, text)
    adb("shell", "input", "tap", str(x), str(y))


def main():
    REPORTS.mkdir(parents=True, exist_ok=True)
    apk = os.environ["JOURNEY_APK"]
    adb("install", "-r", apk)
    adb("shell", "pm", "clear", PACKAGE)  # Fresh emulator only, not owner storage.
    adb("shell", "wm", "size", "360x800")
    adb("shell", "wm", "density", "160")
    adb("logcat", "-c")
    adb("shell", "monkey", "-p", PACKAGE, "-c", "android.intent.category.LAUNCHER", "1")
    try:
        home = capture("01_home", require_home)
        tap(home, "DEVAM ET")
        def require_map(root):
            control(root, "BÖLÜME GİT")
            control(root, "Bölüm 1, açık")
        route = capture("02_map", require_map)
        tap(route, "Bölüm 1, açık")
        capture("03_real_l1", require_gameplay)
        assert adb("shell", "pidof", PACKAGE).strip(), "App process died"
    finally:
        log = adb("logcat", "-d")
        (REPORTS / "logcat.txt").write_text(log, encoding="utf-8")
        require_clean_log(log)
    (REPORTS / "PASS.txt").write_text("Real default Journey home/map/L1 PASS\n", encoding="utf-8")


if __name__ == "__main__":
    main()
