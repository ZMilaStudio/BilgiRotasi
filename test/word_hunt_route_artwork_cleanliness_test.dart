import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
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

  test('Orman production skin points at the scenic artwork bundle', () {
    const theme = WordHuntRouteVisualThemes.ormanYolu;
    expect(theme.id, 'orman-yolu-production');
    expect(theme.hasArtwork, isTrue);
    expect(theme.backgroundAsset, isNull);
    expect(theme.backgroundBase64AssetParts, hasLength(7));
    expect(theme.overlayDecorationsOnArtwork, isFalse);
    expect(theme.backgroundScale, 1);
    expect(theme.backgroundBlurSigma, 0);
    expect(theme.backgroundOverlayColor, Colors.transparent);
    expect(theme.mapTheme.pathColor, const Color(0xFFE7CB83));
    expect(theme.mapTheme.lockedPathColor, const Color(0xFFB5A276));
    expect(theme.mapTheme.pathUnderlayColor, const Color(0xFF342416));
    expect(theme.mapTheme.lockedNodeColor, const Color(0xFF56594F));
    expect(theme.mapTheme.nodeShadowColor, const Color(0xFF08120D));
  });

  testWidgets('Orman production artwork decodes with production route overlay', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntThemedRouteMapScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: WordHuntRouteVisualThemes.ormanYolu,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('word_hunt_route_background_asset')),
      findsOneWidget,
    );
    expect(find.byType(Image), findsWidgets);
    expect(
      find.byKey(const Key('word_hunt_route_stop_asset_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_plaque_5')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_plaque_10')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_decoration_layer')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_route_path')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_node_1_current')),
      findsOneWidget,
    );
    for (var level = 2; level <= 10; level++) {
      expect(
        find.byKey(Key('word_hunt_reusable_node_${level}_locked')),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);
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
