import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_map_decoration.dart';

/// Bir Kelime Avı rotasının yalnız görsel skin verisini taşır.
///
/// Bilerek node koordinatı, hitbox, progression veya route-id özel widget
/// içermez. Yeni rota görselleştirmesi bu veri paketini değiştirerek yapılmalı;
/// ortak 1-10 geometri motoru değişmemelidir.
@immutable
class WordHuntRouteVisualTheme {
  const WordHuntRouteVisualTheme({
    required this.id,
    required this.mapTheme,
    required this.decorationSpec,
    required this.decorationPalette,
    this.decorationOpacity = 0.38,
    this.backgroundAsset,
    this.backgroundFit = BoxFit.cover,
    this.backgroundAlignment = Alignment.center,
    this.backgroundBlurSigma = 0,
    this.backgroundOverlayColor = Colors.transparent,
  }) : assert(decorationOpacity >= 0 && decorationOpacity <= 1),
       assert(backgroundBlurSigma >= 0);

  final String id;
  final WordHuntRouteMapTheme mapTheme;
  final WordHuntRouteDecorationSpec decorationSpec;
  final WordHuntRouteDecorationPalette decorationPalette;
  final double decorationOpacity;

  /// Opsiyonel gerçek rota artwork'ü. Görsel yalnız sahne tabanıdır; node,
  /// hitbox, yıldız, kilit veya progression state'i asset içine bake edilmez.
  /// Böylece aynı canonical 1-10 motoru raster sahne üzerinde de çalışır.
  final String? backgroundAsset;
  final BoxFit backgroundFit;
  final Alignment backgroundAlignment;
  final double backgroundBlurSigma;
  final Color backgroundOverlayColor;
}

/// Bütün temalı 10-bölümlük rotalar için tek generic bağlayıcı.
///
/// Rota ile görsel skin paketini ortak motora aktarır. Rota adına göre branch,
/// ayrı widget veya koordinat üretmez. Production host, catalog entry içindeki
/// visualTheme verisini bu ortak bağlayıcıya aktarabilir.
class WordHuntThemedRouteMapScreen extends StatelessWidget {
  const WordHuntThemedRouteMapScreen({
    super.key,
    required this.route,
    required this.visualTheme,
    this.progress = const WordHuntProgressSnapshot(),
    this.onLevelTap,
  });

  final WordHuntRouteDefinition route;
  final WordHuntRouteVisualTheme visualTheme;
  final WordHuntProgressSnapshot progress;
  final ValueChanged<int>? onLevelTap;

  @override
  Widget build(BuildContext context) {
    final backgroundAsset = visualTheme.backgroundAsset;
    final effectiveMapTheme = backgroundAsset == null
        ? visualTheme.mapTheme
        : _transparentSceneTheme(visualTheme.mapTheme);
    final map = WordHuntReusableRouteMapScreen(
      route: route,
      theme: effectiveMapTheme,
      progress: progress,
      onLevelTap: onLevelTap,
      decorationSpec: visualTheme.decorationSpec,
      decorationPalette: visualTheme.decorationPalette,
      decorationOpacity: visualTheme.decorationOpacity,
    );

    if (backgroundAsset == null) return map;

    Widget artwork = Image.asset(
      backgroundAsset,
      key: const Key('word_hunt_route_background_asset'),
      fit: visualTheme.backgroundFit,
      alignment: visualTheme.backgroundAlignment,
      filterQuality: FilterQuality.high,
    );
    if (visualTheme.backgroundBlurSigma > 0) {
      artwork = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: visualTheme.backgroundBlurSigma,
          sigmaY: visualTheme.backgroundBlurSigma,
        ),
        child: artwork,
      );
    }

    return Stack(
      key: const Key('word_hunt_themed_artwork_stack'),
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(child: artwork),
        if (visualTheme.backgroundOverlayColor.a > 0)
          Positioned.fill(
            key: const Key('word_hunt_route_background_overlay'),
            child: ColoredBox(color: visualTheme.backgroundOverlayColor),
          ),
        Positioned.fill(child: map),
      ],
    );
  }

  WordHuntRouteMapTheme _transparentSceneTheme(WordHuntRouteMapTheme source) {
    return WordHuntRouteMapTheme(
      id: source.id,
      backgroundColor: Colors.transparent,
      surfaceColor: Colors.transparent,
      pathColor: source.pathColor,
      lockedPathColor: source.lockedPathColor,
      nodeColor: source.nodeColor,
      lockedNodeColor: source.lockedNodeColor,
      accentColor: source.accentColor,
      textColor: source.textColor,
      sceneGlowColor: source.sceneGlowColor,
      pathUnderlayColor: source.pathUnderlayColor,
      nodeShadowColor: source.nodeShadowColor,
      sceneDepth: source.sceneDepth,
    );
  }
}

