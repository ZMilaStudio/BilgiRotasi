import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gunes_imparatorlugu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kayip_sehir_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_rewards.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_yeralti_kralligi_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final starter = WordHuntStarterContent.baslangicLimani;
  final sky = WordHuntGokyuzuContent.gokyuzuAdalari;
  final forest = WordHuntOrmanContent.ormanYolu;
  final ancient = WordHuntOrman2Content.orman2;
  final crystal = WordHuntKristalContent.kristalVadisi;
  final lostCity = WordHuntKayipSehirContent.kayipSehir;
  final underground = WordHuntYeraltiKralligiContent.yeraltiKralligi;
  final sun = WordHuntGunesImparatorluguContent.gunesImparatorlugu;

  WordHuntProgressSnapshot seventeenStarsWithFinal(List<String> levelIds) {
    return WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (final id in levelIds.take(5)) id: 3,
        levelIds[5]: 1,
        levelIds.last: 1,
      },
    );
  }

  WordHuntProgressSnapshot sixteenStarsWithoutFinal(List<String> levelIds) {
    return WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (final id in levelIds.take(5)) id: 3,
        levelIds[5]: 1,
      },
    );
  }

  WordHuntProgressSnapshot completedRouteProgress(
    WordHuntProgressSnapshot progress,
    List<String> levelIds, {
    required int requiredStars,
  }) {
    var next = progress;
    if (requiredStars > 0) {
      for (final id in levelIds.take(6)) {
        next = next.recordLevelResult(levelId: id, stars: 3);
      }
    }
    return next.recordLevelResult(levelId: levelIds.last, stars: 1);
  }

  group('route reward identity and metadata', () {
    test('production routeRewardId values stay exact and unique', () {
      expect(starter.routeRewardId, 'badge-kelime-yolcusu');
      expect(sky.routeRewardId, 'badge-gokyuzu-kasifi');
      expect(forest.routeRewardId, 'badge-orman-kasifi');
      expect(ancient.routeRewardId, 'badge-kadim-orman-kasifi');
      expect(crystal.routeRewardId, 'badge-kristal-kasifi');
      expect(lostCity.routeRewardId, 'badge-kayip-sehir-kasifi');
      expect(underground.routeRewardId, 'badge-yeralti-kasifi');
      expect(sun.routeRewardId, 'badge-gunes-kasifi');

      final ids = WordHuntRouteCatalog.entries
          .map((entry) => entry.route.routeRewardId)
          .toSet();
      expect(ids, hasLength(WordHuntRouteCatalog.entries.length));
    });

    test('every production reward id has exact display metadata', () {
      expect(
        WordHuntRouteRewardCatalog.forRoute(starter)?.displayName,
        'Kelime Yolcusu',
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(sky)?.displayName,
        'Gökyüzü Kaşifi',
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(forest)?.displayName,
        'Orman Kaşifi',
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(ancient)?.displayName,
        'Kadim Orman Kaşifi',
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(crystal)?.displayName,
        'Kristal Kaşifi',
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(lostCity)?.displayName,
        'Kayıp Şehir Kaşifi',
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(lostCity)?.icon,
        Icons.account_balance_rounded,
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(underground)?.displayName,
        'Yeraltı Kaşifi',
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(underground)?.icon,
        Icons.vpn_key_rounded,
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(sun)?.displayName,
        'Güneş Kaşifi',
      );
      expect(
        WordHuntRouteRewardCatalog.forRoute(sun)?.icon,
        Icons.wb_sunny_rounded,
      );
      expect(WordHuntRouteRewardCatalog.rewards, hasLength(8));

      for (final entry in WordHuntRouteCatalog.entries) {
        expect(
          WordHuntRouteRewardCatalog.forRoute(entry.route),
          isNotNull,
          reason: '${entry.route.id} reward metadata eksik olmamalı.',
        );
      }
    });
  });

  group('progress reward ownership', () {
    test('default reward set is empty', () {
      expect(const WordHuntProgressSnapshot().unlockedRouteRewardIds, isEmpty);
    });

    test('grant preserves stars and info cards and is idempotent', () {
      const original = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{'baslangic-1': 3},
        unlockedInfoCardIds: <String>{'kart-1'},
      );

      final granted = original.grantRouteReward('badge-kelime-yolcusu');
      expect(granted.starsFor('baslangic-1'), 3);
      expect(granted.unlockedInfoCardIds, <String>{'kart-1'});
      expect(granted.unlockedRouteRewardIds, <String>{'badge-kelime-yolcusu'});

      final duplicate = granted.grantRouteReward('badge-kelime-yolcusu');
      expect(identical(duplicate, granted), isTrue);
      expect(duplicate.unlockedRouteRewardIds, hasLength(1));
    });

    test('empty reward id is rejected', () {
      expect(
        () => const WordHuntProgressSnapshot().grantRouteReward('   '),
        throwsArgumentError,
      );
    });

    test('recordLevelResult never drops earned rewards', () {
      final earned = const WordHuntProgressSnapshot().grantRouteReward(
        'badge-kelime-yolcusu',
      );
      final updated = earned.recordLevelResult(
        levelId: 'baslangic-1',
        stars: 2,
        unlockedInfoCards: const <String>['kart-1'],
      );

      expect(updated.starsFor('baslangic-1'), 2);
      expect(updated.unlockedInfoCardIds, contains('kart-1'));
      expect(updated.unlockedRouteRewardIds, contains('badge-kelime-yolcusu'));
    });
  });

  group('live false-to-true route completion grant', () {
    test('Orman final completion grants badge and route milestone', () {
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: forest,
        progress: const WordHuntProgressSnapshot(),
        levelId: forest.levels.last.id,
        stars: 1,
      );

      expect(transition.beforeRouteComplete, isFalse);
      expect(transition.afterRouteComplete, isTrue);
      expect(transition.routeCompletedNow, isTrue);
      expect(transition.rewardGranted, isTrue);
      expect(
        transition.progress.unlockedRouteRewardIds,
        contains('badge-orman-kasifi'),
      );
    });

    test(
      'Kadim final completion grants badge and exposes Kristal as next route',
      () {
        final transition = WordHuntRouteRewardEngine.recordLevelResult(
          route: ancient,
          progress: const WordHuntProgressSnapshot(),
          levelId: ancient.levels.last.id,
          stars: 1,
        );

        expect(transition.routeCompletedNow, isTrue);
        expect(transition.rewardGranted, isTrue);
        expect(
          transition.progress.unlockedRouteRewardIds,
          contains('badge-kadim-orman-kasifi'),
        );
        expect(
          WordHuntRouteRewardEngine.nextCatalogEntry(ancient)?.route.id,
          'kristal-vadisi',
        );
      },
    );

    test('Kristal completion grants badge and exposes Kayıp as next route', () {
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: crystal,
        progress: const WordHuntProgressSnapshot(),
        levelId: crystal.levels.last.id,
        stars: 1,
      );
      expect(transition.routeCompletedNow, isTrue);
      expect(transition.rewardGranted, isTrue);
      expect(
        transition.progress.unlockedRouteRewardIds,
        contains('badge-kristal-kasifi'),
      );
      expect(
        WordHuntRouteRewardEngine.nextCatalogEntry(crystal)?.route.id,
        'kayip-sehir',
      );
    });

    test('trilogy route completion grants each reward exactly once', () {
      for (final route in <dynamic>[lostCity, underground, sun]) {
        final first = WordHuntRouteRewardEngine.recordLevelResult(
          route: route,
          progress: const WordHuntProgressSnapshot(),
          levelId: route.levels.last.id,
          stars: 1,
        );
        expect(first.routeCompletedNow, isTrue, reason: route.id);
        expect(first.rewardGranted, isTrue, reason: route.id);
        expect(
          first.progress.unlockedRouteRewardIds,
          contains(route.routeRewardId),
          reason: route.id,
        );

        final replay = WordHuntRouteRewardEngine.recordLevelResult(
          route: route,
          progress: first.progress,
          levelId: route.levels.last.id,
          stars: 1,
        );
        expect(replay.routeCompletedNow, isFalse, reason: route.id);
        expect(replay.rewardGranted, isFalse, reason: route.id);
        expect(
          replay.progress.unlockedRouteRewardIds
              .where((id) => id == route.routeRewardId),
          hasLength(1),
          reason: route.id,
        );
      }
    });

    test('Starter final at 17 stars grants no reward', () {
      final ids = starter.levels.map((level) => level.id).toList();
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: starter,
        progress: sixteenStarsWithoutFinal(ids),
        levelId: ids.last,
        stars: 1,
      );

      expect(
        WordHuntRouteProgressEngine.totalStars(starter, transition.progress),
        17,
      );
      expect(transition.afterRouteComplete, isFalse);
      expect(transition.routeCompletedNow, isFalse);
      expect(transition.rewardGranted, isFalse);
      expect(transition.progress.unlockedRouteRewardIds, isEmpty);
    });

    test(
      'Starter later non-final replay to 18 grants reward and unlocks Sky',
      () {
        final ids = starter.levels.map((level) => level.id).toList();
        final before = seventeenStarsWithFinal(ids);
        expect(
          WordHuntRouteProgressEngine.isRouteComplete(starter, before),
          isFalse,
        );

        final transition = WordHuntRouteRewardEngine.recordLevelResult(
          route: starter,
          progress: before,
          levelId: ids[5],
          stars: 2,
        );

        expect(
          WordHuntRouteProgressEngine.totalStars(starter, transition.progress),
          18,
        );
        expect(transition.routeCompletedNow, isTrue);
        expect(transition.rewardGranted, isTrue);
        expect(
          transition.progress.unlockedRouteRewardIds,
          contains('badge-kelime-yolcusu'),
        );
        expect(
          WordHuntRouteCatalog.gokyuzu.isUnlocked(transition.progress),
          isTrue,
        );
        expect(
          WordHuntRouteRewardEngine.nextCatalogEntry(starter)?.route.title,
          'Gökyüzü Adaları',
        );
      },
    );

    test(
      'Sky later non-final replay to 18 grants reward and unlocks Forest',
      () {
        final ids = sky.levels.map((level) => level.id).toList();
        var before = seventeenStarsWithFinal(ids);
        before = completedRouteProgress(
          before,
          starter.levels.map((level) => level.id).toList(),
          requiredStars: starter.unlockStarsRequired,
        );
        expect(
          WordHuntRouteProgressEngine.isRouteComplete(sky, before),
          isFalse,
        );

        final transition = WordHuntRouteRewardEngine.recordLevelResult(
          route: sky,
          progress: before,
          levelId: ids[5],
          stars: 2,
        );

        expect(transition.routeCompletedNow, isTrue);
        expect(transition.rewardGranted, isTrue);
        expect(
          transition.progress.unlockedRouteRewardIds,
          contains('badge-gokyuzu-kasifi'),
        );
        expect(
          WordHuntRouteCatalog.orman.isUnlocked(transition.progress),
          isTrue,
        );
        expect(
          WordHuntRouteRewardEngine.nextCatalogEntry(sky)?.route.title,
          'Orman Yolu',
        );
      },
    );

    test(
      'already complete earned replay does not reveal or duplicate reward',
      () {
        final ids = forest.levels.map((level) => level.id).toList();
        final before = const WordHuntProgressSnapshot(
          bestStarsByLevelId: <String, int>{'orman-yolu-10': 1},
          unlockedRouteRewardIds: <String>{'badge-orman-kasifi'},
        );
        expect(
          WordHuntRouteProgressEngine.isRouteComplete(forest, before),
          isTrue,
        );

        final transition = WordHuntRouteRewardEngine.recordLevelResult(
          route: forest,
          progress: before,
          levelId: ids.first,
          stars: 2,
        );

        expect(transition.beforeRouteComplete, isTrue);
        expect(transition.afterRouteComplete, isTrue);
        expect(transition.routeCompletedNow, isFalse);
        expect(transition.rewardGranted, isFalse);
        expect(transition.progress.unlockedRouteRewardIds, hasLength(1));
      },
    );
  });

  group('legacy reward backfill', () {
    test('starter historical completion backfills only starter badge', () {
      final loaded = completedRouteProgress(
        const WordHuntProgressSnapshot(),
        starter.levels.map((level) => level.id).toList(),
        requiredStars: starter.unlockStarsRequired,
      );

      final backfilled = WordHuntRouteRewardEngine.backfillCompletedRoutes(
        loaded,
      );
      expect(backfilled.unlockedRouteRewardIds, <String>{
        'badge-kelime-yolcusu',
      });
      expect(
        WordHuntRouteProgressEngine.totalStars(starter, backfilled),
        WordHuntRouteProgressEngine.totalStars(starter, loaded),
      );
      expect(backfilled.unlockedInfoCardIds, loaded.unlockedInfoCardIds);
    });

    test('historical completed trilogy progress backfills new badges idempotently', () {
      var loaded = const WordHuntProgressSnapshot();
      for (final route in <dynamic>[lostCity, underground, sun]) {
        loaded = loaded.recordLevelResult(
          levelId: route.levels.last.id,
          stars: 1,
        );
      }

      final backfilled = WordHuntRouteRewardEngine.backfillCompletedRoutes(
        loaded,
      );
      expect(backfilled.unlockedRouteRewardIds, containsAll(<String>[
        'badge-kayip-sehir-kasifi',
        'badge-yeralti-kasifi',
        'badge-gunes-kasifi',
      ]));

      final second = WordHuntRouteRewardEngine.backfillCompletedRoutes(
        backfilled,
      );
      expect(identical(second, backfilled), isTrue);
    });

    test('all historical completions backfill five normalized badges', () {
      var loaded = const WordHuntProgressSnapshot();
      loaded = completedRouteProgress(
        loaded,
        starter.levels.map((level) => level.id).toList(),
        requiredStars: starter.unlockStarsRequired,
      );
      loaded = completedRouteProgress(
        loaded,
        sky.levels.map((level) => level.id).toList(),
        requiredStars: sky.unlockStarsRequired,
      );
      loaded = completedRouteProgress(
        loaded,
        forest.levels.map((level) => level.id).toList(),
        requiredStars: forest.unlockStarsRequired,
      );
      loaded = completedRouteProgress(
        loaded,
        ancient.levels.map((level) => level.id).toList(),
        requiredStars: ancient.unlockStarsRequired,
      );
      loaded = completedRouteProgress(
        loaded,
        crystal.levels.map((level) => level.id).toList(),
        requiredStars: crystal.unlockStarsRequired,
      );

      final backfilled = WordHuntRouteRewardEngine.backfillCompletedRoutes(
        loaded,
      );
      expect(backfilled.unlockedRouteRewardIds, <String>{
        'badge-kelime-yolcusu',
        'badge-gokyuzu-kasifi',
        'badge-orman-kasifi',
        'badge-kadim-orman-kasifi',
        'badge-kristal-kasifi',
      });

      final second = WordHuntRouteRewardEngine.backfillCompletedRoutes(
        backfilled,
      );
      expect(identical(second, backfilled), isTrue);
      expect(second.unlockedRouteRewardIds, hasLength(5));
    });
  });

  test('next route mapping follows production catalog order', () {
    expect(
      WordHuntRouteRewardEngine.nextCatalogEntry(starter)?.route.id,
      'gokyuzu-adalari',
    );
    expect(
      WordHuntRouteRewardEngine.nextCatalogEntry(sky)?.route.id,
      'orman-yolu',
    );
    expect(
      WordHuntRouteRewardEngine.nextCatalogEntry(forest)?.route.id,
      'orman-2',
    );
    expect(
      WordHuntRouteRewardEngine.nextCatalogEntry(ancient)?.route.id,
      'kristal-vadisi',
    );
    expect(
      WordHuntRouteRewardEngine.nextCatalogEntry(crystal)?.route.id,
      'kayip-sehir',
    );
    expect(
      WordHuntRouteRewardEngine.nextCatalogEntry(lostCity)?.route.id,
      'yeralti-kralligi',
    );
    expect(
      WordHuntRouteRewardEngine.nextCatalogEntry(underground)?.route.id,
      'gunes-imparatorlugu',
    );
    expect(WordHuntRouteRewardEngine.nextCatalogEntry(sun), isNull);
  });
}
