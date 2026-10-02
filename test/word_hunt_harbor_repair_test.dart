import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reference_route_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_harbor_segment_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_star_visuals.dart';

void main() {
  final route = WordHuntStarterContent.baslangicLimani;
  test('shared content and progression authority is unchanged', () {
    expect(route.availableLevelCount, 40);
    expect(route.plannedRouteLevelCount, 100);
    expect(route.levels[19].type, WordHuntLevelType.challenge);
    expect(route.levels[29].index, 30);
    expect(route.levels[29].type, WordHuntLevelType.challenge);
    expect(route.levels[29].type, isNot(WordHuntLevelType.routeFinal));
  });

  testWidgets('main Bilgi Rotası uses both approved harbor scenes', (tester) async {
    const progress = WordHuntProgressSnapshot();
    for (final segment in <int>[2, 3]) {
      await tester.pumpWidget(MaterialApp(
        home: WordHuntReferenceRouteScreen(
          route: route,
          segmentIndex: segment,
          progress: progress,
        ),
      ));
      await tester.pump();
      final image = tester.widget<Image>(
        find.byKey(Key('word_hunt_harbor_scene_asset_$segment')),
      );
      expect((image.image as AssetImage).assetName,
          WordHuntHarborSegmentArt.assetFor(segment));
      expect(find.text('ROTA FİNALİ'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  test('shared route star palette is fixed for all route families', () {
    expect(WordHuntStarVisuals.filled, const Color(0xFFFFD45B));
    expect(WordHuntStarVisuals.empty, const Color(0xFF65717D));
  });
}
