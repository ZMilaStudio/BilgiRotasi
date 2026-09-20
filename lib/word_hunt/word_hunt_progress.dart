import 'word_hunt_models.dart';

class WordHuntProgressSnapshot {
  const WordHuntProgressSnapshot({
    this.bestStarsByLevelId = const <String, int>{},
    this.unlockedInfoCardIds = const <String>{},
    this.unlockedRouteRewardIds = const <String>{},
    this.bestBonusFoundCountByLevelId = const <String, int>{},
    this.grandfatheredUnlockedRouteIds = const <String>{},
    this.lastActiveRouteId,
  });

  final Map<String, int> bestStarsByLevelId;
  final Set<String> unlockedInfoCardIds;
  final Set<String> unlockedRouteRewardIds;
  final Map<String, int> bestBonusFoundCountByLevelId;
  final Set<String> grandfatheredUnlockedRouteIds;
  final String? lastActiveRouteId;

  int starsFor(String levelId) => bestStarsByLevelId[levelId] ?? 0;

  int? bestBonusFoundCountFor(String levelId) =>
      bestBonusFoundCountByLevelId[levelId];

  WordHuntProgressSnapshot recordLevelResult({
    required String levelId,
    required int stars,
    Iterable<String> unlockedInfoCards = const <String>[],
    int? foundBonusCount,
  }) {
    if (foundBonusCount != null && foundBonusCount < 0) {
      throw ArgumentError.value(
        foundBonusCount,
        'foundBonusCount',
        'negatif olamaz',
      );
    }

    final safeStars = stars.clamp(0, 3).toInt();
    final current = starsFor(levelId);
    final nextBest = safeStars > current ? safeStars : current;

    final nextBonusCounts = <String, int>{
      ...bestBonusFoundCountByLevelId,
    };
    if (foundBonusCount != null) {
      final currentBonus = bestBonusFoundCountByLevelId[levelId];
      if (currentBonus == null || foundBonusCount > currentBonus) {
        nextBonusCounts[levelId] = foundBonusCount;
      }
    }

    return WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        ...bestStarsByLevelId,
        levelId: nextBest,
      },
      unlockedInfoCardIds: <String>{
        ...unlockedInfoCardIds,
        ...unlockedInfoCards.where((id) => id.trim().isNotEmpty),
      },
      unlockedRouteRewardIds: unlockedRouteRewardIds,
      bestBonusFoundCountByLevelId: nextBonusCounts,
      grandfatheredUnlockedRouteIds: grandfatheredUnlockedRouteIds,
      lastActiveRouteId: lastActiveRouteId,
    );
  }

  WordHuntProgressSnapshot grantRouteReward(String rewardId) {
    final normalized = rewardId.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(rewardId, 'rewardId', 'boş olamaz');
    }
    if (unlockedRouteRewardIds.contains(normalized)) return this;

    return WordHuntProgressSnapshot(
      bestStarsByLevelId: bestStarsByLevelId,
      unlockedInfoCardIds: unlockedInfoCardIds,
      unlockedRouteRewardIds: <String>{
        ...unlockedRouteRewardIds,
        normalized,
      },
      bestBonusFoundCountByLevelId: bestBonusFoundCountByLevelId,
      grandfatheredUnlockedRouteIds: grandfatheredUnlockedRouteIds,
      lastActiveRouteId: lastActiveRouteId,
    );
  }

  WordHuntProgressSnapshot grantGrandfatheredRouteAccess(String routeId) {
    final normalized = routeId.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(routeId, 'routeId', 'boş olamaz');
    }
    if (grandfatheredUnlockedRouteIds.contains(normalized)) return this;

    return WordHuntProgressSnapshot(
      bestStarsByLevelId: bestStarsByLevelId,
      unlockedInfoCardIds: unlockedInfoCardIds,
      unlockedRouteRewardIds: unlockedRouteRewardIds,
      bestBonusFoundCountByLevelId: bestBonusFoundCountByLevelId,
      grandfatheredUnlockedRouteIds: <String>{
        ...grandfatheredUnlockedRouteIds,
        normalized,
      },
      lastActiveRouteId: lastActiveRouteId,
    );
  }

  WordHuntProgressSnapshot markLastActiveRoute(String routeId) {
    final normalized = routeId.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(routeId, 'routeId', 'boş olamaz');
    }
    if (lastActiveRouteId == normalized) return this;

    return WordHuntProgressSnapshot(
      bestStarsByLevelId: bestStarsByLevelId,
      unlockedInfoCardIds: unlockedInfoCardIds,
      unlockedRouteRewardIds: unlockedRouteRewardIds,
      bestBonusFoundCountByLevelId: bestBonusFoundCountByLevelId,
      grandfatheredUnlockedRouteIds: grandfatheredUnlockedRouteIds,
      lastActiveRouteId: normalized,
    );
  }
}

class WordHuntRouteProgressEngine {
  WordHuntRouteProgressEngine._();

  static int totalStars(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) {
    return route.levels.fold<int>(
      0,
      (total, level) => total + progress.starsFor(level.id),
    );
  }

  static bool isLevelCompleted(
    WordHuntLevelDefinition level,
    WordHuntProgressSnapshot progress,
  ) {
    return progress.starsFor(level.id) >= 1;
  }

  static bool isLevelUnlocked(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
    int levelIndex,
  ) {
    if (levelIndex < 1 || levelIndex > route.levels.length) {
      return false;
    }
    if (levelIndex == 1) {
      return true;
    }

    // Canonical rota ilerlemesi sıralıdır: her bölüm yalnız kendinden önceki
    // bölüm tamamlandığında açılır. Bu nedenle 7→8, 8→9 ve 9→10 zinciri
    // korunur. 8 normal bir bölümdür; bonus değildir.
    final previous = route.levels[levelIndex - 2];
    return isLevelCompleted(previous, progress);
  }

  static bool isRouteComplete(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) {
    if (route.levels.isEmpty) {
      return false;
    }

    final finalLevel = route.levels.last;
    return finalLevel.type == WordHuntLevelType.routeFinal &&
        isLevelCompleted(finalLevel, progress) &&
        totalStars(route, progress) >= route.unlockStarsRequired;
  }

  static int nextPlayableLevelIndex(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) {
    for (var index = 1; index <= route.levels.length; index++) {
      final level = route.levels[index - 1];
      if (isLevelUnlocked(route, progress, index) &&
          !isLevelCompleted(level, progress)) {
        return index;
      }
    }
    return route.levels.isEmpty ? 0 : route.levels.length;
  }
}
