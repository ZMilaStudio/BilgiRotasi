import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_background.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_gameplay_visual.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_geometry.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_theme.dart';
import 'package:word_hunt_flutter_feature/word_hunt_screens.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'word_hunt_journey_visual_system_test.dart' as proof;

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  final schedule = JourneyThemeSchedule.production;
  setUpAll(() async {
    final fonts = Platform.environment['JOURNEY_VISUAL_FONT_DIR'];
    if (fonts == null) return;
    for (final pair in [
      ('Roboto', 'roboto-regular.ttf'),
      ('MaterialIcons', 'materialicons-regular.otf'),
      ('serif', 'roboto-regular.ttf'),
    ]) {
      final loader = FontLoader(pair.$1)..addFont(
        Future.value(
          ByteData.sublistView(await File('$fonts/${pair.$2}').readAsBytes()),
        ),
      );
      await loader.load();
    }
  });
  test('four contiguous coastal bands, sparse landmarks, future scale', () {
    expect(schedule.bands.map((b) => (b.first, b.last)).toList(), [
      (1, 20),
      (21, 50),
      (51, 75),
      (76, 100),
    ]);
    for (var n = 1; n <= 100; n++) {
      expect(schedule.themeForOrdinal(n).scenery, JourneyScenery.coast);
      final frame = schedule.transitionForOrdinal(n);
      expect(frame.mix, inInclusiveRange(0, 1));
      expect(
        frame.to.readability.resolve().passesAll(frame.to.readability.samples),
        isTrue,
      );
      final bg = Color.lerp(frame.top, frame.bottom, .5)!;
      expect(contrast(const Color(0xFFD9C79A), bg), greaterThanOrEqualTo(3));
    }
    for (final n in [1, 20, 50, 75, 100]) {
      expect(schedule.landmarkForOrdinal(n), isNotNull);
    }
    expect(schedule.transitionForOrdinal(101).from.id, 'fener_beacon_v1');
    expect(schedule.transitionForOrdinal(101).mix, .1);
    expect(schedule.themeForOrdinal(150).scenery, JourneyScenery.forest);
    expect(schedule.themeForOrdinal(250).scenery, JourneyScenery.sky);
    expect(schedule.bands.length, 4);
    schedule.themeForOrdinal(15000);
    expect(
      () => JourneyThemeSchedule(
        themes: schedule.themes,
        bands: [
          JourneyThemeBand(1, 20, schedule.themes.first),
          JourneyThemeBand(22, 50, schedule.themes.first),
        ],
      ),
      throwsArgumentError,
    );
  });
  test(
    'actual gameplay plates fail closed across all cell states and biomes',
    () {
      for (final n in [1, 10, 20, 31, 40, 50, 75, 100, 150, 250, 350]) {
        final presentation = JourneyGameplayVisual.forOrdinal(n);
        final skin = presentation.skin;
        expect(skin.gridIdleAsset, isNull);
        expect(skin.gridSelectedAsset, isNull);
        for (final plate in [
          skin.gridIdleColor,
          skin.gridSelectedColor,
          skin.gridFoundColor,
          skin.gridErrorColor,
          skin.targetSurfaceColor,
          skin.bonusSurfaceColor,
          skin.foundSurfaceColor,
        ]) {
          expect(plate.a, 1);
          expect(
            contrast(skin.gridTextColor, plate),
            greaterThanOrEqualTo(4.5),
          );
        }
      }
    },
  );
  test('edge art exclusion never enters geometry hitboxes', () {
    const geometry = WordHuntJourneyGeometry();
    for (final width in [360.0, 412.0]) {
      for (var n = 1; n <= 101; n++) {
        final hit = geometry.globalHitRect(n, width);
        expect(hit.left, greaterThan(JourneyBackgroundPainter.edgeArtWidth));
        expect(
          hit.right,
          lessThan(width - JourneyBackgroundPainter.edgeArtWidth),
        );
        expect(hit.width, closeTo(68, 1e-9));
        expect(hit.height, closeTo(68, 1e-9));
      }
    }
  });
  for (final viewport in [const Size(360, 800), const Size(412, 915)]) {
    testWidgets('actual Journey gameplay readable proof $viewport', (
      tester,
    ) async {
      proof.size(tester, viewport);
      final level = WordHuntStarterContent.baslangicLimani.levels.first;
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('visual_capture'),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Roboto'),
            home: WordHuntLevelProductionScreen(
              level: level,
              infoCards: WordHuntStarterContent.infoCards,
              presentation: JourneyGameplayVisual.forOrdinal(1),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('word_hunt_production_cell_0_0')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await proof.capture(
        tester,
        'fener_gameplay_${viewport.width.toInt()}x${viewport.height.toInt()}',
        viewport,
      );
      await tester.pumpWidget(const SizedBox());
    });
    testWidgets('Fener foundation proof and bounded resources $viewport', (
      tester,
    ) async {
      proof.size(tester, viewport);
      final controller = WordHuntJourneyMapController();
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('visual_capture'),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Roboto'),
            home: WordHuntInfiniteJourneyMapScreen(
              publishedLevelCount: 15000,
              themeSchedule: schedule,
              controller: controller,
              stateForOrdinal:
                  (n) => WordHuntJourneyNodePresentation(
                    n % 4 == 0
                        ? WordHuntJourneyNodeState.locked
                        : n % 4 == 1
                        ? WordHuntJourneyNodeState.current
                        : WordHuntJourneyNodeState.values[2 + n % 3],
                    challenge: n % 20 == 0,
                  ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final n in [1, 20, 21, 50, 75, 100, 101, 15000]) {
        controller.jumpToLevel(n);
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byKey(Key('word_hunt_journey_level_$n'))),
          const Size(68, 68),
        );
        expect(
          find.byType(JourneyChunkBackground).evaluate().length,
          lessThanOrEqualTo(3),
        );
        expect(tester.takeException(), isNull);
        final name =
            'fener_${viewport.width.toInt()}x${viewport.height.toInt()}_L$n';
        final pixels = await proof.capture(tester, name, viewport);
        expect(await proof.capture(tester, name, viewport), pixels);
      }
    });
  }
}
