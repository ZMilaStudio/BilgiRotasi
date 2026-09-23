import 'package:flutter/material.dart';

import 'word_hunt_artwork_presentation.dart';
import 'word_hunt_edge_ambient.dart';
import 'word_hunt_path_renderer.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_chrome_theme.dart';
import 'word_hunt_route_map_decoration.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_seal_renderer.dart';

/// Locked Güneş İmparatorluğu environment + Solar Seal production config.
///
/// Reverse presentation maps the shared canonical point set so L1 is lower and
/// L10 is upper. Logical topology remains the shared 1→2→...→10 graph.
abstract final class WordHuntGunesImparatorluguVisualTheme {
  static const String routeId = 'gunes-imparatorlugu';
  static const String assetPath =
      'assets/word_hunt/GUNES_IMPARATORLUGU_ENV_941x1672.webp';

  static const WordHuntSealVisualSpec sealSpec = WordHuntSealVisualSpec.solar;
  static const WordHuntPathVisualSpec pathSpec =
      WordHuntPathVisualSpec.ceremonialAlignment;

  static const WordHuntRouteChromeTheme chromeTheme = WordHuntRouteChromeTheme(
    id: 'gunes-imparatorlugu-imperial-chrome',
    headerTint: Color(0xFF182B52),
    surfaceTint: Color(0xFF22263A),
    materialFamily: WordHuntChromeMaterialFamily.ceremonialStone,
    back: WordHuntChromeControlSpec.icon(icon: Icons.arrow_back_rounded),
    info: WordHuntChromeControlSpec.icon(icon: Icons.info_outline_rounded),
  );

  static const WordHuntRouteVisualTheme production = WordHuntRouteVisualTheme(
    id: 'gunes-imparatorlugu-production',
    mapTheme: WordHuntRouteMapTheme(
      id: 'gunes-imparatorlugu-production',
      backgroundColor: Color(0xFFD9C9A5),
      surfaceColor: Color(0xFF22263A),
      pathColor: Color(0xFFE2BB69),
      lockedPathColor: Color(0xFF796F59),
      nodeColor: Color(0xFFB18A46),
      lockedNodeColor: Color(0xFF71684F),
      accentColor: Color(0xFF69D8D0),
      finalAccentColor: Color(0xFFF0C870),
      textColor: Color(0xFFFFF0C4),
      sceneGlowColor: Color(0xFFEBDCA6),
      pathUnderlayColor: Color(0xFF14172A),
      nodeShadowColor: Color(0xFF111427),
      sceneDepth: 0,
    ),
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 20260918,
      count: 0,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFFB18A46),
      secondary: Color(0xFF182B52),
      accent: Color(0xFF69D8D0),
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
    presentationOrder: WordHuntRoutePresentationOrder.reverse,
  );
}
