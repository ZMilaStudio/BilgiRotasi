import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_seal_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpNode(
    WidgetTester tester, {
    required WordHuntSealVisualSpec spec,
    required WordHuntLevelType type,
    required WordHuntSealNodeState state,
    required int levelIndex,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: WordHuntSealNode(
              levelIndex: levelIndex,
              levelType: type,
              state: state,
              spec: spec,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('generic renderer accepts Ancient Mechanical and Solar specs', (
    tester,
  ) async {
    for (final spec in <WordHuntSealVisualSpec>[
      WordHuntSealVisualSpec.ancient,
      WordHuntSealVisualSpec.mechanical,
      WordHuntSealVisualSpec.solar,
    ]) {
      await pumpNode(
        tester,
        spec: spec,
        type: WordHuntLevelType.normal,
        state: WordHuntSealNodeState.current,
        levelIndex: 3,
      );
      expect(
        find.byKey(const Key('word_hunt_seal_silhouette_3_normal')),
        findsOneWidget,
        reason: spec.id,
      );
      expect(tester.takeException(), isNull, reason: spec.id);
    }
  });

  testWidgets('L5 challenge silhouette persists across all live states', (
    tester,
  ) async {
    for (final state in WordHuntSealNodeState.values) {
      await pumpNode(
        tester,
        spec: WordHuntSealVisualSpec.mechanical,
        type: WordHuntLevelType.challenge,
        state: state,
        levelIndex: 5,
      );
      expect(
        find.byKey(const Key('word_hunt_seal_silhouette_5_challenge')),
        findsOneWidget,
        reason: state.name,
      );
      expect(
        find.byKey(Key('word_hunt_seal_node_5_${state.name}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('L10 final silhouette persists across all live states', (
    tester,
  ) async {
    for (final state in WordHuntSealNodeState.values) {
      await pumpNode(
        tester,
        spec: WordHuntSealVisualSpec.solar,
        type: WordHuntLevelType.routeFinal,
        state: state,
        levelIndex: 10,
      );
      expect(
        find.byKey(const Key('word_hunt_seal_silhouette_10_final')),
        findsOneWidget,
        reason: state.name,
      );
      expect(
        find.byKey(Key('word_hunt_seal_node_10_${state.name}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('numeral authority is live and rendered exactly once', (
    tester,
  ) async {
    await pumpNode(
      tester,
      spec: WordHuntSealVisualSpec.ancient,
      type: WordHuntLevelType.challenge,
      state: WordHuntSealNodeState.current,
      levelIndex: 5,
    );

    expect(
      find.byKey(const Key('word_hunt_seal_numeral_5')),
      findsOneWidget,
    );
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('completed has three filled stars and other states keep sockets empty', (
    tester,
  ) async {
    for (final state in <WordHuntSealNodeState>[
      WordHuntSealNodeState.normal,
      WordHuntSealNodeState.locked,
      WordHuntSealNodeState.current,
    ]) {
      await pumpNode(
        tester,
        spec: WordHuntSealVisualSpec.mechanical,
        type: WordHuntLevelType.challenge,
        state: state,
        levelIndex: 5,
      );
      for (var i = 0; i < 3; i++) {
        expect(
          find.byKey(Key('word_hunt_seal_star_socket_5_$i')),
          findsOneWidget,
        );
        expect(
          find.byKey(Key('word_hunt_seal_star_filled_5_$i')),
          findsNothing,
        );
      }
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    }

    await pumpNode(
      tester,
      spec: WordHuntSealVisualSpec.mechanical,
      type: WordHuntLevelType.challenge,
      state: WordHuntSealNodeState.completed,
      levelIndex: 5,
    );
    for (var i = 0; i < 3; i++) {
      expect(
        find.byKey(Key('word_hunt_seal_star_socket_5_$i')),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('word_hunt_seal_star_filled_5_$i')),
        findsOneWidget,
      );
    }
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
  });

  testWidgets('locked seal keeps silhouette and uses secondary physical lock', (
    tester,
  ) async {
    await pumpNode(
      tester,
      spec: WordHuntSealVisualSpec.ancient,
      type: WordHuntLevelType.routeFinal,
      state: WordHuntSealNodeState.locked,
      levelIndex: 10,
    );

    expect(
      find.byKey(const Key('word_hunt_seal_silhouette_10_final')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_seal_physical_lock_10')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
  });

  test('footprint hierarchy supports L10 greater than L5 greater than normal', () {
    for (final spec in <WordHuntSealVisualSpec>[
      WordHuntSealVisualSpec.ancient,
      WordHuntSealVisualSpec.mechanical,
      WordHuntSealVisualSpec.solar,
    ]) {
      final normal = spec.footprintFor(WordHuntLevelType.normal);
      final challenge = spec.footprintFor(WordHuntLevelType.challenge);
      final finalNode = spec.footprintFor(WordHuntLevelType.routeFinal);

      expect(challenge, greaterThan(normal), reason: spec.id);
      expect(finalNode, greaterThan(challenge), reason: spec.id);
    }
  });
}
