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
  }) : assert(decorationOpacity >= 0 && decorationOpacity <= 1);

  final String id;
  final WordHuntRouteMapTheme mapTheme;
  final WordHuntRouteDecorationSpec decorationSpec;
  final WordHuntRouteDecorationPalette decorationPalette;
  final double decorationOpacity;
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
    return WordHuntReusableRouteMapScreen(
      route: route,
      theme: visualTheme.mapTheme,
      progress: progress,
      onLevelTap: onLevelTap,
      decorationSpec: visualTheme.decorationSpec,
      decorationPalette: visualTheme.decorationPalette,
      decorationOpacity: visualTheme.decorationOpacity,
    );
  }
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
