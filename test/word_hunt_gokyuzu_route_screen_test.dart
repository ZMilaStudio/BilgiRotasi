import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_route_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WordHuntLevelDefinition level(int index, WordHuntLevelType type) {
    return WordHuntLevelDefinition(
      id: 'gokyuzu-$index',
      routeId: 'gokyuzu-adalari',
      index: index,
      type: type,
      grid: const <String>[
        'KAPILARM',
        'ABCDEFGH',
        'IJKLMNOP',
        'QRSTUVYZ',
        'ABCDEFGH',
        'IJKLMNOP',
        'QRSTUVYZ',
        'ABCDEFGH',
      ],
      targetWords: const <String>['KAPI'],
      starRules: const WordHuntStarRules(),
    );
  }

  WordHuntRouteDefinition route() => WordHuntRouteDefinition(
    id: 'gokyuzu-adalari',
    title: 'Gökyüzü Adaları',
    theme: 'gokyuzu',
    unlockStarsRequired: 18,
    routeRewardId: 'badge-gokyuzu-kasifi',
    levels: <WordHuntLevelDefinition>[
      for (var i = 1; i <= 7; i++) level(i, WordHuntLevelType.normal),
      level(8, WordHuntLevelType.bonus),
      level(9, WordHuntLevelType.normal),
      level(10, WordHuntLevelType.routeFinal),
    ],
  );

  Future<void> pump(
    WidgetTester tester, {
    WordHuntProgressSnapshot progress = const WordHuntProgressSnapshot(),
  }) async {
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntGokyuzuRouteScreen(route: route(), progress: progress),
      ),
    );
    await tester.pump();
  }

  testWidgets('V2 kabuğu 10 node ve yalnız rota içi kontrolleri gösterir', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byKey(const Key('word_hunt_gokyuzu_route')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_gokyuzu_back')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_gokyuzu_info')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_gokyuzu_compass')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_gokyuzu_book')), findsOneWidget);
    for (var i = 1; i <= 10; i++) {
      expect(find.byKey(Key('word_hunt_gokyuzu_level_$i')), findsOneWidget);
      expect(find.byKey(Key('word_hunt_gokyuzu_scene_$i')), findsOneWidget);
    }
    expect(find.text('Mağaza'), findsNothing);
    expect(find.text('Başarılar'), findsNothing);
    expect(find.text('Oyna'), findsNothing);
    expect(find.text('Sıralama'), findsNothing);
    expect(find.text('Rozetler'), findsNothing);
  });

  testWidgets('başlangıçta 1 açık, 2 kilitli ve dinamik raster state ayrıdır', (
    tester,
  ) async {
    await pump(tester);
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_level_2_locked')),
      findsOneWidget,
    );
    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    final assetNames =
        images
            .map((image) => image.image)
            .whereType<AssetImage>()
            .map((image) => image.assetName)
            .toSet();
    expect(
      assetNames,
      contains('assets/word_hunt/gokyuzu_adalari/scene_level_01.webp'),
    );
    expect(
      assetNames,
      contains('assets/word_hunt/gokyuzu_adalari/route_node_base.webp'),
    );
  });

  testWidgets('7 tamamlanınca 8 ve 9 görsel olarak açılır, 10 kilitli kalır', (
    tester,
  ) async {
    await pump(
      tester,
      progress: const WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{'gokyuzu-7': 1},
      ),
    );
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_level_8_locked')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_level_9_locked')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('word_hunt_gokyuzu_level_10_locked')),
      findsOneWidget,
    );
  });
}
