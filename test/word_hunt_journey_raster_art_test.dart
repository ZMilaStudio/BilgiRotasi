import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_art.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_theme.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_background.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_geometry.dart';

JourneyArtAsset asset(String path) => JourneyArtAsset(
  path: path,
  intrinsicSize: const Size(32, 32),
  sha256: List.filled(64, 'a').join(),
);

JourneyArtRegistry registry({bool rich = false}) => JourneyArtRegistry([
  for (final id in [
    'fener_shore_v1',
    'fener_cliffs_v1',
    'fener_approach_v1',
    'fener_beacon_v1',
    'forest_v1',
  ])
    JourneyArtKit(
      themeId: id,
      baseAtmosphere: asset('$id/base.webp'),
      leftEnvironment:
          rich
              ? [for (var i = 0; i < 8; i++) asset('$id/left_$i.webp')]
              : [asset('$id/left.webp')],
      rightEnvironment:
          rich
              ? [for (var i = 0; i < 8; i++) asset('$id/right_$i.webp')]
              : [asset('$id/right.webp')],
      landmarkAssets: {
        if (id == 'fener_beacon_v1') 100: asset('$id/lighthouse.webp'),
      },
    ),
]);

Future<Uint8List> fixture() async {
  final recorder = ui.PictureRecorder();
  Canvas(
    recorder,
  ).drawRect(const Rect.fromLTWH(0, 0, 32, 32), Paint()..color = Colors.indigo);
  final picture = recorder.endRecording(),
      image = await picture.toImage(32, 32);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  testWidgets('raster row/chunk seams share endpoints at 20/21 and 100/101', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final png = await fixture();
      final codec = await ui.instantiateImageCodec(png);
      final frame = await codec.getNextFrame();
      final art = registry();
      final images = <String, ui.Image>{};
      for (final kit in (art.installationManifest()['kits'] as List)) {
        for (final entry in kit['assets'] as List) {
          images[entry['path']] = frame.image;
        }
      }
      const geometry = WordHuntJourneyGeometry();
      Future<Uint8List> edge(int n, bool bottom) async {
        final chunk = (n - 1) ~/ 20, y = ((n - 1) % 20) * 112;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder)..translate(0, -y.toDouble());
        JourneyRasterPainter(
          registry: art,
          schedule: JourneyThemeSchedule.production,
          geometry: geometry,
          chunk: chunk,
          count: 15000,
          width: 360,
          rows: {n},
          images: images,
        ).paint(canvas, const Size(360, 2240));
        final picture = recorder.endRecording(),
            image = await picture.toImage(360, 112);
        final data = (await image.toByteData())!;
        final row = bottom ? 111 : 0;
        final bytes = Uint8List.fromList(
          data.buffer.asUint8List(row * 360 * 4, 360 * 4),
        );
        image.dispose();
        picture.dispose();
        return bytes;
      }

      for (final n in [20, 100]) {
        final before = await edge(n, true), after = await edge(n + 1, false);
        // Half-pixel gradient sampling can differ by one quantized channel step.
        for (var i = 0; i < before.length; i++) {
          expect((before[i] - after[i]).abs(), lessThanOrEqualTo(1));
        }
      }
      frame.image.dispose();
      codec.dispose();
    });
  });
  test('metadata rejects unsafe focal/dimensions and kit policies', () {
    expect(
      () => JourneyArtRegistry([
        JourneyArtKit(
          themeId: 'fener_shore_v1',
          baseAtmosphere: asset('x'),
          landmarkAssets: {100: asset('wrong-owner')},
        ),
      ]).validateForSchedule(JourneyThemeSchedule.production),
      throwsArgumentError,
    );
    expect(
      () => JourneyArtAsset(
        path: 'x',
        intrinsicSize: const Size(double.infinity, 1),
        sha256: List.filled(64, 'a').join(),
      ),
      throwsArgumentError,
    );
    expect(
      () => JourneyArtAsset(
        path: 'x',
        intrinsicSize: const Size(1, 1),
        sha256: List.filled(64, 'a').join(),
        focalPoint: const Alignment(2, 0),
      ),
      throwsArgumentError,
    );
    expect(
      () => JourneyArtKit(
        themeId: 'x',
        baseAtmosphere: asset('x'),
        corridorOpacity: 1,
      ),
      throwsArgumentError,
    );
  });
  test(
    'registry fails closed for duplicates/landmark ownership/transition partner',
    () {
      expect(
        () => JourneyArtRegistry([
          JourneyArtKit(themeId: 'a', baseAtmosphere: asset('same')),
          JourneyArtKit(themeId: 'b', baseAtmosphere: asset('same')),
        ]),
        throwsArgumentError,
      );
      expect(
        () => JourneyArtRegistry([
          JourneyArtKit(
            themeId: 'a',
            baseAtmosphere: asset('a'),
            landmarkAssets: {20: asset('a20')},
          ),
          JourneyArtKit(
            themeId: 'b',
            baseAtmosphere: asset('b'),
            landmarkAssets: {20: asset('b20')},
          ),
        ]),
        throwsArgumentError,
      );
      expect(
        () => JourneyArtRegistry([
          JourneyArtKit(
            themeId: 'a',
            baseAtmosphere: asset('a'),
            transitionPartner: 'missing',
          ),
        ]),
        throwsArgumentError,
      );
    },
  );
  test(
    'variants deterministic, not random or save driven; empty production registry',
    () {
      final kit = JourneyArtKit(
        themeId: 'a',
        baseAtmosphere: asset('a'),
        leftEnvironment: [asset('left1'), asset('left2')],
      );
      expect(kit.variant(kit.leftEnvironment, 1)?.path, 'left1');
      expect(kit.variant(kit.leftEnvironment, 4)?.path, 'left1');
      expect(kit.variant(kit.leftEnvironment, 5)?.path, 'left2');
      expect(JourneyArtRegistry.production['fener_shore_v1'], isNull);
      expect(JourneyBackgroundPainter.edgeArtWidth, 28);
    },
  );
  for (final viewport in [const Size(360, 800), const Size(412, 915)]) {
    for (final n in [1, 20, 21, 50, 51, 75, 76, 100, 101, 15000]) {
      testWidgets('raster replacement preserves geometry/actions $viewport L$n', (
        tester,
      ) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final handle = tester.ensureSemantics();
        final png = (await tester.runAsync(fixture))!,
            controller = WordHuntJourneyMapController();
        var taps = 0;
        Widget map(JourneyArtRegistry? art) => MaterialApp(
          home: WordHuntInfiniteJourneyMapScreen(
            publishedLevelCount: 15000,
            initialOrdinal: n,
            currentOrdinal: n,
            controller: controller,
            themeSchedule: JourneyThemeSchedule.production,
            artRegistry: art,
            artProvider: (_) => MemoryImage(png),
            stateForOrdinal:
                (ordinal) => WordHuntJourneyNodePresentation(
                  ordinal == n
                      ? WordHuntJourneyNodeState.current
                      : WordHuntJourneyNodeState.locked,
                ),
            onLevelTap: (_) => taps++,
          ),
        );
        await tester.pumpWidget(map(null));
        await tester.pumpAndSettle();
        final key = find.byKey(Key('word_hunt_journey_level_$n'));
        final before = tester.getRect(key),
            labels = tester.getSemantics(key).getSemanticsData();
        await tester.runAsync(
          () => precacheImage(
            ResizeImage(
              MemoryImage(png),
              width: 768,
              height: 1024,
              policy: ResizeImagePolicy.fit,
              allowUpscaling: false,
            ),
            tester.element(find.byType(WordHuntInfiniteJourneyMapScreen)),
          ),
        );
        expect(
          find.byKey(const ValueKey('journey_art_procedural_fallback')),
          findsWidgets,
        );
        await tester.pumpWidget(map(registry()));
        await tester.pumpAndSettle();
        expect(tester.getRect(key), before);
        expect(before.width, 68);
        expect(before.height, 68);
        final after = tester.getSemantics(key).getSemanticsData();
        expect(after.label, labels.label);
        expect(after.actions, labels.actions);
        await tester.tap(key);
        expect(taps, 1);
        expect(
          find.byType(JourneyChunkBackground).evaluate().length,
          lessThanOrEqualTo(3),
        );
        final painters =
            tester
                .widgetList<CustomPaint>(find.byType(CustomPaint))
                .map((w) => w.painter)
                .whereType<JourneyRasterPainter>()
                .toList();
        final all = painters.expand((p) => p.images.keys).toSet();
        expect(
          all.length,
          lessThanOrEqualTo(JourneyRasterBackground.maxResources),
        );
        expect(
          all.where((p) => p.endsWith('/base.webp')).length,
          lessThanOrEqualTo(JourneyRasterBackground.maxBaseResources),
        );
        if (n < 110)
          expect(
            find.byKey(const ValueKey('journey_art_raster_active')),
            findsWidgets,
          );
        if (n == 15000) {
          // The schedule cycles future themes; only this nearby forest kit loads.
          expect(all, {
            'forest_v1/base.webp',
            'forest_v1/left.webp',
            'forest_v1/right.webp',
          });
        }
        // Decoration painter is below corridor, and corridor below runtime route/nodes.
        final chunk = find.byKey(ValueKey('journey_chunk_${(n - 1) ~/ 20}'));
        final layers =
            tester
                .widgetList<CustomPaint>(
                  find.descendant(
                    of: chunk,
                    matching: find.byType(CustomPaint),
                  ),
                )
                .map((w) => w.painter.runtimeType)
                .toList();
        expect(
          layers.indexOf(JourneyReadabilityCorridor),
          greaterThan(layers.indexOf(JourneyRasterPainter)),
        );
        expect(tester.takeException(), isNull);
        handle.dispose();
      });
    }
  }
  testWidgets(
    'missing registered asset observable; fallback and locked action intact',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntInfiniteJourneyMapScreen(
            publishedLevelCount: 40,
            themeSchedule: JourneyThemeSchedule.production,
            artRegistry: registry(),
            artProvider: (_) => MemoryImage(Uint8List.fromList([0])),
            stateForOrdinal:
                (_) => const WordHuntJourneyNodePresentation(
                  WordHuntJourneyNodeState.locked,
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('journey_art_missing_fallback')),
        findsWidgets,
      );
      expect(find.byType(JourneyChunkBackground), findsWidgets);
      final data =
          tester
              .getSemantics(find.byKey(const Key('word_hunt_journey_level_1')))
              .getSemanticsData();
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      expect(tester.takeException(), isNull);
      handle.dispose();
    },
  );
  testWidgets('oversized viewport retains per-chunk resource admission caps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 14000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final png = (await tester.runAsync(fixture))!;
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntInfiniteJourneyMapScreen(
          publishedLevelCount: 15000,
          themeSchedule: JourneyThemeSchedule.production,
          artRegistry: registry(rich: true),
          artProvider: (_) => MemoryImage(png),
          stateForOrdinal:
              (_) => const WordHuntJourneyNodePresentation(
                WordHuntJourneyNodeState.locked,
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('journey_art_resource_fallback')),
      findsWidgets,
    );
    // The contract is per-chunk admission. Each admitted chunk never exceeds caps.
    for (final paint in tester.widgetList<CustomPaint>(
      find.byType(CustomPaint),
    )) {
      final painter = paint.painter;
      if (painter is JourneyRasterPainter) {
        expect(
          painter.images.length,
          lessThanOrEqualTo(JourneyRasterBackground.maxResources),
        );
      }
    }
    expect(tester.takeException(), isNull);
  });
}
