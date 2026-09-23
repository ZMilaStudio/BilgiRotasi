import 'word_hunt_models.dart';

class WordHuntScoreResult {
  const WordHuntScoreResult({required this.stars, required this.completed});

  final int stars;
  final bool completed;
}

class WordHuntScoringEngine {
  WordHuntScoringEngine._();

  static WordHuntScoreResult calculate({
    required WordHuntLevelDefinition level,
    required int foundTargetCount,
    required int mistakes,
    required int elapsedSeconds,
  }) {
    final completed = foundTargetCount >= level.targetWords.length;
    if (!completed) {
      return const WordHuntScoreResult(stars: 0, completed: false);
    }

    final safeMistakes = mistakes < 0 ? 0 : mistakes;
    final safeElapsed = elapsedSeconds < 0 ? 0 : elapsedSeconds;
    final rules = level.starRules;

    if (_passesTier(
      mistakes: safeMistakes,
      elapsedSeconds: safeElapsed,
      maxMistakes: rules.threeStarMaxMistakes,
      maxSeconds: rules.threeStarMaxSeconds,
    )) {
      return const WordHuntScoreResult(stars: 3, completed: true);
    }

    if (_passesTier(
      mistakes: safeMistakes,
      elapsedSeconds: safeElapsed,
      maxMistakes: rules.twoStarMaxMistakes,
      maxSeconds: rules.twoStarMaxSeconds,
    )) {
      return const WordHuntScoreResult(stars: 2, completed: true);
    }

    return const WordHuntScoreResult(stars: 1, completed: true);
  }

  static bool _passesTier({
    required int mistakes,
    required int elapsedSeconds,
    required int? maxMistakes,
    required int? maxSeconds,
  }) {
    final mistakesPass = maxMistakes == null || mistakes <= maxMistakes;
    final timePass = maxSeconds == null || elapsedSeconds <= maxSeconds;
    return mistakesPass && timePass;
  }
}
