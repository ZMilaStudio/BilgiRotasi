import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from xml.etree import ElementTree

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "harbor_layout_preview.py"
SPEC = importlib.util.spec_from_file_location("harbor_layout_preview", SCRIPT)
PREVIEW = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PREVIEW)


class HarborLayoutPreviewTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix="harbor-preview-test-")
        cls.tmp = Path(cls.temp.name)
        cls.manifest_dir = cls.tmp / "manifests"
        baseline = ROOT / "test" / "fixtures" / "harbor" / "legacy_production_parity_baseline.json"
        cls.manifest_paths = PREVIEW.emit_legacy_test_manifests(baseline, cls.manifest_dir)

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def test_two_manifest_fixtures_cover_exact_segments_and_ids(self):
        for segment, path in zip((2, 3), self.manifest_paths, strict=True):
            manifest, _, _, _ = PREVIEW.load_manifest(path)
            source = json.loads((ROOT / "test/fixtures/harbor/legacy_production_parity_baseline.json").read_text())
            expected = source["source"]["segments"][str(segment)]["levelIds"]
            self.assertEqual([node["levelId"] for node in manifest["nodes"]], expected)
            self.assertEqual(len(set(expected)), 10)
            self.assertEqual(len(manifest["connections"]), 9)
            self.assertTrue(all(edge["fromLevelId"] == expected[index] and edge["toLevelId"] == expected[index + 1]
                                for index, edge in enumerate(manifest["connections"])))
            self.assertTrue(all(node["starAnchor"]["unit"] == "nodeRelativeLogicalDp" for node in manifest["nodes"]))
            self.assertEqual([node["levelId"] for node in manifest["nodes"] if "challengeAnchor" in node], [expected[-1]])

    def test_real_asset_hashes_and_pinned_bytes_are_verified(self):
        for path in self.manifest_paths:
            manifest, _, asset, digest = PREVIEW.load_manifest(path)
            actual = hashlib.sha256(asset.read_bytes()).hexdigest()
            self.assertEqual(actual, digest)
            self.assertEqual(actual, PREVIEW.APPROVED_ASSETS[manifest["scene"]["assetPath"]])

    def test_mixed_units_and_bad_digest_fail_closed(self):
        path = self.manifest_paths[0]
        manifest = json.loads(path.read_text())
        manifest["nodes"][0]["starAnchor"]["unit"] = "scenePixels"
        bad = self.tmp / "mixed-unit.json"
        bad.write_text(json.dumps(manifest))
        with self.assertRaisesRegex(PREVIEW.PreviewError, "starAnchor.unit"):
            PREVIEW.load_manifest(bad)

        manifest = json.loads(path.read_text())
        manifest["scene"]["sha256"] = "0" * 64
        bad.write_text(json.dumps(manifest))
        with self.assertRaisesRegex(PREVIEW.PreviewError, "pinned SHA-256"):
            PREVIEW.load_manifest(bad)

    def test_one_manifest_generates_svg_and_png_for_both_viewports(self):
        for segment, manifest_path in zip((2, 3), self.manifest_paths, strict=True):
            out = self.tmp / f"one-manifest-segment-{segment}"
            products = PREVIEW.render_manifest(manifest_path, out, [(360, 800), (412, 915)])
            self.assertEqual(len(products), 4)
            first_level = 11 if segment == 2 else 21
            for width, height in ((360, 800), (412, 915)):
                stem = f"segment_{segment}_{width}x{height}_TECHNICAL_PREVIEW_NOT_APPROVED_DESIGN"
                svg = (out / f"{stem}.svg").read_text(encoding="utf-8")
                self.assertIn(PREVIEW.LABEL, svg)
                for layer in ("connections", "hitboxes", "nodes", "stars", "challenges"):
                    self.assertIn(f'id="{layer}"', svg)
                for level in range(first_level, first_level + 10):
                    level_id = f"baslangic-{level}"
                    self.assertIn(f'data-level-id="{level_id}"', svg)
                    self.assertIn(f'id="stars-{level_id}"', svg)
                    if level < first_level + 9:
                        self.assertIn(f'id="edge-{level_id}-baslangic-{level + 1}"', svg)
                self.assertIn(f'id="challenge-baslangic-{first_level + 9}"', svg)
                self.assertIn('>STAR ANCHOR</text>', svg)
                png_path = out / f"{stem}.png"
                with Image.open(png_path) as image:
                    self.assertEqual(image.size, (width, height))
                    self.assertEqual(image.format, "PNG")
                    self.assertEqual(image.info["Title"], PREVIEW.LABEL)
                    self.assertEqual(image.info["Manifest-Schema-Version"], "2")
                    asset_path = f"assets/word_hunt/harbor_segments/segment_0{segment}_clean.webp"
                    self.assertEqual(image.info["Scene-Asset-SHA256"], PREVIEW.APPROVED_ASSETS[asset_path])

    def test_repeat_generation_is_byte_deterministic(self):
        first = self.tmp / "repeat-a"
        second = self.tmp / "repeat-b"
        PREVIEW.render_manifest(self.manifest_paths[1], first, [(360, 800), (412, 915)])
        PREVIEW.render_manifest(self.manifest_paths[1], second, [(360, 800), (412, 915)])
        for name in sorted(path.name for path in first.iterdir()):
            self.assertEqual((first / name).read_bytes(), (second / name).read_bytes(), name)

    def test_logical_offsets_are_added_after_scene_scaling(self):
        node_center = (180.0, 350.0)
        star_offset = (0.0, 42.5)
        projected_offsets = []
        for viewport in ((360, 800), (412, 915)):
            scale, tx, ty = PREVIEW._transform(*SCENE_SIZE, *viewport)
            center = PREVIEW._project(node_center, scale, tx, ty)
            star = PREVIEW._project_offset(node_center, star_offset, scale, tx, ty)
            projected_offsets.append(star[1] - center[1])
        self.assertAlmostEqual(projected_offsets[0], 42.5)
        self.assertAlmostEqual(projected_offsets[1], 42.5)

    def test_cover_transform_matches_checkpoint_b_for_both_screens(self):
        baseline = json.loads((ROOT / "test/fixtures/harbor/legacy_production_parity_baseline.json").read_text())
        for expected in baseline["viewportContract"]["expected"]:
            width, height = expected["screen"]
            map_width, map_height = expected["mapViewport"]
            scale, tx, ty = PREVIEW._transform(*SCENE_SIZE, width, height)
            self.assertAlmostEqual(scale, expected["scale"], places=12)
            self.assertAlmostEqual(tx, expected["translation"][0], places=9)
            self.assertAlmostEqual(ty, 76 + expected["translation"][1], places=9)
            self.assertEqual(height - 76, map_height)
            self.assertEqual(map_width, width)

    def test_design_candidate_has_scene_specific_manifest_and_bounded_layout(self):
        path = ROOT / "test/fixtures/harbor/segment_2_design_candidate_manifest.json"
        manifest, _, asset, digest = PREVIEW.load_manifest(path)
        self.assertEqual(digest, PREVIEW.APPROVED_ASSETS[manifest["scene"]["assetPath"]])
        self.assertEqual(hashlib.sha256(asset.read_bytes()).hexdigest(), digest)
        self.assertEqual([n["levelId"] for n in manifest["nodes"]], [f"baslangic-{n}" for n in range(11, 21)])
        self.assertEqual(len(manifest["connections"]), 9)
        self.assertEqual([n["levelId"] for n in manifest["nodes"] if "challengeAnchor" in n], ["baslangic-20"])
        for width, height in ((360, 800), (412, 915)):
            self.assertEqual(len(PREVIEW.validate_design_bounds(manifest, width, height)), 10)
        with self.assertRaisesRegex(PREVIEW.PreviewError, "only supports Segment 2"):
            PREVIEW.validate_design_bounds(manifest, 320, 640)

    def test_design_candidate_both_outputs_are_editable_and_deterministic(self):
        manifest = ROOT / "test/fixtures/harbor/segment_2_design_candidate_manifest.json"
        first, second = self.tmp / "design-a", self.tmp / "design-b"
        for out in (first, second):
            PREVIEW.render_manifest(manifest, out, [(360, 800), (412, 915)], design_preview=True)
        for name in sorted(path.name for path in first.iterdir()):
            self.assertEqual((first / name).read_bytes(), (second / name).read_bytes(), name)
            if name.endswith(".svg"):
                svg = (first / name).read_text(encoding="utf-8")
                ElementTree.fromstring(svg)
                for layer in ("scene-art", "connections", "nodes", "stars", "challenges", "header", "segment-navigation"):
                    self.assertIn(f'id="{layer}"', svg)
                for level in range(11, 21):
                    self.assertIn(f'id="node-baslangic-{level}"', svg)
                    self.assertIn(f'id="stars-baslangic-{level}"', svg)
                self.assertIn('id="challenge-baslangic-20"', svg)
                self.assertIn('#FFD45B', svg)
                self.assertIn('#65717D', svg)
                self.assertNotIn('STAR ANCHOR', svg)
                self.assertNotIn('CHALLENGE ANCHOR', svg)
                self.assertNotIn('id="hitboxes"', svg)
            else:
                with Image.open(first / name) as image:
                    self.assertEqual(image.size, (360, 800) if "360x800" in name else (412, 915))
                    self.assertEqual(image.info["Title"], PREVIEW.DESIGN_LABEL)
                    self.assertIn("illustrative", image.info["Progression"])

    def test_design_mode_rejects_edge_clipping_instead_of_emitting_a_fake_pass(self):
        path = ROOT / "test/fixtures/harbor/segment_2_design_candidate_manifest.json"
        manifest, _, _, _ = PREVIEW.load_manifest(path)
        manifest["nodes"][0]["_center"] = (0.0, 1475.0)
        with self.assertRaisesRegex(PREVIEW.PreviewError, "clipped"):
            PREVIEW.validate_design_bounds(manifest, 360, 800)


SCENE_SIZE = (941, 1672)


if __name__ == "__main__":
    unittest.main()
