import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_domain/word_hunt_journey_progress.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_map_state_adapter.dart';

void main() {
  test(
    'snapshot stars, current and metadata are independent; unpublished throws',
    () {
      final catalog = PublishedJourneyCatalog(
        levelCount: 15000,
        publishedLevelCount: 5,
        metadata: const {
          4: JourneyLevelMetadata(challenge: true, milestone: true),
          5: JourneyLevelMetadata(challenge: true),
        },
      );
      final p = WordHuntJourneyProgress(
        catalog: catalog,
        save: WordHuntJourneySaveV1(
          bestStarsByStableId: {
            journeyStableId(1): 1,
            journeyStableId(2): 2,
            journeyStableId(3): 3,
          },
          lastViewedLevelId: journeyStableId(2),
        ),
      );
      final adapter = JourneyMapStateAdapter(p);
      expect(adapter.publishedLevelCount, 5);
      expect(adapter.currentOrdinal, 4);
      expect(adapter.initialOrdinal(preferLastViewed: true), 2);
      expect(adapter.initialOrdinal(), 4);
      for (var n = 1; n <= 3; n++) {
        expect(
          adapter.presentationForOrdinal(n).state,
          WordHuntJourneyNodeState.values[n + 1],
        );
        expect(adapter.presentationForOrdinal(n).stars, n);
        expect(adapter.canJumpToOrdinal(n), isTrue);
      }
      expect(
        adapter.presentationForOrdinal(4).state,
        WordHuntJourneyNodeState.current,
      );
      expect(adapter.presentationForOrdinal(4).challenge, isTrue);
      expect(adapter.presentationForOrdinal(4).milestone, isTrue);
      expect(
        adapter.presentationForOrdinal(5).state,
        WordHuntJourneyNodeState.locked,
      );
      expect(adapter.presentationForOrdinal(5).challenge, isTrue);
      expect(adapter.canJumpToOrdinal(5), isFalse);
      expect(() => adapter.presentationForOrdinal(6), throwsStateError);
      final before = p.snapshot;
      final controller = WordHuntJourneyMapController();
      expect(adapter.jumpToOrdinal(controller, 5), isFalse);
      expect(adapter.jumpToOrdinal(controller, 6), isFalse);
      expect(adapter.jumpToOrdinal(controller, 3), isTrue);
      expect(p.snapshot, same(before));
      p.recordCompletion(journeyStableId(4), stars: 2, bonusFound: 1);
      expect(adapter.presentationForOrdinal(4).stars, 2);
      expect(adapter.presentationForOrdinal(4).challenge, isTrue);
      expect(adapter.currentOrdinal, 5);
    },
  );
  testWidgets(
    'adapter wires published map and eligible direct jump without save mutation',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final p = WordHuntJourneyProgress(
        catalog: PublishedJourneyCatalog(
          levelCount: 15000,
          publishedLevelCount: 500,
        ),
        save: WordHuntJourneySaveV1(
          bestStarsByStableId: {
            for (var n = 1; n < 500; n++) journeyStableId(n): 3,
          },
        ),
      );
      final adapter = JourneyMapStateAdapter(p);
      final controller = WordHuntJourneyMapController();
      final before = p.snapshot;
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntInfiniteJourneyMapScreen(
            publishedLevelCount: adapter.publishedLevelCount,
            initialOrdinal: adapter.initialOrdinal()!,
            currentOrdinal: adapter.currentOrdinal!,
            stateForOrdinal: adapter.presentationForOrdinal,
            controller: controller,
            onLevelTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('word_hunt_journey_level_500')),
        findsOneWidget,
      );
      expect(adapter.jumpToOrdinal(controller, 501), isFalse);
      expect(
        find.byKey(const Key('word_hunt_journey_level_501')),
        findsNothing,
      );
      expect(adapter.jumpToOrdinal(controller, 1), isTrue);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('word_hunt_journey_level_1')),
        findsOneWidget,
      );
      expect(p.snapshot, same(before));
      expect(tester.takeException(), isNull);
    },
  );
}
