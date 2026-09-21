import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('approved route map renders ten deterministic stops', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: WordHuntRouteMapPrototypeScreen()),
    );

    expect(find.text('BAŞLANGIÇ LİMANI'), findsOneWidget);
    expect(find.text('MEYDAN OKUMA'), findsOneWidget);
    expect(find.text('BONUS DURAK'), findsNothing);
    expect(find.text('ROTA FİNALİ'), findsOneWidget);

    for (var index = 1; index <= 10; index++) {
      expect(find.byKey(Key('word_hunt_map_level_$index')), findsOneWidget);
    }
  });

  testWidgets('only unlocked map stop invokes callback', (tester) async {
    var tappedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteMapPrototypeScreen(
          onLevelTap: (index) => tappedIndex = index,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('word_hunt_map_level_1')));
    await tester.pump();
    expect(tappedIndex, 1);

    tappedIndex = 0;
    await tester.tap(find.byKey(const Key('word_hunt_map_level_2')));
    await tester.pump();
    expect(tappedIndex, 0);
  });

  testWidgets('completing first stop unlocks second stop', (tester) async {
    final firstLevel = WordHuntStarterContent.baslangicLimani.levels.first;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{firstLevel.id: 2},
    );
    var tappedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteMapPrototypeScreen(
          progress: progress,
          onLevelTap: (index) => tappedIndex = index,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('word_hunt_map_level_2')));
    await tester.pump();
    expect(tappedIndex, 2);
    expect(find.text('2 / 60'), findsOneWidget);
  });

  testWidgets('enriched harbor map remains stable on a narrow phone surface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: WordHuntRouteMapPrototypeScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('word_hunt_map_level_1')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_map_level_10')), findsOneWidget);
    expect(find.text('MEYDAN OKUMA'), findsOneWidget);
    expect(find.text('BONUS DURAK'), findsNothing);
    expect(find.text('ROTA FİNALİ'), findsOneWidget);
  });
}
