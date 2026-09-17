import 'package:flutter/material.dart';

import 'word_hunt_artwork_presentation.dart';
import 'word_hunt_models.dart';
import 'word_hunt_orman2_content.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_map_decoration.dart';
import 'word_hunt_route_visual_theme.dart';

/// Proof-only Kristal Vadisi renderer fixture.
///
/// Bu dosya production catalog/content değildir. Gerçek 10-level progression
/// state'ini göstermek için mevcut Kadim level definitions yalnız görsel fixture
/// olarak reuse edilir; route catalog'a hiçbir entry eklenmez.
abstract final class WordHuntKristalRuntimeProof {
  static const String artworkAsset =
      'assets/word_hunt/KRISTAL_VADISI_RUNTIME_PROOF_SOURCE.png';
  static const int artworkWidth = 941;
  static const int artworkHeight = 1672;
  static const int artworkBytes = 2793116;
  static const String artworkSha256 =
      '189dec3f731f66e72449625457d35d28500fe5cbd5a69ab1f2f04f303ca1bc20';

  static final WordHuntRouteDefinition route = WordHuntRouteDefinition(
    id: 'kristal-vadisi-runtime-proof',
    title: 'Kristal Vadisi',
    theme: 'kristal-runtime-proof',
    unlockStarsRequired: 0,
    levels: WordHuntOrman2Content.orman2.levels,
    routeRewardId: 'proof-kristal-runtime',
  );

  static final WordHuntProgressSnapshot progress = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (final level in WordHuntOrman2Content.orman2.levels.take(4))
        level.id: 3,
    },
  );

  static const WordHuntRouteVisualTheme visualTheme = WordHuntRouteVisualTheme(
    id: 'kristal-vadisi-runtime-proof',
    mapTheme: WordHuntRouteMapTheme(
      id: 'kristal-vadisi-runtime-proof',
      backgroundColor: Color(0xFF090B20),
      surfaceColor: Color(0xFF15182B),
      pathColor: Color(0xFF78E3DC),
      lockedPathColor: Color(0xFFB7BED0),
      nodeColor: Color(0xFF6D4BB3),
      lockedNodeColor: Color(0xFF41475A),
      accentColor: Color(0xFFF2C66D),
      finalAccentColor: Color(0xFFFFD77A),
      textColor: Color(0xFFF7F4FF),
      sceneGlowColor: Color(0xFF7FE7E2),
      pathUnderlayColor: Color(0xFF11152B),
      nodeShadowColor: Color(0xFF050713),
      sceneDepth: 0.42,
      nodeVisualStyle: WordHuntRouteNodeVisualStyle.facetedCrystal,
    ),
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 20260917,
      count: 0,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF6D4BB3),
      secondary: Color(0xFF55D6D0),
      accent: Color(0xFFF2C66D),
    ),
    decorationOpacity: 0,
    backgroundAsset: artworkAsset,
    backgroundFit: BoxFit.cover,
    backgroundAlignment: Alignment.center,
    backgroundBlurSigma: 0,
    backgroundOverlayColor: Colors.transparent,
    backgroundScale: 1,
    backgroundContrast: 1,
    backgroundSaturation: 1,
    backgroundVignetteColor: Colors.transparent,
    backgroundVignetteStrength: 0,
    overlayDecorationsOnArtwork: false,
    artworkOverlayMode: WordHuntArtworkOverlayMode.reusable,
    referenceCanvasSize: Size(411, 731),
    extendTallAmbientFromArtworkEdges: true,
  );
}
