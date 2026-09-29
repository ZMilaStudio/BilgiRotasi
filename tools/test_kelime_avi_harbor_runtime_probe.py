"""Fail-closed contracts for the combined Android probe; synthetic unit evidence."""
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path
from unittest.mock import patch

import kelime_avi_harbor_runtime_probe as probe


def geometry():
    records = []
    for width, height in ((360, 800), (412, 915)):
        for scenario in ("mixed", "l20Playable", "segment3"):
            segment = 3 if scenario == "segment3" else 2
            first, last = (segment - 1) * 10 + 1, segment * 10
            def add(key, rect):
                records.append(dict(scenario=scenario, logicalWidth=width,
                                    logicalHeight=height, key=key,
                                    rect=dict(left=rect[0], top=rect[1],
                                              right=rect[2], bottom=rect[3])))
            add(f"word_hunt_harbor_scene_{segment}", (0, 0, width, height))
            for level in range(first, last + 1):
                offset = level - first
                x, y = 15 + (offset % 3) * 105, 90 + (offset // 3) * 155
                add(f"word_hunt_harbor_level_{level}", (x, y, x + 68, y + 68))
            add(f"word_hunt_harbor_medallion_{last}", (22, 562, 76, 616))
            if scenario != "mixed":
                add(f"word_hunt_harbor_challenge_{last}", (5, 630, 93, 650))
    return records


def segment3_xml():
    root = ET.Element("hierarchy")
    for level in range(21, 31):
        offset = level - 21
        x, y = 15 + offset % 3 * 105, 90 + offset // 3 * 155
        stars = level % 3 + 1 if level <= 28 else 0
        state = "açık" if level <= 29 else "kilitli"
        challenge = "meydan okuma, " if level == 30 else ""
        ET.SubElement(root, "node", {
            "content-desc": f"Bölüm {level}, {challenge}{state}, {stars} yıldız",
            "clickable": "true" if level <= 29 else "false",
            "bounds": f"[{x},{y}][{x+68},{y+68}]",
        })
    return root


class ProbeContractTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.reports = patch.object(probe, "REPORTS", Path(self.directory.name))
        self.reports.start()
        self.addCleanup(self.reports.stop)
        for values in (probe.FAILURES, probe.CAPTURES, probe.ACCESSIBILITY,
                       probe.SEMANTICS_AGGREGATED):
            values.clear()

    def test_all_six_geometry_groups_are_required(self):
        probe.verify_geometry(geometry())
        with self.assertRaisesRegex(AssertionError, "Missing Flutter geometry"):
            probe.verify_geometry([r for r in geometry() if r["scenario"] != "segment3"])

    def test_l20_plaque_clipping_is_rejected(self):
        records = geometry()
        for record in records:
            if record["key"] == "word_hunt_harbor_challenge_20":
                record["rect"]["right"] = 999
        with self.assertRaisesRegex(AssertionError, "plaque clipped"):
            probe.verify_geometry(records)

    def test_l20_plaque_overlap_and_not_below_are_rejected(self):
        records = geometry()
        for record in records:
            if record["key"] == "word_hunt_harbor_challenge_20":
                record["rect"].update(top=600, bottom=625)
        with self.assertRaisesRegex(AssertionError, "not below"):
            probe.verify_geometry(records)

    def test_l30_plaque_clipping_is_rejected(self):
        records = geometry()
        for record in records:
            if record["key"] == "word_hunt_harbor_challenge_30":
                record["rect"]["bottom"] = 999
        with self.assertRaisesRegex(AssertionError, "plaque clipped"):
            probe.verify_geometry(records)

    def test_exact_hitbox_and_non_overlap_remain_strict(self):
        records = geometry()
        records[1]["rect"]["right"] += 1
        with self.assertRaisesRegex(AssertionError, "not 68dp"):
            probe.verify_geometry(records)
        records = geometry()
        records[2]["rect"] = dict(records[1]["rect"])
        with self.assertRaisesRegex(AssertionError, "RenderBox overlap"):
            probe.verify_geometry(records)

    def test_segment3_all_nodes_stars_locks_and_independent_taps(self):
        with patch.object(probe, "adb") as adb:
            probe.verify_segment3(segment3_xml(), 360, 800)
            self.assertEqual(adb.call_count, 2)
        root = segment3_xml()
        root[-1].set("clickable", "true")
        with self.assertRaisesRegex(AssertionError, "clickable"):
            probe.verify_segment3(root, 360, 800)

    def test_segment3_missing_node_and_wrong_stars_fail(self):
        root = segment3_xml()
        root.remove(root[0])
        with self.assertRaisesRegex(AssertionError, "expected one"):
            probe.verify_segment3(root, 360, 800)
        root = segment3_xml()
        root[0].set("content-desc", "Bölüm 21, açık, 0 yıldız")
        with self.assertRaisesRegex(AssertionError, "fixture stars"):
            probe.verify_segment3(root, 360, 800)

    def test_l30_distinct_plaque_overlap_fails(self):
        root = segment3_xml()
        ET.SubElement(root, "node", {"content-desc": "MEYDAN OKUMA",
                                     "bounds": "[20,100][100,120]"})
        with self.assertRaisesRegex(AssertionError, "clipped/not below"):
            probe.verify_segment3(root, 360, 800)

    def test_missing_capture_fails_final_result(self):
        probe.write_result()
        self.assertIn("RESULT=FAIL", (probe.REPORTS / "HARBOR_RESULT.txt").read_text())
        self.assertTrue(probe.FAILURES)


if __name__ == "__main__":
    unittest.main()
