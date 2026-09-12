import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
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
    await tester.pump();

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
  });

  testWidgets('production themed chrome forwards all controls and level taps', (
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
    await tester.pump();

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
    await tester.pump();

    expect(backCount, 1);
    expect(infoCount, 1);
    expect(compassCount, 1);
    expect(bookCount, 1);

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

  testWidgets('production themed chrome stays overflow-free on narrow phone', (
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
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('word_hunt_themed_chrome_back')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_themed_chrome_book')),
      findsOneWidget,
    );
  });
}
