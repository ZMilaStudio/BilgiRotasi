import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:bilgi_rotasi/word_hunt/word_hunt_pixel_proof_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';

final out = Platform.environment['L10_DIAGNOSTIC_OUT']!;
const productionSha = 'ea18a5b83f12f9ef5f08c1c50a2e0724e916922a';
const captureKey = Key('l10_regression_capture');
const sourceKey = Key('word_hunt_pixel_proof_source_scene');
const coverKey = Key('word_hunt_l10_caption_cover');
const layerKey = Key('word_hunt_l10_caption_layer');
Widget app(Widget screen) =>
    RepaintBoundary(key: captureKey, child: MaterialApp(home: screen));

Future<void> loaded(WidgetTester t) async {
  await t.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await t.pump();
}

Future<img.Image> capture(WidgetTester t, String name) async {
  final b = t.renderObject<RenderRepaintBoundary>(find.byKey(captureKey));
  return (await t.runAsync(() async {
    final im = await b.toImage(pixelRatio: 1);
    try {
      final data = await im.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data!.buffer.asUint8List();
      final path = diagnosticPath(name);
      File(path).parent.createSync(recursive: true);
      File(path).writeAsBytesSync(bytes);
      return img.decodePng(bytes)!;
    } finally {
      im.dispose();
    }
  }))!;
}

Widget scene(List<Widget> children) => Scaffold(
  backgroundColor: Colors.black,
  body: SafeArea(
    child: ClipRect(
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox.fromSize(
            key: sourceKey,
            size: WordHuntPixelProofLayout.sourceSize,
            child: Stack(fit: StackFit.expand, children: children),
          ),
        ),
      ),
    ),
  ),
);

List<double> rectList(Rect r) => [r.left, r.top, r.right, r.bottom];
List<int> rgba(img.Pixel p) => [
  p.r.toInt(),
  p.g.toInt(),
  p.b.toInt(),
  p.a.toInt(),
];

Map<String, Object?> compare(img.Image before, img.Image after, Rect region) {
  final outside = <Map<String, Object?>>[];
  final all = <Offset>[];
  final expansions = <String, int>{for (var i = 0; i <= 3; i++) '$i': 0};
  for (var y = 0; y < before.height; y++)
    for (var x = 0; x < before.width; x++) {
      final a = rgba(before.getPixel(x, y)), b = rgba(after.getPixel(x, y));
      if (List.generate(4, (i) => a[i] == b[i]).every((v) => v)) continue;
      final pos = Offset(x.toDouble(), y.toDouble());
      all.add(pos);
      for (var i = 0; i <= 3; i++)
        if (!region.inflate(i.toDouble()).contains(pos)) {
          expansions['$i'] = expansions['$i']! + 1;
        }
      if (!region.contains(pos)) {
        final center = pos + const Offset(.5, .5);
        final dx = math.max(
          0.0,
          math.max(region.left - center.dx, center.dx - region.right),
        );
        final dy = math.max(
          0.0,
          math.max(region.top - center.dy, center.dy - region.bottom),
        );
        outside.add({
          'x': x,
          'y': y,
          'before': a,
          'after': b,
          'delta': List.generate(4, (i) => b[i] - a[i]),
          'position':
              pos.dx < region.left
                  ? 'left'
                  : pos.dx >= region.right
                  ? 'right'
                  : pos.dy < region.top
                  ? 'above'
                  : 'below',
          'centerDistanceToAllowed': math.sqrt(dx * dx + dy * dy),
          'minimumPixelDistance': math.sqrt(
            math.pow(
                  math.max(
                    0.0,
                    math.max(region.left - x, x - (region.right - 1)),
                  ),
                  2,
                ) +
                math.pow(
                  math.max(
                    0.0,
                    math.max(region.top - y, y - (region.bottom - 1)),
                  ),
                  2,
                ),
          ),
        });
      }
    }
  List<double>? bbox(List<Offset> points) =>
      points.isEmpty
          ? null
          : [
            points.map((p) => p.dx).reduce(math.min),
            points.map((p) => p.dy).reduce(math.min),
            points.map((p) => p.dx).reduce(math.max) + 1,
            points.map((p) => p.dy).reduce(math.max) + 1,
          ];
  return {
    'changedTotal': all.length,
    'outsideCount': outside.length,
    'outsideMinMax':
        outside.isEmpty
            ? null
            : {
              'minX': outside.map((p) => p['x'] as int).reduce(math.min),
              'maxX': outside.map((p) => p['x'] as int).reduce(math.max),
              'minY': outside.map((p) => p['y'] as int).reduce(math.min),
              'maxY': outside.map((p) => p['y'] as int).reduce(math.max),
            },
    'outside': outside,
    'allDiffBounds': bbox(all),
    'outsideBounds': bbox(
      outside
          .map(
            (p) =>
                Offset((p['x'] as int).toDouble(), (p['y'] as int).toDouble()),
          )
          .toList(),
    ),
    'expandedOutside': expansions,
  };
}

