import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_orchestration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_presentations.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_milestone_info_rewards.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave 7 milestone info reward projection', () {
    test('normal level is not a milestone reward boundary', () {
      final route = _v2Route();
      final projection = WordHuntMilestoneInfoRewardEngine.project(
        route: route,
        routeInfoCards: _cards,
        completedLevelId: route.levels[8].id,
        beforeProgress: const WordHuntProgressSnapshot(),
      );

      expect(projection.milestoneEligible, isFalse);
      expect(projection.completedSegmentIndex, 1);
      expect(projection.candidateCardIds, isEmpty);
      expect(projection.newlyGrantedCardIds, isEmpty);
      expect(projection.shouldPresent, isFalse);
    });

    test('legacy L10 derives candidates from existing levels 1-10 only', () {
      final route = WordHuntStarterContent.baslangicLimani;
      final projection = WordHuntMilestoneInfoRewardEngine.project(
        route: route,
        routeInfoCards: WordHuntStarterContent.infoCards,
        completedLevelId: route.levels[9].id,
        beforeProgress: const WordHuntProgressSnapshot(),
      );
      final contentIds = <String>{
        for (final level in route.levels.take(10)) ...level.infoCardIds,
      };
      final catalogIds = WordHuntStarterContent.infoCards
          .map((card) => card.id)
          .toSet();

      expect(projection.milestoneEligible, isTrue);
      expect(projection.completedSegmentIndex, 1);
      expect(projection.candidateCardIds, contentIds);
      expect(projection.candidateCardIds.difference(catalogIds), isEmpty);
      expect(projection.resolvedCards.length, projection.candidateCardIds.length);
    });

    test('V2 L10 unions gameplay and milestone cards with correct delta', () async {
      final route = _v2Route();
      final throughNine = _progressThrough(route, 9);
      final before = WordHuntProgressSnapshot(
        bestStarsByLevelId: throughNine.bestStarsByLevelId,
        unlockedInfoCardIds: const <String>{'card-c'},
      );
      var readyCount = 0;
      var saveCount = 0;

      final result = await WordHuntCompletionOrchestrator.process(
        route: route,
        beforeProgress: before,
        levelId: route.levels[9].id,
        stars: 1,
        unlockedInfoCards: const <String>{'card-a'},
        foundBonusCount: null,
        routeInfoCards: _cards,
        onProgressReady: (_) => readyCount++,
        persistProgress: (_) async => saveCount++,
      );

      expect(result.destination.segmentCompletedNow, isTrue);
      expect(result.destination.completedSegment, 1);
      expect(
        result.destination.milestoneInfoReward.candidateCardIds,
        const <String>{'card-a', 'card-b', 'card-c'},
      );
      expect(
        result.destination.milestoneInfoReward.alreadyOwnedCardIds,
        const <String>{'card-a', 'card-c'},
      );
      expect(
        result.destination.milestoneInfoReward.newlyGrantedCardIds,
        const <String>{'card-b'},
      );
      expect(
        result.transition.progress.unlockedInfoCardIds,
        containsAll(<String>['card-a', 'card-b', 'card-c']),
      );
      expect(readyCount, 1);
      expect(saveCount, 1);
    });

    test('V2 segment milestones derive segment-local candidate sets', () {
      final route = _v2Route();
      final cases = <(int, int, Set<String>)>[
        (10, 1, <String>{'card-a', 'card-b', 'card-c'}),
        (20, 2, <String>{'card-d'}),
        (50, 5, <String>{'card-e'}),
        (100, 10, <String>{'card-f'}),
      ];

      for (final item in cases) {
        final projection = WordHuntMilestoneInfoRewardEngine.project(
          route: route,
          routeInfoCards: _cards,
          completedLevelId: route.levels[item.$1 - 1].id,
          beforeProgress: const WordHuntProgressSnapshot(),
        );
        expect(projection.milestoneEligible, isTrue, reason: 'L${item.$1}');
        expect(projection.completedSegmentIndex, item.$2);
        expect(projection.candidateCardIds, item.$3);
      }
    });

    test('replay is idempotent and does not surface already-owned cards', () async {
      final route = _v2Route();
      final before = _progressThrough(route, 9);
      final first = await WordHuntCompletionOrchestrator.process(
        route: route,
        beforeProgress: before,
        levelId: route.levels[9].id,
        stars: 1,
        unlockedInfoCards: const <String>{},
        foundBonusCount: null,
        routeInfoCards: _cards,
        onProgressReady: (_) {},
        persistProgress: (_) async {},
      );

      var replaySaves = 0;
      final replay = await WordHuntCompletionOrchestrator.process(
        route: route,
        beforeProgress: first.transition.progress,
        levelId: route.levels[9].id,
        stars: 1,
        unlockedInfoCards: const <String>{},
        foundBonusCount: null,
        routeInfoCards: _cards,
        onProgressReady: (_) {},
        persistProgress: (_) async => replaySaves++,
      );

      expect(
        replay.transition.progress.unlockedInfoCardIds,
        containsAll(<String>['card-a', 'card-b', 'card-c']),
      );
      expect(replay.destination.milestoneInfoReward.newlyGrantedCardIds, isEmpty);
      expect(replay.destination.milestoneInfoReward.shouldPresent, isFalse);
      expect(replaySaves, 1, reason: 'Replay has one canonical save, never a second card save.');
    });

    test('L50 stays midpoint only; L100 grants distinct card and route rewards', () async {
      final route = _v2Route();

      final l50 = await _process(route, 50, _progressThrough(route, 49));
      expect(l50.destination.isMajorMidpoint, isTrue);
      expect(l50.destination.isTrueRouteFinal, isFalse);
      expect(l50.destination.milestoneInfoReward.newlyGrantedCardIds, <String>{'card-e'});
      expect(l50.transition.rewardGranted, isFalse);

      final l100 = await _process(route, 100, _progressThrough(route, 99));
      expect(l100.destination.isTrueRouteFinal, isTrue);
      expect(l100.destination.completedSegment, 10);
      expect(l100.destination.milestoneInfoReward.newlyGrantedCardIds, <String>{'card-f'});
      expect(l100.transition.progress.unlockedInfoCardIds, contains('card-f'));
      expect(
        l100.transition.progress.unlockedRouteRewardIds,
        contains(route.routeRewardId),
      );
      expect(l100.transition.rewardGranted, isTrue);
    });

    test('historical owner with all candidate cards gets no new presentation', () {
      final route = _v2Route();
      const before = WordHuntProgressSnapshot(
        unlockedInfoCardIds: <String>{'card-a', 'card-b', 'card-c'},
      );
      final projection = WordHuntMilestoneInfoRewardEngine.project(
        route: route,
        routeInfoCards: _cards,
        completedLevelId: route.levels[9].id,
        beforeProgress: before,
      );

      expect(projection.alreadyOwnedCardIds.length, 3);
      expect(projection.newlyGrantedCardIds, isEmpty);
      expect(projection.shouldPresent, isFalse);
    });
  });

  group('Wave 7 persistence and chrome safety', () {
    test('schema v3 and historical storage prefix remain unchanged', () {
      const progress = WordHuntProgressSnapshot(
        unlockedInfoCardIds: <String>{'card-a', 'historical-id'},
      );
      final raw = WordHuntProgressCodec.encode(progress, ownerScope: 'wave7');
      final decoded = WordHuntProgressCodec.decode(
        raw,
        expectedOwnerScope: 'wave7',
      );

      expect(WordHuntProgressCodec.schemaVersion, 3);
      expect(
        WordHuntProgressCodec.storageKeyForUid('wave7'),
        startsWith('bilgi_rotasi_word_hunt_progress_v1_'),
      );
      expect(decoded.unlockedInfoCardIds, progress.unlockedInfoCardIds);
    });

    test('production map sources contain no book/compass callback plumbing', () {
      final paths = <String>[
        'lib/word_hunt/word_hunt_reference_route_screen.dart',
        'lib/word_hunt/word_hunt_pixel_proof_screen.dart',
        'lib/word_hunt/word_hunt_gokyuzu_master_art_screen.dart',
        'lib/word_hunt/word_hunt_themed_production_route_screen.dart',
        'lib/word_hunt/word_hunt_production_entry_screen.dart',
      ];
      for (final path in paths) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains('onCompass')), reason: path);
        expect(source, isNot(contains('onBook')), reason: path);
        expect(source, isNot(contains('_showCompassHint')), reason: path);
        expect(source, isNot(contains('_showBook')), reason: path);
      }

      final artworkSource = File(
        'lib/word_hunt/word_hunt_artwork_route_map_screen.dart',
      ).readAsStringSync();
      expect(artworkSource, isNot(contains('_CompassPulse')));
      expect(
        artworkSource,
        isNot(contains('word_hunt_route_stop_compass_highlight')),
      );
    });

    test('production keeps staged Starter plus seven legacy routes', () {
      expect(WordHuntRouteCatalog.entries.length, 8);
      final starter = WordHuntRouteCatalog.starter.route;
      expect(starter.levels, hasLength(20));
      expect(starter.plannedRouteLevelCount, 100);
      expect(starter.segments, hasLength(2));
      for (final entry in WordHuntRouteCatalog.entries.skip(1)) {
        expect(entry.route.levels, hasLength(10), reason: entry.route.id);
        expect(entry.route.segments, isEmpty, reason: entry.route.id);
      }
      expect(
        WordHuntRouteCatalog.entries
            .expand((entry) => entry.route.levels.take(10))
            .map((level) => level.id)
            .toSet()
            .length,
        80,
      );
    });
  });

  group('Wave 7 completion reward layout', () {
    const viewports = <Size>[Size(360, 640), Size(412, 915)];

    testWidgets('one, multiple, none, L50 and L100 reward states fit', (
      tester,
    ) async {
      final route = _v2Route();
      final multiple = await _process(route, 10, _progressThrough(route, 9));
      final one = await _process(route, 20, _progressThrough(route, 19));
      final l50 = await _process(route, 50, _progressThrough(route, 49));
      final l100 = await _process(route, 100, _progressThrough(route, 99));
      final noNew = await WordHuntCompletionOrchestrator.process(
        route: route,
        beforeProgress: WordHuntProgressSnapshot(
          bestStarsByLevelId: _progressThrough(route, 9).bestStarsByLevelId,
          unlockedInfoCardIds: const <String>{'card-a', 'card-b', 'card-c'},
        ),
        levelId: route.levels[9].id,
        stars: 1,
        unlockedInfoCards: const <String>{},
        foundBonusCount: null,
        routeInfoCards: _cards,
        onProgressReady: (_) {},
        persistProgress: (_) async {},
      );

      final cases = <WordHuntCompletionDestination>[
        one.destination,
        multiple.destination,
        noNew.destination,
        l50.destination,
        l100.destination,
      ];

      for (final viewport in viewports) {
        await tester.binding.setSurfaceSize(viewport);
        for (final destination in cases) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: WordHuntCompletionPresentation(destination: destination),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(
            find.byKey(const Key('word_hunt_completion_primary')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('word_hunt_completion_return_route')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('word_hunt_completion_info_reward')),
            destination.milestoneInfoReward.shouldPresent
                ? findsOneWidget
                : findsNothing,
          );
        }
      }
      await tester.binding.setSurfaceSize(null);
    });
  });
}

