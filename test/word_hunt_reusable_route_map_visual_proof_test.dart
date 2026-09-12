import 'dart:io';
import 'dart:ui' as ui;

import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const initialProgress = WordHuntProgressSnapshot();

  testWidgets('reusable map renders identical geometry in three proof themes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const themes = <WordHuntRouteMapTheme>[
      WordHuntRouteMapTheme.harborProof,
      WordHuntRouteMapTheme.skyProof,
      WordHuntRouteMapTheme.forestProof,
    ];

    final centersByTheme = <String, List<Offset>>{};
    final writeEvidence = Platform.environment['CI'] == 'true';
    final reportsDirectory = Directory('reports');
    if (writeEvidence) {
      reportsDirectory.createSync(recursive: true);
    }

    for (final theme in themes) {
      final boundaryKey = Key('reusable-proof-boundary-${theme.id}');
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            key: boundaryKey,
            child: WordHuntReusableRouteMapScreen(
              route: WordHuntStarterContent.baslangicLimani,
              theme: theme,
              progress: initialProgress,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      centersByTheme[theme.id] = <Offset>[
        for (var level = 1; level <= 10; level++)
          tester.getCenter(find.byKey(Key('word_hunt_reusable_level_$level'))),
      ];

      expect(
        find.byKey(const Key('word_hunt_reusable_node_1_current')),
        findsOneWidget,
      );
      for (var level = 2; level <= 10; level++) {
        expect(
          find.byKey(Key('word_hunt_reusable_node_${level}_locked')),
          findsOneWidget,
        );
      }
      expect(find.text('BAŞLANGIÇ'), findsOneWidget);
      expect(find.text('BİTİŞ'), findsOneWidget);
      expect(tester.takeException(), isNull);

      if (writeEvidence) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(boundaryKey),
        );
        expect(boundary.debugNeedsPaint, isFalse);
        final safeTheme = theme.id.replaceAll('-', '_').toUpperCase();
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          try {
            final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
            expect(bytes, isNotNull);
            File(
              'reports/WORD_HUNT_REUSABLE_MAP_WIDGET_$safeTheme.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
          } finally {
            image.dispose();
          }
        });
      }
    }

    expect(centersByTheme['sky-proof'], centersByTheme['harbor-proof']);
    expect(centersByTheme['forest-proof'], centersByTheme['harbor-proof']);

    if (writeEvidence) {
      File('reports/WORD_HUNT_REUSABLE_MAP_WIDGET.txt').writeAsStringSync(
        'EVIDENCE_KIND=FLUTTER_WIDGET_TEST_RENDER\n'
        'DEVICE_SCREENSHOT=NO\n'
        'SURFACE=390x844@1.0\n'
        'THEMES=harbor-proof,sky-proof,forest-proof\n'
        'GEOMETRY=SHARED_NORMALIZED_10_STOP\n'
        'PROGRESSION=1-2-3-4-5-6-7-8-9-10\n'
        'LEVEL_8=NORMAL\n'
        'STATE=LEVEL_1_OPEN_LEVELS_2_TO_10_LOCKED\n',
      );
    }
  });
}
