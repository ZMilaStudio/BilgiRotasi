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

    // Bonus durak ana rota için zorunlu bir geçiş kapısı değildir. Bir bölümün
    // hemen öncesindeki durak bonus ise ana rota, bonusun öncesindeki bölüm
    // tamamlandığında devam eder. Böylece canonical 7 -> (8 bonus, 9 ana)
    // davranışı rota kimliğine özel if yazmadan bütün 10-bölümlük rotalarda
    // korunur. Final 10'un hemen öncesi 9 normal olduğundan 10 yine yalnız 9
    // tamamlandıktan sonra açılır.
    final previous = route.levels[levelIndex - 2];
    if (previous.type == WordHuntLevelType.bonus && levelIndex >= 3) {
      final levelBeforeBonus = route.levels[levelIndex - 3];
      return isLevelCompleted(levelBeforeBonus, progress);
    }

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
