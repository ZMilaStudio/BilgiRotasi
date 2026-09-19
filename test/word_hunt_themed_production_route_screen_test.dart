import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_edge_ambient.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_chrome_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_themed_production_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const progressThroughSeven = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'orman-yolu-01': 3,
      'orman-yolu-02': 3,
      'orman-yolu-03': 3,
      'orman-yolu-04': 3,
      'orman-yolu-05': 3,
      'orman-yolu-06': 3,
      'orman-yolu-07': 3,
    },
  );

  const progressThroughNine = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'orman-yolu-01': 3,
      'orman-yolu-02': 3,
      'orman-yolu-03': 3,
      'orman-yolu-04': 3,
      'orman-yolu-05': 3,
      'orman-yolu-06': 3,
      'orman-yolu-07': 3,
      'orman-yolu-08': 3,
      'orman-yolu-09': 3,
    },
  );

  testWidgets('fresh production route opens only level 1', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var tappedLevel = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntThemedProductionRouteScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: WordHuntRouteVisualThemes.ormanYolu,
          progress: const WordHuntProgressSnapshot(),
          onBack: () {},
          onInfo: () {},
          onCompass: () {},
          onBook: () {},
          onLevelTap: (level) => tappedLevel = level,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('word_hunt_reusable_level_1')));
    await tester.pump();
    expect(tappedLevel, 1);

    for (var level = 2; level <= 10; level++) {
      tappedLevel = 0;
      await tester.tap(
        find.byKey(Key('word_hunt_reusable_level_$level')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(tappedLevel, 0, reason: 'Bölüm $level fresh progress ile kilitli');
      expect(tester.takeException(), isNull);
    }

    expect(find.byKey(const Key('word_hunt_route_final_lock')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('word_hunt_orman_header_panel'))).height,
      47,
    );
    expect(
      tester.getSize(find.byKey(const Key('word_hunt_route_stop_plaque_5'))),
      Size.zero,
      reason: 'Meydan Okuma tabelası dekoratif kalmalı; ayrı buton olmamalı.',
    );
  });

  testWidgets('final unlock removes lock overlay without changing progression', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntThemedProductionRouteScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: WordHuntRouteVisualThemes.ormanYolu,
          progress: progressThroughNine,
          onBack: () {},
          onInfo: () {},
          onCompass: () {},
          onBook: () {},
          onLevelTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word_hunt_route_final_lock')), findsNothing);
    expect(
      find.byKey(const Key('word_hunt_reusable_node_10_current')),
      findsOneWidget,
    );
  });

  testWidgets('production themed chrome forwards controls and compass pulses next node', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var backCount = 0;
    var infoCount = 0;
    var compassCount = 0;
    var bookCount = 0;
    var tappedLevel = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntThemedProductionRouteScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: WordHuntRouteVisualThemes.ormanYolu,
          progress: progressThroughSeven,
          onBack: () => backCount++,
          onInfo: () => infoCount++,
          onCompass: () => compassCount++,
          onBook: () => bookCount++,
          onLevelTap: (level) => tappedLevel = level,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('word_hunt_themed_production_route')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_route_map')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('word_hunt_themed_chrome_back')));
    await tester.tap(find.byKey(const Key('word_hunt_themed_chrome_info')));
    await tester.tap(find.byKey(const Key('word_hunt_themed_chrome_compass')));
    await tester.tap(find.byKey(const Key('word_hunt_themed_chrome_book')));
    await tester.pump(const Duration(milliseconds: 80));

    expect(backCount, 1);
    expect(infoCount, 1);
    expect(compassCount, 1);
    expect(bookCount, 1);
    expect(
      find.byKey(
        const ValueKey<String>('word_hunt_route_stop_compass_highlight_8_1'),
      ),
      findsOneWidget,
      reason: 'Pusula yalnız sıradaki oynanabilir Bölüm 8’i vurgulamalı.',
    );

    await tester.pump(const Duration(milliseconds: 1100));
    expect(
      find.byKey(
        const ValueKey<String>('word_hunt_route_stop_compass_highlight_8_1'),
      ),
      findsNothing,
      reason: 'Pusula vurgusu kısa süreli olmalı.',
    );

    await tester.tap(find.byKey(const Key('word_hunt_reusable_level_8')));
    await tester.pump();
    expect(tappedLevel, 8);

    tappedLevel = 0;
    await tester.tap(
      find.byKey(const Key('word_hunt_reusable_level_9')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tappedLevel, 0);
    expect(tester.takeException(), isNull);
  });

  test('edge-derived ambient source has no mirror or vertical flip transform', () {
    final source = File(
      'lib/word_hunt/word_hunt_edge_ambient.dart',
    ).readAsStringSync();
    expect(source, isNot(contains('Matrix4.diagonal3Values')));
    expect(source, isNot(contains('Transform.flip')));
    expect(source, isNot(contains('scaleY: -1')));
  });

  testWidgets(
    'edge-derived tall bands and configured icon chrome render without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final base = WordHuntKristalVisualTheme.production;
      final foundationTheme = WordHuntRouteVisualTheme(
        id: 'wave1-foundation-test',
        mapTheme: base.mapTheme,
        decorationSpec: base.decorationSpec,
        decorationPalette: base.decorationPalette,
        decorationOpacity: 0,
        backgroundAsset: base.backgroundAsset,
        backgroundFit: base.backgroundFit,
        backgroundAlignment: base.backgroundAlignment,
        artworkOverlayMode: base.artworkOverlayMode,
        referenceCanvasSize: const Size(411, 731),
        extendTallAmbientFromArtworkEdges: true,
        tallAmbientMode: WordHuntTallAmbientMode.edgeDerivedLowFrequency,
        chromeTheme: WordHuntRouteChromeTheme.iconFoundation,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntThemedProductionRouteScreen(
            route: WordHuntOrmanContent.ormanYolu,
            visualTheme: foundationTheme,
            progress: progressThroughSeven,
            onBack: () {},
            onInfo: () {},
            onCompass: () {},
            onBook: () {},
            onLevelTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('word_hunt_edge_ambient_top')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_edge_ambient_bottom')),
        findsOneWidget,
      );

      final compass = find.byKey(
        const Key('word_hunt_themed_chrome_compass'),
      );
      final codex = find.byKey(const Key('word_hunt_themed_chrome_book'));
      expect(
        find.descendant(
          of: compass,
          matching: find.byIcon(Icons.explore_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: codex,
          matching: find.byIcon(Icons.menu_book_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: compass, matching: find.byType(Image)),
        findsNothing,
      );
      expect(
        find.descendant(of: codex, matching: find.byType(Image)),
        findsNothing,
      );
      final header = tester.widget<Container>(
        find.byKey(const Key('word_hunt_reusable_route_header_panel')),
      );
      final headerDecoration = header.decoration! as BoxDecoration;
      final headerGradient = headerDecoration.gradient! as LinearGradient;
      expect(
        headerGradient.colors.first,
        WordHuntRouteChromeTheme.iconFoundation.headerTint.withValues(
          alpha: 0.90,
        ),
      );
      expect(
        headerGradient.colors.last,
        WordHuntRouteChromeTheme.iconFoundation.surfaceTint.withValues(
          alpha: 0.94,
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('existing route keeps legacy Harbor asset controls by default', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntThemedProductionRouteScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: WordHuntRouteVisualThemes.ormanYolu,
          progress: progressThroughSeven,
          onBack: () {},
          onInfo: () {},
          onCompass: () {},
          onBook: () {},
          onLevelTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('word_hunt_themed_chrome_compass')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word_hunt_themed_chrome_book')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('production themed chrome stays overflow-free and controls do not overlap final', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntThemedProductionRouteScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: WordHuntRouteVisualThemes.ormanYolu,
          progress: progressThroughSeven,
          onBack: () {},
          onInfo: () {},
          onCompass: () {},
          onBook: () {},
          onLevelTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('word_hunt_themed_chrome_back')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_themed_chrome_book')),
      findsOneWidget,
    );

    final finalRect = tester.getRect(
      find.byKey(const Key('word_hunt_reusable_level_10')),
    );
    final compassRect = tester.getRect(
      find.byKey(const Key('word_hunt_themed_chrome_compass')),
    );
    final bookRect = tester.getRect(
      find.byKey(const Key('word_hunt_themed_chrome_book')),
    );
    expect(finalRect.overlaps(compassRect), isFalse);
    expect(finalRect.overlaps(bookRect), isFalse);
  });
}
