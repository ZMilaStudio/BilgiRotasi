import 'package:flutter/foundation.dart';

import 'word_hunt_gameplay_presentation.dart';
import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_catalog.dart';
import 'word_hunt_route_rewards.dart';
import 'word_hunt_segment_projection.dart';

enum WordHuntCompletionDestinationKind {
  nextLevel,
  nextSegment,
  nextRoute,
  returnToRoute,
  terminalRouteComplete,
}

@immutable
class WordHuntRouteCompletionSummary {
  const WordHuntRouteCompletionSummary({
    required this.routeId,
    required this.routeTitle,
    required this.totalStars,
    required this.maximumStars,
    required this.knownBonusFoundTotal,
    required this.maximumBonusTotal,
    required this.hasUnknownBonusHistory,
    required this.reward,
    required this.rewardGrantedNow,
    required this.nextUnlockedRoute,
    required this.presentationProfile,
    required this.terminal,
  });

  final String routeId;
  final String routeTitle;
  final int totalStars;
  final int maximumStars;
  final int knownBonusFoundTotal;
  final int maximumBonusTotal;
  final bool hasUnknownBonusHistory;
  final WordHuntRouteRewardDefinition? reward;
  final bool rewardGrantedNow;
  final WordHuntRouteCatalogEntry? nextUnlockedRoute;
  final WordHuntRoutePresentationProfile presentationProfile;
  final bool terminal;
}

@immutable
class WordHuntCompletionDestination {
  const WordHuntCompletionDestination({
    required this.kind,
    required this.completedAbsoluteLevel,
    required this.completedSegment,
    required this.localLevel,
    required this.levelCompletedNow,
    required this.segmentCompletedNow,
    required this.isMajorMidpoint,
    required this.isTrueRouteFinal,
    required this.canonicalNextPlayableLevel,
    required this.nextPlayableSegment,
    required this.routeCompletedNow,
    required this.rewardGrantedNow,
    required this.summary,
  });

  final WordHuntCompletionDestinationKind kind;
  final int completedAbsoluteLevel;
  final int completedSegment;
  final int localLevel;
  final bool levelCompletedNow;
  final bool segmentCompletedNow;
  final bool isMajorMidpoint;
  final bool isTrueRouteFinal;
  final int canonicalNextPlayableLevel;
  final int nextPlayableSegment;
  final bool routeCompletedNow;
  final bool rewardGrantedNow;
  final WordHuntRouteCompletionSummary summary;

  WordHuntRouteCatalogEntry? get nextRoute => summary.nextUnlockedRoute;
}

@immutable
class WordHuntCompletionProcessResult {
  const WordHuntCompletionProcessResult({
    required this.transition,
    required this.destination,
  });

  final WordHuntRouteRewardTransition transition;
  final WordHuntCompletionDestination destination;
}

abstract final class WordHuntCompletionCoordinator {
  static int activeSegmentForProgress({
    required WordHuntRouteDefinition route,
    required WordHuntProgressSnapshot progress,
  }) {
    if (route.segments.isEmpty) return 1;
    final next = WordHuntRouteProgressEngine.nextPlayableLevelIndex(
      route,
      progress,
    );
    final bounded = next.clamp(1, route.levels.length);
    return WordHuntSegmentProjection.forLevel(route, bounded).segmentIndex;
  }

