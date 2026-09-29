import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_harbor_segment_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_progress.dart';
import 'package:word_hunt_flutter_feature/word_hunt_reference_route_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_star_visuals.dart';

import 'package:kelime_avi_standalone/harbor_visual_proof_main.dart'
    as harbor_proof;

const _segment2LayoutAsset =
    'assets/word_hunt/harbor_segments/segment_02_ui/layout_schema_v2.json';

WordHuntProgressSnapshot _through(int count) => WordHuntProgressSnapshot(
  bestStarsByLevelId: <String, int>{
    for (var index = 1; index <= count; index++)
      'baslangic-$index': index % 3 + 1,
  },
);

Future<void> _pumpHarborProof(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  rootBundle.evict(_segment2LayoutAsset);
  await tester.pumpWidget(
    harbor_proof.buildHarborVisualProofApp(key: UniqueKey()),
  );
  await _pumpUntilVisible(
    tester,
    find.byKey(const Key('word_hunt_harbor_level_20')),
    description: 'Harbor proof Segment 2',
  );
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  required String description,
}) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    if (find
        .byKey(const Key('word_hunt_harbor_layout_error_2'))
        .evaluate()
        .isNotEmpty) {
      fail('$description reached the Segment 2 layout error state');
    }
    if (find
        .byKey(const Key('word_hunt_harbor_identity_error_2'))
        .evaluate()
        .isNotEmpty) {
      fail('$description reached the Segment 2 identity error state');
    }
  }
  fail('$description did not reach its expected terminal widget');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'approved clean scenes are bundled without baked mockup overlays',
    () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      for (final entry in <String, int>{
        WordHuntHarborSegmentArt.segment2: 100000,
        WordHuntHarborSegmentArt.segment3: 100000,
        'assets/word_hunt/harbor_segments/segment_02_ui/layout_schema_v2.json':
            1000,
        'assets/word_hunt/harbor_segments/segment_02_ui/medallion_blank.png':
            100000,
        'assets/word_hunt/harbor_segments/segment_02_ui/locked_medallion.png':
            100000,
        'assets/word_hunt/harbor_segments/segment_02_ui/star_socket_blank.png':
            100000,
        'assets/word_hunt/harbor_segments/segment_02_ui/challenge_combined_blank.png':
            100000,
        'assets/word_hunt/harbor_segments/segment_02_ui/hanging_lantern.png':
            100000,
      }.entries) {
        final path = entry.key;
        expect(manifest.listAssets(), contains(path));
        expect(
          (await rootBundle.load(path)).lengthInBytes,
          greaterThan(entry.value),
        );
      }
      expect(WordHuntHarborSegmentArt.segment2Centers, hasLength(10));
      expect(WordHuntHarborSegmentArt.segment3Centers, hasLength(10));
      expect(
        WordHuntHarborSegmentArt.segment2Centers,
        isNot(WordHuntHarborSegmentArt.segment3Centers),
      );
    },
  );

  testWidgets('Segment 1 continues to use the byte-locked MASTER ART', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: WordHuntReferenceRouteScreen()),
    );
    expect(
      find.byKey(const Key('word_hunt_pixel_proof_master_art')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('word_hunt_harbor_scene_2')), findsNothing);
  });

  for (final (segment, start, end) in <(int, int, int)>[(3, 21, 30)]) {
    testWidgets(
      'Segment $segment: clean art, true IDs, challenge and tap sizes',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final progress = _through(end - 1);
        final tapped = <int>[];
        await tester.pumpWidget(
          MaterialApp(
            home: WordHuntReferenceRouteScreen(
              progress: progress,
              segmentIndex: segment,
              onLevelTap: tapped.add,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(Key('word_hunt_harbor_scene_asset_$segment')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('word_hunt_reference_background_fallback')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('word_hunt_harbor_missing_asset')),
          findsNothing,
        );
        for (var level = start; level <= end; level++) {
          expect(
            find.byKey(Key('word_hunt_harbor_level_$level')),
            findsOneWidget,
          );
          expect(
            tester
                .widget<Text>(find.byKey(Key('word_hunt_harbor_number_$level')))
                .data,
            '$level',
          );
          final hitbox = tester.getSize(
            find.byKey(Key('word_hunt_harbor_level_$level')),
          );
          expect(hitbox.width, greaterThanOrEqualTo(48));
          expect(hitbox.height, greaterThanOrEqualTo(48));
        }
        expect(find.text('MEYDAN OKUMA'), findsOneWidget);
        expect(find.text('ROTA FİNALİ'), findsNothing);
        await tester.tap(find.byKey(Key('word_hunt_harbor_level_$end')));
        expect(tapped, <int>[end]);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'proof entrypoint toggles deterministic mixed and L20-playable snapshots',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pumpHarborProof(tester, const Size(360, 800));

        for (var level = 11; level <= 20; level++) {
          expect(
            find.byKey(Key('word_hunt_harbor_level_$level')),
            findsOneWidget,
          );
          expect(
            tester.getSize(find.byKey(Key('word_hunt_harbor_level_$level'))),
            const Size(68, 68),
          );
        }
        expect(
          find.bySemanticsLabel(RegExp(r'Bölüm 11, açık, 1 yıldız')),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(RegExp(r'Bölüm 12, açık, 2 yıldız')),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(RegExp(r'Bölüm 13, açık, 3 yıldız')),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(RegExp(r'Bölüm 15, açık, 0 yıldız')),
          findsOneWidget,
        );
        for (var level = 16; level <= 20; level++) {
          expect(
            find.bySemanticsLabel(RegExp('Bölüm $level,.*kilitli, 0 yıldız')),
            findsOneWidget,
          );
          expect(
            find.byKey(Key('word_hunt_harbor_number_$level')),
            findsNothing,
          );
          expect(
            find.byKey(Key('word_hunt_harbor_star_backplate_$level')),
            findsNothing,
          );
        }
        expect(
          find.byKey(const Key('word_hunt_harbor_challenge_20')),
          findsNothing,
        );

        await tester.tap(find.byKey(const Key('word_hunt_harbor_info')));
        await _pumpUntilVisible(
          tester,
          find.byKey(const Key('word_hunt_harbor_challenge_20')),
          description: 'L20-playable proof scenario',
        );

        expect(
          find.bySemanticsLabel(
            RegExp(r'Bölüm 20, meydan okuma, açık, 0 yıldız'),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('word_hunt_harbor_number_20')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('word_hunt_harbor_challenge_20')),
          findsOneWidget,
        );
        expect(find.text('Meydan Okuma'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  for (final (width, height) in <(int, int)>[(360, 800), (412, 915)]) {
    testWidgets(
      'premium Segment 2 proof geometry is visible at ${width}x$height',
      (tester) async {
        await _pumpHarborProof(
          tester,
          Size(width.toDouble(), height.toDouble()),
        );
        await tester.tap(find.byKey(const Key('word_hunt_harbor_info')));
        await _pumpUntilVisible(
          tester,
          find.byKey(const Key('word_hunt_harbor_challenge_20')),
          description: 'L20-playable geometry scenario',
        );

        final scene = tester.getRect(
          find.byKey(const Key('word_hunt_harbor_scene_2')),
        );
        final hitboxFinder = find.byKey(const Key('word_hunt_harbor_level_20'));
        final hitbox = tester.getRect(hitboxFinder);
        final medallion = tester.getRect(
          find.byKey(const Key('word_hunt_harbor_medallion_20')),
        );
        final plaque = tester.getRect(
          find.byKey(const Key('word_hunt_harbor_challenge_20')),
        );
        expect(tester.getSize(hitboxFinder), const Size(68, 68));
        expect(plaque.top, greaterThanOrEqualTo(hitbox.bottom));
        expect((plaque.center.dx - hitbox.center.dx).abs(), lessThan(0.01));
        expect((medallion.center.dx - hitbox.center.dx).abs(), lessThan(0.01));
        for (final rect in <Rect>[hitbox, medallion, plaque]) {
          expect(rect.left, greaterThanOrEqualTo(scene.left));
          expect(rect.top, greaterThanOrEqualTo(scene.top));
          expect(rect.right, lessThanOrEqualTo(scene.right));
          expect(rect.bottom, lessThanOrEqualTo(scene.bottom));
        }
        for (var level = 11; level < 20; level++) {
          final other = tester.getRect(
            find.byKey(Key('word_hunt_harbor_level_$level')),
          );
          expect(plaque.overlaps(other), isFalse, reason: 'L20/L$level');
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  // Same four physical-size contracts, extended to *every* node and neighbor
  // pair. No skipping/compressing stars or touch targets to obtain a PASS.
  for (final (segment, start, end, completed) in <(int, int, int, int)>[
    (3, 21, 30, 29),
  ]) {
    for (final (width, height) in <(int, int)>[(360, 800), (412, 915)]) {
      testWidgets('Segment $segment: full composition at ${width}x$height', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width.toDouble(), height.toDouble());
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final tapped = <int>[];
        await tester.pumpWidget(
          MaterialApp(
            home: WordHuntReferenceRouteScreen(
              progress: _through(completed),
              segmentIndex: segment,
              onBack: () {},
              onInfo: () {},
              onLevelTap: tapped.add,
              onSegmentSelect: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        const epsilon = 1e-6;
        final scene = tester.getRect(
          find.byKey(Key('word_hunt_harbor_scene_$segment')),
        );
        final sourceImage = tester.getRect(
          find.byKey(Key('word_hunt_harbor_scene_asset_$segment')),
        );
        final source = WordHuntHarborSegmentArt.sourceSize;
        final scale = sourceImage.width / source.width;
        final centers = WordHuntHarborSegmentArt.centersFor(segment);
        expect(centers, hasLength(10));
        expect(
          tester.getRect(find.byKey(Key('word_hunt_harbor_path_$segment'))),
          scene,
        );
        expect(
          find.byKey(const Key('word_hunt_harbor_missing_asset')),
          findsNothing,
        );

        final hitboxes = <int, Rect>{};
        final rings = <int, Rect>{};
        final starPlates = <int, Rect>{};
        for (var level = start; level <= end; level++) {
          final hitFinder = find.byKey(Key('word_hunt_harbor_level_$level'));
          final ringFinder = find.byKey(
            Key('word_hunt_harbor_medallion_$level'),
          );
          final starFinder = find.byKey(
            Key('word_hunt_harbor_star_backplate_$level'),
          );
          final hit = tester.getRect(hitFinder);
          final ring = tester.getRect(ringFinder);
          final plate = tester.getRect(starFinder);
          hitboxes[level] = hit;
          rings[level] = ring;
          starPlates[level] = plate;
          expect(
            tester.getSize(hitFinder),
            const Size(
              WordHuntHarborNodeGeometry.hitboxSize,
              WordHuntHarborNodeGeometry.hitboxSize,
            ),
          );
          expect(hit.width, greaterThanOrEqualTo(48));
          expect(hit.height, greaterThanOrEqualTo(48));
          expect(tester.getSize(ringFinder), const Size(54, 54));
          expect((ring.width - 54).abs(), lessThan(epsilon));
          expect((ring.height - 54).abs(), lessThan(epsilon));
          expect(plate.width, greaterThanOrEqualTo(45));
          expect(plate.height, greaterThanOrEqualTo(15));
          expect(
            (ring.center - hit.center).distance,
            lessThan(epsilon),
            reason: 'L$level visual and touch centers',
          );
          expect(
            (plate.center.dx - ring.center.dx).abs(),
            lessThan(epsilon),
            reason: 'L$level centered star anchor',
          );
          expect(
            (plate.top - ring.bottom - 7).abs(),
            lessThan(epsilon),
            reason: 'L$level constant ring-to-stars gap',
          );
          for (final rect in <Rect>[hit, ring, plate]) {
            expect(
              rect.left,
              greaterThanOrEqualTo(scene.left - epsilon),
              reason: 'L$level left scene edge',
            );
            expect(
              rect.top,
              greaterThanOrEqualTo(scene.top - epsilon),
              reason: 'L$level top scene edge',
            );
            expect(
              rect.right,
              lessThanOrEqualTo(scene.right + epsilon),
              reason: 'L$level right scene edge',
            );
            expect(
              rect.bottom,
              lessThanOrEqualTo(scene.bottom + epsilon),
              reason: 'L$level bottom scene edge',
            );
          }
          expect(
            tester
                .widget<Text>(find.byKey(Key('word_hunt_harbor_number_$level')))
                .data,
            '$level',
          );
          for (var i = 0; i < 3; i++) {
            expect(
              find.byKey(Key('word_hunt_harbor_star_${level}_$i')),
              findsOneWidget,
            );
          }
          final original = centers[level - start];
          final routeCenter = Offset(
            sourceImage.left + original.dx * scale,
            sourceImage.top + original.dy * scale,
          );
          expect(
            (ring.center - routeCenter).distance,
            lessThan(0.5),
            reason: 'L$level scene/path projection',
          );
          debugPrint(
            'Harbor S$segment ${width}x$height L$level '
            'hit=$hit ring=$ring stars=$plate',
          );
        }

        final tagFinder = find.byKey(Key('word_hunt_harbor_challenge_$end'));
        expect(tagFinder, findsOneWidget);
        final tag = tester.getRect(tagFinder);
        expect(find.text('MEYDAN OKUMA'), findsOneWidget);
        expect(find.text('ROTA FİNALİ'), findsNothing);
        expect(
          (tag.center.dx - rings[end]!.center.dx).abs(),
          lessThan(epsilon),
          reason: 'L$end badge uses node center',
        );
        expect(
          (tag.top - starPlates[end]!.bottom - 9).abs(),
          lessThan(epsilon),
          reason: 'L$end badge clear of stars',
        );
        expect(tester.getSize(tagFinder), const Size(132, 22));
        expect(tag.left, greaterThanOrEqualTo(scene.left - epsilon));
        expect(tag.right, lessThanOrEqualTo(scene.right + epsilon));
        expect(tag.bottom, lessThanOrEqualTo(scene.bottom + epsilon));

        // Check all 45 distinct node pairs, not only the originally reported
        // L13/14 and L23/24 pairs. No cross-node touch/visual envelope overlap.
        for (var first = start; first <= end; first++) {
          for (var second = first + 1; second <= end; second++) {
            final firstRects = <Rect>[
              hitboxes[first]!,
              rings[first]!,
              starPlates[first]!,
              if (first == end) tag,
            ];
            final secondRects = <Rect>[
              hitboxes[second]!,
              rings[second]!,
              starPlates[second]!,
              if (second == end) tag,
            ];
            for (final a in firstRects) {
              for (final b in secondRects) {
                expect(
                  a.overlaps(b),
                  isFalse,
                  reason:
                      'L$first/L$second collision at ${width}x$height '
                      '($a vs $b)',
                );
              }
            }
          }
        }

        // Test the exact construction endpoints against the node projection,
        // *not* against PathMetric's approximate tangent interpolation. The
        // production path uses connectionEndpoints for moveTo/cubicTo.
        // Separately, ensure raster-space sampling remains subpixel-accurate.
        // 1/256 logical px is a fixed visual precision bound, not a retry of
        // the previous 1e-6/1e-5 double-equality tolerances.
        const pathMetricSamplingSubpixelBound = 1 / 256;
        // The painted cubic is shared with production. Sample every
        // connection against every ring, star backplate and challenge badge.
        // This prevents a future layout change from routing through labels.
        for (var first = start; first < end; first++) {
          final a = rings[first]!.center;
          final b = rings[first + 1]!.center;
          final direction = b.dx >= a.dx ? 1.0 : -1.0;
          final expectedStart = a + Offset(direction * 31, -6);
          final expectedEnd = b + Offset(-direction * 31, -6);
          final (definedStart, definedEnd) =
              WordHuntHarborNodeGeometry.connectionEndpoints(a, b);
          expect(
            definedStart,
            expectedStart,
            reason: 'L$first exact construction start',
          );
          expect(
            definedEnd,
            expectedEnd,
            reason: 'L$first exact construction end',
          );

          final metric = WordHuntHarborNodeGeometry.connection(
            a,
            b,
          ).computeMetrics().single;
          expect(
            metric.isClosed,
            isFalse,
            reason: 'L$first connection is not a loop',
          );
          final sampledStart = metric.getTangentForOffset(0)!.position;
          final sampledEnd = metric
              .getTangentForOffset(metric.length)!
              .position;
          expect(
            (sampledStart - definedStart).distance,
            lessThan(pathMetricSamplingSubpixelBound),
            reason: 'L$first approximate PathMetric start, subpixel bound',
          );
          expect(
            (sampledEnd - definedEnd).distance,
            lessThan(pathMetricSamplingSubpixelBound),
            reason: 'L$first approximate PathMetric end, subpixel bound',
          );
          for (var sample = 0; sample <= 40; sample++) {
            final point = metric
                .getTangentForOffset(metric.length * sample / 40)!
                .position;
            for (var level = start; level <= end; level++) {
              expect(
                rings[level]!.inflate(1).contains(point),
                isFalse,
                reason: 'L$first path crosses L$level ring',
              );
              expect(
                starPlates[level]!.inflate(1).contains(point),
                isFalse,
                reason: 'L$first path crosses L$level stars',
              );
            }
            expect(
              tag.inflate(1).contains(point),
              isFalse,
              reason: 'L$first path crosses challenge badge',
            );
          }
        }

        final viewport = Rect.fromLTWH(
          0,
          0,
          width.toDouble(),
          height.toDouble(),
        );
        final safePadding = MediaQuery.paddingOf(
          tester.element(
            find.byKey(Key('word_hunt_harbor_segment_screen_$segment')),
          ),
        );
        final safeViewport = Rect.fromLTRB(
          viewport.left + safePadding.left,
          viewport.top + safePadding.top,
          viewport.right - safePadding.right,
          viewport.bottom - safePadding.bottom,
        );
        for (final key in <String>[
          'word_hunt_harbor_back',
          'word_hunt_harbor_info',
          'word_hunt_harbor_segment_navigation',
        ]) {
          final rect = tester.getRect(find.byKey(Key(key)));
          expect(
            rect.left,
            greaterThanOrEqualTo(safeViewport.left - epsilon),
            reason: key,
          );
          expect(
            rect.top,
            greaterThanOrEqualTo(safeViewport.top - epsilon),
            reason: key,
          );
          expect(
            rect.right,
            lessThanOrEqualTo(safeViewport.right + epsilon),
            reason: key,
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(safeViewport.bottom + epsilon),
            reason: key,
          );
        }
        for (var level = start; level <= end; level++) {
          await tester.tap(find.byKey(Key('word_hunt_harbor_level_$level')));
        }
        expect(
          tapped,
          List<int>.generate(10, (index) => start + index),
          reason: 'Every level retains its own independent touch callback',
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('0/1/2/3 stars are visually distinct with canonical palette', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              WordHuntProgressStars(earned: 0, keyPrefix: 's0_'),
              WordHuntProgressStars(earned: 1, keyPrefix: 's1_'),
              WordHuntProgressStars(earned: 2, keyPrefix: 's2_'),
              WordHuntProgressStars(earned: 3, keyPrefix: 's3_'),
            ],
          ),
        ),
      ),
    );
    for (var earned = 0; earned <= 3; earned++) {
      for (var index = 0; index < 3; index++) {
        final icon = tester.widget<Icon>(find.byKey(Key('s${earned}_$index')));
        expect(
          icon.color,
          index < earned
              ? WordHuntStarVisuals.filled
              : WordHuntStarVisuals.empty,
        );
        expect(
          icon.icon,
          index < earned ? Icons.star_rounded : Icons.star_outline_rounded,
        );
      }
    }
  });

  testWidgets('history navigation and replay preserve persisted stars', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final progress = _through(29);
    final seen = <int>[];
    var selected = 3;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => WordHuntReferenceRouteScreen(
            progress: progress,
            segmentIndex: selected,
            onSegmentSelect: (index) => setState(() => selected = index),
            onLevelTap: seen.add,
          ),
        ),
      ),
    );
    await _pumpUntilVisible(
      tester,
      find.byKey(const Key('word_hunt_harbor_level_30')),
      description: 'initial Segment 3 history view',
    );
    expect(selected, 3);
    rootBundle.evict(_segment2LayoutAsset);
    await tester.tap(find.byKey(const Key('word_hunt_harbor_segment_2')));
    await _pumpUntilVisible(
      tester,
      find.byKey(const Key('word_hunt_harbor_level_12')),
      description: 'Segment 2 history view',
    );
    expect(selected, 2);
    await tester.tap(find.byKey(const Key('word_hunt_harbor_level_12')));
    expect(seen, <int>[12]);
    expect(progress.starsFor('baslangic-12'), 1);
    await tester.tap(find.byKey(const Key('word_hunt_harbor_segment_3')));
    await _pumpUntilVisible(
      tester,
      find.byKey(const Key('word_hunt_harbor_level_30')),
      description: 'replayed Segment 3 history view',
    );
    expect(selected, 3);
    expect(progress.starsFor('baslangic-29'), 3);
    expect(find.byKey(const Key('word_hunt_harbor_level_30')), findsOneWidget);
    expect(find.text('ROTA FİNALİ'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
