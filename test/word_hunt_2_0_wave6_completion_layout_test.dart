import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_orchestration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_presentations.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gameplay_presentation.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_rewards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const viewports = <Size>[Size(360, 640), Size(412, 915)];

  testWidgets('normal/segment/midpoint/strong completion fit compact+tall', (
    tester,
  ) async {
    final route = _route();
    final entry = _entry(route);
    final destinations = <WordHuntCompletionDestination>[
      _destination(route, entry, 1),
      _destination(route, entry, 10),
      _destination(route, entry, 50),
      _destination(route, entry, 100),
    ];

    for (final viewport in viewports) {
      await tester.binding.setSurfaceSize(viewport);
      for (final destination in destinations) {
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

        expect(
          tester.takeException(),
          isNull,
          reason: destination.completedAbsoluteLevel.toString(),
        );
        final key =
            destination.routeCompletedNow || destination.isTrueRouteFinal
                ? const Key('word_hunt_route_completion_surface')
                : const Key('word_hunt_level_completion_surface');
        _expectInsideViewport(tester, key, viewport);
        _expectInsideViewport(
          tester,
          const Key('word_hunt_completion_primary'),
          viewport,
        );
        _expectInsideViewport(
          tester,
          const Key('word_hunt_completion_return_route'),
          viewport,
        );
        expect(
          find.byKey(const Key('word_hunt_completion_route_title')),
          findsOneWidget,
        );

        if (destination.completedAbsoluteLevel == 1) {
          expect(find.text('Sonraki Bölüm'), findsOneWidget);
        }
        if (destination.completedAbsoluteLevel == 10) {
          expect(find.text('Sonraki Bölge'), findsOneWidget);
          expect(find.text('Bölge Tamamlandı'), findsOneWidget);
        }
        if (destination.completedAbsoluteLevel == 50) {
          expect(
            find.byKey(const Key('word_hunt_completion_midpoint')),
            findsOneWidget,
          );
          expect(find.text('Sonraki Bölge'), findsOneWidget);
        }
        if (destination.completedAbsoluteLevel == 100) {
          expect(find.text('Rota Tamamlandı'), findsOneWidget);
          expect(
            find.byKey(const Key('word_hunt_completion_reward')),
            findsOneWidget,
          );
          expect(find.text('Rotalar'), findsOneWidget);
        }
      }
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('unknown bonus history remains readable on strong completion', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final route = _route();
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

    expect(find.textContaining('bilinmeyen kayıt var'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

WordHuntCompletionDestination _destination(
  WordHuntRouteDefinition route,
  WordHuntRouteCatalogEntry entry,
  int absoluteLevel,
) {
  final before = _progressThrough(absoluteLevel - 1);
  final transition = WordHuntRouteRewardEngine.recordLevelResult(
    route: route,
    progress: before,
    levelId: route.levels[absoluteLevel - 1].id,
    stars: 1,
  );
  return WordHuntCompletionCoordinator.resolve(
    route: route,
    completedLevelId: route.levels[absoluteLevel - 1].id,
    beforeProgress: before,
    afterProgress: transition.progress,
    transition: transition,
    catalogEntries: <WordHuntRouteCatalogEntry>[entry],
  );
}

WordHuntRouteDefinition _route() {
  const routeId = 'wave6-layout';
  return WordHuntRouteDefinition(
    id: routeId,
    title: 'Wave 6 Çok Uzun Rota Başlığı Taşma Yapmamalı ve Okunabilir Kalmalı',
    theme: 'wave6-layout',
    unlockStarsRequired: 250,
    routeRewardId: 'badge-kelime-yolcusu',
    levels: List<WordHuntLevelDefinition>.generate(100, (zeroIndex) {
      final index = zeroIndex + 1;
      return WordHuntLevelDefinition(
        id: 'wave6-layout-$index',
        routeId: routeId,
        index: index,
        type:
            index == 10 || index == 100
                ? WordHuntLevelType.routeFinal
                : WordHuntLevelType.normal,
        grid: const <String>['AAA', 'AAA', 'AAA'],
        targetWords: const <String>['AAA'],
        bonusWords: index <= 2 ? const <String>['A'] : const <String>[],
        starRules: const WordHuntStarRules(),
      );
    }, growable: false),
    segments: List<WordHuntSegmentDefinition>.generate(10, (zeroIndex) {
      final index = zeroIndex + 1;
      final start = zeroIndex * 10 + 1;
      return WordHuntSegmentDefinition(
        id: 'wave6-layout-segment-$index',
        index: index,
        displayName: 'Bölge $index',
        startLevelIndex: start,
        endLevelIndex: start + 9,
      );
    }, growable: false),
  );
}

WordHuntRouteCatalogEntry _entry(WordHuntRouteDefinition route) {
  return WordHuntRouteCatalogEntry(
    cardKey: route.id,
    route: route,
    infoCards: const <WordHuntInfoCard>[],
    ordinalLabel: 'Wave 6',
    icon: Icons.route_rounded,
    colors: const <Color>[Color(0xFF123456), Color(0xFF654321)],
    unlockRule: const WordHuntRouteUnlockRule.always(),
    presentationKind: WordHuntRoutePresentationKind.referenceRoute,
    presentationProfile: WordHuntRoutePresentationProfiles.starter,
  );
}

WordHuntProgressSnapshot _progressThrough(int absoluteLevel) {
  return WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (var index = 1; index <= absoluteLevel; index++)
        'wave6-layout-$index': 1,
    },
  );
}

void _expectInsideViewport(WidgetTester tester, Key key, Size viewport) {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  final rect = tester.getRect(finder);
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(viewport.width));
  expect(rect.bottom, lessThanOrEqualTo(viewport.height));
}