  static WordHuntCompletionDestination resolve({
    required WordHuntRouteDefinition route,
    required String completedLevelId,
    required WordHuntProgressSnapshot beforeProgress,
    required WordHuntProgressSnapshot afterProgress,
    required WordHuntRouteRewardTransition transition,
    List<WordHuntRouteCatalogEntry>? catalogEntries,
  }) {
    final completedIndex = route.levels.indexWhere(
      (level) => level.id == completedLevelId,
    );
    if (completedIndex < 0) {
      throw ArgumentError.value(
        completedLevelId,
        'completedLevelId',
        'rotada bulunamadı',
      );
    }

    final absoluteLevel = completedIndex + 1;
    final level = route.levels[completedIndex];
    final explicitV2 = WordHuntSegmentProjection.isExplicitV2Route(route);
    final projection = explicitV2
        ? WordHuntSegmentProjection.forLevel(route, absoluteLevel)
        : null;
    final completedSegment = projection?.segmentIndex ?? 1;
    final localLevel = projection?.localLevelIndex ?? absoluteLevel;
    final segmentCompletedNow = explicitV2 && (projection?.isSegmentEnd ?? false);
    final isMajorMidpoint = projection?.isMajorMidpoint ?? false;
    final isTrueRouteFinal = projection?.isTrueRouteFinal ?? false;
    final levelCompletedNow =
        !WordHuntRouteProgressEngine.isLevelCompleted(level, beforeProgress) &&
        WordHuntRouteProgressEngine.isLevelCompleted(level, afterProgress);
    final canonicalNextPlayableLevel =
        WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, afterProgress);
    final nextPlayableSegment = _segmentForLevel(
      route,
      canonicalNextPlayableLevel,
    );

    final entries = catalogEntries ?? WordHuntRouteCatalog.entries;
    final nextCandidate = _nextCatalogEntry(route, entries);
    final nextUnlockedRoute =
        nextCandidate != null && nextCandidate.isUnlocked(afterProgress)
            ? nextCandidate
            : null;
    final currentIndex = entries.indexWhere((entry) => entry.route.id == route.id);
    final terminal = currentIndex >= 0 && currentIndex == entries.length - 1;

    final currentEntry =
        currentIndex >= 0 ? entries[currentIndex] : null;
    final summary = _summary(
      route: route,
      progress: afterProgress,
      rewardGrantedNow: transition.rewardGranted,
      nextUnlockedRoute: nextUnlockedRoute,
      currentEntry: currentEntry,
      terminal: terminal,
    );

    final kind = _destinationKind(
      route: route,
      completedAbsoluteLevel: absoluteLevel,
      explicitV2: explicitV2,
      segmentCompletedNow: segmentCompletedNow,
      isTrueRouteFinal: isTrueRouteFinal,
      afterRouteComplete: transition.afterRouteComplete,
      routeCompletedNow: transition.routeCompletedNow,
      nextUnlockedRoute: nextUnlockedRoute,
      terminal: terminal,
    );

