import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_map_decoration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const progressThroughSeven = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'baslangic-1': 3,
      'baslangic-2': 3,
      'baslangic-3': 3,
      'baslangic-4': 3,
      'baslangic-5': 3,
      'baslangic-6': 3,
      'baslangic-7': 3,
    },
  );

  const decoration = WordHuntRouteDecorationSpec(
    kind: WordHuntRouteDecorationKind.forest,
    seed: 20260912,
    count: 18,
  );

  const palette = WordHuntRouteDecorationPalette(
    primary: Color(0xFF4F8D62),
    secondary: Color(0xFF72533A),
    accent: Color(0xFFF3D47A),
  );

  testWidgets('decoration is painted below path and node layers', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntReusableRouteMapScreen(
          route: WordHuntStarterContent.baslangicLimani,
          theme: WordHuntRouteMapTheme.forestProof,
          progress: progressThroughSeven,
          decorationSpec: decoration,
          decorationPalette: palette,
        ),
      ),
    );
    await tester.pump();

    final stack = tester.widget<Stack>(
      find.byKey(const Key('word_hunt_reusable_layer_stack')),
    );

    expect(stack.children, hasLength(12));
    expect(
      stack.children[0].key,
      const Key('word_hunt_reusable_decoration_layer'),
    );
    expect(
      stack.children[1].key,
      const Key('word_hunt_reusable_path_layer'),
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_route_decoration')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_route_path')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_level_8')),
      findsOneWidget,
    );
  });

  testWidgets('decoration never blocks an unlocked node tap', (tester) async {
    var tapped = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntReusableRouteMapScreen(
          route: WordHuntStarterContent.baslangicLimani,
          theme: WordHuntRouteMapTheme.forestProof,
          progress: progressThroughSeven,
          decorationSpec: decoration,
          decorationPalette: palette,
          onLevelTap: (index) => tapped = index,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('word_hunt_reusable_level_8')));
    await tester.pump();

    expect(tapped, 8);
  });
}
