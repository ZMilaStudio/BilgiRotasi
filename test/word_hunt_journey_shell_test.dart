import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_domain/word_hunt_journey_progress.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_codec.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_prototype_shell.dart';

class RecordingRepository implements JourneySaveRepository {
  RecordingRepository([WordHuntJourneySaveV1? seed])
    : inner = InMemoryJourneySaveRepository(
        initialJson:
            seed == null ? null : const WordHuntJourneySaveCodec().encode(seed),
      );
  final InMemoryJourneySaveRepository inner;
  int writes = 0;
  bool failSave = false;
  @override
  Future<WordHuntJourneySaveV1?> load() => inner.load();
  @override
  Future<void> save(WordHuntJourneySaveV1 save) async {
    if (failSave) throw StateError('Internal storage failure');
    writes++;
    await inner.save(save);
  }

  @override
  Future<void> clear() => inner.clear();
}

WordHuntJourneySaveV1 prefix(int frontier, {int? last}) =>
    WordHuntJourneySaveV1(
      bestStarsByStableId: {
        for (var n = 1; n < frontier; n++) journeyStableId(n): 3,
      },
      lastViewedLevelId: last == null ? null : journeyStableId(last),
    );

Future<void> boot(
  WidgetTester tester,
  RecordingRepository repository, {
  int count = 150,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WordHuntJourneyPrototypeShell(
        syntheticProof: true,
        catalog: PublishedJourneyCatalog(
          levelCount: 15000,
          publishedLevelCount: count,
        ),
        repository: repository,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> press(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Future<void> jump(WidgetTester tester, String input) async {
  await press(tester, 'journey_go_to');
  await tester.enterText(find.byKey(const Key('journey_ordinal_input')), input);
  await press(tester, 'journey_jump_submit');
}

Future<void> complete(
  WidgetTester tester,
  int ordinal,
  int stars,
  int bonus,
) async {
  await press(tester, 'word_hunt_journey_level_$ordinal');
  expect(find.byType(WordHuntJourneySyntheticLevelScreen), findsOneWidget);
  await press(tester, 'journey_stars_$stars');
  await tester.enterText(
    find.byKey(const Key('journey_bonus_input')),
    '$bonus',
  );
  await press(tester, 'journey_finish');
  expect(find.byType(WordHuntJourneySyntheticLevelScreen), findsNothing);
  expect(
    find.byKey(Key('word_hunt_journey_level_$ordinal')).hitTestable(),
    findsOneWidget,
  );
}

WordHuntInfiniteJourneyMapScreen map(WidgetTester tester) =>
    tester.widget(find.byType(WordHuntInfiniteJourneyMapScreen));
int countSemantics(WidgetTester tester) {
  var count = 0;
  void visit(SemanticsNode node) {
    count++;
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return count;
}

bool hasEditableLabel(WidgetTester tester, String label) {
  var found = false;
  void visit(SemanticsNode node) {
    final data = node.getSemanticsData();
    if (data.flagsCollection.isTextField &&
        data.label.contains(label) &&
        data.hasAction(ui.SemanticsAction.setText))
      found = true;
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return found;
}

void main() {
  testWidgets(
    'dialog and completion actions have semantics; back cancels gameplay',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        final repository = RecordingRepository();
        await boot(tester, repository);
        await press(tester, 'journey_home_continue');
        await press(tester, 'journey_go_to');
        // TextField's wrapper is not its editable semantics child.
        await press(tester, 'journey_ordinal_input');
        expect(hasEditableLabel(tester, 'Bölüm numarası'), isTrue);
        expect(
          tester
              .getSemantics(find.byKey(const Key('journey_jump_submit')))
              .getSemanticsData()
              .hasAction(ui.SemanticsAction.tap),
          isTrue,
        );
        await tester.tap(find.text('İPTAL'));
        await tester.pumpAndSettle();
        await press(tester, 'word_hunt_journey_level_1');
        for (final key in [
          'journey_stars_1',
          'journey_stars_2',
          'journey_stars_3',
          'journey_finish',
        ]) {
          expect(
            tester
                .getSemantics(find.byKey(Key(key)))
                .getSemanticsData()
                .hasAction(ui.SemanticsAction.tap),
            isTrue,
          );
        }
        await press(tester, 'journey_bonus_input');
        expect(hasEditableLabel(tester, 'Bonus sayısı'), isTrue);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('word_hunt_journey_level_1')).hitTestable(),
          findsOneWidget,
        );
        expect(
          (await repository.load())!.isCompleted(journeyStableId(1)),
          isFalse,
        );
        expect(map(tester).currentOrdinal, 1);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('journey_home_continue')), findsOneWidget);
      } finally {
        handle.dispose();
      }
    },
  );
  testWidgets(
    'home continue is frontier, resume is last viewed; controls accessible',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        final repository = RecordingRepository(prefix(23, last: 4));
        await boot(tester, repository);
        for (final key in ['journey_home_continue', 'journey_home_map']) {
          final data =
              tester.getSemantics(find.byKey(Key(key))).getSemanticsData();
          expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
          expect(data.flagsCollection.isButton, isTrue);
        }
        await press(tester, 'journey_home_continue');
        expect(
          find.byKey(const Key('word_hunt_journey_level_23')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('word_hunt_journey_continue')),
          findsNothing,
        );
        await press(tester, 'journey_back');
        await press(tester, 'journey_home_map');
        expect(
          find.byKey(const Key('word_hunt_journey_level_4')),
          findsOneWidget,
        );
        expect(map(tester).currentOrdinal, 23);
        await press(tester, 'journey_map_continue');
        expect(
          find.byKey(const Key('word_hunt_journey_level_23')),
          findsOneWidget,
        );
        expect(repository.writes, 0);
      } finally {
        handle.dispose();
      }
    },
  );
  for (final entry
      in <String, String>{
        '': 'Geçerli bir bölüm numarası gir.',
        'abc': 'Geçerli bir bölüm numarası gir.',
        '0': 'Geçerli bir bölüm numarası gir.',
        '-1': 'Geçerli bir bölüm numarası gir.',
        '2.5': 'Geçerli bir bölüm numarası gir.',
        '24': 'Bu bölüm henüz açılmadı.',
        '151': 'Bu bölüm henüz yayınlanmadı.',
      }.entries) {
    testWidgets('go-to rejects ${entry.key} accessibly without save mutation', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        final repository = RecordingRepository(prefix(23, last: 4));
        await boot(tester, repository);
        await press(tester, 'journey_home_map');
        final before = const WordHuntJourneySaveCodec().encode(
          (await repository.load())!,
        );
        await jump(tester, entry.key);
        expect(find.text(entry.value), findsOneWidget);
        expect(
          tester
              .getSemantics(find.text(entry.value))
              .getSemanticsData()
              .flagsCollection
              .isLiveRegion,
          isTrue,
        );
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(repository.writes, 0);
        expect(
          const WordHuntJourneySaveCodec().encode((await repository.load())!),
          before,
        );
        expect(find.byType(WordHuntJourneySyntheticLevelScreen), findsNothing);
      } finally {
        handle.dispose();
      }
    });
  }
  testWidgets(
    'eligible jumps persist only last viewed; locked tap and scroll do not save',
    (tester) async {
      final repository = RecordingRepository(prefix(3, last: 1));
      await boot(tester, repository);
      await press(tester, 'journey_home_map');
      await press(tester, 'word_hunt_journey_level_4');
      expect(find.byType(WordHuntJourneySyntheticLevelScreen), findsNothing);
      expect(repository.writes, 0);
      await jump(tester, '2');
      expect((await repository.load())!.lastViewedLevelId, journeyStableId(2));
      expect(map(tester).currentOrdinal, 3);
      await jump(tester, '3');
      expect((await repository.load())!.lastViewedLevelId, journeyStableId(3));
      final writes = repository.writes;
      await tester.drag(
        find.byKey(const Key('word_hunt_infinite_journey_list')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(repository.writes, writes);
      expect((await repository.load())!.lastViewedLevelId, journeyStableId(3));
    },
  );
  testWidgets(
    '1/2/3 star completion, bonus, replay and return anchor synchronize map',
    (tester) async {
      final repository = RecordingRepository();
      await boot(tester, repository);
      await press(tester, 'journey_home_continue');
      for (var n = 1; n <= 3; n++) {
        await press(tester, 'journey_map_continue');
        await complete(tester, n, n, n + 2);
        final save = (await repository.load())!;
        expect(save.bestStarsByStableId[journeyStableId(n)], n);
        expect(save.bestBonusByStableId[journeyStableId(n)], n + 2);
        expect(save.lastViewedLevelId, journeyStableId(n));
        expect(map(tester).stateForOrdinal(n).stars, n);
        expect(
          map(tester).stateForOrdinal(n + 1).state,
          WordHuntJourneyNodeState.current,
        );
        expect(find.byKey(Key('word_hunt_journey_level_$n')), findsOneWidget);
      }
      await complete(tester, 3, 1, 1);
      final save = (await repository.load())!;
      expect(save.bestStarsByStableId[journeyStableId(3)], 3);
      expect(save.bestBonusByStableId[journeyStableId(3)], 5);
      expect(map(tester).currentOrdinal, 4);
      expect(save.lastViewedLevelId, journeyStableId(3));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'dispose/reconstruct loads completion stars bonus and last viewed separately',
    (tester) async {
      final repository = RecordingRepository();
      await boot(tester, repository);
      await press(tester, 'journey_home_continue');
      await complete(tester, 1, 3, 4);
      await press(tester, 'journey_map_continue');
      await complete(tester, 2, 2, 5);
      await jump(tester, '1');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await boot(tester, repository);
      expect(find.text('Bölüm 3'), findsOneWidget);
      expect(find.text('Toplam yıldız: 5'), findsOneWidget);
      await press(tester, 'journey_home_map');
      expect(
        find.byKey(const Key('word_hunt_journey_level_1')),
        findsOneWidget,
      );
      final save = (await repository.load())!;
      expect(save.lastViewedLevelId, journeyStableId(1));
      expect(save.bestBonusByStableId, {
        journeyStableId(1): 4,
        journeyStableId(2): 5,
      });
      expect(
        WordHuntJourneyProgress(
          catalog: PublishedJourneyCatalog(levelCount: 150),
          save: save,
        ).nextPlayableLevel(),
        3,
      );
      await press(tester, 'journey_map_continue');
      expect(map(tester).currentOrdinal, 3);
    },
  );
  testWidgets(
    'ineligible last viewed falls back; published end is not a game final',
    (tester) async {
      final repository = RecordingRepository(
        WordHuntJourneySaveV1(lastViewedLevelId: journeyStableId(15001)),
      );
      await boot(tester, repository, count: 1);
      await press(tester, 'journey_home_map');
      expect(
        find.byKey(const Key('word_hunt_journey_level_1')),
        findsOneWidget,
      );
      await complete(tester, 1, 1, 0);
      await press(tester, 'journey_map_continue');
      expect(
        find.text('Şimdilik tüm bölümleri tamamladın. Yeni bölümler yakında.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('word_hunt_journey_level_2')), findsNothing);
      await press(tester, 'journey_back');
      await press(tester, 'journey_home_continue');
      expect(find.byType(WordHuntInfiniteJourneyMapScreen), findsNothing);
      expect(
        find.text('Şimdilik tüm bölümleri tamamladın. Yeni bölümler yakında.'),
        findsOneWidget,
      );
      await press(tester, 'journey_home_map');
      expect(
        find.byKey(const Key('word_hunt_journey_level_1')),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'empty publication shows content unavailable, no map or future node',
    (tester) async {
      await boot(tester, RecordingRepository(), count: 0);
      await press(tester, 'journey_home_continue');
      expect(find.byType(WordHuntInfiniteJourneyMapScreen), findsNothing);
      expect(find.byKey(const Key('journey_feedback')), findsOneWidget);
      await press(tester, 'journey_home_map');
      expect(find.byType(WordHuntInfiniteJourneyMapScreen), findsNothing);
    },
  );
  testWidgets(
    'invalid bonus and failed save do not commit completion; retry succeeds',
    (tester) async {
      final repository = RecordingRepository();
      await boot(tester, repository);
      await press(tester, 'journey_home_continue');
      await press(tester, 'word_hunt_journey_level_1');
      for (final value in ['abc', '-1']) {
        await tester.enterText(
          find.byKey(const Key('journey_bonus_input')),
          value,
        );
        await press(tester, 'journey_finish');
        expect(find.text('Geçerli bir bonus sayısı gir.'), findsOneWidget);
        expect(
          (await repository.load())!.isCompleted(journeyStableId(1)),
          isFalse,
        );
      }
      await tester.enterText(find.byKey(const Key('journey_bonus_input')), '2');
      repository.failSave = true;
      await press(tester, 'journey_finish');
      expect(find.byType(WordHuntJourneySyntheticLevelScreen), findsOneWidget);
      expect(
        find.text('Kayıt yapılamadı. Tekrar dene.').hitTestable(),
        findsOneWidget,
      );
      expect(
        (await repository.load())!.isCompleted(journeyStableId(1)),
        isFalse,
      );
      repository.failSave = false;
      await press(tester, 'journey_finish');
      expect(
        (await repository.load())!.bestBonusByStableId[journeyStableId(1)],
        2,
      );
      expect(map(tester).currentOrdinal, 2);
    },
  );
  for (final config in [
    (150, const Size(360, 800)),
    (1500, const Size(412, 915)),
    (15000, const Size(768, 1024)),
  ]) {
    testWidgets('${config.$1} shell flow stays bounded at ${config.$2}', (
      tester,
    ) async {
      tester.view.physicalSize = config.$2;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final handle = tester.ensureSemantics();
      try {
        final repository = RecordingRepository(prefix(config.$1, last: 1));
        await boot(tester, repository, count: config.$1);
        await press(tester, 'journey_home_map');
        await jump(tester, '${config.$1}');
        final finder = find.byKey(Key('word_hunt_journey_level_${config.$1}'));
        expect(finder, findsOneWidget);
        expect(tester.getSize(finder), const Size(68, 68));
        expect(countSemantics(tester), lessThan(60));
        expect(
          find.byWidgetPredicate((_) => true).evaluate().length,
          lessThan(800),
        );
        final nodes = find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith(
                'word_hunt_journey_level_',
              ),
        );
        expect(nodes.evaluate().length, lessThanOrEqualTo(13));
        await complete(tester, config.$1, 3, 1);
        expect(
          (await repository.load())!.bestStarsByStableId[journeyStableId(
            config.$1,
          )],
          3,
        );
        expect(
          find.byKey(Key('word_hunt_journey_level_${config.$1}')),
          findsOneWidget,
        );
        expect(countSemantics(tester), lessThan(60));
        debugPrint(
          'shell ${config.$1} ${config.$2}: nodes=${nodes.evaluate().length}, semantics=${countSemantics(tester)}',
        );
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    });
  }
}
