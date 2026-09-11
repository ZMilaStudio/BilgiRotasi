import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
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
}
