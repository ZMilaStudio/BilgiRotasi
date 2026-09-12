import 'package:flutter/material.dart';

import 'word_hunt_gokyuzu_content.dart';
import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_starter_content.dart';

/// Production rota seçicisindeki bir rotanın nasıl açıldığını tanımlar.
///
/// Yeni rotalar için selector widget'ına özel koşul eklemek yerine bu veri
/// sözleşmesi kullanılmalıdır.
enum WordHuntRouteUnlockKind { always, routeStars }

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

  final WordHuntRouteUnlockKind kind;
  final WordHuntRouteDefinition? prerequisiteRoute;
  final int requiredStars;

  bool isUnlocked(WordHuntProgressSnapshot progress) {
    if (kind == WordHuntRouteUnlockKind.always) return true;
    return currentStars(progress) >= requiredStars;
  }

  int currentStars(WordHuntProgressSnapshot progress) {
    final prerequisite = prerequisiteRoute;
    if (prerequisite == null) return 0;
    return WordHuntRouteProgressEngine.totalStars(prerequisite, progress);
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
///
/// Orman Yolu içeriği doğrulanmış olsa da owner unlock + production skin kararı
/// verilmeden bu listeye bilerek eklenmez.
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

  static const List<WordHuntRouteCatalogEntry> entries =
      <WordHuntRouteCatalogEntry>[starter, gokyuzu];

  /// Catalog mode dışında doğrudan QA rotası açıldığında da canlı rotaların
  /// mevcut production presentation'ını korur. Tanınmayan/gelecek rotalar
  /// owner tarafından kataloğa eklenene kadar null döner.
  static WordHuntRouteCatalogEntry? entryForRouteId(String routeId) {
    for (final entry in entries) {
      if (entry.route.id == routeId) return entry;
    }
    return null;
  }
}
