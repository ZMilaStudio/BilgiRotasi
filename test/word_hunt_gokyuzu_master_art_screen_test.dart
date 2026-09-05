import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_master_art_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

WordHuntRouteDefinition _route() {
  return WordHuntRouteDefinition(
    id: 'gokyuzu-adalari',
    title: 'Gökyüzü Adaları',
    theme: 'sky',
    unlockStarsRequired: 18,
    routeRewardId: 'gokyuzu_reward',
    levels: List<WordHuntLevelDefinition>.generate(10, (zeroBased) {
      final index = zeroBased + 1;
      return WordHuntLevelDefinition(
        id: 'gokyuzu-$index',
        routeId: 'gokyuzu-adalari',
        index: index,
        type: index == 8
            ? WordHuntLevelType.bonus
            : index == 10
                ? WordHuntLevelType.routeFinal
                : WordHuntLevelType.normal,
        grid: const <String>['AAA', 'AAA', 'AAA'],
        targetWords: const <String>['AAA'],
        starRules: const WordHuntStarRules(),
      );
    }),
  );
}

void main() {
  testWidgets('Gökyüzü route uses approved master art and transparent hitboxes',
      (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntGokyuzuMasterArtScreen(
          route: _route(),
          onLevelTap: taps.add,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('word_hunt_gokyuzu_master_art_image')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_gokyuzu_progress_text')), findsOneWidget);
    expect(find.text('0 / 30'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_gokyuzu_level_1')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_gokyuzu_level_10')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_gokyuzu_compass')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_gokyuzu_book')), findsOneWidget);

    await tester.tap(find.byKey(const Key('word_hunt_gokyuzu_level_1')));
    await tester.pump();
    expect(taps, <int>[1]);

    await tester.tap(find.byKey(const Key('word_hunt_gokyuzu_level_2')));
    await tester.pump();
    expect(taps, <int>[1]);
  });

  test('Gökyüzü bonus 8 does not gate normal node 9', () {
    final route = _route();
    const empty = WordHuntProgressSnapshot();

    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, empty, 1), isTrue);
    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, empty, 8), isFalse);
    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, empty, 9), isFalse);

    final afterSeven = empty.recordLevelResult(levelId: 'gokyuzu-7', stars: 1);
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, afterSeven, 8),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, afterSeven, 9),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, afterSeven, 10),
      isFalse,
    );

    final afterNine = afterSeven.recordLevelResult(levelId: 'gokyuzu-9', stars: 1);
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, afterNine, 10),
      isTrue,
    );
  });
}
