import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_domain/word_hunt_journey_progress.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';

class CountingCatalog implements JourneyCatalog {
  CountingCatalog(this.inner);
  final JourneyCatalog inner;
  int lookups = 0;
  @override
  int get publishedLevelCount => inner.publishedLevelCount;
  @override
  JourneyLevelRecord? recordForOrdinal(int n) {
    lookups++;
    return inner.recordForOrdinal(n);
  }

  @override
  JourneyLevelRecord? recordForStableId(String id) {
    lookups++;
    return inner.recordForStableId(id);
  }

  @override
  bool isPublished(int n) => inner.isPublished(n);
  @override
  JourneyLevelRecord? get firstPublished => inner.firstPublished;
  @override
  JourneyLevelRecord? get lastPublished => inner.lastPublished;
  @override
  int? nextOrdinal(int n) => inner.nextOrdinal(n);
  @override
  int? previousOrdinal(int n) => inner.previousOrdinal(n);
}

void main() {
  test('linear access, monotonic replay, bonus and separate last viewed', () {
    final p = WordHuntJourneyProgress(
      catalog: PublishedJourneyCatalog(levelCount: 3),
    );
    expect(p.isUnlocked(journeyStableId(1)), isTrue);
    expect(p.isUnlocked(journeyStableId(2)), isFalse);
    expect(p.currentFrontier().playableOrdinal, 1);
    expect(p.canReplay(journeyStableId(1)), isFalse);
    expect(
      () => p.recordCompletion(journeyStableId(2), stars: 3, bonusFound: 0),
      throwsStateError,
    );
    p.recordLastViewed(journeyStableId(1));
    p.recordCompletion(journeyStableId(1), stars: 1, bonusFound: 3);
    expect(p.nextPlayableLevel(), 2);
    expect(p.isUnlocked(journeyStableId(2)), isTrue);
    expect(p.canReplay(journeyStableId(1)), isTrue);
    p.recordCompletion(journeyStableId(1), stars: 2, bonusFound: 1);
    p.recordCompletion(journeyStableId(1), stars: 3, bonusFound: 5);
    p.recordCompletion(journeyStableId(1), stars: 1, bonusFound: 1);
    expect(p.snapshot.bestStarsByStableId[journeyStableId(1)], 3);
    expect(p.snapshot.bestBonusByStableId[journeyStableId(1)], 5);
    expect(p.isCompleted(journeyStableId(1)), isTrue);
    expect(p.lastViewedOrdinal, 1);
    expect(p.resumeOrdinal(), 2);
    expect(p.resumeOrdinal(preferLastViewed: true), 1);
    expect(p.canJumpToOrdinal(1), isTrue);
    expect(p.canJumpToOrdinal(2), isTrue);
    expect(p.canJumpToOrdinal(3), isFalse);
    expect(() => p.recordLastViewed(journeyStableId(3)), throwsStateError);
  });
  test('invalid completion fails without mutation', () {
    final p = WordHuntJourneyProgress(
      catalog: PublishedJourneyCatalog(levelCount: 1),
    );
    final before = p.snapshot;
    for (final stars in [-1, 0, 4]) {
      expect(
        () =>
            p.recordCompletion(journeyStableId(1), stars: stars, bonusFound: 0),
        throwsArgumentError,
      );
    }
    expect(
      () => p.recordCompletion(journeyStableId(1), stars: 1, bonusFound: -1),
      throwsArgumentError,
    );
    expect(p.snapshot, same(before));
  });
  test(
    'published end never becomes N+1, future save IDs retained on mutation',
    () {
      final catalog = PublishedJourneyCatalog(
        levelCount: 15000,
        publishedLevelCount: 2,
      );
      final p = WordHuntJourneyProgress(
        catalog: catalog,
        save: WordHuntJourneySaveV1(
          bestStarsByStableId: {journeyStableId(15001): 3},
          bestBonusByStableId: {journeyStableId(15001): 5},
          lastViewedLevelId: journeyStableId(15001),
        ),
      );
      expect(p.resumeOrdinal(preferLastViewed: true), 1);
      for (var n = 1; n <= 2; n++) {
        p.recordCompletion(journeyStableId(n), stars: 1, bonusFound: 0);
      }
      expect(p.currentFrontier().atPublishedEnd, isTrue);
      expect(p.currentFrontier().lastPublishedOrdinal, 2);
      expect(p.nextPlayableLevel(), isNull);
      expect(p.resumeOrdinal(), 2);
      expect(p.canJumpToOrdinal(3), isFalse);
      expect(p.canJumpToOrdinal(15001), isFalse);
      expect(p.isUnlocked(journeyStableId(3)), isFalse);
      expect(
        () => p.recordCompletion(journeyStableId(3), stars: 1, bonusFound: 0),
        throwsStateError,
      );
      expect(p.snapshot.bestStarsByStableId[journeyStableId(15001)], 3);
      expect(p.snapshot.bestBonusByStableId[journeyStableId(15001)], 5);
      expect(p.snapshot.lastViewedLevelId, journeyStableId(15001));
      final expanded = WordHuntJourneyProgress(
        catalog: PublishedJourneyCatalog(levelCount: 3),
        save: p.snapshot,
      );
      expect(expanded.nextPlayableLevel(), 3);
    },
  );
  for (final count in [150, 1500, 15000]) {
    test(
      '$count cached frontier reads and jump eligibility have bounded catalog calls',
      () {
        final c = CountingCatalog(PublishedJourneyCatalog(levelCount: count));
        final p = WordHuntJourneyProgress(
          catalog: c,
          save: WordHuntJourneySaveV1(
            bestStarsByStableId: {
              for (var n = 1; n < count; n++) journeyStableId(n): 2,
            },
          ),
        );
        c.lookups = 0;
        for (var i = 0; i < 1000; i++) {
          expect(p.currentFrontier().playableOrdinal, count);
          expect(p.nextPlayableLevel(), count);
        }
        expect(c.lookups, 0);
        for (final n in [1, count ~/ 2, count]) {
          expect(p.canJumpToOrdinal(n), isTrue);
        }
        expect(c.lookups, 3);
        p.recordCompletion(journeyStableId(count), stars: 3, bonusFound: 0);
        expect(p.currentFrontier().atPublishedEnd, isTrue);
      },
    );
  }
  test('zero published catalog has no resume or eligibility', () {
    final p = WordHuntJourneyProgress(
      catalog: PublishedJourneyCatalog(levelCount: 1, publishedLevelCount: 0),
    );
    expect(p.currentFrontier().atPublishedEnd, isTrue);
    expect(p.resumeOrdinal(), isNull);
    expect(p.canJumpToOrdinal(1), isFalse);
  });
}
