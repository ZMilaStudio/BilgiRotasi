import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('proof visual themes are unique data bundles without geometry', () {
    final themes = WordHuntRouteVisualThemeProofs.all;

    expect(themes, hasLength(3));
    expect(themes.map((theme) => theme.id).toSet(), hasLength(themes.length));

    for (final theme in themes) {
      expect(theme.id, isNotEmpty);
      expect(theme.decorationSpec.count, inInclusiveRange(0, 40));
      expect(theme.decorationOpacity, inInclusiveRange(0.0, 1.0));
    }

    // Tema paketleri node koordinatı taşımaz; canonical 1-10 geometri tek
    // kaynak olarak ortak motor üzerinde kalır.
    expect(WordHuntRouteMapGeometry.normalizedStops, hasLength(10));
  });

  test('changing visual theme never changes canonical 1-10 map points', () {
    const size = Size(390, 844);
    final canonical = WordHuntRouteMapGeometry.pointsFor(size);

    for (final theme in WordHuntRouteVisualThemeProofs.all) {
      expect(theme.mapTheme.id, isNotEmpty);
      expect(WordHuntRouteMapGeometry.pointsFor(size), canonical);
    }
  });
}
