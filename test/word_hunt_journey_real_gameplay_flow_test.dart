import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';
import 'package:word_hunt_domain/word_hunt_progress.dart';
import 'package:word_hunt_domain/word_hunt_progress_codec.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_gameplay_host.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_prototype_shell.dart';
import 'package:word_hunt_flutter_feature/word_hunt_models.dart';
import 'package:word_hunt_flutter_feature/word_hunt_path.dart';
import 'package:word_hunt_flutter_feature/word_hunt_screens.dart';
import 'support/word_hunt_canonical_paths.dart';
import 'word_hunt_journey_shell_test.dart' as proof;

class DelayedRepository extends proof.RecordingRepository {
  Completer<void>? hold;
  @override
  Future<void> save(WordHuntJourneySaveV1 save) async {
    if (hold != null) await hold!.future;
    await super.save(save);
  }
}

Future<void> bootReal(
  WidgetTester tester,
  proof.RecordingRepository repo, {
  Size viewport = const Size(720, 1280),
}) async {
  await tester.binding.setSurfaceSize(viewport);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: WordHuntJourneyPrototypeShell(
        catalog: PublishedJourneyCatalog(levelCount: 15000),
        repository: repo,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await proof.press(tester, 'journey_home_continue');
}

Future<void> drag(WidgetTester tester, List<WordHuntCell> path) async {
  final start = tester.getCenter(
    find.byKey(
      Key('word_hunt_production_cell_${path.first.row}_${path.first.column}'),
    ),
  );
  final end = tester.getCenter(
    find.byKey(
      Key('word_hunt_production_cell_${path.last.row}_${path.last.column}'),
    ),
  );
  final gesture = await tester.startGesture(start);
  await gesture.moveTo(end);
  await gesture.up();
  await tester.pump();
}

Future<void> solve(
  WidgetTester tester,
  WordHuntLevelDefinition level, {
  int mistakes = 0,
  bool bonus = false,
}) async {
  for (var n = 0; n < mistakes; n++) {
    await drag(tester, wrongSelection(level));
  }
  if (bonus) {
    for (final word in level.bonusWords) {
      await drag(tester, canonicalPath(level, word));
    }
  }
  for (final word in level.targetWords) {
    await drag(tester, canonicalPath(level, word));
  }
  await tester.pumpAndSettle();
  if (find
      .byKey(const Key('word_hunt_production_finish'))
      .evaluate()
      .isNotEmpty) {
    await proof.press(tester, 'word_hunt_production_finish');
  }
}

void main() {
  final levels = WordHuntStarterContent.baslangicLimani.levels;
  for (final viewport in [const Size(360, 800), const Size(412, 915)]) {
    testWidgets('real gameplay launch and word completion at $viewport', (
      tester,
    ) async {
      final repo = proof.RecordingRepository();
      await bootReal(tester, repo, viewport: viewport);
      await proof.press(tester, 'word_hunt_journey_level_1');
      expect(find.byType(WordHuntLevelProductionScreen), findsOneWidget);
      await solve(tester, levels.first, bonus: true);
      expect((await repo.load())!.bestStarsByStableId[journeyStableId(1)], 3);
      expect(proof.map(tester).currentOrdinal, 2);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  for (final stars in [1, 2, 3]) {
    testWidgets(
      'real gestures produce $stars stars, bonus, save and next frontier',
      (tester) async {
        final legacy = WordHuntProgressCodec.encode(
          const WordHuntProgressSnapshot(),
          ownerScope: 'guest',
        );
        SharedPreferences.setMockInitialValues({
          WordHuntProgressCodec.storageKeyForUid(null): legacy,
          'kelime_avi_standalone_progress_v1_guest': legacy,
        });
        final preferences = await SharedPreferences.getInstance();
        final before = {
          for (final key in preferences.getKeys()) key: preferences.get(key),
        };
        final repo = proof.RecordingRepository();
        await bootReal(tester, repo);
        await proof.press(tester, 'word_hunt_journey_level_1');
        expect(find.byType(WordHuntLevelProductionScreen), findsOneWidget);
        expect(find.byType(WordHuntJourneySyntheticLevelScreen), findsNothing);
        final level = levels.first;
        final mistakes =
            stars == 3
                ? 0
                : stars == 2
                ? level.starRules.threeStarMaxMistakes! + 1
                : level.starRules.twoStarMaxMistakes! + 1;
        await solve(tester, level, mistakes: mistakes, bonus: true);
        final saved = (await repo.load())!;
        expect(saved.bestStarsByStableId, {journeyStableId(1): stars});
        expect(saved.bestBonusByStableId, {
          journeyStableId(1): level.bonusWords.length,
        });
        expect(saved.lastViewedLevelId, journeyStableId(1));
        expect(proof.map(tester).currentOrdinal, 2);
        expect(find.byType(WordHuntJourneyGameplayHost), findsNothing);
        expect(
          repo.writes,
          2,
        ); // Last-viewed, then one Journey-only completion.
        await preferences.reload();
        expect({
          for (final key in preferences.getKeys()) key: preferences.get(key),
        }, before);
        expect(saved.bestStarsByStableId.containsKey(level.id), isFalse);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  for (final ordinal in [10, 20, 31, 40]) {
    testWidgets('L$ordinal uses real canonical payload and real completion', (
      tester,
    ) async {
      final repo = proof.RecordingRepository(proof.prefix(ordinal));
      await bootReal(tester, repo);
      await proof.press(tester, 'word_hunt_journey_level_$ordinal');
      final screen = tester.widget<WordHuntLevelProductionScreen>(
        find.byType(WordHuntLevelProductionScreen),
      );
      expect(screen.level, same(levels[ordinal - 1]));
      expect(screen.deferCompletionDialog, isTrue);
      if (ordinal == 40) {
        expect(screen.level.type, WordHuntLevelType.challenge);
        expect(screen.level.timeLimitSeconds, 120);
      }
      await solve(tester, screen.level);
      expect(
        (await repo.load())!.bestStarsByStableId[journeyStableId(ordinal)],
        3,
      );
      expect(proof.map(tester).currentOrdinal, ordinal + 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('completed replay retains better stars/bonus and frontier', (
    tester,
  ) async {
    final repo = proof.RecordingRepository(
      WordHuntJourneySaveV1(
        bestStarsByStableId: {journeyStableId(1): 3},
        bestBonusByStableId: {
          journeyStableId(1): levels.first.bonusWords.length,
        },
      ),
    );
    await bootReal(tester, repo);
    await proof.press(tester, 'word_hunt_journey_level_1');
    await solve(
      tester,
      levels.first,
      mistakes: levels.first.starRules.twoStarMaxMistakes! + 1,
    );
    expect((await repo.load())!.bestStarsByStableId[journeyStableId(1)], 3);
    expect(
      (await repo.load())!.bestBonusByStableId[journeyStableId(1)],
      levels.first.bonusWords.length,
    );
    expect(proof.map(tester).currentOrdinal, 2);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'failed save keeps real outcome, rolls back, and retry commits once',
    (tester) async {
      final repo = proof.RecordingRepository();
      await bootReal(tester, repo);
      await proof.press(tester, 'word_hunt_journey_level_1');
      repo.failSave = true;
      await solve(tester, levels.first, bonus: true);
      expect(find.byKey(const Key('journey_completion_retry')), findsOneWidget);
      expect(
        find.text('Kayıt yapılamadı. Sonucun korundu; tekrar dene.'),
        findsOneWidget,
      );
      expect((await repo.load())!.bestStarsByStableId, isEmpty);
      expect(repo.writes, 1);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('journey_completion_retry')), findsOneWidget);
      expect(
        find.byType(WordHuntInfiniteJourneyMapScreen).hitTestable(),
        findsNothing,
      );
      repo.failSave = false;
      await proof.press(tester, 'journey_completion_retry');
      expect((await repo.load())!.bestStarsByStableId[journeyStableId(1)], 3);
      expect(proof.map(tester).currentOrdinal, 2);
      expect(repo.writes, 2);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('cancel after real interaction writes only last viewed', (
    tester,
  ) async {
    final repo = proof.RecordingRepository();
    await bootReal(tester, repo);
    await proof.press(tester, 'word_hunt_journey_level_1');
    await drag(
      tester,
      canonicalPath(levels.first, levels.first.targetWords.first),
    );
    await drag(
      tester,
      canonicalPath(levels.first, levels.first.bonusWords.first),
    );
    await proof.press(tester, 'word_hunt_production_back');
    // Cancel also discards a genuinely found bonus, not just target progress.
    await proof.press(tester, 'word_hunt_production_exit_confirm');
    final save = (await repo.load())!;
    expect(save.bestStarsByStableId, isEmpty);
    expect(save.bestBonusByStableId, isEmpty);
    expect(save.lastViewedLevelId, journeyStableId(1));
    expect(proof.map(tester).currentOrdinal, 1);
    expect(repo.writes, 1);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'locked does not open; published eligible content frontier is separate',
    (tester) async {
      final repo = proof.RecordingRepository();
      await bootReal(tester, repo);
      final map = proof.map(tester);
      map.onLevelTap?.call(2);
      await tester.pumpAndSettle();
      expect(find.byType(WordHuntLevelProductionScreen), findsNothing);
      expect(repo.writes, 0);
      await tester.pumpWidget(const SizedBox());
      final endRepo = proof.RecordingRepository(proof.prefix(41));
      await bootReal(tester, endRepo);
      await proof.press(tester, 'word_hunt_journey_level_41');
      expect(
        find.text('Bu bölümün oyun içeriği henüz hazır değil.'),
        findsOneWidget,
      );
      expect(find.byType(WordHuntLevelProductionScreen), findsNothing);
      expect(endRepo.writes, 0);
      expect(proof.map(tester).currentOrdinal, 41);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('system back before input cancels without completion', (
    tester,
  ) async {
    final repo = proof.RecordingRepository();
    await bootReal(tester, repo);
    await proof.press(tester, 'word_hunt_journey_level_1');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(WordHuntJourneyGameplayHost), findsNothing);
    expect((await repo.load())!.bestStarsByStableId, isEmpty);
    expect((await repo.load())!.bestBonusByStableId, isEmpty);
    expect(proof.map(tester).currentOrdinal, 1);
    expect(repo.writes, 1);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('pending persistence blocks return until acknowledged', (
    tester,
  ) async {
    final repo = DelayedRepository();
    await bootReal(tester, repo);
    await proof.press(tester, 'word_hunt_journey_level_1');
    repo.hold = Completer<void>();
    for (final word in levels.first.targetWords) {
      await drag(tester, canonicalPath(levels.first, word));
    }
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('word_hunt_production_finish')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(WordHuntJourneyGameplayHost), findsOneWidget);
    expect(
      find.byType(WordHuntInfiniteJourneyMapScreen).hitTestable(),
      findsNothing,
    );
    expect((await repo.load())!.bestStarsByStableId, isEmpty);
    repo.hold!.complete();
    await tester.pumpAndSettle();
    expect(proof.map(tester).currentOrdinal, 2);
    expect(repo.writes, 2);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('replay improves bonus without losing existing stars', (
    tester,
  ) async {
    final repo = proof.RecordingRepository(
      WordHuntJourneySaveV1(
        bestStarsByStableId: {journeyStableId(1): 3},
        bestBonusByStableId: {journeyStableId(1): 0},
      ),
    );
    await bootReal(tester, repo);
    await proof.press(tester, 'word_hunt_journey_level_1');
    await solve(tester, levels.first, bonus: true);
    expect(
      (await repo.load())!.bestBonusByStableId[journeyStableId(1)],
      levels.first.bonusWords.length,
    );
    expect((await repo.load())!.bestStarsByStableId[journeyStableId(1)], 3);
    expect(proof.map(tester).currentOrdinal, 2);
    await tester.pumpWidget(const SizedBox());
  });
}
