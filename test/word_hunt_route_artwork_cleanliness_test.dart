import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_map_decoration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const baseMapTheme = WordHuntRouteMapTheme(
    id: 'artwork-cleanliness-test',
    backgroundColor: Color(0xFF07150D),
    surfaceColor: Color(0xFF143420),
    pathColor: Color(0xFFEBD49B),
    lockedPathColor: Color(0xFF657066),
    nodeColor: Color(0xFF81542F),
    lockedNodeColor: Color(0xFF4A5050),
    accentColor: Color(0xFFFFD96B),
    textColor: Color(0xFFFFF7E2),
  );
  const decorationSpec = WordHuntRouteDecorationSpec(
    kind: WordHuntRouteDecorationKind.forest,
    seed: 42,
    count: 12,
  );
  const decorationPalette = WordHuntRouteDecorationPalette(
    primary: Color(0xFF4F8A45),
    secondary: Color(0xFF6A4328),
    accent: Color(0xFFFFE08A),
  );

  test('Orman production skin keeps raster layering clean by default', () {
    const theme = WordHuntRouteVisualThemes.ormanYolu;
    expect(theme.id, 'orman-yolu-production');
    expect(theme.overlayDecorationsOnArtwork, isFalse);
    expect(theme.backgroundScale, 1);
  });

  testWidgets('raster artwork suppresses procedural decorations by default', (
    tester,
  ) async {
    const visualTheme = WordHuntRouteVisualTheme(
      id: 'clean-artwork',
      mapTheme: baseMapTheme,
      decorationSpec: decorationSpec,
      decorationPalette: decorationPalette,
      backgroundAsset: 'assets/word_hunt/baslangic_limani_bg.jpg',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntThemedRouteMapScreen(
          route: WordHuntStarterContent.baslangicLimani,
          visualTheme: visualTheme,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('word_hunt_reusable_decoration_layer')),
      findsNothing,
    );
  });

  testWidgets('hybrid artwork can explicitly opt in to procedural decorations', (
    tester,
  ) async {
    const visualTheme = WordHuntRouteVisualTheme(
      id: 'hybrid-artwork',
      mapTheme: baseMapTheme,
      decorationSpec: decorationSpec,
      decorationPalette: decorationPalette,
      backgroundAsset: 'assets/word_hunt/baslangic_limani_bg.jpg',
      overlayDecorationsOnArtwork: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntThemedRouteMapScreen(
          route: WordHuntStarterContent.baslangicLimani,
          visualTheme: visualTheme,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('word_hunt_reusable_decoration_layer')),
      findsOneWidget,
    );
  });
}
