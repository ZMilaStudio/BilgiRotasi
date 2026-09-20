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
    required bool explicitV2Route,
  }) : _explicitV2Route = explicitV2Route;

  final int absoluteLevelIndex;
  final int segmentIndex;
  final int localLevelIndex;
  final int segmentStartLevelIndex;
  final int segmentEndLevelIndex;
  final WordHuntSegmentDefinition segment;
  final WordHuntLevelDefinition level;
  final bool isSegmentStart;
  final bool isSegmentEnd;
  final bool _explicitV2Route;

  bool get isSegmentMilestone => isSegmentEnd;

  bool get isMajorMidpoint => _explicitV2Route && absoluteLevelIndex == 50;

  bool get isTrueRouteFinal => _explicitV2Route && absoluteLevelIndex == 100;

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
    if (route.segments.isEmpty) {
      throw StateError('Rota explicit segment metadata taşımıyor.');
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
      explicitV2Route: isExplicitV2Route(route),
    );
  }

  static bool isExplicitV2Route(WordHuntRouteDefinition route) {
    if (route.levels.length != 100 || route.segments.length != 10) {
      return false;
    }

    for (var offset = 0; offset < route.segments.length; offset++) {
      final segment = route.segments[offset];
      final expectedStart = offset * 10 + 1;
      if (segment.index != offset + 1 ||
          segment.startLevelIndex != expectedStart ||
          segment.endLevelIndex != expectedStart + 9) {
        return false;
      }
    }

    return true;
  }
}
