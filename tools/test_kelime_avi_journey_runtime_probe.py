import unittest
import xml.etree.ElementTree as ET
from kelime_avi_journey_runtime_probe import control, require_home, require_gameplay, require_clean_log, ERRORS


def tree(labels):
    root = ET.Element("hierarchy")
    for text in labels:
        ET.SubElement(root, "node", text=text, **{"content-desc": text,
                      "clickable": "true", "bounds": "[0,0][68,68]"})
    return root


class JourneyProbeTest(unittest.TestCase):
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
