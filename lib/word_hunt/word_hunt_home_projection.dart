import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_catalog.dart';
import 'word_hunt_segment_projection.dart';

class WordHuntContinueDestination {
  const WordHuntContinueDestination({
    required this.route,
    required this.routeTitle,
    required this.level,
    required this.absoluteLevelIndex,
    required this.localLevelIndex,
    required this.activeSegmentIndex,
  });

  final WordHuntRouteDefinition route;
  final String routeTitle;
  final WordHuntLevelDefinition level;
  final int absoluteLevelIndex;
  final int localLevelIndex;
  final int activeSegmentIndex;

  String get levelId => level.id;
  String get displayName => level.displayNameOrFallback;
}

class WordHuntRouteHomeSummary {
  const WordHuntRouteHomeSummary({
    required this.route,
    required this.completedLevelCount,
    required this.totalLevelCount,
    required this.totalStars,
    required this.activeSegmentIndex,
    required this.totalSegmentCount,
    required this.unlocked,
    required this.complete,
  });

  final WordHuntRouteDefinition route;
  final int completedLevelCount;
  final int totalLevelCount;
  final int totalStars;
  final int activeSegmentIndex;
  final int totalSegmentCount;
  final bool unlocked;
  final bool complete;

  String get routeId => route.id;
  String get routeTitle => route.title;
}

class WordHuntHomeProjection {
  const WordHuntHomeProjection({
    required this.continueDestination,
    required this.totalCompletedLevels,
    required this.totalLevelCount,
    required this.totalStars,
    required this.unlockedInfoCardCount,
    required this.completedRouteCount,
    required this.knownBonusFoundTotal,
    required this.hasUnknownBonusHistory,
    required this.routeSummaries,
  });

  final WordHuntContinueDestination continueDestination;
  final int totalCompletedLevels;
  final int totalLevelCount;
  final int totalStars;
  final int unlockedInfoCardCount;
  final int completedRouteCount;
  final int knownBonusFoundTotal;
  final bool hasUnknownBonusHistory;
  final List<WordHuntRouteHomeSummary> routeSummaries;

  static WordHuntHomeProjection fromProgress(
    WordHuntProgressSnapshot progress, {
    List<WordHuntRouteCatalogEntry>? catalogEntries,
  }) {
    final entries = catalogEntries ?? WordHuntRouteCatalog.entries;
    if (entries.isEmpty) {
      throw StateError('Kelime Avı home projection en az bir rota bekler.');
    }

    final continueEntry = _resolveContinueEntry(entries, progress);
    final continueIndex = WordHuntRouteProgressEngine.nextPlayableLevelIndex(
      continueEntry.route,
      progress,
    );
    if (continueIndex < 1 ||
        continueIndex > continueEntry.route.levels.length) {
      throw StateError('Kelime Avı continue destination üretilemedi.');
    }
    final continueLocation = _segmentLocation(
      continueEntry.route,
      continueIndex,
    );
    final continueDestination = WordHuntContinueDestination(
      route: continueEntry.route,
      routeTitle: continueEntry.route.title,
      level: continueEntry.route.levels[continueIndex - 1],
      absoluteLevelIndex: continueIndex,
      localLevelIndex: continueLocation.$2,
      activeSegmentIndex: continueLocation.$1,
    );

    var completedLevels = 0;
    var totalLevels = 0;
    var stars = 0;
    var completedRoutes = 0;
    var knownBonusFound = 0;
    var hasUnknownBonus = false;
    final routeSummaries = <WordHuntRouteHomeSummary>[];

    for (final entry in entries) {
      final route = entry.route;
      final unlocked = entry.isUnlocked(progress);
      final complete = WordHuntRouteProgressEngine.isRouteComplete(
        route,
        progress,
      );
      final nextIndex = WordHuntRouteProgressEngine.nextPlayableLevelIndex(
        route,
        progress,
      );
      final activeSegment = route.levels.isEmpty
          ? 1
          : _segmentLocation(route, nextIndex).$1;
      var routeCompletedLevels = 0;
      var routeStars = 0;

      totalLevels += route.levels.length;
      if (complete) {
        completedRoutes++;
      }

      for (final level in route.levels) {
        final levelCompleted = WordHuntRouteProgressEngine.isLevelCompleted(
          level,
          progress,
        );
        final levelStars = progress.starsFor(level.id);
        routeStars += levelStars;
        stars += levelStars;

        if (levelCompleted) {
          completedLevels++;
          routeCompletedLevels++;
          if (!progress.bestBonusFoundCountByLevelId.containsKey(level.id)) {
            hasUnknownBonus = true;
          }
        }

        final knownBonus = progress.bestBonusFoundCountByLevelId[level.id];
        if (knownBonus != null) {
          knownBonusFound += knownBonus;
        }
      }

      routeSummaries.add(
        WordHuntRouteHomeSummary(
          route: route,
          completedLevelCount: routeCompletedLevels,
          totalLevelCount: route.levels.length,
          totalStars: routeStars,
          activeSegmentIndex: activeSegment,
          totalSegmentCount: route.segments.isEmpty ? 1 : route.segments.length,
          unlocked: unlocked,
          complete: complete,
        ),
      );
    }

    return WordHuntHomeProjection(
      continueDestination: continueDestination,
      totalCompletedLevels: completedLevels,
      totalLevelCount: totalLevels,
      totalStars: stars,
      unlockedInfoCardCount: progress.unlockedInfoCardIds.length,
      completedRouteCount: completedRoutes,
      knownBonusFoundTotal: knownBonusFound,
      hasUnknownBonusHistory: hasUnknownBonus,
      routeSummaries: List<WordHuntRouteHomeSummary>.unmodifiable(
        routeSummaries,
      ),
    );
  }

  static WordHuntRouteCatalogEntry _resolveContinueEntry(
    List<WordHuntRouteCatalogEntry> entries,
    WordHuntProgressSnapshot progress,
  ) {
    final lastActiveRouteId = progress.lastActiveRouteId;
    if (lastActiveRouteId != null) {
      for (final entry in entries) {
        if (entry.route.id == lastActiveRouteId &&
            entry.isUnlocked(progress) &&
            !WordHuntRouteProgressEngine.isRouteComplete(
              entry.route,
              progress,
            )) {
          return entry;
        }
      }
    }

    for (final entry in entries.reversed) {
      if (entry.isUnlocked(progress) &&
          !WordHuntRouteProgressEngine.isRouteComplete(
            entry.route,
            progress,
          )) {
        return entry;
      }
    }

    for (final entry in entries.reversed) {
      if (entry.isUnlocked(progress)) {
        return entry;
      }
    }

    return entries.first;
  }

  static (int, int) _segmentLocation(
    WordHuntRouteDefinition route,
    int absoluteLevelIndex,
  ) {
    if (route.segments.isEmpty) {
      return (1, absoluteLevelIndex);
    }

    final projection = WordHuntSegmentProjection.forLevel(
      route,
      absoluteLevelIndex,
    );
    return (projection.segmentIndex, projection.localLevelIndex);
  }
}
