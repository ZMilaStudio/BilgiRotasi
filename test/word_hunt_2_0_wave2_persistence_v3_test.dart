import 'dart:convert';

import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_migration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_rewards.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wave 2 schema v3 codec', () {
    test('schemaVersion is 3 and v3 field set is additive', () {
      expect(WordHuntProgressCodec.schemaVersion, 3);

      const snapshot = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{'baslangic-1': 3},
        unlockedInfoCardIds: <String>{'kart-1'},
        unlockedRouteRewardIds: <String>{'badge-kelime-yolcusu'},
        bestBonusFoundCountByLevelId: <String, int>{'baslangic-1': 0},
        grandfatheredUnlockedRouteIds: <String>{'baslangic-limani'},
        lastActiveRouteId: 'baslangic-limani',
      );

      final raw = WordHuntProgressCodec.encode(
        snapshot,
        ownerScope: 'user_wave2',
      );
      final payload = jsonDecode(raw) as Map<String, dynamic>;

      expect(payload['schema'], 3);
      expect(payload.keys.toSet(), <String>{
        'schema',
        'ownerScope',
        'bestStarsByLevelId',
        'unlockedInfoCardIds',
        'unlockedRouteRewardIds',
        'bestBonusFoundCountByLevelId',
        'grandfatheredUnlockedRouteIds',
        'lastActiveRouteId',
      });
    });

    test('schema 1 decode metadata migrates without stars/cards loss', () {
      const raw =
          '{"schema":1,"ownerScope":"guest",'
          '"bestStarsByLevelId":{"baslangic-1":3,"baslangic-10":1},'
          '"unlockedInfoCardIds":["kart-a","kart-b"]}';

      final decoded = WordHuntProgressCodec.decodeWithMetadata(
        raw,
        expectedOwnerScope: 'guest',
      );
      final migrated = WordHuntLegacyProgressMigration.migrate(decoded);

      expect(decoded.sourceSchemaVersion, 1);
      expect(decoded.requiresMigrationWriteback, isTrue);
      expect(migrated.starsFor('baslangic-1'), 3);
      expect(migrated.starsFor('baslangic-10'), 1);
      expect(migrated.unlockedInfoCardIds, <String>{'kart-a', 'kart-b'});
      expect(migrated.unlockedRouteRewardIds, isEmpty);
      expect(migrated.bestBonusFoundCountByLevelId, isEmpty);
    });

    test('schema 2 decode metadata migrates without existing field loss', () {
      const raw =
          '{"schema":2,"ownerScope":"user_a",'
          '"bestStarsByLevelId":{"baslangic-1":3},'
          '"unlockedInfoCardIds":["kart-a"],'
          '"unlockedRouteRewardIds":["badge-kelime-yolcusu"]}';

      final decoded = WordHuntProgressCodec.decodeWithMetadata(
        raw,
        expectedOwnerScope: 'user_a',
      );
      final migrated = WordHuntLegacyProgressMigration.migrate(decoded);

      expect(decoded.sourceSchemaVersion, 2);
      expect(decoded.requiresMigrationWriteback, isTrue);
      expect(migrated.bestStarsByLevelId, <String, int>{'baslangic-1': 3});
      expect(migrated.unlockedInfoCardIds, <String>{'kart-a'});
      expect(migrated.unlockedRouteRewardIds, <String>{'badge-kelime-yolcusu'});
      expect(migrated.bestBonusFoundCountByLevelId, isEmpty);
    });

    test('schema 3 roundtrip preserves every v3 field', () {
      const snapshot = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{'level-b': 1, 'level-a': 3},
        unlockedInfoCardIds: <String>{'card-b', 'card-a'},
        unlockedRouteRewardIds: <String>{'reward-b', 'reward-a'},
        bestBonusFoundCountByLevelId: <String, int>{'level-a': 0, 'level-b': 2},
        grandfatheredUnlockedRouteIds: <String>{'route-b', 'route-a'},
        lastActiveRouteId: 'route-b',
      );

      final raw = WordHuntProgressCodec.encode(
        snapshot,
        ownerScope: 'user_roundtrip',
      );
      final decoded = WordHuntProgressCodec.decodeWithMetadata(
        raw,
        expectedOwnerScope: 'user_roundtrip',
      );

      expect(decoded.sourceSchemaVersion, 3);
      expect(decoded.requiresMigrationWriteback, isFalse);
      expect(decoded.snapshot.bestStarsByLevelId, snapshot.bestStarsByLevelId);
      expect(
        decoded.snapshot.unlockedInfoCardIds,
        snapshot.unlockedInfoCardIds,
      );
      expect(
        decoded.snapshot.unlockedRouteRewardIds,
        snapshot.unlockedRouteRewardIds,
      );
      expect(
        decoded.snapshot.bestBonusFoundCountByLevelId,
        snapshot.bestBonusFoundCountByLevelId,
      );
      expect(
        decoded.snapshot.grandfatheredUnlockedRouteIds,
        snapshot.grandfatheredUnlockedRouteIds,
      );
      expect(decoded.snapshot.lastActiveRouteId, snapshot.lastActiveRouteId);

      final rawAgain = WordHuntProgressCodec.encode(
        decoded.snapshot,
        ownerScope: 'user_roundtrip',
      );
      expect(rawAgain, raw);
    });

    test('owner scope isolation stays fail-closed', () {
      final raw = WordHuntProgressCodec.encode(
        const WordHuntProgressSnapshot(),
        ownerScope: 'user_A',
      );

      expect(
        () => WordHuntProgressCodec.decode(raw, expectedOwnerScope: 'user_B'),
        throwsFormatException,
      );
      expect(
        () => WordHuntProgressCodec.decode(raw, expectedOwnerScope: 'guest'),
        throwsFormatException,
      );
    });

    test('historical v1 storage key identity stays unchanged', () {
      expect(
        WordHuntProgressCodec.storageKeyForUid(null),
        'bilgi_rotasi_word_hunt_progress_v1_guest',
      );
      expect(
        WordHuntProgressCodec.storageKeyForUid('  abc  '),
        'bilgi_rotasi_word_hunt_progress_v1_user_abc',
      );
      expect(
        WordHuntProgressCodec.storageKeyForUid('user-A'),
        'bilgi_rotasi_word_hunt_progress_v1_user_user-A',
      );
    });

    test('future schema remains rejected and corrupt JSON fails closed', () {
      const future =
          '{"schema":4,"ownerScope":"guest",'
          '"bestStarsByLevelId":{},"unlockedInfoCardIds":[],'
          '"unlockedRouteRewardIds":[],"bestBonusFoundCountByLevelId":{},'
          '"grandfatheredUnlockedRouteIds":[],"lastActiveRouteId":null}';

      expect(
        () => WordHuntProgressCodec.decode(future, expectedOwnerScope: 'guest'),
        throwsFormatException,
      );
      expect(
        () => WordHuntProgressCodec.decode(
          '{broken',
          expectedOwnerScope: 'guest',
        ),
        throwsFormatException,
      );
    });
  });

  group('Wave 2 bonus persistence', () {
    test('historical unknown bonus stays absent after schema2 migration', () {
      const raw =
          '{"schema":2,"ownerScope":"guest","bestStarsByLevelId":{},'
          '"unlockedInfoCardIds":[],"unlockedRouteRewardIds":[]}';

      final migrated = WordHuntLegacyProgressMigration.migrate(
        WordHuntProgressCodec.decodeWithMetadata(
          raw,
          expectedOwnerScope: 'guest',
        ),
      );

      expect(migrated.bestBonusFoundCountByLevelId, isEmpty);
      expect(migrated.bestBonusFoundCountFor('baslangic-1'), isNull);
    });

    test('known zero bonus remains explicit zero', () {
      final knownZero = const WordHuntProgressSnapshot().recordLevelResult(
        levelId: 'level-1',
        stars: 1,
        foundBonusCount: 0,
      );

      expect(knownZero.bestBonusFoundCountFor('level-1'), 0);

      final raw = WordHuntProgressCodec.encode(knownZero, ownerScope: 'guest');
      final restored = WordHuntProgressCodec.decode(
        raw,
        expectedOwnerScope: 'guest',
      );
      expect(restored.bestBonusFoundCountFor('level-1'), 0);
    });

    test('best bonus merge is monotonic and negative is rejected', () {
      var snapshot = const WordHuntProgressSnapshot().recordLevelResult(
        levelId: 'level-1',
        stars: 1,
        foundBonusCount: 2,
      );
      snapshot = snapshot.recordLevelResult(
        levelId: 'level-1',
        stars: 1,
        foundBonusCount: 1,
      );
      expect(snapshot.bestBonusFoundCountFor('level-1'), 2);

      snapshot = snapshot.recordLevelResult(
        levelId: 'level-1',
        stars: 1,
        foundBonusCount: 3,
      );
      expect(snapshot.bestBonusFoundCountFor('level-1'), 3);

      expect(
        () => snapshot.recordLevelResult(
          levelId: 'level-1',
          stars: 1,
          foundBonusCount: -1,
        ),
        throwsArgumentError,
      );
    });

    test('route-aware caller rejects bonus count above level maximum', () {
      final route = WordHuntLegacyProgressMigration.frozenLegacyRoutes.first;
      final level = route.levels.firstWhere(
        (candidate) => candidate.bonusWords.isNotEmpty,
      );

      expect(
        () => WordHuntRouteRewardEngine.recordLevelResult(
          route: route,
          progress: const WordHuntProgressSnapshot(),
          levelId: level.id,
          stars: 1,
          foundBonusCount: level.bonusWords.length + 1,
        ),
        throwsArgumentError,
      );
    });

    test('play result carries nullable persistence fact additively', () {
      const unknown = WordHuntLevelPlayResult(
        levelId: 'legacy',
        stars: 1,
        unlockedInfoCardIds: <String>{},
      );
      const knownZero = WordHuntLevelPlayResult(
        levelId: 'new',
        stars: 1,
        unlockedInfoCardIds: <String>{},
        foundBonusCount: 0,
      );

      expect(unknown.foundBonusCount, isNull);
      expect(knownZero.foundBonusCount, 0);
    });
  });

  group('Wave 2 frozen legacy access migration', () {
    test('empty legacy progress keeps starter historical access', () {
      const raw =
          '{"schema":1,"ownerScope":"guest","bestStarsByLevelId":{},'
          '"unlockedInfoCardIds":[]}';
      final migrated = WordHuntLegacyProgressMigration.migrate(
        WordHuntProgressCodec.decodeWithMetadata(
          raw,
          expectedOwnerScope: 'guest',
        ),
      );

      expect(migrated.grandfatheredUnlockedRouteIds, <String>{
        'baslangic-limani',
      });
      expect(migrated.lastActiveRouteId, isNull);
    });

    test('Starter legacy completion preserves Sky access', () {
      final starter = WordHuntLegacyProgressMigration.frozenLegacyRoutes[0];
      final legacy = WordHuntProgressSnapshot(
        bestStarsByLevelId: _completedStars(starter),
      );

      final access =
          WordHuntLegacyProgressMigration.deriveLegacyAccessEntitlements(
            legacy,
          );

      expect(
        access,
        containsAll(<String>['baslangic-limani', 'gokyuzu-adalari']),
      );
    });

    test('Sky legacy completion preserves Orman access', () {
      final sky = WordHuntLegacyProgressMigration.frozenLegacyRoutes[1];
      final legacy = WordHuntProgressSnapshot(
        bestStarsByLevelId: _completedStars(sky),
      );

      final access =
          WordHuntLegacyProgressMigration.deriveLegacyAccessEntitlements(
            legacy,
          );

      expect(
        access,
        containsAll(<String>[
          'baslangic-limani',
          'gokyuzu-adalari',
          'orman-yolu',
        ]),
      );
    });

    test('downstream persisted progress preserves monotonic route access', () {
      final lostCity = WordHuntLegacyProgressMigration.frozenLegacyRoutes[5];
      final legacy = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{lostCity.levels.first.id: 1},
      );

      final access =
          WordHuntLegacyProgressMigration.deriveLegacyAccessEntitlements(
            legacy,
          );

      expect(
        access.toList(),
        containsAll(<String>[
          'baslangic-limani',
          'gokyuzu-adalari',
          'orman-yolu',
          'orman-2',
          'kristal-vadisi',
          'kayip-sehir',
        ]),
      );
      expect(access, isNot(contains('yeralti-kralligi')));
    });

    test('access entitlement does not mark accessed route complete', () {
      final starter = WordHuntLegacyProgressMigration.frozenLegacyRoutes[0];
      final sky = WordHuntLegacyProgressMigration.frozenLegacyRoutes[1];
      final legacy = WordHuntProgressSnapshot(
        bestStarsByLevelId: _completedStars(starter),
      );
      final migrated = WordHuntProgressSnapshot(
        bestStarsByLevelId: legacy.bestStarsByLevelId,
        grandfatheredUnlockedRouteIds:
            WordHuntLegacyProgressMigration.deriveLegacyAccessEntitlements(
              legacy,
            ),
      );

      expect(
        migrated.grandfatheredUnlockedRouteIds,
        contains('gokyuzu-adalari'),
      );
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(sky, migrated),
        isFalse,
      );
    });

    test(
      'reward ownership stays separate from completion and access truth',
      () {
        final sky = WordHuntLegacyProgressMigration.frozenLegacyRoutes[1];
        const legacy = WordHuntProgressSnapshot(
          unlockedRouteRewardIds: <String>{'badge-gokyuzu-kasifi'},
        );

        expect(
          WordHuntRouteProgressEngine.isRouteComplete(sky, legacy),
          isFalse,
        );
        expect(
          WordHuntLegacyProgressMigration.deriveLegacyAccessEntitlements(
            legacy,
          ),
          <String>{'baslangic-limani'},
        );
        expect(legacy.unlockedRouteRewardIds, contains('badge-gokyuzu-kasifi'));
      },
    );

    test('last-active fallback uses furthest route with actual progress', () {
      final orman = WordHuntLegacyProgressMigration.frozenLegacyRoutes[2];
      final kristal = WordHuntLegacyProgressMigration.frozenLegacyRoutes[4];
      final legacy = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          orman.levels.first.id: 3,
          kristal.levels.first.id: 0,
        },
      );

      expect(
        WordHuntLegacyProgressMigration.deriveLastActiveRouteFallback(legacy),
        'kristal-vadisi',
      );
    });

    test('schema3 migration call is idempotent and non-destructive', () {
      const snapshot = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{'baslangic-1': 3},
        bestBonusFoundCountByLevelId: <String, int>{'baslangic-1': 1},
        grandfatheredUnlockedRouteIds: <String>{'baslangic-limani'},
        lastActiveRouteId: 'baslangic-limani',
      );
      final raw = WordHuntProgressCodec.encode(snapshot, ownerScope: 'guest');
      final decoded = WordHuntProgressCodec.decodeWithMetadata(
        raw,
        expectedOwnerScope: 'guest',
      );
      final migrated = WordHuntLegacyProgressMigration.migrate(decoded);

      expect(decoded.requiresMigrationWriteback, isFalse);
      expect(identical(migrated, decoded.snapshot), isTrue);
    });
  });

  group('Wave 2 snapshot preservation and scale', () {
    test('snapshot mutators preserve all v3 fields', () {
      const original = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{'level-1': 2},
        unlockedInfoCardIds: <String>{'card-1'},
        unlockedRouteRewardIds: <String>{'reward-1'},
        bestBonusFoundCountByLevelId: <String, int>{'level-1': 2},
        grandfatheredUnlockedRouteIds: <String>{'route-1'},
        lastActiveRouteId: 'route-1',
      );

      final recorded = original.recordLevelResult(
        levelId: 'level-2',
        stars: 3,
        unlockedInfoCards: const <String>['card-2'],
        foundBonusCount: 0,
      );
      final rewarded = recorded.grantRouteReward('reward-2');
      final accessed = rewarded.grantGrandfatheredRouteAccess('route-2');
      final active = accessed.markLastActiveRoute('route-2');

      expect(active.bestStarsByLevelId['level-1'], 2);
      expect(active.bestBonusFoundCountByLevelId['level-1'], 2);
      expect(active.bestBonusFoundCountByLevelId['level-2'], 0);
      expect(
        active.unlockedInfoCardIds,
        containsAll(<String>['card-1', 'card-2']),
      );
      expect(
        active.unlockedRouteRewardIds,
        containsAll(<String>['reward-1', 'reward-2']),
      );
      expect(
        active.grandfatheredUnlockedRouteIds,
        containsAll(<String>['route-1', 'route-2']),
      );
      expect(active.lastActiveRouteId, 'route-2');
    });

    test('800-level v3 roundtrip has no semantic data loss', () {
      final stars = <String, int>{};
      final bonus = <String, int>{};
      for (var route = 1; route <= 8; route++) {
        for (var level = 1; level <= 100; level++) {
          final id = 'route-$route-level-${level.toString().padLeft(3, '0')}';
          stars[id] = (route + level) % 4;
          if (level % 7 == 0) {
            bonus[id] = level % 3;
          }
        }
      }

      final snapshot = WordHuntProgressSnapshot(
        bestStarsByLevelId: stars,
        unlockedInfoCardIds: const <String>{'card-a', 'card-z'},
        unlockedRouteRewardIds: const <String>{'reward-a', 'reward-z'},
        bestBonusFoundCountByLevelId: bonus,
        grandfatheredUnlockedRouteIds: const <String>{
          'baslangic-limani',
          'gokyuzu-adalari',
          'orman-yolu',
        },
        lastActiveRouteId: 'orman-yolu',
      );

      final raw = WordHuntProgressCodec.encode(
        snapshot,
        ownerScope: 'user_800',
      );
      final restored = WordHuntProgressCodec.decode(
        raw,
        expectedOwnerScope: 'user_800',
      );

      expect(restored.bestStarsByLevelId, hasLength(800));
      expect(restored.bestStarsByLevelId, snapshot.bestStarsByLevelId);
      expect(
        restored.bestBonusFoundCountByLevelId,
        snapshot.bestBonusFoundCountByLevelId,
      );
      expect(restored.unlockedInfoCardIds, snapshot.unlockedInfoCardIds);
      expect(restored.unlockedRouteRewardIds, snapshot.unlockedRouteRewardIds);
      expect(
        restored.grandfatheredUnlockedRouteIds,
        snapshot.grandfatheredUnlockedRouteIds,
      );
      expect(restored.lastActiveRouteId, 'orman-yolu');
    });
  });
}

Map<String, int> _completedStars(dynamic route) {
  return <String, int>{for (final level in route.levels) level.id as String: 3};
}