class ToggleScene extends StatefulWidget {
  const ToggleScene({required this.children, super.key});
  final List<Widget> children;
  @override
  State<ToggleScene> createState() => ToggleState();
}

class ToggleState extends State<ToggleScene> {
  int mode = 0;
  Widget? overlay;
  void set(int m, Widget? o) => setState(() {
    mode = m;
    overlay = o;
  });
  @override
  Widget build(BuildContext context) =>
      scene([...widget.children, if (mode != 0) overlay!]);
}

String diagnosticPath(String name) {
  final split = name.indexOf('_');
  final viewport = name.substring(0, split);
  final kind = name.substring(split + 1).toLowerCase();
  return '$out/${viewport.startsWith('360') ? '360' : '412'}/$kind.png';
}

void writeVisualEvidence(
  img.Image before,
  img.Image after,
  Rect allowed,
  Map<String, Object?> comparison,
  String directory,
) {
  final diff = img.Image(width: before.width, height: before.height);
  final marked = img.Image.from(after);
  for (var y = 0; y < before.height; y++) {
    for (var x = 0; x < before.width; x++) {
      final a = rgba(before.getPixel(x, y)), b = rgba(after.getPixel(x, y));
      diff.setPixelRgba(
        x,
        y,
        ((b[0] - a[0]).abs() * 8).clamp(0, 255),
        ((b[1] - a[1]).abs() * 8).clamp(0, 255),
        ((b[2] - a[2]).abs() * 8).clamp(0, 255),
        255,
      );
    }
  }
  img.drawRect(
    marked,
    x1: allowed.left.toInt(),
    y1: allowed.top.toInt(),
    x2: allowed.right.toInt() - 1,
    y2: allowed.bottom.toInt() - 1,
    color: img.ColorRgba8(255, 0, 0, 255),
  );
  final rows = <String>[
    'x,y,before_R,before_G,before_B,before_A,after_R,after_G,after_B,after_A,delta_R,delta_G,delta_B,delta_A,direction,min_distance',
  ];
  for (final raw in comparison['outside'] as List<Map<String, Object?>>) {
    final x = raw['x'] as int, y = raw['y'] as int;
    img.drawCircle(
      marked,
      x: x,
      y: y,
      radius: 2,
      color: img.ColorRgba8(0, 255, 255, 255),
    );
    rows.add(
      [
        x,
        y,
        ...raw['before'] as List<int>,
        ...raw['after'] as List<int>,
        ...raw['delta'] as List<int>,
        raw['position'],
        raw['minimumPixelDistance'],
      ].join(','),
    );
  }
  File('$directory/diff.png').writeAsBytesSync(img.encodePng(diff));
  File('$directory/outside_marked.png').writeAsBytesSync(img.encodePng(marked));
  File(
    '$directory/outside_pixels.csv',
  ).writeAsStringSync('${rows.join('\n')}\n');
}

