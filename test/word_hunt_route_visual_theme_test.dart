import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_map_decoration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('proof visual themes are unique data bundles without geometry', () {
    final themes = WordHuntRouteVisualThemeProofs.all;

    expect(themes, hasLength(3));
    expect(themes.map((theme) => theme.id).toSet(), hasLength(themes.length));

    for (final theme in themes) {
      expect(theme.id, isNotEmpty);
      expect(theme.decorationSpec.count, inInclusiveRange(0, 40));
      expect(theme.decorationOpacity, inInclusiveRange(0.0, 1.0));
      expect(theme.backgroundBlurSigma, greaterThanOrEqualTo(0));
    }

    // Tema paketleri node koordinatı taşımaz; canonical 1-10 geometri tek
    // kaynak olarak ortak motor üzerinde kalır.
    expect(WordHuntRouteMapGeometry.normalizedStops, hasLength(10));
  });

  test('changing visual theme never changes canonical 1-10 map points', () {
    const size = Size(390, 844);
    final canonical = WordHuntRouteMapGeometry.pointsFor(size);

    for (final theme in WordHuntRouteVisualThemeProofs.all) {
      expect(theme.mapTheme.id, isNotEmpty);
      expect(WordHuntRouteMapGeometry.pointsFor(size), canonical);
    }
  });

  testWidgets('one generic themed screen renders forest sky and harbor', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final visualTheme in WordHuntRouteVisualThemeProofs.all) {
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntThemedRouteMapScreen(
            route: WordHuntStarterContent.baslangicLimani,
            visualTheme: visualTheme,
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('word_hunt_reusable_route_map')),
        findsOneWidget,
      );
      for (var level = 1; level <= 10; level++) {
        expect(
          find.byKey(Key('word_hunt_reusable_level_$level')),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('generic themed screen can place raster artwork below live nodes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const artworkTheme = WordHuntRouteVisualTheme(
      id: 'artwork-contract-proof',
      mapTheme: WordHuntRouteMapTheme(
        id: 'artwork-contract-proof',
        backgroundColor: Color(0xFF07150D),
        surfaceColor: Color(0xFF143420),
        pathColor: Color(0xFFEBD49B),
        lockedPathColor: Color(0xFF657066),
        nodeColor: Color(0xFF81542F),
        lockedNodeColor: Color(0xFF4A5050),
        accentColor: Color(0xFFFFD96B),
        textColor: Color(0xFFFFF7E2),
      ),
      decorationSpec: WordHuntRouteDecorationSpec(
        kind: WordHuntRouteDecorationKind.forest,
        seed: 7,
        count: 0,
      ),
      decorationPalette: WordHuntRouteDecorationPalette(
        primary: Color(0xFF4F8A45),
        secondary: Color(0xFF6A4328),
        accent: Color(0xFFFFE08A),
      ),
      backgroundAsset: 'assets/word_hunt/baslangic_limani_bg.jpg',
      backgroundBlurSigma: 1.5,
      backgroundOverlayColor: Color(0x22000000),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntThemedRouteMapScreen(
          route: WordHuntStarterContent.baslangicLimani,
          visualTheme: artworkTheme,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('word_hunt_themed_artwork_stack')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_route_background_asset')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_route_background_overlay')),
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

  testWidgets('real Orman Yolu content renders through the same generic map', (
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
          visualTheme: WordHuntRouteVisualThemeProofs.forest,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Orman Yolu'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_reusable_route_map')),
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
}
