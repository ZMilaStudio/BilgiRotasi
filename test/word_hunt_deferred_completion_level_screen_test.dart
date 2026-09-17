import 'package:bilgi_rotasi/word_hunt/word_hunt_deferred_completion_level_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _finalLevel = WordHuntLevelDefinition(
  id: 'test-final',
  routeId: 'test-route',
  index: 10,
  type: WordHuntLevelType.routeFinal,
  grid: <String>['ABC', 'DEF', 'GHI'],
  targetWords: <String>['ABC'],
  starRules: WordHuntStarRules(
    twoStarMaxMistakes: 2,
    threeStarMaxMistakes: 0,
  ),
);

class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  WordHuntLevelPlayResult? result;

  Future<void> _open() async {
    final next = await Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder: (_) => const WordHuntDeferredCompletionLevelScreen(
          level: _finalLevel,
          infoCards: <WordHuntInfoCard>[],
          routeTitle: 'Test Rotası',
        ),
      ),
    );
    if (!mounted) return;
    setState(() => result = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: result == null
            ? FilledButton(
                key: const Key('open_deferred_final'),
                onPressed: _open,
                child: const Text('Aç'),
              )
            : Text(
                '${result!.levelId}:${result!.stars}',
                key: const Key('deferred_result'),
              ),
      ),
    );
  }
}

Future<void> _pumpHarness(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(720, 1280));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const MaterialApp(home: _Harness()));
  await tester.tap(find.byKey(const Key('open_deferred_final')));
  await tester.pumpAndSettle();
  expect(
    find.byKey(const Key('word_hunt_deferred_completion_navigator')),
    findsOneWidget,
  );
  expect(find.byKey(const Key('word_hunt_production_screen')), findsOneWidget);
}

Future<void> _dragCells(
  WidgetTester tester, {
  required int startRow,
  required int startColumn,
  required int endRow,
  required int endColumn,
}) async {
  final start = tester.getCenter(
    find.byKey(Key('word_hunt_production_cell_${startRow}_$startColumn')),
  );
  final end = tester.getCenter(
    find.byKey(Key('word_hunt_production_cell_${endRow}_$endColumn')),
  );
  final gesture = await tester.startGesture(start);
  await gesture.moveTo(end);
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('deferred final suppresses generic result and forwards score', (
    tester,
  ) async {
    await _pumpHarness(tester);

    await _dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 0,
      endColumn: 2,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('word_hunt_production_result_dialog')),
      findsNothing,
    );
    expect(find.byKey(const Key('deferred_result')), findsOneWidget);
    expect(find.text('test-final:3'), findsOneWidget);
  });

  testWidgets('deferred final does not auto-dismiss exit confirmation', (
    tester,
  ) async {
    await _pumpHarness(tester);

    await _dragCells(
      tester,
      startRow: 1,
      startColumn: 0,
      endRow: 1,
      endColumn: 2,
    );
    expect(find.text('1 hata'), findsOneWidget);

    await tester.tap(find.byKey(const Key('word_hunt_production_back')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('word_hunt_production_exit_dialog')),
      findsOneWidget,
    );
    expect(find.text('Bölümden çıkılsın mı?'), findsOneWidget);
  });
}
