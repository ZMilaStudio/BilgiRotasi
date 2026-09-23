import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gunes_imparatorlugu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gunes_imparatorlugu_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kayip_sehir_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kayip_sehir_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_selector.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_yeralti_kralligi_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_yeralti_kralligi_visual_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final entrySource =
      File(
        'packages/word_hunt_flutter_feature/lib/word_hunt_feature_entry_screen.dart',
      ).readAsStringSync();
  final selectorSource =
      File(
        'packages/word_hunt_flutter_feature/lib/word_hunt_route_selector.dart',
      ).readAsStringSync();
  final catalogSource =
      File(
        'packages/word_hunt_flutter_feature/lib/word_hunt_route_catalog.dart',
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

    expect(entries, hasLength(8));
    expect(entries.map((entry) => entry.route.id).toList(), <String>[
      'baslangic-limani',
      'gokyuzu-adalari',
      'orman-yolu',
      'orman-2',
      'kristal-vadisi',
      'kayip-sehir',
      'yeralti-kralligi',
      'gunes-imparatorlugu',
    ]);
    expect(entries.map((entry) => entry.ordinalLabel).toList(), <String>[
      'İlk rota',
      'İkinci rota',
      'Üçüncü rota',
      'Dördüncü rota',
      'Beşinci rota',
      'Altıncı rota',
      'Yedinci rota',
      'Sekizinci rota',
    ]);
    expect(entries.map((entry) => entry.route.title).toList(), <String>[
      'Başlangıç Limanı',
      'Gökyüzü Adaları',
      'Orman Yolu',
      'Kadim Orman',
      'Kristal Vadisi',
      'Kayıp Şehir',
      'Yeraltı Krallığı',
      'Güneş İmparatorluğu',
    ]);
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
    expect(
      WordHuntRouteCatalog.kristal.presentationKind,
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
      WordHuntRouteCatalog.kristal.visualTheme,
      same(WordHuntKristalVisualTheme.production),
    );
    for (final entry in <WordHuntRouteCatalogEntry>[
      WordHuntRouteCatalog.kayipSehir,
      WordHuntRouteCatalog.yeraltiKralligi,
      WordHuntRouteCatalog.gunesImparatorlugu,
    ]) {
      expect(
        entry.presentationKind,
        WordHuntRoutePresentationKind.themedReusable,
      );
    }
    expect(
      WordHuntRouteCatalog.kayipSehir.visualTheme,
      same(WordHuntKayipSehirVisualTheme.production),
    );
    expect(
      WordHuntRouteCatalog.yeraltiKralligi.visualTheme,
      same(WordHuntYeraltiKralligiVisualTheme.production),
    );
    expect(
      WordHuntRouteCatalog.gunesImparatorlugu.visualTheme,
      same(WordHuntGunesImparatorluguVisualTheme.production),
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
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntKristalContent.kristalVadisi.id,
      ),
      same(WordHuntRouteCatalog.kristal),
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntKayipSehirContent.kayipSehir.id,
      ),
      same(WordHuntRouteCatalog.kayipSehir),
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntYeraltiKralligiContent.yeraltiKralligi.id,
      ),
      same(WordHuntRouteCatalog.yeraltiKralligi),
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntGunesImparatorluguContent.gunesImparatorlugu.id,
      ),
      same(WordHuntRouteCatalog.gunesImparatorlugu),
    );
  });

  test('linear catalog prerequisite contract is exact and data-driven', () {
    expect(
      WordHuntRouteCatalog.starter.unlockRule.kind,
      WordHuntRouteUnlockKind.always,
    );

    final skyRule = WordHuntRouteCatalog.gokyuzu.unlockRule;
    expect(skyRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(
      skyRule.prerequisiteRoute,
      same(WordHuntStarterContent.baslangicLimani),
    );
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

    final kristalRule = WordHuntRouteCatalog.kristal.unlockRule;
    expect(kristalRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(kristalRule.prerequisiteRoute, same(WordHuntOrman2Content.orman2));
    expect(WordHuntOrman2Content.orman2.unlockStarsRequired, 0);
    expect(WordHuntKristalContent.kristalVadisi.unlockStarsRequired, 0);
    expect(
      WordHuntRouteCatalog.kristal.lockedMessage,
      'Kadim Orman’ı tamamlayarak aç.',
    );

    final kayipRule = WordHuntRouteCatalog.kayipSehir.unlockRule;
    expect(kayipRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(
      kayipRule.prerequisiteRoute,
      same(WordHuntKristalContent.kristalVadisi),
    );
    expect(kayipRule.requiredStars, 0);
    expect(WordHuntKayipSehirContent.kayipSehir.unlockStarsRequired, 0);
    expect(
      WordHuntRouteCatalog.kayipSehir.lockedMessage,
      'Kristal Vadisi’ni tamamlayarak aç.',
    );

    final yeraltiRule = WordHuntRouteCatalog.yeraltiKralligi.unlockRule;
    expect(yeraltiRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(
      yeraltiRule.prerequisiteRoute,
      same(WordHuntKayipSehirContent.kayipSehir),
    );
    expect(yeraltiRule.requiredStars, 0);
    expect(
      WordHuntYeraltiKralligiContent.yeraltiKralligi.unlockStarsRequired,
      0,
    );
    expect(
      WordHuntRouteCatalog.yeraltiKralligi.lockedMessage,
      'Kayıp Şehir’i tamamlayarak aç.',
    );

    final gunesRule = WordHuntRouteCatalog.gunesImparatorlugu.unlockRule;
    expect(gunesRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(
      gunesRule.prerequisiteRoute,
      same(WordHuntYeraltiKralligiContent.yeraltiKralligi),
    );
    expect(gunesRule.requiredStars, 0);
    expect(
      WordHuntGunesImparatorluguContent.gunesImparatorlugu.unlockStarsRequired,
      0,
    );
    expect(
      WordHuntRouteCatalog.gunesImparatorlugu.lockedMessage,
      'Yeraltı Krallığı’nı tamamlayarak aç.',
    );
  });

  test('fresh progress yalnız Başlangıç Limanı rotasını açar', () {
    const progress = WordHuntProgressSnapshot();

    expect(WordHuntRouteCatalog.starter.isUnlocked(progress), isTrue);
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isFalse);
    expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isFalse);
    expect(WordHuntRouteCatalog.orman2Pilot.isUnlocked(progress), isFalse);
    expect(WordHuntRouteCatalog.kristal.isUnlocked(progress), isFalse);
    expect(WordHuntRouteCatalog.kayipSehir.isUnlocked(progress), isFalse);
    expect(WordHuntRouteCatalog.yeraltiKralligi.isUnlocked(progress), isFalse);
    expect(
      WordHuntRouteCatalog.gunesImparatorlugu.isUnlocked(progress),
      isFalse,
    );
  });

  test('18 Başlangıç yıldızı final olmadan Gökyüzü açmaz', () {
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (final level in WordHuntStarterContent.baslangicLimani.levels.take(
          6,
        ))
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

  test('Başlangıç L20 + en az 18 yıldız Gökyüzü açmaz', () {
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: starterCompleteStars(),
    );

    expect(
      WordHuntRouteProgressEngine.isRouteComplete(
        WordHuntStarterContent.baslangicLimani,
        progress,
      ),
      isFalse,
    );
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isFalse);
  });

  test(
    'Başlangıç complete olsa da Gökyüzü incomplete iken Orman kilitlidir',
    () {
      final progress = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          ...starterCompleteStars(),
          for (final level in WordHuntGokyuzuContent.gokyuzuAdalari.levels.take(
            6,
          ))
            level.id: 3,
        },
        grandfatheredUnlockedRouteIds: <String>{
          WordHuntGokyuzuContent.gokyuzuAdalari.id,
        },
      );

      expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isTrue);
      expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isFalse);
    },
  );

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
    expect(
      WordHuntRouteCatalog.orman2Pilot.unlockRule.currentStars(progress),
      1,
    );
    expect(WordHuntRouteCatalog.orman2Pilot.isUnlocked(progress), isTrue);
  });

  test('Orman Yolu yüksek yıldız ama final yokken Kadim Orman kilitlidir', () {
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (final level in WordHuntOrmanContent.ormanYolu.levels.take(9))
          level.id: 3,
      },
    );

    expect(
      WordHuntRouteCatalog.orman2Pilot.unlockRule.currentStars(progress),
      27,
    );
    expect(WordHuntRouteCatalog.orman2Pilot.isUnlocked(progress), isFalse);
  });

  test('Kadim finali 1 yıldızla tamamlanınca Kristal Vadisi açılır', () {
    final finalLevel = WordHuntOrman2Content.orman2.levels.last;
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{finalLevel.id: 1},
    );

    expect(WordHuntOrman2Content.orman2.unlockStarsRequired, 0);
    expect(WordHuntKristalContent.kristalVadisi.unlockStarsRequired, 0);
    expect(WordHuntRouteCatalog.kristal.isUnlocked(progress), isTrue);
  });

  test('historical five-route complete user unlocks only Kayıp next', () {
    final progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        ...starterCompleteStars(),
        ...skyCompleteStars(),
        WordHuntOrmanContent.ormanYolu.levels.last.id: 1,
        WordHuntOrman2Content.orman2.levels.last.id: 1,
        WordHuntKristalContent.kristalVadisi.levels.last.id: 1,
      },
    );

    expect(WordHuntRouteCatalog.kayipSehir.isUnlocked(progress), isTrue);
    expect(WordHuntRouteCatalog.yeraltiKralligi.isUnlocked(progress), isFalse);
    expect(
      WordHuntRouteCatalog.gunesImparatorlugu.isUnlocked(progress),
      isFalse,
    );
  });

  testWidgets(
    'historical five-route complete user keeps Kayıp access then advances linearly',
    (tester) async {
      var progress = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          ...starterCompleteStars(),
          ...skyCompleteStars(),
          WordHuntOrmanContent.ormanYolu.levels.last.id: 1,
          WordHuntOrman2Content.orman2.levels.last.id: 1,
          WordHuntKristalContent.kristalVadisi.levels.last.id: 1,
        },
      );

      Future<void> pump() async {
        await tester.pumpWidget(
          MaterialApp(
            home: WordHuntRouteSelector(progress: progress, onRouteTap: (_) {}),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pump();
      await tester.ensureVisible(
        find.byKey(const Key('word_hunt_route_card_kayip-sehir')),
      );
      expect(WordHuntRouteCatalog.kayipSehir.isUnlocked(progress), isTrue);
      expect(
        WordHuntRouteCatalog.yeraltiKralligi.isUnlocked(progress),
        isFalse,
      );

      progress = progress.recordLevelResult(
        levelId: WordHuntKayipSehirContent.kayipSehir.levels.last.id,
        stars: 1,
      );
      await pump();
      await tester.ensureVisible(
        find.byKey(const Key('word_hunt_route_card_yeralti-kralligi')),
      );
      expect(WordHuntRouteCatalog.yeraltiKralligi.isUnlocked(progress), isTrue);
      expect(
        WordHuntRouteCatalog.gunesImparatorlugu.isUnlocked(progress),
        isFalse,
      );

      progress = progress.recordLevelResult(
        levelId: WordHuntYeraltiKralligiContent.yeraltiKralligi.levels.last.id,
        stars: 1,
      );
      await pump();
      await tester.ensureVisible(
        find.byKey(const Key('word_hunt_route_card_gunes-imparatorlugu')),
      );
      expect(
        WordHuntRouteCatalog.gunesImparatorlugu.isUnlocked(progress),
        isTrue,
      );
    },
  );

  test(
    'legacy Orman progress Gökyüzü incomplete iken prerequisite bypass etmez',
    () {
      final forest = WordHuntOrmanContent.ormanYolu;
      final progress = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          ...starterCompleteStars(),
          forest.levels[0].id: 3,
          forest.levels[4].id: 2,
        },
        grandfatheredUnlockedRouteIds: <String>{
          WordHuntGokyuzuContent.gokyuzuAdalari.id,
        },
      );

      expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isTrue);
      expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isFalse);
      expect(progress.starsFor(forest.levels[0].id), 3);
      expect(progress.starsFor(forest.levels[4].id), 2);
    },
  );

  test(
    'Gökyüzü sonradan complete olunca Orman açılır ve downstream progress korunur',
    () {
      final forest = WordHuntOrmanContent.ormanYolu;
      var progress = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          ...starterCompleteStars(),
          forest.levels[0].id: 3,
          forest.levels[4].id: 2,
        },
      );

      for (final level in WordHuntGokyuzuContent.gokyuzuAdalari.levels.take(
        6,
      )) {
        progress = progress.recordLevelResult(levelId: level.id, stars: 3);
      }
      progress = progress.recordLevelResult(
        levelId: WordHuntGokyuzuContent.gokyuzuAdalari.levels.last.id,
        stars: 1,
      );

      expect(WordHuntRouteCatalog.orman.isUnlocked(progress), isTrue);
      expect(progress.starsFor(forest.levels[0].id), 3);
      expect(progress.starsFor(forest.levels[4].id), 2);
    },
  );

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

    final stagedFrontierWithThreshold = WordHuntProgressSnapshot(
      bestStarsByLevelId: starterCompleteStars(),
    );
    expect(skyRule.isUnlocked(stagedFrontierWithThreshold), isFalse);

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
    await tester.ensureVisible(
      find.byKey(const Key('word_hunt_route_card_kristal')),
    );
    expect(find.text('Kadim Orman’ı tamamlayarak aç.'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('word_hunt_route_card_kayip-sehir')),
    );
    expect(find.text('Kristal Vadisi’ni tamamlayarak aç.'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('word_hunt_route_card_yeralti-kralligi')),
    );
    expect(find.text('Kayıp Şehir’i tamamlayarak aç.'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('word_hunt_route_card_gunes-imparatorlugu')),
    );
    expect(find.text('Yeraltı Krallığı’nı tamamlayarak aç.'), findsOneWidget);

    final forestCard = find.byKey(const Key('word_hunt_route_card_orman'));
    await tester.ensureVisible(forestCard);
    await tester.tap(forestCard);
    await tester.pump();
    expect(selected, isNull);
  });

  testWidgets(
    'Orman Yolu finali tamamlanınca selector Kadim Orman seçimine izin verir',
    (tester) async {
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
    },
  );

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

  test(
    'kilitli rota mesajı unlock türünü generic olarak desteklemeyi sürdürür',
    () {
      expect(entrySource, contains('String _lockedRouteMessage('));
      expect(
        entrySource,
        contains('final lockedMessage = entry.lockedMessage;'),
      );
      expect(entrySource, contains('return lockedMessage;'));
      expect(entrySource, contains('case WordHuntRouteUnlockKind.routeStars:'));
      expect(
        entrySource,
        contains('case WordHuntRouteUnlockKind.routeComplete:'),
      );
      expect(entrySource, contains('bölümü tamamlaman gerekli.'));
    },
  );

  test(
    'lineer progression için route-id özel selector/renderer if eklenmemiştir',
    () {
      expect(selectorSource, isNot(contains("route.id == 'orman-2'")));
      expect(selectorSource, isNot(contains("route.id == 'orman-yolu'")));
      expect(catalogSource, isNot(contains("if (route.id == 'orman-2')")));
      expect(catalogSource, isNot(contains("if (route.id == 'orman-yolu')")));
      expect(
        catalogSource,
        isNot(contains("if (route.id == 'kristal-vadisi')")),
      );
      expect(entrySource, isNot(contains("route.id == 'orman-2'")));
      expect(entrySource, isNot(contains("route.id == 'kristal-vadisi'")));
      expect(entrySource, isNot(contains("route.id == 'kayip-sehir'")));
      expect(entrySource, isNot(contains("route.id == 'yeralti-kralligi'")));
      expect(entrySource, isNot(contains("route.id == 'gunes-imparatorlugu'")));
    },
  );

  test(
    'route renderer ve gameplay background mevcut route-id if kullanmaz',
    () {
      expect(entrySource, contains('WordHuntRouteCatalog.entryForRouteId('));
      expect(entrySource, contains('_activePresentationKind'));
      expect(entrySource, contains('switch (_activePresentationKind)'));
      expect(entrySource, contains('_gameplayPresentationForLevel('));
      expect(entrySource, contains('.presentationProfile'));
      expect(entrySource, contains('.gameplayForLevel('));
      expect(
        entrySource,
        isNot(contains('route.id == WordHuntGokyuzuMasterArtScreen.routeId')),
      );
      expect(entrySource, isNot(contains("route.id == 'orman-yolu'")));
    },
  );

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
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntKristalContent.kristalVadisi.id,
      )?.presentationKind,
      WordHuntRoutePresentationKind.themedReusable,
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntKayipSehirContent.kayipSehir.id,
      )?.visualTheme,
      same(WordHuntKayipSehirVisualTheme.production),
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntYeraltiKralligiContent.yeraltiKralligi.id,
      )?.visualTheme,
      same(WordHuntYeraltiKralligiVisualTheme.production),
    );
    expect(
      WordHuntRouteCatalog.entryForRouteId(
        WordHuntGunesImparatorluguContent.gunesImparatorlugu.id,
      )?.visualTheme,
      same(WordHuntGunesImparatorluguVisualTheme.production),
    );
  });
}
