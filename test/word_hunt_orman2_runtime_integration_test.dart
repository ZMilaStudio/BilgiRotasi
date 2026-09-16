import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_artwork_presentation.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_themed_production_route_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Orman 2 immutable WebP byte gate remains frozen in repo', () {
    final file = File(WordHuntOrman2VisualTheme.assetPath);
    expect(file.existsSync(), isTrue);
    final bytes = file.readAsBytesSync();
    expect(bytes.length, 1109268);
    expect(
      sha256.convert(bytes).toString(),
      'aede5c6f08b6fe4cd64d17a1ef309e13256dde1c1e97fbee0c53b019f63c6c8d',
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WEBP');
  });

  test('Kadim Orman technical route identity remains orman-2 and validator-clean', () {
    final route = WordHuntOrman2Content.orman2;
    expect(route.id, 'orman-2');
    expect(route.title, 'Kadim Orman');
    expect(route.theme, 'orman');
    expect(route.levels, hasLength(10));
    expect(WordHuntDefinitionValidator.validateRoute(route), isEmpty);

    final orman1Ids = WordHuntOrmanContent.ormanYolu.levels
        .map((level) => level.id)
        .toSet();
    final orman2Ids = route.levels.map((level) => level.id).toSet();
    expect(orman1Ids.intersection(orman2Ids), isEmpty);
    for (var index = 0; index < route.levels.length; index++) {
      final pilot = route.levels[index];
      final source = WordHuntOrmanContent.ormanYolu.levels[index];
      expect(pilot.routeId, route.id);
      expect(pilot.index, index + 1);
      expect(pilot.grid, same(source.grid));
      expect(pilot.targetWords, same(source.targetWords));
      expect(pilot.type, source.type);
    }
    expect(route.levels.map((level) => level.index).toList(), <int>[1,2,3,4,5,6,7,8,9,10]);
  });

  test('Kadim Orman progression identity does not mix with Orman Yolu', () {
    final orman1Final = WordHuntOrmanContent.ormanYolu.levels.last;
    final orman2Final = WordHuntOrman2Content.orman2.levels.last;

    final orman1Only = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{orman1Final.id: 1},
    );
    expect(WordHuntRouteProgressEngine.isLevelCompleted(orman1Final, orman1Only), isTrue);
    expect(WordHuntRouteProgressEngine.isLevelCompleted(orman2Final, orman1Only), isFalse);

    final orman2Only = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{orman2Final.id: 1},
    );
    expect(WordHuntRouteProgressEngine.isLevelCompleted(orman1Final, orman2Only), isFalse);
    expect(WordHuntRouteProgressEngine.isLevelCompleted(orman2Final, orman2Only), isTrue);
  });

  test('Orman 2 theme uses approved generic artwork contract without recolor', () {
    const theme = WordHuntOrman2VisualTheme.production;
    expect(theme.backgroundAsset, WordHuntOrman2VisualTheme.assetPath);
    expect(theme.backgroundBase64AssetParts, isEmpty);
    expect(theme.backgroundFit, BoxFit.cover);
    expect(theme.backgroundAlignment, Alignment.center);
    expect(theme.backgroundBlurSigma, 0);
    expect(theme.backgroundScale, 1);
    expect(theme.backgroundContrast, 1);
    expect(theme.backgroundSaturation, 1);
    expect(theme.backgroundOverlayColor, Colors.transparent);
    expect(theme.backgroundVignetteStrength, 0);
    expect(theme.overlayDecorationsOnArtwork, isFalse);
    expect(
      theme.artworkOverlayMode,
      WordHuntArtworkOverlayMode.embeddedRouteLiveNodes,
    );
    expect(theme.referenceCanvasSize, const Size(411, 731));
    expect(theme.extendTallAmbientFromArtworkEdges, isTrue);
  });

  test('canonical WordHuntRouteMapGeometry normalizedStops stays exact', () {
    expect(
      WordHuntRouteMapGeometry.normalizedStops,
      const <Offset>[
        Offset(0.18, 0.10),
        Offset(0.48, 0.17),
        Offset(0.75, 0.27),
        Offset(0.66, 0.38),
        Offset(0.28, 0.47),
        Offset(0.18, 0.60),
        Offset(0.48, 0.67),
        Offset(0.78, 0.74),
        Offset(0.32, 0.82),
        Offset(0.60, 0.91),
      ],
    );
  });

  test('Kadim Orman is routable and visible through the production catalog', () {
    final entry = WordHuntRouteCatalog.entryForRouteId(
      WordHuntOrman2Content.orman2.id,
    );
    expect(entry, same(WordHuntRouteCatalog.orman2Pilot));
    expect(entry?.presentationKind, WordHuntRoutePresentationKind.themedReusable);
    expect(entry?.visualTheme, same(WordHuntOrman2VisualTheme.production));
    expect(
      WordHuntRouteCatalog.entries.any(
        (visible) => visible.route.id == WordHuntOrman2Content.orman2.id,
      ),
      isTrue,
    );
    expect(entry?.unlockRule.prerequisiteRoute, same(WordHuntOrmanContent.ormanYolu));
    expect(entry?.unlockRule.kind, WordHuntRouteUnlockKind.routeComplete);
  });

  testWidgets('Kadim Orman renders live Flutter nodes and chrome on clean artwork', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(411, 731);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntThemedProductionRouteScreen(
          route: WordHuntOrman2Content.orman2,
          visualTheme: WordHuntOrman2VisualTheme.production,
          progress: const WordHuntProgressSnapshot(),
          onBack: () {},
          onInfo: () {},
          onCompass: () {},
          onBook: () {},
          onLevelTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kadim Orman'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_themed_chrome_back')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_themed_chrome_info')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_themed_chrome_compass')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_themed_chrome_book')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_reusable_node_1_current')), findsOneWidget);
    for (var level = 2; level <= 10; level++) {
      expect(
        find.byKey(Key('word_hunt_reusable_node_${level}_locked')),
        findsOneWidget,
      );
    }
    final embeddedPath = tester.widget<SizedBox>(
      find.byKey(const Key('word_hunt_reusable_route_path')),
    );
    expect(embeddedPath, isA<SizedBox>());
    expect(tester.takeException(), isNull);
  });
}
