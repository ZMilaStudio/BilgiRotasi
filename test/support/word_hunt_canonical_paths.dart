import 'package:bilgi_rotasi/word_hunt/word_hunt_input.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';

/// Finds exact physical words in canonical data, without old grid coordinates.
/// Fails closed for absent/ambiguous words (palindrome directions deduplicate).
List<WordHuntCell> canonicalPath(WordHuntLevelDefinition level, String word) {
  final normalized = WordHuntPathEngine.normalizeWord(word);
  final matches = <String, List<WordHuntCell>>{};
  for (var row = 0; row < level.rowCount; row++) {
    for (var col = 0; col < level.columnCount; col++) {
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final path = List.generate(
            normalized.length,
            (i) => WordHuntCell(row + dr * i, col + dc * i),
          );
          if (path.any(
            (c) =>
                c.row < 0 ||
                c.row >= level.rowCount ||
                c.column < 0 ||
                c.column >= level.columnCount,
          ))
            continue;
          final read = path.map((c) => level.grid[c.row][c.column]).join();
          if (WordHuntPathEngine.normalizeWord(read) != normalized) continue;
          final keys = path.map((c) => '${c.row},${c.column}').toList()..sort();
          matches[keys.join('|')] = path;
        }
      }
    }
  }
  if (matches.length != 1) {
    throw StateError(
      '${level.id}: $word needs one physical path; found ${matches.length}',
    );
  }
  return matches.values.single;
}

List<WordHuntCell> extendPath(List<WordHuntCell> path, int count) {
  final dr = path[1].row - path[0].row;
  final dc = path[1].column - path[0].column;
  return [
    ...path,
    for (var i = 1; i <= count; i++)
      WordHuntCell(path.last.row + dr * i, path.last.column + dc * i),
  ];
}

/// Selects a real target with room for both one- and two-cell overshoot.
(String, List<WordHuntCell>) extendableTarget(WordHuntLevelDefinition level) {
  for (final word in level.targetWords) {
    final forward = canonicalPath(level, word);
    for (final path in [forward, forward.reversed.toList()]) {
      final extended = extendPath(path, 2);
      if (extended.every(
        (c) =>
            c.row >= 0 &&
            c.row < level.rowCount &&
            c.column >= 0 &&
            c.column < level.columnCount,
      )) {
        return (word, path);
      }
    }
  }
  throw StateError('${level.id}: no target supports the overshoot fixture');
}

/// A meaningful straight selection that is neither a word nor a trimmed word.
List<WordHuntCell> wrongSelection(WordHuntLevelDefinition level) {
  final minimum = [
    ...level.targetWords,
    ...level.bonusWords,
  ].map((w) => w.length).reduce((a, b) => a < b ? a : b);
  for (var row = 0; row < level.rowCount; row++) {
    for (var col = 0; col <= level.columnCount - minimum; col++) {
      final path = List.generate(minimum, (i) => WordHuntCell(row, col + i));
      final result = WordHuntInputResolver.resolve(level: level, path: path);
      if (result.result?.kind == WordHuntSelectionKind.notAWord) return path;
    }
  }
  throw StateError('${level.id}: no meaningful wrong-selection fixture');
}
