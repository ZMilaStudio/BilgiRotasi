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

  test('scenic theme tokens cannot alter canonical normalized geometry', () {
    const size = Size(430, 932);
    final canonical = WordHuntRouteMapGeometry.pointsFor(size);

    for (final theme in <WordHuntRouteMapTheme>[
      WordHuntRouteMapTheme.forestProof,
      WordHuntRouteMapTheme.skyProof,
      WordHuntRouteMapTheme.harborProof,
    ]) {
      expect(theme.sceneDepth, inInclusiveRange(0.0, 1.0));
      expect(WordHuntRouteMapGeometry.pointsFor(size), canonical);
    }
  });

  testWidgets('scenic polish keeps node centers and hitboxes identical', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<(List<Offset>, List<Size>)> render(
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

      final centers = <Offset>[];
      final sizes = <Size>[];
      for (var level = 1; level <= 10; level++) {
        final finder = find.byKey(Key('word_hunt_reusable_level_$level'));
        centers.add(tester.getCenter(finder));
        sizes.add(tester.getSize(finder));
      }
      return (centers, sizes);
    }

    final forest = await render(WordHuntRouteMapTheme.forestProof);
    final sky = await render(WordHuntRouteMapTheme.skyProof);
    final harbor = await render(WordHuntRouteMapTheme.harborProof);

    expect(sky.$1, forest.$1);
    expect(harbor.$1, forest.$1);
    expect(sky.$2, forest.$2);
    expect(harbor.$2, forest.$2);
    expect(forest.$2, everyElement(const Size(86, 82)));
  });

  testWidgets('proof progression is visible as 1-7 done 8 current 9-10 locked', (
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
    await tester.pump();

    for (var level = 1; level <= 7; level++) {
      expect(
        find.byKey(Key('word_hunt_reusable_node_${level}_completed')),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(const Key('word_hunt_reusable_node_8_current')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_node_9_locked')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_node_10_locked')),
      findsOneWidget,
    );
  });

  testWidgets('generic atmosphere renders forest and sky on a tall phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final theme in <WordHuntRouteMapTheme>[
      WordHuntRouteMapTheme.forestProof,
      WordHuntRouteMapTheme.skyProof,
    ]) {
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

      expect(
        find.byKey(const Key('word_hunt_reusable_atmosphere_layer')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_reusable_route_path')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
