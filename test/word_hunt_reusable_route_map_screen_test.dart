import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const progressThroughSeven = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'baslangic-1': 3,
      'baslangic-2': 3,
      'baslangic-3': 3,
      'baslangic-4': 3,
      'baslangic-5': 3,
      'baslangic-6': 3,
      'baslangic-7': 3,
    },
  );

  const progressThroughEight = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'baslangic-1': 3,
      'baslangic-2': 3,
      'baslangic-3': 3,
      'baslangic-4': 3,
      'baslangic-5': 3,
      'baslangic-6': 3,
      'baslangic-7': 3,
      'baslangic-8': 3,
    },
  );

  const progressThroughNine = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'baslangic-1': 3,
      'baslangic-2': 3,
      'baslangic-3': 3,
      'baslangic-4': 3,
      'baslangic-5': 3,
      'baslangic-6': 3,
      'baslangic-7': 3,
      'baslangic-8': 3,
      'baslangic-9': 3,
    },
  );

  test('reusable map owns exactly one normalized ten-stop geometry', () {
    expect(WordHuntRouteMapGeometry.normalizedStops, hasLength(10));

    for (final point in WordHuntRouteMapGeometry.normalizedStops) {
      expect(point.dx, inInclusiveRange(0.15, 0.85));
      expect(point.dy, inInclusiveRange(0.08, 0.92));
    }
  });

  test('geometry scales proportionally instead of using device pixels', () {
    const small = Size(320, 640);
    const large = Size(640, 1280);

    final smallPoints = WordHuntRouteMapGeometry.pointsFor(small);
    final largePoints = WordHuntRouteMapGeometry.pointsFor(large);

    for (var index = 0; index < 10; index++) {
      expect(largePoints[index].dx, closeTo(smallPoints[index].dx * 2, 0.001));
      expect(largePoints[index].dy, closeTo(smallPoints[index].dy * 2, 0.001));
    }
  });

  test('level eight is normal on both existing routes', () {
    expect(
      WordHuntStarterContent.baslangicLimani.levels[7].type,
      WordHuntLevelType.normal,
    );
    expect(
      WordHuntGokyuzuContent.gokyuzuAdalari.levels[7].type,
      WordHuntLevelType.normal,
    );
  });

  test('route geometry stays sequential through levels 7, 8, 9 and 10', () {
    expect(WordHuntRouteMapGeometry.connections, contains((7, 8)));
    expect(WordHuntRouteMapGeometry.connections, contains((8, 9)));
    expect(WordHuntRouteMapGeometry.connections, isNot(contains((7, 9))));
    expect(WordHuntRouteMapGeometry.connections, contains((9, 10)));
  });

  test('sequential 7-8-9-10 progression works for a future route id', () {
    final futureRoute = WordHuntRouteDefinition(
      id: 'orman-yolu-proof',
      title: 'Orman Yolu Proof',
      theme: 'orman',
      unlockStarsRequired: 18,
      levels: WordHuntStarterContent.baslangicLimani.levels,
      routeRewardId: 'proof-only',
    );

    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(
        futureRoute,
        progressThroughSeven,
        8,
      ),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(
        futureRoute,
        progressThroughSeven,
        9,
      ),
      isFalse,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(
        futureRoute,
        progressThroughEight,
        9,
      ),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(
        futureRoute,
        progressThroughEight,
        10,
      ),
      isFalse,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(
        futureRoute,
        progressThroughNine,
        10,
      ),
      isTrue,
    );
  });

  test('proof themes are visually distinct but cannot carry geometry', () {
    const themes = <WordHuntRouteMapTheme>[
      WordHuntRouteMapTheme.harborProof,
      WordHuntRouteMapTheme.skyProof,
      WordHuntRouteMapTheme.forestProof,
    ];

    expect(themes.map((theme) => theme.id).toSet(), hasLength(3));
    expect(themes.map((theme) => theme.backgroundColor).toSet(), hasLength(3));
    expect(themes.map((theme) => theme.nodeColor).toSet(), hasLength(3));
  });

  testWidgets('three themes render the same ten node positions', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<List<Offset>> renderAndReadCenters(
      WordHuntRouteMapTheme theme,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntReusableRouteMapScreen(
            route: WordHuntStarterContent.baslangicLimani,
            theme: theme,
            progress: progressThroughSeven,
          ),
        ),
      );
      await tester.pump();

      return <Offset>[
        for (var index = 1; index <= 10; index++)
          tester.getCenter(find.byKey(Key('word_hunt_reusable_level_$index'))),
      ];
    }

    final harbor = await renderAndReadCenters(
      WordHuntRouteMapTheme.harborProof,
    );
    final sky = await renderAndReadCenters(WordHuntRouteMapTheme.skyProof);
    final forest = await renderAndReadCenters(
      WordHuntRouteMapTheme.forestProof,
    );

    expect(sky, harbor);
    expect(forest, harbor);
  });

  testWidgets('skeleton exposes path, ten nodes and start/end labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntReusableRouteMapScreen(
          route: WordHuntStarterContent.baslangicLimani,
          theme: WordHuntRouteMapTheme.forestProof,
          progress: progressThroughSeven,
        ),
      ),
    );

    expect(find.byKey(const Key('word_hunt_reusable_route_path')), findsOneWidget);
    expect(find.text('BAŞLANGIÇ'), findsOneWidget);
    expect(find.text('BİTİŞ'), findsOneWidget);

    for (var index = 1; index <= 10; index++) {
      expect(find.byKey(Key('word_hunt_reusable_level_$index')), findsOneWidget);
    }
  });

  testWidgets('progression stays sequential without route-specific layout', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntReusableRouteMapScreen(
          route: WordHuntStarterContent.baslangicLimani,
          theme: WordHuntRouteMapTheme.harborProof,
          progress: progressThroughSeven,
          onLevelTap: (index) => tapped = index,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('word_hunt_reusable_level_8')));
    await tester.pump();
    expect(tapped, 8);

    tapped = 0;
    await tester.tap(
      find.byKey(const Key('word_hunt_reusable_level_9')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tapped, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntReusableRouteMapScreen(
          route: WordHuntStarterContent.baslangicLimani,
          theme: WordHuntRouteMapTheme.harborProof,
          progress: progressThroughEight,
          onLevelTap: (index) => tapped = index,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('word_hunt_reusable_level_9')));
    await tester.pump();
    expect(tapped, 9);

    tapped = 0;
    await tester.tap(
      find.byKey(const Key('word_hunt_reusable_level_10')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tapped, 0);
  });

  testWidgets('skeleton remains overflow-free on a narrow phone surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntReusableRouteMapScreen(
          route: WordHuntStarterContent.baslangicLimani,
          theme: WordHuntRouteMapTheme.skyProof,
          progress: progressThroughSeven,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('word_hunt_reusable_route_map')), findsOneWidget);
  });
}
