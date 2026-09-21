import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_orchestration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_global_level_numbering.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_rewards.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_segment_host.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_segment_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wave 10A global display numbering foundation', () {
    test('locked route order matches production catalog order', () {
      expect(
        WordHuntRouteCatalog.entries.map((entry) => entry.route.id).toList(),
        WordHuntGlobalLevelNumbering.routeOrder,
      );
    });

    test('global display matrix is exact and local index stays local', () {
      const cases = <(String, int, int)>[
        ('baslangic-limani', 1, 1),
        ('baslangic-limani', 100, 100),
        ('gokyuzu-adalari', 1, 101),
        ('gokyuzu-adalari', 50, 150),
        ('gokyuzu-adalari', 100, 200),
        ('orman-yolu', 1, 201),
        ('orman-2', 1, 301),
        ('kristal-vadisi', 1, 401),
        ('kayip-sehir', 1, 501),
        ('yeralti-kralligi', 1, 601),
        ('gunes-imparatorlugu', 1, 701),
        ('gunes-imparatorlugu', 100, 800),
      ];

      for (final item in cases) {
        expect(
          WordHuntGlobalLevelNumbering.globalDisplayNumber(
            routeId: item.$1,
            localIndex: item.$2,
          ),
          item.$3,
          reason: '${item.$1} local ${item.$2}',
        );
      }

      expect(
        () => WordHuntGlobalLevelNumbering.globalDisplayNumber(
          routeId: 'baslangic-limani',
          localIndex: 0,
        ),
        throwsRangeError,
      );
      expect(
        () => WordHuntGlobalLevelNumbering.globalDisplayNumber(
          routeId: 'baslangic-limani',
          localIndex: 101,
        ),
        throwsRangeError,
      );
    });

    test('explicit name wins; fallback uses global display number', () {
      final fallback = _level(index: 1, routeId: 'gokyuzu-adalari');
      final named = _level(
        index: 1,
        routeId: 'gokyuzu-adalari',
        displayName: 'Kervan İzi',
      );
      expect(
        WordHuntGlobalLevelNumbering.displayNameForLevel(fallback),
        'Bölüm 101',
      );
      expect(
        WordHuntGlobalLevelNumbering.displayNameForLevel(named),
        'Kervan İzi',
      );
    });
  });

  group('Wave 10A staged segmented-route foundation', () {
    final route = _partialRoute();

    test('20/2 route is segmented but not complete V2', () {
      expect(route.availableLevelCount, 20);
      expect(route.plannedRouteLevelCount, 100);
      expect(route.maximumStars, 60);
      expect(route.plannedMaximumStars, 300);
      expect(WordHuntSegmentProjection.isSegmentedRoute(route), isTrue);
      expect(WordHuntSegmentProjection.isCompleteV2Route(route), isFalse);
      expect(WordHuntSegmentProjection.isExplicitV2Route(route), isFalse);
      expect(WordHuntDefinitionValidator.validateRoute(route), isEmpty);
    });

    test('Segment2 projects exactly local nodes 1-10 over absolute 11-20', () {
      final progress = _progressThrough(route, 10);
      final host = WordHuntRouteSegmentHost.forRoute(
        route: route,
        progress: progress,
        segmentIndex: 2,
      );

      expect(host.isLegacySegmentOne, isFalse);
      expect(host.nodes, hasLength(10));
      expect(
        host.nodes.map((node) => node.localNodeIndex).toList(),
        List<int>.generate(10, (index) => index + 1),
      );
      expect(
        host.nodes.map((node) => node.absoluteLevelIndex).toList(),
        List<int>.generate(10, (index) => index + 11),
      );
    });

    test('content frontier is never interpreted as route completion', () {
      final completeAvailable = _progressThrough(route, 20);
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(route, completeAvailable),
        isFalse,
      );
      expect(
        WordHuntSegmentProjection.forLevel(route, 20).isTrueRouteFinal,
        isFalse,
      );
    });

    test('L10 transitions to Segment2 while L20 stops at content frontier', () {
      final throughNine = _progressThrough(route, 9);
      final afterTen = throughNine.recordLevelResult(
        levelId: route.levels[9].id,
        stars: 1,
      );
      final tenTransition = WordHuntRouteRewardTransition(
        progress: afterTen,
        beforeRouteComplete: false,
        afterRouteComplete: false,
        rewardGranted: false,
      );
      final tenDestination = WordHuntCompletionCoordinator.resolve(
        route: route,
        completedLevelId: route.levels[9].id,
        beforeProgress: throughNine,
        afterProgress: afterTen,
        transition: tenTransition,
        catalogEntries: const <WordHuntRouteCatalogEntry>[],
      );

      expect(
        tenDestination.kind,
        WordHuntCompletionDestinationKind.nextSegment,
      );
      expect(tenDestination.completedSegment, 1);
      expect(tenDestination.nextPlayableSegment, 2);
      expect(tenDestination.canonicalNextPlayableLevel, 11);

      final throughNineteen = _progressThrough(route, 19);
      final afterTwenty = throughNineteen.recordLevelResult(
        levelId: route.levels[19].id,
        stars: 1,
      );
      final twentyTransition = WordHuntRouteRewardTransition(
        progress: afterTwenty,
        beforeRouteComplete: false,
        afterRouteComplete: false,
        rewardGranted: false,
      );
      final twentyDestination = WordHuntCompletionCoordinator.resolve(
        route: route,
        completedLevelId: route.levels[19].id,
        beforeProgress: throughNineteen,
        afterProgress: afterTwenty,
        transition: twentyTransition,
        catalogEntries: const <WordHuntRouteCatalogEntry>[],
      );

      expect(
        twentyDestination.kind,
        WordHuntCompletionDestinationKind.contentFrontier,
      );
      expect(twentyDestination.completedSegment, 2);
      expect(twentyDestination.segmentCompletedNow, isTrue);
      expect(twentyDestination.isTrueRouteFinal, isFalse);
      expect(twentyDestination.routeCompletedNow, isFalse);
      expect(twentyDestination.rewardGrantedNow, isFalse);
    });

    test('content frontier never grants route reward', () {
      final before = _progressThrough(route, 19);
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: before,
        levelId: route.levels[19].id,
        stars: 3,
        foundBonusCount: 0,
      );

      expect(transition.afterRouteComplete, isFalse);
      expect(transition.routeCompletedNow, isFalse);
      expect(transition.rewardGranted, isFalse);
      expect(
        transition.progress.unlockedRouteRewardIds,
        isNot(contains(route.routeRewardId)),
      );
    });

    test('staged route rejects lying routeFinal at current content frontier', () {
      final invalid = _partialRoute(lastType: WordHuntLevelType.routeFinal);
      expect(
        WordHuntDefinitionValidator.validateRoute(invalid),
        contains('staged 2.0 içerik sınırı rota finali olamaz'),
      );
    });
  });
}

