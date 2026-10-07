import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_domain/word_hunt_experience_mode.dart';
import 'package:flutter/material.dart';
import 'package:kelime_avi_standalone/main.dart';
import 'package:kelime_avi_standalone/word_hunt_device_test_panel.dart';
import 'package:kelime_avi_standalone/word_hunt_standalone_progress_store.dart';
import 'package:word_hunt_domain/word_hunt_progress.dart';
import 'package:word_hunt_domain/word_hunt_progress_codec.dart';
import 'package:word_hunt_flutter_feature/word_hunt_route_catalog.dart';

class _Preferences implements WordHuntStandalonePreferences {
  final strings = <String, String>{'unrelated': 'keep'};
  final bools = <String, bool>{'unrelated': true};
  @override
  Future<String?> getString(String key) async => strings[key];
  @override
  Future<void> setString(String key, String value) async {
    strings[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async => bools[key];
  @override
  Future<void> setBool(String key, bool value) async {
    bools[key] = value;
  }
}

void main() {
  test(
    'Harbor presets preserve other-route progress and existing metadata',
    () async {
      final preferences = _Preferences();
      final seeder = WordHuntDeviceTestSeeder(
        WordHuntStandaloneProgressStore(preferences: preferences),
      );
      const identity = WordHuntStandaloneProgressStorageIdentity();
      final other = WordHuntRouteCatalog.entries[1].route;
      final otherLevel = other.levels.first.id;
      final original = WordHuntProgressSnapshot(
        bestStarsByLevelId: {otherLevel: 2, 'baslangic-20': 3},
        bestBonusFoundCountByLevelId: {otherLevel: 1, 'baslangic-20': 1},
        unlockedInfoCardIds: {'existing-card'},
        unlockedRouteRewardIds: {'existing-reward'},
        grandfatheredUnlockedRouteIds: {other.id},
        lastActiveRouteId: other.id,
      );
      await seeder.store.setString(
        identity.progressStorageKeyForUid(null),
        WordHuntProgressCodec.encode(original, ownerScope: 'guest'),
      );
      for (final completed in [19, 0]) {
        await seeder.prepare(completed: completed);
        final result = await seeder.load();
        expect(result.starsFor(otherLevel), 2);
        expect(result.bestBonusFoundCountByLevelId, {otherLevel: 1});
        expect(result.starsFor('baslangic-20'), 0);
        expect(result.unlockedInfoCardIds, original.unlockedInfoCardIds);
        expect(result.unlockedRouteRewardIds, original.unlockedRouteRewardIds);
        expect(
          result.grandfatheredUnlockedRouteIds,
          original.grandfatheredUnlockedRouteIds,
        );
        expect(result.lastActiveRouteId, original.lastActiveRouteId);
        expect(preferences.strings['unrelated'], 'keep');
      }
    },
  );

  test(
    'schema-3 presets use real standalone storage and sequential unlock',
    () async {
      final preferences = _Preferences();
      final seeder = WordHuntDeviceTestSeeder(
        WordHuntStandaloneProgressStore(preferences: preferences),
      );
      const identity = WordHuntStandaloneProgressStorageIdentity();
      expect(WordHuntProgressCodec.schemaVersion, 3);
      expect(
        identity.progressStorageKeyForUid(null),
        'kelime_avi_standalone_progress_v1_guest',
      );
      final route = WordHuntDeviceTestSeeder.route;
      for (final level in [11, 21, 30, ...List.generate(30, (i) => i + 1)]) {
        await seeder.prepareLevel(level);
        final progress = await seeder.load();
        expect(progress.bestStarsByLevelId.length, level - 1);
        expect(progress.starsFor(route.levels[level - 1].id), 0);
        expect(
          WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, level),
          isTrue,
        );
        expect(
          WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress),
          level,
        );
        if (level < 30) {
          expect(
            WordHuntRouteProgressEngine.isLevelUnlocked(
              route,
              progress,
              level + 1,
            ),
            isFalse,
          );
        }
        expect(progress.unlockedRouteRewardIds, isEmpty);
      }
      for (final preset in [
        (30, 59, false),
        (30, 60, true),
        (20, 60, false),
        (30, 90, true),
      ]) {
        final total = preset.$2;
        await seeder.preparePilotBoundary(completed: preset.$1, stars: total);
        final progress = await seeder.load();
        expect(WordHuntRouteProgressEngine.totalStars(route, progress), total);
        expect(progress.bestStarsByLevelId.length, preset.$1);
        expect(
          progress.bestStarsByLevelId.values.every((v) => v >= 1 && v <= 3),
          isTrue,
        );
        expect(
          WordHuntRouteProgressEngine.isRouteComplete(route, progress),
          isFalse,
        );
        expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), preset.$3);
        expect(
          progress.grandfatheredUnlockedRouteIds.contains('gokyuzu-adalari'),
          preset.$3,
        );
        expect(
          WordHuntProgressCodec.decode(
            preferences.strings[identity.progressStorageKeyForUid(null)]!,
            expectedOwnerScope: 'guest',
          ).grandfatheredUnlockedRouteIds,
          progress.grandfatheredUnlockedRouteIds,
        );
      }
      // Locked presets remain reproducible even after an unlocked preset.
      await seeder.preparePilotBoundary(completed: 30, stars: 59);
      expect(
        WordHuntRouteCatalog.gokyuzu.isUnlocked(await seeder.load()),
        isFalse,
      );
      await seeder.prepare(completed: 30);
      expect((await seeder.load()).bestStarsByLevelId, {
        for (final l in route.levels.take(30)) l.id: 3,
      });
      await seeder.prepareLevel(20);
      final completed = (await seeder.load()).recordLevelResult(
        levelId: route.levels[19].id,
        stars: 3,
      );
      await seeder.store.setString(
        identity.progressStorageKeyForUid(null),
        WordHuntProgressCodec.encode(completed, ownerScope: 'guest'),
      );
      expect((await seeder.load()).starsFor(route.levels[19].id), 3);
      await seeder.prepare();
      expect((await seeder.load()).bestStarsByLevelId, isEmpty);
      expect(preferences.strings['unrelated'], 'keep');
      expect(preferences.bools, {'unrelated': true});
      expect(preferences.strings.keys.toSet(), {
        'unrelated',
        identity.progressStorageKeyForUid(null),
      });
      expect(() => seeder.prepareLevel(31), throwsRangeError);
    },
  );

  testWidgets('five hidden taps, TEST MODE, confirmation and feedback', (
    tester,
  ) async {
    final preferences = _Preferences();
    await tester.pumpWidget(
      KelimeAviStandaloneApp(
        experienceMode: WordHuntExperienceMode.legacy,
        progressStore: WordHuntStandaloneProgressStore(
          preferences: preferences,
        ),
      ),
    );
    expect(find.textContaining('TEST MODE'), findsNothing);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const Key('kelime_avi_version')));
    }
    await tester.pump();
    expect(find.byType(WordHuntDeviceTestPanel), findsNothing);
    await tester.tap(find.byKey(const Key('kelime_avi_version')));
    await tester.pumpAndSettle();
    expect(find.text('Device Test Panel — TEST MODE'), findsOneWidget);
    await tester.tap(find.text('L11 hazırla'));
    await tester.pumpAndSettle();
    expect(preferences.strings.keys, ['unrelated']);
    await tester.tap(find.text('Uygula'));
    await tester.pumpAndSettle();
    expect(find.textContaining('10/30 tamamlandı'), findsWidgets);
    expect(find.textContaining('L11 hazırla hazırlandı.'), findsOneWidget);
  });
}
