import 'package:word_hunt_domain/word_hunt_journey_progress.dart';
import 'word_hunt_infinite_journey_map_screen.dart';

/// Map receives presentation only, never storage or legacy progression models.
class JourneyMapStateAdapter {
  const JourneyMapStateAdapter(this.progress);
  final WordHuntJourneyProgress progress;
  int get publishedLevelCount => progress.catalog.publishedLevelCount;
  int? get currentOrdinal => progress.currentFrontier().playableOrdinal;
  int? initialOrdinal({bool preferLastViewed = false}) =>
      progress.resumeOrdinal(preferLastViewed: preferLastViewed);
  bool canJumpToOrdinal(int ordinal) => progress.canJumpToOrdinal(ordinal);
  bool jumpToOrdinal(WordHuntJourneyMapController controller, int ordinal) {
    if (!canJumpToOrdinal(ordinal)) return false;
    controller.jumpToLevel(ordinal);
    return true;
  }

  WordHuntJourneyNodePresentation presentationForOrdinal(int ordinal) {
    final record = progress.catalog.recordForOrdinal(ordinal);
    if (record == null || !record.published) {
      throw StateError('Unpublished nodes must not enter the map');
    }
    final stars = progress.snapshot.bestStarsByStableId[record.stableId] ?? 0;
    final state =
        !progress.isUnlocked(record.stableId)
            ? WordHuntJourneyNodeState.locked
            : stars > 0
            ? WordHuntJourneyNodeState.values[stars + 1]
            : WordHuntJourneyNodeState.current;
    return WordHuntJourneyNodePresentation(
      state,
      challenge: record.challenge,
      milestone: record.milestone,
    );
  }
}
