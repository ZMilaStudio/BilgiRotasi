import 'dart:math' as math;
import 'word_hunt_journey_catalog_contract.dart';
import 'word_hunt_journey_save_v1.dart';

/// Null playable ordinal explicitly represents the published end (not N+1).
class JourneyFrontier {
  const JourneyFrontier({
    required this.publishedLevelCount,
    this.playableOrdinal,
  });
  final int publishedLevelCount;
  final int? playableOrdinal;
  bool get atPublishedEnd => playableOrdinal == null;
  int? get lastPublishedOrdinal =>
      publishedLevelCount == 0 ? null : publishedLevelCount;
}

class WordHuntJourneyProgress {
  WordHuntJourneyProgress({required this.catalog, WordHuntJourneySaveV1? save})
    : _save = save ?? WordHuntJourneySaveV1() {
    _advanceFrontier();
  }
  final JourneyCatalog catalog;
  WordHuntJourneySaveV1 _save;
  int _firstIncomplete = 1;
  WordHuntJourneySaveV1 get snapshot => _save;
  bool isCompleted(String stableId) => _save.isCompleted(stableId);
  bool isUnlocked(String stableId) {
    final record = catalog.recordForStableId(stableId);
    return record != null &&
        record.published &&
        (record.ordinal == 1 ||
            _save.isCompleted(journeyStableId(record.ordinal - 1)));
  }

  bool canReplay(String stableId) =>
      isCompleted(stableId) && isUnlocked(stableId);
  bool canJumpToOrdinal(int ordinal) {
    if (!catalog.isPublished(ordinal)) return false;
    final id = journeyStableId(ordinal);
    return isUnlocked(id) && (isCompleted(id) || ordinal == _firstIncomplete);
  }

  JourneyFrontier currentFrontier() => JourneyFrontier(
    publishedLevelCount: catalog.publishedLevelCount,
    playableOrdinal:
        _firstIncomplete <= catalog.publishedLevelCount
            ? _firstIncomplete
            : null,
  );
  int? nextPlayableLevel() => currentFrontier().playableOrdinal;
  int? get lastViewedOrdinal {
    final id = _save.lastViewedLevelId;
    return id == null ? null : catalog.recordForStableId(id)?.ordinal;
  }

  int? resumeOrdinal({bool preferLastViewed = false}) {
    final last = lastViewedOrdinal;
    if (preferLastViewed && last != null && canJumpToOrdinal(last)) return last;
    return nextPlayableLevel() ?? catalog.lastPublished?.ordinal;
  }

  void recordLastViewed(String stableId) {
    final record = catalog.recordForStableId(stableId);
    if (record == null || !canJumpToOrdinal(record.ordinal)) {
      throw StateError('Last viewed must be eligible');
    }
    _save = WordHuntJourneySaveV1(
      bestStarsByStableId: _save.bestStarsByStableId,
      bestBonusByStableId: _save.bestBonusByStableId,
      lastViewedLevelId: stableId,
    );
  }

  void recordCompletion(
    String stableId, {
    required int stars,
    required int bonusFound,
  }) {
    if (stars < 1 || stars > 3 || bonusFound < 0) {
      throw ArgumentError(
        'Completion requires 1..3 stars and nonnegative bonus',
      );
    }
    if (!isUnlocked(stableId)) throw StateError('Locked or unpublished level');
    _save = WordHuntJourneySaveV1(
      bestStarsByStableId: {
        ..._save.bestStarsByStableId,
        stableId: math.max(stars, _save.bestStarsByStableId[stableId] ?? 0),
      },
      bestBonusByStableId: {
        ..._save.bestBonusByStableId,
        stableId: math.max(
          bonusFound,
          _save.bestBonusByStableId[stableId] ?? 0,
        ),
      },
      lastViewedLevelId: _save.lastViewedLevelId,
    );
    _advanceFrontier();
  }

  // One prefix scan on load; monotonic advancement after mutations, never on reads.
  void _advanceFrontier() {
    while (_firstIncomplete <= catalog.publishedLevelCount &&
        _save.isCompleted(journeyStableId(_firstIncomplete))) {
      _firstIncomplete++;
    }
  }
}
