import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const route = WordHuntGokyuzuContent.gokyuzuAdalari;

  test('Gökyüzü Adaları 10 bölüm / 30 yıldız / 80 kelime sözleşmesini taşır', () {
    expect(route.id, 'gokyuzu-adalari');
    expect(route.title, 'Gökyüzü Adaları');
    expect(route.levels, hasLength(10));
    expect(route.maximumStars, 30);
    expect(route.unlockStarsRequired, 18);

    const targetCounts = <int>[5, 5, 6, 6, 7, 7, 8, 7, 9, 9];
    const bonusCounts = <int>[1, 1, 1, 1, 1, 1, 1, 2, 1, 1];
    var totalWords = 0;
    for (var index = 0; index < route.levels.length; index++) {
      final level = route.levels[index];
      expect(level.index, index + 1, reason: level.id);
      expect(level.rowCount, 8, reason: level.id);
      expect(level.columnCount, 8, reason: level.id);
      expect(level.targetWords, hasLength(targetCounts[index]), reason: level.id);
      expect(level.bonusWords, hasLength(bonusCounts[index]), reason: level.id);
      totalWords += level.targetWords.length + level.bonusWords.length;
    }
    expect(totalWords, 80);
  });

  test('bölüm tipleri ve özel bonuslar canonical paket eğrisini korur', () {
    final counts = <WordHuntLevelType, int>{};
    for (final level in route.levels) {
      counts[level.type] = (counts[level.type] ?? 0) + 1;
    }
    expect(counts[WordHuntLevelType.normal], 7);
    expect(counts[WordHuntLevelType.challenge], 1);
    expect(counts[WordHuntLevelType.bonus], 1);
    expect(counts[WordHuntLevelType.routeFinal], 1);
    expect(route.levels[4].type, WordHuntLevelType.challenge);
    expect(route.levels[7].type, WordHuntLevelType.bonus);
    expect(route.levels[9].type, WordHuntLevelType.routeFinal);
    expect(route.levels[7].bonusWords, const <String>['SIRLAR', 'HAZİNE']);
    expect(route.levels[8].bonusWords, const <String>['ROKET']);
    expect(route.levels[9].bonusWords, const <String>['ZAFER']);
  });

  test('içerik validatorı bütün rota ve bilgi kartlarını kabul eder', () {
    final errors = WordHuntContentValidator.validate(
      route: route,
      infoCards: WordHuntGokyuzuContent.infoCards,
    );
    expect(errors, isEmpty, reason: errors.join('\n'));
  });

  test('her target ve bonus exactly-one fiziksel occurrence taşır', () {
    for (final level in route.levels) {
      for (final word in <String>[...level.targetWords, ...level.bonusWords]) {
        final occurrences = _findPhysicalOccurrences(level.grid, word);
        expect(
          occurrences,
          hasLength(1),
          reason: '${level.id}: $word exactly-one physical occurrence',
        );

        final path = occurrences.single;
        final forward = WordHuntPathEngine.evaluate(level: level, path: path);
        final expectedKind = level.bonusWords.contains(word)
            ? WordHuntSelectionKind.bonus
            : WordHuntSelectionKind.target;
        expect(forward.kind, expectedKind, reason: '${level.id}: $word forward');
        expect(forward.canonicalWord, word);

        final reverse = WordHuntPathEngine.evaluate(
          level: level,
          path: path.reversed.toList(growable: false),
        );
        expect(reverse.kind, expectedKind, reason: '${level.id}: $word reverse');
        expect(reverse.canonicalWord, word);
      }
    }
  });

  test('ilk iki bölüm yalnız yatay/dikey kelime hatlarıyla başlar', () {
    for (final level in route.levels.take(2)) {
      for (final word in <String>[...level.targetWords, ...level.bonusWords]) {
        final path = _findPhysicalOccurrences(level.grid, word).single;
        expect(
          _directionFamily(path),
          isNot('diagonal'),
          reason: '${level.id}: $word',
        );
      }
    }
  });

  test('Bölüm 5 ve final yatay/dikey/çapraz ailelerini birlikte taşır', () {
    for (final levelIndex in <int>[5, 10]) {
      final level = route.levels[levelIndex - 1];
      final families = <String>{};
      for (final word in <String>[...level.targetWords, ...level.bonusWords]) {
        final path = _findPhysicalOccurrences(level.grid, word).single;
        families.add(_directionFamily(path));
      }
      expect(
        families,
        const <String>{'horizontal', 'vertical', 'diagonal'},
        reason: level.id,
      );
    }
  });

  test('Bölüm 5 ve Bölüm 10 süre/yıldız eşikleri korunur', () {
    final level5 = route.levels[4];
    final level10 = route.levels[9];
    expect(level5.timeLimitSeconds, 60);
    expect(level5.starRules.twoStarMaxSeconds, 50);
    expect(level5.starRules.threeStarMaxSeconds, 35);
    expect(level5.starRules.twoStarMaxMistakes, 1);
    expect(level5.starRules.threeStarMaxMistakes, 0);
    expect(level10.timeLimitSeconds, 120);
    expect(level10.starRules.twoStarMaxSeconds, 100);
    expect(level10.starRules.threeStarMaxSeconds, 75);
    expect(level10.starRules.twoStarMaxMistakes, 2);
    expect(level10.starRules.threeStarMaxMistakes, 0);
  });

  test('bilgi kartları yalnız bölümde bulunan canonical kelimelere bağlıdır', () {
    final cardsById = <String, WordHuntInfoCard>{
      for (final card in WordHuntGokyuzuContent.infoCards) card.id: card,
    };
    expect(cardsById, hasLength(WordHuntGokyuzuContent.infoCards.length));

    for (final level in route.levels) {
      final words = <String>{...level.targetWords, ...level.bonusWords}
          .map(WordHuntPathEngine.normalizeWord)
          .toSet();
      for (final cardId in level.infoCardIds) {
        expect(cardsById, contains(cardId), reason: '${level.id}: $cardId');
        expect(
          words,
          contains(WordHuntPathEngine.normalizeWord(cardsById[cardId]!.word)),
          reason: '${level.id}: $cardId',
        );
      }
    }
  });
}

