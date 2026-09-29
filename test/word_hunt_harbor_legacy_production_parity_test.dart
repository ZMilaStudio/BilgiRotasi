import 'dart:convert';
import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_harbor_layout_manifest.dart';
import 'package:word_hunt_flutter_feature/word_hunt_harbor_segment_screen.dart';

import '../tools/word_hunt_harbor_asset_verifier.dart';

void main() {
  final baseline =
      jsonDecode(
            File(
              'test/fixtures/harbor/legacy_production_parity_baseline.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  test(
    'baseline is explicitly legacy technical evidence, not design approval',
    () {
      expect(baseline['recordType'], 'LEGACY_PRODUCTION_PARITY_BASELINE');
      expect(baseline['visualApproval'], isFalse);
      expect(baseline['baselinePurpose'], contains('not visual approval'));
      expect(baseline['progressSample'], contains('not captured'));
    },
  );

  test(
    'baseline node centers and segment identity match production constants',
    () {
      final source = baseline['source'] as Map<String, dynamic>;
      final segments = source['segments'] as Map<String, dynamic>;
      expect(
        <double>[
          WordHuntHarborSegmentArt.sourceSize.width,
          WordHuntHarborSegmentArt.sourceSize.height,
        ],
        <double>[941, 1672],
      );

      for (final segment in <int>[2, 3]) {
        final record = segments['$segment'] as Map<String, dynamic>;
        final actualCenters =
            WordHuntHarborSegmentArt.centersFor(
              segment,
            ).map((offset) => <double>[offset.dx, offset.dy]).toList();
        final expectedCenters =
            (record['nodeCentersScenePx'] as List)
                .map(
                  (point) =>
                      (point as List)
                          .map((value) => (value as num).toDouble())
                          .toList(),
                )
                .toList();
        expect(
          actualCenters,
          expectedCenters,
          reason: 'Segment $segment scene centers',
        );

        final firstLevel = segment == 2 ? 11 : 21;
        expect(
          record['levelIds'],
          List<String>.generate(
            10,
            (index) => 'baslangic-${firstLevel + index}',
          ),
        );
      }
    },
  );

  test(
    'approved Segment 2/3 asset bytes match the recorded SHA-256 values',
    () async {
      final segments =
          (baseline['source'] as Map<String, dynamic>)['segments']
              as Map<String, dynamic>;
      for (final segment in <int>[2, 3]) {
        final record = segments['$segment'] as Map<String, dynamic>;
        final metadata = await HarborSceneAssetByteVerifier.resolveFile(
          repositoryRoot: Directory.current.path,
          assetPath: record['assetPath'] as String,
        );
        expect(metadata, isNotNull, reason: 'Segment $segment asset byte hash');
        expect(metadata!.sha256, record['sha256']);
        expect(metadata.width, 941);
        expect(metadata.height, 1672);
      }
    },
  );

  test(
    'recorded cover transforms match the two deterministic map viewports',
    () {
      final viewportContract =
          baseline['viewportContract'] as Map<String, dynamic>;
      final records = viewportContract['expected'] as List;
      for (final entry in records.cast<Map<String, dynamic>>()) {
        final screen = (entry['screen'] as List).cast<num>();
        final mapViewport = (entry['mapViewport'] as List).cast<num>();
        final transform = HarborLayoutManifest.sceneToViewportTransform(
          sceneWidth: 941,
          sceneHeight: 1672,
          viewportWidth: mapViewport[0].toDouble(),
          viewportHeight: mapViewport[1].toDouble(),
        );
        expect(
          screen[1] - viewportContract['headerHeightLogicalDp'],
          mapViewport[1],
        );
        expect(
          transform.scale,
          closeTo((entry['scale'] as num).toDouble(), 1e-12),
        );
        final expectedTranslation = (entry['translation'] as List).cast<num>();
        expect(
          transform.translationX,
          closeTo(expectedTranslation[0].toDouble(), 1e-9),
        );
        expect(
          transform.translationY,
          closeTo(expectedTranslation[1].toDouble(), 1e-9),
        );
      }
    },
  );

  testWidgets(
    'unchanged Segment 3 retains legacy node, hitbox and badge parity',
    (tester) async {
      final viewportContract =
          baseline['viewportContract'] as Map<String, dynamic>;
      final viewportRecords =
          (viewportContract['expected'] as List).cast<Map<String, dynamic>>();
      final segmentRecords =
          ((baseline['source'] as Map<String, dynamic>)['segments']
              as Map<String, dynamic>);
      final route = WordHuntRouteCatalog.starter.route;

      tester.view.devicePixelRatio = 1;
      for (final viewportRecord in viewportRecords) {
        final screen = (viewportRecord['screen'] as List).cast<num>();
        final screenSize = Size(screen[0].toDouble(), screen[1].toDouble());
        tester.view.physicalSize = screenSize;

        // Segment 2 now has explicit schema-v2 geometry and a dedicated
        // integration test. This fixture remains historical parity evidence;
        // only unchanged Segment 3 still uses the legacy renderer.
        for (final segment in <int>[3]) {
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: screenSize,
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                ),
                child: WordHuntHarborSegmentScreen(
                  route: route,
                  progress: const WordHuntProgressSnapshot(),
                  segmentIndex: segment,
                  furthestAccessibleSegment: 3,
                ),
              ),
            ),
          );
          await tester.pump();

          final sceneRect = tester.getRect(
            find.byKey(Key('word_hunt_harbor_scene_$segment')),
          );
          final expectedMapViewport =
              (viewportRecord['mapViewport'] as List).cast<num>();
          expect(sceneRect.width, expectedMapViewport[0].toDouble());
          expect(sceneRect.height, expectedMapViewport[1].toDouble());

          final transform = HarborLayoutManifest.sceneToViewportTransform(
            sceneWidth: 941,
            sceneHeight: 1672,
            viewportWidth: expectedMapViewport[0].toDouble(),
            viewportHeight: expectedMapViewport[1].toDouble(),
          );
          final record = segmentRecords['$segment'] as Map<String, dynamic>;
          final centers = (record['nodeCentersScenePx'] as List).cast<List>();
          final firstLevel = segment == 2 ? 11 : 21;

          for (var localIndex = 0; localIndex < 10; localIndex++) {
            final level = firstLevel + localIndex;
            final sceneCenter = centers[localIndex].cast<num>();
            final projectedCenter = transform.projectScene(
              HarborLayoutPoint(
                sceneCenter[0].toDouble(),
                sceneCenter[1].toDouble(),
                HarborLayoutCoordinateUnit.scenePixels,
              ),
            );
            final expectedCenter = Offset(
              projectedCenter.x,
              (viewportContract['headerHeightLogicalDp'] as num) +
                  projectedCenter.y,
            );
            final hitbox = tester.getRect(
              find.byKey(Key('word_hunt_harbor_level_$level')),
            );
            expect(hitbox.center.dx, closeTo(expectedCenter.dx, 1e-6));
            expect(hitbox.center.dy, closeTo(expectedCenter.dy, 1e-6));
            expect(hitbox.width, closeTo(68, 1e-9));
            expect(hitbox.height, closeTo(68, 1e-9));

            final ring = tester.getRect(
              find.byKey(Key('word_hunt_harbor_medallion_$level')),
            );
            expect(ring.center.dx, closeTo(expectedCenter.dx, 1e-6));
            expect(ring.center.dy, closeTo(expectedCenter.dy, 1e-6));
            expect(ring.width, closeTo(54, 1e-9));
            expect(ring.height, closeTo(54, 1e-9));

            final stars = tester.getRect(
              find.byKey(Key('word_hunt_harbor_star_backplate_$level')),
            );
            expect(stars.center.dx, closeTo(expectedCenter.dx, 1e-6));
            expect(stars.top, closeTo(expectedCenter.dy + 34, 1e-6));
            expect(stars.width, closeTo(49, 1e-9));
            expect(stars.height, closeTo(17, 1e-9));

            final challenge = find.byKey(
              Key('word_hunt_harbor_challenge_$level'),
            );
            final shouldShowChallenge = level == 30;
            expect(
              challenge,
              shouldShowChallenge ? findsOneWidget : findsNothing,
            );
            if (shouldShowChallenge) {
              final badge = tester.getRect(challenge);
              expect(badge.center.dx, closeTo(expectedCenter.dx, 1e-6));
              expect(badge.top, closeTo(expectedCenter.dy + 60, 1e-6));
              expect(badge.width, closeTo(132, 1e-9));
              expect(badge.height, closeTo(22, 1e-9));
            }
          }
          expect(tester.takeException(), isNull);
        }
      }
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  test(
    'legacy route endpoints and curve formula match the recorded renderer',
    () {
      final curve = baseline['routeCurve'] as Map<String, dynamic>;
      final source = File(
        'packages/word_hunt_flutter_feature/lib/word_hunt_harbor_segment_screen.dart',
      ).readAsStringSync().replaceAll(RegExp(r'\s+'), ' ');
      expect(curve['control1FromStartAndDelta'], <String>[
        'start.x + delta.x * 0.36',
        'start.y + delta.y * 0.13 - 5',
      ]);
      expect(curve['control2FromStartAndEnd'], <String>[
        'start.x + delta.x * 0.64',
        'end.y - delta.y * 0.13 - 8',
      ]);
      expect(source, contains('start.dx + delta.dx * 0.36'));
      expect(source, contains('start.dy + delta.dy * 0.13 - 5'));
      expect(source, contains('start.dx + delta.dx * 0.64'));
      expect(source, contains('finish.dy - delta.dy * 0.13 - 8'));

      final geometry = baseline['nodeOverlayGeometry'] as Map<String, dynamic>;
      final ringSize =
          ((geometry['ring'] as Map<String, dynamic>)['diameterLogicalDp']
                  as num)
              .toDouble();
      final hitboxSize =
          ((geometry['hitbox'] as Map<String, dynamic>)['sizeLogicalDp']
                      as List)
                  .first
              as num;
      expect(WordHuntHarborNodeGeometry.ringSize, ringSize);
      expect(WordHuntHarborNodeGeometry.hitboxSize, hitboxSize.toDouble());

      final segmentRecords =
          ((baseline['source'] as Map<String, dynamic>)['segments']
              as Map<String, dynamic>);
      for (final viewportRecord
          in (baseline['viewportContract'] as Map<String, dynamic>)['expected']
              as List) {
        final view = viewportRecord as Map<String, dynamic>;
        final scale = (view['scale'] as num).toDouble();
        final translationValues = (view['translation'] as List).cast<num>();
        final translation = Offset(
          translationValues[0].toDouble(),
          translationValues[1].toDouble(),
        );
        for (final segment in <int>[2, 3]) {
          final centers =
              (segmentRecords['$segment']
                      as Map<String, dynamic>)['nodeCentersScenePx']
                  as List;
          final projected =
              centers.map((point) {
                final coordinates = (point as List).cast<num>();
                return translation +
                    Offset(
                          coordinates[0].toDouble(),
                          coordinates[1].toDouble(),
                        ) *
                        scale;
              }).toList();
          expect(projected, hasLength(10));
          expect(projected.length - 1, curve['pathCountPerSegment']);
          for (var index = 0; index < projected.length - 1; index++) {
            final from = projected[index];
            final to = projected[index + 1];
            final endpoints = WordHuntHarborNodeGeometry.connectionEndpoints(
              from,
              to,
            );
            final direction = to.dx >= from.dx ? 1.0 : -1.0;
            expect(endpoints.$1.dx, closeTo(from.dx + direction * 31, 1e-9));
            expect(endpoints.$1.dy, closeTo(from.dy - 6, 1e-9));
            expect(endpoints.$2.dx, closeTo(to.dx - direction * 31, 1e-9));
            expect(endpoints.$2.dy, closeTo(to.dy - 6, 1e-9));
          }
        }
      }
    },
  );

  test(
    'typed contract separates fixed logical-dp offsets from scene geometry',
    () {
      final compatibility =
          baseline['manifestCompatibility'] as Map<String, dynamic>;
      expect(compatibility['nodeCentersScenePixels'], contains('exact'));
      expect(
        compatibility['singleStaticScenePixelCopyOfLegacyDpGeometryExactAtBothViewports'],
        isFalse,
      );

      final viewports =
          (baseline['viewportContract'] as Map<String, dynamic>)['expected']
              as List;
      final scales =
          viewports
              .cast<Map<String, dynamic>>()
              .map((entry) => (entry['scale'] as num).toDouble())
              .toList();
      expect(scales[0], isNot(scales[1]));
      expect(31 / scales[0], isNot(closeTo(31 / scales[1], 1e-9)));
      expect(34 / scales[0], isNot(closeTo(34 / scales[1], 1e-9)));
      expect(71 / scales[0], isNot(closeTo(71 / scales[1], 1e-9)));
    },
  );
}
