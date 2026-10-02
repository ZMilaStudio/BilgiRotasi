import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_models.dart';
import 'package:word_hunt_domain/word_hunt_progress.dart';
import 'package:word_hunt_domain/word_hunt_progress_codec.dart';
import 'package:word_hunt_domain/word_hunt_segment_projection.dart';
import 'package:word_hunt_flutter_feature/word_hunt_completion_orchestration.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_entry_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_host.dart';
import 'package:word_hunt_flutter_feature/word_hunt_route_catalog.dart';
import 'package:word_hunt_flutter_feature/word_hunt_route_rewards.dart';
import 'package:word_hunt_flutter_feature/word_hunt_route_selector.dart';

final _starter = WordHuntStarterContent.baslangicLimani;

WordHuntProgressSnapshot _pilotProgress(int completed, int total) {
  assert(total >= completed && total <= completed * 3);
  var extra = total - completed;
  final stars = <String, int>{};
  for (final level in _starter.levels.take(completed)) {
    final add = extra.clamp(0, 2).toInt();
    stars[level.id] = 1 + add;
    extra -= add;
  }
  return WordHuntProgressSnapshot(bestStarsByLevelId: stars);
}

class _Store implements WordHuntProgressStore {
  String? raw;
  int writes = 0;
  @override
  Future<String?> getString(String key) async => raw;
  @override
  Future<void> setString(String key, String value) async {
    raw = value;
    writes++;
  }

  @override
  Future<bool?> getBool(String key) async => false;
  @override
  Future<void> setBool(String key, bool value) async {}
}

class _Identity implements WordHuntProgressStorageIdentity {
  const _Identity();
  @override
  String ownerScopeForUid(String? uid) => 'guest';
  @override
  String progressStorageKeyForUid(String? uid) => 'pilot_test_guest';
  @override
  String kristalRevealSeenKeyForUid(String? uid) => 'pilot_test_reveal';
}

