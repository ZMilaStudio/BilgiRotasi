import hashlib
from pathlib import Path
import tempfile
import unittest

from PIL import Image
from tools.validate_journey_art_pack import validate


class JourneyArtIntegrityTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="journey-art-validator-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        file = self.root / "base.png"
        Image.new("RGB", (8, 16), "navy").save(file)
        self.asset = {"path": "base.png", "intrinsicSize": [8, 16],
                      "sha256": hashlib.sha256(file.read_bytes()).hexdigest(),
                      "focalPoint": [0, 0]}
        self.kit = {"themeId": "test", "assets": [self.asset], "landmarks": [1]}

    def check(self, kit=None, bundle=None):
        return validate({"kits": [kit or self.kit]}, self.root,
                        {"base.png"} if bundle is None else bundle)

    def test_valid(self):
        self.assertEqual(self.check(), [])

    def test_missing_bundle(self):
        self.assertIn("not in Flutter bundle: base.png", self.check(bundle=set()))

    def test_hash_dimensions_focal(self):
        self.asset.update(sha256="0" * 64, intrinsicSize=[9, 16], focalPoint=[2, 0])
        errors = self.check()
        self.assertEqual(len(errors), 3)

    def test_duplicate_partner_owner(self):
        second = dict(self.kit, themeId="other", transitionPartner="missing")
        errors = validate({"kits": [self.kit, second]}, self.root, {"base.png"})
        self.assertEqual(len(errors), 3)

    def test_missing_and_path_escape(self):
        self.asset["path"] = "../private.png"
        self.assertEqual(self.check(), ["unsafe path: ../private.png"])
        self.asset["path"] = "missing.png"
        self.assertIn("missing file: missing.png", self.check())


if __name__ == "__main__":
    unittest.main()
