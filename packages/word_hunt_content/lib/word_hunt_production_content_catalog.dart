import 'word_hunt_gokyuzu_content.dart';
import 'word_hunt_gunes_imparatorlugu_content.dart';
import 'word_hunt_kayip_sehir_content.dart';
import 'word_hunt_kristal_content.dart';
import 'word_hunt_orman2_content.dart';
import 'word_hunt_orman_content.dart';
import 'word_hunt_starter_content.dart';
import 'word_hunt_yeralti_kralligi_content.dart';
import 'word_hunt_models.dart';

/// Pure production-content unlock semantics, intentionally separate from
/// Flutter presentation, artwork, and app navigation.
enum WordHuntContentRouteUnlockKind { always, routeStars, routeComplete }

class WordHuntContentRouteUnlockRule {
  const WordHuntContentRouteUnlockRule.always()
    : kind = WordHuntContentRouteUnlockKind.always,
      prerequisiteRouteId = null,
      requiredStars = 0;

  const WordHuntContentRouteUnlockRule.routeStars({
    required this.prerequisiteRouteId,
    required this.requiredStars,
  }) : kind = WordHuntContentRouteUnlockKind.routeStars;

  const WordHuntContentRouteUnlockRule.routeComplete({
    required this.prerequisiteRouteId,
  }) : kind = WordHuntContentRouteUnlockKind.routeComplete,
       requiredStars = 0;

  final WordHuntContentRouteUnlockKind kind;
  final String? prerequisiteRouteId;
  final int requiredStars;
}

/// Content-side metadata for one production route.
///
/// UI iconography, colors, visual themes, renderer selection, and navigation
/// remain application concerns.
class WordHuntProductionContentEntry {
  const WordHuntProductionContentEntry({
    required this.cardKey,
    required this.route,
    required this.infoCards,
    required this.ordinalLabel,
    required this.unlockRule,
    this.lockedMessage,
  });

  final String cardKey;
  final WordHuntRouteDefinition route;
  final List<WordHuntInfoCard> infoCards;
  final String ordinalLabel;
  final WordHuntContentRouteUnlockRule unlockRule;
  final String? lockedMessage;
}

/// The single production authority for Word Hunt route/content identity,
/// ordering, declarations, and unlock metadata.
abstract final class WordHuntProductionContentCatalog {
  static const starter = WordHuntProductionContentEntry(
    cardKey: 'starter',
    route: WordHuntStarterContent.baslangicLimani,
    infoCards: WordHuntStarterContent.infoCards,
    ordinalLabel: 'İlk rota',
    unlockRule: WordHuntContentRouteUnlockRule.always(),
  );

  static const gokyuzu = WordHuntProductionContentEntry(
    cardKey: 'gokyuzu',
    route: WordHuntGokyuzuContent.gokyuzuAdalari,
    infoCards: WordHuntGokyuzuContent.infoCards,
    ordinalLabel: 'İkinci rota',
    unlockRule: WordHuntContentRouteUnlockRule.routeComplete(
      prerequisiteRouteId: 'baslangic-limani',
    ),
    lockedMessage: 'Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.',
  );

  static const orman = WordHuntProductionContentEntry(
    cardKey: 'orman',
    route: WordHuntOrmanContent.ormanYolu,
    infoCards: WordHuntOrmanContent.infoCards,
    ordinalLabel: 'Üçüncü rota',
    unlockRule: WordHuntContentRouteUnlockRule.routeComplete(
      prerequisiteRouteId: 'gokyuzu-adalari',
    ),
    lockedMessage: 'Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.',
  );

  static const orman2Pilot = WordHuntProductionContentEntry(
    cardKey: 'orman2',
    route: WordHuntOrman2Content.orman2,
    infoCards: WordHuntOrman2Content.infoCards,
    ordinalLabel: 'Dördüncü rota',
    unlockRule: WordHuntContentRouteUnlockRule.routeComplete(
      prerequisiteRouteId: 'orman-yolu',
    ),
    lockedMessage: 'Orman Yolu’nu tamamlayarak aç.',
  );

  static const kristal = WordHuntProductionContentEntry(
    cardKey: 'kristal',
    route: WordHuntKristalContent.kristalVadisi,
    infoCards: WordHuntKristalContent.infoCards,
    ordinalLabel: 'Beşinci rota',
    unlockRule: WordHuntContentRouteUnlockRule.routeComplete(
      prerequisiteRouteId: 'orman-2',
    ),
    lockedMessage: 'Kadim Orman’ı tamamlayarak aç.',
  );

  static const kayipSehir = WordHuntProductionContentEntry(
    cardKey: 'kayip-sehir',
    route: WordHuntKayipSehirContent.kayipSehir,
    infoCards: WordHuntKayipSehirContent.infoCards,
    ordinalLabel: 'Altıncı rota',
    unlockRule: WordHuntContentRouteUnlockRule.routeComplete(
      prerequisiteRouteId: 'kristal-vadisi',
    ),
    lockedMessage: 'Kristal Vadisi’ni tamamlayarak aç.',
  );

  static const yeraltiKralligi = WordHuntProductionContentEntry(
    cardKey: 'yeralti-kralligi',
    route: WordHuntYeraltiKralligiContent.yeraltiKralligi,
    infoCards: WordHuntYeraltiKralligiContent.infoCards,
    ordinalLabel: 'Yedinci rota',
    unlockRule: WordHuntContentRouteUnlockRule.routeComplete(
      prerequisiteRouteId: 'kayip-sehir',
    ),
    lockedMessage: 'Kayıp Şehir’i tamamlayarak aç.',
  );

  static const gunesImparatorlugu = WordHuntProductionContentEntry(
    cardKey: 'gunes-imparatorlugu',
    route: WordHuntGunesImparatorluguContent.gunesImparatorlugu,
    infoCards: WordHuntGunesImparatorluguContent.infoCards,
    ordinalLabel: 'Sekizinci rota',
    unlockRule: WordHuntContentRouteUnlockRule.routeComplete(
      prerequisiteRouteId: 'yeralti-kralligi',
    ),
    lockedMessage: 'Yeraltı Krallığı’nı tamamlayarak aç.',
  );

  static const entries = <WordHuntProductionContentEntry>[
    starter,
    gokyuzu,
    orman,
    orman2Pilot,
    kristal,
    kayipSehir,
    yeraltiKralligi,
    gunesImparatorlugu,
  ];

  static WordHuntProductionContentEntry? entryForRouteId(String routeId) {
    for (final entry in entries) {
      if (entry.route.id == routeId) {
        return entry;
      }
    }
    return null;
  }

  static WordHuntRouteDefinition? routeForId(String routeId) =>
      entryForRouteId(routeId)?.route;
}
