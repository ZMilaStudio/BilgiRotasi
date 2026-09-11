import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_map_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const forest = WordHuntRouteDecorationSpec(
    kind: WordHuntRouteDecorationKind.forest,
    seed: 20260912,
    count: 18,
  );
  const palette = WordHuntRouteDecorationPalette(
    primary: Color(0xFF4F8D62),
    secondary: Color(0xFF72533A),
    accent: Color(0xFFF3D47A),
  );

  test('same seed creates exactly the same normalized decoration layout', () {
    final first = WordHuntRouteDecorationLayout.generate(
      spec: forest,
      reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
    );
    final second = WordHuntRouteDecorationLayout.generate(
      spec: forest,
      reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
    );

    expect(first, hasLength(18));
    expect(second, hasLength(first.length));
    for (var index = 0; index < first.length; index++) {
      expect(second[index].center, first[index].center);
      expect(second[index].scale, first[index].scale);
      expect(second[index].rotationTurns, first[index].rotationTurns);
    }
  });

  test('decoration kind never carries a separate coordinate layout', () {
    const harbor = WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.harbor,
      seed: 20260912,
      count: 18,
    );
    const sky = WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.sky,
      seed: 20260912,
      count: 18,
    );

    final forestMarks = WordHuntRouteDecorationLayout.generate(
      spec: forest,
      reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
    );
    final harborMarks = WordHuntRouteDecorationLayout.generate(
      spec: harbor,
      reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
    );
    final skyMarks = WordHuntRouteDecorationLayout.generate(
      spec: sky,
      reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
    );

    expect(
      harborMarks.map((mark) => mark.center).toList(),
      forestMarks.map((mark) => mark.center).toList(),
    );
    expect(
      skyMarks.map((mark) => mark.center).toList(),
      forestMarks.map((mark) => mark.center).toList(),
    );
  });

  test('generated marks stay normalized and outside node safe zones', () {
    final marks = WordHuntRouteDecorationLayout.generate(
      spec: forest,
      reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
    );

    for (final mark in marks) {
      expect(mark.center.dx, inInclusiveRange(0.035, 0.965));
      expect(mark.center.dy, inInclusiveRange(0.035, 0.965));
      expect(mark.scale, inInclusiveRange(0.72, 1.28));
      expect(mark.rotationTurns, inInclusiveRange(0.0, 1.0));

      for (final node in WordHuntRouteMapGeometry.normalizedStops) {
        expect((mark.center - node).distance, greaterThanOrEqualTo(0.115));
      }
    }
  });

  test('different seeds create a different layout without touching nodes', () {
    const alternate = WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 99,
      count: 18,
    );

    final first = WordHuntRouteDecorationLayout.generate(
      spec: forest,
      reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
    );
    final second = WordHuntRouteDecorationLayout.generate(
      spec: alternate,
      reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
    );

    expect(
      second.map((mark) => mark.center).toList(),
      isNot(first.map((mark) => mark.center).toList()),
    );
  });

  testWidgets('all motif painters stay exception-free on narrow and tall surfaces', (
    tester,
  ) async {
    const specs = <WordHuntRouteDecorationSpec>[
      WordHuntRouteDecorationSpec(
        kind: WordHuntRouteDecorationKind.forest,
        seed: 20260912,
        count: 18,
      ),
      WordHuntRouteDecorationSpec(
        kind: WordHuntRouteDecorationKind.sky,
        seed: 20260912,
        count: 18,
      ),
      WordHuntRouteDecorationSpec(
        kind: WordHuntRouteDecorationKind.harbor,
        seed: 20260912,
        count: 18,
      ),
    ];
    const sizes = <Size>[
      Size(320, 640),
      Size(430, 932),
    ];

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final spec in specs) {
      for (final size in sizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                painter: WordHuntRouteDecorationPainter(
                  spec: spec,
                  reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
                  palette: palette,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    }
  });
}
