import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_progress_migration.dart';
import 'word_hunt_route_catalog.dart';

@immutable
class WordHuntRouteRewardDefinition {
  const WordHuntRouteRewardDefinition({
    required this.id,
    required this.displayName,
    required this.icon,
  });

  final String id;
  final String displayName;
  final IconData icon;
}

/// Kelime Avı production rota ödüllerinin tek display-metadata kaynağı.
///
/// Runtime identity route tanımındaki `routeRewardId` değeridir; kullanıcıya
/// görünen ad ve Material sembolü bu catalog üzerinden çözülür.
abstract final class WordHuntRouteRewardCatalog {
  static const List<WordHuntRouteRewardDefinition> rewards =
      <WordHuntRouteRewardDefinition>[
        WordHuntRouteRewardDefinition(
          id: 'badge-kelime-yolcusu',
          displayName: 'Kelime Yolcusu',
          icon: Icons.explore_rounded,
        ),
        WordHuntRouteRewardDefinition(
          id: 'badge-gokyuzu-kasifi',
          displayName: 'Gökyüzü Kaşifi',
          icon: Icons.star_rounded,
        ),
        WordHuntRouteRewardDefinition(
          id: 'badge-orman-kasifi',
          displayName: 'Orman Kaşifi',
          icon: Icons.eco_rounded,
        ),
        WordHuntRouteRewardDefinition(
          id: 'badge-kadim-orman-kasifi',
          displayName: 'Kadim Orman Kaşifi',
          icon: Icons.park_rounded,
        ),
        WordHuntRouteRewardDefinition(
          id: 'badge-kristal-kasifi',
          displayName: 'Kristal Kaşifi',
          icon: Icons.diamond_rounded,
        ),
        WordHuntRouteRewardDefinition(
          id: 'badge-kayip-sehir-kasifi',
          displayName: 'Kayıp Şehir Kaşifi',
          icon: Icons.account_balance_rounded,
        ),
        WordHuntRouteRewardDefinition(
          id: 'badge-yeralti-kasifi',
          displayName: 'Yeraltı Kaşifi',
          icon: Icons.vpn_key_rounded,
        ),
        WordHuntRouteRewardDefinition(
          id: 'badge-gunes-kasifi',
          displayName: 'Güneş Kaşifi',
          icon: Icons.wb_sunny_rounded,
        ),
      ];

  static WordHuntRouteRewardDefinition? forId(String rewardId) {
    for (final reward in rewards) {
      if (reward.id == rewardId) return reward;
    }
    return null;
  }

  static WordHuntRouteRewardDefinition? forRoute(
    WordHuntRouteDefinition route,
  ) => forId(route.routeRewardId);
}

@immutable
class WordHuntRouteRewardTransition {
  const WordHuntRouteRewardTransition({
    required this.progress,
    required this.beforeRouteComplete,
    required this.afterRouteComplete,
    required this.rewardGranted,
  });

  final WordHuntProgressSnapshot progress;
  final bool beforeRouteComplete;
  final bool afterRouteComplete;
  final bool rewardGranted;

  bool get routeCompletedNow => !beforeRouteComplete && afterRouteComplete;
}

/// Route-complete milestone ile kalıcı reward ownership arasındaki küçük,
/// test-edilebilir orchestration katmanı.
abstract final class WordHuntRouteRewardEngine {
  static WordHuntRouteRewardTransition recordLevelResult({
    required WordHuntRouteDefinition route,
    required WordHuntProgressSnapshot progress,
    required String levelId,
    required int stars,
    Iterable<String> unlockedInfoCards = const <String>[],
    int? foundBonusCount,
  }) {
    if (foundBonusCount != null) {
      if (foundBonusCount < 0) {
        throw ArgumentError.value(
          foundBonusCount,
          'foundBonusCount',
          'negatif olamaz',
        );
      }
      final levelIndex = route.levels.indexWhere(
        (level) => level.id == levelId,
      );
      if (levelIndex < 0) {
        throw ArgumentError.value(levelId, 'levelId', 'rotada bulunamadı');
      }
      final maximumBonusCount = route.levels[levelIndex].bonusWords.length;
      if (foundBonusCount > maximumBonusCount) {
        throw ArgumentError.value(
          foundBonusCount,
          'foundBonusCount',
          'bölüm bonus kelime sayısını aşamaz',
        );
      }
    }

    final beforeRouteComplete = WordHuntRouteProgressEngine.isRouteComplete(
      route,
      progress,
    );

    var updated = progress.recordLevelResult(
      levelId: levelId,
      stars: stars,
      unlockedInfoCards: unlockedInfoCards,
      foundBonusCount: foundBonusCount,
    );
    final afterRouteComplete = WordHuntRouteProgressEngine.isRouteComplete(
      route,
      updated,
    );

    var rewardGranted = false;
    if (afterRouteComplete &&
        !updated.unlockedRouteRewardIds.contains(route.routeRewardId)) {
      updated = updated.grantRouteReward(route.routeRewardId);
      rewardGranted = true;
    }

    return WordHuntRouteRewardTransition(
      progress: updated,
      beforeRouteComplete: beforeRouteComplete,
      afterRouteComplete: afterRouteComplete,
      rewardGranted: rewardGranted,
    );
  }

  /// Historical progress için yalnız eksik reward ownership kayıtlarını ekler.
  /// Stars, info cards ve progression verisi değiştirilmez.
  static WordHuntProgressSnapshot backfillCompletedRoutes(
    WordHuntProgressSnapshot progress,
  ) {
    var updated = progress;
    for (final route in WordHuntLegacyProgressMigration.frozenLegacyRoutes) {
      if (WordHuntLegacyProgressMigration.isFrozenLegacyRouteComplete(
            route,
            updated,
          ) &&
          !updated.unlockedRouteRewardIds.contains(route.routeRewardId)) {
        updated = updated.grantRouteReward(route.routeRewardId);
      }
    }
    return updated;
  }

  /// Production catalog sırasından current route'un bir sonraki entry'sini
  /// döndürür; son rotada null olur.
  static WordHuntRouteCatalogEntry? nextCatalogEntry(
    WordHuntRouteDefinition route,
  ) {
    final entries = WordHuntRouteCatalog.entries;
    final index = entries.indexWhere((entry) => entry.route.id == route.id);
    if (index < 0 || index + 1 >= entries.length) return null;
    return entries[index + 1];
  }
}
