import 'package:flutter/foundation.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_segment_projection.dart';

@immutable
class WordHuntMilestoneInfoRewardProjection {
  const WordHuntMilestoneInfoRewardProjection({
    required this.milestoneEligible,
    required this.completedSegmentIndex,
    required this.candidateCardIds,
    required this.newlyGrantedCardIds,
    required this.alreadyOwnedCardIds,
    required this.resolvedCards,
    required this.newlyGrantedCards,
  });

  const WordHuntMilestoneInfoRewardProjection.none({
    this.completedSegmentIndex = 0,
  }) : milestoneEligible = false,
       candidateCardIds = const <String>{},
       newlyGrantedCardIds = const <String>{},
       alreadyOwnedCardIds = const <String>{},
       resolvedCards = const <WordHuntInfoCard>[],
       newlyGrantedCards = const <WordHuntInfoCard>[];

  final bool milestoneEligible;
  final int completedSegmentIndex;
  final Set<String> candidateCardIds;
  final Set<String> newlyGrantedCardIds;
  final Set<String> alreadyOwnedCardIds;
  final List<WordHuntInfoCard> resolvedCards;
  final List<WordHuntInfoCard> newlyGrantedCards;

  bool get shouldPresent => newlyGrantedCards.isNotEmpty;
}

/// Segment/milestone bilgi kartı ödülünü mevcut content metadata'sından
/// türeten saf projection authority'si. Kalıcı ownership burada yazılmaz.
abstract final class WordHuntMilestoneInfoRewardEngine {
  static WordHuntMilestoneInfoRewardProjection project({
    required WordHuntRouteDefinition route,
    required List<WordHuntInfoCard> routeInfoCards,
    required String completedLevelId,
    required WordHuntProgressSnapshot beforeProgress,
    Iterable<String> gameplayUnlockedInfoCardIds = const <String>[],
  }) {
    final completedOffset = route.levels.indexWhere(
      (level) => level.id == completedLevelId,
    );
    if (completedOffset < 0) {
      throw ArgumentError.value(
        completedLevelId,
        'completedLevelId',
        'rotada bulunamadı',
      );
    }

    final absoluteLevelIndex = completedOffset + 1;
    final segmentedRoute = WordHuntSegmentProjection.isSegmentedRoute(route);

    int segmentIndex;
    int segmentStart;
    int segmentEnd;
    if (segmentedRoute) {
      final projection = WordHuntSegmentProjection.forLevel(
        route,
        absoluteLevelIndex,
      );
      if (!projection.isSegmentMilestone) {
        return WordHuntMilestoneInfoRewardProjection.none(
          completedSegmentIndex: projection.segmentIndex,
        );
      }
      segmentIndex = projection.segmentIndex;
      segmentStart = projection.segmentStartLevelIndex;
      segmentEnd = projection.segmentEndLevelIndex;
    } else {
      final legacySegmentMilestone =
          route.levels.length == 10 && absoluteLevelIndex == 10;
      if (!legacySegmentMilestone) {
        return const WordHuntMilestoneInfoRewardProjection.none(
          completedSegmentIndex: 1,
        );
      }
      segmentIndex = 1;
      segmentStart = 1;
      segmentEnd = 10;
    }

    final candidateCardIds = <String>{};
    for (var index = segmentStart; index <= segmentEnd; index++) {
      for (final rawId in route.levels[index - 1].infoCardIds) {
        final id = rawId.trim();
        if (id.isNotEmpty) candidateCardIds.add(id);
      }
    }

    final metadataById = <String, WordHuntInfoCard>{
      for (final card in routeInfoCards) card.id: card,
    };
    final gameplayOwned =
        gameplayUnlockedInfoCardIds
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toSet();
    final ownedBeforeMilestone = <String>{
      ...beforeProgress.unlockedInfoCardIds,
      ...gameplayOwned,
    };

    final alreadyOwnedCardIds = <String>{
      for (final id in candidateCardIds)
        if (ownedBeforeMilestone.contains(id)) id,
    };
    final newlyGrantedCardIds = <String>{
      for (final id in candidateCardIds)
        if (!ownedBeforeMilestone.contains(id)) id,
    };
    final resolvedCards = <WordHuntInfoCard>[
      for (final id in candidateCardIds)
        if (metadataById[id] case final card?) card,
    ];
    final newlyGrantedCards = <WordHuntInfoCard>[
      for (final id in newlyGrantedCardIds)
        if (metadataById[id] case final card?) card,
    ];

    return WordHuntMilestoneInfoRewardProjection(
      milestoneEligible: true,
      completedSegmentIndex: segmentIndex,
      candidateCardIds: Set<String>.unmodifiable(candidateCardIds),
      newlyGrantedCardIds: Set<String>.unmodifiable(newlyGrantedCardIds),
      alreadyOwnedCardIds: Set<String>.unmodifiable(alreadyOwnedCardIds),
      resolvedCards: List<WordHuntInfoCard>.unmodifiable(resolvedCards),
      newlyGrantedCards: List<WordHuntInfoCard>.unmodifiable(newlyGrantedCards),
    );
  }
}