List<List<WordHuntCell>> _findPhysicalOccurrences(
  List<String> grid,
  String canonicalWord,
) {
  final rows = grid.length;
  final columns = grid.first.runes.length;
  final word = WordHuntPathEngine.normalizeWord(canonicalWord);
  final wordLength = word.runes.length;
  final byPhysicalPath = <String, List<WordHuntCell>>{};

  for (var row = 0; row < rows; row++) {
    for (var column = 0; column < columns; column++) {
      for (final rowDelta in const <int>[-1, 0, 1]) {
        for (final columnDelta in const <int>[-1, 0, 1]) {
          if (rowDelta == 0 && columnDelta == 0) continue;
          final endRow = row + rowDelta * (wordLength - 1);
          final endColumn = column + columnDelta * (wordLength - 1);
          if (endRow < 0 ||
              endRow >= rows ||
              endColumn < 0 ||
              endColumn >= columns) {
            continue;
          }

          final path = List<WordHuntCell>.generate(
            wordLength,
            (index) => WordHuntCell(
              row + rowDelta * index,
              column + columnDelta * index,
            ),
            growable: false,
          );
          final read = String.fromCharCodes(
            path.map((cell) => grid[cell.row].runes.elementAt(cell.column)),
          );
          final normalizedRead = WordHuntPathEngine.normalizeWord(read);
          if (normalizedRead == word ||
              WordHuntPathEngine.reverseWord(normalizedRead) == word) {
            byPhysicalPath[_physicalPathKey(path)] = path;
          }
        }
      }
    }
  }

  return byPhysicalPath.values.toList(growable: false);
}

String _physicalPathKey(List<WordHuntCell> path) {
  final a = '${path.first.row},${path.first.column}';
  final b = '${path.last.row},${path.last.column}';
  return a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a';
}

String _directionFamily(List<WordHuntCell> path) {
  final rowDelta = path[1].row - path[0].row;
  final columnDelta = path[1].column - path[0].column;
  if (rowDelta == 0) return 'horizontal';
  if (columnDelta == 0) return 'vertical';
  return 'diagonal';
}
