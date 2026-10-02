import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_content_validator.dart';
import 'package:word_hunt_domain/word_hunt_models.dart';

List<Set<(int, int)>> pathsFor(WordHuntLevelDefinition level, String word) {
  final paths = <String, Set<(int, int)>>{};
  for (var row = 0; row < 8; row++) {
    for (var column = 0; column < 8; column++) {
      for (final dr in [-1, 0, 1]) {
        for (final dc in [-1, 0, 1]) {
          if (dr == 0 && dc == 0) continue;
          final cells = List.generate(
            word.length,
            (i) => (row + dr * i, column + dc * i),
          );
          if (cells.any((c) => c.$1 < 0 || c.$1 >= 8 || c.$2 < 0 || c.$2 >= 8))
            continue;
          if (cells.map((c) => level.grid[c.$1][c.$2]).join() != word) continue;
          final ordered =
              cells.toList()..sort(
                (a, b) =>
                    a.$1 == b.$1 ? a.$2.compareTo(b.$2) : a.$1.compareTo(b.$1),
              );
          paths[ordered.join('|')] = cells.toSet();
        }
      }
    }
  }
  return paths.values.toList();
}

void main() {
  const route = WordHuntStarterContent.baslangicLimani;
  test(
    'owner density, natural-word fit and full-route exact placement contracts',
    () {
      final allWords = <String>[];
      expect(
        WordHuntContentValidator.validate(
          route: route,
          infoCards: WordHuntStarterContent.infoCards,
        ),
        isEmpty,
      );
      for (final level in route.levels) {
        final count = level.targetWords.length;
        if (level.index <= 30) {
          expect(
            count,
            level.index <= 5
                ? 6
                : level.index <= 10
                ? 7
                : level.index < 20
                ? inInclusiveRange(7, 8)
                : level.index == 20
                ? inInclusiveRange(8, 9)
                : level.index < 30
                ? 8
                : inInclusiveRange(8, 9),
            reason: level.id,
          );
        }
        expect(level.grid, hasLength(8));
        expect(level.grid.every((row) => row.length == 8), isTrue);
        final words = [...level.targetWords, ...level.bonusWords];
        expect(words.toSet().length, words.length);
        for (final word in words) {
          expect(word.length, inInclusiveRange(3, 8));
          expect(['GÖKKUŞAK', 'ÇİSENTİ'], isNot(contains(word)));
          expect(
            pathsFor(level, word),
            hasLength(1),
            reason: '${level.id}: $word',
          );
        }
        allWords.addAll(words);
      }
      expect(
        allWords.toSet().length,
        allWords.length,
        reason: 'Keep route-wide target/bonus uniqueness',
      );
    },
  );

  for (final level in route.levels) {
    test('${level.id} deterministic target readability and spatial spread', () {
      final paths =
          level.targetWords
              .map((word) => pathsFor(level, word).single)
              .toList();
      final occupancy = <(int, int), int>{};
      for (final path in paths) {
        for (final cell in path)
          occupancy.update(cell, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(
        occupancy.values.every((n) => n <= 2),
        isTrue,
        reason: 'No triple occupancy',
      );
      for (var i = 0; i < paths.length; i++) {
        var neighbors = 0;
        for (var j = 0; j < paths.length; j++) {
          if (i == j) continue;
          final shared = paths[i].intersection(paths[j]).length;
          expect(
            shared,
            lessThanOrEqualTo(1),
            reason: 'No repeated pair overlap',
          );
          if (shared > 0) neighbors++;
        }
        expect(neighbors, lessThanOrEqualTo(2));
      }
      expect(
        occupancy.keys.map((c) => (c.$1 ~/ 4, c.$2 ~/ 4)).toSet(),
        hasLength(4),
      );
      final rows = occupancy.keys.map((c) => c.$1).toList()..sort();
      final columns = occupancy.keys.map((c) => c.$2).toList()..sort();
      expect(rows.last - rows.first, greaterThanOrEqualTo(5));
      expect(columns.last - columns.first, greaterThanOrEqualTo(5));
    });
  }
}
