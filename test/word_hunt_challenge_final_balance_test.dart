import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_scoring.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const routes = <WordHuntRouteDefinition>[
    WordHuntStarterContent.baslangicLimani,
    WordHuntGokyuzuContent.gokyuzuAdalari,
    WordHuntOrmanContent.ormanYolu,
    WordHuntOrman2Content.orman2,
  ];

  test('challenge/final progressive star-time matrix is exact', () {
    _expectBalance(
      WordHuntStarterContent.baslangicLimani.levels[4],
      type: WordHuntLevelType.challenge,
      timeLimitSeconds: 60,
      threeStarMaxMistakes: 0,
      twoStarMaxMistakes: 1,
      threeStarMaxSeconds: 35,
      twoStarMaxSeconds: 50,
    );
    _expectBalance(
      WordHuntStarterContent.baslangicLimani.levels[9],
      type: WordHuntLevelType.routeFinal,
      timeLimitSeconds: 120,
      threeStarMaxMistakes: 0,
      twoStarMaxMistakes: 2,
      threeStarMaxSeconds: 75,
      twoStarMaxSeconds: 100,
    );

    _expectBalance(
      WordHuntGokyuzuContent.gokyuzuAdalari.levels[4],
      type: WordHuntLevelType.challenge,
      timeLimitSeconds: 60,
      threeStarMaxMistakes: 0,
      twoStarMaxMistakes: 1,
      threeStarMaxSeconds: 35,
      twoStarMaxSeconds: 50,
    );
    _expectBalance(
      WordHuntGokyuzuContent.gokyuzuAdalari.levels[9],
      type: WordHuntLevelType.routeFinal,
      timeLimitSeconds: 120,
      threeStarMaxMistakes: 0,
      twoStarMaxMistakes: 2,
      threeStarMaxSeconds: 75,
      twoStarMaxSeconds: 100,
    );

    _expectBalance(
      WordHuntOrmanContent.ormanYolu.levels[4],
      type: WordHuntLevelType.challenge,
      timeLimitSeconds: 60,
      threeStarMaxMistakes: 0,
      twoStarMaxMistakes: 1,
      threeStarMaxSeconds: 25,
      twoStarMaxSeconds: 36,
    );
    _expectBalance(
      WordHuntOrmanContent.ormanYolu.levels[9],
      type: WordHuntLevelType.routeFinal,
      timeLimitSeconds: 120,
      threeStarMaxMistakes: 0,
      twoStarMaxMistakes: 2,
      threeStarMaxSeconds: 50,
      twoStarMaxSeconds: 66,
    );

    _expectBalance(
      WordHuntOrman2Content.orman2.levels[4],
      type: WordHuntLevelType.challenge,
      timeLimitSeconds: 60,
      threeStarMaxMistakes: 0,
      twoStarMaxMistakes: 1,
      threeStarMaxSeconds: 24,
      twoStarMaxSeconds: 35,
    );
    _expectBalance(
      WordHuntOrman2Content.orman2.levels[9],
      type: WordHuntLevelType.routeFinal,
      timeLimitSeconds: 120,
      threeStarMaxMistakes: 0,
      twoStarMaxMistakes: 2,
      threeStarMaxSeconds: 48,
      twoStarMaxSeconds: 64,
    );
  });

  test('normal levels remain mistake-only across all production routes', () {
    for (final route in routes) {
      for (var index = 0; index < route.levels.length; index++) {
        if (index == 4 || index == 9) continue;
        final level = route.levels[index];
        expect(level.type, WordHuntLevelType.normal, reason: level.id);
        expect(level.timeLimitSeconds, isNull, reason: level.id);
        expect(level.starRules.threeStarMaxMistakes, 0, reason: level.id);
        expect(level.starRules.twoStarMaxMistakes, 2, reason: level.id);
        expect(level.starRules.threeStarMaxSeconds, isNull, reason: level.id);
        expect(level.starRules.twoStarMaxSeconds, isNull, reason: level.id);
      }
    }
  });

  test('Orman L5 progressive scoring boundaries are inclusive', () {
    final level = WordHuntOrmanContent.ormanYolu.levels[4];
    _expectScore(level, seconds: 25, mistakes: 0, stars: 3);
    _expectScore(level, seconds: 26, mistakes: 0, stars: 2);
    _expectScore(level, seconds: 36, mistakes: 1, stars: 2);
    _expectScore(level, seconds: 37, mistakes: 0, stars: 1);
    _expectScore(level, seconds: 20, mistakes: 2, stars: 1);
  });

  test('Kadim L5 progressive scoring boundaries are inclusive', () {
    final level = WordHuntOrman2Content.orman2.levels[4];
    _expectScore(level, seconds: 24, mistakes: 0, stars: 3);
    _expectScore(level, seconds: 25, mistakes: 0, stars: 2);
    _expectScore(level, seconds: 35, mistakes: 1, stars: 2);
    _expectScore(level, seconds: 36, mistakes: 0, stars: 1);
  });

  test('Orman L10 progressive scoring boundaries are inclusive', () {
    final level = WordHuntOrmanContent.ormanYolu.levels[9];
    _expectScore(level, seconds: 50, mistakes: 0, stars: 3);
    _expectScore(level, seconds: 51, mistakes: 0, stars: 2);
    _expectScore(level, seconds: 66, mistakes: 2, stars: 2);
    _expectScore(level, seconds: 67, mistakes: 0, stars: 1);
    _expectScore(level, seconds: 40, mistakes: 3, stars: 1);
  });

  test('Kadim L10 progressive scoring boundaries are inclusive', () {
    final level = WordHuntOrman2Content.orman2.levels[9];
    _expectScore(level, seconds: 48, mistakes: 0, stars: 3);
    _expectScore(level, seconds: 49, mistakes: 0, stars: 2);
    _expectScore(level, seconds: 64, mistakes: 2, stars: 2);
    _expectScore(level, seconds: 65, mistakes: 0, stars: 1);
  });

  test('incomplete target set remains zero stars regardless of time or mistakes', () {
    for (final level in <WordHuntLevelDefinition>[
      WordHuntOrmanContent.ormanYolu.levels[4],
      WordHuntOrman2Content.orman2.levels[9],
    ]) {
      final result = WordHuntScoringEngine.calculate(
        level: level,
        foundTargetCount: level.targetWords.length - 1,
        mistakes: 0,
        elapsedSeconds: 0,
      );
      expect(result.completed, isFalse, reason: level.id);
      expect(result.stars, 0, reason: level.id);
    }
  });
}

