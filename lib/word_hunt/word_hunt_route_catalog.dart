import 'package:flutter/material.dart';

import 'word_hunt_gameplay_presentation.dart';
import 'word_hunt_gokyuzu_content.dart';
import 'word_hunt_gunes_imparatorlugu_content.dart';
import 'word_hunt_gunes_imparatorlugu_visual_theme.dart';
import 'word_hunt_kayip_sehir_content.dart';
import 'word_hunt_kayip_sehir_visual_theme.dart';
import 'word_hunt_kristal_content.dart';
import 'word_hunt_kristal_visual_theme.dart';
import 'word_hunt_models.dart';
import 'word_hunt_orman2_content.dart';
import 'word_hunt_orman2_visual_theme.dart';
import 'word_hunt_orman_content.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_starter_content.dart';
import 'word_hunt_yeralti_kralligi_content.dart';
import 'word_hunt_yeralti_kralligi_visual_theme.dart';

/// Production rota seçicisindeki bir rotanın nasıl açıldığını tanımlar.
///
/// Yeni rotalar için selector widget'ına özel koşul eklemek yerine bu veri
/// sözleşmesi kullanılmalıdır.
enum WordHuntRouteUnlockKind { always, routeStars, routeComplete }

/// Production rota ekranının hangi ortak renderer ailesini kullandığını söyler.
///
/// Bu enum rota kimliği değildir. Birden fazla rota aynı presentation kind'ı
/// paylaşabilir; böylece production entry içinde rota-id bazlı `if` zincirleri
/// oluşmaz. Reusable themed renderer yeni rotaların ortak production yoludur.
enum WordHuntRoutePresentationKind {
  referenceRoute,
  gokyuzuMasterArt,
  themedReusable,
}

@immutable
class WordHuntRouteUnlockRule {
  const WordHuntRouteUnlockRule.always()
    : kind = WordHuntRouteUnlockKind.always,
      prerequisiteRoute = null,
      requiredStars = 0;

  const WordHuntRouteUnlockRule.routeStars({
    required this.prerequisiteRoute,
    required this.requiredStars,
  }) : kind = WordHuntRouteUnlockKind.routeStars,
       assert(requiredStars > 0);

  const WordHuntRouteUnlockRule.routeComplete({required this.prerequisiteRoute})
    : kind = WordHuntRouteUnlockKind.routeComplete,
      requiredStars = 0;

  final WordHuntRouteUnlockKind kind;
  final WordHuntRouteDefinition? prerequisiteRoute;
  final int requiredStars;

  bool isUnlocked(WordHuntProgressSnapshot progress) {
    switch (kind) {
      case WordHuntRouteUnlockKind.always:
        return true;
      case WordHuntRouteUnlockKind.routeStars:
        return currentStars(progress) >= requiredStars;
      case WordHuntRouteUnlockKind.routeComplete:
        final prerequisite = prerequisiteRoute;
        if (prerequisite == null) return false;
        return WordHuntRouteProgressEngine.isRouteComplete(
          prerequisite,
          progress,
        );
    }
  }

  int currentStars(WordHuntProgressSnapshot progress) {
    final prerequisite = prerequisiteRoute;
    if (prerequisite == null) return 0;
    return WordHuntRouteProgressEngine.totalStars(prerequisite, progress);
  }

  int currentCompletedLevels(WordHuntProgressSnapshot progress) {
    final prerequisite = prerequisiteRoute;
    if (prerequisite == null) return 0;
    return prerequisite.levels
        .where(
          (level) =>
              WordHuntRouteProgressEngine.isLevelCompleted(level, progress),
        )
        .length;
  }
}

/// Rota kartının ve production route host'un ihtiyaç duyduğu veri paketi.
///
/// Geometri taşımaz ve rota adına göre widget üretmez. Böylece katalog büyürken
/// selector ve production entry içinde rota-id özel bloklar çoğalmaz.
@immutable
class WordHuntRouteCatalogEntry {
  const WordHuntRouteCatalogEntry({
    required this.cardKey,
    required this.route,
    required this.infoCards,
    required this.ordinalLabel,
    required this.icon,
    required this.colors,
    required this.unlockRule,
    required this.presentationKind,
    required this.presentationProfile,
    this.lockedMessage,
    this.visualTheme,
  }) : assert(
         presentationKind != WordHuntRoutePresentationKind.themedReusable ||
             visualTheme != null,
         'themedReusable presentation bir visualTheme gerektirir.',
       );

  final String cardKey;
  final WordHuntRouteDefinition route;
  final List<WordHuntInfoCard> infoCards;
  final String ordinalLabel;
  final IconData icon;
  final List<Color> colors;
  final WordHuntRouteUnlockRule unlockRule;
  final WordHuntRoutePresentationKind presentationKind;
  final WordHuntRoutePresentationProfile presentationProfile;