Future<WordHuntCompletionProcessResult> _process(
  WordHuntRouteDefinition route,
  int absoluteLevel,
  WordHuntProgressSnapshot before,
) {
  return WordHuntCompletionOrchestrator.process(
    route: route,
    beforeProgress: before,
    levelId: route.levels[absoluteLevel - 1].id,
    stars: 1,
    unlockedInfoCards: const <String>{},
    foundBonusCount: null,
    routeInfoCards: _cards,
    onProgressReady: (_) {},
    persistProgress: (_) async {},
  );
}

WordHuntProgressSnapshot _progressThrough(
  WordHuntRouteDefinition route,
  int absoluteLevel,
) {
  var progress = const WordHuntProgressSnapshot();
  for (var index = 0; index < absoluteLevel; index++) {
    progress = progress.recordLevelResult(
      levelId: route.levels[index].id,
      stars: 1,
    );
  }
  return progress;
}

const List<WordHuntInfoCard> _cards = <WordHuntInfoCard>[
  WordHuntInfoCard(
    id: 'card-a',
    word: 'AAA',
    title: 'Kart A',
    shortFact: 'A bilgisi.',
    category: 'Test',
  ),
  WordHuntInfoCard(
    id: 'card-b',
    word: 'BBB',
    title: 'Kart B',
    shortFact: 'B bilgisi.',
    category: 'Test',
  ),
  WordHuntInfoCard(
    id: 'card-c',
    word: 'CCC',
    title: 'Kart C',
    shortFact: 'C bilgisi.',
    category: 'Test',
  ),
  WordHuntInfoCard(
    id: 'card-d',
    word: 'DDD',
    title: 'Kart D',
    shortFact: 'D bilgisi.',
    category: 'Test',
  ),
  WordHuntInfoCard(
    id: 'card-e',
    word: 'EEE',
    title: 'Kart E',
    shortFact: 'E bilgisi.',
    category: 'Test',
  ),
  WordHuntInfoCard(
    id: 'card-f',
    word: 'FFF',
    title: 'Kart F',
    shortFact: 'F bilgisi.',
    category: 'Test',
  ),
];

