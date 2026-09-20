import 'package:flutter/material.dart';

import 'word_hunt_artwork_presentation.dart';
import 'word_hunt_edge_ambient.dart';
import 'word_hunt_path_renderer.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_chrome_theme.dart';
import 'word_hunt_route_map_decoration.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_seal_renderer.dart';

/// Locked Yeraltı Krallığı environment + Mechanical Seal production config.
///
/// Live level state, numerals, stars, locks and route path remain renderer-owned.
abstract final class WordHuntYeraltiKralligiVisualTheme {
  static const String routeId = 'yeralti-kralligi';
  static const String assetPath =
      'assets/word_hunt/YERALTI_KRALLIGI_ENV_941x1672.webp';

  static const WordHuntSealVisualSpec sealSpec =
      WordHuntSealVisualSpec.mechanical;
  static const WordHuntPathVisualSpec pathSpec =
      WordHuntPathVisualSpec.engineeredSegmented;

  static const WordHuntRouteChromeTheme chromeTheme =
      WordHuntRouteChromeTheme(
        id: 'yeralti-kralligi-mechanical-chrome',
        headerTint: Color(0xFF182630),
        surfaceTint: Color(0xFF202426),
        materialFamily: WordHuntChromeMaterialFamily.engineeredMetal,
        back: WordHuntChromeControlSpec.icon(
          icon: Icons.arrow_back_rounded,
        ),
        info: WordHuntChromeControlSpec.icon(
          icon: Icons.info_outline_rounded,
        ),
      );

  static const WordHuntRouteVisualTheme production = WordHuntRouteVisualTheme(
    id: 'yeralti-kralligi-production',
    mapTheme: WordHuntRouteMapTheme(
      id: 'yeralti-kralligi-production',
      backgroundColor: Color(0xFF111A23),
      surfaceColor: Color(0xFF202426),
      pathColor: Color(0xFFA76A3C),
      lockedPathColor: Color(0xFF665A50),
      nodeColor: Color(0xFF453E38),
      lockedNodeColor: Color(0xFF4D4B48),
      accentColor: Color(0xFF55C7C2),
      finalAccentColor: Color(0xFFC59A55),
      textColor: Color(0xFFF4E6CE),
      sceneGlowColor: Color(0xFF55C7C2),
      pathUnderlayColor: Color(0xFF141110),
      nodeShadowColor: Color(0xFF100D0B),
      sceneDepth: 0,
    ),
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 20260918,
      count: 0,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF453E38),
      secondary: Color(0xFF55C7C2),
      accent: Color(0xFFA76A3C),
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
