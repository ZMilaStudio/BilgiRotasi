import 'word_hunt_models.dart';

class WordHuntProgressSnapshot {
  const WordHuntProgressSnapshot({
    this.bestStarsByLevelId = const <String, int>{},
    this.unlockedInfoCardIds = const <String>{},
  });

  final Map<String, int> bestStarsByLevelId;
  final Set<String> unlockedInfoCardIds;

  int starsFor(String levelId) => bestStarsByLevelId[levelId] ?? 0;

  WordHuntProgressSnapshot recordLevelResult({
    required String levelId,
    required int stars,
    Iterable<String> unlockedInfoCards = const <String>[],
  }) {
    final safeStars = stars.clamp(0, 3).toInt();
    final current = starsFor(levelId);
    final nextBest = safeStars > current ? safeStars : current;

    return WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        ...bestStarsByLevelId,
        levelId: nextBest,
      },
      unlockedInfoCardIds: <String>{
        ...unlockedInfoCardIds,
        ...unlockedInfoCards.where((id) => id.trim().isNotEmpty),
      },
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

    // Canonical 10-bölümlük rota sözleşmesinde 7 tamamlandığında 8 ve 9
    // paralel olarak açılır. 8 normal bir bölümdür; bonus değildir ve 9 için
    // geçiş kapısı sayılmaz. Final 10 ise yalnız 9 tamamlandıktan sonra açılır.
    if (route.levels.length == 10 && levelIndex == 9) {
      return isLevelCompleted(route.levels[6], progress);
    }

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