WordHuntRouteDefinition _v2Route() {
  const routeId = 'wave7-v2';
  return WordHuntRouteDefinition(
    id: routeId,
    title: 'Wave 7 V2',
    theme: 'wave7',
    unlockStarsRequired: 0,
    routeRewardId: 'badge-kelime-yolcusu',
    levels: List<WordHuntLevelDefinition>.generate(100, (zeroIndex) {
      final index = zeroIndex + 1;
      final infoCardIds = switch (index) {
        1 => const <String>['card-a'],
        2 => const <String>['card-b'],
        10 => const <String>['card-c'],
        11 => const <String>['card-d'],
        41 => const <String>['card-e'],
        91 => const <String>['card-f'],
        _ => const <String>[],
      };
      return WordHuntLevelDefinition(
        id: 'wave7-v2-$index',
        routeId: routeId,
        index: index,
        type:
            index == 100
                ? WordHuntLevelType.routeFinal
                : WordHuntLevelType.normal,
        grid: const <String>['AAA', 'AAA', 'AAA'],
        targetWords: const <String>['AAA'],
        infoCardIds: infoCardIds,
        starRules: const WordHuntStarRules(),
      );
    }, growable: false),
    segments: List<WordHuntSegmentDefinition>.generate(10, (zeroIndex) {
      final segmentIndex = zeroIndex + 1;
      final start = zeroIndex * 10 + 1;
      return WordHuntSegmentDefinition(
        id: 'wave7-segment-$segmentIndex',
        index: segmentIndex,
        displayName: 'Segment $segmentIndex',
        startLevelIndex: start,
        endLevelIndex: start + 9,
      );
    }, growable: false),
  );
}
