import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reference_route_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_harbor_layout_manifest.dart';
import 'package:word_hunt_flutter_feature/word_hunt_star_visuals.dart';

void main() {
  final route = WordHuntStarterContent.baslangicLimani;

  test(
    'production manifest and approved scene bytes retain their authorities',
    () {
      final scene = File(
        'assets/word_hunt/harbor_segments/segment_02_clean.webp',
      );
      expect(
        sha256.convert(scene.readAsBytesSync()).toString(),
        HarborLayoutManifest.segment2SceneSha256,
      );
      final production = File(
        'assets/word_hunt/harbor_segments/segment_02_ui/layout_schema_v2.json',
      );
      final source = File(
        'test/fixtures/harbor/segment_2_design_candidate_manifest.json',
      );
      expect(production.readAsBytesSync(), source.readAsBytesSync());
      for (final name in const <String>[
        'medallion_blank.png',
        'locked_medallion.png',
        'star_socket_blank.png',
        'challenge_combined_blank.png',
        'hanging_lantern.png',
      ]) {
        final product = File(
          'assets/word_hunt/harbor_segments/segment_02_ui/$name',
        );
        final approved = File(
          'test/fixtures/harbor/segment_2_locked_reference_refinement/assets/$name',
        );
        expect(
          product.readAsBytesSync(),
          approved.readAsBytesSync(),
          reason: name,
        );
      }
    },
  );

  WordHuntProgressSnapshot through(int last, {int stars = 1}) =>
      WordHuntProgressSnapshot(
        bestStarsByLevelId: {
          for (final level in route.levels.take(last)) level.id: stars,
        },
      );

  Future<void> show(
    WidgetTester tester, {
    required Size size,
    required WordHuntProgressSnapshot progress,
    ValueChanged<int>? onLevelTap,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: DefaultAssetBundle(
          bundle: _ManifestAssetBundle(),
          child: WordHuntReferenceRouteScreen(
            route: route,
            segmentIndex: 2,
            progress: progress,
            onLevelTap: onLevelTap,
          ),
        ),
      ),
    );
    for (var attempt = 0; attempt < 5; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find
          .byKey(const Key('word_hunt_harbor_level_11'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }
    expect(find.byKey(const Key('word_hunt_harbor_level_11')), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('word_hunt_harbor_layout_error_2')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('word_hunt_harbor_identity_error_2')),
      findsNothing,
    );
  }

  testWidgets('real progress drives 0/1/2/3 stars and lock-only nodes', (
    tester,
  ) async {
    await show(tester, size: const Size(412, 915), progress: through(10));
    expect(
      find.byKey(const Key('word_hunt_harbor_current_glow_11')),
      findsOneWidget,
    );
    for (var index = 0; index < 3; index++) {
      final icon = tester.widget<Icon>(
        find.byKey(Key('word_hunt_harbor_star_11_$index')),
      );
      expect(icon.color, WordHuntStarVisuals.empty);
    }
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: {
        for (final level in route.levels.take(10)) level.id: 1,
        'baslangic-11': 1,
        'baslangic-12': 1,
        'baslangic-13': 2,
        'baslangic-14': 3,
      },
    );
    await show(tester, size: const Size(412, 915), progress: progress);
    expect(find.text('YILDIZLAR TEMSİLİ'), findsNothing);
    expect(find.textContaining(' / ${route.maximumStars} ★'), findsOneWidget);
    for (final (number, stars) in const <(int, int)>[
      (11, 1),
      (12, 1),
      (13, 2),
      (14, 3),
    ]) {
      for (var index = 0; index < 3; index++) {
        final icon = tester.widget<Icon>(
          find.byKey(Key('word_hunt_harbor_star_${number}_$index')),
        );
        expect(
          icon.color,
          index < stars
              ? WordHuntStarVisuals.filled
              : WordHuntStarVisuals.empty,
        );
      }
    }
    expect(find.byKey(const Key('word_hunt_harbor_number_16')), findsNothing);
    expect(
      find.byKey(const Key('word_hunt_harbor_star_backplate_16')),
      findsNothing,
    );
    final lock = tester.widget<Image>(
      find.byKey(const Key('word_hunt_harbor_medallion_16')),
    );
    expect(
      (lock.image as AssetImage).assetName,
      contains('locked_medallion.png'),
    );
    expect(
      tester
          .getSize(find.byKey(const Key('word_hunt_harbor_medallion_16')))
          .width,
      lessThan(
        tester
            .getSize(find.byKey(const Key('word_hunt_harbor_medallion_15')))
            .width,
      ),
    );
    expect(
      find.byKey(const Key('word_hunt_harbor_star_backplate_20')),
      findsNothing,
    );
  });

  testWidgets('68dp hit target calls real level callback only when unlocked', (
    tester,
  ) async {
    final taps = <int>[];
    await show(
      tester,
      size: const Size(360, 800),
      progress: through(13),
      onLevelTap: taps.add,
    );
    final open = find.byKey(const Key('word_hunt_harbor_level_14'));
    expect(tester.getSize(open), const Size(68, 68));
    await tester.tap(open);
    expect(taps, <int>[14]);
    await tester.tap(find.byKey(const Key('word_hunt_harbor_level_15')));
    expect(taps, <int>[14]);
  });

  testWidgets('L20 is an interactive challenge, never a route-final crown', (
    tester,
  ) async {
    final taps = <int>[];
    await show(
      tester,
      size: const Size(412, 915),
      progress: through(19),
      onLevelTap: taps.add,
    );
    expect(route.levels[19].id, 'baslangic-20');
    expect(find.byKey(const Key('word_hunt_harbor_number_20')), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_harbor_challenge_20')),
      findsOneWidget,
    );
    expect(find.text('Meydan Okuma'), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium), findsNothing);
    await tester.tap(find.byKey(const Key('word_hunt_harbor_level_20')));
    expect(taps, <int>[20]);
  });

  testWidgets(
    'same manifest renders ten nodes and nine ropes at both viewports',
    (tester) async {
      for (final size in const <Size>[Size(360, 800), Size(412, 915)]) {
        await show(tester, size: size, progress: through(19));
        for (var level = 11; level <= 20; level++) {
          expect(
            find.byKey(Key('word_hunt_harbor_level_$level')),
            findsOneWidget,
          );
        }
        expect(
          find.byKey(const Key('word_hunt_harbor_path_2')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('word_hunt_harbor_lantern_2_2')),
          findsOneWidget,
        );
        final scene = tester.getRect(
          find.byKey(const Key('word_hunt_harbor_scene_2')),
        );
        for (var level = 11; level <= 20; level++) {
          final visual = tester.getRect(
            find.byKey(Key('word_hunt_harbor_medallion_$level')),
          );
          expect(
            scene.contains(visual.topLeft),
            isTrue,
            reason: '$size L$level top-left',
          );
          expect(
            scene.contains(visual.bottomRight),
            isTrue,
            reason: '$size L$level bottom-right',
          );
        }
        final plaque = tester.getRect(
          find.byKey(const Key('word_hunt_harbor_challenge_20')),
        );
        expect(
          scene.contains(plaque.bottomRight),
          isTrue,
          reason: '$size L20 plaque',
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  test('schema-v2 transform keeps scene and node-relative units separate', () {
    final narrow = HarborLayoutManifest.sceneToViewportTransform(
      sceneWidth: 941,
      sceneHeight: 1672,
      viewportWidth: 360,
      viewportHeight: 662,
    );
    final wide = HarborLayoutManifest.sceneToViewportTransform(
      sceneWidth: 941,
      sceneHeight: 1672,
      viewportWidth: 412,
      viewportHeight: 777,
    );
    const center = HarborLayoutPoint(
      325,
      1475,
      HarborLayoutCoordinateUnit.scenePixels,
    );
    const star = HarborLayoutPoint(
      0,
      42.5,
      HarborLayoutCoordinateUnit.nodeRelativeLogicalDp,
    );
    for (final transform in <HarborSceneViewportTransform>[narrow, wide]) {
      final p = transform.projectScene(center);
      final s = transform.projectNodeOffset(center, star);
      expect(s.x, p.x);
      expect(s.y - p.y, 42.5);
    }
  });
}

class _ManifestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => rootBundle.load(key);

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    if (key.endsWith('/segment_02_ui/layout_schema_v2.json')) {
      return Future<String>.value(
        File(
          'assets/word_hunt/harbor_segments/segment_02_ui/layout_schema_v2.json',
        ).readAsStringSync(),
      );
    }
    return rootBundle.loadString(key, cache: cache);
  }
}
