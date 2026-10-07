import unittest
import subprocess
import tempfile
from pathlib import Path
from unittest.mock import patch
import xml.etree.ElementTree as ET
import kelime_avi_journey_runtime_probe as probe
from kelime_avi_journey_runtime_probe import control, require_home, require_gameplay, require_clean_log, ERRORS


def tree(labels):
    root = ET.Element("hierarchy")
    for text in labels:
        ET.SubElement(root, "node", text=text, **{"content-desc": text,
                      "clickable": "true", "bounds": "[0,0][68,68]"})
    return root


class JourneyProbeTest(unittest.TestCase):
    def run_capture(self, responses, check=require_home):
        clock = [0.0]
        def sleep(seconds):
            clock[0] += seconds
        def command(*args, **kwargs):
            if "pidof" in args:
                return "123\n"
            if "screencap" in args:
                return b"png"
            if "dump" in args:
                response = responses.pop(0) if len(responses) > 1 else responses[0]
                if isinstance(response, Exception):
                    raise response
                command.xml = response
                return "dumped"
            return command.xml
        with tempfile.TemporaryDirectory() as folder, \
                patch.object(probe, "REPORTS", Path(folder)), \
                patch.object(probe, "adb", side_effect=command), \
                patch.object(probe.time, "monotonic", side_effect=lambda: clock[0]), \
                patch.object(probe.time, "sleep", side_effect=sleep):
            try:
                result = probe.capture("home", check, timeout=2)
            except AssertionError:
                self.assertTrue((Path(folder) / "home_readiness_failure.txt").exists())
                self.assertFalse((Path(folder) / "home.png").exists())
                raise
            self.assertTrue((Path(folder) / "home.png").exists())
            return result

    def test_transient_dump_failure_then_success(self):
        xml = ET.tostring(tree(["Bölüm 1", "DEVAM ET", "HARİTAYI AÇ"]), encoding="unicode")
        require_home(self.run_capture([
            subprocess.CalledProcessError(1, "uiautomator"), xml]))

    def test_empty_and_malformed_xml_then_success(self):
        xml = ET.tostring(tree(["Bölüm 1", "DEVAM ET", "HARİTAYI AÇ"]), encoding="unicode")
        require_home(self.run_capture(["", "not xml", xml]))

    def test_missing_semantics_then_success(self):
        xml = ET.tostring(tree(["Bölüm 1", "DEVAM ET", "HARİTAYI AÇ"]), encoding="unicode")
        require_home(self.run_capture(["<hierarchy/>", xml]))

    def test_all_dump_failures_timeout(self):
        with self.assertRaisesRegex(AssertionError, "not ready within"):
            self.run_capture([subprocess.CalledProcessError(1, "uiautomator")])

    def test_valid_xml_without_controls_timeout(self):
        with self.assertRaisesRegex(AssertionError, "Missing clickable"):
            self.run_capture(["<hierarchy/>"])

    def test_missing_gameplay_targets_timeout(self):
        xml = ET.tostring(tree(["KALEM"]), encoding="unicode")
        with self.assertRaisesRegex(AssertionError, "MASA"):
            self.run_capture([xml], require_gameplay)

    def test_delayed_process_and_never_started(self):
        for succeeds in (True, False):
            clock = [0.0]
            def sleep(seconds):
                clock[0] += seconds
            responses = [AssertionError("absent"), AssertionError("absent")]
            responses += [None] if succeeds else [AssertionError("absent")] * 4
            with patch.object(probe, "require_process", side_effect=responses), \
                    patch.object(probe.time, "monotonic", side_effect=lambda: clock[0]), \
                    patch.object(probe.time, "sleep", side_effect=sleep):
                if succeeds:
                    probe.wait_for_process(timeout=2)
                else:
                    with self.assertRaisesRegex(AssertionError, "did not start"):
                        probe.wait_for_process(timeout=2)

    def test_process_death_fails_without_ui_retry(self):
        with patch.object(probe, "adb", return_value="") as command:
            with self.assertRaisesRegex(AssertionError, "process died"):
                probe.capture("home", require_home)
            self.assertEqual(command.call_count, 1)

    def test_home_and_clickable_controls(self):
        root = tree(["Bölüm 1", "DEVAM ET", "HARİTAYI AÇ"])
        require_home(root)
        self.assertEqual(control(root, "DEVAM ET"), (34, 34))
        self.assertEqual(control(tree(["BÖLÜME GİT"]), "BÖLÜME GİT"), (34, 34))

    def test_legacy_and_missing_controls_rejected(self):
        for labels in (["Oyna", "Rotalar"], ["Bölüm 1", "DEVAM ET"]):
            with self.assertRaises(AssertionError):
                require_home(tree(labels))
        root = tree(["DEVAM ET"])
        root[0].set("clickable", "false")
        with self.assertRaises(AssertionError):
            control(root, "DEVAM ET")

    def test_real_canonical_gameplay_markers_required(self):
        words = ["KALEM", "MASA", "OYUN", "ROTA", "BİLGİ", "SİLGİ"]
        require_gameplay(tree(words))
        for missing in words:
            with self.assertRaises(AssertionError):
                require_gameplay(tree([w for w in words if w != missing]))
        with self.assertRaises(AssertionError):
            require_gameplay(tree(["Bölüm 1", "Sentetik oyun"]))

    def test_errors_fail_closed(self):
        require_clean_log("normal Flutter startup")
        for error in ERRORS:
            with self.assertRaises(AssertionError):
                require_clean_log(error)


if __name__ == "__main__":
    unittest.main()
