import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = WordHuntKristalContent.kristalVadisi;
  final theme = WordHuntKristalVisualTheme.production.mapTheme;
  final visualTheme = WordHuntKristalVisualTheme.production;
  final rendererSource =
      File(
        'packages/word_hunt_flutter_feature/lib/word_hunt_reusable_route_map_screen.dart',
      ).readAsStringSync();
  final themedSource =
      File(
        'packages/word_hunt_flutter_feature/lib/word_hunt_themed_production_route_screen.dart',
      ).readAsStringSync();

  test('facetedCrystal is generic theme data and owner hierarchy is exact', () {
    expect(theme.nodeVisualStyle, WordHuntRouteNodeVisualStyle.facetedCrystal);
    expect(WordHuntFacetedCrystalMetrics.normalScale, 1.00);
    expect(WordHuntFacetedCrystalMetrics.challengeScale, 1.06);
    expect(WordHuntFacetedCrystalMetrics.finalScale, 1.11);
    expect(WordHuntFacetedCrystalMetrics.normalBodyWidth, 48);
    expect(WordHuntFacetedCrystalMetrics.normalBodyHeight, 46);
    expect(WordHuntFacetedCrystalMetrics.normalShardSilhouette, 58);
    expect(WordHuntFacetedCrystalMetrics.finalBodyWidth, 52);
    expect(WordHuntFacetedCrystalMetrics.finalBodyHeight, 50);
    expect(WordHuntFacetedCrystalMetrics.finalCrestWidth, 52);
    expect(WordHuntFacetedCrystalMetrics.finalCrestHeight, 32);
    expect(
      WordHuntFacetedCrystalMetrics.finalScale,
      greaterThan(WordHuntFacetedCrystalMetrics.challengeScale),
    );
    expect(
      WordHuntFacetedCrystalMetrics.challengeScale,
      greaterThan(WordHuntFacetedCrystalMetrics.normalScale),
    );
    expect(rendererSource, isNot(contains("route.id == 'kristal-vadisi'")));
    expect(rendererSource, isNot(contains('route.id == "kristal-vadisi"')));
  });

  test('canonical geometry and hitbox contract remain exact', () {
    expect(WordHuntRouteMapGeometry.normalizedStops, const <Offset>[
      Offset(.18, .10),
      Offset(.48, .17),
      Offset(.75, .27),
      Offset(.66, .38),
      Offset(.28, .47),
      Offset(.18, .60),
      Offset(.48, .67),
      Offset(.78, .74),
      Offset(.32, .82),
      Offset(.60, .91),
    ]);
    expect(rendererSource, contains('static const double _nodeDiameter = 54;'));
    expect(rendererSource, contains('static const double _nodeBoxWidth = 86;'));
    expect(
      rendererSource,
      contains('static const double _nodeBoxHeight = 82;'),
    );
  });

  testWidgets(
    'completed L1-L4, current L5 and locked crystal seals use premium medallion structure',
    (tester) async {
      final progress = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          for (final level in route.levels.take(4)) level.id: 3,
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntThemedRouteMapScreen(
            route: route,
            visualTheme: visualTheme,
            progress: progress,
          ),
        ),
      );
      await tester.pump();

      for (var i = 1; i <= 4; i++) {
        expect(
          find.byKey(Key('word_hunt_reusable_node_${i}_completed')),
          findsOneWidget,
        );
        expect(
          find.byKey(Key('word_hunt_faceted_medallion_$i')),
          findsOneWidget,
        );
        expect(find.byKey(Key('word_hunt_faceted_stars_$i')), findsOneWidget);
      }
      expect(
        find.byKey(const Key('word_hunt_reusable_node_5_current')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_medallion_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_challenge_glow')),
        findsOneWidget,
      );

      for (var i = 6; i <= 9; i++) {
        expect(
          find.byKey(Key('word_hunt_reusable_node_${i}_locked')),
          findsOneWidget,
        );
        expect(
          find.byKey(Key('word_hunt_faceted_medallion_$i')),
          findsOneWidget,
        );
        expect(find.byKey(Key('word_hunt_faceted_lock_$i')), findsOneWidget);
      }

      expect(
        find.byKey(const Key('word_hunt_reusable_node_10_locked')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_medallion_10')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_final_crest')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_final_crest_state_locked')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_lock_10')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.emoji_events), findsNothing);
      expect(find.byIcon(Icons.workspace_premium), findsNothing);
    },
  );

  testWidgets(
    'unlocked current L10 keeps unique active crystal-throne treatment',
    (tester) async {
      final progress = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          for (final level in route.levels.take(9)) level.id: 1,
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntThemedRouteMapScreen(
            route: route,
            visualTheme: visualTheme,
            progress: progress,
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('word_hunt_reusable_node_10_current')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_medallion_10')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_final_active_glow')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_final_crest')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_faceted_final_crest_state_active')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('word_hunt_faceted_lock_10')), findsNothing);
    },
  );

  testWidgets(
    'artwork-hosted reusable map keeps one live back control contract',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntReusableRouteMapScreen(
            route: route,
            theme: theme,
            hostedByArtworkChrome: true,
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('word_hunt_reusable_route_title')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    },
  );

  test('Kristal path remains generic broken stepping trail', () {
    expect(rendererSource, contains('_paintSteppingStones('));
    expect(rendererSource, contains('artworkMode ? 11.0 : 8.0'));
    expect(
      rendererSource,
      contains('artworkMode ? (emphasized ? 8.5 : 6.5) : 13'),
    );
  });

  test(
    'tall ambient tint derives from theme instead of fixed forest green',
    () {
      expect(
        themedSource,
        contains(
          'final ambientEdge = theme.backgroundColor.withValues(alpha: 0.34);',
        ),
      );
      expect(
        themedSource,
        contains('<Color>[ambientEdge, ambientMid, ambientClear]'),
      );
      expect(themedSource, isNot(contains('Color(0x24030B07)')));
    },
  );
}
