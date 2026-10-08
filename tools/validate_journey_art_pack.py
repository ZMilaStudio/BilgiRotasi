"""Install-time raster integrity; never a per-frame hash/decode operation.

Input: JourneyArtRegistry.installationManifest(), plus a JSON list exported from
Flutter AssetManifest.listAssets() in the target app's real asset bundle.
No assets are generated or changed. Pillow is the existing image tooling dependency.
"""
import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image


def validate(manifest, root, bundled):
    errors = []
    kits = manifest.get("kits", [])
    ids = [kit["themeId"] for kit in kits]
    if len(set(ids)) != len(ids):
        errors.append("duplicate theme ID")
    seen, owners = set(), set()
    for kit in kits:
        partner = kit.get("transitionPartner")
        if partner is not None and partner not in ids:
            errors.append(f"missing transition partner: {partner}")
        for ordinal in kit.get("landmarks", []):
            if ordinal in owners:
                errors.append(f"duplicate landmark ownership: {ordinal}")
            owners.add(ordinal)
        for asset in kit["assets"]:
            name = asset["path"]
            if name in seen:
                errors.append(f"duplicate path: {name}")
            seen.add(name)
            file = (root / name).resolve()
            if not file.is_relative_to(root.resolve()):
                errors.append(f"unsafe path: {name}")
                continue
            if name not in bundled:
                errors.append(f"not in Flutter bundle: {name}")
            focal = asset["focalPoint"]
            if len(focal) != 2 or not all(isinstance(n, (int, float)) and -1 <= n <= 1 for n in focal):
                errors.append(f"invalid focal point: {name}")
            if not file.is_file():
                errors.append(f"missing file: {name}")
                continue
            if hashlib.sha256(file.read_bytes()).hexdigest() != asset["sha256"]:
                errors.append(f"SHA-256 mismatch: {name}")
            try:
                with Image.open(file) as image:
                    image.load()
                    if list(image.size) != asset["intrinsicSize"] or min(image.size) <= 0:
                        errors.append(f"intrinsic dimensions mismatch: {name}")
            except (OSError, ValueError) as error:
                errors.append(f"invalid raster: {name}: {error}")
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--bundle-assets", required=True, type=Path)
    args = parser.parse_args()
    errors = validate(json.loads(args.manifest.read_text(encoding="utf-8")),
                      args.root, set(json.loads(args.bundle_assets.read_text(encoding="utf-8"))))
    print(json.dumps({"errors": errors, "valid": not errors}, ensure_ascii=False))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
