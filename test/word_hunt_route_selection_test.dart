import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
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

  test('production catalog yalnız mevcut iki canlı rotayı taşır', () {
    final entries = WordHuntRouteCatalog.entries;

    expect(entries, hasLength(2));
    expect(entries[0].cardKey, 'starter');
    expect(entries[0].route.id, WordHuntStarterContent.baslangicLimani.id);
    expect(entries[1].cardKey, 'gokyuzu');
    expect(entries[1].route.id, WordHuntGokyuzuContent.gokyuzuAdalari.id);
    expect(entries.map((entry) => entry.route.id), isNot(contains('orman-yolu')));
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
    expect(WordHuntRouteCatalog.starter.visualTheme, isNull);
    expect(WordHuntRouteCatalog.gokyuzu.visualTheme, isNull);

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
    expect(WordHuntRouteCatalog.entryForRouteId('orman-yolu'), isNull);
  });

  test('generic themed presentation catalog verisiyle tanımlanabilir', () {
    const syntheticThemedEntry = WordHuntRouteCatalogEntry(
      cardKey: 'synthetic-themed',
      route: WordHuntOrmanContent.ormanYolu,
      infoCards: WordHuntOrmanContent.infoCards,
      ordinalLabel: 'Synthetic',
      icon: Icons.park_rounded,
      colors: <Color>[Color(0xFF2F855A), Color(0xFF173A28)],
      unlockRule: WordHuntRouteUnlockRule.always(),
      presentationKind: WordHuntRoutePresentationKind.themedReusable,
      visualTheme: WordHuntRouteVisualThemeProofs.forest,
    );

    expect(
      syntheticThemedEntry.presentationKind,
      WordHuntRoutePresentationKind.themedReusable,
    );
    expect(syntheticThemedEntry.visualTheme?.id, 'forest-proof');
    expect(syntheticThemedEntry.route.id, 'orman-yolu');

    // Bu test yalnız production kabiliyetini kanıtlar; Orman owner unlock/skin
    // kararı verilmeden canlı catalog listesine eklenmiş değildir.
    expect(
      WordHuntRouteCatalog.entries.map((entry) => entry.route.id),
      isNot(contains('orman-yolu')),
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

  test('Gökyüzü kapısı 18 Başlangıç Limanı yıldızına bağlıdır', () {
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

  test('selector kartları catalog listesinden generic olarak üretir', () {
    expect(selectorSource, contains("Key('word_hunt_route_selector')"));
    expect(selectorSource, contains('WordHuntRouteCatalog.entries.length'));
    expect(
      selectorSource,
      contains("Key('word_hunt_route_card_\${entry.cardKey}')"),
    );
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
  });

  test('production host generic themed renderer yolunu destekler', () {
    expect(
      entrySource,
      contains('case WordHuntRoutePresentationKind.themedReusable:'),
    );
    expect(entrySource, contains('WordHuntThemedRouteMapScreen('));
    expect(entrySource, contains("Key('word_hunt_production_entry_themed_route')"));
    expect(entrySource, contains('_activeCatalogEntry?.visualTheme'));
    expect(
      entrySource,
      isNot(contains("route.id == 'orman-yolu'")),
    );
  });

  test('QA belirli canlı rotayı selector olmadan doğrudan açabilir', () {
    expect(entrySource, contains('this.routeSelectionEnabled = true'));
    expect(entrySource, contains('final bool routeSelectionEnabled;'));
    expect(entrySource, contains('widget.routeSelectionEnabled &&'));
    expect(
      entrySource,
      contains("Key('word_hunt_production_entry_gokyuzu_route')"),
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntGokyuzuContent.gokyuzuAdalari.id,
      )?.presentationKind,
      WordHuntRoutePresentationKind.gokyuzuMasterArt,
    );
  });
}
