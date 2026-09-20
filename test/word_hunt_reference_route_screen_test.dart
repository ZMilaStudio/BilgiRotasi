import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reference_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpReferenceRoute(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(411, 891));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntReferenceRouteScreen(
          sceneAssetPath: 'assets/word_hunt/baslangic_limani_bg.jpg',
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpCanonicalReferenceRoute(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(
      WordHuntReferenceRouteLayout.canonicalSize,
    );
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntReferenceRouteScreen(
          sceneAssetPath: 'assets/word_hunt/baslangic_limani_bg.jpg',
        ),
      ),
    );
    await tester.pump();
  }

  Offset centerOf(WidgetTester tester, int level) {
    return tester.getCenter(find.byKey(Key('word_hunt_route_stop_orb_$level')));
  }

  Rect rectOf(WidgetTester tester, int level) {
    return tester.getRect(find.byKey(Key('word_hunt_reference_level_$level')));
  }

  test(
    'reference route segment palette follows destination type and lock state',
    () {
      expect(
        WordHuntReferenceRouteVisualContract.segmentStyleFor(
          destinationType: WordHuntLevelType.normal,
          unlocked: true,
        ),
        WordHuntReferenceRouteSegmentStyle.normal,
      );
      expect(
        WordHuntReferenceRouteVisualContract.segmentStyleFor(
          destinationType: WordHuntLevelType.challenge,
          unlocked: true,
        ),
        WordHuntReferenceRouteSegmentStyle.challenge,
      );
      expect(
        WordHuntReferenceRouteVisualContract.segmentStyleFor(
          destinationType: WordHuntLevelType.bonus,
          unlocked: true,
        ),
        WordHuntReferenceRouteSegmentStyle.bonus,
      );
      expect(
        WordHuntReferenceRouteVisualContract.segmentStyleFor(
          destinationType: WordHuntLevelType.routeFinal,
          unlocked: true,
        ),
        WordHuntReferenceRouteSegmentStyle.finalStop,
      );
      expect(
        WordHuntReferenceRouteVisualContract.segmentStyleFor(
          destinationType: WordHuntLevelType.bonus,
          unlocked: false,
        ),
        WordHuntReferenceRouteSegmentStyle.locked,
        reason: 'Kilitli rota parçası özel hedef rengini kullanmamalı.',
      );
      expect(
        WordHuntReferenceRouteVisualContract.segmentStyleFor(
          destinationType: WordHuntLevelType.routeFinal,
          unlocked: false,
        ),
        WordHuntReferenceRouteSegmentStyle.finalStop,
        reason:
            'Kilitli final oynanamaz kalırken referanstaki sıcak altın hedef yolunu korumalı.',
      );
    },
  );

  testWidgets(
    'approved top chrome keeps real route data in reference hierarchy',
    (tester) async {
      await pumpReferenceRoute(tester);

      expect(find.text('KELİME AVI'), findsOneWidget);
      expect(find.text('BAŞLANGIÇ LİMANI'), findsOneWidget);
      expect(find.text('0 / 30'), findsOneWidget);
      expect(find.text('Kapı: 18'), findsOneWidget);
    },
  );

  testWidgets(
    'production route uses MASTER ART with transparent progression hitboxes',
    (tester) async {
      final tappedLevels = <int>[];
      await tester.binding.setSurfaceSize(
        WordHuntReferenceRouteLayout.canonicalSize,
      );
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntReferenceRouteScreen(
            progress: const WordHuntProgressSnapshot(
              bestStarsByLevelId: <String, int>{
                'baslangic-1': 3,
                'baslangic-2': 3,
                'baslangic-3': 3,
                'baslangic-4': 3,
                'baslangic-5': 3,
                'baslangic-6': 3,
                'baslangic-7': 3,
              },
            ),
            onLevelTap: tappedLevels.add,
          ),
        ),
      );
      await tester.pump();

      final masterArt = tester.widget<Image>(
        find.byKey(const Key('word_hunt_pixel_proof_master_art')),
      );
      expect(
        (masterArt.image as AssetImage).assetName,
        'assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg',
      );
      expect(
        find.byKey(const Key('word_hunt_pixel_proof_node_9_override')),
        findsNothing,
        reason: '8 tamamlanmadan 9 açık görünmemelidir.',
      );
      expect(
        find.byKey(const Key('word_hunt_reference_route_area')),
        findsNothing,
        reason: 'MASTER ART üzerine eski layered rota ikinci kez çizilmemeli.',
      );
      expect(
        find.byKey(const Key('word_hunt_route_stop_asset_1')),
        findsNothing,
        reason: 'MASTER ART üzerine eski görünür node sanatı bindirilmemeli.',
      );

      await tester.tap(
        find.byKey(const Key('word_hunt_pixel_proof_level_8')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(tappedLevels, <int>[8]);

      await tester.tap(
        find.byKey(const Key('word_hunt_pixel_proof_level_9')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(
        tappedLevels,
        <int>[8],
        reason: '8 tamamlanmadan 9 callback üretmemelidir.',
      );

      await tester.tap(
        find.byKey(const Key('word_hunt_pixel_proof_level_10')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(
        tappedLevels,
        <int>[8],
        reason: '9 tamamlanmadan final 10 callback üretmemelidir.',
      );
    },
  );

  testWidgets('route centers follow the canonical 1080x1920 pixel contract', (
    tester,
  ) async {
    await pumpCanonicalReferenceRoute(tester);

    const expected = <Offset>[
      Offset(204.12, 456.96),
      Offset(478.44, 493.44),
      Offset(693.36, 585.60),
      Offset(867.24, 716.16),
      Offset(361.80, 869.76),
      Offset(180.36, 1059.84),
      Offset(496.80, 1119.36),
      Offset(721.44, 1182.72),
      Offset(254.88, 1338.24),
      Offset(528.12, 1530.24),
    ];

    for (var index = 0; index < expected.length; index++) {
      final actual = tester.getCenter(
        find.byKey(Key('word_hunt_route_stop_orb_${index + 1}')),
      );
      expect(
        actual.dx,
        closeTo(expected[index].dx, 0.01),
        reason: '${index + 1}. durağın yatay merkezi referansla eşleşmeli.',
      );
      expect(
        actual.dy,
        closeTo(expected[index].dy, 0.01),
        reason: '${index + 1}. durağın dikey merkezi referansla eşleşmeli.',
      );
    }
  });

  test(
    'binding reference locks the measured panel and route curves',
    () {
      expect(
        WordHuntReferenceRouteLayout.canonicalSize,
        const Size(1080, 1920),
      );
      expect(
        WordHuntReferenceRouteLayout.topPanel,
        const Rect.fromLTRB(87.48, 134.40, 997.92, 303.36),
      );
      expect(WordHuntReferenceRouteLayout.routeControls, hasLength(9));
      expect(
        WordHuntReferenceRouteLayout.routeControls,
        const <(Offset, Offset)>[
          (Offset(291.60, 453.12), Offset(394.20, 464.64)),
          (Offset(556.20, 510.72), Offset(631.80, 549.12)),
          (Offset(760.32, 624.00), Offset(820.80, 668.16)),
          (Offset(840.24, 787.20), Offset(561.60, 812.16)),
          (Offset(270.00, 921.60), Offset(205.20, 988.80)),
          (Offset(264.60, 1084.80), Offset(388.80, 1104.00)),
          (Offset(577.80, 1132.80), Offset(658.80, 1157.76)),
          (Offset(648.00, 1238.40), Offset(361.80, 1267.20)),
          (Offset(243.00, 1432.32), Offset(410.40, 1488.00)),
        ],
      );
      expect(
        WordHuntReferenceRouteLayout.specialPlaques[5],
        const Rect.fromLTWH(426, 825, 324, 88),
      );
      expect(
        WordHuntReferenceRouteLayout.specialPlaques[10],
        const Rect.fromLTWH(613, 1488, 250, 110),
      );
      expect(
        WordHuntReferenceRouteLayout.finalCrown,
        const Rect.fromLTWH(451, 1417, 154, 94),
      );
      expect(
        WordHuntReferenceRouteLayout.backgroundSceneOffset,
        const Offset(0, 90),
      );
    },
  );

  test('canonical scene transform is shared and deterministic', () {
    final identity = WordHuntCanonicalSceneTransform.cover(
      const Size(1080, 1920),
    );
    expect(identity.scale, 1);
    expect(identity.translation, Offset.zero);
    expect(identity.sceneRect, Offset.zero & const Size(1080, 1920));

    final narrow = WordHuntCanonicalSceneTransform.cover(const Size(411, 891));
    expect(narrow.scale, closeTo(891 / 1920, 0.000001));
    expect(
      narrow.toViewport(WordHuntReferenceRouteLayout.stops.first),
      narrow.translation +
          WordHuntReferenceRouteLayout.stops.first * narrow.scale,
    );
  });

  testWidgets('background and overlays share one canonical scene transform', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(411, 891));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntReferenceRouteScreen(
          sceneAssetPath: 'assets/word_hunt/baslangic_limani_bg.jpg',
        ),
      ),
    );
    await tester.pump();

    final scene = find.byKey(const Key('word_hunt_reference_canonical_scene'));
    expect(scene, findsOneWidget);
    expect(
      find.descendant(
        of: scene,
        matching: find.byKey(const Key('word_hunt_reference_background_asset')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: scene,
        matching: find.byKey(const Key('word_hunt_reference_route_area')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('reference layered map keeps top chrome and removes bottom controls', (
    tester,
  ) async {
    await pumpCanonicalReferenceRoute(tester);

    final panel = tester.getRect(
      find.byKey(const Key('word_hunt_reference_top_panel')),
    );
    expect(panel, WordHuntReferenceRouteLayout.topPanel);
    expect(find.byKey(const Key('word_hunt_reference_back')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_reference_info')), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_reference_compass')),
      findsNothing,
    );
    expect(find.byKey(const Key('word_hunt_reference_book')), findsNothing);
    expect(
      find.byKey(const Key('word_hunt_reference_compass_asset')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('word_hunt_reference_book_asset')),
      findsNothing,
    );
  });

  testWidgets('challenge plaque and final crown follow canonical bounds', (
    tester,
  ) async {
    await pumpCanonicalReferenceRoute(tester);

    for (final level in <int>[5, 10]) {
      final expected = WordHuntReferenceRouteLayout.specialPlaques[level]!;
      final actual = tester.getRect(
        find.byKey(Key('word_hunt_route_stop_plaque_$level')),
      );
      expect(actual.left, closeTo(expected.left, 1.1));
      expect(actual.top, closeTo(expected.top, 1.1));
      expect(actual.width, closeTo(expected.width, 1.1));
      expect(actual.height, closeTo(expected.height, 1.1));
    }
    expect(
      find.byKey(const Key('word_hunt_route_stop_plaque_8')),
      findsNothing,
    );

    final crown = tester.getRect(
      find.byKey(const Key('word_hunt_route_stop_crown_10')),
    );
    expect(
      crown.left,
      closeTo(WordHuntReferenceRouteLayout.finalCrown.left, 1.1),
    );
    expect(
      crown.top,
      closeTo(WordHuntReferenceRouteLayout.finalCrown.top, 1.1),
    );
    expect(crown.width, WordHuntReferenceRouteLayout.finalCrown.width);
    expect(crown.height, WordHuntReferenceRouteLayout.finalCrown.height);
  });

  testWidgets('Android 16 proof viewport has no render overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: WordHuntReferenceRouteScreen()),
    );
    await tester.pump();
    expect(
      tester.takeException(),
      isNull,
      reason: 'Canonical Android 16 tuvalinde panel veya rota taşmamalı.',
    );
  });

  testWidgets('411x891 narrow phone keeps one scene without render overflow', (
    tester,
  ) async {
    await pumpReferenceRoute(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reference route follows the approved composition hierarchy', (
    tester,
  ) async {
    await pumpReferenceRoute(tester);

    for (var level = 1; level <= 10; level++) {
      expect(
        find.byKey(Key('word_hunt_reference_level_$level')),
        findsOneWidget,
      );
    }

    final one = centerOf(tester, 1);
    final two = centerOf(tester, 2);
    final three = centerOf(tester, 3);
    final four = centerOf(tester, 4);
    final five = centerOf(tester, 5);
    final six = centerOf(tester, 6);
    final seven = centerOf(tester, 7);
    final eight = centerOf(tester, 8);
    final nine = centerOf(tester, 9);
    final ten = centerOf(tester, 10);

    expect(one.dy, lessThan(five.dy));
    expect(two.dy, lessThan(five.dy));
    expect(three.dy, lessThan(five.dy));
    expect(four.dy, lessThan(five.dy));

    expect(five.dx, lessThan(411 * 0.48));
    expect(six.dx, lessThan(seven.dx));
    expect(seven.dx - nine.dx, greaterThan(85));
    expect(eight.dx, greaterThan(five.dx));
    expect(nine.dx, lessThan(seven.dx));
    expect(ten.dy, greaterThan(nine.dy));
    expect((ten.dx - 411 / 2).abs(), lessThan(65));
  });

  testWidgets('upper stops keep enough breathing room for node and stars', (
    tester,
  ) async {
    await pumpReferenceRoute(tester);

    final three = rectOf(tester, 3);
    final four = rectOf(tester, 4);

    expect(
      three.overlaps(four),
      isFalse,
      reason: '3 ve 4 durak kutuları veya yıldız alanları üst üste binmemeli.',
    );
    expect(
      four.top - three.bottom,
      greaterThanOrEqualTo(1),
      reason: '1-4 üst bölgesi referanstaki gibi ferah kalmalı.',
    );
  });

  testWidgets('stop 7 stars stay clear of level 8', (tester) async {
    await pumpReferenceRoute(tester);

    final seven = rectOf(tester, 7);
    final eight = rectOf(tester, 8);

    expect(
      seven.overlaps(eight),
      isFalse,
      reason: '7 numaranın yıldız alanı 8 numaralı bölümün arkasında kalmamalı.',
    );
    expect(
      eight.left - seven.right,
      greaterThanOrEqualTo(1),
      reason:
          '7 ve 8 yatay açılımında yıldızları okunur tutan güvenlik boşluğu olmalı.',
    );
  });

  testWidgets('special labels stay to the right of stops 5 and 10', (
    tester,
  ) async {
    await pumpReferenceRoute(tester);

    for (final entry in <(int, String)>[
      (5, 'MEYDAN OKUMA'),
      (10, 'ROTA FİNALİ'),
    ]) {
      final orb = tester.getCenter(
        find.byKey(Key('word_hunt_route_stop_orb_${entry.$1}')),
      );
      final label = tester.getCenter(find.text(entry.$2));
      expect(
        label.dx,
        greaterThan(orb.dx),
        reason: '${entry.$1} özel etiketi referanstaki gibi sağda kalmalı.',
      );
    }
    expect(find.text('BONUS DURAK'), findsNothing);
  });

  testWidgets(
    'reference route omits rejected scenic labels and keeps bottom controls',
    (tester) async {
      await pumpReferenceRoute(tester);

      expect(find.text('Fener'), findsNothing);
      expect(find.text('Liman'), findsNothing);
      expect(find.text('Hazine'), findsNothing);

      final compass = find.byKey(const Key('word_hunt_reference_compass'));
      final book = find.byKey(const Key('word_hunt_reference_book'));
      expect(compass, findsOneWidget);
      expect(book, findsOneWidget);
      expect(tester.getCenter(compass).dx, lessThan(tester.getCenter(book).dx));
    },
  );

  testWidgets(
    'reference screen remains an isolated prototype with all route levels visible',
    (tester) async {
      await pumpReferenceRoute(tester);

      expect(
        find.byKey(const Key('word_hunt_reference_route_area')),
        findsOneWidget,
      );
      for (var level = 1; level <= 10; level++) {
        expect(
          find.byKey(Key('word_hunt_reference_level_$level')),
          findsOneWidget,
        );
      }
    },
  );
}