  /// Kilitli selector kartında gösterilecek ürün metni. Null olduğunda selector
  /// unlock rule'dan mevcut generic açıklamayı üretir.
  final String? lockedMessage;

  /// Yalnız [WordHuntRoutePresentationKind.themedReusable] rotalarında gerekir.
  /// Node koordinatı veya progression içermez; yalnız ortak renderer skinidir.
  final WordHuntRouteVisualTheme? visualTheme;

  bool isUnlocked(WordHuntProgressSnapshot progress) =>
      unlockRule.isUnlocked(progress);
}

/// Kullanıcıya şu anda gerçekten sunulan production Kelime Avı rotaları.
abstract final class WordHuntRouteCatalog {
  static final WordHuntRouteCatalogEntry starter = WordHuntRouteCatalogEntry(
    cardKey: 'starter',
    route: WordHuntStarterContent.baslangicLimani,
    infoCards: WordHuntStarterContent.infoCards,
    ordinalLabel: 'İlk rota',
    icon: Icons.anchor_rounded,
    colors: <Color>[Color(0xFF0E7490), Color(0xFF1E3A8A)],
    unlockRule: WordHuntRouteUnlockRule.always(),
    presentationKind: WordHuntRoutePresentationKind.referenceRoute,
    presentationProfile: WordHuntRoutePresentationProfiles.starter,
  );

  static final WordHuntRouteCatalogEntry gokyuzu = WordHuntRouteCatalogEntry(
    cardKey: 'gokyuzu',
    route: WordHuntGokyuzuContent.gokyuzuAdalari,
    infoCards: WordHuntGokyuzuContent.infoCards,
    ordinalLabel: 'İkinci rota',
    icon: Icons.cloud_rounded,
    colors: <Color>[Color(0xFF6D28D9), Color(0xFF1D4ED8)],
    unlockRule: WordHuntRouteUnlockRule.routeComplete(
      prerequisiteRoute: WordHuntStarterContent.baslangicLimani,
    ),
    lockedMessage: 'Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.',
    presentationKind: WordHuntRoutePresentationKind.gokyuzuMasterArt,
    presentationProfile: WordHuntRoutePresentationProfiles.gokyuzu,
  );

  /// Orman Yolu yalnız Gökyüzü Adaları route-complete olduğunda açılır.
  /// Gökyüzü'nün kendi completion contract'ı final + en az 18 yıldızdır.
  static final WordHuntRouteCatalogEntry orman = WordHuntRouteCatalogEntry(
    cardKey: 'orman',
    route: WordHuntOrmanContent.ormanYolu,
    infoCards: WordHuntOrmanContent.infoCards,
    ordinalLabel: 'Üçüncü rota',
    icon: Icons.park_rounded,
    colors: <Color>[Color(0xFF166534), Color(0xFF3F2B1D)],
    unlockRule: WordHuntRouteUnlockRule.routeComplete(
      prerequisiteRoute: WordHuntGokyuzuContent.gokyuzuAdalari,
    ),
    lockedMessage: 'Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.',
    presentationKind: WordHuntRoutePresentationKind.themedReusable,
    presentationProfile: WordHuntRoutePresentationProfiles.ormanYolu,
    visualTheme: WordHuntRouteVisualThemes.ormanYolu,
  );

  /// Kadim Orman teknik olarak `orman-2` kimliğini korur ve Orman Yolu'nun
  /// route-complete contract'ı sağlandığında açılır. Orman Yolu için ekstra
  /// yıldız eşiği yoktur; final bölümünün en az bir yıldızla bitmesi yeterlidir.
  static final WordHuntRouteCatalogEntry orman2Pilot =
      WordHuntRouteCatalogEntry(
        cardKey: 'orman2',
        route: WordHuntOrman2Content.orman2,
        infoCards: WordHuntOrman2Content.infoCards,
        ordinalLabel: 'Dördüncü rota',
        icon: Icons.forest_rounded,
        colors: const <Color>[Color(0xFF173D2A), Color(0xFF162C24)],
        unlockRule: const WordHuntRouteUnlockRule.routeComplete(
          prerequisiteRoute: WordHuntOrmanContent.ormanYolu,
        ),
        lockedMessage: 'Orman Yolu’nu tamamlayarak aç.',
        presentationKind: WordHuntRoutePresentationKind.themedReusable,
        presentationProfile: WordHuntRoutePresentationProfiles.orman2,
        visualTheme: WordHuntOrman2VisualTheme.production,
      );

