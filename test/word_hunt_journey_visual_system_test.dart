import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_codec.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';
import 'package:word_hunt_flutter_feature/word_hunt_gameplay_readability_contract.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_background.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_geometry.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_prototype_shell.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_theme.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_theme_demo.dart';

void size(WidgetTester tester, Size value) {
  tester.view.physicalSize = value;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

int semantics(WidgetTester tester) {
  var count = 0;
  void visit(SemanticsNode node) {
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

Finder levelNodes() => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('word_hunt_journey_level_'),
);

Future<List<int>> capture(
  WidgetTester tester,
  String name,
  Size dimensions,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('visual_capture')),
  );
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      expect(Size(image.width.toDouble(), image.height.toDouble()), dimensions);
      final bytes =
          (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!.buffer.asUint8List();
      final directory = Platform.environment['JOURNEY_VISUAL_PROOF_DIR'];
      if (directory != null) {
        // Opt-in test evidence outside the repository, never a golden baseline.
        final png =
            (await image.toByteData(
              format: ui.ImageByteFormat.png,
            ))!.buffer.asUint8List();
        await File('$directory/$name.png').writeAsBytes(png);
      }
      return bytes.toList();
    } finally {
      image.dispose();
    }
  }))!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Optional local evidence uses the existing SDK fonts. Portable CI geometry
  // and pixel-determinism tests need no host-specific font installation.
  setUpAll(() async {
    final directory = Platform.environment['JOURNEY_VISUAL_FONT_DIR'];
    if (directory == null) return;
    for (final pair in [
      ('Roboto', 'roboto-regular.ttf'),
      ('MaterialIcons', 'materialicons-regular.otf'),
    ]) {
      final loader = FontLoader(pair.$1)..addFont(
        Future.value(
          ByteData.sublistView(
            await File('$directory/${pair.$2}').readAsBytes(),
          ),
        ),
      );
      await loader.load();
    }
  });
  final schedule = JourneyThemeSchedule.synthetic;
  for (final viewport in [
    const Size(360, 800),
    const Size(412, 915),
    const Size(768, 1024),
  ]) {
    for (final count in [150, 1500, 15000]) {
      testWidgets('visual resources bounded: $count at $viewport', (
        tester,
      ) async {
        size(tester, viewport);
        final handle = tester.ensureSemantics();
        try {
          final controller = WordHuntJourneyMapController();
          var calls = 0;
          await tester.pumpWidget(
            RepaintBoundary(
              key: const Key('visual_capture'),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(fontFamily: 'Roboto'),
                home: WordHuntInfiniteJourneyMapScreen(
                  publishedLevelCount: count,
                  controller: controller,
                  themeSchedule: schedule,
                  stateForOrdinal: (_) {
                    calls++;
                    return const WordHuntJourneyNodePresentation(
                      WordHuntJourneyNodeState.current,
                    );
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (final requested in [50, 101, 150, 250, 350, 15000]) {
            calls = 0;
            controller.jumpToLevel(requested);
            await tester.pumpAndSettle();
            final backgrounds =
                tester
                    .widgetList<JourneyChunkBackground>(
                      find.byType(JourneyChunkBackground),
                    )
                    .toList();
            expect(backgrounds.length, lessThanOrEqualTo(3));
            expect(
              backgrounds.fold<int>(0, (n, b) => n + b.rows * 2),
              lessThanOrEqualTo(120),
            );
            for (final b in backgrounds) {
              expect(b.rows, lessThanOrEqualTo(20));
              expect(
                tester.getSize(find.byWidget(b)).height,
                lessThanOrEqualTo(2240),
              );
            }
            expect(levelNodes().evaluate().length, lessThanOrEqualTo(13));
            expect(semantics(tester), lessThan(40));
            expect(calls, lessThan(40));
            expect(
              find.byType(Image),
              findsNothing,
              reason: 'No decoded asset cache in procedural mode.',
            );
            final target = requested.clamp(1, count);
            expect(
              tester.getSize(
                find.byKey(Key('word_hunt_journey_level_$target')),
              ),
              const Size(68, 68),
            );
            debugPrint(
              'visual $count $viewport target=$target backgrounds=${backgrounds.length} decor=${backgrounds.fold<int>(0, (n, b) => n + b.rows * 2)} nodes=${levelNodes().evaluate().length} semantics=${semantics(tester)}',
            );
            expect(tester.takeException(), isNull);
          }
        } finally {
          handle.dispose();
        }
      });
    }
  }
  testWidgets(
    'theme replacement changes pixels, not geometry, identity, semantics or actions',
    (tester) async {
      size(tester, const Size(360, 800));
      final handle = tester.ensureSemantics();
      try {
        final taps = <int>[];
        Future<void> mount(JourneyThemeSchedule theme) async {
          await tester.pumpWidget(
            RepaintBoundary(
              key: const Key('visual_capture'),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(fontFamily: 'Roboto'),
                home: WordHuntInfiniteJourneyMapScreen(
                  publishedLevelCount: 15000,
                  initialOrdinal: 50,
                  themeSchedule: theme,
                  stateForOrdinal:
                      (_) => const WordHuntJourneyNodePresentation(
                        WordHuntJourneyNodeState.current,
                      ),
                  onLevelTap: taps.add,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        await mount(schedule);
        final node = find.byKey(const Key('word_hunt_journey_level_50'));
        final before = tester.getRect(node);
        final label = tester.getSemantics(node).getSemanticsData().label;
        final count = semantics(tester);
        final pixels = await capture(
          tester,
          'theme_before',
          const Size(360, 800),
        );
        await mount(
          JourneyThemeSchedule(themes: schedule.themes.reversed.toList()),
        );
        expect(tester.getRect(node), before);
        expect(tester.getSemantics(node).getSemanticsData().label, label);
        expect(semantics(tester), count);
        expect(
          await capture(tester, 'theme_after', const Size(360, 800)),
          isNot(pixels),
        );
        await tester.tap(node);
        expect(taps, [50]);
        expect(WordHuntJourneyGeometry.stableIdForOrdinal(50), 'level_000050');
      } finally {
        handle.dispose();
      }
    },
  );
  for (final proof in [
    (50, const Size(360, 800), 'coast_landmark'),
    (150, const Size(412, 915), 'forest'),
    (250, const Size(768, 1024), 'sky'),
    (350, const Size(768, 1024), 'night'),
    (100, const Size(360, 800), 'boundary_100_101'),
  ]) {
    testWidgets('deterministic actual Flutter map pixels: ${proof.$3}', (
      tester,
    ) async {
      size(tester, proof.$2);
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('visual_capture'),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Roboto'),
            home: WordHuntInfiniteJourneyMapScreen(
              publishedLevelCount: 15000,
              initialOrdinal: proof.$1,
              themeSchedule: schedule,
              stateForOrdinal:
                  (n) => WordHuntJourneyNodePresentation(
                    n % 3 == 0
                        ? WordHuntJourneyNodeState.locked
                        : WordHuntJourneyNodeState.completed2,
                  ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final first = await capture(tester, proof.$3, proof.$2);
      await tester.pump();
      expect(await capture(tester, proof.$3, proof.$2), first);
      expect(first.toSet().length, greaterThan(50));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'corrected gameplay surface renders four states inside safe zone',
    (tester) async {
      const viewport = Size(360, 800);
      size(tester, viewport);
      final bad = JourneyThemeDefinition(
        id: 'unsafe_demo_v1',
        scenery: JourneyScenery.night,
        top: Colors.white,
        bottom: const Color(0xFFDDDDDD),
        accent: Colors.white,
        readability: JourneyThemeReadability(
          contract: const WordHuntGameplayReadabilityContract(
            textMode: WordHuntTextMode.light,
            scrimColor: Colors.black,
            scrimOpacity: .02,
          ),
          samples: [Colors.white, const Color(0xFFDDDDDD)],
        ),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('visual_capture'),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Roboto'),
            home: Scaffold(body: JourneyThemeReadabilityDemo(theme: bad)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final resolved = bad.readability.resolve();
      for (final state in WordHuntReadableState.values) {
        final finder = find.byKey(
          ValueKey('journey_readability_${state.name}'),
        );
        final rect = tester.getRect(finder);
        expect(rect.left, greaterThanOrEqualTo(360 * .08));
        expect(rect.right, lessThanOrEqualTo(360 * .92));
        expect(rect.top, greaterThanOrEqualTo(800 * .18));
        expect(rect.bottom, lessThanOrEqualTo(800 * .82));
        final text = tester.widget<Text>(
          find.descendant(of: finder, matching: find.byType(Text)),
        );
        expect(text.style!.color, resolved.foregroundFor(state));
      }
      final pixels = await capture(tester, 'corrected_readability', viewport);
      // Actual rendered center-board background, not merely metadata arithmetic.
      final p = (400 * 360 + 180) * 4;
      final sample = Color.fromARGB(
        pixels[p + 3],
        pixels[p],
        pixels[p + 1],
        pixels[p + 2],
      );
      final luminance = sample.computeLuminance();
      expect(1.05 / (luminance + .05), greaterThanOrEqualTo(4.5));
    },
  );
  testWidgets(
    'shell Continue / Open Map / Go To preserve theme and save separation',
    (tester) async {
      size(tester, const Size(412, 915));
      final repo = InMemoryJourneySaveRepository(
        initialJson: WordHuntJourneySaveCodec().encode(
          WordHuntJourneySaveV1(
            bestStarsByStableId: {
              for (var n = 1; n < 300; n++) journeyStableId(n): 2,
            },
            lastViewedLevelId: journeyStableId(50),
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntJourneyPrototypeShell(
            syntheticProof: true,
            catalog: PublishedJourneyCatalog(levelCount: 15000),
            repository: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('journey_home_map')));
      await tester.pumpAndSettle();
      for (final ordinal in [50, 150, 250]) {
        if (ordinal != 50) {
          await tester.tap(find.byKey(const Key('journey_go_to')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const Key('journey_ordinal_input')),
            '$ordinal',
          );
          await tester.tap(find.byKey(const Key('journey_jump_submit')));
          await tester.pumpAndSettle();
        }
        final map = tester.widget<WordHuntInfiniteJourneyMapScreen>(
          find.byType(WordHuntInfiniteJourneyMapScreen),
        );
        expect(
          map.themeSchedule!.themeForOrdinal(ordinal).id,
          {50: 'coast_v1', 150: 'forest_v1', 250: 'sky_v1'}[ordinal],
        );
        expect(
          find.byKey(Key('word_hunt_journey_level_$ordinal')),
          findsOneWidget,
        );
      }
      await tester.tap(find.byKey(const Key('journey_map_continue')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('word_hunt_journey_level_300')),
        findsOneWidget,
      );
      expect((await repo.load())!.lastViewedLevelId, journeyStableId(250));
      await tester.tap(find.byKey(const Key('word_hunt_journey_level_300')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sentetik okunabilirlik demosu'));
      await tester.pumpAndSettle();
      expect(find.byType(JourneyThemeReadabilityDemo), findsOneWidget);
      expect(find.text('sky_v1'), findsOneWidget);
    },
  );
}
