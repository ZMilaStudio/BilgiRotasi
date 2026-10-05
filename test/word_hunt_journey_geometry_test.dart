import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_geometry.dart';

void main() {
  const geometry = WordHuntJourneyGeometry();

  test('stable IDs are not chunk, theme or publication identity', () {
    expect(WordHuntJourneyGeometry.stableIdForOrdinal(1), 'level_000001');
    expect(WordHuntJourneyGeometry.stableIdForOrdinal(15000), 'level_015000');
    expect(
      () => WordHuntJourneyGeometry.stableIdForOrdinal(0),
      throwsRangeError,
    );
    for (final count in [150, 1500, 15000]) {
      expect(geometry.offsetForOrdinal(-3, count, 800), 0);
      expect(
        geometry.offsetForOrdinal(count + 1, count, 800),
        geometry.offsetForOrdinal(count, count, 800),
      );
    }
  });

  test('every seam has one incoming and outgoing half of the same cubic', () {
    for (var boundary = 20; boundary < 15000; boundary += 20) {
      final chunk = boundary ~/ 20 - 1;
      final outgoing = geometry.curvesForChunk(chunk, 15000, 360).last;
      final incoming = geometry.curvesForChunk(chunk + 1, 15000, 360).first;
      expect(outgoing.end, incoming.start + const Offset(0, 2240));
      expect(outgoing.end.dy, 2240);
      expect(incoming.start.dy, 0);
      final leftTangent = outgoing.end - outgoing.control2;
      final rightTangent = incoming.control1 - incoming.start;
      expect(leftTangent.dx, closeTo(rightTangent.dx, 1e-9));
      expect(leftTangent.dy, closeTo(rightTangent.dy, 1e-9));
      expect(
        geometry.curvesForChunk(chunk, 15000, 360).length,
        chunk == 0 ? 20 : 21,
      );
    }
    expect(geometry.curvesForChunk(749, 15000, 360).length, 20);
    expect(geometry.curvesForChunk(1, 21, 360).length, 1);
    expect(geometry.curvesForChunk(0, 1, 360), isEmpty);
  });

  test('15k ordinals map deterministically to 20-level chunks', () {
    expect(geometry.chunkIndexForOrdinal(1), 0);
    expect(geometry.chunkIndexForOrdinal(20), 0);
    expect(geometry.chunkIndexForOrdinal(21), 1);
    expect(geometry.chunkIndexForOrdinal(15000), 749);
    expect(geometry.localIndexForOrdinal(15000), 19);

    final first = geometry.globalCenterForOrdinal(12345, 360);
    final second = geometry.globalCenterForOrdinal(12345, 360);
    expect(second, first);
  });

  for (final width in <double>[360, 412, 768]) {
    test('all 15k hitboxes including seam pairs stay bounded at $width', () {
      for (var n = 1; n <= 15000; n++) {
        final rect = geometry.globalHitRect(n, width);
        expect(rect.width, closeTo(68, 1e-9));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(width));
        expect((rect.center.dx - width / 2).abs(), lessThanOrEqualTo(146));
        if (n < 15000)
          expect(geometry.hitRectsOverlap(n, n + 1, width), isFalse);
        expect(
          geometry.globalCenterForOrdinal(n, width),
          geometry.globalCenterForOrdinal(n, width),
        );
      }
      // Increasing published count is not an input to node placement.
      expect(
        geometry.globalCenterForOrdinal(20, width),
        const WordHuntJourneyGeometry().globalCenterForOrdinal(20, width),
      );
    });
    test('no 68dp hitbox overlap in representative chunks at width $width', () {
      for (final start in <int>[1, 981, 14981]) {
        final end = start + 19;
        for (var a = start; a <= end; a++) {
          for (var b = a + 1; b <= end; b++) {
            expect(
              geometry.hitRectsOverlap(a, b, width),
              isFalse,
              reason: 'overlap at $a/$b for width $width',
            );
          }
        }
      }
    });

    test('lane remains bounded at width $width', () {
      for (var ordinal = 1; ordinal <= 15000; ordinal += 997) {
        final center = geometry.globalCenterForOrdinal(ordinal, width);
        expect(center.dx, greaterThanOrEqualTo(geometry.nodeHitSize / 2));
        expect(center.dx, lessThanOrEqualTo(width - geometry.nodeHitSize / 2));
      }
    });
  }
}
