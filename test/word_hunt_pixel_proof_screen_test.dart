import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_pixel_proof_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

// PR #132 final exact-head verification anchor. This comment intentionally
// changes no production/test behavior; it triggers the path-filtered Android
// 16 proof workflows after docs-only finalization commits.
// Final-gate child PR intentionally preserves the exact production tree.
// Final-cleanup gate also verifies the finalized pilot-status documentation.
void main() {
  test('pixel proof source is the untouched Issue 109 Photo 1 JPEG', () {
    final file = File(WordHuntPixelProofAssets.masterArt);
    expect(file.lengthSync(), 156589);
    expect(
      sha256.convert(file.readAsBytesSync()).toString(),
      'fb4597bb4d37b30cefeec2ba913c591fe9471529f80966830afd5b801a86fca3',
    );
    final source = img.decodeJpg(file.readAsBytesSync());
    expect(source, isNotNull);
    expect(source!.width, 720);
    expect(source.height, 1280);
  });

  testWidgets(
    'pixel proof keeps master art while visible progression follows real state',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(540, 960));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(home: WordHuntPixelProofScreen()),
      );
      await tester.pump();

      final masterArt = tester.widget<Image>(
        find.byKey(const Key('word_hunt_pixel_proof_master_art')),
      );
      expect(
        (masterArt.image as AssetImage).assetName,
        WordHuntPixelProofAssets.masterArt,
      );
      expect(masterArt.fit, BoxFit.fill);
      expect(masterArt.filterQuality, FilterQuality.none);

      expect(
        find.byKey(const Key('word_hunt_master_art_progress_counter_text')),
        findsOneWidget,
      );
      expect(find.text('0 / 60'), findsOneWidget);
      expect(
        find.byKey(const Key('word_hunt_master_art_level_1_locked')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('word_hunt_master_art_level_2_locked')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_master_art_level_10_locked')),
        findsOneWidget,
      );

      final nodeNine = tester.widget<Image>(
        find.byKey(const Key('word_hunt_pixel_proof_node_9_asset')),
      );
      expect(
        (nodeNine.image as AssetImage).assetName,
        WordHuntPixelProofAssets.nodeNineOpen,
      );
      expect(find.text('9'), findsOneWidget);

      final scene = find.byKey(const Key('word_hunt_pixel_proof_source_scene'));
      expect(
        find.descendant(of: scene, matching: find.byType(CustomPaint)),
        findsNothing,
      );
      for (var level = 1; level <= 10; level++) {
        expect(
          find.byKey(Key('word_hunt_pixel_proof_level_$level')),
          findsOneWidget,
        );
        expect(
          find.byKey(Key('word_hunt_master_art_level_${level}_stars')),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('visible stars and unlocks track progressed snapshot', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(720, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final route = WordHuntStarterContent.baslangicLimani;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        route.levels[0].id: 3,
        route.levels[1].id: 2,
        route.levels[2].id: 1,
        route.levels[3].id: 3,
        route.levels[4].id: 1,
        route.levels[5].id: 2,
        route.levels[6].id: 3,
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntPixelProofScreen(
          route: route,
          progress: progress,
          nodeNineOpenOverride: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('15 / 60'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_master_art_level_8_locked')),
      findsNothing,
      reason: '7 tamamlanınca normal 8 açılmalı.',
    );
    expect(
      find.byKey(const Key('word_hunt_master_art_level_9_locked')),
      findsOneWidget,
      reason: '8 tamamlanmadan 9 kilitli kalmalı.',
    );
    expect(
      find.byKey(const Key('word_hunt_master_art_level_10_locked')),
      findsOneWidget,
      reason: '9 tamamlanmadan final 10 kilitli kalmalı.',
    );

    expect(
      tester.widget<Icon>(
        find.byKey(const Key('word_hunt_master_art_level_1_star_3')),
      ).icon,
      Icons.star_rounded,
    );
    expect(
      tester.widget<Icon>(
        find.byKey(const Key('word_hunt_master_art_level_2_star_3')),
      ).icon,
      Icons.star_outline_rounded,
    );
  });

  testWidgets('pixel proof keeps progression callbacks behind invisible art', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final tapped = <int>[];

    await tester.pumpWidget(
      MaterialApp(home: WordHuntPixelProofScreen(onLevelTap: tapped.add)),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
    await tester.pump();
    expect(tapped, <int>[1]);

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_10')));
    await tester.pump();
    expect(tapped, <int>[
      1,
    ], reason: 'Progression kilitli final hitbox callback üretmemeli.');
  });

  testWidgets('pixel proof removes bottom chrome and preserves top callbacks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var backTaps = 0;
    var infoTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntPixelProofScreen(
          progress: const WordHuntProgressSnapshot(),
          onBack: () => backTaps++,
          onInfo: () => infoTaps++,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('word_hunt_pixel_proof_compass')),
      findsNothing,
    );
    expect(find.byKey(const Key('word_hunt_pixel_proof_book')), findsNothing);
    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_back')));
    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_info')));
    await tester.pump();
    expect(backTaps, 1);
    expect(infoTaps, 1);
  });
}
