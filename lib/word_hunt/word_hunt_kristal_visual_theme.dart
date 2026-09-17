import 'package:flutter/material.dart';

import 'word_hunt_artwork_presentation.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_map_decoration.dart';
import 'word_hunt_route_visual_theme.dart';

/// Owner-approved Kristal Vadisi environment artwork + generic live overlay skin.
abstract final class WordHuntKristalVisualTheme {
  static const String assetPath =
      'assets/word_hunt/KRISTAL_VADISI_ENV_941x1672.webp';

  static const WordHuntRouteVisualTheme production = WordHuntRouteVisualTheme(
    id: 'kristal-vadisi-production',
    mapTheme: WordHuntRouteMapTheme(
      id: 'kristal-vadisi-production',
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
      secondary: Color(0xFF78E3DC),
      accent: Color(0xFFF2C66D),
    ),
    decorationOpacity: 0,
    backgroundAsset: assetPath,
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