/// Oyunda kullanılacak reusable rota skinleri.
///
/// Bu sınıf proof/QA presetlerinden ayrıdır. Production host gerçek rota için
/// buradaki veriyi kullanır; node koordinatı, hitbox ve progression yine ortak
/// reusable motor tarafından yönetilir.
abstract final class WordHuntRouteVisualThemes {
  static const WordHuntRouteVisualTheme ormanYolu = WordHuntRouteVisualTheme(
    id: 'orman-yolu-production',
    mapTheme: WordHuntRouteMapTheme(
      id: 'orman-yolu-production',
      backgroundColor: Color(0xFF07150D),
      surfaceColor: Color(0xFF143420),
      pathColor: Color(0xFFEBD49B),
      lockedPathColor: Color(0xFF657066),
      nodeColor: Color(0xFF81542F),
      lockedNodeColor: Color(0xFF4A5050),
      accentColor: Color(0xFFFFD96B),
      textColor: Color(0xFFFFF7E2),
      sceneGlowColor: Color(0xFFFFE7A8),
      pathUnderlayColor: Color(0xA7352416),
      nodeShadowColor: Color(0xD407100A),
      sceneDepth: 0.58,
    ),
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 20260912,
      count: 28,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF4F8A45),
      secondary: Color(0xFF6A4328),
      accent: Color(0xFFFFE08A),
    ),
    decorationOpacity: 0.94,
  );
}

/// Production görsel kararı değildir; reusable motorun farklı skin verileriyle
/// çalışabildiğini kanıtlayan veri-only preset'lerdir.
abstract final class WordHuntRouteVisualThemeProofs {
  static const WordHuntRouteVisualTheme forest = WordHuntRouteVisualTheme(
    id: 'forest-proof',
    mapTheme: WordHuntRouteMapTheme(
      id: 'forest-proof',
      backgroundColor: Color(0xFF07150D),
      surfaceColor: Color(0xFF143420),
      pathColor: Color(0xFFEBD49B),
      lockedPathColor: Color(0xFF657066),
      nodeColor: Color(0xFF81542F),
      lockedNodeColor: Color(0xFF4A5050),
      accentColor: Color(0xFFFFD96B),
      textColor: Color(0xFFFFF7E2),
      sceneGlowColor: Color(0xFFFFE7A8),
      pathUnderlayColor: Color(0xA7352416),
      nodeShadowColor: Color(0xD407100A),
      sceneDepth: 0.58,
    ),
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 20260912,
      count: 28,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF4F8A45),
      secondary: Color(0xFF6A4328),
      accent: Color(0xFFFFE08A),
    ),
    decorationOpacity: 0.94,
  );

  static const WordHuntRouteVisualTheme sky = WordHuntRouteVisualTheme(
    id: 'sky-proof',
    mapTheme: WordHuntRouteMapTheme.skyProof,
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.sky,
      seed: 20260913,
      count: 16,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFFB9D7FF),
      secondary: Color(0xFF7C8CCF),
      accent: Color(0xFFFDE68A),
    ),
  );

  static const WordHuntRouteVisualTheme harbor = WordHuntRouteVisualTheme(
    id: 'harbor-proof',
    mapTheme: WordHuntRouteMapTheme.harborProof,
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.harbor,
      seed: 20260914,
      count: 14,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF58D5E6),
      secondary: Color(0xFF0C2B3C),
      accent: Color(0xFFFFC857),
    ),
  );

  static const List<WordHuntRouteVisualTheme> all =
      <WordHuntRouteVisualTheme>[forest, sky, harbor];
}
