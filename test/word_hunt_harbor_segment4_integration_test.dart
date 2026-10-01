import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_progress.dart';
import 'package:word_hunt_flutter_feature/word_hunt_harbor_layout_manifest.dart';
import 'package:word_hunt_flutter_feature/word_hunt_harbor_segment_registry.dart';
import 'package:word_hunt_flutter_feature/word_hunt_reference_route_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_star_visuals.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const art = WordHuntHarborSegmentRegistry.fenerBurnu;
  const route = WordHuntStarterContent.baslangicLimani;
  testWidgets('production route navigates Segment 3 to 4 and back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var segment = 3;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: {for (var n = 1; n <= 30; n++) 'baslangic-$n': 2},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder:
              (context, setState) => WordHuntReferenceRouteScreen(
                route: route,
                progress: progress,
                segmentIndex: segment,
                onSegmentSelect: (value) => setState(() => segment = value),
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('word_hunt_harbor_segment_4')));
    for (
      var attempt = 0;
      attempt < 100 &&
          find.byKey(const Key('word_hunt_harbor_level_31')).evaluate().isEmpty;
      attempt++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(segment, 4);
    expect(find.byKey(const Key('word_hunt_harbor_level_31')), findsOneWidget);
    await tester.tap(find.byKey(const Key('word_hunt_harbor_segment_3')));
    await tester.pumpAndSettle();
    expect(segment, 3);
    expect(find.byKey(const Key('word_hunt_harbor_level_21')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test(
    'registered scene bytes, decoded dimensions and ordered manifest',
    () async {
      final bytes = File(art.sceneAsset).readAsBytesSync();
      expect(sha256.convert(bytes).toString(), art.sceneSha256);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 941);
      expect(frame.image.height, 1672);
      frame.image.dispose();
      codec.dispose();
      final json = File(art.manifestAsset).readAsStringSync();
      HarborSceneAssetMetadata? resolve(String path) =>
          path == art.sceneAsset
              ? HarborSceneAssetMetadata(
                assetPath: path,
                width: 941,
                height: 1672,
                sha256: sha256.convert(bytes).toString(),
              )
              : null;
      final manifest = HarborLayoutManifest.parseJson(
        json,
        resolveAsset: resolve,
      );
      expect(manifest.segmentIndex, 4);
      expect(
        manifest.nodes.map((n) => n.levelId),
        List.generate(10, (i) => 'baslangic-${i + 31}'),
      );
      expect(manifest.connections, hasLength(9));
      expect(manifest.minimumHitTargetLogicalDp, 68);
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (m) => m['segmentIndex'] = 5,
        (m) => (m['scene'] as Map)['sha256'] = '0' * 64,
        (m) => (m['nodes'] as List).removeLast(),
        (m) => (m['connections'] as List).removeLast(),
        (m) => (m['nodes'] as List).first['levelId'] = 'baslangic-30',
      ]) {
        final broken = jsonDecode(json) as Map<String, dynamic>;
        mutate(broken);
        expect(
          () => HarborLayoutManifest.parseJson(
            jsonEncode(broken),
            resolveAsset: resolve,
          ),
          throwsA(isA<HarborLayoutValidationException>()),
        );
      }
    },
  );
  for (final viewport in [const Size(360, 800), const Size(412, 915)]) {
    for (final completed in [33, 39, 40]) {
      testWidgets(
        '$viewport / completed $completed: real route, geometry, stars and taps',
        (tester) async {
          tester.view.physicalSize = viewport;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final progress = WordHuntProgressSnapshot(
            bestStarsByLevelId: {
              for (var n = 1; n <= completed; n++)
                'baslangic-$n': n >= 31 ? ((n - 31) % 3) + 1 : 1,
            },
          );
          final taps = <int>[];
          final segments = <int>[];
          await tester.pumpWidget(
            RepaintBoundary(
              key: const Key('fener_burnu_review_capture'),
              child: MaterialApp(
                home: WordHuntReferenceRouteScreen(
                  route: route,
                  progress: progress,
                  segmentIndex: 4,
                  onLevelTap: taps.add,
                  onSegmentSelect: segments.add,
                ),
              ),
            ),
          );
          for (
            var attempt = 0;
            attempt < 100 &&
                find
                    .byKey(const Key('word_hunt_harbor_level_31'))
                    .evaluate()
                    .isEmpty;
            attempt++
          ) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)),
            );
            await tester.pump(const Duration(milliseconds: 20));
          }
          expect(
            find.byKey(const Key('word_hunt_harbor_layout_error_4')),
            findsNothing,
          );
          expect(
            find.byKey(const Key('word_hunt_harbor_scene_asset_4')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('word_hunt_reference_background_fallback')),
            findsNothing,
          );
          final scene = tester.getRect(
            find.byKey(const Key('word_hunt_harbor_scene_4')),
          );
          final boxes = <Rect>[];
          for (var n = 31; n <= 40; n++) {
            final finder = find.byKey(Key('word_hunt_harbor_level_$n'));
            expect(tester.getSize(finder), const Size(68, 68));
            final rect = tester.getRect(finder);
            boxes.add(rect);
            expect(scene.contains(rect.topLeft), isTrue);
            expect(
              scene.contains(rect.bottomRight - const Offset(.01, .01)),
              isTrue,
            );
            await tester.tap(finder);
            expect(taps.contains(n), n <= completed + 1);
            final starsFinder = find.byKey(Key('word_hunt_harbor_stars_$n'));
            if (n <= completed + 1) {
              expect(starsFinder, findsOneWidget);
              final starsRect = tester.getRect(starsFinder);
              expect(scene.contains(starsRect.topLeft), isTrue);
              expect(
                scene.contains(starsRect.bottomRight - const Offset(.01, .01)),
                isTrue,
              );
              final stars = tester.widget<WordHuntProgressStars>(
                find.descendant(
                  of: starsFinder,
                  matching: find.byType(WordHuntProgressStars),
                ),
              );
              expect(stars.earned, progress.starsFor('baslangic-$n'));
            } else {
              expect(starsFinder, findsNothing);
            }
          }
          for (var i = 0; i < 10; i++) {
            for (var j = i + 1; j < 10; j++) {
              expect(boxes[i].overlaps(boxes[j]), isFalse);
            }
          }
          final plaque = find.byKey(const Key('word_hunt_harbor_challenge_40'));
          final plaqueRect = tester.getRect(plaque);
          expect(scene.contains(plaqueRect.topLeft), isTrue);
          expect(scene.contains(plaqueRect.bottomRight), isTrue);
          final textRect = tester.getRect(
            find.descendant(of: plaque, matching: find.text('Meydan Okuma')),
          );
          expect(plaqueRect.contains(textRect.topLeft), isTrue);
          expect(plaqueRect.contains(textRect.bottomRight), isTrue);
          for (final box in boxes) {
            expect(box.overlaps(plaqueRect), isFalse);
          }
          await tester.tap(find.byKey(const Key('word_hunt_harbor_segment_3')));
          expect(segments, contains(3));
          expect(tester.takeException(), isNull);
          await tester.pump();
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const Key('fener_burnu_review_capture')),
            );
            final image = await boundary.toImage(pixelRatio: 1);
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            final output = Directory(
              '${Directory.systemTemp.path}/fener-burnu-checkpoint-c-review',
            );
            await output.create(recursive: true);
            await File(
              '${output.path}/fener_${viewport.width.toInt()}x${viewport.height.toInt()}_$completed.png',
            ).writeAsBytes(png!.buffer.asUint8List());
            image.dispose();
          });
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}
