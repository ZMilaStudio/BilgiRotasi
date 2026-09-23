import 'word_hunt_models.dart';

enum WordHuntPathRule {
  /// Klasik kelime avı: yatay, dikey veya çapraz tek bir düz çizgi.
  straightEightDirections,

  /// Gelecekte Bilgi Zinciri gibi modlar için: sekiz yönde bitişik hücreler.
  adjacentEightDirections,
}

enum WordHuntSelectionKind {
  target,
  bonus,
  alreadyFound,
  notAWord,
  invalidPath,
}

class WordHuntCell {
  const WordHuntCell(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) {
    return other is WordHuntCell && row == other.row && column == other.column;
  }

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => 'WordHuntCell($row, $column)';
}

class WordHuntPathReadResult {
  const WordHuntPathReadResult._({
    required this.isValid,
    required this.word,
    this.error,
  });

  const WordHuntPathReadResult.valid(String word)
    : this._(isValid: true, word: word);

  const WordHuntPathReadResult.invalid(String error)
    : this._(isValid: false, word: '', error: error);

  final bool isValid;
  final String word;
  final String? error;
}

class WordHuntSelectionResult {
  const WordHuntSelectionResult({
    required this.kind,
    required this.selectedWord,
    this.canonicalWord,
    this.error,
  });

  final WordHuntSelectionKind kind;
  final String selectedWord;
  final String? canonicalWord;
  final String? error;

  bool get accepted =>
      kind == WordHuntSelectionKind.target ||
      kind == WordHuntSelectionKind.bonus;
}

class WordHuntPathEngine {
  WordHuntPathEngine._();

  static WordHuntPathReadResult readWord({
    required List<String> grid,
    required List<WordHuntCell> path,
    WordHuntPathRule rule = WordHuntPathRule.straightEightDirections,
  }) {
    if (grid.isEmpty) {
      return const WordHuntPathReadResult.invalid('grid boş olamaz');
    }
    if (path.isEmpty) {
      return const WordHuntPathReadResult.invalid('seçim yolu boş olamaz');
    }

    final rows = grid.map((row) => row.runes.toList(growable: false)).toList();
    final width = rows.first.length;
    if (width == 0) {
      return const WordHuntPathReadResult.invalid('grid satırları boş olamaz');
    }
    if (rows.any((row) => row.length != width)) {
      return const WordHuntPathReadResult.invalid('grid dikdörtgen olmalı');
    }

    final used = <WordHuntCell>{};
    for (final cell in path) {
      if (cell.row < 0 ||
          cell.row >= rows.length ||
          cell.column < 0 ||
          cell.column >= width) {
        return WordHuntPathReadResult.invalid('hücre grid dışında: $cell');
      }
      if (!used.add(cell)) {
        return WordHuntPathReadResult.invalid(
          'aynı hücre tekrar kullanılamaz: $cell',
        );
      }
    }

    if (path.length > 1) {
      final firstDelta = _delta(path[0], path[1]);
      if (!_isAdjacent(firstDelta.$1, firstDelta.$2)) {
        return const WordHuntPathReadResult.invalid(
          'ardışık hücreler sekiz yönde bitişik olmalı',
        );
      }

      for (var index = 1; index < path.length; index++) {
        final delta = _delta(path[index - 1], path[index]);
        if (!_isAdjacent(delta.$1, delta.$2)) {
          return const WordHuntPathReadResult.invalid(
            'ardışık hücreler sekiz yönde bitişik olmalı',
          );
        }
        if (rule == WordHuntPathRule.straightEightDirections &&
            delta != firstDelta) {
          return const WordHuntPathReadResult.invalid(
            'klasik kelime avında seçim tek bir düz çizgide olmalı',
          );
        }
      }
    }

    final buffer = StringBuffer();
    for (final cell in path) {
      buffer.writeCharCode(rows[cell.row][cell.column]);
    }

    return WordHuntPathReadResult.valid(buffer.toString());
  }

  static WordHuntSelectionResult evaluate({
    required WordHuntLevelDefinition level,
    required List<WordHuntCell> path,
    Set<String> foundTargetWords = const <String>{},
    Set<String> foundBonusWords = const <String>{},
    WordHuntPathRule rule = WordHuntPathRule.straightEightDirections,
  }) {
    final read = readWord(grid: level.grid, path: path, rule: rule);
    if (!read.isValid) {
      return WordHuntSelectionResult(
        kind: WordHuntSelectionKind.invalidPath,
        selectedWord: '',
        error: read.error,
      );
    }

    final selected = normalizeWord(read.word);
    final selectedReverse = reverseWord(selected);

    final target = _findCanonical(level.targetWords, selected, selectedReverse);
    if (target != null) {
      final normalizedFound = foundTargetWords.map(normalizeWord).toSet();
      if (normalizedFound.contains(normalizeWord(target))) {
        return WordHuntSelectionResult(
          kind: WordHuntSelectionKind.alreadyFound,
          selectedWord: selected,
          canonicalWord: target,
        );
      }
      return WordHuntSelectionResult(
        kind: WordHuntSelectionKind.target,
        selectedWord: selected,
        canonicalWord: target,
      );
    }

    final bonus = _findCanonical(level.bonusWords, selected, selectedReverse);
    if (bonus != null) {
      final normalizedFound = foundBonusWords.map(normalizeWord).toSet();
      if (normalizedFound.contains(normalizeWord(bonus))) {
        return WordHuntSelectionResult(
          kind: WordHuntSelectionKind.alreadyFound,
          selectedWord: selected,
          canonicalWord: bonus,
        );
      }
      return WordHuntSelectionResult(
        kind: WordHuntSelectionKind.bonus,
        selectedWord: selected,
        canonicalWord: bonus,
      );
    }

    return WordHuntSelectionResult(
      kind: WordHuntSelectionKind.notAWord,
      selectedWord: selected,
    );
  }

  static String normalizeWord(String value) {
    return value.trim().replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
  }

  static String reverseWord(String value) {
    return String.fromCharCodes(value.runes.toList().reversed);
  }

  static (int, int) _delta(WordHuntCell from, WordHuntCell to) {
    return (to.row - from.row, to.column - from.column);
  }

  static bool _isAdjacent(int rowDelta, int columnDelta) {
    if (rowDelta == 0 && columnDelta == 0) return false;
    return rowDelta.abs() <= 1 && columnDelta.abs() <= 1;
  }

  static String? _findCanonical(
    List<String> candidates,
    String selected,
    String selectedReverse,
  ) {
    for (final candidate in candidates) {
      final normalized = normalizeWord(candidate);
      if (normalized == selected || normalized == selectedReverse) {
        return candidate;
      }
    }
    return null;
  }
}
