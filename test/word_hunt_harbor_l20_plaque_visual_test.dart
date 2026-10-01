import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apps/kelime_avi_standalone/lib/harbor_visual_proof_main.dart'
    as proof;

// Conservative painted brown interior, measured in the unchanged 1252x1203
// challenge_combined_blank.png. Gold border, bolts and transparent margins are
// deliberately excluded. This oracle is independent of the renderer's layout.
const _assetSize = Size(1252, 1203);
const _paintedInterior = Rect.fromLTRB(160, 865, 1092, 1055);

Rect _interiorIn(Rect image) => Rect.fromLTRB(
  image.left + _paintedInterior.left / _assetSize.width * image.width,
  image.top + _paintedInterior.top / _assetSize.height * image.height,
  image.left + _paintedInterior.right / _assetSize.width * image.width,
  image.top + _paintedInterior.bottom / _assetSize.height * image.height,
);

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 60; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
  }
  fail('Harbor did not reach the requested terminal widget');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Optional local visual evidence uses real installed fonts, not Ahem. CI's
  // geometry assertions remain runnable without platform-specific font files.
  setUpAll(() async {
    final directory = Platform.environment['HARBOR_VISUAL_FONT_DIR'];
    if (directory == null) return;
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final (family, file) in <(String, String)>[
      ('serif', 'timesbd.ttf'),
      ('Roboto', 'arial.ttf'),
    ]) {
      final loader = FontLoader(family)..addFont(
        Future.value(
          ByteData.sublistView(File('$directory/$file').readAsBytesSync()),
        ),
      );
      await loader.load();
    }
  });

  for (final size in const <Size>[Size(360, 800), Size(412, 915)]) {
    testWidgets('L20 text fits painted plaque at ${size.width.toInt()}x'
        '${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      rootBundle.evict(
        'assets/word_hunt/harbor_segments/segment_02_ui/layout_schema_v2.json',
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('harbor_l20_visual_capture'),
          child: proof.buildHarborVisualProofApp(key: UniqueKey()),
        ),
      );
      await _waitFor(
        tester,
        find.byKey(const Key('word_hunt_harbor_level_20')),
      );
      await tester.tap(find.byKey(const Key('word_hunt_harbor_info')));
      final label = find.byKey(const Key('word_hunt_harbor_challenge_20'));
      await _waitFor(tester, label);
      await tester.runAsync(() async {
        for (final element in find.byType(Image).evaluate()) {
          await precacheImage((element.widget as Image).image, element);
        }
      });
      await tester.pump();

      // Capture actual Flutter pixels even when a subsequent assertion fails.
      final output = Platform.environment['HARBOR_VISUAL_OUTPUT_DIR'];
      if (output != null) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('harbor_l20_visual_capture')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory(output)..createSync(recursive: true);
          File(
            '${directory.path}/harbor_${size.width.toInt()}x'
            '${size.height.toInt()}_l20_playable.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      final image = tester.getRect(
        find.byKey(const Key('word_hunt_harbor_medallion_20')),
      );
      final interior = _interiorIn(image);
      final paragraphFinder = find.descendant(
        of: label,
        matching: find.byType(RichText),
        matchRoot: true,
      );
      final paragraph = tester.renderObject<RenderParagraph>(paragraphFinder);
      final transform = paragraph.getTransformTo(null);
      final text = MatrixUtils.transformRect(
        transform,
        Offset.zero & paragraph.size,
      );
      expect(
        interior.inflate(0.01).contains(text.topLeft),
        isTrue,
        reason: 'Text top-left $text must be inside painted interior $interior',
      );
      expect(
        interior.inflate(0.01).contains(text.bottomRight),
        isTrue,
        reason:
            'Text bottom-right $text must be inside painted interior $interior',
      );
      expect((text.center.dx - interior.center.dx).abs(), lessThan(0.01));
      expect((text.center.dy - interior.center.dy).abs(), lessThan(0.01));
      final hitbox = tester.getRect(
        find.byKey(const Key('word_hunt_harbor_level_20')),
      );
      expect(
        tester.getSize(find.byKey(const Key('word_hunt_harbor_level_20'))),
        const Size(68, 68),
      );
      expect(text.top, greaterThanOrEqualTo(hitbox.bottom));
      final scene = tester.getRect(
        find.byKey(const Key('word_hunt_harbor_scene_2')),
      );
      expect(scene.contains(text.topLeft), isTrue);
      expect(scene.contains(text.bottomRight), isTrue);
      for (var level = 11; level < 20; level++) {
        expect(
          text.overlaps(
            tester.getRect(find.byKey(Key('word_hunt_harbor_level_$level'))),
          ),
          isFalse,
          reason: 'L20 label must not overlap L$level',
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
