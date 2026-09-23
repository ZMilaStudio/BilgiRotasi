import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_progress_codec.dart';

/// Pure migration rules for a caller-supplied frozen legacy route catalog.
///
/// The host app owns its content declarations and passes the historically
/// frozen routes into this domain contract. That keeps content authority out of
/// the shared domain package while preserving the legacy migration semantics.
abstract final class WordHuntLegacyProgressMigration {
  static WordHuntProgressSnapshot migrate(
    WordHuntProgressDecodeResult decoded, {
    required List<WordHuntRouteDefinition> frozenLegacyRoutes,
  }) {
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
        ...deriveLegacyAccessEntitlements(
          legacy,
          frozenLegacyRoutes: frozenLegacyRoutes,
        ),
      },
      lastActiveRouteId:
          legacy.lastActiveRouteId ??
          deriveLastActiveRouteFallback(
            legacy,
            frozenLegacyRoutes: frozenLegacyRoutes,
          ),
    );
  }

  static Set<String> deriveLegacyAccessEntitlements(
    WordHuntProgressSnapshot legacy, {
    required List<WordHuntRouteDefinition> frozenLegacyRoutes,
  }) {
    if (frozenLegacyRoutes.isEmpty) return const <String>{};

    var furthestAccessibleIndex = 0;

    for (var index = 0; index < frozenLegacyRoutes.length; index++) {
      if (_hasPersistedProgress(frozenLegacyRoutes[index], legacy)) {
        furthestAccessibleIndex =
            index > furthestAccessibleIndex ? index : furthestAccessibleIndex;
      }
    }

    for (var index = 0; index + 1 < frozenLegacyRoutes.length; index++) {
      if (isFrozenLegacyRouteComplete(frozenLegacyRoutes[index], legacy)) {
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
    WordHuntProgressSnapshot legacy, {
    required List<WordHuntRouteDefinition> frozenLegacyRoutes,
  }) {
    for (var index = frozenLegacyRoutes.length - 1; index >= 0; index--) {
      final route = frozenLegacyRoutes[index];
      if (_hasPersistedProgress(route, legacy)) {
        return route.id;
      }
    }
    return null;
  }

  static bool isFrozenLegacyRouteComplete(
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

  static bool _hasPersistedProgress(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) {
    return route.levels.any(
      (level) => progress.bestStarsByLevelId.containsKey(level.id),
    );
  }
}
