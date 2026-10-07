import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_production_journey_catalog.dart';
import 'package:word_hunt_content/word_hunt_journey_gameplay_resolver.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_experience_mode.dart';
import 'package:word_hunt_domain/word_hunt_journey_progress.dart';
import 'package:word_hunt_domain/word_hunt_journey_catalog_contract.dart';
import 'package:word_hunt_domain/word_hunt_progress_codec.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_entry_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_host.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_prototype_shell.dart';
import 'package:word_hunt_flutter_feature/word_hunt_screens.dart';
import '../apps/kelime_avi_standalone/lib/main.dart';
import '../apps/kelime_avi_standalone/lib/journey_owner_test_main.dart'
    as owner;
import '../apps/kelime_avi_standalone/lib/journey_owner_test_store.dart'
    as owner;
import '../apps/kelime_avi_standalone/lib/word_hunt_production_journey_store.dart';
import '../apps/kelime_avi_standalone/lib/word_hunt_standalone_progress_store.dart';
import 'word_hunt_journey_owner_runtime_test.dart' as owner;
import 'word_hunt_journey_real_gameplay_flow_test.dart' as real;

class TrackedPreferences extends owner.OwnerPreferencesSpy {
  final reads = <String>[];
  @override
  Future<String?> read(String key) async {
    reads.add(key);
    return super.read(key);
  }
}

