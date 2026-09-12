import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const route = WordHuntOrmanContent.ormanYolu;

  test('Orman Yolu has ten canonical levels and validates', () {
    expect(route.id, 'orman-yolu');
    expect(route.title, 'Orman Yolu');
    expect(route.levels, hasLength(10));
    expect(
      WordHuntContentValidator.validate(
        route: route,
        infoCards: WordHuntOrmanContent.infoCards,
      ),
      isEmpty,
    );

    for (var index = 1; index <= route.levels.length; index++) {
      final level = route.levels[index - 1];
      expect(level.id, 'orman-yolu-${index.toString().padLeft(2, '0')}');
      expect(level.routeId, route.id);
      expect(level.index, index);
      expect(level.grid, hasLength(8));
      expect(level.grid.every((row) => row.runes.length == 8), isTrue);
    }
  });

  test('5-8-9-10 type and time contract is canonical', () {
    expect(route.levels[4].type, WordHuntLevelType.challenge);
    expect(route.levels[4].timeLimitSeconds, 60);
    expect(route.levels[7].type, WordHuntLevelType.normal);
    expect(route.levels[8].type, WordHuntLevelType.normal);
    expect(route.levels[9].type, WordHuntLevelType.routeFinal);
    expect(route.levels[9].timeLimitSeconds, 120);
  });

  test('progression is strictly 7 to 8 to 9 to 10', () {
    var progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (var index = 1; index <= 7; index++)
          'orman-yolu-${index.toString().padLeft(2, '0')}': 1,
      },
    );

    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 8),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 9),
      isFalse,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10),
      isFalse,
    );

    progress = progress.recordLevelResult(levelId: 'orman-yolu-08', stars: 1);
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 9),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10),
      isFalse,
    );

    progress = progress.recordLevelResult(levelId: 'orman-yolu-09', stars: 1);
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10),
      isTrue,
    );
  });

  test('every target and bonus has exactly one physical straight occurrence', () {
    for (final level in route.levels) {
      for (final word in <String>[...level.targetWords, ...level.bonusWords]) {
        expect(
          _physicalOccurrenceCount(level.grid, word),
          1,
          reason: '${level.id} / $word',
        );
      }
    }
  });
}

int _physicalOccurrenceCount(List<String> grid, String candidate) {
  final rows = grid.map((row) => row.runes.toList(growable: false)).toList();
  final word = WordHuntPathEngine.normalizeWord(candidate).runes.toList();
  const directions = <(int, int)>[
    (-1, -1),
    (-1, 0),
    (-1, 1),
    (0, -1),
    (0, 1),
    (1, -1),
    (1, 0),
    (1, 1),
  ];
  final physicalPaths = <String>{};

  for (var startRow = 0; startRow < rows.length; startRow++) {
    for (var startColumn = 0; startColumn < rows.first.length; startColumn++) {
      for (final direction in directions) {
        final cells = <(int, int)>[];
        var matches = true;

        for (var index = 0; index < word.length; index++) {
          final row = startRow + direction.$1 * index;
          final column = startColumn + direction.$2 * index;
          if (row < 0 ||
              row >= rows.length ||
              column < 0 ||
              column >= rows.first.length ||
              rows[row][column] != word[index]) {
            matches = false;
            break;
          }
          cells.add((row, column));
        }

        if (!matches) continue;
        final forward = cells.map((cell) => '${cell.$1}:${cell.$2}').join('|');
        final reverse = cells.reversed
            .map((cell) => '${cell.$1}:${cell.$2}')
            .join('|');
        physicalPaths.add(forward.compareTo(reverse) <= 0 ? forward : reverse);
      }
    }
  }

  return physicalPaths.length;
}
