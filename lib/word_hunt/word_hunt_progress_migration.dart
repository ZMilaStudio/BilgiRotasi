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
    if (!decoded.requiresMigrationWriteback) {
      return decoded.snapshot;
    }

    final legacy = decoded.snapshot;
    return WordHuntProgressSnapshot(
      bestStarsByLevelId: legacy.bestStarsByLevelId,
      unlockedInfoCardIds: legacy.unlockedInfoCardIds,
      unlockedRouteRewardIds: legacy.unlockedRouteRewardIds,
      bestBonusFoundCountByLevelId: legacy.bestBonusFoundCountByLevelId,
      grandfatheredUnlockedRouteIds: <String>{
        ...legacy.grandfatheredUnlockedRouteIds,
        ...deriveLegacyAccessEntitlements(legacy),
      },
      lastActiveRouteId:
          legacy.lastActiveRouteId ?? deriveLastActiveRouteFallback(legacy),
    );
  }

  static Set<String> deriveLegacyAccessEntitlements(
    WordHuntProgressSnapshot legacy,
  ) {
    if (frozenLegacyRoutes.isEmpty) return const <String>{};

    var furthestAccessibleIndex = 0;

    for (var index = 0; index < frozenLegacyRoutes.length; index++) {
      if (_hasPersistedProgress(frozenLegacyRoutes[index], legacy)) {
        furthestAccessibleIndex =
            index > furthestAccessibleIndex ? index : furthestAccessibleIndex;
      }
    }

    for (var index = 0; index + 1 < frozenLegacyRoutes.length; index++) {
      if (_isFrozenLegacyRouteComplete(frozenLegacyRoutes[index], legacy)) {
        final historicallyOpenedIndex = index + 1;
        furthestAccessibleIndex =
            historicallyOpenedIndex > furthestAccessibleIndex
                ? historicallyOpenedIndex
                : furthestAccessibleIndex;
      }
    }

    return <String>{
      for (var index = 0; index <= furthestAccessibleIndex; index++)
        frozenLegacyRoutes[index].id,
    };
  }

  static String? deriveLastActiveRouteFallback(
    WordHuntProgressSnapshot legacy,
  ) {
    for (var index = frozenLegacyRoutes.length - 1; index >= 0; index--) {
      final route = frozenLegacyRoutes[index];
      if (_hasPersistedProgress(route, legacy)) {
        return route.id;
      }
    }
    return null;
  }

  static bool _hasPersistedProgress(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) {
    return route.levels.any(
      (level) => progress.bestStarsByLevelId.containsKey(level.id),
    );
  }

  static bool _isFrozenLegacyRouteComplete(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) {
    if (route.levels.isEmpty) return false;

    final legacyFinal = route.levels.last;
    if (legacyFinal.type != WordHuntLevelType.routeFinal) return false;
    if (progress.starsFor(legacyFinal.id) < 1) return false;

    var totalStars = 0;
    for (final level in route.levels) {
      totalStars += progress.starsFor(level.id);
    }
    return totalStars >= route.unlockStarsRequired;
  }
}