WordHuntLevelDefinition _level({
  required int index,
  required String routeId,
  String? displayName,
  WordHuntLevelType type = WordHuntLevelType.normal,
}) {
  return WordHuntLevelDefinition(
    id: '$routeId-$index',
    routeId: routeId,
    index: index,
    type: type,
    grid: const <String>['ABC', 'DEF', 'GHI'],
    targetWords: const <String>['ABC'],
    starRules: const WordHuntStarRules(),
    displayName: displayName,
  );
}

WordHuntRouteDefinition _partialRoute({
  WordHuntLevelType lastType = WordHuntLevelType.challenge,
}) {
  const routeId = 'baslangic-limani';
  return WordHuntRouteDefinition(
    id: routeId,
    title: 'Başlangıç Limanı',
    theme: 'liman',
    unlockStarsRequired: 18,
    routeRewardId: 'reward',
    plannedLevelCount: 100,
    levels: List<WordHuntLevelDefinition>.generate(20, (offset) {
      final index = offset + 1;
      return _level(
        index: index,
        routeId: routeId,
        type: index == 20 ? lastType : WordHuntLevelType.normal,
      );
    }, growable: false),
    segments: const <WordHuntSegmentDefinition>[
      WordHuntSegmentDefinition(
        id: 'baslangic-limani-segment-01',
        index: 1,
        displayName: 'Segment 1',
        startLevelIndex: 1,
        endLevelIndex: 10,
      ),
      WordHuntSegmentDefinition(
        id: 'baslangic-limani-segment-02',
        index: 2,
        displayName: 'Segment 2',
        startLevelIndex: 11,
        endLevelIndex: 20,
      ),
    ],
  );
}

WordHuntProgressSnapshot _progressThrough(
  WordHuntRouteDefinition route,
  int levelIndex,
) {
  return WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (final level in route.levels.take(levelIndex)) level.id: 1,
    },
  );
}
