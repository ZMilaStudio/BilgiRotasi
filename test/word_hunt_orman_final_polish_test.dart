import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_production_entry_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_themed_production_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const throughSeven = WordHuntProgressSnapshot(
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

  const throughNine = WordHuntProgressSnapshot(
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

  const completedWithTwoFinalStars = WordHuntProgressSnapshot(
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
      'orman-yolu-10': 2,
    },
  );

  Future<void> pumpRoute(
    WidgetTester tester,
    WordHuntProgressSnapshot progress, {
    Size size = const Size(390, 844),
    EdgeInsets safePadding = EdgeInsets.zero,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size, padding: safePadding),
          child: WordHuntThemedProductionRouteScreen(
            route: WordHuntOrmanContent.ormanYolu,
            visualTheme: WordHuntRouteVisualThemes.ormanYolu,
            progress: progress,
            onBack: () {},
            onInfo: () {},
            onLevelTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('final node locked open and completed states stay distinct', (
    tester,
  ) async {
    await pumpRoute(tester, const WordHuntProgressSnapshot());
    expect(find.byKey(const Key('word_hunt_route_final_lock')), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_reusable_node_10_locked')),
      findsOneWidget,
    );

    await pumpRoute(tester, throughNine);
    expect(find.byKey(const Key('word_hunt_route_final_lock')), findsNothing);
    expect(
      find.byKey(const Key('word_hunt_reusable_node_10_current')),
      findsOneWidget,
    );
    expect(find.text('27 / 30'), findsOneWidget);

    await pumpRoute(tester, completedWithTwoFinalStars);
    expect(find.byKey(const Key('word_hunt_route_final_lock')), findsNothing);
    expect(
      find.byKey(const Key('word_hunt_reusable_node_10_completed')),
      findsOneWidget,
    );
    expect(find.text('29 / 30'), findsOneWidget);
  });

  testWidgets('safe area and top touch targets stay separated on compact phone', (
    tester,
  ) async {
    const size = Size(360, 720);
    const padding = EdgeInsets.only(top: 44, bottom: 34);
    await pumpRoute(
      tester,
      throughSeven,
      size: size,
      safePadding: padding,
    );

    final back = tester.getRect(
      find.byKey(const Key('word_hunt_themed_chrome_back')),
    );
    final info = tester.getRect(
      find.byKey(const Key('word_hunt_themed_chrome_info')),
    );
    final finalNode = tester.getRect(
      find.byKey(const Key('word_hunt_reusable_level_10')),
    );

    expect(back.top, greaterThanOrEqualTo(padding.top));
    expect(info.top, greaterThanOrEqualTo(padding.top));
    expect(back.width, greaterThanOrEqualTo(48));
    expect(back.height, greaterThanOrEqualTo(48));
    expect(info.width, greaterThanOrEqualTo(48));
    expect(info.height, greaterThanOrEqualTo(48));
    expect(finalNode.width, greaterThanOrEqualTo(78));
    expect(finalNode.height, greaterThanOrEqualTo(72));
    expect(
      find.byKey(const Key('word_hunt_themed_chrome_compass')),
      findsNothing,
    );
    expect(find.byKey(const Key('word_hunt_themed_chrome_book')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removed compass leaves canonical next playable node intact', (
    tester,
  ) async {
    await pumpRoute(tester, throughSeven);

    expect(
      find.byKey(const Key('word_hunt_themed_chrome_compass')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_node_8_current')),
      findsOneWidget,
    );
    for (var level = 1; level <= 10; level++) {
      expect(
        find.byKey(
          ValueKey<String>('word_hunt_route_stop_compass_highlight_${level}_1'),
        ),
        findsNothing,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('info guide stays reachable without book dependency', (
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
        home: WordHuntProductionEntryScreen(
          ownerUid: 'orman-final-polish-book',
          route: WordHuntOrmanContent.ormanYolu,
          infoCards: WordHuntOrmanContent.infoCards,
          routeSelectionEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word_hunt_themed_chrome_book')), findsNothing);
    await tester.tap(find.byKey(const Key('word_hunt_themed_chrome_info')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_route_help_dialog')), findsOneWidget);
    expect(find.text('Bölümleri sırayla tamamla.'), findsOneWidget);
    expect(
      find.text('Her bölümden en fazla 3 yıldız kazanılabilir.'),
      findsOneWidget,
    );
    expect(find.text('İlerledikçe yeni duraklar açılır.'), findsOneWidget);
    expect(find.text('Taçlı bölüm tema finalidir.'), findsOneWidget);
    expect(find.text('Pusula sonraki durağı gösterir.'), findsNothing);
    expect(
      find.text('Kitap bölümün konusu hakkında bilgi verir.'),
      findsNothing,
    );
    expect(find.byKey(const Key('word_hunt_unlocked_info_cards')), findsNothing);

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_route_help_dialog')), findsNothing);
    expect(find.byKey(const Key('word_hunt_unlocked_info_cards')), findsNothing);
  });

  testWidgets('opening transition stays short and Meydan Okuma stays decorative', (
    tester,
  ) async {
    await pumpRoute(tester, const WordHuntProgressSnapshot());

    final transition = tester.widget<TweenAnimationBuilder<double>>(
      find.byKey(const Key('word_hunt_orman_opening_transition')),
    );
    expect(transition.duration, const Duration(milliseconds: 650));
    expect(transition.duration, lessThan(const Duration(seconds: 1)));

    expect(find.text('MEYDAN OKUMA'), findsNothing);
    expect(find.bySemanticsLabel('Meydan Okuma'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
