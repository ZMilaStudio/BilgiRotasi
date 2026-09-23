import 'package:flutter/material.dart';
import 'package:word_hunt_content/word_hunt_production_content_catalog.dart';

import 'word_hunt_gameplay_presentation.dart';
import 'word_hunt_gunes_imparatorlugu_visual_theme.dart';
import 'word_hunt_kayip_sehir_visual_theme.dart';
import 'word_hunt_kristal_visual_theme.dart';
import 'word_hunt_models.dart';
import 'word_hunt_orman2_visual_theme.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_visual_theme.dart';
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
      unlockRule.isUnlocked(progress) ||
      progress.grandfatheredUnlockedRouteIds.contains(route.id);
}

/// Application presentation adapter over the shared production content authority.
abstract final class WordHuntRouteCatalog {
  static WordHuntRouteCatalogEntry _entry({
    required String routeId,
    required IconData icon,
    required List<Color> colors,
    required WordHuntRoutePresentationKind presentationKind,
    required WordHuntRoutePresentationProfile presentationProfile,
    WordHuntRouteVisualTheme? visualTheme,
  }) {
    final content = WordHuntProductionContentCatalog.entryForRouteId(routeId);
    if (content == null) {
      throw StateError('Bilinmeyen shared content route: $routeId');
    }
    return WordHuntRouteCatalogEntry(
      cardKey: content.cardKey,
      route: content.route,
      infoCards: content.infoCards,
      ordinalLabel: content.ordinalLabel,
      icon: icon,
      colors: colors,
      unlockRule: _unlockRuleFor(content.unlockRule),
      lockedMessage: content.lockedMessage,
      presentationKind: presentationKind,
      presentationProfile: presentationProfile,
      visualTheme: visualTheme,
    );
  }

  static WordHuntRouteUnlockRule _unlockRuleFor(
    WordHuntContentRouteUnlockRule rule,
  ) {
    switch (rule.kind) {
      case WordHuntContentRouteUnlockKind.always:
        return const WordHuntRouteUnlockRule.always();
      case WordHuntContentRouteUnlockKind.routeStars:
        final prerequisite = _prerequisiteRouteFor(rule);
        return WordHuntRouteUnlockRule.routeStars(
          prerequisiteRoute: prerequisite,
          requiredStars: rule.requiredStars,
        );
      case WordHuntContentRouteUnlockKind.routeComplete:
        return WordHuntRouteUnlockRule.routeComplete(
          prerequisiteRoute: _prerequisiteRouteFor(rule),
        );
    }
  }

  static WordHuntRouteDefinition _prerequisiteRouteFor(
    WordHuntContentRouteUnlockRule rule,
  ) {
    final routeId = rule.prerequisiteRouteId;
    final route =
        routeId == null
            ? null
            : WordHuntProductionContentCatalog.routeForId(routeId);
    if (route == null) {
      throw StateError('Shared content prerequisite missing: $routeId');
    }
    return route;
  }

  static final WordHuntRouteCatalogEntry starter = _entry(
    routeId: 'baslangic-limani',
    icon: Icons.anchor_rounded,
    colors: const <Color>[Color(0xFF0E7490), Color(0xFF1E3A8A)],
    presentationKind: WordHuntRoutePresentationKind.referenceRoute,
    presentationProfile: WordHuntRoutePresentationProfiles.starter,
  );

  static final WordHuntRouteCatalogEntry gokyuzu = _entry(
    routeId: 'gokyuzu-adalari',
    icon: Icons.cloud_rounded,
    colors: const <Color>[Color(0xFF6D28D9), Color(0xFF1D4ED8)],
    presentationKind: WordHuntRoutePresentationKind.gokyuzuMasterArt,
    presentationProfile: WordHuntRoutePresentationProfiles.gokyuzu,
  );

  static final WordHuntRouteCatalogEntry orman = _entry(
    routeId: 'orman-yolu',
    icon: Icons.park_rounded,
    colors: const <Color>[Color(0xFF166534), Color(0xFF3F2B1D)],
    presentationKind: WordHuntRoutePresentationKind.themedReusable,
    presentationProfile: WordHuntRoutePresentationProfiles.ormanYolu,
    visualTheme: WordHuntRouteVisualThemes.ormanYolu,
  );

  static final WordHuntRouteCatalogEntry orman2Pilot = _entry(
    routeId: 'orman-2',
    icon: Icons.forest_rounded,
    colors: const <Color>[Color(0xFF173D2A), Color(0xFF162C24)],
    presentationKind: WordHuntRoutePresentationKind.themedReusable,
    presentationProfile: WordHuntRoutePresentationProfiles.orman2,
    visualTheme: WordHuntOrman2VisualTheme.production,
  );

  static final WordHuntRouteCatalogEntry kristal = _entry(
    routeId: 'kristal-vadisi',
    icon: Icons.diamond_rounded,
    colors: const <Color>[Color(0xFF6D4BB3), Color(0xFF237D83)],
    presentationKind: WordHuntRoutePresentationKind.themedReusable,
    presentationProfile: WordHuntRoutePresentationProfiles.kristal,
    visualTheme: WordHuntKristalVisualTheme.production,
  );

  static final WordHuntRouteCatalogEntry kayipSehir = _entry(
    routeId: 'kayip-sehir',
    icon: Icons.account_balance_rounded,
    colors: <Color>[
      WordHuntKayipSehirVisualTheme.production.mapTheme.surfaceColor,
      WordHuntKayipSehirVisualTheme.production.mapTheme.pathColor,
    ],
    presentationKind: WordHuntRoutePresentationKind.themedReusable,
    presentationProfile: WordHuntRoutePresentationProfiles.kayipSehir,
    visualTheme: WordHuntKayipSehirVisualTheme.production,
  );

  static final WordHuntRouteCatalogEntry yeraltiKralligi = _entry(
    routeId: 'yeralti-kralligi',
    icon: Icons.vpn_key_rounded,
    colors: <Color>[
      WordHuntYeraltiKralligiVisualTheme.production.mapTheme.surfaceColor,
      WordHuntYeraltiKralligiVisualTheme.production.mapTheme.pathColor,
    ],
    presentationKind: WordHuntRoutePresentationKind.themedReusable,
    presentationProfile: WordHuntRoutePresentationProfiles.yeraltiKralligi,
    visualTheme: WordHuntYeraltiKralligiVisualTheme.production,
  );

  static final WordHuntRouteCatalogEntry gunesImparatorlugu = _entry(
    routeId: 'gunes-imparatorlugu',
    icon: Icons.wb_sunny_rounded,
    colors: <Color>[
      WordHuntGunesImparatorluguVisualTheme.production.mapTheme.surfaceColor,
      WordHuntGunesImparatorluguVisualTheme.production.mapTheme.pathColor,
    ],
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