void _expectBalance(
  WordHuntLevelDefinition level, {
  required WordHuntLevelType type,
  required int timeLimitSeconds,
  required int threeStarMaxMistakes,
  required int twoStarMaxMistakes,
  required int threeStarMaxSeconds,
  required int twoStarMaxSeconds,
}) {
  expect(level.type, type, reason: level.id);
  expect(level.timeLimitSeconds, timeLimitSeconds, reason: level.id);
  expect(
    level.starRules.threeStarMaxMistakes,
    threeStarMaxMistakes,
    reason: level.id,
  );
  expect(
    level.starRules.twoStarMaxMistakes,
    twoStarMaxMistakes,
    reason: level.id,
  );
  expect(
    level.starRules.threeStarMaxSeconds,
    threeStarMaxSeconds,
    reason: level.id,
  );
  expect(
    level.starRules.twoStarMaxSeconds,
    twoStarMaxSeconds,
    reason: level.id,
  );
}

void _expectScore(
  WordHuntLevelDefinition level, {
  required int seconds,
  required int mistakes,
  required int stars,
}) {
  final result = WordHuntScoringEngine.calculate(
    level: level,
    foundTargetCount: level.targetWords.length,
    mistakes: mistakes,
    elapsedSeconds: seconds,
  );
  expect(result.completed, isTrue, reason: level.id);
  expect(
    result.stars,
    stars,
    reason: '${level.id}: ${seconds}s / $mistakes mistakes',
  );
}
