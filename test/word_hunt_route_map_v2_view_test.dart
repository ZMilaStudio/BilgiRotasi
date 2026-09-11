import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_map_v2_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const proofProgress = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'baslangic-1': 3,
      'baslangic-2': 3,
      'baslangic-3': 3,
      'baslangic-4': 3,
      'baslangic-5': 3,
      'baslangic-6': 3,
      'baslangic-7': 3,
    },
  );

  const proofProgressThroughEight = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'baslangic-1': 3,
      'baslangic-2': 3,
      'baslangic-3': 3,
      'baslangic-4': 3,
      'baslangic-5': 3,
      'baslangic-6': 3,
      'baslangic-7': 3,
      'baslangic-8': 3,
    },
  );

  testWidgets('v2 route map renders the approved ten-stop composition', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntRouteMapV2Screen(progress: proofProgress),
      ),
    );

    expect(find.text('KELİME AVI'), findsOneWidget);
    expect(find.text('BAŞLANGIÇ LİMANI'), findsOneWidget);
    expect(find.text('MEYDAN OKUMA'), findsOneWidget);
    expect(find.text('BONUS DURAK'), findsNothing);
    expect(find.text('ROTA FİNALİ'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_v2_scene')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_v2_compass')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_v2_book')), findsOneWidget);

    for (var index = 1; index <= 10; index++) {
      expect(find.byKey(Key('word_hunt_v2_level_$index')), findsOneWidget);
    }
  });

  testWidgets('v2 opens 8 first, then 9, while final 10 stays locked', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteMapV2Screen(
          progress: proofProgress,
          onLevelTap: (index) => tapped = index,
        ),
      ),
    );

    final level8 = find.byKey(const Key('word_hunt_v2_level_8'));
    await tester.ensureVisible(level8);
    await tester.pumpAndSettle();
    await tester.tap(level8);
    await tester.pump();
    expect(tapped, 8);

    tapped = 0;
    final level9 = find.byKey(const Key('word_hunt_v2_level_9'));
    await tester.ensureVisible(level9);
    await tester.pumpAndSettle();
    await tester.tap(level9, warnIfMissed: false);
    await tester.pump();
    expect(tapped, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteMapV2Screen(
          progress: proofProgressThroughEight,
          onLevelTap: (index) => tapped = index,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final unlockedLevel9 = find.byKey(const Key('word_hunt_v2_level_9'));
    await tester.ensureVisible(unlockedLevel9);
    await tester.pumpAndSettle();
    await tester.tap(unlockedLevel9);
    await tester.pump();
    expect(tapped, 9);

    tapped = 0;
    final level10 = find.byKey(const Key('word_hunt_v2_level_10'));
    await tester.ensureVisible(level10);
    await tester.pumpAndSettle();
    await tester.tap(level10, warnIfMissed: false);
    await tester.pump();
    expect(tapped, 0);
  });

  testWidgets('v2 remains overflow-free on a narrow Android-sized surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntRouteMapV2Screen(progress: proofProgress),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('word_hunt_v2_scene')), findsOneWidget);
  });

  testWidgets('illustrated Baslangic Limani asset is bundled as JPEG', (
    tester,
  ) async {
    final data = await rootBundle.load(
      'assets/word_hunt/baslangic_limani_bg.jpg',
    );
    expect(data.lengthInBytes, greaterThan(1024));

    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    expect(bytes[0], 0xFF);
    expect(bytes[1], 0xD8);
    expect(bytes[bytes.length - 2], 0xFF);
    expect(bytes[bytes.length - 1], 0xD9);
  });
}