void writeManifest() {
  final files =
      Directory(out)
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                !f.path.endsWith('manifest.json') &&
                !f.path.endsWith('test.log'),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final entries = <Map<String, Object?>>[];
  for (final file in files) {
    final bytes = file.readAsBytesSync();
    final decoded = file.path.endsWith('.png') ? img.decodePng(bytes) : null;
    entries.add({
      'path': file.path,
      'sha256': sha256.convert(bytes).toString(),
      'bytes': bytes.length,
      if (decoded != null) 'dimensions': [decoded.width, decoded.height],
    });
  }
  final flutterFile = File('$out/flutter-version.json');
  File('$out/manifest.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'diagnosticCommitSha':
          Platform.environment['DIAGNOSTIC_SHA'] ??
          'LOCAL_PREFLIGHT_UNCOMMITTED',
      'parentProductionSha': productionSha,
      'flutter':
          flutterFile.existsSync()
              ? jsonDecode(flutterFile.readAsStringSync())
              : 'NOT_RECORDED_LOCAL_PREFLIGHT',
      'os': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'dart': Platform.version,
      'runnerImage': Platform.environment['ImageOS'],
      'runnerImageVersion': Platform.environment['ImageVersion'],
      'dpr': 1,
      'provenance':
          Platform.environment['GITHUB_ACTIONS'] == 'true'
              ? 'Ubuntu GitHub Actions diagnostic, exact production widget, no font injection'
              : 'LOCAL WINDOWS PREFLIGHT, NOT UBUNTU EVIDENCE',
      'harnessSha256':
          sha256
              .convert(
                File(
                  'test/diagnostics/word_hunt_l10_six_pixel_diagnostic_test.dart',
                ).readAsBytesSync(),
              )
              .toString(),
      'productionRendererSha256':
          sha256
              .convert(
                File(
                  'packages/word_hunt_flutter_feature/lib/word_hunt_pixel_proof_screen.dart',
                ).readAsBytesSync(),
              )
              .toString(),
      'canonicalRegressionSha256':
          sha256
              .convert(
                File(
                  'test/word_hunt_l10_stage_final_label_test.dart',
                ).readAsBytesSync(),
              )
              .toString(),
      'files': entries,
      'testLogNote':
          'test.log is uploaded separately; excluded from hash manifest while still being written',
    }),
  );
}

