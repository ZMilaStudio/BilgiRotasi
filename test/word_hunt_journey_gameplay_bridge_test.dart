import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_content/word_hunt_journey_gameplay_resolver.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_journey_gameplay_completion.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_gameplay_host.dart';
import 'package:word_hunt_flutter_feature/word_hunt_screens.dart';

void main() {
  final resolver = JourneyGameplayResolver();
  final catalog = PublishedJourneyCatalog(levelCount: 15000);
  test('all real payloads are the canonical objects with stable adapters', () {
    for (final level in WordHuntStarterContent.baslangicLimani.levels) {
      final record = catalog.recordForOrdinal(level.index)!;
      expect(resolver.hasGameplayContent(record.stableId), isTrue);
      expect(resolver.resolve(record), same(level));
      expect(record.stableId, isNot(level.id));
    }
  });
  test('publication, payload availability and malformed identities differ', () {
    expect(catalog.isPublished(500), isTrue);
    expect(resolver.hasGameplayContent(journeyStableId(500)), isFalse);
    expect(resolver.resolve(catalog.recordForOrdinal(500)!), isNull);
    expect(resolver.hasGameplayContent('unknown'), isFalse);
    for (final record in [
      const JourneyLevelRecord(
        stableId: 'unknown',
        ordinal: 1,
        published: true,
      ),
      JourneyLevelRecord(
        stableId: journeyStableId(1),
        ordinal: 2,
        published: true,
      ),
      JourneyLevelRecord(
        stableId: journeyStableId(1),
        ordinal: 1,
        published: false,
      ),
      JourneyLevelRecord(
        stableId: journeyStableId(1),
        ordinal: 1,
        published: true,
        gameplayContentId: 'wrong',
      ),
    ]) {
      expect(resolver.resolve(record), isNull);
    }
  });
  for (final ordinal in [1, 10, 20, 31, 40]) {
    test(
      'L$ordinal outcome consumes gameplay score and challenge metadata',
      () {
        final record = catalog.recordForOrdinal(ordinal)!;
        final level = resolver.resolve(record)!;
        final result = JourneyGameplayCompletionBridge.normalize(
          record,
          level,
          WordHuntLevelPlayResult(
            levelId: level.id,
            stars: 2,
            foundBonusCount: level.bonusWords.length,
            unlockedInfoCardIds: const {'legacy-info'},
          ),
        );
        expect(result.stableLevelId, journeyStableId(ordinal));
        expect(result.earnedStars, 2);
        expect(result.bonusFoundCount, level.bonusWords.length);
        expect(result.completed, isTrue);
        expect(result.challenge, ordinal == 20 || ordinal == 40);
      },
    );
  }
  test('normalization fails closed on mismatched or incomplete outcomes', () {
    final record = catalog.recordForOrdinal(1)!;
    final level = resolver.resolve(record)!;
    for (final result in [
      WordHuntLevelPlayResult(
        levelId: 'wrong',
        stars: 3,
        foundBonusCount: 0,
        unlockedInfoCardIds: const {},
      ),
      WordHuntLevelPlayResult(
        levelId: level.id,
        stars: 3,
        unlockedInfoCardIds: const {},
      ),
      WordHuntLevelPlayResult(
        levelId: level.id,
        stars: 0,
        foundBonusCount: 0,
        unlockedInfoCardIds: const {},
      ),
      WordHuntLevelPlayResult(
        levelId: level.id,
        stars: 3,
        foundBonusCount: level.bonusWords.length + 1,
        unlockedInfoCardIds: const {},
      ),
    ]) {
      expect(
        () => JourneyGameplayCompletionBridge.normalize(record, level, result),
        throwsA(anything),
      );
    }
    expect(
      () => JourneyGameplayCompletion(
        stableLevelId: 'id',
        earnedStars: 4,
        bonusFoundCount: 0,
        completed: true,
        challenge: false,
      ),
      throwsArgumentError,
    );
  });
}
