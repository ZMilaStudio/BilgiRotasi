import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_prototype_shell.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_screens.dart';
import '../apps/kelime_avi_standalone/lib/journey_owner_test_main.dart';
import '../apps/kelime_avi_standalone/lib/journey_owner_test_store.dart';
import 'support/word_hunt_canonical_paths.dart';

class OwnerPreferencesSpy implements JourneyOwnerPreferences {
  final values = <String, String>{'legacy_schema3': 'keep'};
  final writes = <String>[];
  final removals = <String>[];
  bool fail = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (fail) throw StateError('Disk failure');
    writes.add(key);
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    removals.add(key);
    values.remove(key);
  }
}

Future<void> press(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

void main() {
  test(
    'persistent adapter reconstructs, isolates keys, and rejects corruption',
    () async {
      final prefs = OwnerPreferencesSpy();
      final first = JourneyOwnerTestRepository(preferences: prefs);
      await first.save(ownerPreset(20));
      final restored =
          await JourneyOwnerTestRepository(preferences: prefs).load();
      expect(restored!.bestStarsByStableId.length, 19);
      expect(restored.lastViewedLevelId, journeyStableId(20));
      expect(prefs.writes, [JourneyOwnerTestRepository.key]);
      await first.clear();
      expect(prefs.removals, [JourneyOwnerTestRepository.key]);
      expect(prefs.values, {'legacy_schema3': 'keep'});
      prefs.values[JourneyOwnerTestRepository.key] = 'broken';
      expect(first.load, throwsFormatException);
    },
  );
  for (final frontier in [1, 10, 20, 31, 40, 41]) {
    test('preset $frontier creates genuine Save v1 completed states', () {
      final seed = ownerPreset(frontier);
      expect(seed.bestStarsByStableId.length, frontier - 1);
      expect(
        seed.bestStarsByStableId.values.every(
          (stars) => stars >= 1 && stars <= 3,
        ),
        isTrue,
      );
      expect(
        seed.bestStarsByStableId.containsKey(journeyStableId(frontier)),
        isFalse,
      );
    });
  }
  testWidgets(
    'bootstrap uses real shell, real gameplay and isolated persistent completion',
    (tester) async {
      final prefs = OwnerPreferencesSpy();
      final repo = JourneyOwnerTestRepository(preferences: prefs);
      await tester.pumpWidget(JourneyOwnerTestApp(repository: repo));
      await tester.pumpAndSettle();
      final shell = tester.widget<WordHuntJourneyPrototypeShell>(
        find.byType(WordHuntJourneyPrototypeShell),
      );
      expect(shell.syntheticProof, isFalse);
      expect(shell.catalog.publishedLevelCount, 40);
      await press(tester, 'journey_home_continue');
      await press(tester, 'word_hunt_journey_level_1');
      expect(find.byType(WordHuntLevelProductionScreen), findsOneWidget);
      final level = WordHuntStarterContent.baslangicLimani.levels.first;
      for (final word in [...level.bonusWords, ...level.targetWords]) {
        final path = canonicalPath(level, word);
        final gesture = await tester.startGesture(
          tester.getCenter(
            find.byKey(
              Key(
                'word_hunt_production_cell_${path.first.row}_${path.first.column}',
              ),
            ),
          ),
        );
        await gesture.moveTo(
          tester.getCenter(
            find.byKey(
              Key(
                'word_hunt_production_cell_${path.last.row}_${path.last.column}',
              ),
            ),
          ),
        );
        await gesture.up();
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect((await repo.load())!.bestStarsByStableId[journeyStableId(1)], 3);
      expect(
        (await repo.load())!.bestBonusByStableId[journeyStableId(1)],
        level.bonusWords.length,
      );
      expect(prefs.writes, [
        JourneyOwnerTestRepository.key,
        JourneyOwnerTestRepository.key,
      ]);
      expect(prefs.values['legacy_schema3'], 'keep');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        JourneyOwnerTestApp(
          repository: JourneyOwnerTestRepository(preferences: prefs),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bölüm 2'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('reset needs confirmation; presets replace only the test store', (
    tester,
  ) async {
    final prefs = OwnerPreferencesSpy();
    final repo = JourneyOwnerTestRepository(preferences: prefs);
    await repo.save(ownerPreset(40));
    await tester.pumpWidget(JourneyOwnerTestApp(repository: repo));
    await tester.pumpAndSettle();
    await press(tester, 'journey_test_tools');
    await tester.ensureVisible(find.byKey(const Key('journey_reset')));
    await press(tester, 'journey_reset');
    expect(prefs.removals, isEmpty);
    await press(tester, 'journey_test_confirm');
    expect(prefs.removals, [JourneyOwnerTestRepository.key]);
    expect(find.text('Bölüm 1'), findsOneWidget);
    expect(prefs.values['legacy_schema3'], 'keep');
    await press(tester, 'journey_test_tools');
    await tester.ensureVisible(find.byKey(const Key('journey_preset_41')));
    await press(tester, 'journey_preset_41');
    await press(tester, 'journey_test_confirm');
    await press(tester, 'journey_home_continue');
    expect(
      find.text('Şimdilik tüm bölümleri tamamladın. Yeni bölümler yakında.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('preview 15k has no launch callback and no save mutation', (
    tester,
  ) async {
    final prefs = OwnerPreferencesSpy();
    await tester.pumpWidget(
      JourneyOwnerTestApp(
        repository: JourneyOwnerTestRepository(preferences: prefs),
      ),
    );
    await tester.pumpAndSettle();
    await press(tester, 'journey_test_tools');
    await tester.ensureVisible(find.byKey(const Key('journey_preview')));
    await press(tester, 'journey_preview');
    final map = tester.widget<WordHuntInfiniteJourneyMapScreen>(
      find.byType(WordHuntInfiniteJourneyMapScreen),
    );
    expect(map.publishedLevelCount, 15000);
    expect(map.onLevelTap, isNull);
    map.controller!.jumpToLevel(15000);
    await tester.pumpAndSettle();
    await press(tester, 'journey_measure');
    expect(find.textContaining('Monteli chunk:'), findsOneWidget);
    expect(prefs.writes, isEmpty);
    expect(prefs.removals, isEmpty);
    expect(find.byType(WordHuntLevelProductionScreen), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(JourneyOwnerVisualPreview), findsNothing);
    await press(tester, 'journey_home_continue');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Bölüm 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'go-to dialog remains usable with keyboard inset and rejects locked/unpublished',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        JourneyOwnerTestApp(
          repository: JourneyOwnerTestRepository(
            preferences: OwnerPreferencesSpy(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await press(tester, 'journey_home_continue');
      await press(tester, 'journey_go_to');
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      for (final input in ['0', '2', '41']) {
        await tester.enterText(
          find.byKey(const Key('journey_ordinal_input')),
          input,
        );
        await press(tester, 'journey_jump_submit');
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
