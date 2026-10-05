import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_geometry.dart';

int semanticsCount(WidgetTester tester, {bool levelsOnly = false}) {
  var count = 0;
  void visit(SemanticsNode node) {
    if (!levelsOnly || node.getSemanticsData().label.startsWith('Bölüm '))
      count++;
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return count;
}

Finder nodes() => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('word_hunt_journey_level_'),
);
Finder chunks() => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('journey_chunk_'),
);

void configure(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('chunk seam is painted continuously across L20 to L21', (
    tester,
  ) async {
    configure(tester, const Size(360, 800));
    const key = Key('journey_seam_capture');
    const geometry = WordHuntJourneyGeometry();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          home: WordHuntInfiniteJourneyMapScreen(
            publishedLevelCount: 15000,
            initialOrdinal: 20,
            stateForOrdinal:
                (_) => const WordHuntJourneyNodePresentation(
                  WordHuntJourneyNodeState.current,
                ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1);
      try {
        final data =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        final seam = geometry.curveForEdge(20, 360).halves.$1.end;
        final y = (seam.dy - geometry.offsetForOrdinal(20, 15000, 800)).round();
        for (var row = y - 2; row <= y + 2; row++) {
          var painted = false;
          for (var x = seam.dx.round() - 3; x <= seam.dx.round() + 3; x++) {
            final offset = (row * image.width + x) * 4;
            if (data.getUint8(offset) > 120 && data.getUint8(offset + 1) > 120)
              painted = true;
          }
          expect(
            painted,
            isTrue,
            reason: 'No background-only row at chunk seam y=$row',
          );
        }
      } finally {
        image.dispose();
      }
    });
  });
  for (final viewport in [
    const Size(360, 800),
    const Size(412, 915),
    const Size(768, 1024),
  ]) {
    for (final count in [150, 1500, 15000]) {
      testWidgets(
        '$count levels: bounded widgets/semantics and direct jumps at $viewport',
        (tester) async {
          configure(tester, viewport);
          final handle = tester.ensureSemantics();
          try {
            final controller = WordHuntJourneyMapController();
            var resolutions = 0;
            await tester.pumpWidget(
              MaterialApp(
                home: WordHuntInfiniteJourneyMapScreen(
                  publishedLevelCount: count,
                  initialOrdinal: count - 1,
                  currentOrdinal: 1,
                  controller: controller,
                  stateForOrdinal: (n) {
                    resolutions++;
                    return const WordHuntJourneyNodePresentation(
                      WordHuntJourneyNodeState.current,
                    );
                  },
                  onLevelTap: (_) {},
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              find.byKey(Key('word_hunt_journey_level_${count - 1}')),
              findsOneWidget,
            );
            expect(
              resolutions,
              lessThan(40),
              reason:
                  'Initial jump must not materialize the preceding catalog.',
            );
            for (final requested in [1, 500, 5000, 15000, 0, 99999]) {
              resolutions = 0;
              controller.jumpToLevel(requested);
              await tester.pumpAndSettle();
              final target = requested.clamp(1, count);
              final finder = find.byKey(Key('word_hunt_journey_level_$target'));
              expect(finder, findsOneWidget);
              expect(tester.getSize(finder), const Size(68, 68));
              final rect = tester.getRect(finder);
              expect(rect.left, greaterThanOrEqualTo(0));
              expect(rect.right, lessThanOrEqualTo(viewport.width));
              expect(rect.top, greaterThanOrEqualTo(0));
              expect(rect.bottom, lessThanOrEqualTo(viewport.height));
              expect(chunks().evaluate().length, lessThanOrEqualTo(3));
              expect(nodes().evaluate().length, lessThanOrEqualTo(13));
              expect(
                semanticsCount(tester, levelsOnly: true),
                lessThanOrEqualTo(11),
              );
              expect(semanticsCount(tester), lessThan(40));
              expect(
                find.byWidgetPredicate((_) => true).evaluate().length,
                lessThan(650),
              );
              expect(
                resolutions,
                lessThan(40),
                reason: 'Jump must not walk intermediate chunks.',
              );
              for (final element in find.byType(CustomPaint).evaluate()) {
                final widget = element.widget as CustomPaint;
                if (widget.painter != null) {
                  expect(
                    tester.getSize(find.byWidget(widget)).height,
                    lessThanOrEqualTo(2240),
                  );
                }
              }
              debugPrint(
                'journey $count $viewport jump=$target chunks=${chunks().evaluate().length} nodes=${nodes().evaluate().length} semantics=${semanticsCount(tester, levelsOnly: true)} resolutions=$resolutions',
              );
              expect(tester.takeException(), isNull);
            }
            await tester.tap(
              find.byKey(const Key('word_hunt_journey_continue')),
            );
            await tester.pumpAndSettle();
            expect(
              find.byKey(const Key('word_hunt_journey_level_1')),
              findsOneWidget,
            );
          } finally {
            handle.dispose();
          }
        },
      );
    }
  }
  testWidgets(
    'locked challenge, current and earned-star milestone retain independent actions',
    (tester) async {
      configure(tester, const Size(360, 800));
      final handle = tester.ensureSemantics();
      try {
        final taps = <int>[];
        await tester.pumpWidget(
          MaterialApp(
            home: WordHuntInfiniteJourneyMapScreen(
              publishedLevelCount: 40,
              stateForOrdinal:
                  (n) => WordHuntJourneyNodePresentation(
                    n == 1 || n > 5
                        ? WordHuntJourneyNodeState.locked
                        : n == 2
                        ? WordHuntJourneyNodeState.current
                        : WordHuntJourneyNodeState.values[n.clamp(3, 5) - 1],
                    challenge: n == 1 || n == 2,
                    milestone: n == 5,
                  ),
              onLevelTap: taps.add,
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (var n = 1; n <= 5; n++) {
          final finder = find.byKey(Key('word_hunt_journey_level_$n'));
          final data = tester.getSemantics(finder).getSemanticsData();
          expect(data.hasAction(ui.SemanticsAction.tap), n != 1);
          expect(
            data.flagsCollection.isEnabled,
            n != 1 ? ui.Tristate.isTrue : ui.Tristate.isFalse,
          );
          expect(data.label, contains(n == 1 ? 'kilitli' : 'açık'));
          if (n <= 2) expect(data.label, contains('meydan okuma'));
          if (n >= 3) expect(data.label, contains('${n - 2} yıldız'));
          if (n == 5) expect(data.label, contains('kilometre taşı'));
          await tester.tap(finder);
        }
        expect(taps, [2, 3, 4, 5]);
        expect(find.byIcon(Icons.star), findsNWidgets(6));
        expect(find.byIcon(Icons.star_outline), findsNWidgets(3));
        final root =
            tester
                .binding
                .renderViews
                .single
                .owner!
                .semanticsOwner!
                .rootSemanticsNode!;
        var labels = <String>[];
        void visit(SemanticsNode node) {
          final label = node.getSemanticsData().label;
          if (label.startsWith('Bölüm ')) labels.add(label);
          node.visitChildren((child) {
            visit(child);
            return true;
          });
        }

        visit(root);
        expect(
          labels.toSet().length,
          labels.length,
          reason: 'No duplicate child text/tap semantics.',
        );
      } finally {
        handle.dispose();
      }
    },
  );
  testWidgets('pre-attachment jump, callback absence and partial last chunk', (
    tester,
  ) async {
    configure(tester, const Size(412, 915));
    final handle = tester.ensureSemantics();
    try {
      final controller = WordHuntJourneyMapController()..jumpToLevel(21);
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntInfiniteJourneyMapScreen(
            publishedLevelCount: 21,
            controller: controller,
            stateForOrdinal:
                (_) => const WordHuntJourneyNodePresentation(
                  WordHuntJourneyNodeState.current,
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final node = find.byKey(const Key('word_hunt_journey_level_21'));
      expect(node, findsOneWidget);
      expect(
        tester
            .getSemantics(node)
            .getSemanticsData()
            .hasAction(ui.SemanticsAction.tap),
        isFalse,
      );
      expect(find.byKey(const Key('word_hunt_journey_level_22')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      controller.jumpToLevel(1);
      expect(tester.takeException(), isNull);
    } finally {
      handle.dispose();
    }
  });
}
