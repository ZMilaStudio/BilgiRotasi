import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_path_renderer.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('three semantic path specs are supported without route ids', () {
    expect(
      WordHuntPathVisualSpec.ancientWaymarks.family,
      WordHuntPathVisualFamily.ancientWaymarks,
    );
    expect(
      WordHuntPathVisualSpec.ancientWaymarks.material,
      WordHuntPathMaterial.weatheredStone,
    );
    expect(
      WordHuntPathVisualSpec.engineeredSegmented.family,
      WordHuntPathVisualFamily.engineeredSegmented,
    );
    expect(
      WordHuntPathVisualSpec.engineeredSegmented.material,
      WordHuntPathMaterial.carvedStoneCopper,
    );
    expect(
      WordHuntPathVisualSpec.ceremonialAlignment.family,
      WordHuntPathVisualFamily.ceremonialAlignment,
    );
    expect(
      WordHuntPathVisualSpec.ceremonialAlignment.material,
      WordHuntPathMaterial.ceremonialStoneGold,
    );

    final source = File(
      'lib/word_hunt/word_hunt_path_renderer.dart',
    ).readAsStringSync();
    expect(source, isNot(contains('WordHuntRouteMapGeometry')));
    expect(source, isNot(contains('kayip-sehir')));
    expect(source, isNot(contains('yeralti-kralligi')));
    expect(source, isNot(contains('gunes-imparatorlugu')));
  });

  test('canonical topology remains sequential and renderer does not own it', () {
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
    expect(WordHuntRouteMapGeometry.connections, contains((8, 9)));
    expect(WordHuntRouteMapGeometry.connections, contains((9, 10)));
    expect(WordHuntRouteMapGeometry.connections, isNot(contains((8, 10))));
  });

  test('forward and reverse assignment reuse the exact canonical point set', () {
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
    for (var i = 0; i < 10; i++) {
      expect(reverse[i], forward[9 - i]);
    }
    expect(
      WordHuntRouteMapGeometry.connections,
      containsAll(<(int, int)>[(8, 9), (9, 10)]),
    );
    expect(WordHuntRouteMapGeometry.connections, isNot(contains((8, 10))));
  });

  testWidgets('all path families paint supplied segments without topology data', (
    tester,
  ) async {
    const segments = <WordHuntPathSegment>[
      WordHuntPathSegment(
        start: Offset(20, 30),
        end: Offset(120, 100),
        active: true,
      ),
      WordHuntPathSegment(
        start: Offset(120, 100),
        end: Offset(220, 180),
        active: false,
      ),
    ];

    for (final spec in <WordHuntPathVisualSpec>[
      WordHuntPathVisualSpec.ancientWaymarks,
      WordHuntPathVisualSpec.engineeredSegmented,
      WordHuntPathVisualSpec.ceremonialAlignment,
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 260,
            height: 220,
            child: CustomPaint(
              painter: WordHuntPathPainter(
                segments: segments,
                spec: spec,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: spec.id);
    }
  });
}
