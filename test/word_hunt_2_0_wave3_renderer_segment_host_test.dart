import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_segment_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wave 3 legacy 10-node equivalence', () {
    test('every production route projects the same canonical 10 levels', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        final route = entry.route;
        final host = WordHuntRouteSegmentHost.forRoute(
          route: route,
          progress: const WordHuntProgressSnapshot(),
        );

        expect(host.isLegacySegmentOne, isTrue, reason: route.id);
        expect(host.nodes, hasLength(10), reason: route.id);
        expect(
          host.nodes.map((node) => node.localNodeIndex).toList(),
          List<int>.generate(10, (index) => index + 1),
          reason: route.id,
        );
        expect(
          host.nodes.map((node) => node.absoluteLevelIndex).toList(),
          List<int>.generate(10, (index) => index + 1),
          reason: route.id,
        );
        expect(
          host.nodes.map((node) => node.levelId).toList(),
          route.levels.map((level) => level.id).toList(),
          reason: route.id,
        );
      }
    });

    test('legacy L10 keeps endpoint and route-final presentation identity', () {
      final route = WordHuntRouteCatalog.entries.first.route;
      final host = WordHuntRouteSegmentHost.forRoute(
        route: route,
        progress: const WordHuntProgressSnapshot(),
      );
      final node10 = host.nodes.last;

      expect(node10.localNodeIndex, 10);
      expect(node10.absoluteLevelIndex, 10);
      expect(node10.isSegmentEndpoint, isTrue);
      expect(node10.gameplayType, WordHuntLevelType.routeFinal);
      expect(node10.isTrueRouteFinal, isTrue);
    });
  });

  group('Wave 3 synthetic 100-level segment host', () {
    final route = _syntheticRoute();

    test('segments 1, 2, 5 and 10 emit exactly 10 canonical nodes', () {
      for (final expectation in <(int, int, int)>[
        (1, 1, 10),
        (2, 11, 20),
        (5, 41, 50),
        (10, 91, 100),
      ]) {
        final host = WordHuntRouteSegmentHost.forRoute(
          route: route,
          progress: const WordHuntProgressSnapshot(),
          segmentIndex: expectation.$1,
        );

        expect(host.isLegacySegmentOne, isFalse);
        expect(host.nodes, hasLength(10));
        expect(
          host.nodes.map((node) => node.localNodeIndex).toList(),
          List<int>.generate(10, (index) => index + 1),
        );
        expect(host.nodes.first.absoluteLevelIndex, expectation.$2);
        expect(host.nodes.last.absoluteLevelIndex, expectation.$3);
        expect(host.nodes.first.levelId, 'synthetic-${expectation.$2}');
        expect(host.nodes.last.levelId, 'synthetic-${expectation.$3}');
      }
    });

    test('local identity remains separate from absolute gameplay identity', () {
      final segment2 = WordHuntRouteSegmentHost.forRoute(
        route: route,
        progress: _progressThrough(10),
        segmentIndex: 2,
      );
      final segment5 = WordHuntRouteSegmentHost.forRoute(
        route: route,
        progress: _progressThrough(49),
        segmentIndex: 5,
      );
      final segment10 = WordHuntRouteSegmentHost.forRoute(
        route: route,
        progress: _progressThrough(99),
        segmentIndex: 10,
      );

      expect(segment2.nodes.first.localNodeIndex, 1);
      expect(segment2.nodes.first.absoluteLevelIndex, 11);
      expect(segment2.nodes.last.localNodeIndex, 10);
      expect(segment2.nodes.last.absoluteLevelIndex, 20);
      expect(segment5.nodes.last.localNodeIndex, 10);
      expect(segment5.nodes.last.absoluteLevelIndex, 50);
      expect(segment10.nodes.last.localNodeIndex, 10);
      expect(segment10.nodes.last.absoluteLevelIndex, 100);
    });

    test('segment endpoint, midpoint and true final stay distinct', () {
      final segment2 = WordHuntRouteSegmentHost.forRoute(
        route: route,
        progress: const WordHuntProgressSnapshot(),
        segmentIndex: 2,
      );
      final segment5 = WordHuntRouteSegmentHost.forRoute(
        route: route,
        progress: const WordHuntProgressSnapshot(),
        segmentIndex: 5,
      );
      final segment10 = WordHuntRouteSegmentHost.forRoute(
        route: route,
        progress: const WordHuntProgressSnapshot(),
        segmentIndex: 10,
      );

      expect(segment2.nodes.last.isSegmentEndpoint, isTrue);
      expect(segment2.nodes.last.absoluteLevelIndex, 20);
      expect(segment2.nodes.last.isTrueRouteFinal, isFalse);

      expect(segment5.nodes.last.absoluteLevelIndex, 50);
      expect(segment5.nodes.last.isSegmentEndpoint, isTrue);
      expect(segment5.nodes.last.isMajorMidpoint, isTrue);
      expect(segment5.nodes.last.isTrueRouteFinal, isFalse);

      expect(segment10.nodes.last.absoluteLevelIndex, 100);
      expect(segment10.nodes.last.isSegmentEndpoint, isTrue);
      expect(segment10.nodes.last.isTrueRouteFinal, isTrue);
    });

    testWidgets('renderer tap on segment 2 local node 1 resolves absolute 11', (
      tester,
    ) async {
      var tappedAbsoluteIndex = 0;
      await tester.binding.setSurfaceSize(const Size(540, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntReusableRouteMapScreen(
            route: route,
            theme: WordHuntRouteMapTheme.harborProof,
            progress: _progressThrough(10),
            segmentIndex: 2,
            onLevelTap: (absoluteIndex) => tappedAbsoluteIndex = absoluteIndex,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('word_hunt_reusable_level_11')), findsOneWidget);
      expect(find.byKey(const Key('word_hunt_reusable_level_1')), findsNothing);

      await tester.tap(
        find.byKey(const Key('word_hunt_reusable_level_11')),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(tappedAbsoluteIndex, 11);
    });
  });

  group('Wave 3 geometry and persistence regression', () {
    test('canonical geometry remains exactly ten points and nine connections', () {
      expect(WordHuntRouteMapGeometry.normalizedStops, hasLength(10));
      expect(WordHuntRouteMapGeometry.connections, <(int, int)>[
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 5),
        (5, 6),
        (6, 7),
        (7, 8),
        (8, 9),
        (9, 10),
      ]);
    });

    test('forward and reverse reuse the exact canonical point set', () {
      const size = Size(941, 1672);
      final forward = WordHuntRouteMapGeometry.pointsFor(
        size,
        presentationOrder: WordHuntRoutePresentationOrder.forward,
      );
      final reverse = WordHuntRouteMapGeometry.pointsFor(
        size,
        presentationOrder: WordHuntRoutePresentationOrder.reverse,
      );

      expect(forward, hasLength(10));
      expect(reverse, hasLength(10));
      for (var index = 0; index < 10; index++) {
        expect(reverse[index], forward[9 - index]);
      }
    });

    test('renderer decomposition adds no persistence schema state', () {
      expect(WordHuntProgressCodec.schemaVersion, 3);
      expect(
        WordHuntProgressCodec.storageKeyForUid(null),
        'bilgi_rotasi_word_hunt_progress_v1_guest',
      );
    });
  });
}

