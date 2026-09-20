import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const viewports = <Size>[Size(360, 640), Size(412, 915)];

  testWidgets('all production gameplay profiles fit compact and tall phones', (
    tester,
  ) async {
    for (final viewport in viewports) {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;

      for (final entry in WordHuntRouteCatalog.entries) {
        final level = entry.route.levels.first;
        await tester.pumpWidget(
          MaterialApp(
            home: WordHuntLevelProductionScreen(
              level: level,
              infoCards: entry.infoCards,
              routeTitle: entry.route.title,
              presentation: entry.presentationProfile.gameplayForLevel(
                levelIndex: level.index,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          tester.takeException(),
          isNull,
          reason: '${entry.route.id} @ ${viewport.width}x${viewport.height}',
        );
        for (final key in <Key>[
          const Key('word_hunt_production_back'),
          const Key('word_hunt_production_progress'),
          const Key('word_hunt_production_mistakes'),
          const Key('word_hunt_production_elapsed'),
          const Key('word_hunt_production_word_plates'),
          const Key('word_hunt_production_grid'),
          const Key('word_hunt_production_instruction_plate'),
        ]) {
          _expectInsideViewport(tester, key, viewport, reason: entry.route.id);
        }
      }
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('representative route completion panels fit compact and tall', (
    tester,
  ) async {
    final representativeEntries = <WordHuntRouteCatalogEntry>[
      WordHuntRouteCatalog.starter,
      WordHuntRouteCatalog.gokyuzu,
      WordHuntRouteCatalog.orman,
      WordHuntRouteCatalog.kayipSehir,
      WordHuntRouteCatalog.yeraltiKralligi,
      WordHuntRouteCatalog.gunesImparatorlugu,
    ];

    for (final viewport in viewports) {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;

      for (final entry in representativeEntries) {
        await tester.pumpWidget(
          MaterialApp(
            home: WordHuntLevelProductionScreen(
              level: _completionFixture(entry.route.id),
              infoCards: const <WordHuntInfoCard>[],
              routeTitle: entry.route.title,
              presentation: entry.presentationProfile.gameplayForLevel(
                levelIndex: 1,
              ),
              now: () => DateTime(2026, 9, 20, 12),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        final gridRect = tester.getRect(
          find.byKey(const Key('word_hunt_production_grid')),
        );
        final start = Offset(
          gridRect.left + gridRect.width / 6,
          gridRect.top + gridRect.height / 6,
        );
        final end = Offset(
          gridRect.left + gridRect.width * 5 / 6,
          gridRect.top + gridRect.height / 6,
        );
        final gesture = await tester.startGesture(start);
        await gesture.moveTo(end);
        await gesture.up();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.byKey(const Key('word_hunt_production_result_panel')),
          findsOneWidget,
          reason: entry.route.id,
        );
        expect(find.text('Rotaya Dön'), findsOneWidget, reason: entry.route.id);
        expect(
          tester.takeException(),
          isNull,
          reason:
              'completion ${entry.route.id} @ ${viewport.width}x${viewport.height}',
        );
        _expectInsideViewport(
          tester,
          const Key('word_hunt_production_result_panel'),
          viewport,
          reason: entry.route.id,
        );
        _expectInsideViewport(
          tester,
          const Key('word_hunt_production_return_route'),
          viewport,
          reason: entry.route.id,
        );

        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        await tester.pump();
      }
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

WordHuntLevelDefinition _completionFixture(String routeId) {
  return WordHuntLevelDefinition(
    id: 'wave5-layout-$routeId',
    routeId: routeId,
    index: 1,
    type: WordHuntLevelType.normal,
    grid: const <String>['ABC', 'DEF', 'GHI'],
    targetWords: const <String>['ABC'],
    bonusWords: const <String>[],
    starRules: const WordHuntStarRules(),
  );
}

void _expectInsideViewport(
  WidgetTester tester,
  Key key,
  Size viewport, {
  required String reason,
}) {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget, reason: reason);
  final rect = tester.getRect(finder);
  expect(rect.left, greaterThanOrEqualTo(0), reason: reason);
  expect(rect.top, greaterThanOrEqualTo(0), reason: reason);
  expect(rect.right, lessThanOrEqualTo(viewport.width), reason: reason);
  expect(rect.bottom, lessThanOrEqualTo(viewport.height), reason: reason);
}
