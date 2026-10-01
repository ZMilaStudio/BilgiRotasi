import 'package:bilgi_rotasi/word_hunt/word_hunt_gameplay_presentation.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/word_hunt_canonical_paths.dart';

void main() {
  final levelOne = WordHuntStarterContent.baslangicLimani.levels.first;
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

  Future<void> dragPath(WidgetTester tester, List<WordHuntCell> path) =>
      dragCells(
        tester,
        startRow: path.first.row,
        startColumn: path.first.column,
        endRow: path.last.row,
        endColumn: path.last.column,
      );

  Future<void> completeLevelOneTargets(WidgetTester tester) async {
    for (final word in levelOne.targetWords) {
      await dragPath(tester, canonicalPath(levelOne, word));
    }
  }

  testWidgets(
    'production Bölüm 1 8x8 grid ve canonical target başlangıç durumunu gösterir',
    (tester) async {
      await pumpLevel(tester);
      expect(
        find.byKey(const Key('word_hunt_production_screen')),
        findsOneWidget,
      );
      expect(find.text('Bölüm 1'), findsOneWidget);
      expect(find.text('0/${levelOne.targetWords.length}'), findsOneWidget);
      expect(find.text('0 hata'), findsOneWidget);
      for (final word in [...levelOne.targetWords, ...levelOne.bonusWords]) {
        expect(find.text(word), findsOneWidget);
      }
      expect(
        find.byKey(
          Key('word_hunt_production_bonus_icon_${levelOne.bonusWords.single}'),
        ),
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

      for (
        var levelOffset = 0;
        levelOffset < levelIndexes.length;
        levelOffset++
      ) {
        final levelIndex = levelIndexes[levelOffset];
        final level =
            WordHuntStarterContent.baslangicLimani.levels[levelIndex - 1];
        await pumpLevel(tester, level: level, surfaceSize: surface);

        expect(find.text('Bölüm $levelIndex'), findsOneWidget);
        expect(find.text('0/${level.targetWords.length}'), findsOneWidget);
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
    await dragPath(tester, canonicalPath(levelOne, 'KALEM').reversed.toList());
    expect(find.text('1/${levelOne.targetWords.length}'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_production_target_KALEM_found')),
      findsOneWidget,
    );

    await dragPath(tester, wrongSelection(levelOne));
    expect(find.text('1 hata'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));

    await dragPath(tester, canonicalPath(levelOne, levelOne.bonusWords.single));
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

      await dragPath(tester, wrongSelection(levelOne));
      expect(find.text('1 hata'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));

      now = now.add(const Duration(seconds: 10));
      await completeLevelOneTargets(tester);
      expect(
        find.text(
          '${levelOne.targetWords.length}/${levelOne.targetWords.length}',
        ),
        findsOneWidget,
      );
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

      await dragPath(tester, wrongSelection(levelOne));
      expect(find.text('1 hata'), findsOneWidget);

      await dragPath(
        tester,
        canonicalPath(levelOne, levelOne.bonusWords.single),
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

    await dragPath(tester, canonicalPath(level, level.targetWords.first));
    expect(
      find.byKey(
        Key('word_hunt_production_target_${level.targetWords.first}_found'),
      ),
      findsOneWidget,
    );
    expect(find.text('1/${level.targetWords.length}'), findsOneWidget);
  });

  testWidgets('kısa temas hata sayılmaz, tek hücre taşan hedef bulunur', (
    tester,
  ) async {
    final level = WordHuntStarterContent.baslangicLimani.levels[4];
    await pumpLevel(tester, level: level);
    final fixture = extendableTarget(level);

    await tester.tap(find.byKey(const Key('word_hunt_production_cell_2_0')));
    await tester.pump();
    expect(find.text('0 hata'), findsOneWidget);

    await dragPath(tester, extendPath(fixture.$2, 1));
    expect(find.text('1/${level.targetWords.length}'), findsOneWidget);
    expect(find.text('0 hata'), findsOneWidget);
    expect(
      find.byKey(Key('word_hunt_production_target_${fixture.$1}_found')),
      findsOneWidget,
    );
  });

  testWidgets('ikinci parmak etkin sürüklemeyi değiştirmez', (tester) async {
    final level = WordHuntStarterContent.baslangicLimani.levels[4];
    await pumpLevel(tester, level: level);

    final firstPath = canonicalPath(level, level.targetWords.first);
    final secondPath = canonicalPath(level, level.targetWords[1]);
    Offset center(WordHuntCell cell) => tester.getCenter(
      find.byKey(Key('word_hunt_production_cell_${cell.row}_${cell.column}')),
    );
    final firstStart = center(firstPath.first);
    final firstEnd = center(firstPath.last);
    final secondStart = center(secondPath.first);
    final secondEnd = center(secondPath.last);

    final first = await tester.createGesture(pointer: 1);
    final second = await tester.createGesture(pointer: 2);
    await first.down(firstStart);
    await second.down(secondStart);
    await second.moveTo(secondEnd);
    await second.up();
    await first.moveTo(firstEnd);
    await first.up();
    await tester.pump();

    expect(find.text('1/${level.targetWords.length}'), findsOneWidget);
    expect(find.text('0 hata'), findsOneWidget);
    expect(
      find.byKey(
        Key('word_hunt_production_target_${level.targetWords.first}_found'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('anlamlı attempt geri çıkış onayı verir', (tester) async {
    await pumpLevel(tester);
    await dragPath(tester, wrongSelection(levelOne));
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
