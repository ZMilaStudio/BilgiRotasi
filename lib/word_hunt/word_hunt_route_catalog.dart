import 'package:flutter/material.dart';

import 'word_hunt_gokyuzu_content.dart';
import 'word_hunt_models.dart';
import 'word_hunt_orman2_content.dart';
import 'word_hunt_orman2_visual_theme.dart';
import 'word_hunt_orman_content.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_starter_content.dart';

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

  const WordHuntRouteUnlockRule.routeComplete({
    required this.prerequisiteRoute,
  }) : kind = WordHuntRouteUnlockKind.routeComplete,
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
        if (prerequisite == null || prerequisite.levels.isEmpty) return false;
        return WordHuntRouteProgressEngine.isLevelCompleted(
          prerequisite.levels.last,
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
          (level) => WordHuntRouteProgressEngine.isLevelCompleted(
            level,
            progress,
          ),
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

  /// Yalnız [WordHuntRoutePresentationKind.themedReusable] rotalarında gerekir.
  /// Node koordinatı veya progression içermez; yalnız ortak renderer skinidir.
  final WordHuntRouteVisualTheme? visualTheme;

  bool isUnlocked(WordHuntProgressSnapshot progress) =>
      unlockRule.isUnlocked(progress);
}

/// Kullanıcıya şu anda gerçekten sunulan production Kelime Avı rotaları.
abstract final class WordHuntRouteCatalog {
  static const WordHuntRouteCatalogEntry starter = WordHuntRouteCatalogEntry(
    cardKey: 'starter',
    route: WordHuntStarterContent.baslangicLimani,
    infoCards: WordHuntStarterContent.infoCards,
    ordinalLabel: 'İlk rota',
    icon: Icons.anchor_rounded,
    colors: <Color>[Color(0xFF0E7490), Color(0xFF1E3A8A)],
    unlockRule: WordHuntRouteUnlockRule.always(),
    presentationKind: WordHuntRoutePresentationKind.referenceRoute,
  );

  static const WordHuntRouteCatalogEntry gokyuzu = WordHuntRouteCatalogEntry(
    cardKey: 'gokyuzu',
    route: WordHuntGokyuzuContent.gokyuzuAdalari,
    infoCards: WordHuntGokyuzuContent.infoCards,
    ordinalLabel: 'İkinci rota',
    icon: Icons.cloud_rounded,
    colors: <Color>[Color(0xFF6D28D9), Color(0xFF1D4ED8)],
    unlockRule: WordHuntRouteUnlockRule.routeStars(
      prerequisiteRoute: WordHuntStarterContent.baslangicLimani,
      requiredStars: 18,
    ),
    presentationKind: WordHuntRoutePresentationKind.gokyuzuMasterArt,
  );

  /// Owner kararı: Orman Yolu, Başlangıç Limanı'nın 10. bölümü en az bir
  /// yıldızla tamamlandığında açılır. Gökyüzü Adaları'nın durumundan bağımsızdır.
  static const WordHuntRouteCatalogEntry orman = WordHuntRouteCatalogEntry(
    cardKey: 'orman',
    route: WordHuntOrmanContent.ormanYolu,
    infoCards: WordHuntOrmanContent.infoCards,
    ordinalLabel: 'Üçüncü rota',
    icon: Icons.park_rounded,
    colors: <Color>[Color(0xFF166534), Color(0xFF3F2B1D)],
    unlockRule: WordHuntRouteUnlockRule.routeComplete(
      prerequisiteRoute: WordHuntStarterContent.baslangicLimani,
    ),
    presentationKind: WordHuntRoutePresentationKind.themedReusable,
    visualTheme: WordHuntRouteVisualThemes.ormanYolu,
  );

  /// Orman 2 asset-reuse pilotu gerçek production host tarafından tanınır,
  /// ancak owner görsel onayı gelene kadar selector'da görünür rotalara eklenmez.
  /// Böylece pilot runtime yolu gerçek kalırken yarım rota kullanıcıya sızmaz.
  static final WordHuntRouteCatalogEntry orman2Pilot = WordHuntRouteCatalogEntry(
    cardKey: 'orman2-pilot',
    route: WordHuntOrman2Content.orman2,
    infoCards: WordHuntOrman2Content.infoCards,
    ordinalLabel: 'Dördüncü rota pilotu',
    icon: Icons.forest_rounded,
    colors: const <Color>[Color(0xFF173D2A), Color(0xFF162C24)],
    unlockRule: const WordHuntRouteUnlockRule.routeComplete(
      prerequisiteRoute: WordHuntOrmanContent.ormanYolu,
    ),
    presentationKind: WordHuntRoutePresentationKind.themedReusable,
    visualTheme: WordHuntOrman2VisualTheme.production,
  );

  static const List<WordHuntRouteCatalogEntry> entries =
      <WordHuntRouteCatalogEntry>[starter, gokyuzu, orman];

  static final List<WordHuntRouteCatalogEntry> _presentationEntries =
      <WordHuntRouteCatalogEntry>[...entries, orman2Pilot];

  /// Catalog mode dışında doğrudan QA rotası açıldığında da canlı rotaların
  /// mevcut production presentation'ını korur. Pilot rotalar selector'a
  /// açılmadan aynı data-driven presentation lookup'a katılabilir.
  static WordHuntRouteCatalogEntry? entryForRouteId(String routeId) {
    for (final entry in _presentationEntries) {
      if (entry.route.id == routeId) return entry;
    }
    return null;
  }
}
