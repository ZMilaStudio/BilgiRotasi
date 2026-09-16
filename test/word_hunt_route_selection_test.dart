import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_selector.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final entrySource = File(
    'lib/word_hunt/word_hunt_production_entry_screen.dart',
  ).readAsStringSync();
  final selectorSource = File(
    'lib/word_hunt/word_hunt_route_selector.dart',
  ).readAsStringSync();
  final catalogSource = File(
    'lib/word_hunt/word_hunt_route_catalog.dart',
  ).readAsStringSync();

  Map<String, int> starterCompleteStars() => <String, int>{
        for (final level in WordHuntStarterContent.baslangicLimani.levels.take(6))
          level.id: 3,
        WordHuntStarterContent.baslangicLimani.levels.last.id: 1,
      };

  Map<String, int> skyCompleteStars() => <String, int>{
        for (final level in WordHuntGokyuzuContent.gokyuzuAdalari.levels.take(6))
          level.id: 3,
        WordHuntGokyuzuContent.gokyuzuAdalari.levels.last.id: 1,
      };

  test('production catalog order, ids and ordinal labels stay exact', () {
    final entries = WordHuntRouteCatalog.entries;

    expect(entries, hasLength(4));
    expect(
      entries.map((entry) => entry.route.id).toList(),
      <String>[
        'baslangic-limani',
        'gokyuzu-adalari',
        'orman-yolu',
        'orman-2',
      ],
    );
    expect(
      entries.map((entry) => entry.ordinalLabel).toList(),
      <String>['İlk rota', 'İkinci rota', 'Üçüncü rota', 'Dördüncü rota'],
    );
    expect(entries[3].route.title, 'Kadim Orman');
  });

  test('canlı rotaların production presentation türü catalog verisidir', () {
    expect(
      WordHuntRouteCatalog.starter.presentationKind,
      WordHuntRoutePresentationKind.referenceRoute,
    );
    expect(
      WordHuntRouteCatalog.gokyuzu.presentationKind,
      WordHuntRoutePresentationKind.gokyuzuMasterArt,
    );
    expect(
      WordHuntRouteCatalog.orman.presentationKind,
      WordHuntRoutePresentationKind.themedReusable,
    );
    expect(
      WordHuntRouteCatalog.orman2Pilot.presentationKind,
      WordHuntRoutePresentationKind.themedReusable,
    );
    expect(WordHuntRouteCatalog.starter.visualTheme, isNull);
    expect(WordHuntRouteCatalog.gokyuzu.visualTheme, isNull);
    expect(
      WordHuntRouteCatalog.orman.visualTheme,
      same(WordHuntRouteVisualThemes.ormanYolu),
    );
    expect(
      WordHuntRouteCatalog.orman2Pilot.visualTheme,
      same(WordHuntOrman2VisualTheme.production),
    );

    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntStarterContent.baslangicLimani.id,
      ),
      same(WordHuntRouteCatalog.starter),
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntGokyuzuContent.gokyuzuAdalari.id,
      ),
      same(WordHuntRouteCatalog.gokyuzu),
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(WordHuntOrmanContent.ormanYolu.id),
      same(WordHuntRouteCatalog.orman),
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(WordHuntOrman2Content.orman2.id),
      same(WordHuntRouteCatalog.orman2Pilot),
    );
  });

  test('linear catalog prerequisite contract is exact and data-driven', () {
    expect(
      WordHuntRouteCatalog.starter.unlockRule.kind,
      WordHuntRouteUnlockKind.always,
    );

    final skyRule = WordHuntRouteCatalog.gokyuzu.unlockRule;
    expect(skyRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(skyRule.prerequisiteRoute, same(WordHuntStarterContent.baslangicLimani));
    expect(WordHuntStarterContent.baslangicLimani.unlockStarsRequired, 18);
    expect(
      WordHuntRouteCatalog.gokyuzu.lockedMessage,
      'Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.',
    );

    final forestRule = WordHuntRouteCatalog.orman.unlockRule;
    expect(forestRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(
      forestRule.prerequisiteRoute,
      same(WordHuntGokyuzuContent.gokyuzuAdalari),
    );
    expect(WordHuntGokyuzuContent.gokyuzuAdalari.unlockStarsRequired, 18);
    expect(
      WordHuntRouteCatalog.orman.lockedMessage,
      'Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.',
    );

    final kadimRule = WordHuntRouteCatalog.orman2Pilot.unlockRule;
    expect(kadimRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(kadimRule.prerequisiteRoute, same(WordHuntOrmanContent.ormanYolu));
    expect(WordHuntOrmanContent.ormanYolu.unlockStarsRequired, 0);
    expect(
      WordHuntRouteCatalog.orman2Pilot.lockedMessage,
      'Orman Yolu’nu tamamlayarak aç.',
    );
  });

  test('fresh progress yalnız Başlangıç Limanı rotasını açar', () {
    const progress = WordHuntProgressSnapshot();

    expect(WordHuntRouteCatalog.starter.isUnlocked(progress), isTrue);
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isFalse);
    expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isFalse);
    expect(WordHuntRouteCatalog.orman2Pilot.isUnlocked(progress), isFalse);
  });

  test('18 Başlangıç yıldızı final olmadan Gökyüzü açmaz', () {
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (final level in WordHuntStarterContent.baslangicLimani.levels.take(6))
          level.id: 3,
      },
    );

    expect(WordHuntRouteCatalog.gokyuzu.unlockRule.currentStars(progress), 18);
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isFalse);
  });

  test('Başlangıç finali tamam ama 17 yıldızda Gökyüzü kapalı kalır', () {
    final levels = WordHuntStarterContent.baslangicLimani.levels;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (final level in levels.take(5)) level.id: 3,
        levels[5].id: 1,
        levels.last.id: 1,
      },
    );

    expect(WordHuntRouteCatalog.gokyuzu.unlockRule.currentStars(progress), 17);
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isFalse);
  });

  test('Başlangıç final + en az 18 yıldız Gökyüzü açar', () {
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: starterCompleteStars(),
    );

    expect(
      WordHuntRouteProgressEngine.isRouteComplete(
        WordHuntStarterContent.baslangicLimani,
        progress,
      ),
      isTrue,
    );
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isTrue);
  });

  test('Başlangıç complete olsa da Gökyüzü incomplete iken Orman kilitlidir', () {
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        ...starterCompleteStars(),
        for (final level in WordHuntGokyuzuContent.gokyuzuAdalari.levels.take(6))
          level.id: 3,
      },
    );

    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isTrue);
    expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isFalse);
  });

  test('Gökyüzü finali tamam ama 17 yıldızda Orman kilitlidir', () {
    final levels = WordHuntGokyuzuContent.gokyuzuAdalari.levels;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        ...starterCompleteStars(),
        for (final level in levels.take(5)) level.id: 3,
        levels[5].id: 1,
        levels.last.id: 1,
      },
    );

    expect(WordHuntRouteCatalog.orman.unlockRule.currentStars(progress), 17);
    expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isFalse);
  });

  test('Gökyüzü final + en az 18 yıldız Orman Yolu açar', () {
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        ...starterCompleteStars(),
        ...skyCompleteStars(),
      },
    );

    expect(
      WordHuntRouteProgressEngine.isRouteComplete(
        WordHuntGokyuzuContent.gokyuzuAdalari,
        progress,
      ),
      isTrue,
    );
    expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isTrue);
  });

  test('Orman Yolu finali 1 yıldızla tamamlanınca Kadim Orman açılır', () {
    final finalLevel = WordHuntOrmanContent.ormanYolu.levels.last;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{finalLevel.id: 1},
    );

    expect(WordHuntOrmanContent.ormanYolu.unlockStarsRequired, 0);
    expect(WordHuntRouteCatalog.orman2Pilot.unlockRule.currentStars(progress), 1);
    expect(WordHuntRouteCatalog.orman2Pilot.isUnlocked(progress), isTrue);
  });

  test('Orman Yolu yüksek yıldız ama final yokken Kadim Orman kilitlidir', () {
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (final level in WordHuntOrmanContent.ormanYolu.levels.take(9))
          level.id: 3,
      },
    );

    expect(WordHuntRouteCatalog.orman2Pilot.unlockRule.currentStars(progress), 27);
    expect(WordHuntRouteCatalog.orman2Pilot.isUnlocked(progress), isFalse);
  });

  test('legacy Orman progress Gökyüzü incomplete iken prerequisite bypass etmez', () {
    final forest = WordHuntOrmanContent.ormanYolu;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        ...starterCompleteStars(),
        forest.levels[0].id: 3,
        forest.levels[4].id: 2,
      },
    );

    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isTrue);
    expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isFalse);
    expect(progress.starsFor(forest.levels[0].id), 3);
    expect(progress.starsFor(forest.levels[4].id), 2);
  });

  test('Gökyüzü sonradan complete olunca Orman açılır ve downstream progress korunur', () {
    final forest = WordHuntOrmanContent.ormanYolu;
    var progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        ...starterCompleteStars(),
        forest.levels[0].id: 3,
        forest.levels[4].id: 2,
      },
    );

    for (final level in WordHuntGokyuzuContent.gokyuzuAdalari.levels.take(6)) {
      progress = progress.recordLevelResult(levelId: level.id, stars: 3);
    }
    progress = progress.recordLevelResult(
      levelId: WordHuntGokyuzuContent.gokyuzuAdalari.levels.last.id,
      stars: 1,
    );

    expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isTrue);
    expect(progress.starsFor(forest.levels[0].id), 3);
    expect(progress.starsFor(forest.levels[4].id), 2);
  });

  test('routeComplete rule gerçek route completion contractını kullanır', () {
    final skyRule = WordHuntRouteCatalog.gokyuzu.unlockRule;
    final starterLevels = WordHuntStarterContent.baslangicLimani.levels;

    final thresholdWithoutFinal = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (final level in starterLevels.take(6)) level.id: 3,
      },
    );
    expect(skyRule.isUnlocked(thresholdWithoutFinal), isFalse);

    final finalWithoutThreshold = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{starterLevels.last.id: 1},
    );
    expect(skyRule.isUnlocked(finalWithoutThreshold), isFalse);

    final finalWithThreshold = WordHuntProgressSnapshot(
      bestStarsByLevelId: starterCompleteStars(),
    );
    expect(skyRule.isUnlocked(finalWithThreshold), isTrue);

    final forestFinal = WordHuntOrmanContent.ormanYolu.levels.last;
    final zeroThresholdFinal = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{forestFinal.id: 1},
    );
    expect(
      WordHuntRouteCatalog.orman2Pilot.isUnlocked(zeroThresholdFinal),
      isTrue,
    );
  });

  test(
    'Orman açıldığında kendi iç progressionı yine yalnız Bölüm 1 ile başlar',
    () {
      final progress = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          ...starterCompleteStars(),
          ...skyCompleteStars(),
        },
      );
      expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isTrue);
      expect(
        WordHuntRouteProgressEngine.isLevelUnlocked(
          WordHuntOrmanContent.ormanYolu,
          progress,
          1,
        ),
        isTrue,
      );
      for (var level = 2; level <= 10; level++) {
        expect(
          WordHuntRouteProgressEngine.isLevelUnlocked(
            WordHuntOrmanContent.ormanYolu,
            progress,
            level,
          ),
          isFalse,
        );
      }
    },
  );

  testWidgets('fresh selector lineer kilit mesajlarını exact gösterir', (
    tester,
  ) async {
    WordHuntRouteCatalogEntry? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteSelector(
          progress: const WordHuntProgressSnapshot(),
          onRouteTap: (entry) => selected = entry,
        ),
      ),
    );

    expect(
      find.text('Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.'),
      findsOneWidget,
    );
    expect(
      find.text('Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.'),
      findsOneWidget,
    );
    expect(find.text('Orman Yolu’nu tamamlayarak aç.'), findsOneWidget);

    final forestCard = find.byKey(const Key('word_hunt_route_card_orman'));
    await tester.ensureVisible(forestCard);
    await tester.tap(forestCard);
    await tester.pump();
    expect(selected, isNull);
  });

  testWidgets('Orman Yolu finali tamamlanınca selector Kadim Orman seçimine izin verir', (
    tester,
  ) async {
    final finalLevel = WordHuntOrmanContent.ormanYolu.levels.last;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{finalLevel.id: 1},
    );
    WordHuntRouteCatalogEntry? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteSelector(
          progress: progress,
          onRouteTap: (entry) => selected = entry,
        ),
      ),
    );

    final card = find.byKey(const Key('word_hunt_route_card_orman2'));
    await tester.ensureVisible(card);
    expect(find.text('Orman Yolu’nu tamamlayarak aç.'), findsNothing);
    await tester.tap(card);
    await tester.pump();
    expect(selected, same(WordHuntRouteCatalog.orman2Pilot));
  });

  test('selector kartları catalog listesinden generic olarak üretir', () {
    expect(selectorSource, contains("Key('word_hunt_route_selector')"));
    expect(selectorSource, contains('WordHuntRouteCatalog.entries.length'));
    expect(
      selectorSource,
      contains("Key('word_hunt_route_card_\${entry.cardKey}')"),
    );
    expect(selectorSource, contains('entry.lockedMessage'));
    expect(entrySource, contains('WordHuntRouteSelector('));
    expect(entrySource, contains('void _openCatalogRoute('));
    expect(entrySource, isNot(contains('void _openGokyuzuRoute(')));
    expect(entrySource, isNot(contains('void _openStarterRoute(')));
  });

  test('kilitli rota mesajı unlock türünü generic olarak desteklemeyi sürdürür', () {
    expect(entrySource, contains('String _lockedRouteMessage('));
    expect(entrySource, contains('case WordHuntRouteUnlockKind.routeStars:'));
    expect(entrySource, contains('case WordHuntRouteUnlockKind.routeComplete:'));
    expect(entrySource, contains('bölümü tamamlaman gerekli.'));
  });

  test('lineer progression için route-id özel selector/renderer if eklenmemiştir', () {
    expect(selectorSource, isNot(contains("route.id == 'orman-2'")));
    expect(selectorSource, isNot(contains("route.id == 'orman-yolu'")));
    expect(catalogSource, isNot(contains("if (route.id == 'orman-2')")));
    expect(catalogSource, isNot(contains("if (route.id == 'orman-yolu')")));
    expect(entrySource, isNot(contains("route.id == 'orman-2'")));
  });

  test('route renderer ve gameplay background mevcut route-id if kullanmaz', () {
    expect(entrySource, contains('WordHuntRouteCatalog.entryForRouteId('));
    expect(entrySource, contains('_activePresentationKind'));
    expect(entrySource, contains('switch (_activePresentationKind)'));
    expect(entrySource, contains('_gameplayBackgroundForLevel('));
    expect(
      entrySource,
      isNot(
        contains('route.id == WordHuntGokyuzuMasterArtScreen.routeId'),
      ),
    );
    expect(entrySource, isNot(contains("route.id == 'orman-yolu'")));
  });

  test('production host generic themed renderer yolunu destekler', () {
    expect(
      entrySource,
      contains('case WordHuntRoutePresentationKind.themedReusable:'),
    );
    expect(entrySource, contains('WordHuntThemedProductionRouteScreen('));
    expect(
      entrySource,
      contains("Key('word_hunt_production_entry_themed_route')"),
    );
    expect(entrySource, contains('_activeCatalogEntry?.visualTheme'));
  });

  test('QA belirli canlı rotayı selector olmadan doğrudan açabilir', () {
    expect(entrySource, contains('this.routeSelectionEnabled = true'));
    expect(entrySource, contains('final bool routeSelectionEnabled;'));
    expect(entrySource, contains('widget.routeSelectionEnabled &&'));
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntOrmanContent.ormanYolu.id,
      )?.presentationKind,
      WordHuntRoutePresentationKind.themedReusable,
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntOrman2Content.orman2.id,
      )?.presentationKind,
      WordHuntRoutePresentationKind.themedReusable,
    );
  });
}
