import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_master_art_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = _route();

  Future<void> usePhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(540, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('phone MASTER ART, banner reserve and controls render', (
    tester,
  ) async {
    await usePhoneViewport(tester);
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntGokyuzuMasterArtScreen(
          route: route,
          onLevelTap: (index) => tapped = index,
        ),
      ),
    );
    await tester.pump();

    expect(WordHuntGokyuzuMasterArtLayout.sourceSize, const Size(941, 1672));
    expect(WordHuntGokyuzuMasterArtLayout.bannerReserveHeight, 50);
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_phone_viewport')),
      findsOneWidget,
    );
    expect(
      tester.getSize(
        find.byKey(const Key('word_hunt_gokyuzu_master_art_phone_viewport')),
      ),
      const Size(540, 910),
    );
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_image')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_banner_reserve')),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const Key('word_hunt_gokyuzu_banner_reserve'))),
      const Size(540, 50),
    );
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_compass')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_book')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_back')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_info')),
      findsOneWidget,
    );
    for (var index = 1; index <= 10; index++) {
      expect(
        find.byKey(Key('word_hunt_gokyuzu_master_art_level_$index')),
        findsOneWidget,
      );
    }

    await tester.tap(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_level_1')),
    );
    await tester.pump();
    expect(tapped, 1);

    tapped = 0;
    await tester.tap(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_level_2')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tapped, 0);
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_level_2_locked')),
      findsOneWidget,
    );
  });

  testWidgets('completed previous level unlocks the next hitbox', (
    tester,
  ) async {
    await usePhoneViewport(tester);
    var tapped = 0;
    final progress = const WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{'gokyuzu-1': 2},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntGokyuzuMasterArtScreen(
          route: route,
          progress: progress,
          onLevelTap: (index) => tapped = index,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_level_2')),
    );
    await tester.pump();
    expect(tapped, 2);
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_level_2_locked')),
      findsNothing,
    );
  });

  test('level 7 opens bonus 8 and normal 9; 10 waits for 9', () {
    final after7 = const WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'gokyuzu-1': 1,
        'gokyuzu-2': 1,
        'gokyuzu-3': 1,
        'gokyuzu-4': 1,
        'gokyuzu-5': 1,
        'gokyuzu-6': 1,
        'gokyuzu-7': 1,
      },
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, after7, 8),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, after7, 9),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, after7, 10),
      isFalse,
    );

    final after9 = after7.recordLevelResult(levelId: 'gokyuzu-9', stars: 1);
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, after9, 10),
      isTrue,
    );
  });
}

WordHuntRouteDefinition _route() {
  return WordHuntRouteDefinition(
    id: 'gokyuzu-adalari',
    title: 'Gökyüzü Adaları',
    theme: 'gokyuzu',
    unlockStarsRequired: 18,
    routeRewardId: 'badge-gokyuzu-kasifi',
    levels: List<WordHuntLevelDefinition>.generate(10, (zeroBased) {
      final index = zeroBased + 1;
      return WordHuntLevelDefinition(
        id: 'gokyuzu-$index',
        routeId: 'gokyuzu-adalari',
        index: index,
        type:
            index == 8
                ? WordHuntLevelType.bonus
                : index == 10
                ? WordHuntLevelType.routeFinal
                : WordHuntLevelType.normal,
        grid: const <String>['ABC', 'DEF', 'GHI'],
        targetWords: const <String>['ABC'],
        starRules: const WordHuntStarRules(),
      );
    }),
  );
}
