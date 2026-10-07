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
  }) : assert(levelsPerChunk > 0),
       assert(rowPitch >= nodeHitSize),
       assert(nodeHitSize > 0),
       assert(maxLaneWidth >= nodeHitSize),
       assert(horizontalPadding >= 0);

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
    return globalHitRect(
      a,
      viewportWidth,
    ).overlaps(globalHitRect(b, viewportWidth));
  }

  Rect globalHitRect(int ordinal, double width) => Rect.fromCenter(
    center: globalCenterForOrdinal(ordinal, width),
    width: nodeHitSize,
    height: nodeHitSize,
  );

  static String stableIdForOrdinal(int ordinal) {
    if (ordinal < 1) throw RangeError.range(ordinal, 1, null, 'ordinal');
    return 'level_${ordinal.toString().padLeft(6, '0')}';
  }

  double offsetForOrdinal(int ordinal, int count, double viewportHeight) {
    final bounded = ordinal.clamp(1, count);
    final extent =
        ((count + levelsPerChunk - 1) ~/ levelsPerChunk) * chunkExtent;
    return (rowPitch / 2 + (bounded - 1) * rowPitch - viewportHeight * .35)
        .clamp(0.0, math.max(0.0, extent - viewportHeight))
        .toDouble();
  }

  /// A seam edge is split at t=.5, exactly at the chunk boundary. Each half
  /// belongs to one tile; no full-map path or duplicated cross-seam stroke.
  List<WordHuntJourneyCurve> curvesForChunk(
    int chunk,
    int count,
    double width,
  ) {
    final first = chunk * levelsPerChunk + 1;
    final last = math.min(count, first + levelsPerChunk - 1);
    final origin = Offset(0, chunk * chunkExtent);
    final curves = <WordHuntJourneyCurve>[];
    if (first > 1)
      curves.add(curveForEdge(first - 1, width).halves.$2.shift(-origin));
    for (var ordinal = first; ordinal < last; ordinal++) {
      curves.add(curveForEdge(ordinal, width).shift(-origin));
    }
    if (last < count)
      curves.add(curveForEdge(last, width).halves.$1.shift(-origin));
    return curves;
  }

  WordHuntJourneyCurve curveForEdge(int ordinal, double width) {
    final a = globalCenterForOrdinal(ordinal, width);
    final b = globalCenterForOrdinal(ordinal + 1, width);
    final midY = (a.dy + b.dy) / 2;
    return WordHuntJourneyCurve(a, Offset(a.dx, midY), Offset(b.dx, midY), b);
  }
}

class WordHuntJourneyCurve {
  const WordHuntJourneyCurve(
    this.start,
    this.control1,
    this.control2,
    this.end,
  );
  final Offset start, control1, control2, end;
  WordHuntJourneyCurve shift(Offset delta) => WordHuntJourneyCurve(
    start + delta,
    control1 + delta,
    control2 + delta,
    end + delta,
  );
  (WordHuntJourneyCurve, WordHuntJourneyCurve) get halves {
    final a = (start + control1) / 2;
    final b = (control1 + control2) / 2;
    final c = (control2 + end) / 2;
    final d = (a + b) / 2;
    final e = (b + c) / 2;
    final middle = (d + e) / 2;
    return (
      WordHuntJourneyCurve(start, a, d, middle),
      WordHuntJourneyCurve(middle, e, c, end),
    );
  }
}
