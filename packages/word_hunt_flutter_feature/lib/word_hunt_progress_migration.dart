import 'package:word_hunt_domain/word_hunt_progress_migration.dart' as domain;

import 'word_hunt_gokyuzu_content.dart';
import 'word_hunt_gunes_imparatorlugu_content.dart';
import 'word_hunt_kayip_sehir_content.dart';
import 'word_hunt_kristal_content.dart';
import 'word_hunt_models.dart';
import 'word_hunt_orman2_content.dart';
import 'word_hunt_orman_content.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_progress_codec.dart';
import 'word_hunt_starter_content.dart';
import 'word_hunt_yeralti_kralligi_content.dart';

abstract final class WordHuntLegacyProgressMigration {
  static final WordHuntRouteDefinition _frozenLegacyStarterRoute =
      WordHuntRouteDefinition(
        id: WordHuntStarterContent.baslangicLimani.id,
        title: WordHuntStarterContent.baslangicLimani.title,
        theme: WordHuntStarterContent.baslangicLimani.theme,
        unlockStarsRequired:
            WordHuntStarterContent.baslangicLimani.unlockStarsRequired,
        levels: List<WordHuntLevelDefinition>.unmodifiable(
          WordHuntStarterContent.baslangicLimani.levels.take(10),
        ),
        routeRewardId: WordHuntStarterContent.baslangicLimani.routeRewardId,
      );

  static final List<WordHuntRouteDefinition> frozenLegacyRoutes =
      <WordHuntRouteDefinition>[
        _frozenLegacyStarterRoute,
        WordHuntGokyuzuContent.gokyuzuAdalari,
        WordHuntOrmanContent.ormanYolu,
        WordHuntOrman2Content.orman2,
        WordHuntKristalContent.kristalVadisi,
        WordHuntKayipSehirContent.kayipSehir,
        WordHuntYeraltiKralligiContent.yeraltiKralligi,
        WordHuntGunesImparatorluguContent.gunesImparatorlugu,
      ];

  static WordHuntProgressSnapshot migrate(
    WordHuntProgressDecodeResult decoded,
  ) {
    return domain.WordHuntLegacyProgressMigration.migrate(
      decoded,
      frozenLegacyRoutes: frozenLegacyRoutes,
    );
  }

  static Set<String> deriveLegacyAccessEntitlements(
    WordHuntProgressSnapshot legacy,
  ) {
    return domain
        .WordHuntLegacyProgressMigration.deriveLegacyAccessEntitlements(
      legacy,
      frozenLegacyRoutes: frozenLegacyRoutes,
    );
  }

  static String? deriveLastActiveRouteFallback(
    WordHuntProgressSnapshot legacy,
  ) {
    return domain.WordHuntLegacyProgressMigration.deriveLastActiveRouteFallback(
      legacy,
      frozenLegacyRoutes: frozenLegacyRoutes,
    );
  }

  static bool isFrozenLegacyRouteComplete(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) {
    return domain.WordHuntLegacyProgressMigration.isFrozenLegacyRouteComplete(
      route,
      progress,
    );
  }
}
