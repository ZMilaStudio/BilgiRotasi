import 'dart:ui' show SemanticsAction;

import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_stop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_star_visuals.dart';

WordHuntLevelDefinition _level(int index, WordHuntLevelType type) {
  return WordHuntLevelDefinition(
    id: 'test-$index',
    routeId: 'test-route',
    index: index,
    type: type,
    grid: const <String>['ABC', 'DEF', 'GHI'],
    targetWords: const <String>['ABC'],
    starRules: const WordHuntStarRules(),
  );
}

void main() {
  const metrics = WordHuntRouteStopMetrics.referenceBaseline;

  testWidgets('approved reference keeps normal medallions compact and ornate', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WordHuntRouteStop(
            level: _level(1, WordHuntLevelType.normal),
            stars: 3,
            unlocked: true,
          ),
        ),
      ),
    );

    expect(metrics.normalDiameter, 78);
    expect(metrics.lockedNormalDiameter, 100);
    expect(metrics.challengeDiameter, 104);
    expect(metrics.bonusDiameter, 104);
    expect(metrics.finalDiameter, 142);
    expect(metrics.challengeContainerWidth, 440);
    expect(metrics.bonusContainerWidth, 321);
    expect(
      metrics.starSize,
      24,
      reason: 'Yıldızlar küçük medalyonla orantılı kalmalı.',
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_asset_1')),
      findsOneWidget,
      reason: 'Normal durak production medalyon asset kullanmalı.',
    );
    final normalAsset = tester.widget<Image>(
      find.byKey(const Key('word_hunt_route_stop_asset_1')),
    );
    expect(
      (normalAsset.image as AssetImage).assetName,
      'assets/word_hunt/baslangic_limani/node_normal.webp',
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_frame_1')),
      findsNothing,
      reason: 'Final render procedural medalyon painter kullanmamalı.',
    );

    final number = tester.widget<Text>(
      find.byKey(const Key('word_hunt_route_stop_number_1')),
    );
    expect(
      number.style?.fontSize,
      30,
      reason: 'Rota numarası referanstaki gibi küçük ve dengeli olmalı.',
    );
  });

  testWidgets(
    'locked normal stop gains reference weight without changing domain type',
    (tester) async {
      var tapped = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                WordHuntRouteStop(
                  level: _level(1, WordHuntLevelType.normal),
                  stars: 2,
                  unlocked: true,
                  onTap: () => tapped = 1,
                ),
                WordHuntRouteStop(
                  level: _level(2, WordHuntLevelType.normal),
                  stars: 0,
                  unlocked: false,
                  onTap: () => tapped = 2,
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(const Key('word_hunt_route_stop_orb_1'))),
        Size.square(metrics.normalDiameter),
      );
      expect(
        tester.getSize(find.byKey(const Key('word_hunt_route_stop_orb_2'))),
        Size.square(metrics.lockedNormalDiameter),
      );

      for (var star = 0; star < 3; star++) {
        expect(
          find.byKey(Key('word_hunt_route_stop_star_1_$star')),
          findsOneWidget,
        );
        expect(
          find.byKey(Key('word_hunt_route_stop_star_2_$star')),
          findsOneWidget,
        );
      }

      expect(
        find.byKey(const Key('word_hunt_route_stop_lock_2')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('word_hunt_route_stop_1')));
      await tester.pump();
      expect(tapped, 1);

      await tester.tap(
        find.byKey(const Key('word_hunt_route_stop_2')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(tapped, 1, reason: 'Kilitli durak etkileşim üretmemeli.');
    },
  );

  testWidgets(
    'locked final stays disabled but keeps gold numbered destination',
    (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WordHuntRouteStop(
                level: _level(10, WordHuntLevelType.routeFinal),
                stars: 0,
                unlocked: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('word_hunt_route_stop_number_10')),
        findsNothing,
        reason: 'Final 10 rakamı doğrudan MASTER ART extraction pikselidir.',
      );
      expect(
        find.byKey(const Key('word_hunt_route_stop_lock_badge_10')),
        findsNothing,
        reason: 'Bağlayıcı referansta altın final üzerinde lock badge yoktur.',
      );
      expect(
        find.byKey(const Key('word_hunt_route_stop_crown_10')),
        findsOneWidget,
        reason: 'Final hedefi ayrı ve süslü taç siluetini korumalı.',
      );
      final finalNode = tester.widget<Image>(
        find.byKey(const Key('word_hunt_route_stop_asset_10')),
      );
      expect(
        (finalNode.image as AssetImage).assetName,
        'assets/word_hunt/baslangic_limani/node_final.webp',
      );
      final crownAsset = tester.widget<Image>(
        find.byKey(const Key('word_hunt_route_stop_crown_asset_10')),
      );
      expect(
        (crownAsset.image as AssetImage).assetName,
        'assets/word_hunt/baslangic_limani/final_crown.webp',
      );
      for (var star = 0; star < 3; star++) {
        final icon = tester.widget<Icon>(
          find.byKey(Key('word_hunt_route_stop_star_10_$star')),
        );
        expect(icon.color, const Color(0xFF65717D));
      }
      expect(
        find.byKey(const Key('word_hunt_route_stop_lock_10')),
        findsNothing,
        reason: 'Final hedefi ana kilit ikonuna dönüşmemeli.',
      );

      await tester.tap(
        find.byKey(const Key('word_hunt_route_stop_10')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(tapped, isFalse, reason: 'Kilitli final callback üretmemeli.');

      final semantics = tester.getSemantics(
        find.byKey(const Key('word_hunt_route_stop_10')),
      );
      expect(semantics.label, contains('kilitli'));
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isFalse,
      );
    },
  );

  testWidgets('locked normal stop keeps silver lock and three empty stars', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: WordHuntRouteStop(
              level: _level(9, WordHuntLevelType.normal),
              stars: 0,
              unlocked: false,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('word_hunt_route_stop_lock_9')),
      findsOneWidget,
    );
    final lockedAsset = tester.widget<Image>(
      find.byKey(const Key('word_hunt_route_stop_asset_9')),
    );
    expect(
      (lockedAsset.image as AssetImage).assetName,
      'assets/word_hunt/baslangic_limani/node_locked.webp',
    );
    expect(
      find.byKey(const Key('word_hunt_route_stop_number_9')),
      findsNothing,
    );
    for (var star = 0; star < 3; star++) {
      final icon = tester.widget<Icon>(
        find.byKey(Key('word_hunt_route_stop_star_9_$star')),
      );
      expect(
        icon.color,
        WordHuntStarVisuals.empty,
      );
    }
  });

  testWidgets('theme changes visual tokens without changing stop geometry', (
    tester,
  ) async {
    final alternateTheme = WordHuntRouteStopTheme.harbor.copyWith(
      normalAccent: const Color(0xFF67B85C),
      challengeAccent: const Color(0xFFB78245),
      bonusAccent: const Color(0xFF4F9F62),
      finalAccent: const Color(0xFFD2B06A),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              WordHuntRouteStop(
                level: _level(3, WordHuntLevelType.normal),
                stars: 3,
                unlocked: true,
              ),
              WordHuntRouteStop(
                level: _level(4, WordHuntLevelType.normal),
                stars: 3,
                unlocked: true,
                theme: alternateTheme,
              ),
            ],
          ),
        ),
      ),
    );

    final harborSize = tester.getSize(
      find.byKey(const Key('word_hunt_route_stop_3')),
    );
    final alternateSize = tester.getSize(
      find.byKey(const Key('word_hunt_route_stop_4')),
    );

    expect(harborSize, alternateSize);
    expect(harborSize.width, metrics.normalContainerWidth);
    expect(harborSize.height, metrics.normalContainerHeight);
  });

  testWidgets('special stars stay directly beneath their medallion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: WordHuntRouteStop(
              level: _level(5, WordHuntLevelType.challenge),
              stars: 3,
              unlocked: true,
            ),
          ),
        ),
      ),
    );

    final orbCenter = tester.getCenter(
      find.byKey(const Key('word_hunt_route_stop_orb_5')),
    );
    final middleStarCenter = tester.getCenter(
      find.byKey(const Key('word_hunt_route_stop_star_5_1')),
    );

    expect(
      (orbCenter.dx - middleStarCenter.dx).abs(),
      lessThanOrEqualTo(2),
      reason:
          'Özel durak yıldızları referanstaki gibi medalyonun altında olmalı.',
    );
    expect(
      middleStarCenter.dy,
      greaterThan(orbCenter.dy),
      reason: 'Yıldız sırası medalyonun altında kalmalı.',
    );
  });

  testWidgets(
    'special stops share the same component family and fixed labels',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WordHuntRouteStop(
                  level: _level(5, WordHuntLevelType.challenge),
                  stars: 1,
                  unlocked: true,
                ),
                WordHuntRouteStop(
                  level: _level(8, WordHuntLevelType.bonus),
                  stars: 2,
                  unlocked: true,
                ),
                WordHuntRouteStop(
                  level: _level(10, WordHuntLevelType.routeFinal),
                  stars: 0,
                  unlocked: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('MEYDAN OKUMA'), findsOneWidget);
      expect(find.text('BONUS DURAK'), findsOneWidget);
      expect(find.text('ROTA FİNALİ'), findsOneWidget);
      for (final entry in <(int, String, String)>[
        (5, 'node_challenge.webp', 'challenge_plaque.webp'),
        (8, 'node_bonus.webp', 'bonus_plaque.webp'),
        (10, 'node_final.webp', 'final_plaque.webp'),
      ]) {
        final nodeImage = tester.widget<Image>(
          find.byKey(Key('word_hunt_route_stop_asset_${entry.$1}')),
        );
        expect(
          (nodeImage.image as AssetImage).assetName,
          'assets/word_hunt/baslangic_limani/${entry.$2}',
        );
        final plaqueImage = tester.widget<Image>(
          find.byKey(Key('word_hunt_route_stop_plaque_asset_${entry.$1}')),
        );
        expect(
          (plaqueImage.image as AssetImage).assetName,
          'assets/word_hunt/baslangic_limani/${entry.$3}',
        );
      }
      expect(
        find.byKey(const Key('word_hunt_route_stop_number_5')),
        findsNothing,
        reason: 'Challenge 5 rakamı doğrudan MASTER ART extraction pikselidir.',
      );
      expect(
        find.byKey(const Key('word_hunt_route_stop_number_10')),
        findsNothing,
        reason: 'Final 10 rakamı doğrudan MASTER ART extraction pikselidir.',
      );
      for (final entry in <(int, String)>[
        (5, 'challenge_icon.png'),
        (8, 'bonus_icon.png'),
        (10, 'final_icon.png'),
      ]) {
        final iconImage = tester.widget<Image>(
          find.byKey(Key('word_hunt_route_stop_special_icon_${entry.$1}')),
        );
        expect(
          (iconImage.image as AssetImage).assetName,
          'assets/word_hunt/baslangic_limani/${entry.$2}',
        );
      }
      for (final entry in <(int, double)>[(5, 2.2), (8, 2.0), (10, 1.55)]) {
        final transform = tester.widget<Transform>(
          find.byKey(
            Key('word_hunt_route_stop_special_icon_scale_${entry.$1}'),
          ),
        );
        expect(transform.transform.storage[0], closeTo(entry.$2, 0.001));
        expect(transform.transform.storage[5], closeTo(entry.$2, 0.001));
      }
      expect(
        find.byKey(const Key('word_hunt_route_stop_crossed_swords_5')),
        findsNothing,
        reason: 'Premium kılıç final artı procedural painter olmamalı.',
      );
      expect(
        find.byKey(const Key('word_hunt_route_stop_treasure_chest_10')),
        findsNothing,
        reason: 'Premium sandık final artı procedural painter olmamalı.',
      );

      final challengeLabel = tester.widget<Text>(find.text('MEYDAN OKUMA'));
      expect(challengeLabel.maxLines, 1);

      expect(
        tester.getSize(find.byKey(const Key('word_hunt_route_stop_5'))).width,
        metrics.challengeContainerWidth,
      );
      expect(
        tester.getSize(find.byKey(const Key('word_hunt_route_stop_8'))).width,
        metrics.bonusContainerWidth,
      );
      expect(
        tester.getSize(find.byKey(const Key('word_hunt_route_stop_10'))).width,
        metrics.finalContainerWidth,
      );
      expect(
        find.byKey(const Key('word_hunt_route_stop_lock_badge_10')),
        findsNothing,
      );
    },
  );
}
