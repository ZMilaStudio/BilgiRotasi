import 'word_hunt_models.dart';

class WordHuntSegmentProjection {
  const WordHuntSegmentProjection._({
    required this.absoluteLevelIndex,
    required this.segmentIndex,
    required this.localLevelIndex,
    required this.segmentStartLevelIndex,
    required this.segmentEndLevelIndex,
    required this.segment,
    required this.level,
    required this.isSegmentStart,
    required this.isSegmentEnd,
    required bool segmentedRoute,
    required bool completeV2Route,
  }) : _segmentedRoute = segmentedRoute,
       _completeV2Route = completeV2Route;

  final int absoluteLevelIndex;
  final int segmentIndex;
  final int localLevelIndex;
  final int segmentStartLevelIndex;
  final int segmentEndLevelIndex;
  final WordHuntSegmentDefinition segment;
  final WordHuntLevelDefinition level;
  final bool isSegmentStart;
  final bool isSegmentEnd;
  final bool _segmentedRoute;
  final bool _completeV2Route;

  bool get isSegmentMilestone => isSegmentEnd;

  bool get isMajorMidpoint => _segmentedRoute && absoluteLevelIndex == 50;

  bool get isTrueRouteFinal => _completeV2Route && absoluteLevelIndex == 100;

  static WordHuntSegmentProjection forLevel(
    WordHuntRouteDefinition route,
    int absoluteLevelIndex,
  ) {
    if (absoluteLevelIndex < 1 || absoluteLevelIndex > route.levels.length) {
      throw RangeError.range(
        absoluteLevelIndex,
        1,
        route.levels.length,
        'absoluteLevelIndex',
      );
    }
    if (!isSegmentedRoute(route)) {
      throw StateError(
        'Rota geçerli 10-node explicit segment metadata taşımıyor.',
      );
    }

    WordHuntSegmentDefinition? match;
    for (final segment in route.segments) {
      if (absoluteLevelIndex >= segment.startLevelIndex &&
          absoluteLevelIndex <= segment.endLevelIndex) {
        match = segment;
        break;
      }
    }

    if (match == null) {
      throw StateError(
        'Bölüm $absoluteLevelIndex için segment metadata bulunamadı.',
      );
    }

    return WordHuntSegmentProjection._(
      absoluteLevelIndex: absoluteLevelIndex,
      segmentIndex: match.index,
      localLevelIndex: absoluteLevelIndex - match.startLevelIndex + 1,
      segmentStartLevelIndex: match.startLevelIndex,
      segmentEndLevelIndex: match.endLevelIndex,
      segment: match,
      level: route.levels[absoluteLevelIndex - 1],
      isSegmentStart: absoluteLevelIndex == match.startLevelIndex,
      isSegmentEnd: absoluteLevelIndex == match.endLevelIndex,
      segmentedRoute: true,
      completeV2Route: isCompleteV2Route(route),
    );
  }

  static bool isSegmentedRoute(WordHuntRouteDefinition route) {
    if (route.levels.isEmpty ||
        route.segments.isEmpty ||
        route.levels.length % 10 != 0 ||
        route.segments.length != route.levels.length ~/ 10) {
      return false;
    }

    for (var offset = 0; offset < route.segments.length; offset++) {
      final segment = route.segments[offset];
      final expectedStart = offset * 10 + 1;
      if (segment.index != offset + 1 ||
          segment.startLevelIndex != expectedStart ||
          segment.endLevelIndex != expectedStart + 9 ||
          segment.levelCount != 10) {
        return false;
      }
    }
    return true;
  }

  static bool isCompleteV2Route(WordHuntRouteDefinition route) {
    return isSegmentedRoute(route) &&
        route.levels.length == 100 &&
        route.segments.length == 10 &&
        route.plannedRouteLevelCount == 100;
  }

  /// Wave 1–9 API compatibility: "explicit V2" historically meant complete
  /// 100-level/10-segment authority.
  static bool isExplicitV2Route(WordHuntRouteDefinition route) =>
      isCompleteV2Route(route);
}