WordHuntRouteDefinition _syntheticRoute() {
  const routeId = 'synthetic-wave3';
  final levels = List<WordHuntLevelDefinition>.generate(100, (zeroIndex) {
    final index = zeroIndex + 1;
    return WordHuntLevelDefinition(
      id: 'synthetic-$index',
      routeId: routeId,
      index: index,
      displayName: 'Synthetic $index',
      type: index == 100
          ? WordHuntLevelType.routeFinal
          : index % 10 == 5
          ? WordHuntLevelType.challenge
          : WordHuntLevelType.normal,
      grid: const <String>['AAA', 'AAA', 'AAA'],
      targetWords: const <String>['AAA'],
      starRules: const WordHuntStarRules(),
    );
  }, growable: false);

  final segments = List<WordHuntSegmentDefinition>.generate(10, (zeroIndex) {
    final index = zeroIndex + 1;
    final start = zeroIndex * 10 + 1;
    return WordHuntSegmentDefinition(
      id: 'segment-$index',
      index: index,
      displayName: 'Segment $index',
      startLevelIndex: start,
      endLevelIndex: start + 9,
    );
  }, growable: false);

  return WordHuntRouteDefinition(
    id: routeId,
    title: 'Synthetic Route',
    theme: 'synthetic',
    unlockStarsRequired: 0,
    levels: levels,
    routeRewardId: 'synthetic-reward',
    segments: segments,
  );
}

WordHuntProgressSnapshot _progressThrough(int absoluteLevelIndex) {
  return WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (var index = 1; index <= absoluteLevelIndex; index++)
        'synthetic-$index': 1,
    },
  );
}
