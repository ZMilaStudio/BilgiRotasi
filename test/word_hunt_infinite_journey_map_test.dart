import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';

void main() {
  for (final viewport in <Size>[const Size(360, 800), const Size(412, 915)]) {
    testWidgets('15k map is lazy, jumpable and bounded at $viewport', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final taps = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntInfiniteJourneyMapScreen(
            publishedLevelCount: 15000,
            initialOrdinal: 14999,
            stateForOrdinal: (ordinal) {
              if (ordinal < 14999) {
                return WordHuntJourneyNodeState.completed3;
              }
              if (ordinal == 14999) {
                return WordHuntJourneyNodeState.current;
              }
              return WordHuntJourneyNodeState.locked;
            },
            onLevelTap: taps.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('word_hunt_infinite_journey_list')), findsOneWidget);
      expect(find.byKey(const Key('word_hunt_journey_level_14999')), findsOneWidget);
      expect(find.byKey(const Key('word_hunt_journey_level_15000')), findsOneWidget);
      expect(find.byKey(const Key('word_hunt_journey_level_1')), findsNothing);

      final mountedChunks = find.byWidgetPredicate(
        (widget) => widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('journey_chunk_'),
      );
      expect(mountedChunks.evaluate().length, lessThan(10));

      final current = find.byKey(const Key('word_hunt_journey_level_14999'));
      expect(tester.getSize(current), const Size(68, 68));
      final currentSemantics = tester.getSemantics(current).getSemanticsData();
      expect(currentSemantics.hasAction(ui.SemanticsAction.tap), isTrue);

      final locked = find.byKey(const Key('word_hunt_journey_level_15000'));
      final lockedSemantics = tester.getSemantics(locked).getSemanticsData();
      expect(lockedSemantics.hasAction(ui.SemanticsAction.tap), isFalse);

      await tester.tap(current);
      expect(taps, [14999]);
      taps.clear();
      await tester.tap(locked);
      expect(taps, isEmpty);

      expect(tester.takeException(), isNull);
    });
  }
}
