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

  test('production catalog dört canlı rotayı doğru sırayla taşır', () {
    final entries = WordHuntRouteCatalog.entries;

    expect(entries, hasLength(4));
    expect(entries[0].cardKey, 'starter');
    expect(entries[0].route.id, WordHuntStarterContent.baslangicLimani.id);
    expect(entries[1].cardKey, 'gokyuzu');
    expect(entries[1].route.id, WordHuntGokyuzuContent.gokyuzuAdalari.id);
    expect(entries[2].cardKey, 'orman');
    expect(entries[2].route.id, WordHuntOrmanContent.ormanYolu.id);
    expect(entries[3].cardKey, 'orman2');
    expect(entries[3].route.id, 'orman-2');
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

  test('Başlangıç Limanı her zaman açıktır', () {
    expect(
      WordHuntRouteCatalog.starter.isUnlocked(
        const WordHuntProgressSnapshot(),
      ),
      isTrue,
    );
    expect(
      WordHuntRouteCatalog.starter.unlockRule.kind,
      WordHuntRouteUnlockKind.always,
    );
  });

  test('Gökyüzü kapısı 18 Başlangıç Limanı yıldızına bağlı kalır', () {
    final rule = WordHuntRouteCatalog.gokyuzu.unlockRule;
    expect(rule.kind, WordHuntRouteUnlockKind.routeStars);
    expect(rule.prerequisiteRoute?.id, WordHuntStarterContent.baslangicLimani.id);
    expect(
      rule.requiredStars,
      WordHuntGokyuzuContent.gokyuzuAdalari.unlockStarsRequired,
    );
    expect(rule.requiredStars, 18);

    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 3,
      },
    );

    expect(rule.currentStars(progress), 18);
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isTrue);
  });

  test('17 yıldızda Gökyüzü kapısı kapalı kalır', () {
    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 2,
      },
    );

    expect(WordHuntRouteCatalog.gokyuzu.unlockRule.currentStars(progress), 17);
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isFalse);
  });

  test('Orman Yolu yalnız Başlangıç Limanı 10. bölüm bitince açılır', () {
    final rule = WordHuntRouteCatalog.orman.unlockRule;
    expect(rule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(rule.prerequisiteRoute?.id, WordHuntStarterContent.baslangicLimani.id);
    expect(
      WordHuntRouteCatalog.orman.isUnlocked(const WordHuntProgressSnapshot()),
      isFalse,
    );

    const highStarsWithoutFinal = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 3,
        'baslangic-7': 3,
        'baslangic-8': 3,
        'baslangic-9': 3,
      },
    );
    expect(rule.currentStars(highStarsWithoutFinal), 27);
    expect(rule.currentCompletedLevels(highStarsWithoutFinal), 9);
    expect(
      WordHuntRouteCatalog.orman.isUnlocked(highStarsWithoutFinal),
      isFalse,
    );

    const finalCompleted = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 3,
        'baslangic-7': 3,
        'baslangic-8': 3,
        'baslangic-9': 3,
        'baslangic-10': 1,
      },
    );
    expect(rule.currentCompletedLevels(finalCompleted), 10);
    expect(WordHuntRouteCatalog.orman.isUnlocked(finalCompleted), isTrue);
  });

  test('Kadim Orman fresh progress durumunda görünür ama kilitlidir', () {
    final entry = WordHuntRouteCatalog.orman2Pilot;
    expect(WordHuntRouteCatalog.entries, contains(same(entry)));
    expect(entry.route.id, 'orman-2');
    expect(entry.route.title, 'Kadim Orman');
    expect(entry.isUnlocked(const WordHuntProgressSnapshot()), isFalse);
    expect(entry.lockedMessage, 'Orman Yolu’nu tamamlayarak aç.');
  });

  test('Orman Yolu level 9 tamamken Kadim Orman kilitli kalır', () {
    final stars = <String, int>{
      for (final level in WordHuntOrmanContent.ormanYolu.levels.take(9))
        level.id: 3,
    };
    final progress = WordHuntProgressSnapshot(bestStarsByLevelId: stars);
    final entry = WordHuntRouteCatalog.orman2Pilot;

    expect(entry.unlockRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(entry.unlockRule.prerequisiteRoute, same(WordHuntOrmanContent.ormanYolu));
    expect(entry.unlockRule.currentCompletedLevels(progress), 9);
    expect(entry.isUnlocked(progress), isFalse);
  });

  test('Orman Yolu level 10 tamamlanınca yıldız toplamından bağımsız açılır', () {
    final finalLevel = WordHuntOrmanContent.ormanYolu.levels.last;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{finalLevel.id: 1},
    );
    final entry = WordHuntRouteCatalog.orman2Pilot;

    expect(entry.unlockRule.currentStars(progress), 1);
    expect(entry.unlockRule.requiredStars, 0);
    expect(entry.isUnlocked(progress), isTrue);
  });

  test(
    'Orman açıldığında kendi iç progressionı yine yalnız Bölüm 1 ile başlar',
    () {
      const progress = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{'baslangic-10': 1},
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

  testWidgets('fresh selector Kadim Orman kartını locked ve seçilemez gösterir', (
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

    final card = find.byKey(const Key('word_hunt_route_card_orman2'));
    await tester.ensureVisible(card);
    expect(card, findsOneWidget);
    expect(find.text('Kadim Orman'), findsOneWidget);
    expect(find.text('Orman Yolu’nu tamamlayarak aç.'), findsOneWidget);
    await tester.tap(card);
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

  test('Kadim Orman için route-id özel selector/renderer if eklenmemiştir', () {
    expect(selectorSource, isNot(contains("route.id == 'orman-2'")));
    expect(catalogSource, isNot(contains("if (route.id == 'orman-2')")));
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