void main() {
  setUpAll(() => Directory(out).createSync(recursive: true));
  tearDownAll(writeManifest);
  test(
    'pixel-table math self-check with synthetic pixels, not runtime evidence',
    () {
      final before = img.Image(width: 10, height: 10, numChannels: 4);
      final after = img.Image.from(before);
      for (var i = 0; i < 6; i++) {
        after.setPixelRgba(8, 3 + i, 20 + i, 30, 40, 255);
      }
      final measured = compare(before, after, const Rect.fromLTRB(2, 2, 8, 8));
      expect(measured['outsideCount'], 6);
      expect(measured['outsideMinMax'], {
        'minX': 8,
        'maxX': 8,
        'minY': 3,
        'maxY': 8,
      });
      expect(measured['expandedOutside'], {'0': 6, '1': 0, '2': 0, '3': 0});
      final rows = measured['outside'] as List<Map<String, Object?>>;
      expect(rows.first['before'], [0, 0, 0, 0]);
      expect(rows.first['after'], [20, 30, 40, 255]);
      expect(rows.first['delta'], [20, 30, 40, 255]);
      expect(rows.first['minimumPixelDistance'], 1);
    },
  );
  for (final size in const [Size(360, 800), Size(412, 915)]) {
    testWidgets('forensic isolation $size', (t) async {
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final vp = '${size.width.toInt()}x${size.height.toInt()}';
      final screen = WordHuntPixelProofScreen(
        progress: WordHuntProgressSnapshot(
          bestStarsByLevelId: {
            for (var i = 1; i <= 9; i++) 'baslangic-$i': i % 3 + 1,
          },
        ),
        onLevelTap: (_) {},
      );
      await t.pumpWidget(app(screen));
      await loaded(t);
      final cover = t.getRect(find.byKey(coverKey));
      final rb = t.renderObject<RenderBox>(find.byKey(sourceKey));
      final matrix = rb.getTransformTo(null);
      final sourceOrigin = rb.localToGlobal(Offset.zero);
      final scale =
          (rb.localToGlobal(const Offset(720, 0)).dx - sourceOrigin.dx) / 720;
      final allowed = Rect.fromLTRB(
        cover.left.floorToDouble(),
        cover.top.floorToDouble(),
        cover.right.ceilToDouble(),
        cover.bottom.ceilToDouble(),
      );
      final p = t.widget<Positioned>(find.byKey(coverKey));
      final d = t.widget<DecoratedBox>(
        find.descendant(
          of: find.byKey(coverKey),
          matching: find.byType(DecoratedBox),
        ),
      );
      final coverOnly = Positioned.fromRect(
        rect: const Rect.fromLTRB(477, 1006, 567, 1060),
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: d.decoration,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
      final stack = t.widget<Stack>(
        find
            .descendant(of: find.byKey(sourceKey), matching: find.byType(Stack))
            .first,
      );
      final children = stack.children.where((c) => c.key != layerKey).toList();
      final sem = t.ensureSemantics();
      await t.pump();
      sem.dispose();
      final after = await capture(t, '${vp}_AFTER');
      await t.tap(find.byKey(const Key('word_hunt_pixel_proof_level_10')));
      await t.pumpWidget(app(scene(children)));
      await loaded(t);
      final before = await capture(t, '${vp}_BEFORE');
      await t.pump();
      final beforeRepeat = await capture(t, '${vp}_BEFORE_REPEAT');
      await t.pumpWidget(app(scene([...children, coverOnly])));
      await loaded(t);
      final only = await capture(t, '${vp}_COVER_ONLY');
      await t.pumpWidget(app(scene([...children, p])));
      await loaded(t);
      final reconstructedAfter = await capture(t, '${vp}_RECONSTRUCTED_AFTER');
      final toggleKey = GlobalKey<ToggleState>();
      await t.pumpWidget(app(ToggleScene(key: toggleKey, children: children)));
      await loaded(t);
      final sameBefore = await capture(t, '${vp}_SAME_TREE_BEFORE');
      toggleKey.currentState!.set(1, coverOnly);
      await t.pump();
      final sameCover = await capture(t, '${vp}_SAME_TREE_COVER');
      toggleKey.currentState!.set(2, p);
      await t.pump();
      final sameAfter = await capture(t, '${vp}_SAME_TREE_AFTER');
      final result = {
        'authority': 'ea18a5b83f12f9ef5f08c1c50a2e0724e916922a',
        'environment': Platform.operatingSystem,
        'viewport': [size.width, size.height],
        'dpr': 1,
        'sourceSize': [720, 1280],
        'scale': scale,
        'origin': [sourceOrigin.dx, sourceOrigin.dy],
        'matrix': matrix.storage.toList(),
        'sourceRect': [477, 1006, 567, 1060],
        'viewportRect': rectList(cover),
        'allowed': rectList(allowed),
        'exactComparison': compare(before, after, allowed),
        'legacyToCover': compare(before, only, allowed),
        'coverToText': compare(only, after, allowed),
        'productionToReconstructedAfter': compare(
          after,
          reconstructedAfter,
          allowed,
        ),
        'beforeRepeat': compare(before, beforeRepeat, allowed),
        'beforeToSameTree': compare(before, sameBefore, allowed),
        'sameTreeLegacyToCover': compare(sameBefore, sameCover, allowed),
        'sameTreeCoverToText': compare(sameCover, sameAfter, allowed),
        'sameTreeToProduction': compare(sameAfter, after, allowed),
      };
      final directory = '$out/${vp.startsWith('360') ? '360' : '412'}';
      writeVisualEvidence(
        before,
        after,
        allowed,
        result['exactComparison'] as Map<String, Object?>,
        directory,
      );
      File(
        '$directory/evidence.json',
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(result));
      print('$vp exact ${result['exactComparison']}');
      print('$vp cover-only ${result['legacyToCover']}');
      print('$vp text contribution ${result['coverToText']}');
      final expectedScale = size.width / 720;
      final expectedOrigin = Offset(
        0,
        (size.height - 1280 * expectedScale) / 2,
      );
      expect((scale - expectedScale).abs(), lessThan(1e-9));
      expect((sourceOrigin - expectedOrigin).distance, lessThan(1e-9));
      expect(
        cover,
        MatrixUtils.transformRect(
          matrix,
          const Rect.fromLTRB(477, 1006, 567, 1060),
        ),
      );
      final expectedAllowed =
          size.width == 360
              ? const Rect.fromLTRB(238, 583, 284, 610)
              : const Rect.fromLTRB(272, 666, 325, 698);
      expect(allowed, expectedAllowed);
      // Outside counts are evidence, not a weakened canonical assertion.
      // The unchanged canonical regression remains authoritative on production.
      expect(
        (result['productionToReconstructedAfter'] as Map)['changedTotal'],
        0,
        reason: 'Diagnostic reconstructed AFTER must match production pixels',
      );
      expect(t.takeException(), isNull);
    });
  }
}
