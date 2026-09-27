import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_harbor_segment_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_progress.dart';
import 'package:word_hunt_flutter_feature/word_hunt_reference_route_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_star_visuals.dart';

WordHuntProgressSnapshot _through(int count) => WordHuntProgressSnapshot(
  bestStarsByLevelId: <String, int>{
    for (var index = 1; index <= count; index++)
      'baslangic-$index': index % 3 + 1,
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('approved clean scenes are bundled without baked mockup overlays', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    for (final path in <String>[
      WordHuntHarborSegmentArt.segment2,
      WordHuntHarborSegmentArt.segment3,
    ]) {
      expect(manifest.listAssets(), contains(path));
      expect((await rootBundle.load(path)).lengthInBytes, greaterThan(100000));
    }
    expect(WordHuntHarborSegmentArt.segment2Centers, hasLength(10));
    expect(WordHuntHarborSegmentArt.segment3Centers, hasLength(10));
    expect(WordHuntHarborSegmentArt.segment2Centers,
        isNot(WordHuntHarborSegmentArt.segment3Centers));
  });

  testWidgets('Segment 1 continues to use the byte-locked MASTER ART', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WordHuntReferenceRouteScreen()));
    expect(find.byKey(const Key('word_hunt_pixel_proof_master_art')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_harbor_scene_2')), findsNothing);
  });

  for (final (segment, start, end) in <(int, int, int)>[
    (2, 11, 20), (3, 21, 30),
  ]) {
    testWidgets('Segment $segment: clean art, true IDs, challenge and tap sizes', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final progress = _through(end - 1);
      final tapped = <int>[];
      await tester.pumpWidget(MaterialApp(
        home: WordHuntReferenceRouteScreen(
          progress: progress,
          segmentIndex: segment,
          onLevelTap: tapped.add,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('word_hunt_harbor_scene_asset_$segment')), findsOneWidget);
      expect(find.byKey(const Key('word_hunt_reference_background_fallback')), findsNothing);
      expect(find.byKey(const Key('word_hunt_harbor_missing_asset')), findsNothing);
      for (var level = start; level <= end; level++) {
        expect(find.byKey(Key('word_hunt_harbor_level_$level')), findsOneWidget);
        expect(tester.widget<Text>(find.byKey(Key('word_hunt_harbor_number_$level'))).data,
            '$level');
        final hitbox = tester.getSize(find.byKey(Key('word_hunt_harbor_level_$level')));
        expect(hitbox.width, greaterThanOrEqualTo(48));
        expect(hitbox.height, greaterThanOrEqualTo(48));
      }
      expect(find.text('MEYDAN OKUMA'), findsOneWidget);
      expect(find.text('ROTA FİNALİ'), findsNothing);
      await tester.tap(find.byKey(Key('word_hunt_harbor_level_$end')));
      expect(tapped, <int>[end]);
      expect(tester.takeException(), isNull);
    });
  }


  // Check the actual painted ring and star backplate separately from hitbox
  // geometry. The two target pairs may not overlap at either Android size.
  for (final (segment, first, second, completed) in <(int, int, int, int)>[
    (2, 13, 14, 19),
    (3, 23, 24, 29),
  ]) {
    for (final (width, height) in <(int, int)>[
      (360, 800),
      (412, 915),
    ]) {
      testWidgets('Segment $segment: L$first/L$second separate at ${width}x$height',
          (tester) async {
        tester.view.physicalSize = Size(width.toDouble(), height.toDouble());
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final tapped = <int>[];
        await tester.pumpWidget(MaterialApp(
          home: WordHuntReferenceRouteScreen(
            progress: _through(completed),
            segmentIndex: segment,
            onBack: () {},
            onInfo: () {},
            onLevelTap: tapped.add,
            onSegmentSelect: (_) {},
          ),
        ));
        await tester.pumpAndSettle();

        final scene = tester.getRect(
          find.byKey(Key('word_hunt_harbor_scene_$segment')),
        );
        final sourceImage = tester.getRect(
          find.byKey(Key('word_hunt_harbor_scene_asset_$segment')),
        );
        final source = WordHuntHarborSegmentArt.sourceSize;
        final scale = sourceImage.width / source.width;
        final centers = WordHuntHarborSegmentArt.centersFor(segment);
        expect(
          tester.getRect(find.byKey(Key('word_hunt_harbor_path_$segment'))),
          scene,
        );
        expect(find.byKey(const Key('word_hunt_harbor_missing_asset')),
            findsNothing);

        Rect hitbox(int level) =>
            tester.getRect(find.byKey(Key('word_hunt_harbor_level_$level')));
        Rect medallion(int level) =>
            tester.getRect(find.byKey(Key('word_hunt_harbor_medallion_$level')));
        Rect stars(int level) => tester.getRect(
            find.byKey(Key('word_hunt_harbor_star_backplate_$level')));

        const roundoffTolerance = 1e-9;
        for (final level in <int>[first, second]) {
          final hit = hitbox(level);
          final ring = medallion(level);
          final starPlate = stars(level);
          expect(hit.width, greaterThanOrEqualTo(48), reason: 'L$level hitbox');
          expect(hit.height, greaterThanOrEqualTo(48), reason: 'L$level hitbox');
          // getRect reconstructs edges from global points. Subtracting those
          // edges can introduce floating-point roundoff even when the laid-out
          // DecoratedBox has the exact intended 54x54 size.
          final laidOutRing = tester.getSize(
              find.byKey(Key('word_hunt_harbor_medallion_$level')));
          final ringWidthDelta = (ring.width - 54).abs();
          final ringHeightDelta = (ring.height - 54).abs();
          debugPrint('Harbor S$segment L$level ${width}x$height: '
              'laidOut=${laidOutRing.width.toStringAsPrecision(17)}x'
              '${laidOutRing.height.toStringAsPrecision(17)}, '
              'globalRect=${ring.width.toStringAsPrecision(17)}x'
              '${ring.height.toStringAsPrecision(17)}, '
              'delta=${ringWidthDelta.toStringAsExponential(12)}x'
              '${ringHeightDelta.toStringAsExponential(12)}');
          expect(laidOutRing, const Size(54, 54),
              reason: 'L$level laid-out medallion must remain exactly 54x54');
          expect(ringWidthDelta, lessThanOrEqualTo(roundoffTolerance),
              reason: 'L$level global ring width: $ring');
          expect(ringHeightDelta, lessThanOrEqualTo(roundoffTolerance),
              reason: 'L$level global ring height: $ring');
          expect(starPlate.width, greaterThanOrEqualTo(45));
          expect(starPlate.height, greaterThanOrEqualTo(15));
          expect(hit.contains(ring.center), isTrue);
          expect(hit.contains(starPlate.center), isTrue);
          expect(scene.contains(hit.topLeft), isTrue);
          expect(scene.contains(hit.bottomRight), isTrue);
          expect(
            tester.widget<Text>(
              find.byKey(Key('word_hunt_harbor_number_$level')),
            ).data,
            '$level',
          );
          for (var i = 0; i < 3; i++) {
            expect(find.byKey(Key('word_hunt_harbor_star_${level}_$i')),
                findsOneWidget);
          }
          // Both the path painter and node overlay use these same projected
          // centers; also check the medallion is centered on its hitbox.
          final original = centers[level - (segment - 1) * 10 - 1];
          final pathPoint = Offset(
            sourceImage.left + original.dx * scale,
            sourceImage.top + original.dy * scale,
          );
          expect((ring.center - pathPoint).distance, lessThan(0.5),
              reason: 'L$level path endpoint');
          expect((ring.center - hit.center).distance, lessThan(0.5),
              reason: 'L$level touch/visual center');
        }

        final firstRects = <Rect>[
          hitbox(first), medallion(first), stars(first),
        ];
        final secondRects = <Rect>[
          hitbox(second), medallion(second), stars(second),
        ];
        for (final a in firstRects) {
          for (final b in secondRects) {
            expect(a.overlaps(b), isFalse,
                reason: 'L$first/L$second collision at ${width}x$height');
          }
        }

        final viewport = Rect.fromLTWH(
          0, 0, width.toDouble(), height.toDouble(),
        );
        // The Scaffold contains a SafeArea. Check every control against its
        // inset-adjusted bounds, including the valid right and bottom edges.
        final safePadding = MediaQuery.paddingOf(tester.element(
          find.byKey(Key('word_hunt_harbor_segment_screen_$segment')),
        ));
        final safeViewport = Rect.fromLTRB(
          viewport.left + safePadding.left,
          viewport.top + safePadding.top,
          viewport.right - safePadding.right,
          viewport.bottom - safePadding.bottom,
        );
        String preciseRect(Rect rect) =>
            '(${rect.left.toStringAsPrecision(17)}, '
            '${rect.top.toStringAsPrecision(17)}, '
            '${rect.right.toStringAsPrecision(17)}, '
            '${rect.bottom.toStringAsPrecision(17)})';
        for (final key in <String>[
          'word_hunt_harbor_back',
          'word_hunt_harbor_info',
          'word_hunt_harbor_segment_navigation',
        ]) {
          final rect = tester.getRect(find.byKey(Key(key)));
          final evidence = '$key: rect=${preciseRect(rect)}, '
              'viewport=${preciseRect(viewport)}, '
              'safeViewport=${preciseRect(safeViewport)}, '
              'safePadding=$safePadding';
          debugPrint('Harbor S$segment ${width}x$height: $evidence');
          expect(rect.left, greaterThanOrEqualTo(
              safeViewport.left - roundoffTolerance), reason: evidence);
          expect(rect.top, greaterThanOrEqualTo(
              safeViewport.top - roundoffTolerance), reason: evidence);
          expect(rect.right, lessThanOrEqualTo(
              safeViewport.right + roundoffTolerance), reason: evidence);
          expect(rect.bottom, lessThanOrEqualTo(
              safeViewport.bottom + roundoffTolerance), reason: evidence);
        }
        await tester.tap(find.byKey(Key('word_hunt_harbor_level_$first')));
        await tester.tap(find.byKey(Key('word_hunt_harbor_level_$second')));
        expect(tapped, <int>[first, second],
            reason: 'L$first and L$second keep separate target IDs');
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('0/1/2/3 stars are visually distinct with canonical palette', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(children: <Widget>[
          WordHuntProgressStars(earned: 0, keyPrefix: 's0_'),
          WordHuntProgressStars(earned: 1, keyPrefix: 's1_'),
          WordHuntProgressStars(earned: 2, keyPrefix: 's2_'),
          WordHuntProgressStars(earned: 3, keyPrefix: 's3_'),
        ]),
      ),
    ));
    for (var earned = 0; earned <= 3; earned++) {
      for (var index = 0; index < 3; index++) {
        final icon = tester.widget<Icon>(find.byKey(Key('s${earned}_$index')));
        expect(icon.color, index < earned
            ? WordHuntStarVisuals.filled : WordHuntStarVisuals.empty);
        expect(icon.icon, index < earned
            ? Icons.star_rounded : Icons.star_outline_rounded);
      }
    }
  });

  testWidgets('history navigation and replay preserve persisted stars', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final progress = _through(29);
    final seen = <int>[];
    var selected = 3;
    await tester.pumpWidget(MaterialApp(home: StatefulBuilder(
      builder: (context, setState) => WordHuntReferenceRouteScreen(
        progress: progress,
        segmentIndex: selected,
        onSegmentSelect: (index) => setState(() => selected = index),
        onLevelTap: seen.add,
      ),
    )));
    await tester.pumpAndSettle();
    expect(selected, 3);
    await tester.tap(find.byKey(const Key('word_hunt_harbor_segment_2')));
    await tester.pumpAndSettle();
    expect(selected, 2);
    await tester.tap(find.byKey(const Key('word_hunt_harbor_level_12')));
    expect(seen, <int>[12]);
    expect(progress.starsFor('baslangic-12'), 1);
    await tester.tap(find.byKey(const Key('word_hunt_harbor_segment_3')));
    await tester.pumpAndSettle();
    expect(selected, 3);
    expect(progress.starsFor('baslangic-29'), 3);
    expect(find.byKey(const Key('word_hunt_harbor_level_30')), findsOneWidget);
    expect(find.text('ROTA FİNALİ'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}