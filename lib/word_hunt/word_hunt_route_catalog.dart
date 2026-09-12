import 'package:flutter/material.dart';

import 'word_hunt_gokyuzu_content.dart';
import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_starter_content.dart';

/// Production rota seçicisindeki bir rotanın nasıl açıldığını tanımlar.
///
/// Yeni rotalar için selector widget'ına özel koşul eklemek yerine bu veri
/// sözleşmesi kullanılmalıdır.
enum WordHuntRouteUnlockKind { always, routeStars }

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

/// Rota kartının production selector'da ihtiyaç duyduğu veri paketi.
///
/// Geometri taşımaz ve rota ekranı üretmez. Böylece katalog büyürken selector
/// içinde rota-id özel kart blokları veya `_openXRoute` metotları çoğalmaz.
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
  });

  final String cardKey;
  final WordHuntRouteDefinition route;
  final List<WordHuntInfoCard> infoCards;
  final String ordinalLabel;
  final IconData icon;
  final List<Color> colors;
  final WordHuntRouteUnlockRule unlockRule;

  bool isUnlocked(WordHuntProgressSnapshot progress) =>
      unlockRule.isUnlocked(progress);
}

/// Kullanıcıya şu anda gerçekten sunulan production Kelime Avı rotaları.
///
/// Orman Yolu içeriği doğrulanmış olsa da owner unlock kararı verilmeden bu
/// listeye bilerek eklenmez.
abstract final class WordHuntRouteCatalog {
  static const WordHuntRouteCatalogEntry starter = WordHuntRouteCatalogEntry(
    cardKey: 'starter',
    route: WordHuntStarterContent.baslangicLimani,
    infoCards: WordHuntStarterContent.infoCards,
    ordinalLabel: 'İlk rota',
    icon: Icons.anchor_rounded,
    colors: <Color>[Color(0xFF0E7490), Color(0xFF1E3A8A)],
    unlockRule: WordHuntRouteUnlockRule.always(),
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
  );

  static const List<WordHuntRouteCatalogEntry> entries =
      <WordHuntRouteCatalogEntry>[starter, gokyuzu];
}