  /// Beşinci production rota yalnız Kadim Orman route-complete olduğunda açılır.
  /// Kadim ve Kristal rotalarında ek yıldız kapısı yoktur.
  static final WordHuntRouteCatalogEntry kristal = WordHuntRouteCatalogEntry(
    cardKey: 'kristal',
    route: WordHuntKristalContent.kristalVadisi,
    infoCards: WordHuntKristalContent.infoCards,
    ordinalLabel: 'Beşinci rota',
    icon: Icons.diamond_rounded,
    colors: const <Color>[Color(0xFF6D4BB3), Color(0xFF237D83)],
    unlockRule: const WordHuntRouteUnlockRule.routeComplete(
      prerequisiteRoute: WordHuntOrman2Content.orman2,
    ),
    lockedMessage: 'Kadim Orman’ı tamamlayarak aç.',
    presentationKind: WordHuntRoutePresentationKind.themedReusable,
    presentationProfile: WordHuntRoutePresentationProfiles.kristal,
    visualTheme: WordHuntKristalVisualTheme.production,
  );

  static final WordHuntRouteCatalogEntry kayipSehir =
      WordHuntRouteCatalogEntry(
        cardKey: 'kayip-sehir',
        route: WordHuntKayipSehirContent.kayipSehir,
        infoCards: WordHuntKayipSehirContent.infoCards,
        ordinalLabel: 'Altıncı rota',
        icon: Icons.account_balance_rounded,
        colors: <Color>[
          WordHuntKayipSehirVisualTheme.production.mapTheme.surfaceColor,
          WordHuntKayipSehirVisualTheme.production.mapTheme.pathColor,
        ],
        unlockRule: const WordHuntRouteUnlockRule.routeComplete(
          prerequisiteRoute: WordHuntKristalContent.kristalVadisi,
        ),
        lockedMessage: 'Kristal Vadisi’ni tamamlayarak aç.',
        presentationKind: WordHuntRoutePresentationKind.themedReusable,
        presentationProfile: WordHuntRoutePresentationProfiles.kayipSehir,
        visualTheme: WordHuntKayipSehirVisualTheme.production,
      );

  static final WordHuntRouteCatalogEntry yeraltiKralligi =
      WordHuntRouteCatalogEntry(
        cardKey: 'yeralti-kralligi',
        route: WordHuntYeraltiKralligiContent.yeraltiKralligi,
        infoCards: WordHuntYeraltiKralligiContent.infoCards,
        ordinalLabel: 'Yedinci rota',
        icon: Icons.vpn_key_rounded,
        colors: <Color>[
          WordHuntYeraltiKralligiVisualTheme.production.mapTheme.surfaceColor,
          WordHuntYeraltiKralligiVisualTheme.production.mapTheme.pathColor,
        ],
        unlockRule: const WordHuntRouteUnlockRule.routeComplete(
          prerequisiteRoute: WordHuntKayipSehirContent.kayipSehir,
        ),
        lockedMessage: 'Kayıp Şehir’i tamamlayarak aç.',
        presentationKind: WordHuntRoutePresentationKind.themedReusable,
        presentationProfile: WordHuntRoutePresentationProfiles.yeraltiKralligi,
        visualTheme: WordHuntYeraltiKralligiVisualTheme.production,
      );

  static final WordHuntRouteCatalogEntry gunesImparatorlugu =
      WordHuntRouteCatalogEntry(
        cardKey: 'gunes-imparatorlugu',
        route: WordHuntGunesImparatorluguContent.gunesImparatorlugu,
        infoCards: WordHuntGunesImparatorluguContent.infoCards,
        ordinalLabel: 'Sekizinci rota',
        icon: Icons.wb_sunny_rounded,
        colors: <Color>[
          WordHuntGunesImparatorluguVisualTheme.production.mapTheme.surfaceColor,
          WordHuntGunesImparatorluguVisualTheme.production.mapTheme.pathColor,
        ],
        unlockRule: const WordHuntRouteUnlockRule.routeComplete(
          prerequisiteRoute: WordHuntYeraltiKralligiContent.yeraltiKralligi,
        ),
        lockedMessage: 'Yeraltı Krallığı’nı tamamlayarak aç.',
        presentationKind: WordHuntRoutePresentationKind.themedReusable,
        presentationProfile: WordHuntRoutePresentationProfiles.gunesImparatorlugu,
        visualTheme: WordHuntGunesImparatorluguVisualTheme.production,
      );

  static final List<WordHuntRouteCatalogEntry> entries =
      <WordHuntRouteCatalogEntry>[
        starter,
        gokyuzu,
        orman,
        orman2Pilot,
        kristal,
        kayipSehir,
        yeraltiKralligi,
        gunesImparatorlugu,
      ];

  static final List<WordHuntRouteCatalogEntry> _presentationEntries =
      <WordHuntRouteCatalogEntry>[...entries];

  /// Catalog mode dışında doğrudan QA rotası açıldığında da canlı rotaların
  /// mevcut production presentation'ını korur.
  static WordHuntRouteCatalogEntry? entryForRouteId(String routeId) {
    for (final entry in _presentationEntries) {
      if (entry.route.id == routeId) return entry;
    }
    return null;
  }
}
