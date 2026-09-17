import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_runtime_proof.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_themed_production_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('proof fixture keeps exact state and generic faceted theme tokens', () {
    final route = WordHuntKristalRuntimeProof.route;
    final progress = WordHuntKristalRuntimeProof.progress;
    final theme = WordHuntKristalRuntimeProof.visualTheme;

    expect(route.levels, hasLength(10));
    for (var index = 0; index < 4; index++) {
      expect(progress.starsFor(route.levels[index].id), 3);
    }
    expect(
      WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress),
      5,
    );
    expect(
      theme.mapTheme.nodeVisualStyle,
      WordHuntRouteNodeVisualStyle.facetedCrystal,
    );
    expect(theme.mapTheme.pathColor, const Color(0xFF78E3DC));
    expect(theme.mapTheme.nodeColor, const Color(0xFF6D4BB3));
    expect(theme.mapTheme.lockedNodeColor, const Color(0xFF41475A));
    expect(theme.mapTheme.resolvedFinalAccentColor, const Color(0xFFFFD77A));
  });

  testWidgets('real themed/reusable renderer has one live header and faceted nodes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(411, 731));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntThemedProductionRouteScreen(
          route: WordHuntKristalRuntimeProof.route,
          visualTheme: WordHuntKristalRuntimeProof.visualTheme,
          progress: WordHuntKristalRuntimeProof.progress,
          onBack: () {},
          onInfo: () {},
          onCompass: () {},
          onBook: () {},
          onLevelTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word_hunt_themed_production_route')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_themed_chrome_back')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_reusable_route_title')), findsOneWidget);
    expect(find.text('Kristal Vadisi'), findsOneWidget);

    for (var level = 1; level <= 10; level++) {
      expect(find.byKey(Key('word_hunt_faceted_node_$level')), findsOneWidget);
    }
    expect(find.byKey(const Key('word_hunt_reusable_node_5_current')), findsOneWidget);
    for (var level = 6; level <= 10; level++) {
      expect(
        find.byKey(Key('word_hunt_reusable_node_${level}_locked')),
        findsOneWidget,
      );
    }
    expect(find.byKey(const Key('word_hunt_faceted_final_crown')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
