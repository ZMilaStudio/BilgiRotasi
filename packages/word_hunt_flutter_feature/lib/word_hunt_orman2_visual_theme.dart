import 'package:flutter/material.dart';

import 'word_hunt_artwork_presentation.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_map_decoration.dart';
import 'word_hunt_route_visual_theme.dart';

/// Orman 2 pilotunun immutable clean environment skin'i.
///
/// Raster byte'ları runtime'da recolor/contrast/vignette işleminden geçirilmez.
/// Dekoratif rota environment içinde gömülüdür; ortak Flutter katmanı yalnız
/// canlı node/progression UI'sını çizer.
abstract final class WordHuntOrman2VisualTheme {
  static const String assetPath = 'assets/word_hunt/ORMAN2_FINAL_941x1672.webp';

  static const WordHuntRouteVisualTheme production = WordHuntRouteVisualTheme(
    id: 'orman-2-production',
    mapTheme: WordHuntRouteMapTheme(
      id: 'orman-2-production',
      backgroundColor: Color(0xFF07150D),
      surfaceColor: Color(0xFF143420),
      pathColor: Color(0xFFE7CB83),
      lockedPathColor: Color(0xFFB5A276),
      nodeColor: Color(0xFF693C1E),
      lockedNodeColor: Color(0xFF56594F),
      accentColor: Color(0xFFFFD567),
      textColor: Color(0xFFFFF5DE),
      sceneGlowColor: Color(0xFFFFE7A8),
      pathUnderlayColor: Color(0xFF342416),
      nodeShadowColor: Color(0xFF08120D),
      sceneDepth: 0.58,
    ),
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 20260916,
      count: 0,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF4F8A45),
      secondary: Color(0xFF6A4328),
      accent: Color(0xFFFFE08A),
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
    artworkOverlayMode: WordHuntArtworkOverlayMode.embeddedRouteLiveNodes,
    referenceCanvasSize: Size(411, 731),
    extendTallAmbientFromArtworkEdges: true,
  );
}
