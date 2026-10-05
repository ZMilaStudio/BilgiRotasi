import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_geometry.dart';

void main() {
  const geometry = WordHuntJourneyGeometry();

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