class LegacySpy implements WordHuntProgressStore {
  final values = <String, String>{};
  final reads = <String>[], writes = <String>[];
  @override
  Future<String?> getString(String key) async {
    reads.add(key);
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    writes.add(key);
    values[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async => null;
  @override
  Future<void> setBool(String key, bool value) async =>
      throw StateError('Unexpected bool write');
}

class MissingPayloadResolver extends JourneyGameplayResolver {
  @override
  bool hasGameplayContent(String stableId) => false;
}

void main() {
  final levels = WordHuntStarterContent.baslangicLimani.levels;
  test('single build-time parser defaults and fails safe to Journey', () {
    expect(configuredWordHuntExperience, WordHuntExperienceMode.journey);
    for (final value in ['', 'journey', 'unknown', 'JOURNEY']) {
      expect(parseWordHuntExperience(value), WordHuntExperienceMode.journey);
    }
    expect(parseWordHuntExperience('legacy'), WordHuntExperienceMode.legacy);
  });
  test(
    'production catalog publishes only contiguous resolvable canonical content',
    () {
      final catalog = ProductionJourneyCatalogFactory.create();
      final resolver = JourneyGameplayResolver();
      expect(catalog.publishedLevelCount, levels.length);
      final ids = <String>{};
      for (final level in levels) {
        final record = catalog.recordForOrdinal(level.index)!;
        expect(ids.add(record.stableId), isTrue);
        expect(record.stableId, journeyStableId(level.index));
        expect(record.gameplayContentId, level.id);
        expect(resolver.resolve(record), same(level));
      }
      for (final n in [1, 10, 20, 31, 40]) {
        expect(
          resolver.resolve(catalog.recordForOrdinal(n)!),
          same(levels[n - 1]),
        );
      }
      expect(catalog.recordForOrdinal(levels.length + 1), isNull);
      expect(
        () => ProductionJourneyCatalogFactory.create(levels: [levels[1]]),
        throwsStateError,
      );
      expect(
        () => ProductionJourneyCatalogFactory.create(
          levels: [levels.first, levels.first],
        ),
        throwsStateError,
      );
      expect(
        () => ProductionJourneyCatalogFactory.create(
          resolver: MissingPayloadResolver(),
        ),
        throwsStateError,
      );
    },
  );
  test(
    'production, owner and legacy namespaces remain isolated and reconstruct',
    () async {
      final prefs = TrackedPreferences();
      final ownerRepo = owner.JourneyOwnerTestRepository(preferences: prefs);
      final production = WordHuntProductionJourneyRepository(
        preferences: prefs,
      );
      await ownerRepo.save(owner.ownerPreset(40));
      expect(await production.load(), isNull);
      final progress = WordHuntJourneyProgress(
        catalog: ProductionJourneyCatalogFactory.create(),
      );
      progress.recordCompletion(journeyStableId(1), stars: 3, bonusFound: 1);
      progress.recordLastViewed(journeyStableId(1));
      await production.save(progress.snapshot);
      final restored =
          await WordHuntProductionJourneyRepository(preferences: prefs).load();
      expect(restored!.bestStarsByStableId[journeyStableId(1)], 3);
      expect(restored.bestBonusByStableId[journeyStableId(1)], 1);
      expect(restored.lastViewedLevelId, journeyStableId(1));
      expect(
        WordHuntJourneyProgress(
          catalog: ProductionJourneyCatalogFactory.create(),
          save: restored,
        ).nextPlayableLevel(),
        2,
      );
      expect((await ownerRepo.load())!.bestStarsByStableId.length, 39);
      expect(prefs.values['legacy_schema3'], 'keep');
      expect(
        prefs.reads.every(
          (key) =>
              key == owner.JourneyOwnerTestRepository.key ||
              key == WordHuntProductionJourneyRepository.key,
        ),
        isTrue,
      );
      await production.clear();
      expect((await ownerRepo.load())!.bestStarsByStableId.length, 39);
      prefs.values[WordHuntProductionJourneyRepository.key] = 'broken';
      expect(production.load, throwsFormatException);
    },
  );
  for (final entry in <(String, WordHuntExperienceMode?)>[
    ('no define', null),
    ('journey', parseWordHuntExperience('journey')),
    ('invalid', parseWordHuntExperience('invalid')),
    ('legacy rollback', parseWordHuntExperience('legacy')),
  ]) {
    testWidgets('production entry: ${entry.$1}', (tester) async {
      final legacy = LegacySpy();
      final prefs = TrackedPreferences();
      final repo = WordHuntProductionJourneyRepository(preferences: prefs);
      await tester.pumpWidget(
        KelimeAviStandaloneApp(
          key: UniqueKey(),
          progressStore: legacy,
          journeyRepository: repo,
          experienceMode: entry.$2,
        ),
      );
      await tester.pumpAndSettle();
      if (entry.$2 == WordHuntExperienceMode.legacy) {
        expect(find.byType(KelimeAviStandaloneHomeScreen), findsOneWidget);
        expect(find.byType(WordHuntJourneyPrototypeShell), findsNothing);
        expect(prefs.reads, isEmpty);
      } else {
        expect(find.text('Bölüm 1'), findsOneWidget);
        expect(find.byType(KelimeAviStandaloneHomeScreen), findsNothing);
        expect(find.byType(WordHuntFeatureEntryScreen), findsNothing);
        expect(legacy.reads, isEmpty);
        expect(legacy.writes, isEmpty);
        for (final key in ['journey_home_continue', 'journey_home_map']) {
          expect(find.byKey(Key(key)), findsOneWidget);
        }
        await owner.press(tester, 'journey_home_map');
        expect(find.byKey(const Key('journey_go_to')), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
    'production real completion writes Journey only; rollback and end restore',
    (tester) async {
      final legacy = LegacySpy();
      final prefs = TrackedPreferences();
      Future<void> boot([WordHuntExperienceMode? mode]) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          KelimeAviStandaloneApp(
            progressStore: legacy,
            experienceMode: mode,
            journeyRepository: WordHuntProductionJourneyRepository(
              preferences: prefs,
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await boot();
      await owner.press(tester, 'journey_home_continue');
      await owner.press(tester, 'word_hunt_journey_level_1');
      expect(find.byType(WordHuntLevelProductionScreen), findsOneWidget);
      expect(find.byType(WordHuntFeatureEntryScreen), findsNothing);
      await real.solve(tester, levels.first, bonus: true);
      expect(find.byType(WordHuntLevelProductionScreen), findsNothing);
      expect(
        find.byKey(const Key('word_hunt_journey_level_2')),
        findsOneWidget,
      );
      final saved =
          await WordHuntProductionJourneyRepository(preferences: prefs).load();
      expect(saved!.bestStarsByStableId[journeyStableId(1)], 3);
      expect(
        saved.bestBonusByStableId[journeyStableId(1)],
        levels.first.bonusWords.length,
      );
      expect(legacy.reads, isEmpty);
      expect(legacy.writes, isEmpty);
      expect(
        prefs.writes.every(
          (key) => key == WordHuntProductionJourneyRepository.key,
        ),
        isTrue,
      );
      final journeyRaw = prefs.values[WordHuntProductionJourneyRepository.key];
      await boot(WordHuntExperienceMode.legacy);
      final writesBeforeLegacy = prefs.writes.length;
      await owner.press(tester, 'kelime_avi_standalone_play_button');
      await owner.press(tester, 'word_hunt_home_continue');
      expect(find.byType(WordHuntLevelProductionScreen), findsOneWidget);
      await real.solve(tester, levels.first);
      // Legacy owns its completion dialog; returning delivers the real result.
      if (find.text('Haritaya Dön').evaluate().isNotEmpty) {
        await tester.tap(find.text('Haritaya Dön'));
        await tester.pumpAndSettle();
      }
      expect(legacy.writes, isNotEmpty);
      final legacyKey = const WordHuntStandaloneProgressStorageIdentity()
          .progressStorageKeyForUid(null);
      expect(
        WordHuntProgressCodec.decode(
          legacy.values[legacyKey]!,
          expectedOwnerScope: 'guest',
        ).bestStarsByLevelId[levels.first.id],
        3,
      );
      expect(
        legacy.writes.every(
          (key) =>
              key ==
              const WordHuntStandaloneProgressStorageIdentity()
                  .progressStorageKeyForUid(null),
        ),
        isTrue,
      );
      expect(prefs.writes.length, writesBeforeLegacy);
      expect(prefs.values[WordHuntProductionJourneyRepository.key], journeyRaw);
      final legacyRaw = Map.of(legacy.values);
      await boot();
      expect(find.text('Bölüm 2'), findsOneWidget);
      expect(legacy.values, legacyRaw);
      final progress = WordHuntJourneyProgress(
        catalog: ProductionJourneyCatalogFactory.create(),
        save: saved,
      );
      progress.recordCompletion(journeyStableId(1), stars: 1, bonusFound: 0);
      expect(progress.snapshot.bestStarsByStableId[journeyStableId(1)], 3);
      expect(
        progress.snapshot.bestBonusByStableId[journeyStableId(1)],
        levels.first.bonusWords.length,
      );
      await WordHuntProductionJourneyRepository(
        preferences: prefs,
      ).save(owner.ownerPreset(41));
      await boot();
      await owner.press(tester, 'journey_home_continue');
      expect(
        find.text('Şimdilik tüm bölümleri tamamladın. Yeni bölümler yakında.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}
