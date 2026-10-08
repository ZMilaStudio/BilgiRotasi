# Journey raster art installation contract — Phase 2

Status: adapter contract, NOT final artwork or a release. No owner-approved
Journey raster kit is installed. `JourneyArtRegistry.production` is intentionally
empty. The existing procedural foundation remains the functional fallback.
No placeholder/test image is shipping art.

## Layer order and identity

1. Existing procedural palette/fallback (28px procedural edge clipping retained).
2. Full-width low-frequency vertically seamless atmosphere tile.
3. Transparent side environment variants; optional seamless atmosphere overlay.
4. Single-owner sparse landmark cutout.
5. Soft route-following navy veil (default width 104 logical px, alpha .28,
   blur sigma 18), below the outlined runtime route and opaque runtime nodes.
6. Existing path, 68x68 nodes, semantics/actions and UI.

`JourneyArtKit` and `JourneyArtRegistry` are keyed by schedule theme ID only.
Save/catalog/progression must never query the registry or store art IDs. The
map consumes the default registry; tests can inject `MemoryImage` through
`JourneyArtProvider`. `AssetImage` is the production default. No gameplay,
frontier, unlock, content publication, migration or legacy-selector change.

## Exact proposed slots (files pending owner artwork)

Root: `assets/word_hunt/journey/fener/`. No files currently claimed present.

| Range | Theme ID | Required base | Left / right terrain slots |
| --- | --- | --- | --- |
| 1–20 | fener_shore_v1 | shore/base.webp | shore/left_01.webp, shore/right_01.webp |
| 21–50 | fener_cliffs_v1 | cliffs/base.webp | cliffs/left_01.webp, cliffs/right_01.webp |
| 51–75 | fener_approach_v1 | approach/base.webp | approach/left_01.webp, approach/right_01.webp |
| 76–100 | fener_beacon_v1 | beacon/base.webp | beacon/left_01.webp, beacon/right_01.webp |

Optional per-band `atmosphere.webp`; additional numbered side variants supported.
Only the base is required to activate a kit. Landmarks are owned by the band
containing the ordinal, not by both themes during a transition:

| Ordinal | Owner | Path | Intent |
| --- | --- | --- | --- |
| 1 | shore | shore/arrival_light.webp | arrival lantern |
| 20 | shore | shore/coast_marker.webp | coastal marker |
| 50 | cliffs | cliffs/distant_beacon.webp | distant beacon |
| 75 | approach | approach/lighthouse_approach.webp | architecture approach |
| 100 | beacon | beacon/main_lighthouse.webp | dominant lighthouse silhouette |

Future themes register the same model without renderer switches. A declared
`transitionPartner` must exist in the registry. Palette-only/fallback partner
is allowed when no partner is declared; L101 is currently such a future biome.

## Deterministic placement / crop

Base repeats vertically, phase anchored to global ordinal Y, NOT chunk-local
scroll position. Author matching top/bottom tile edges. Runtime fitWidth scales
to viewport width; base focal crop is top-centered by design, no arbitrary
per-level placements. Overlay follows the same seamless tile policy.

Side variant index = floor((ordinal-1)/4) modulo variant count. Each transparent
cutout occupies a four-row block (448 logical px) at the side, default width
32% of viewport (policy allows up to 45%). This is NOT the 28px fallback clip.
Four-row blocks align with 20-row chunks. Side cutouts must fade to transparent
at top/bottom, so changes of variant never expose rectangular edges. Fit/focal
metadata controls crop. No intentional important details underneath route.

Landmark cutouts occupy a row-height side slot (112px tall, 35% viewport width),
alternate deterministically by ordinal parity, and are owned once. Compose the
main lighthouse as a readable portrait silhouette at this display scale; do not
expect a giant map-sized cutout. No lighthouse duplicates in both fade partners.

## Transitions / resource budget

Schedule is authority for 20→21, 50→51, 75→76, 100→101. Old/new art opacity
interpolates vertically between adjacent row endpoints; procedural palette
bridge always exists below them. No per-row decode, empty intermediate frame,
geometry move or landmark duplication. Image tile and side alpha edges must
be validated using actual final art; code cannot certify arbitrary seam quality.

Only visible plus one-row-near resources acquire streams. Cached offscreen
chunks mount no raster resources. At supported 360x800/412x915 viewports tests
assert <=3 chunks, <=2 distinct base resources and <=16 distinct active raster
resources across mounted chunks. Per-chunk admission also fails to fallback
if either cap is exceeded (e.g. oversized/custom viewport/kit).
Decode requests fit within 768x1024, preserve aspect and disallow upscaling;
maximum requested RGBA extent ~3MiB/resource (~48MiB for 16 distinct resources).
This is an architecture ceiling, NOT a measured physical RAM PASS. GPU layers,
Flutter cache retention and total app memory need device measurement. No
Journey-owned global decoded cache; dispose local cloned handles/listeners on
resource exit, normal Flutter image caching remains in charge.

## Authoring / export brief

Premium stylized-realistic coastal mobile game environment; calm mysterious
navy/indigo/deep blue sea, weathered blue-gray stone, subtle turquoise reflection,
restrained fog and warm amber lights. Not cartoon, low-poly, photo collage,
childish, hyper-fantasy or over-saturated. Strong side silhouettes and quiet
center. No letters, logos, numbers, stars, locks, UI, nodes or baked path.

Base source: square/moderate vertical tile, recommended 768x768 or 768x1024,
low-frequency sea/fog/sky only, vertically seamless. Sides: transparent portrait
WebP/PNG, recommended master 512x1024 with transparent end fades. Landmarks:
transparent portrait master around 512x768, readable at row-slot scale. These
are recommended targets, not mandatory intrinsic dimensions. Preserve masters
outside runtime bundle. Prefer runtime WebP where alpha/quality permits.
Record actual pixel dimensions, SHA-256, BoxFit and focal point after export.
Focal alignment axes must be finite in [-1,1]. No huge single-band/15k bitmap.

## Installation validation and acceptance

1. Owner approves actual art at phone scale, including seams and crop.
2. Add assets to root Flutter bundle and standalone's existing asset-link path;
   do not replace Windows symlinks or alter accepted assets to fix local errno267.
3. Register metadata in the presentation registry; validate schedule ownership.
4. Export `registry.installationManifest()` and a JSON list from the **actual
   target app** `AssetManifest.loadFromAssetBundle(bundle).listAssets()` to TEMP.
5. Run `python tools/validate_journey_art_pack.py <manifest.json> --root <repo>
   --bundle-assets <actual-bundle-list.json>`. It validates real file, decoded
   dimensions, SHA-256, registered bundle path, duplicate paths/landmark owners,
   declared transition partner and focal metadata. No per-frame hashing.
6. Raster widget tests inject only deterministic in-memory test fixtures; these
   fixtures are not committed art or evidence of final aesthetic acceptance.
7. Debug/test keys distinguish `journey_art_procedural_fallback`,
   `journey_art_raster_active`, `journey_art_missing_fallback` and
   `journey_art_resource_fallback`. Failed image loading is handled, not a blank
   screen/uncaught missing-asset exception. Partial failed kits remain observable.
8. Linux/Android and physical visual/memory acceptance remain pending. This task
   creates no PR, CI dispatch, APK/AAB, signing or release publication.
