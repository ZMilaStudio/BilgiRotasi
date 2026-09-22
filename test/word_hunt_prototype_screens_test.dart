import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> dragCells(
    WidgetTester tester,
    WordHuntLevelDefinition level, {
    required int startRow,
    required int startColumn,
    required int endRow,
    required int endColumn,
  }) async {
    final rect = tester.getRect(find.byKey(const Key('word_hunt_grid')));
    final cellWidth = rect.width / level.columnCount;
    final cellHeight = rect.height / level.rowCount;
    final start = Offset(
      rect.left + (startColumn + 0.5) * cellWidth,
      rect.top + (startRow + 0.5) * cellHeight,
    );
    final end = Offset(
      rect.left + (endColumn + 0.5) * cellWidth,
      rect.top + (endRow + 0.5) * cellHeight,
    );
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(end);
    await gesture.up();
    await tester.pump();
  }

  testWidgets('boş ilerlemede yalnız ilk rota durağı açıktır', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WordHuntRoutePrototypeScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Başlangıç Limanı'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('word_hunt_level_1')),
        matching: find.byIcon(Icons.lock_rounded),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word_hunt_level_2')),
        matching: find.byIcon(Icons.lock_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('önceki bölüm tamamlanınca ikinci durak açılır', (tester) async {
    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{'baslangic-1': 2},
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntRoutePrototypeScreen(initialProgress: progress),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('word_hunt_level_2')),
        matching: find.byIcon(Icons.lock_rounded),
      ),
      findsNothing,
    );
    expect(find.text('2 / 90'), findsOneWidget);
  });

  testWidgets(
    'prototype grid 8x8 oranında render olur ve KALEM gesture çalışır',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(720, 1280));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final level = WordHuntStarterContent.baslangicLimani.levels.first;
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntLevelPrototypeScreen(
            level: level,
            infoCards: WordHuntStarterContent.infoCards,
          ),
        ),
      );
      await tester.pump();
      final rect = tester.getRect(find.byKey(const Key('word_hunt_grid')));
      expect(rect.width / rect.height, closeTo(1.0, 0.01));
      await dragCells(
        tester,
        level,
        startRow: 0,
        startColumn: 4,
        endRow: 4,
        endColumn: 4,
      );
      expect(find.text('Harika! KALEM bulundu.'), findsOneWidget);
    },
  );

  testWidgets('Bölüm 2 DENİZ bilgi kartı dinamik 8x8 hücre hesabıyla açılır', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(720, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final level = WordHuntStarterContent.baslangicLimani.levels[1];
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntLevelPrototypeScreen(
          level: level,
          infoCards: WordHuntStarterContent.infoCards,
        ),
      ),
    );
    await tester.pump();
    await dragCells(
      tester,
      level,
      startRow: 3,
      startColumn: 3,
      endRow: 7,
      endColumn: 3,
    );
    expect(find.text('Bilgi kartı açıldı: Deniz'), findsOneWidget);
  });
}
