import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final entrySource = File(
    'lib/word_hunt/word_hunt_production_entry_screen.dart',
  ).readAsStringSync();
  final selectorSource = File(
    'lib/word_hunt/word_hunt_route_selector.dart',
  ).readAsStringSync();

  test('production catalog üç canlı rotayı sırasıyla taşır', () {
    final entries = WordHuntRouteCatalog.entries;

    expect(entries, hasLength(3));
    expect(entries[0].cardKey, 'starter');
    expect(entries[0].route.id, WordHuntStarterContent.baslangicLimani.id);
    expect(entries[1].cardKey, 'gokyuzu');
    expect(entries[1].route.id, WordHuntGokyuzuContent.gokyuzuAdalari.id);
    expect(entries[2].cardKey, 'orman');
    expect(entries[2].route.id, WordHuntOrmanContent.ormanYolu.id);
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
    expect(WordHuntRouteCatalog.starter.visualTheme, isNull);
    expect(WordHuntRouteCatalog.gokyuzu.visualTheme, isNull);
    expect(
      WordHuntRouteCatalog.orman.visualTheme,
      same(WordHuntRouteVisualThemes.ormanYolu),
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
    expect(WordHuntRouteCatalog.orman.isUnlocked(const WordHuntProgressSnapshot()), isFalse);

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
    expect(WordHuntRouteCatalog.orman.isUnlocked(highStarsWithoutFinal), isFalse);

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

  test('Orman açıldığında kendi iç progressionı yine yalnız Bölüm 1 ile başlar', () {
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
  });

  test('selector kartları catalog listesinden generic olarak üretir', () {
    expect(selectorSource, contains("Key('word_hunt_route_selector')"));
    expect(selectorSource, contains('WordHuntRouteCatalog.entries.length'));
    expect(
      selectorSource,
      contains("Key('word_hunt_route_card_\${entry.cardKey}')"),
    );
    expect(selectorSource, contains('WordHuntRouteUnlockKind.routeComplete'));
    expect(selectorSource, contains(". bölümü tamamla'"));
    expect(entrySource, contains('WordHuntRouteSelector('));
    expect(entrySource, contains('void _openCatalogRoute('));
    expect(entrySource, isNot(contains('void _openGokyuzuRoute(')));
    expect(entrySource, isNot(contains('void _openStarterRoute(')));
  });

  test('route renderer ve gameplay background route-id if kullanmaz', () {
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
  });
}
