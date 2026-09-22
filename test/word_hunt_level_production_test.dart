import 'package:bilgi_rotasi/word_hunt/word_hunt_gameplay_presentation.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLevel(
    WidgetTester tester, {
    WordHuntLevelDefinition? level,
    DateTime Function()? now,
    Size surfaceSize = const Size(720, 1280),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntLevelProductionScreen(
          level: level ?? WordHuntStarterContent.baslangicLimani.levels.first,
          infoCards: WordHuntStarterContent.infoCards,
          now: now,
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> dragCells(
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

  Future<void> completeLevelOneTargets(WidgetTester tester) async {
    await dragCells(
      tester,
      startRow: 0,
      startColumn: 4,
      endRow: 4,
      endColumn: 4,
    );
    await dragCells(
      tester,
      startRow: 4,
      startColumn: 4,
      endRow: 4,
      endColumn: 7,
    );
    await dragCells(
      tester,
      startRow: 6,
      startColumn: 4,
      endRow: 6,
      endColumn: 7,
    );
    await dragCells(
      tester,
      startRow: 1,
      startColumn: 1,
      endRow: 1,
      endColumn: 4,
    );
    await dragCells(
      tester,
      startRow: 2,
      startColumn: 3,
      endRow: 6,
      endColumn: 3,
    );
  }

  testWidgets(
    'production Bölüm 1 8x8 grid ve 0/5 başlangıç durumunu gösterir',
    (tester) async {
      await pumpLevel(tester);
      expect(
        find.byKey(const Key('word_hunt_production_screen')),
        findsOneWidget,
      );
      expect(find.text('Bölüm 1'), findsOneWidget);
      expect(find.text('0/5'), findsOneWidget);
      expect(find.text('0 hata'), findsOneWidget);
      expect(find.text('KALEM'), findsOneWidget);
      expect(find.text('BİLGİ'), findsOneWidget);
      expect(find.text('ELMA'), findsOneWidget);
      expect(
        find.byKey(const Key('word_hunt_production_bonus_icon_ELMA')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_production_gameplay_background')),
        findsOneWidget,
      );
      final background = tester.widget<WordHuntGameplaySceneBackground>(
        find.byType(WordHuntGameplaySceneBackground),
      );
      expect(
        background.scene.assetPath,
        WordHuntRoutePresentationProfiles.harborBackground,
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(
        scaffold.backgroundColor,
        WordHuntRoutePresentationProfiles.harborSkin.scaffoldColor,
      );
      expect(
        find.byKey(const Key('word_hunt_production_instruction_plate')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_production_cell_7_7')),
        findsOneWidget,
      );
      final rect = tester.getRect(
        find.byKey(const Key('word_hunt_production_grid')),
      );
      expect(rect.width / rect.height, closeTo(1.0, 0.01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Android 16 dar viewportta B1 B5 B8 B10 64 hücre ve liman chrome görünür',
    (tester) async {
      const surface = Size(411, 731);
      const levelIndexes = <int>[1, 5, 8, 10];
      const targetCounts = <int>[5, 7, 7, 9];

      for (
        var levelOffset = 0;
        levelOffset < levelIndexes.length;
        levelOffset++
      ) {
        final levelIndex = levelIndexes[levelOffset];
        await pumpLevel(
          tester,
          level: WordHuntStarterContent.baslangicLimani.levels[levelIndex - 1],
          surfaceSize: surface,
        );

        expect(find.text('Bölüm $levelIndex'), findsOneWidget);
        expect(find.text('0/${targetCounts[levelOffset]}'), findsOneWidget);
        expect(
          find.byKey(const Key('word_hunt_production_instruction_plate')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('word_hunt_production_cell_7_7')),
          findsOneWidget,
        );

        final metricsRect = tester.getRect(
          find.byKey(const Key('word_hunt_production_progress')),
        );
        final targetsRect = tester.getRect(
          find.byKey(const Key('word_hunt_production_target_plates')),
        );
        final bonusRect = tester.getRect(
          find.byKey(const Key('word_hunt_production_bonus_plates')),
        );
        final gridRect = tester.getRect(
          find.byKey(const Key('word_hunt_production_grid')),
        );
        final instructionRect = tester.getRect(
          find.byKey(const Key('word_hunt_production_instruction_plate')),
        );
        expect(metricsRect.height, greaterThanOrEqualTo(44));
        expect(targetsRect.bottom, lessThan(bonusRect.top));
        expect(bonusRect.bottom, lessThan(gridRect.top));
        expect(gridRect.bottom, lessThan(instructionRect.top));

        final viewport = Offset.zero & surface;
        for (var row = 0; row < 8; row++) {
          for (var column = 0; column < 8; column++) {
            final rect = tester.getRect(
              find.byKey(Key('word_hunt_production_cell_${row}_$column')),
            );
            expect(
              viewport.contains(rect.topLeft) &&
                  viewport.contains(rect.bottomRight),
              isTrue,
              reason: 'B$levelIndex cell $row,$column viewport dışında: $rect',
            );
          }
        }
        expect(tester.takeException(), isNull, reason: 'Bölüm $levelIndex');
      }
    },
  );

  testWidgets('target reverse wrong ve bonus ayrışır', (tester) async {
    await pumpLevel(tester);
    await dragCells(
      tester,
      startRow: 4,
      startColumn: 4,
      endRow: 0,
      endColumn: 4,
    );
    expect(find.text('1/5'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_production_target_KALEM_found')),
      findsOneWidget,
    );

    await dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 0,
      endColumn: 3,
    );
    expect(find.text('1 hata'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));

    await dragCells(
      tester,
      startRow: 4,
      startColumn: 2,
      endRow: 4,
      endColumn: 5,
    );
    expect(
      find.byKey(const Key('word_hunt_production_bonus_ELMA_found')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('word_hunt_production_finish')), findsNothing);
  });

  testWidgets(
    'targetlar bitince süre ve hata donar, grid bonus için açık kalır',
    (tester) async {
      var now = DateTime(2026, 8, 29, 12);
      await pumpLevel(tester, now: () => now);

      await dragCells(
        tester,
        startRow: 0,
        startColumn: 0,
        endRow: 0,
        endColumn: 3,
      );
      expect(find.text('1 hata'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));

      now = now.add(const Duration(seconds: 10));
      await completeLevelOneTargets(tester);
      expect(find.text('5/5'), findsOneWidget);
      expect(
        find.byKey(const Key('word_hunt_production_finish')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_production_result_dialog')),
        findsNothing,
      );

      final frozen =
          tester
              .widget<Text>(
                find.byKey(const Key('word_hunt_production_elapsed_text')),
              )
              .data;
      expect(frozen, '10s');

      now = now.add(const Duration(seconds: 20));
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('word_hunt_production_elapsed_text')),
            )
            .data,
        frozen,
      );

      await dragCells(
        tester,
        startRow: 0,
        startColumn: 0,
        endRow: 0,
        endColumn: 3,
      );
      expect(find.text('1 hata'), findsOneWidget);

      await dragCells(
        tester,
        startRow: 4,
        startColumn: 2,
        endRow: 4,
        endColumn: 5,
      );
      expect(
        find.byKey(const Key('word_hunt_production_bonus_ELMA_found')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('word_hunt_production_result_dialog')),
        findsNothing,
      );

      await tester.ensureVisible(
        find.byKey(const Key('word_hunt_production_finish')),
      );
      await tester.tap(find.byKey(const Key('word_hunt_production_finish')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('word_hunt_production_result_dialog')),
        findsOneWidget,
      );
      expect(find.text('10 saniye'), findsOneWidget);
      expect(find.text('1 hata'), findsWidgets);
      expect(
        tester
            .widget<Icon>(
              find.byKey(const Key('word_hunt_production_result_star_2')),
            )
            .icon,
        Icons.star_rounded,
      );
      expect(
        tester
            .widget<Icon>(
              find.byKey(const Key('word_hunt_production_result_star_3')),
            )
            .icon,
        Icons.star_outline_rounded,
      );
    },
  );

  testWidgets('timeLimit production oynanışı hard fail ile kapatmaz', (
    tester,
  ) async {
    var now = DateTime(2026, 8, 29, 12);
    final level = WordHuntStarterContent.baslangicLimani.levels[4];
    await pumpLevel(tester, level: level, now: () => now);
    now = now.add(const Duration(seconds: 65));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('65s'), findsOneWidget);

    await dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 0,
      endColumn: 5,
    );
    expect(
      find.byKey(const Key('word_hunt_production_target_ANKARA_found')),
      findsOneWidget,
    );
    expect(find.text('1/7'), findsOneWidget);
  });

  testWidgets('kısa temas hata sayılmaz, tek hücre taşan hedef bulunur', (
    tester,
  ) async {
    final level = WordHuntStarterContent.baslangicLimani.levels[4];
    await pumpLevel(tester, level: level);

    await tester.tap(
      find.byKey(const Key('word_hunt_production_cell_2_0')),
    );
    await tester.pump();
    expect(find.text('0 hata'), findsOneWidget);

    await dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 0,
      endColumn: 6,
    );
    expect(find.text('1/7'), findsOneWidget);
    expect(find.text('0 hata'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_production_target_ANKARA_found')),
      findsOneWidget,
    );
  });

  testWidgets('ikinci parmak etkin sürüklemeyi değiştirmez', (tester) async {
    final level = WordHuntStarterContent.baslangicLimani.levels[4];
    await pumpLevel(tester, level: level);

    final firstStart = tester.getCenter(
      find.byKey(const Key('word_hunt_production_cell_0_0')),
    );
    final firstEnd = tester.getCenter(
      find.byKey(const Key('word_hunt_production_cell_0_5')),
    );
    final secondStart = tester.getCenter(
      find.byKey(const Key('word_hunt_production_cell_7_0')),
    );
    final secondEnd = tester.getCenter(
      find.byKey(const Key('word_hunt_production_cell_7_4')),
    );

    final first = await tester.createGesture(pointer: 1);
    final second = await tester.createGesture(pointer: 2);
    await first.down(firstStart);
    await second.down(secondStart);
    await second.moveTo(secondEnd);
    await second.up();
    await first.moveTo(firstEnd);
    await first.up();
    await tester.pump();

    expect(find.text('1/7'), findsOneWidget);
    expect(find.text('0 hata'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_production_target_ANKARA_found')),
      findsOneWidget,
    );
  });

  testWidgets('anlamlı attempt geri çıkış onayı verir', (tester) async {
    await pumpLevel(tester);
    await dragCells(
      tester,
      startRow: 0,
      startColumn: 0,
      endRow: 0,
      endColumn: 3,
    );
    await tester.tap(find.byKey(const Key('word_hunt_production_back')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('word_hunt_production_exit_dialog')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('word_hunt_production_exit_continue')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('word_hunt_production_screen')),
      findsOneWidget,
    );
  });
}