void main() {
  test('full 100-level semantics keep L100 as the only true route final', () {
    final sample = _starter.levels.first;
    final route = WordHuntRouteDefinition(
      id: 'fixture-full100',
      title: 'Full100 fixture',
      theme: 'fixture',
      unlockStarsRequired: 0,
      routeRewardId: 'fixture-reward',
      plannedLevelCount: 100,
      levels: List.generate(
        100,
        (offset) => WordHuntLevelDefinition(
          id: 'fixture-${offset + 1}',
          routeId: 'fixture-full100',
          index: offset + 1,
          type:
              offset == 99
                  ? WordHuntLevelType.routeFinal
                  : WordHuntLevelType.normal,
          grid: sample.grid,
          targetWords: sample.targetWords,
          starRules: sample.starRules,
        ),
      ),
      segments: List.generate(
        10,
        (offset) => WordHuntSegmentDefinition(
          id: 'fixture-segment-${offset + 1}',
          index: offset + 1,
          displayName: 'Segment ${offset + 1}',
          startLevelIndex: offset * 10 + 1,
          endLevelIndex: offset * 10 + 10,
        ),
      ),
    );
    expect(WordHuntSegmentProjection.isCompleteV2Route(route), isTrue);
    expect(
      WordHuntSegmentProjection.forLevel(route, 30).isTrueRouteFinal,
      isFalse,
    );
    expect(
      WordHuntSegmentProjection.forLevel(route, 100).isTrueRouteFinal,
      isTrue,
    );
    final before = WordHuntProgressSnapshot(
      bestStarsByLevelId: {
        for (final level in route.levels.take(99)) level.id: 1,
      },
    );
    expect(WordHuntRouteProgressEngine.isRouteComplete(route, before), isFalse);
    expect(
      WordHuntRouteProgressEngine.isRouteComplete(
        route,
        before.recordLevelResult(levelId: route.levels.last.id, stars: 1),
      ),
      isTrue,
    );
  });

  for (final boundary in [
    (0, 0, false),
    (20, 60, false),
    (30, 59, false),
    (30, 60, true),
    (30, 90, true),
  ]) {
    test('pilot30_v1 ${boundary.$1} completed / ${boundary.$2} stars', () {
      final progress = _pilotProgress(boundary.$1, boundary.$2);
      final rule = WordHuntRouteCatalog.gokyuzu.unlockRule;
      expect(rule.requiredCompletedLevels, 30);
      expect(rule.requiredStars, 60);
      expect(rule.currentCompletedLevels(progress), boundary.$1);
      expect(rule.currentStars(progress), boundary.$2);
      expect(rule.isUnlocked(progress), boundary.$3);
      final granted = WordHuntRouteCatalog.grantEligiblePilotAccess(progress);
      expect(
        granted.grandfatheredUnlockedRouteIds.contains('gokyuzu-adalari'),
        boundary.$3,
      );
      expect(granted.bestStarsByLevelId, progress.bestStarsByLevelId);
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(_starter, granted),
        isFalse,
      );
      expect(granted.unlockedRouteRewardIds, isEmpty);
      expect(WordHuntRouteCatalog.orman.isUnlocked(granted), isFalse);
    });
  }

  test('missing L30 cannot be substituted by foreign or future stars', () {
    final progress = _pilotProgress(29, 60);
    final polluted = WordHuntProgressSnapshot(
      bestStarsByLevelId: {
        ...progress.bestStarsByLevelId,
        'baslangic-31': 3,
        'gokyuzu-1': 3,
      },
    );
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(polluted), isFalse);
  });

  test('future L31+ remains outside the bounded pilot rule', () {
    final sample = _starter.levels.first;
    final future = WordHuntLevelDefinition(
      id: 'future-41',
      routeId: _starter.id,
      index: 41,
      type: WordHuntLevelType.normal,
      grid: sample.grid,
      targetWords: sample.targetWords,
      starRules: sample.starRules,
    );
    final expanded = WordHuntRouteDefinition(
      id: _starter.id,
      title: _starter.title,
      theme: _starter.theme,
      unlockStarsRequired: _starter.unlockStarsRequired,
      levels: [..._starter.levels, future],
      routeRewardId: _starter.routeRewardId,
      segments: _starter.segments,
      plannedLevelCount: 100,
    );
    final rule = WordHuntRouteUnlockRule.completedLevelsAndStars(
      prerequisiteRoute: expanded,
      requiredCompletedLevels: 30,
      requiredStars: 60,
    );
    final before = _pilotProgress(30, 59);
    final progress = before.recordLevelResult(levelId: future.id, stars: 3);
    expect(rule.currentStars(progress), 59);
    expect(rule.currentCompletedLevels(progress), 30);
    expect(rule.isUnlocked(progress), isFalse);
  });

  test(
    'replay 59 to 60 grants and persists through real completion orchestration',
    () async {
      final before = _pilotProgress(30, 59);
      final replay = _starter.levels.firstWhere(
        (l) => before.starsFor(l.id) == 2,
      );
      final store = _Store();
      WordHuntProgressSnapshot? shown;
      final processed = await WordHuntCompletionOrchestrator.process(
        route: _starter,
        beforeProgress: before,
        levelId: replay.id,
        stars: 3,
        unlockedInfoCards: const {},
        foundBonusCount: 0,
        routeInfoCards: WordHuntStarterContent.infoCards,
        onProgressReady: (p) => shown = p,
        persistProgress:
            (p) => store.setString(
              'pilot_test_guest',
              WordHuntProgressCodec.encode(p, ownerScope: 'guest'),
            ),
      );
      final saved = WordHuntProgressCodec.decode(
        store.raw!,
        expectedOwnerScope: 'guest',
      );
      expect(store.writes, 1);
      expect(shown?.grandfatheredUnlockedRouteIds, contains('gokyuzu-adalari'));
      expect(WordHuntRouteCatalog.gokyuzu.unlockRule.currentStars(saved), 60);
      expect(saved.grandfatheredUnlockedRouteIds, contains('gokyuzu-adalari'));
      expect(processed.transition.routeCompletedNow, isFalse);
      expect(processed.transition.rewardGranted, isFalse);
      expect(saved.unlockedRouteRewardIds, isEmpty);
      expect(processed.destination.isTrueRouteFinal, isFalse);
      expect(
        processed.destination.kind,
        isNot(WordHuntCompletionDestinationKind.terminalRouteComplete),
      );
    },
  );

  test('L30 crossing earns pilot access, never route completion or reward', () {
    final before = _pilotProgress(29, 59);
    final result = WordHuntRouteRewardEngine.recordLevelResult(
      route: _starter,
      progress: before,
      levelId: _starter.levels[29].id,
      stars: 1,
    );
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(result.progress), isTrue);
    expect(
      result.progress.grandfatheredUnlockedRouteIds,
      contains('gokyuzu-adalari'),
    );
    expect(result.afterRouteComplete, isFalse);
    expect(result.routeCompletedNow, isFalse);
    expect(result.rewardGranted, isFalse);
    expect(result.progress.unlockedRouteRewardIds, isEmpty);
  });

  testWidgets(
    'existing schema-3 eligible user gets one lossless load writeback',
    (tester) async {
      final pilot = _pilotProgress(30, 60);
      final original = WordHuntProgressSnapshot(
        bestStarsByLevelId: {...pilot.bestStarsByLevelId, 'other-level': 2},
        bestBonusFoundCountByLevelId: {'other-level': 1},
        unlockedInfoCardIds: {'existing-card'},
        unlockedRouteRewardIds: {'existing-reward'},
        grandfatheredUnlockedRouteIds: {'other-route'},
        lastActiveRouteId: _starter.id,
      );
      final store =
          _Store()
            ..raw = WordHuntProgressCodec.encode(original, ownerScope: 'guest');
      Future<void> load() async {
        await tester.pumpWidget(
          MaterialApp(
            home: WordHuntFeatureEntryScreen(
              progressStore: store,
              progressStorageIdentity: const _Identity(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await load();
      final saved = WordHuntProgressCodec.decode(
        store.raw!,
        expectedOwnerScope: 'guest',
      );
      expect(WordHuntProgressCodec.schemaVersion, 3);
      expect(store.writes, 1);
      expect(
        saved.grandfatheredUnlockedRouteIds,
        containsAll(['other-route', 'gokyuzu-adalari']),
      );
      expect(saved.bestStarsByLevelId, original.bestStarsByLevelId);
      expect(
        saved.bestBonusFoundCountByLevelId,
        original.bestBonusFoundCountByLevelId,
      );
      expect(saved.unlockedInfoCardIds, original.unlockedInfoCardIds);
      expect(saved.unlockedRouteRewardIds, contains('existing-reward'));
      expect(saved.lastActiveRouteId, original.lastActiveRouteId);
      expect(
        identical(
          WordHuntRouteRewardEngine.backfillCompletedRoutes(saved),
          saved,
        ),
        isTrue,
      );
      await tester.pumpWidget(const SizedBox());
      await load();
      expect(store.writes, 1);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'earned grandfather access survives stricter future policy reevaluation',
    () {
      const progress = WordHuntProgressSnapshot(
        grandfatheredUnlockedRouteIds: {'gokyuzu-adalari'},
      );
      expect(
        WordHuntRouteCatalog.gokyuzu.unlockRule.isUnlocked(progress),
        isFalse,
      );
      expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isTrue);
      expect(
        WordHuntRouteCatalog.grantEligiblePilotAccess(progress),
        same(progress),
      );
      final entry = WordHuntRouteCatalog.gokyuzu;
      final stricter = WordHuntRouteCatalogEntry(
        cardKey: entry.cardKey,
        route: entry.route,
        infoCards: entry.infoCards,
        ordinalLabel: entry.ordinalLabel,
        icon: entry.icon,
        colors: entry.colors,
        unlockRule: WordHuntRouteUnlockRule.routeComplete(
          prerequisiteRoute: _starter,
        ),
        presentationKind: entry.presentationKind,
        presentationProfile: entry.presentationProfile,
      );
      expect(stricter.isUnlocked(progress), isTrue);
    },
  );

  for (final boundary in [
    (29, 60, '29 / 30 bölüm • 60 / 60 yıldız'),
    (30, 59, '30 / 30 bölüm • 59 / 60 yıldız'),
  ]) {
    testWidgets('selector shows both conditions: ${boundary.$3}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntRouteSelector(
            progress: _pilotProgress(boundary.$1, boundary.$2),
            onRouteTap: (_) {},
          ),
        ),
      );
      expect(find.text(boundary.$3), findsOneWidget);
      expect(
        find.text('Başlangıç Limanı L1–30’u tamamla ve en az 60 yıldız kazan.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('unlocked pilot keeps starter staged 40/100, not completed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteSelector(
          progress: WordHuntRouteCatalog.grantEligiblePilotAccess(
            _pilotProgress(30, 60),
          ),
          onRouteTap: (_) {},
        ),
      ),
    );
    final starter = find.byKey(const Key('word_hunt_route_card_starter'));
    expect(
      find.descendant(of: starter, matching: find.text('Tamamlandı')),
      findsNothing,
    );
    expect(
      find.descendant(of: starter, matching: find.textContaining('40 / 100')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: starter, matching: find.text('Rozet kazanıldı')),
      findsNothing,
    );
  });
}
