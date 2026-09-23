import 'package:flutter/material.dart';

import 'word_hunt_artwork_presentation.dart';
import 'word_hunt_edge_ambient.dart';
import 'word_hunt_path_renderer.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_chrome_theme.dart';
import 'word_hunt_route_map_decoration.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_seal_renderer.dart';

/// Locked Kayıp Şehir environment + Ancient Seal production visual config.
///
/// This file binds only visual configuration. Catalog/navigation ownership stays
/// outside this wave.
abstract final class WordHuntKayipSehirVisualTheme {
  static const String routeId = 'kayip-sehir';
  static const String assetPath =
      'assets/word_hunt/KAYIP_SEHIR_ENV_941x1672.webp';

  static const WordHuntSealVisualSpec sealSpec = WordHuntSealVisualSpec.ancient;
  static const WordHuntPathVisualSpec pathSpec =
      WordHuntPathVisualSpec.ancientWaymarks;

  static const WordHuntRouteChromeTheme chromeTheme = WordHuntRouteChromeTheme(
    id: 'kayip-sehir-archaeological-chrome',
    headerTint: Color(0xFF46362B),
    surfaceTint: Color(0xFF2A211B),
    materialFamily: WordHuntChromeMaterialFamily.carvedStone,
    back: WordHuntChromeControlSpec.icon(icon: Icons.arrow_back_rounded),
    info: WordHuntChromeControlSpec.icon(icon: Icons.info_outline_rounded),
  );

  static const WordHuntRouteVisualTheme production = WordHuntRouteVisualTheme(
    id: 'kayip-sehir-production',
    mapTheme: WordHuntRouteMapTheme(
      id: 'kayip-sehir-production',
      backgroundColor: Color(0xFF6C5542),
      surfaceColor: Color(0xFF46362B),
      pathColor: Color(0xFFC8A46D),
      lockedPathColor: Color(0xFF746755),
      nodeColor: Color(0xFF75513A),
      lockedNodeColor: Color(0xFF55504B),
      accentColor: Color(0xFF56BDB2),
      finalAccentColor: Color(0xFFD3B475),
      textColor: Color(0xFFF8E9C8),
      sceneGlowColor: Color(0xFFDDBB82),
      pathUnderlayColor: Color(0xFF241A13),
      nodeShadowColor: Color(0xFF140F0C),
      sceneDepth: 0,
    ),
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 20260918,
      count: 0,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF75513A),
      secondary: Color(0xFF56BDB2),
      accent: Color(0xFFC8A46D),
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
    sealSpec: sealSpec,
    pathSpec: pathSpec,
    chromeTheme: chromeTheme,
    tallAmbientMode: WordHuntTallAmbientMode.edgeDerivedLowFrequency,
    presentationOrder: WordHuntRoutePresentationOrder.forward,
  );
}
