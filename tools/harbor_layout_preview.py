#!/usr/bin/env python3
"""Render schema-v2 Harbor layout manifests as editable SVG and PNG proofs.

Technical previews are explicitly not approved map designs. The renderer only
consumes scene art and manifest geometry; it never changes production files.
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import html
import json
import math
from pathlib import Path
import sys

try:
    from PIL import Image, ImageDraw, ImageFont, PngImagePlugin
except ImportError as error:  # pragma: no cover - runtime dependency diagnostic
    raise SystemExit("Pillow is required to create PNG previews; no substitute PNG is generated.") from error


ROOT = Path(__file__).resolve().parents[1]
SCENE_SIZE = (941, 1672)
HEADER_DP = 76
NAV_DP = 64
APPROVED_ASSETS = {
    "assets/word_hunt/harbor_segments/segment_02_clean.webp":
        "cd115f2eb3866beb4e1375ad545e31c23dce60b02d23d960f9b46b9c5828b566",
    "assets/word_hunt/harbor_segments/segment_03_clean.webp":
        "230ea2158d8173029123dfb6b68593c2b015d4f278ad524b94221c8de9ae231c",
}
LABEL = "TECHNICAL PREVIEW - NOT APPROVED DESIGN"
DESIGN_LABEL = "DESIGN CANDIDATE - OWNER REVIEW PENDING"
# Presentation-only sample, never read from or written to player progression.
ILLUSTRATIVE_STARS = (3, 2, 1, 0, 0, 0, 0, 0, 0, 0)


class PreviewError(ValueError):
    pass


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _point(value: object, expected_unit: str, name: str, scene_size: tuple[int, int]):
    if not isinstance(value, dict) or set(value) != {"unit", "x", "y"}:
        raise PreviewError(f"{name}: expected exactly unit/x/y fields")
    if value["unit"] != expected_unit:
        raise PreviewError(f"{name}.unit must be {expected_unit}")
    x, y = value["x"], value["y"]
    if isinstance(x, bool) or isinstance(y, bool) or not isinstance(x, (int, float)) or not isinstance(y, (int, float)):
        raise PreviewError(f"{name}: coordinates must be finite numbers")
    if not math.isfinite(x) or not math.isfinite(y):
        raise PreviewError(f"{name}: coordinates must be finite numbers")
    if expected_unit == "scenePixels" and not (0 <= x <= scene_size[0] and 0 <= y <= scene_size[1]):
        raise PreviewError(f"{name}: scene-pixel point lies outside the scene")
    return float(x), float(y)


def _require_keys(value: object, expected: set[str], name: str):
    if not isinstance(value, dict) or set(value) != expected:
        raise PreviewError(f"{name}: fields must be exactly {', '.join(sorted(expected))}")


def load_manifest(manifest_path: Path) -> tuple[dict, bytes, Path, str]:
    raw = manifest_path.read_bytes()
    try:
        manifest = json.loads(raw)
    except json.JSONDecodeError as error:
        raise PreviewError(f"manifest JSON invalid: {error}") from error
    if not isinstance(manifest, dict) or type(manifest.get("schemaVersion")) is not int or manifest.get("schemaVersion") != 2:
        raise PreviewError("manifest schemaVersion must be 2")
    segment_value = manifest.get("segmentIndex")
    if manifest.get("routeId") != "baslangic-limani" or isinstance(segment_value, bool) or not isinstance(segment_value, int) or segment_value not in (2, 3):
        raise PreviewError("only Baslangic Limani Segment 2/3 manifests are supported")
    scene = manifest.get("scene")
    _require_keys(manifest, {"schemaVersion", "routeId", "segmentIndex", "scene", "minimumHitTargetLogicalDp", "nodes", "connections"}, "manifest")
    _require_keys(scene, {"assetPath", "coordinateSpace", "coordinateSize", "sha256"}, "scene")
    if (not isinstance(scene, dict) or scene.get("coordinateSpace") != "scenePixels"
            or scene.get("coordinateSize") != list(SCENE_SIZE)
            or any(type(value) is not int for value in scene.get("coordinateSize", []))):
        raise PreviewError("scene must use scenePixels and the 941x1672 source canvas")
    hit_target = manifest["minimumHitTargetLogicalDp"]
    if isinstance(hit_target, bool) or not isinstance(hit_target, (int, float)) or not math.isfinite(hit_target) or hit_target < 48:
        raise PreviewError("minimumHitTargetLogicalDp must be a finite number of at least 48")
    asset_path = scene.get("assetPath")
    if asset_path not in APPROVED_ASSETS:
        raise PreviewError("scene asset is not an approved clean Segment 2/3 asset")
    asset_file = ROOT / asset_path
    asset_bytes = asset_file.read_bytes()
    actual_digest = sha256(asset_bytes)
    manifest_digest = scene.get("sha256")
    if (actual_digest != APPROVED_ASSETS[asset_path] or not isinstance(manifest_digest, str)
            or manifest_digest.lower() != actual_digest):
        raise PreviewError("scene asset bytes do not match the pinned SHA-256")
    with Image.open(asset_file) as image:
        if image.size != SCENE_SIZE or image.format != "WEBP":
            raise PreviewError("scene asset must be a 941x1672 WebP")

    first_level = 11 if manifest["segmentIndex"] == 2 else 21
    expected_ids = [f"baslangic-{n}" for n in range(first_level, first_level + 10)]
    nodes = manifest.get("nodes")
    if not isinstance(nodes, list) or len(nodes) != 10:
        raise PreviewError("manifest must contain exactly ten nodes")
    if [node.get("levelId") for node in nodes] != expected_ids:
        raise PreviewError("node IDs must be the complete ordered absolute segment IDs")
    by_id = {}
    for index, node in enumerate(nodes):
        if not isinstance(node, dict):
            raise PreviewError(f"nodes[{index}] must be an object")
        allowed = {"levelId", "center", "connectionAnchor", "starAnchor", "challengeAnchor"}
        if set(node) - allowed or not {"levelId", "center", "connectionAnchor", "starAnchor"}.issubset(node):
            raise PreviewError(f"nodes[{index}]: unsupported or missing fields")
        level_id = node["levelId"]
        if level_id in by_id:
            raise PreviewError(f"duplicate node ID: {level_id}")
        node["_center"] = _point(node.get("center"), "scenePixels", f"nodes[{index}].center", SCENE_SIZE)
        node["_connection_anchor"] = _point(node.get("connectionAnchor"), "scenePixels", f"nodes[{index}].connectionAnchor", SCENE_SIZE)
        node["_star_offset"] = _point(node.get("starAnchor"), "nodeRelativeLogicalDp", f"nodes[{index}].starAnchor", SCENE_SIZE)
        dx = node["_connection_anchor"][0] - node["_center"][0]
        dy = node["_connection_anchor"][1] - node["_center"][1]
        review_scales = [max(360 / SCENE_SIZE[0], (800 - HEADER_DP) / SCENE_SIZE[1]),
                         max(412 / SCENE_SIZE[0], (915 - HEADER_DP) / SCENE_SIZE[1])]
        if math.hypot(dx, dy) * max(review_scales) > 27.001:
            raise PreviewError(f"nodes[{index}].connectionAnchor is outside the visual ring")
        if node.get("challengeAnchor") is not None:
            node["_challenge_offset"] = _point(node["challengeAnchor"], "nodeRelativeLogicalDp", f"nodes[{index}].challengeAnchor", SCENE_SIZE)
        by_id[level_id] = node

    edges = manifest.get("connections")
    if not isinstance(edges, list) or len(edges) != 9:
        raise PreviewError("manifest must contain exactly nine connections")
    for index, edge in enumerate(edges):
        _require_keys(edge, {"fromLevelId", "toLevelId", "start", "control1", "control2", "end"}, f"connections[{index}]")
        source_id, target_id = expected_ids[index], expected_ids[index + 1]
        if edge.get("fromLevelId") != source_id or edge.get("toLevelId") != target_id:
            raise PreviewError(f"connections[{index}] is not the correctly ordered adjacent edge")
        for field in ("start", "control1", "control2", "end"):
            edge[f"_{field}"] = _point(edge.get(field), "scenePixels", f"connections[{index}].{field}", SCENE_SIZE)
        if edge["_start"] != by_id[source_id]["_connection_anchor"] or edge["_end"] != by_id[target_id]["_connection_anchor"]:
            raise PreviewError(f"connections[{index}] endpoints must equal their node connection anchors")
    return manifest, raw, asset_file, actual_digest


def _transform(scene_width: int, scene_height: int, screen_width: int, screen_height: int):
    viewport_height = screen_height - HEADER_DP
    scale = max(screen_width / scene_width, viewport_height / scene_height)
    tx = (screen_width - scene_width * scale) / 2
    ty = HEADER_DP + (viewport_height - scene_height * scale) / 2
    return scale, tx, ty


def _project(point, scale, tx, ty):
    return tx + point[0] * scale, ty + point[1] * scale


def _project_offset(center, offset, scale, tx, ty):
    x, y = _project(center, scale, tx, ty)
    return x + offset[0], y + offset[1]


def _cubic(p0, p1, p2, p3, t):
    q = 1 - t
    return (q**3*p0[0] + 3*q*q*t*p1[0] + 3*q*t*t*p2[0] + t**3*p3[0],
            q**3*p0[1] + 3*q*q*t*p1[1] + 3*q*t*t*p2[1] + t**3*p3[1])


def _svg(manifest, asset_bytes, source_digest, asset_digest, width, height) -> bytes:
    scale, tx, ty = _transform(*SCENE_SIZE, width, height)
    scene_width, scene_height = SCENE_SIZE
    asset_uri = "data:image/webp;base64," + base64.b64encode(asset_bytes).decode("ascii")
    clip_id = "map-viewport"
    pieces = [
        f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        f"<title>{html.escape(LABEL)}</title>",
        f"<desc>Schema v{manifest['schemaVersion']}; manifest SHA-256 {source_digest}; scene asset SHA-256 {asset_digest}. Technical geometry only.</desc>",
        f'<defs><clipPath id="{clip_id}"><rect x="0" y="{HEADER_DP}" width="{width}" height="{height-HEADER_DP}"/></clipPath></defs>',
        '<rect width="100%" height="100%" fill="#071629"/>',
        f'<text x="8" y="25" fill="#ffd45b" font-family="sans-serif" font-size="10">{html.escape(LABEL)}</text>',
        f'<g id="scene-art" clip-path="url(#{clip_id})"><image x="{tx:.8f}" y="{ty:.8f}" width="{scene_width*scale:.8f}" height="{scene_height*scale:.8f}" preserveAspectRatio="none" xlink:href="{asset_uri}"/></g>',
        '<g id="connections" fill="none" stroke="#ff00c8" stroke-width="2" opacity="0.82">',
    ]
    for edge in manifest["connections"]:
        pts = [_project(edge[f"_{name}"], scale, tx, ty) for name in ("start", "control1", "control2", "end")]
        pieces.append(f'<path id="edge-{html.escape(edge["fromLevelId"])}-{html.escape(edge["toLevelId"])}" d="M {pts[0][0]:.5f},{pts[0][1]:.5f} C {pts[1][0]:.5f},{pts[1][1]:.5f} {pts[2][0]:.5f},{pts[2][1]:.5f} {pts[3][0]:.5f},{pts[3][1]:.5f}"/>')
    pieces.append('</g><g id="hitboxes" fill="none" stroke="#00d5ff" stroke-dasharray="3 2" stroke-width="0.7">')
    for node in manifest["nodes"]:
        cx, cy = _project(node["_center"], scale, tx, ty)
        level_id = html.escape(node["levelId"])
        pieces.append(f'<rect id="hitbox-{level_id}" x="{cx-34:.5f}" y="{cy-34:.5f}" width="68" height="68"/>')
    pieces.append('</g><g id="nodes" fill="#0a1c2c" fill-opacity="0.92" stroke="#f0b95e" stroke-width="2">')
    for node in manifest["nodes"]:
        cx, cy = _project(node["_center"], scale, tx, ty)
        level_id = html.escape(node["levelId"])
        pieces.append(f'<g id="node-{level_id}" data-level-id="{level_id}"><circle cx="{cx:.5f}" cy="{cy:.5f}" r="27"/><circle cx="{cx:.5f}" cy="{cy:.5f}" r="23" fill="none" stroke="#00d5ff" stroke-width="0.7"/><text x="{cx:.5f}" y="{cy+5:.5f}" text-anchor="middle" fill="#fff5e8" stroke="none" font-family="sans-serif" font-size="14">{level_id.rsplit('-',1)[1]}</text></g>')
    pieces.append('</g><g id="stars" fill="none" stroke="#ffd45b" stroke-width="1.2" font-family="sans-serif" font-size="6" text-anchor="middle">')
    for node in manifest["nodes"]:
        cx, cy = _project_offset(node["_center"], node["_star_offset"], scale, tx, ty)
        level_id = html.escape(node["levelId"])
        pieces.append(f'<g id="stars-{level_id}" data-level-id="{level_id}"><circle cx="{cx:.5f}" cy="{cy:.5f}" r="4"/><path d="M {cx-6:.5f},{cy:.5f} H {cx+6:.5f} M {cx:.5f},{cy-6:.5f} V {cy+6:.5f}"/><text x="{cx+13:.5f}" y="{cy+2:.5f}" fill="#ffd45b" stroke="none">STAR ANCHOR</text></g>')
    pieces.append('</g><g id="challenges" fill="#ffffff" stroke="#d39b5a" stroke-width="1" font-family="sans-serif" font-size="8" text-anchor="middle">')
    for node in manifest["nodes"]:
        if "_challenge_offset" not in node:
            continue
        cx, cy = _project_offset(node["_center"], node["_challenge_offset"], scale, tx, ty)
        level_id = html.escape(node["levelId"])
        pieces.append(f'<g id="challenge-{level_id}" data-level-id="{level_id}"><rect x="{cx-66:.5f}" y="{cy-11:.5f}" width="132" height="22" rx="4" fill="#161d27"/><text x="{cx:.5f}" y="{cy+3:.5f}" stroke="none">CHALLENGE ANCHOR</text></g>')
    pieces.append('</g></svg>')
    return "\n".join(pieces).encode("utf-8")


def _render_png(manifest, asset_file, source_digest, asset_digest, width, height, out_path):
    scale, tx, ty = _transform(*SCENE_SIZE, width, height)
    canvas = Image.new("RGBA", (width, height), (7, 22, 41, 255))
    with Image.open(asset_file) as opened:
        scene = opened.convert("RGBA")
    resized = scene.resize((round(SCENE_SIZE[0]*scale), round(SCENE_SIZE[1]*scale)), Image.Resampling.LANCZOS)
    canvas.paste(resized, (round(tx), round(ty)))
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rectangle((0, 0, width, HEADER_DP), fill=(7, 18, 34, 245))
    draw.text((8, 8), LABEL, fill=(255, 212, 91, 255))
    draw.text((8, 28), f"manifest v{manifest['schemaVersion']}  sha256:{source_digest[:12]}", fill=(220, 225, 231, 255))
    draw.text((8, 44), f"scene sha256:{asset_digest[:12]}  Segment {manifest['segmentIndex']}", fill=(220, 225, 231, 255))

    def project(p): return _project(p, scale, tx, ty)
    for edge in manifest["connections"]:
        p = [project(edge[f"_{name}"]) for name in ("start", "control1", "control2", "end")]
        samples = [_cubic(*p, i/64) for i in range(65)]
        draw.line(samples, fill=(255, 0, 200, 220), width=2)
    for node in manifest["nodes"]:
        cx, cy = project(node["_center"])
        draw.rectangle((cx-34, cy-34, cx+34, cy+34), outline=(0, 213, 255, 210), width=1)
        draw.ellipse((cx-27, cy-27, cx+27, cy+27), fill=(10, 28, 44, 235), outline=(240, 185, 94, 255), width=2)
        draw.ellipse((cx-23, cy-23, cx+23, cy+23), outline=(0, 213, 255, 230), width=1)
        number = node["levelId"].rsplit("-", 1)[1]
        box = draw.textbbox((0, 0), number)
        draw.text((cx-(box[2]-box[0])/2, cy-(box[3]-box[1])/2-1), number, fill=(255, 245, 232, 255))
    for node in manifest["nodes"]:
        cx, cy = _project_offset(node["_center"], node["_star_offset"], scale, tx, ty)
        draw.ellipse((cx-4, cy-4, cx+4, cy+4), outline=(255, 212, 91, 255), width=1)
        draw.line((cx-6, cy, cx+6, cy), fill=(255, 212, 91, 255), width=1)
        draw.line((cx, cy-6, cx, cy+6), fill=(255, 212, 91, 255), width=1)
        draw.text((cx+8, cy-3), "STAR ANCHOR", fill=(255, 212, 91, 255))
        if "_challenge_offset" in node:
            bx, by = _project_offset(node["_center"], node["_challenge_offset"], scale, tx, ty)
            draw.rounded_rectangle((bx-66, by-11, bx+66, by+11), radius=4, fill=(22, 29, 39, 240), outline=(211, 155, 90, 255), width=1)
            draw.text((bx-39, by-4), "CHALLENGE ANCHOR", fill=(255, 255, 255, 255))
    png_info = PngImagePlugin.PngInfo()
    png_info.add_text("Title", LABEL)
    png_info.add_text("Manifest-Schema-Version", str(manifest["schemaVersion"]))
    png_info.add_text("Manifest-SHA256", source_digest)
    png_info.add_text("Scene-Asset-SHA256", asset_digest)
    canvas.convert("RGB").save(out_path, format="PNG", pnginfo=png_info, optimize=False)


def _design_transform(width: int, height: int):
    """Production-style header and 64dp segment navigation reserve map space."""
    map_height = height - HEADER_DP - NAV_DP
    scale = max(width / SCENE_SIZE[0], map_height / SCENE_SIZE[1])
    return scale, (width - SCENE_SIZE[0] * scale) / 2, HEADER_DP + (map_height - SCENE_SIZE[1] * scale) / 2


def _star_points(cx, cy, outer=6.0, inner=2.6):
    return [(cx + (outer if i % 2 == 0 else inner) * math.cos(-math.pi / 2 + i * math.pi / 5),
             cy + (outer if i % 2 == 0 else inner) * math.sin(-math.pi / 2 + i * math.pi / 5))
            for i in range(10)]


def _design_geometry(manifest, width, height):
    scale, tx, ty = _design_transform(width, height)
    nodes = []
    for node in manifest["nodes"]:
        center = _project(node["_center"], scale, tx, ty)
        star = (center[0] + node["_star_offset"][0], center[1] + node["_star_offset"][1])
        challenge = None
        if "_challenge_offset" in node:
            challenge = (center[0] + node["_challenge_offset"][0], center[1] + node["_challenge_offset"][1])
        nodes.append((node["levelId"], center, star, challenge))
    edges = [[_project(edge[f"_{name}"], scale, tx, ty) for name in ("start", "control1", "control2", "end")]
             for edge in manifest["connections"]]
    return (scale, tx, ty), nodes, edges


def validate_design_bounds(manifest, width, height):
    """Fail closed on clipping and collisions in the two target viewport layouts."""
    if manifest["segmentIndex"] != 2 or (width, height) not in ((360, 800), (412, 915)):
        raise PreviewError("design mode only supports Segment 2 at the two review viewports")
    _, nodes, _ = _design_geometry(manifest, width, height)
    boxes = []
    decoration_boxes = []
    for level_id, (cx, cy), (sx, sy), challenge in nodes:
        for name, (left, top, right, bottom) in (
            ("hitbox", (cx-34, cy-34, cx+34, cy+34)),
            ("ring", (cx-27, cy-27, cx+27, cy+27)),
            ("stars", (sx-19, sy-7, sx+19, sy+7)),
        ):
            if left < 0 or right > width or top < HEADER_DP or bottom > height-NAV_DP:
                raise PreviewError(f"{level_id} {name} is clipped or overlaps header/navigation at {width}x{height}")
            if name == "hitbox":
                boxes.append((level_id, (left, top, right, bottom)))
            elif name == "stars":
                decoration_boxes.append((level_id, name, (left, top, right, bottom)))
        if challenge is not None:
            bx, by = challenge
            if bx-66 < 0 or bx+66 > width or by-13 < HEADER_DP or by+13 > height-NAV_DP:
                raise PreviewError(f"{level_id} challenge plaque is clipped at {width}x{height}")
            decoration_boxes.append((level_id, "challenge", (bx-66, by-13, bx+66, by+13)))
    for index, (first_id, a) in enumerate(boxes):
        for second_id, b in boxes[index+1:]:
            if min(a[2], b[2]) > max(a[0], b[0]) and min(a[3], b[3]) > max(a[1], b[1]):
                raise PreviewError(f"{first_id} and {second_id} 68dp hitboxes overlap")
    for level_id, name, a in decoration_boxes:
        for other_id, b in boxes:
            if other_id != level_id and min(a[2], b[2]) > max(a[0], b[0]) and min(a[3], b[3]) > max(a[1], b[1]):
                raise PreviewError(f"{level_id} {name} overlaps {other_id} hitbox")
    for index, (first_id, first_name, a) in enumerate(decoration_boxes):
        for second_id, second_name, b in decoration_boxes[index+1:]:
            if min(a[2], b[2]) > max(a[0], b[0]) and min(a[3], b[3]) > max(a[1], b[1]):
                raise PreviewError(f"{first_id} {first_name} overlaps {second_id} {second_name}")
    return nodes


def _svg_design(manifest, asset_bytes, source_digest, asset_digest, width, height):
    (scale, tx, ty), nodes, edges = _design_geometry(manifest, width, height)
    asset_uri = "data:image/webp;base64," + base64.b64encode(asset_bytes).decode("ascii")
    pieces = [
        f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        f'<title>{DESIGN_LABEL}</title>',
        f'<desc>Segment 2 schema v{manifest["schemaVersion"]}; manifest sha256:{source_digest}; approved scene sha256:{asset_digest}; sample stars are illustrative, not player progress.</desc>',
        f'<defs><clipPath id="scene-clip"><rect x="0" y="{HEADER_DP}" width="{width}" height="{height-HEADER_DP-NAV_DP}"/></clipPath>'
        '<linearGradient id="medal" x2="0" y2="1"><stop stop-color="#173847"/><stop offset="0.55" stop-color="#082235"/><stop offset="1" stop-color="#06121f"/></linearGradient>'
        '<linearGradient id="challenge-medal" x2="0" y2="1"><stop stop-color="#59421f"/><stop offset="0.6" stop-color="#201b1a"/><stop offset="1" stop-color="#0b1820"/></linearGradient></defs>',
        '<rect width="100%" height="100%" fill="#061425"/>',
        f'<g id="scene-art" clip-path="url(#scene-clip)"><image x="{tx:.5f}" y="{ty:.5f}" width="{SCENE_SIZE[0]*scale:.5f}" height="{SCENE_SIZE[1]*scale:.5f}" preserveAspectRatio="none" xlink:href="{asset_uri}"/></g>',
        '<g id="connections" fill="none" stroke-linecap="round" clip-path="url(#scene-clip)">',
    ]
    for index, points in enumerate(edges):
        p0,p1,p2,p3 = points
        d = f'M {p0[0]:.3f},{p0[1]:.3f} C {p1[0]:.3f},{p1[1]:.3f} {p2[0]:.3f},{p2[1]:.3f} {p3[0]:.3f},{p3[1]:.3f}'
        edge_id = f'baslangic-{11+index}-baslangic-{12+index}'
        pieces.append(f'<g id="edge-{edge_id}" data-from="baslangic-{11+index}" data-to="baslangic-{12+index}"><path d="{d}" stroke="#081827" stroke-opacity="0.83" stroke-width="5"/><path d="{d}" stroke="#b7a378" stroke-opacity="0.83" stroke-width="1.8"/><path d="{d}" stroke="#e4d5ae" stroke-opacity="0.43" stroke-width="0.6"/></g>')
    pieces.append('</g><g id="nodes" font-family="Georgia,serif" text-anchor="middle">')
    for level_id, (cx,cy), _, _ in nodes:
        level = int(level_id.rsplit('-',1)[1])
        outer = '#d0ad69' if level == 20 else '#a5b6ad'
        fill = 'url(#challenge-medal)' if level == 20 else 'url(#medal)'
        pieces.append(f'<g id="node-{level_id}" data-level-id="{level_id}"><circle cx="{cx+1:.3f}" cy="{cy+2:.3f}" r="29" fill="#020d18" fill-opacity="0.70"/><circle cx="{cx:.3f}" cy="{cy:.3f}" r="27" fill="#081625" stroke="{outer}" stroke-width="2"/><circle cx="{cx:.3f}" cy="{cy:.3f}" r="23.3" fill="{fill}" stroke="#627d82" stroke-width="0.9"/><circle cx="{cx:.3f}" cy="{cy:.3f}" r="19.2" fill="none" stroke="{outer}" stroke-opacity="0.55" stroke-width="0.7"/><text x="{cx:.3f}" y="{cy+7:.3f}" fill="#f8ead0" font-size="21" font-weight="bold">{level}</text></g>')
    pieces.append('</g><g id="stars">')
    for index,(level_id,_,(sx,sy),_) in enumerate(nodes):
        pieces.append(f'<g id="stars-{level_id}" data-level-id="{level_id}">')
        for star_index in range(3):
            points = _star_points(sx+(star_index-1)*12,sy)
            fill = '#FFD45B' if star_index < ILLUSTRATIVE_STARS[index] else '#65717D'
            outline = '#eec06a' if star_index < ILLUSTRATIVE_STARS[index] else '#a0adb7'
            pieces.append(f'<polygon points="{" ".join(f"{x:.3f},{y:.3f}" for x,y in points)}" fill="{fill}" stroke="{outline}" stroke-width="0.7"/>')
        pieces.append('</g>')
    pieces.append('</g><g id="challenges">')
    for level_id,_,_,challenge in nodes:
        if challenge is None:
            continue
        bx,by=challenge
        pieces.append(f'<g id="challenge-{level_id}" data-level-id="{level_id}"><rect x="{bx-66:.3f}" y="{by-13:.3f}" width="132" height="26" rx="7" fill="#081827" stroke="#c9a260" stroke-width="1.3"/><rect x="{bx-62:.3f}" y="{by-9:.3f}" width="124" height="18" rx="5" fill="none" stroke="#7c6746" stroke-width="0.5"/><text x="{bx:.3f}" y="{by+4:.3f}" fill="#f5dca2" text-anchor="middle" font-family="Georgia,serif" font-size="10" font-weight="bold">MEYDAN OKUMA</text></g>')
    pieces.append('</g>')
    pieces.extend([
        f'<g id="header"><rect width="{width}" height="{HEADER_DP}" fill="#071727" fill-opacity="0.97"/><path d="M 31 24 L 20 36 L 31 48 M 21 36 H 41" fill="none" stroke="#dfbf77" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/><circle cx="{width-29}" cy="36" r="15" fill="none" stroke="#bfa06a" stroke-width="1.4"/><text x="{width-29}" y="42" text-anchor="middle" fill="#f0d49c" font-family="Georgia,serif" font-size="17">i</text><text x="{width/2}" y="31" text-anchor="middle" fill="#f5e7cc" font-family="Georgia,serif" font-size="18" font-weight="bold">BAŞLANGIÇ LİMANI</text><text x="{width/2}" y="56" text-anchor="middle" fill="#d2be90" font-family="sans-serif" font-size="9">AÇIK DENİZ GEÇİDİ · YILDIZLAR TEMSİLİ</text></g>',
        f'<g id="segment-navigation"><rect x="0" y="{height-NAV_DP}" width="{width}" height="{NAV_DP}" fill="#071727" fill-opacity="0.98"/>',
    ])
    for index,label in enumerate(('1–10','11–20','21–30')):
        x=10+index*(width-20)/3; cell=(width-20)/3-7
        selected=index==1
        pieces.append(f'<g id="nav-segment-{index+1}"><rect x="{x:.3f}" y="{height-56}" width="{cell:.3f}" height="48" rx="10" fill="{"#244b53" if selected else "#102633"}" stroke="{"#FFD45B" if selected else "#75838a"}" stroke-width="{1.6 if selected else 0.8}"/><text x="{x+cell/2:.3f}" y="{height-27}" text-anchor="middle" fill="#f8ecd9" font-family="sans-serif" font-size="13" font-weight="bold">{label}</text></g>')
    pieces.append('</g></svg>')
    return '\n'.join(pieces).encode('utf-8')


def _render_png_design(manifest, asset_file, source_digest, asset_digest, width, height, out_path):
    # Supersampling keeps the editable-SVG geometry and bitmap proof visually aligned.
    ss = 3
    (scale,tx,ty),nodes,edges = _design_geometry(manifest,width,height)
    canvas = Image.new('RGB',(width*ss,height*ss),'#061425')
    with Image.open(asset_file) as opened:
        scene=opened.convert('RGB')
    resized=scene.resize((round(SCENE_SIZE[0]*scale*ss),round(SCENE_SIZE[1]*scale*ss)),Image.Resampling.LANCZOS)
    canvas.paste(resized,(round(tx*ss),round(ty*ss)))
    overlay=Image.new('RGBA',canvas.size,(0,0,0,0))
    draw=ImageDraw.Draw(overlay,'RGBA')
    def xy(box):return tuple(round(v*ss) for v in box)
    def line(points,color,w):draw.line([(round(x*ss),round(y*ss)) for x,y in points],fill=color,width=round(w*ss),joint='curve')
    def font(size,bold=False):
        path='C:/Windows/Fonts/georgiab.ttf' if bold else 'C:/Windows/Fonts/georgia.ttf'
        return ImageFont.truetype(path,round(size*ss)) if Path(path).exists() else ImageFont.load_default()
    for points in edges:
        samples=[_cubic(*points,i/80) for i in range(81)]
        line(samples,(4,17,30,205),5)
        line(samples,(186,163,117,215),1.8)
        line(samples,(234,215,176,100),0.7)
    for level_id,(cx,cy),_,_ in nodes:
        level=int(level_id.rsplit('-',1)[1]); special=level==20
        draw.ellipse(xy((cx-28,cy-26,cx+30,cy+30)),fill=(1,8,15,175))
        draw.ellipse(xy((cx-27,cy-27,cx+27,cy+27)),fill=(8,21,32,255),outline=(210,174,103,255) if special else (161,181,171,255),width=2*ss)
        draw.ellipse(xy((cx-23.3,cy-23.3,cx+23.3,cy+23.3)),fill=(47,37,24,255) if special else (12,43,56,255),outline=(98,126,130,255),width=ss)
        draw.ellipse(xy((cx-19.2,cy-19.2,cx+19.2,cy+19.2)),outline=(215,177,102,155) if special else (174,193,180,130),width=ss)
        draw.text((round(cx*ss),round((cy-2)*ss)),str(level),font=font(21,True),fill=(248,234,208,255),anchor='mm',stroke_width=round(.6*ss),stroke_fill=(15,18,23,255))
    for index,(level_id,_,(sx,sy),challenge) in enumerate(nodes):
        for star_index in range(3):
            points=[(round(x*ss),round(y*ss)) for x,y in _star_points(sx+(star_index-1)*12,sy)]
            filled=star_index<ILLUSTRATIVE_STARS[index]
            draw.polygon(points,fill=(255,212,91,255) if filled else (101,113,125,255))
            draw.line(points+[points[0]],fill=(237,192,106,255) if filled else (161,173,183,255),width=ss)
        if challenge is not None:
            bx,by=challenge
            draw.rounded_rectangle(xy((bx-66,by-13,bx+66,by+13)),radius=7*ss,fill=(8,24,39,250),outline=(201,162,96,255),width=ss)
            draw.rounded_rectangle(xy((bx-62,by-9,bx+62,by+9)),radius=5*ss,outline=(124,103,70,170),width=ss)
            draw.text((round(bx*ss),round(by*ss)),'MEYDAN OKUMA',font=font(10,True),fill=(245,220,162,255),anchor='mm')
    # Header and segment navigation are opaque, so map art never crosses their controls.
    draw.rectangle(xy((0,0,width,HEADER_DP)),fill=(7,23,39,251))
    draw.line([(31*ss,24*ss),(20*ss,36*ss),(31*ss,48*ss)],fill=(223,191,119,255),width=round(2.5*ss),joint='curve')
    draw.line([(21*ss,36*ss),(41*ss,36*ss)],fill=(223,191,119,255),width=round(2.5*ss))
    draw.ellipse(xy((width-44,21,width-14,51)),outline=(191,160,106,255),width=ss)
    draw.text((round((width-29)*ss),round(36*ss)),'i',font=font(17),fill=(240,212,156,255),anchor='mm')
    draw.text((round(width/2*ss),round(24*ss)),'BAŞLANGIÇ LİMANI',font=font(18,True),fill=(245,231,204,255),anchor='mm')
    draw.text((round(width/2*ss),round(53*ss)),'AÇIK DENİZ GEÇİDİ · YILDIZLAR TEMSİLİ',font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',9*ss) if Path('C:/Windows/Fonts/arial.ttf').exists() else ImageFont.load_default(),fill=(210,190,144,255),anchor='mm')
    draw.rectangle(xy((0,height-NAV_DP,width,height)),fill=(7,23,39,251))
    for index,label in enumerate(('1–10','11–20','21–30')):
        x=10+index*(width-20)/3; cell=(width-20)/3-7; selected=index==1
        draw.rounded_rectangle(xy((x,height-56,x+cell,height-8)),radius=10*ss,fill=(36,75,83,255) if selected else (16,38,51,255),outline=(255,212,91,255) if selected else (117,131,138,255),width=(2 if selected else 1)*ss)
        draw.text((round((x+cell/2)*ss),round((height-32)*ss)),label,font=font(13,True),fill=(248,236,217,255),anchor='mm')
    canvas=Image.alpha_composite(canvas.convert('RGBA'),overlay).convert('RGB').resize((width,height),Image.Resampling.LANCZOS)
    metadata=PngImagePlugin.PngInfo()
    for key,value in (("Title",DESIGN_LABEL),("Manifest-Schema-Version",str(manifest['schemaVersion'])),("Manifest-SHA256",source_digest),("Scene-Asset-SHA256",asset_digest),("Progression","illustrative stars only; not saved player progress")):
        metadata.add_text(key,value)
    canvas.save(out_path,format='PNG',pnginfo=metadata,optimize=False)


def render_manifest(manifest_path: Path, output_dir: Path, viewports: list[tuple[int, int]], *, design_preview=False):
    manifest, manifest_bytes, asset_file, asset_digest = load_manifest(manifest_path)
    source_digest = sha256(manifest_bytes)
    asset_bytes = asset_file.read_bytes()
    output_dir.mkdir(parents=True, exist_ok=True)
    outputs = []
    segment = manifest["segmentIndex"]
    for width, height in viewports:
        if design_preview:
            validate_design_bounds(manifest, width, height)
        stem = (f"segment_{segment}_{width}x{height}_DESIGN_CANDIDATE" if design_preview else
                f"segment_{segment}_{width}x{height}_TECHNICAL_PREVIEW_NOT_APPROVED_DESIGN")
        svg_path = output_dir / f"{stem}.svg"
        png_path = output_dir / f"{stem}.png"
        svg_path.write_bytes((_svg_design if design_preview else _svg)(manifest, asset_bytes, source_digest, asset_digest, width, height))
        if design_preview:
            _render_png_design(manifest, asset_file, source_digest, asset_digest, width, height, png_path)
        else:
            _render_png(manifest, asset_file, source_digest, asset_digest, width, height, png_path)
        outputs.extend((svg_path, png_path))
    return outputs


def emit_legacy_test_manifests(baseline_path: Path, output_dir: Path):
    """Emit technical-only straight-control manifests from the legacy node list.

    Controls lie at one-third/two-thirds of the straight center line. This is a
    generator fixture, not a proposed Harbor route and not visual approval.
    """
    baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
    if baseline.get("recordType") != "LEGACY_PRODUCTION_PARITY_BASELINE" or baseline.get("visualApproval") is not False:
        raise PreviewError("fixture source must be the unapproved legacy technical baseline")
    size = baseline["source"]["sceneSize"]
    output_dir.mkdir(parents=True, exist_ok=True)
    created = []
    for segment in (2, 3):
        source = baseline["source"]["segments"][str(segment)]
        centers = source["nodeCentersScenePx"]
        nodes = []
        ids = source["levelIds"]
        for index, (level_id, center) in enumerate(zip(ids, centers, strict=True)):
            node = {
                "levelId": level_id,
                "center": {"unit": "scenePixels", "x": center[0], "y": center[1]},
                "connectionAnchor": {"unit": "scenePixels", "x": center[0], "y": center[1]},
                "starAnchor": {"unit": "nodeRelativeLogicalDp", "x": 0, "y": 42.5},
            }
            if index == 9:
                node["challengeAnchor"] = {"unit": "nodeRelativeLogicalDp", "x": 0, "y": 71}
            nodes.append(node)
        edges = []
        for index in range(9):
            x0, y0 = centers[index]
            x3, y3 = centers[index+1]
            c1 = (x0+(x3-x0)/3, y0+(y3-y0)/3)
            c2 = (x0+2*(x3-x0)/3, y0+2*(y3-y0)/3)
            make_point = lambda point: {"unit": "scenePixels", "x": point[0], "y": point[1]}
            edges.append({"fromLevelId": ids[index], "toLevelId": ids[index+1],
                          "start": make_point((x0,y0)), "control1": make_point(c1),
                          "control2": make_point(c2), "end": make_point((x3,y3))})
        manifest = {"schemaVersion": 2, "routeId": "baslangic-limani", "segmentIndex": segment,
                    "scene": {"assetPath": source["assetPath"], "coordinateSpace": "scenePixels",
                              "coordinateSize": size, "sha256": source["sha256"]},
                    "minimumHitTargetLogicalDp": 68, "nodes": nodes, "connections": edges}
        target = output_dir / f"segment_{segment}_legacy_technical_fixture_manifest.json"
        if target.exists():
            raise PreviewError(f"refusing to overwrite existing fixture: {target}")
        target.write_text(json.dumps(manifest, indent=2)+"\n", encoding="utf-8")
        created.append(target)
    return created


def parse_viewport(value: str):
    try:
        width, height = (int(part) for part in value.lower().split("x", 1))
    except (ValueError, TypeError) as error:
        raise argparse.ArgumentTypeError("viewport must use WIDTHxHEIGHT") from error
    if width < 1 or height <= HEADER_DP:
        raise argparse.ArgumentTypeError("viewport dimensions must be positive and height must exceed 76dp")
    return width, height


def main(argv=None):
    parser = argparse.ArgumentParser(description=LABEL)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--manifest", type=Path, help="schema-v2 manifest JSON")
    group.add_argument("--emit-legacy-test-manifests", type=Path, metavar="BASELINE_JSON",
                       help="emit technical-only schema-v2 test manifests derived from an unapproved baseline")
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--viewport", action="append", type=parse_viewport, default=[])
    parser.add_argument("--design-preview", action="store_true", help="Segment 2 owner-review visual candidate; technical preview remains the default")
    args = parser.parse_args(argv)
    try:
        if args.emit_legacy_test_manifests:
            for path in emit_legacy_test_manifests(args.emit_legacy_test_manifests, args.output_dir):
                print(path)
            return 0
        viewports = args.viewport or [(360, 800), (412, 915)]
        for path in render_manifest(args.manifest, args.output_dir, viewports, design_preview=args.design_preview):
            print(path)
        return 0
    except (OSError, KeyError, TypeError, PreviewError) as error:
        print(f"preview generation failed: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
