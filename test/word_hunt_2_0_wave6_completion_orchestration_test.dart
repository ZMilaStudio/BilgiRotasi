import 'dart:async';
import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_orchestration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gameplay_presentation.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_master_art_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_rewards.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_segment_host.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reference_route_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_segment_projection.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_themed_production_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave 6 legacy compatibility', () {
    test('current 10-level route completion and star wall stay unchanged', () {
      final starter = WordHuntRouteCatalog.starter.route;
      var progress = const WordHuntProgressSnapshot();

      for (var i = 0; i < 9; i++) {
        progress = progress.recordLevelResult(
          levelId: starter.levels[i].id,
          stars: i < 5 ? 3 : 0,
        );
      }
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(starter, progress),
        isFalse,
      );

      progress = progress.recordLevelResult(
        levelId: starter.levels.last.id,
        stars: 1,
      );
      expect(
        WordHuntRouteProgressEngine.totalStars(starter, progress),
        lessThan(starter.unlockStarsRequired),
      );
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(starter, progress),
        isFalse,
      );

      progress = progress.recordLevelResult(
        levelId: starter.levels[5].id,
        stars: 3,
      );
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(starter, progress),
        isTrue,
      );
      expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isTrue);
    });

    test('legacy routes derive only segment 1', () {
      expect(
        WordHuntCompletionCoordinator.activeSegmentForProgress(
          route: WordHuntRouteCatalog.starter.route,
          progress: const WordHuntProgressSnapshot(),
        ),
        1,
      );
    });
  });

  group('Wave 6 explicit V2 true-final semantics', () {
    test('L10/L20/L50/L90 are not route complete; L100 is true final', () {
      final route = _v2Route();

      for (final index in <int>[10, 20, 50, 90]) {
        final progress = _progressThrough(index);
        expect(
          WordHuntRouteProgressEngine.isRouteComplete(route, progress),
          isFalse,
          reason: 'L$index',
        );
      }

      final finalProgress = _progressThrough(100);
      expect(
        WordHuntRouteProgressEngine.totalStars(route, finalProgress),
        lessThan(route.unlockStarsRequired),
      );
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(route, finalProgress),
        isTrue,
      );
      expect(
        WordHuntSegmentProjection.forLevel(route, 10).isTrueRouteFinal,
        isFalse,
      );
      expect(
        WordHuntSegmentProjection.forLevel(route, 100).isTrueRouteFinal,
        isTrue,
      );
    });

    test('raw L10 routeFinal never overrides explicit V2 authority', () {
      final route = _v2Route();
      expect(route.levels[9].type, WordHuntLevelType.routeFinal);
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(
          route,
          _progressThrough(10),
        ),
        isFalse,
      );
    });
  });

  group('Wave 6 completion coordinator destinations', () {
    test('normal completion uses canonical next playable, not index + 1', () {
      final route = _v2Route();
      final entry = _entry(route);

      final first = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: const WordHuntProgressSnapshot(),
        levelId: route.levels.first.id,
        stars: 1,
      );
      final firstDestination = WordHuntCompletionCoordinator.resolve(
        route: route,
        completedLevelId: route.levels.first.id,
        beforeProgress: const WordHuntProgressSnapshot(),
        afterProgress: first.progress,
        transition: first,
        catalogEntries: <WordHuntRouteCatalogEntry>[entry],
      );
      expect(
        firstDestination.kind,
        WordHuntCompletionDestinationKind.nextLevel,
      );
      expect(firstDestination.canonicalNextPlayableLevel, 2);

      final ahead = _progressThrough(36);
      final replay = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: ahead,
        levelId: route.levels.first.id,
        stars: 1,
      );
      final replayDestination = WordHuntCompletionCoordinator.resolve(
        route: route,
        completedLevelId: route.levels.first.id,
        beforeProgress: ahead,
        afterProgress: replay.progress,
        transition: replay,
        catalogEntries: <WordHuntRouteCatalogEntry>[entry],
      );
      expect(replayDestination.canonicalNextPlayableLevel, 37);
      expect(replayDestination.nextPlayableSegment, 4);
    });

    test('L10/L20/L90 resolve next segment map identity', () {
      final route = _v2Route();
      final entry = _entry(route);
      for (final pair in <(int, int)>[(10, 2), (20, 3), (90, 10)]) {
        final before = _progressThrough(pair.$1 - 1);
        final transition = WordHuntRouteRewardEngine.recordLevelResult(
          route: route,
          progress: before,
          levelId: route.levels[pair.$1 - 1].id,
          stars: 1,
        );
        final destination = WordHuntCompletionCoordinator.resolve(
          route: route,
          completedLevelId: route.levels[pair.$1 - 1].id,
          beforeProgress: before,
          afterProgress: transition.progress,
          transition: transition,
          catalogEntries: <WordHuntRouteCatalogEntry>[entry],
        );

        expect(
          destination.kind,
          WordHuntCompletionDestinationKind.nextSegment,
          reason: 'L${pair.$1}',
        );
        expect(destination.nextPlayableSegment, pair.$2);
        expect(destination.routeCompletedNow, isFalse);
        expect(destination.rewardGrantedNow, isFalse);
      }
    });

    test('L50 is midpoint + segment end but not route final', () {
      final route = _v2Route();
      final entry = _entry(route);
      final before = _progressThrough(49);
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: before,
        levelId: route.levels[49].id,
        stars: 1,
      );
      final destination = WordHuntCompletionCoordinator.resolve(
        route: route,
        completedLevelId: route.levels[49].id,
        beforeProgress: before,
        afterProgress: transition.progress,
        transition: transition,
        catalogEntries: <WordHuntRouteCatalogEntry>[entry],
      );

      expect(destination.isMajorMidpoint, isTrue);
      expect(destination.segmentCompletedNow, isTrue);
      expect(destination.isTrueRouteFinal, isFalse);
      expect(destination.routeCompletedNow, isFalse);
      expect(destination.rewardGrantedNow, isFalse);
      expect(destination.nextPlayableSegment, 6);
      expect(
        destination.kind,
        WordHuntCompletionDestinationKind.nextSegment,
      );
    });

    test('L100 first completion unlocks next route and grants reward once', () {
      final route = _v2Route();
      final nextRoute = _legacyNextRoute();
      final entry = _entry(route);
      final nextEntry = _entry(
        nextRoute,
        unlockRule: WordHuntRouteUnlockRule.routeComplete(
          prerequisiteRoute: route,
        ),
      );
      final before = _progressThrough(99);
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: before,
        levelId: route.levels[99].id,
        stars: 1,
      );
      final destination = WordHuntCompletionCoordinator.resolve(
        route: route,
        completedLevelId: route.levels[99].id,
        beforeProgress: before,
        afterProgress: transition.progress,
        transition: transition,
        catalogEntries: <WordHuntRouteCatalogEntry>[entry, nextEntry],
      );

      expect(destination.isTrueRouteFinal, isTrue);
      expect(destination.routeCompletedNow, isTrue);
      expect(destination.rewardGrantedNow, isTrue);
      expect(
        destination.kind,
        WordHuntCompletionDestinationKind.nextRoute,
      );
      expect(destination.nextRoute?.route.id, nextRoute.id);
      expect(nextEntry.isUnlocked(transition.progress), isTrue);

      final replay = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: transition.progress,
        levelId: route.levels[99].id,
        stars: 1,
      );
      expect(replay.routeCompletedNow, isFalse);
      expect(replay.rewardGranted, isFalse);
      expect(
        replay.progress.unlockedRouteRewardIds
            .where((id) => id == route.routeRewardId),
        hasLength(1),
      );
    });

    test('last catalog route resolves terminal destination', () {
      final route = _v2Route();
      final entry = _entry(route);
      final before = _progressThrough(99);
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: before,
        levelId: route.levels[99].id,
        stars: 1,
      );
      final destination = WordHuntCompletionCoordinator.resolve(
        route: route,
        completedLevelId: route.levels[99].id,
        beforeProgress: before,
        afterProgress: transition.progress,
        transition: transition,
        catalogEntries: <WordHuntRouteCatalogEntry>[entry],
      );
      expect(
        destination.kind,
        WordHuntCompletionDestinationKind.terminalRouteComplete,
      );
      expect(destination.summary.terminal, isTrue);
      expect(destination.nextRoute, isNull);
    });
  });

  group('Wave 6 grandfathered access', () {
    test('entitlement grants access only, without fake completion/reward/stars', () {
      final prerequisite = _v2Route();
      final lockedRoute = _legacyNextRoute();
      final entry = _entry(
        lockedRoute,
        unlockRule: WordHuntRouteUnlockRule.routeComplete(
          prerequisiteRoute: prerequisite,
        ),
      );
      final progress = WordHuntProgressSnapshot(
        grandfatheredUnlockedRouteIds: <String>{lockedRoute.id},
      );

      expect(entry.isUnlocked(progress), isTrue);
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(prerequisite, progress),
        isFalse,
      );
      expect(progress.unlockedRouteRewardIds, isEmpty);
      expect(
        WordHuntRouteProgressEngine.totalStars(prerequisite, progress),
        0,
      );
    });

    test('fresh result never creates new grandfathered entitlement', () {
      final route = _v2Route();
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: const WordHuntProgressSnapshot(),
        levelId: route.levels.first.id,
        stars: 1,
      );
      expect(transition.progress.grandfatheredUnlockedRouteIds, isEmpty);
    });
  });

  group('Wave 6 save and duplicate-write safety', () {
    test('destination is unavailable until canonical save future resolves', () async {
      final route = _v2Route();
      final entry = _entry(route);
      final saveGate = Completer<void>();
      final events = <String>[];
      var completed = false;

      final future = WordHuntCompletionOrchestrator.process(
        route: route,
        beforeProgress: const WordHuntProgressSnapshot(),
        levelId: route.levels.first.id,
        stars: 1,
        unlockedInfoCards: const <String>{},
        foundBonusCount: null,
        onProgressReady: (_) => events.add('state'),
        persistProgress: (_) async {
          events.add('save-start');
          await saveGate.future;
          events.add('save-end');
        },
        catalogEntries: <WordHuntRouteCatalogEntry>[entry],
      ).then((value) {
        completed = true;
        events.add('destination');
        return value;
      });

      await Future<void>.delayed(Duration.zero);
      expect(events, <String>['state', 'save-start']);
      expect(completed, isFalse);

      saveGate.complete();
      final processed = await future;
      expect(events, <String>[
        'state',
        'save-start',
        'save-end',
        'destination',
      ]);
      expect(
        processed.destination.kind,
        WordHuntCompletionDestinationKind.nextLevel,
      );
    });

    test('CTA handler source has no second record or persistence write', () {
      final source = File(
        'lib/word_hunt/word_hunt_production_entry_screen.dart',
      ).readAsStringSync();
      final start = source.indexOf('Future<void> _showParentCompletion');
      final end = source.indexOf(
        'Future<void> _showRouteCompletionCeremony',
        start,
      );
      final handler = source.substring(start, end);

      expect(handler, isNot(contains('recordLevelResult')));
      expect(handler, isNot(contains('_saveProgress(')));
      expect(handler, isNot(contains('grantRouteReward')));
    });

    test('markLastActiveRoute same route is identity/no redundant write state', () {
      const progress = WordHuntProgressSnapshot(
        lastActiveRouteId: 'wave6-v2',
      );
      expect(
        identical(progress.markLastActiveRoute('wave6-v2'), progress),
        isTrue,
      );
    });
  });

  group('Wave 6 active segment and map host', () {
    test('next playable 37 derives active segment 4', () {
      final route = _v2Route();
      expect(
        WordHuntRouteProgressEngine.nextPlayableLevelIndex(
          route,
          _progressThrough(36),
        ),
        37,
      );
      expect(
        WordHuntCompletionCoordinator.activeSegmentForProgress(
          route: route,
          progress: _progressThrough(36),
        ),
        4,
      );
    });

    test('segment hosts expose only 11-20, 41-50 and 91-100', () {
      final route = _v2Route();
      for (final item in <(int, int, int)>[
        (2, 11, 20),
        (5, 41, 50),
        (10, 91, 100),
      ]) {
        final host = WordHuntRouteSegmentHost.forRoute(
          route: route,
          progress: const WordHuntProgressSnapshot(),
          segmentIndex: item.$1,
        );
        expect(host.nodes, hasLength(10));
        expect(host.nodes.first.absoluteLevelIndex, item.$2);
        expect(host.nodes.last.absoluteLevelIndex, item.$3);
      }
    });

    testWidgets('reference/Gökyüzü/themed map families thread segmentIndex', (
      tester,
    ) async {
      final route = _v2Route();
      int? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntReferenceRouteScreen(
            route: route,
            segmentIndex: 2,
            onLevelTap: (value) => tapped = value,
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('word_hunt_reference_level_11')), findsOneWidget);
      expect(find.byKey(const Key('word_hunt_reference_level_1')), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntGokyuzuMasterArtScreen(
            route: route,
            segmentIndex: 2,
            onLevelTap: (value) => tapped = value,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('word_hunt_gokyuzu_master_art_level_1')),
        warnIfMissed: false,
      );
      expect(tapped, 11);

      tapped = null;
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntThemedProductionRouteScreen(
            route: route,
            visualTheme: WordHuntRouteVisualThemes.ormanYolu,
            progress: const WordHuntProgressSnapshot(),
            onBack: () {},
            onInfo: () {},
            onCompass: () {},
            onBook: () {},
            onLevelTap: (value) => tapped = value,
            segmentIndex: 2,
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('word_hunt_reusable_level_11')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_reusable_level_1')),
        findsNothing,
      );
    });
  });

  group('Wave 6 completion summary and result contract', () {
    test('summary derives stars, bonus max/unknown, reward/profile/terminal', () {
      final route = _v2Route();
      final entry = _entry(route);
      final before = _progressThrough(99);
      final withKnownBonus = WordHuntProgressSnapshot(
        bestStarsByLevelId: before.bestStarsByLevelId,
        bestBonusFoundCountByLevelId: const <String, int>{
          'wave6-1': 0,
          'wave6-2': 1,
        },
      );
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: withKnownBonus,
        levelId: route.levels[99].id,
        stars: 1,
      );
      final destination = WordHuntCompletionCoordinator.resolve(
        route: route,
        completedLevelId: route.levels[99].id,
        beforeProgress: withKnownBonus,
        afterProgress: transition.progress,
        transition: transition,
        catalogEntries: <WordHuntRouteCatalogEntry>[entry],
      );
      final summary = destination.summary;

      expect(summary.totalStars, 100);
      expect(summary.maximumStars, 300);
      expect(summary.knownBonusFoundTotal, 1);
      expect(summary.maximumBonusTotal, 2);
      expect(summary.hasUnknownBonusHistory, isFalse);
      expect(summary.rewardGrantedNow, isTrue);
      expect(summary.presentationProfile.id, entry.presentationProfile.id);
      expect(summary.terminal, isTrue);
    });

    test('missing bonus key on historical completed bonus level stays unknown', () {
      final route = _v2Route();
      final entry = _entry(route);
      final before = _progressThrough(99);
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: before,
        levelId: route.levels[99].id,
        stars: 1,
      );
      final destination = WordHuntCompletionCoordinator.resolve(
        route: route,
        completedLevelId: route.levels[99].id,
        beforeProgress: before,
        afterProgress: transition.progress,
        transition: transition,
        catalogEntries: <WordHuntRouteCatalogEntry>[entry],
      );
      expect(destination.summary.hasUnknownBonusHistory, isTrue);
    });

    test('WordHuntLevelPlayResult remains facts-only', () {
      final source = File('lib/word_hunt/word_hunt_screens.dart')
          .readAsStringSync();
      final start = source.indexOf('class WordHuntLevelPlayResult');
      final end = source.indexOf('class WordHuntLevelProductionScreen', start);
      final contract = source.substring(start, end);

      expect(contract, contains('final String levelId;'));
      expect(contract, contains('final int stars;'));
      expect(contract, contains('final Set<String> unlockedInfoCardIds;'));
      expect(contract, contains('final int? foundBonusCount;'));
      for (final forbidden in <String>[
        'nextLevel',
        'nextSegment',
        'nextRoute',
        'navigationAction',
        'routeComplete',
        'destinationRouteId',
      ]) {
        expect(contract, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('schema/navigation state remains derived and unpersisted', () {
      final codec = File('lib/word_hunt/word_hunt_progress_codec.dart')
          .readAsStringSync();
      expect(codec, contains('static const int schemaVersion = 3;'));
      expect(
        codec,
        contains("bilgi_rotasi_word_hunt_progress_v1_"),
      );
      for (final forbidden in <String>[
        "'activeSegment'",
        "'completionDestination'",
        "'nextLevel'",
        "'nextRoute'",
        "'completionUiState'",
        "'milestoneFlag'",
        "'completionSummary'",
      ]) {
        expect(codec, isNot(contains(forbidden)), reason: forbidden);
      }
    });
  });
}

WordHuntRouteDefinition _v2Route() {
  const routeId = 'wave6-v2';
  final levels = List<WordHuntLevelDefinition>.generate(100, (zeroIndex) {
    final index = zeroIndex + 1;
    return WordHuntLevelDefinition(
      id: 'wave6-$index',
      routeId: routeId,
      index: index,
      displayName: 'Wave 6 $index',
      type: index == 10 || index == 100
          ? WordHuntLevelType.routeFinal
          : WordHuntLevelType.normal,
      grid: const <String>['AAA', 'AAA', 'AAA'],
      targetWords: const <String>['AAA'],
      bonusWords: index <= 2 ? const <String>['A'] : const <String>[],
      starRules: const WordHuntStarRules(),
    );
  }, growable: false);
  final segments = List<WordHuntSegmentDefinition>.generate(10, (zeroIndex) {
    final index = zeroIndex + 1;
    final start = zeroIndex * 10 + 1;
    return WordHuntSegmentDefinition(
      id: 'wave6-segment-$index',
      index: index,
      displayName: 'Bölge $index',
      startLevelIndex: start,
      endLevelIndex: start + 9,
    );
  }, growable: false);

  return WordHuntRouteDefinition(
    id: routeId,
    title: 'Wave 6 Çok Uzun Synthetic Rota Başlığı',
    theme: 'wave6',
    unlockStarsRequired: 250,
    levels: levels,
    routeRewardId: 'wave6-reward',
    segments: segments,
  );
}

WordHuntRouteDefinition _legacyNextRoute() {
  return WordHuntRouteDefinition(
    id: 'wave6-next',
    title: 'Wave 6 Next',
    theme: 'wave6-next',
    unlockStarsRequired: 0,
    routeRewardId: 'wave6-next-reward',
    levels: List<WordHuntLevelDefinition>.generate(10, (zeroIndex) {
      final index = zeroIndex + 1;
      return WordHuntLevelDefinition(
        id: 'wave6-next-$index',
        routeId: 'wave6-next',
        index: index,
        type: index == 10
            ? WordHuntLevelType.routeFinal
            : WordHuntLevelType.normal,
        grid: const <String>['AAA', 'AAA', 'AAA'],
        targetWords: const <String>['AAA'],
        starRules: const WordHuntStarRules(),
      );
    }, growable: false),
  );
}

WordHuntRouteCatalogEntry _entry(
  WordHuntRouteDefinition route, {
  WordHuntRouteUnlockRule? unlockRule,
}) {
  return WordHuntRouteCatalogEntry(
    cardKey: route.id,
    route: route,
    infoCards: const <WordHuntInfoCard>[],
    ordinalLabel: 'Wave 6',
    icon: Icons.route_rounded,
    colors: const <Color>[Color(0xFF123456), Color(0xFF654321)],
    unlockRule: unlockRule ?? const WordHuntRouteUnlockRule.always(),
    presentationKind: WordHuntRoutePresentationKind.referenceRoute,
    presentationProfile: WordHuntRoutePresentationProfiles.starter,
  );
}

WordHuntProgressSnapshot _progressThrough(int absoluteLevel) {
  return WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (var index = 1; index <= absoluteLevel; index++) 'wave6-$index': 1,
    },
  );
}