    return WordHuntCompletionDestination(
      kind: kind,
      completedAbsoluteLevel: absoluteLevel,
      completedSegment: completedSegment,
      localLevel: localLevel,
      levelCompletedNow: levelCompletedNow,
      segmentCompletedNow: segmentCompletedNow,
      isMajorMidpoint: isMajorMidpoint,
      isTrueRouteFinal: isTrueRouteFinal,
      canonicalNextPlayableLevel: canonicalNextPlayableLevel,
      nextPlayableSegment: nextPlayableSegment,
      routeCompletedNow: transition.routeCompletedNow,
      rewardGrantedNow: transition.rewardGranted,
      summary: summary,
    );
  }

  static WordHuntCompletionDestinationKind _destinationKind({
    required WordHuntRouteDefinition route,
    required int completedAbsoluteLevel,
    required bool explicitV2,
    required bool segmentCompletedNow,
    required bool isTrueRouteFinal,
    required bool afterRouteComplete,
    required bool routeCompletedNow,
    required WordHuntRouteCatalogEntry? nextUnlockedRoute,
    required bool terminal,
  }) {
    if (explicitV2 && isTrueRouteFinal && afterRouteComplete) {
      if (nextUnlockedRoute != null) {
        return WordHuntCompletionDestinationKind.nextRoute;
      }
      return terminal
          ? WordHuntCompletionDestinationKind.terminalRouteComplete
          : WordHuntCompletionDestinationKind.returnToRoute;
    }

    if (!explicitV2 &&
        afterRouteComplete &&
        (routeCompletedNow ||
            completedAbsoluteLevel == route.levels.length)) {
      if (nextUnlockedRoute != null) {
        return WordHuntCompletionDestinationKind.nextRoute;
      }
      return terminal
          ? WordHuntCompletionDestinationKind.terminalRouteComplete
          : WordHuntCompletionDestinationKind.returnToRoute;
    }

    if (segmentCompletedNow && !isTrueRouteFinal) {
      return WordHuntCompletionDestinationKind.nextSegment;
    }

    return WordHuntCompletionDestinationKind.nextLevel;
  }

  static WordHuntRouteCompletionSummary _summary({
    required WordHuntRouteDefinition route,
    required WordHuntProgressSnapshot progress,
    required bool rewardGrantedNow,
    required WordHuntRouteCatalogEntry? nextUnlockedRoute,
    required WordHuntRouteCatalogEntry? currentEntry,
    required bool terminal,
  }) {
    var knownBonusFoundTotal = 0;
    var maximumBonusTotal = 0;
    var hasUnknownBonusHistory = false;

    for (final level in route.levels) {
      maximumBonusTotal += level.bonusWords.length;
      final known = progress.bestBonusFoundCountByLevelId[level.id];
      if (known != null) {
        knownBonusFoundTotal += known;
      } else if (level.bonusWords.isNotEmpty &&
          WordHuntRouteProgressEngine.isLevelCompleted(level, progress)) {
        hasUnknownBonusHistory = true;
      }
    }

    final entry =
        currentEntry ?? WordHuntRouteCatalog.entryForRouteId(route.id);
    return WordHuntRouteCompletionSummary(
      routeId: route.id,
      routeTitle: route.title,
      totalStars: WordHuntRouteProgressEngine.totalStars(route, progress),
      maximumStars: route.maximumStars,
      knownBonusFoundTotal: knownBonusFoundTotal,
      maximumBonusTotal: maximumBonusTotal,
      hasUnknownBonusHistory: hasUnknownBonusHistory,
      reward: WordHuntRouteRewardCatalog.forRoute(route),
      rewardGrantedNow: rewardGrantedNow,
      nextUnlockedRoute: nextUnlockedRoute,
      presentationProfile:
          entry?.presentationProfile ?? WordHuntRoutePresentationProfiles.starter,
      terminal: terminal,
    );
  }

  static WordHuntRouteCatalogEntry? _nextCatalogEntry(
    WordHuntRouteDefinition route,
    List<WordHuntRouteCatalogEntry> entries,
  ) {
    final index = entries.indexWhere((entry) => entry.route.id == route.id);
    if (index < 0 || index + 1 >= entries.length) return null;
    return entries[index + 1];
  }

  static int _segmentForLevel(
    WordHuntRouteDefinition route,
    int absoluteLevelIndex,
  ) {
    if (route.segments.isEmpty || absoluteLevelIndex <= 0) return 1;
    final bounded = absoluteLevelIndex.clamp(1, route.levels.length);
    return WordHuntSegmentProjection.forLevel(route, bounded).segmentIndex;
  }
}

abstract final class WordHuntCompletionOrchestrator {
  static Future<WordHuntCompletionProcessResult> process({
    required WordHuntRouteDefinition route,
    required WordHuntProgressSnapshot beforeProgress,
    required String levelId,
    required int stars,
    required Iterable<String> unlockedInfoCards,
    required int? foundBonusCount,
    required void Function(WordHuntProgressSnapshot progress) onProgressReady,
    required Future<void> Function(WordHuntProgressSnapshot progress)
        persistProgress,
    List<WordHuntRouteCatalogEntry>? catalogEntries,
  }) async {
    final transition = WordHuntRouteRewardEngine.recordLevelResult(
      route: route,
      progress: beforeProgress,
      levelId: levelId,
      stars: stars,
      unlockedInfoCards: unlockedInfoCards,
      foundBonusCount: foundBonusCount,
    );

    onProgressReady(transition.progress);
    await persistProgress(transition.progress);

    final destination = WordHuntCompletionCoordinator.resolve(
      route: route,
      completedLevelId: levelId,
      beforeProgress: beforeProgress,
      afterProgress: transition.progress,
      transition: transition,
      catalogEntries: catalogEntries,
    );

    return WordHuntCompletionProcessResult(
      transition: transition,
      destination: destination,
    );
  }
}
