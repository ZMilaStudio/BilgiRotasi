import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_segment_projection.dart';

/// Canonical route/progress state'ini renderer'ın tükettiği tek 10-node segment
/// projection'ına çevirir. Segment seçimi persisted progression değildir.
class WordHuntRouteSegmentHost {
  WordHuntRouteSegmentHost._({
    required this.route,
    required this.segmentIndex,
    required this.nodes,
    required this.isLegacySegmentOne,
  });

  final WordHuntRouteDefinition route;
  final int segmentIndex;
  final List<WordHuntRouteMapNodeProjection> nodes;
  final bool isLegacySegmentOne;

  static WordHuntRouteSegmentHost forRoute({
    required WordHuntRouteDefinition route,
    required WordHuntProgressSnapshot progress,
    int segmentIndex = 1,
  }) {
    if (route.segments.isEmpty) {
      if (segmentIndex != 1) {
        throw RangeError.range(segmentIndex, 1, 1, 'segmentIndex');
      }
      if (route.levels.isEmpty || route.levels.length > 10) {
        throw StateError(
          'Legacy Kelime Avı route segment host 1..10 level bekler.',
        );
      }
      final currentAbsoluteIndex =
          WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress);
      return WordHuntRouteSegmentHost._(
        route: route,
        segmentIndex: 1,
        isLegacySegmentOne: true,
        nodes: List<WordHuntRouteMapNodeProjection>.generate(
          route.levels.length,
          (zeroIndex) {
          final absoluteIndex = zeroIndex + 1;
          final level = route.levels[zeroIndex];
          final completed = WordHuntRouteProgressEngine.isLevelCompleted(
            level,
            progress,
          );
          final unlocked = WordHuntRouteProgressEngine.isLevelUnlocked(
            route,
            progress,
            absoluteIndex,
          );
          return WordHuntRouteMapNodeProjection(
            localNodeIndex: absoluteIndex,
            absoluteLevelIndex: absoluteIndex,
            level: level,
            unlocked: unlocked,
            completed: completed,
            current:
                unlocked &&
                !completed &&
                currentAbsoluteIndex == absoluteIndex,
            isSegmentEndpoint: absoluteIndex == route.levels.length,
            isMajorMidpoint: false,
            isTrueRouteFinal:
                absoluteIndex == route.levels.length &&
                level.type == WordHuntLevelType.routeFinal,
          );
        },
          growable: false,
        ),
      );
    }

    if (segmentIndex < 1 || segmentIndex > route.segments.length) {
      throw RangeError.range(
        segmentIndex,
        1,
        route.segments.length,
        'segmentIndex',
      );
    }

    final segment = route.segments[segmentIndex - 1];
    if (segment.levelCount != 10) {
      throw StateError(
        'Kelime Avı renderer segment host exactly 10 node bekler.',
      );
    }

    final currentAbsoluteIndex =
        WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress);
    final nodes = <WordHuntRouteMapNodeProjection>[];
    for (
      var absoluteIndex = segment.startLevelIndex;
      absoluteIndex <= segment.endLevelIndex;
      absoluteIndex++
    ) {
      final projection = WordHuntSegmentProjection.forLevel(
        route,
        absoluteIndex,
      );
      final level = projection.level;
      final completed = WordHuntRouteProgressEngine.isLevelCompleted(
        level,
        progress,
      );
      final unlocked = WordHuntRouteProgressEngine.isLevelUnlocked(
        route,
        progress,
        absoluteIndex,
      );
      nodes.add(
        WordHuntRouteMapNodeProjection(
          localNodeIndex: projection.localLevelIndex,
          absoluteLevelIndex: projection.absoluteLevelIndex,
          level: level,
          unlocked: unlocked,
          completed: completed,
          current:
              unlocked &&
              !completed &&
              currentAbsoluteIndex == projection.absoluteLevelIndex,
          isSegmentEndpoint: projection.isSegmentEnd,
          isMajorMidpoint: projection.isMajorMidpoint,
          isTrueRouteFinal: projection.isTrueRouteFinal,
        ),
      );
    }

    return WordHuntRouteSegmentHost._(
      route: route,
      segmentIndex: segmentIndex,
      nodes: List<WordHuntRouteMapNodeProjection>.unmodifiable(nodes),
      isLegacySegmentOne: false,
    );
  }
}

class WordHuntRouteMapNodeProjection {
  const WordHuntRouteMapNodeProjection({
    required this.localNodeIndex,
    required this.absoluteLevelIndex,
    required this.level,
    required this.unlocked,
    required this.completed,
    required this.current,
    required this.isSegmentEndpoint,
    required this.isMajorMidpoint,
    required this.isTrueRouteFinal,
  });

  final int localNodeIndex;
  final int absoluteLevelIndex;
  final WordHuntLevelDefinition level;
  final bool unlocked;
  final bool completed;
  final bool current;
  final bool isSegmentEndpoint;
  final bool isMajorMidpoint;
  final bool isTrueRouteFinal;

  String get levelId => level.id;
  String get displayName => level.displayNameOrFallback;
  WordHuntLevelType get gameplayType => level.type;
}
