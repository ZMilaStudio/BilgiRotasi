# Journey / Fener Burnu visual foundation v1

Source base: `52d490d1706eb9a93c9f6688a8c1c38074063867`.
This is a procedural production foundation, not final raster art, release,
physical-device acceptance, or publication of new level payloads.

## One continuous world

Geometry remains deterministic and chunk-local (20 rows / chunk, 112px pitch,
68px hitbox). Chunk IDs are rendering internals, not player-facing regions.
The existing virtualized map mounts bounded tiles/nodes regardless of catalog
size. No hand-authored node coordinates or per-ten-level maps are introduced.

`JourneyThemeSchedule.production` is the presentation source of truth:

| Visual range | Identity | Direction | Landmark |
|---|---|---|---|
| 1–20 | fener_shore_v1 | Calm indigo shoreline, low motif density | L1 arrival light, L20 coast marker |
| 21–50 | fener_cliffs_v1 | Deeper sea, cliff/harbor trace | L50 distant beacon |
| 51–75 | fener_approach_v1 | Darker cape approach, warmer lights | L75 approaching lighthouse |
| 76–100 | fener_beacon_v1 | Main beacon band, strongest warm accent | L100 lighthouse visual milestone |

Each band fades from its predecessor over at most ten levels. L101 blends from
the actual L100 beacon palette to the next configured biome. Generic ordered,
contiguous band records permit future regions; the bounded cyclic fallback is
presentation-only and never grants access or publishes synthetic content.

## Layer / final-art seam

1. Shared row-endpoint background gradients (identical endpoints across chunks).
2. Seeded, bounded side motifs (two per row).
3. Sparse procedural coastal landmarks, never runtime nodes.
4. Dual-tone path and opaque node plates.
5. Runtime labels, locks, stars and controls; never baked into background art.

Art is clipped to 28px edge strips, leaving the geometry's minimum 34px outer
hitbox gap intact at 360/412 widths. Center-lane contrast is controlled by the
shared gradient, not by an arbitrary noisy photograph. Landmark rendering is
IgnorePointer/ExcludeSemantics and does not modify gameplay eligibility.

`JourneyArtAsset` retains path, intrinsic dimensions, SHA-256, BoxFit and focal
point metadata. It is currently a **metadata seam**, not a shipping raster
loader: `JourneyBackgroundPainter` renders procedural proof. Final raster
integration still needs an explicitly tested tile/row sampling adapter and
asset registration; setting `art` alone must not be described as final-art
delivery. Do not reuse a single finite Harbor screenshot as a repeating map.

### Direct art brief

Create a modular vertical coastal environment kit for a continuous mobile
journey: stylized-realistic premium illustration, indigo/navy sea, weathered
stone and copper, restrained turquoise reflections, warm amber lanterns and
lighthouse. Calm shore evolves into cliffs and a dramatic cape; no category or
world-selection boundary. Composition must leave the entire central route
corridor quiet and low-frequency. Edge landmarks have readable silhouettes;
their light must not obscure runtime text. No baked numbers, stars, locks,
nodes, path, words, UI, logos or lettering. Orthographic/near-orthographic
camera with consistent scale; no perspective that requires manual node moves.
Supply seamless vertical transition strips and side landmark cutouts, not ten
independent maps. Prefer lossless source masters; runtime WebP/export dimensions,
hashes, focal points and crop rules require measured adapter acceptance before
production registration. Do not certify arbitrary new raster art from palette
samples alone.

## Production gameplay readability

`JourneyGameplayVisual` reuses the canonical production scene and gameplay
engine, but removes background-dependent grid image plates from Journey's
presentation. Normal/found/selected/error cells and target/bonus panels are
opaque surfaces. The exact foreground/surface colors must pass 4.5:1 contrast
before the presentation is returned. An unsafe combination throws, rather than
silently reducing the threshold. Existing theme scrim correction and normalized
safe area remain reusable for future artwork; opaque board surfaces are the
current actual guarantee independent of background sampling/filtering.

Light-on-dark and dark-on-light are supported; legacy route skins, grid/input,
scoring, challenge rules, Save v1 and schema3 are untouched. Future themes that
cannot produce readable actual state surfaces must fail closed.

## Proof / acceptance

The new production-visual test covers band ranges, landmark presence, L100→101,
contrast of actual cell/panel states, edge-art exclusion, 68px hitboxes, bounded
mounted backgrounds and deterministic captures at 360×800 and 412×915.
Opt-in `JOURNEY_VISUAL_PROOF_DIR` writes local Flutter test renders outside the
repository; `JOURNEY_VISUAL_FONT_DIR` supplies existing SDK fonts.
L1/20/21/50/75/100/101 proofs use metadata-only inspection, not unlocked new
production payloads. Local widget proof does not establish Android/physical
memory, performance, or owner visual acceptance. Final premium raster art and
physical-device aesthetic/readability review remain separate gates.

## Phase 2 adapter continuation

The raster integration gap above is now addressed by `word_hunt_journey_art.dart`.
See `JOURNEY_FENER_ART_PACK_SPEC.md` for exact layer/slot/validation/resource
contracts. The production registry remains empty until actual owner-approved
raster artwork arrives; the foundation is still fallback, not premium final art.
