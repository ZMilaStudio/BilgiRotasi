import 'dart:ui' as ui;

import 'package:bilgi_rotasi/word_hunt/word_hunt_pixel_proof_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

const _caption = 'İLK ETAP\nFİNALİ';
const _coverKey = Key('word_hunt_l10_caption_cover');
const _sourceKey = Key('word_hunt_pixel_proof_source_scene');
const _captureKey = Key('l10_regression_capture');
const _approvedRect = Rect.fromLTRB(477, 1006, 567, 1060);

Widget _app(Widget screen) =>
    RepaintBoundary(key: _captureKey, child: MaterialApp(home: screen));

Future<void> _loadImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pump();
}

Future<img.Image> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return img.decodePng(bytes!.buffer.asUint8List())!;
    } finally {
      image.dispose();
    }
  }))!;
}

List<Rect> _hitboxes(WidgetTester tester) => <Rect>[
  for (var i = 1; i <= 10; i++)
    tester.getRect(find.byKey(Key('word_hunt_pixel_proof_level_$i'))),
];

// Reconstruct the pre-repair scene from the *actual* production children,
// removing only the L10 cover. No alternate asset, progress or hitbox fixture.
Widget _legacyScene(Stack scene) => Scaffold(
  backgroundColor: Colors.black,
  body: SafeArea(
    child: ClipRect(
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox.fromSize(
            key: _sourceKey,
            size: WordHuntPixelProofLayout.sourceSize,
            child: Stack(
              fit: StackFit.expand,
              children:
                  scene.children
                      .where(
                        (child) =>
                            child.key !=
                            const Key('word_hunt_l10_caption_layer'),
                      )
                      .toList(),
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  for (final viewport in const <Size>[Size(360, 800), Size(412, 915)]) {
    testWidgets('L10 caption and fail-closed regional pixels at $viewport', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final taps = <int>[];
      final screen = WordHuntPixelProofScreen(
        progress: WordHuntProgressSnapshot(
          bestStarsByLevelId: <String, int>{
            for (var i = 1; i <= 9; i++) 'baslangic-$i': i % 3 + 1,
          },
        ),
        onLevelTap: taps.add,
      );
      await tester.pumpWidget(_app(screen));
      await _loadImages(tester);
      expect(find.text(_caption), findsOneWidget);
      expect(find.textContaining('ROTA FİNALİ'), findsNothing);
      final coverFinder = find.byKey(_coverKey);
      final positioned = tester.widget<Positioned>(coverFinder);
      expect(
        Rect.fromLTWH(
          positioned.left!,
          positioned.top!,
          positioned.width!,
          positioned.height!,
        ),
        _approvedRect,
      );
      expect(
        find.descendant(of: coverFinder, matching: find.byType(IgnorePointer)),
        findsOneWidget,
      );
      expect(
        tester
            .widget<IgnorePointer>(
              find.descendant(
                of: coverFinder,
                matching: find.byType(IgnorePointer),
              ),
            )
            .ignoring,
        isTrue,
      );
      expect(
        find.descendant(
          of: coverFinder,
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      // Opaque paint over the entire accepted area hides the baked old glyphs;
      // a transparent / missing / undersized cover must fail this contract.
      final box = tester.widget<DecoratedBox>(
        find.descendant(of: coverFinder, matching: find.byType(DecoratedBox)),
      );
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(2));
      final gradient = decoration.gradient! as LinearGradient;
      expect(gradient.colors, const <Color>[
        Color(0xFF1B130C),
        Color(0xFF0C0B05),
      ]);
      expect(gradient.colors.every((color) => color.a == 1), isTrue);
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      final cover = tester.getRect(coverFinder);
      final text = tester.getRect(find.text(_caption));
      expect(cover.inflate(0.01).contains(text.topLeft), isTrue);
      expect(cover.inflate(0.01).contains(text.bottomRight), isTrue);
      expect((cover.center - text.center).distance, lessThan(0.01));
      final source = tester.renderObject<RenderBox>(find.byKey(_sourceKey));
      expect(
        cover,
        MatrixUtils.transformRect(source.getTransformTo(null), _approvedRect),
      );
      final master = tester.widget<Image>(
        find.byKey(const Key('word_hunt_pixel_proof_master_art')),
      );
      expect(
        (master.image as AssetImage).assetName,
        WordHuntPixelProofAssets.masterArt,
      );
      expect(master.fit, BoxFit.fill);
      expect(master.filterQuality, FilterQuality.none);
      final semantics = tester.ensureSemantics();
      await tester.pump();
      expect(
        tester
            .binding
            .renderViews
            .single
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!
            .toStringDeep()
            .contains('İLK ETAP'),
        isFalse,
      );
      semantics.dispose();
      final afterBoxes = _hitboxes(tester);
      final after = await _pixels(tester);
      await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_10')));
      expect(taps, <int>[10]);
      final scene = tester.widget<Stack>(
        find
            .descendant(
              of: find.byKey(_sourceKey),
              matching: find.byType(Stack),
            )
            .first,
      );
      await tester.pumpWidget(_app(_legacyScene(scene)));
      await _loadImages(tester);
      expect(find.text(_caption), findsNothing); // Old implementation fails A.
      expect(_hitboxes(tester), afterBoxes);
      final before = await _pixels(tester);
      expect(before.width, viewport.width.toInt());
      expect(before.height, viewport.height.toInt());
      expect(after.width, before.width);
      expect(after.height, before.height);
      var changedInside = 0;
      var changedOutside = 0;
      // Include only rasterized edge pixels of the accepted source rectangle.
      final region = Rect.fromLTRB(
        cover.left.floorToDouble(),
        cover.top.floorToDouble(),
        cover.right.ceilToDouble(),
        cover.bottom.ceilToDouble(),
      );
      for (var y = 0; y < before.height; y++) {
        for (var x = 0; x < before.width; x++) {
          final a = before.getPixel(x, y);
          final b = after.getPixel(x, y);
          if (a.r != b.r || a.g != b.g || a.b != b.b || a.a != b.a) {
            if (region.contains(Offset(x.toDouble(), y.toDouble()))) {
              changedInside++;
            } else {
              changedOutside++;
            }
          }
        }
      }
      expect(
        changedOutside,
        0,
        reason: 'No pixel outside the L10 label may change',
      );
      expect(
        changedInside,
        greaterThan(100),
        reason: 'Old raster caption must be covered',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('caption never appears on another segment', (tester) async {
    for (final segment in <int>[2, 3]) {
      await tester.pumpWidget(
        _app(WordHuntPixelProofScreen(segmentIndex: segment)),
      );
      expect(find.text(_caption), findsNothing);
      expect(find.byKey(_coverKey), findsNothing);
    }
  });

  testWidgets('caption never appears on another route', (tester) async {
    const starter = WordHuntStarterContent.baslangicLimani;
    final otherRoute = WordHuntRouteDefinition(
      id: 'other-route',
      title: starter.title,
      theme: starter.theme,
      unlockStarsRequired: starter.unlockStarsRequired,
      levels: starter.levels,
      routeRewardId: starter.routeRewardId,
      segments: starter.segments,
    );
    await tester.pumpWidget(_app(WordHuntPixelProofScreen(route: otherRoute)));
    expect(find.text(_caption), findsNothing);
    expect(find.byKey(_coverKey), findsNothing);
  });
}
