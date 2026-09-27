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