import 'dart:math' as math;
import 'dart:ui';

class WordHuntJourneyGeometry {
  const WordHuntJourneyGeometry({
    this.levelsPerChunk = 20,
    this.rowPitch = 112,
    this.nodeHitSize = 68,
    this.maxLaneWidth = 360,
    this.horizontalPadding = 34,
    this.phaseStep = 0.78,
  });

  final int levelsPerChunk;
  final double rowPitch;
  final double nodeHitSize;
  final double maxLaneWidth;
  final double horizontalPadding;
  final double phaseStep;

  double get chunkExtent => levelsPerChunk * rowPitch;

  int chunkIndexForOrdinal(int ordinal) {
    assert(ordinal >= 1);
    return (ordinal - 1) ~/ levelsPerChunk;
  }

  int localIndexForOrdinal(int ordinal) {
    assert(ordinal >= 1);
    return (ordinal - 1) % levelsPerChunk;
  }

  Offset globalCenterForOrdinal(int ordinal, double viewportWidth) {
    assert(ordinal >= 1);
    final laneWidth = math.min(
      maxLaneWidth,
      math.max(nodeHitSize, viewportWidth - (horizontalPadding * 2)),
    );
    final amplitude = math.max(0, (laneWidth - nodeHitSize) / 2);
    final centerX = viewportWidth / 2;
    final phase = (ordinal - 1) * phaseStep;
    final x = centerX + math.sin(phase) * amplitude;
    final y = (rowPitch / 2) + ((ordinal - 1) * rowPitch);
    return Offset(x, y);
  }

  Offset localCenterForOrdinal(int ordinal, double viewportWidth) {
    final global = globalCenterForOrdinal(ordinal, viewportWidth);
    final chunk = chunkIndexForOrdinal(ordinal);
    return Offset(global.dx, global.dy - (chunk * chunkExtent));
  }

  Rect hitRectForOrdinal(int ordinal, double viewportWidth) {
    final center = localCenterForOrdinal(ordinal, viewportWidth);
    return Rect.fromCenter(
      center: center,
      width: nodeHitSize,
      height: nodeHitSize,
    );
  }

  bool hitRectsOverlap(int a, int b, double viewportWidth) {
    if (a == b) return true;
    final aChunk = chunkIndexForOrdinal(a);
    final bChunk = chunkIndexForOrdinal(b);
    if (aChunk != bChunk) return false;
    return hitRectForOrdinal(a, viewportWidth)
        .overlaps(hitRectForOrdinal(b, viewportWidth));
  }
}
