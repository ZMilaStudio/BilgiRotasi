import 'word_hunt_models.dart';
import 'word_hunt_path.dart';

class WordHuntContentValidator {
  WordHuntContentValidator._();

  static List<String> validate({
    required WordHuntRouteDefinition route,
    required List<WordHuntInfoCard> infoCards,
  }) {
    final errors = <String>[
      ...WordHuntDefinitionValidator.validateRoute(route),
    ];

    final cardsById = <String, WordHuntInfoCard>{};
    for (final card in infoCards) {
      final id = card.id.trim();
      if (id.isEmpty) {
        errors.add('bilgi kartı id boş olamaz');
        continue;
      }
      if (cardsById.containsKey(id)) {
        errors.add('bilgi kartı id tekrar ediyor: $id');
        continue;
      }
      cardsById[id] = card;

      if (card.word.trim().isEmpty) {
        errors.add('$id: word boş olamaz');
      }
      if (card.title.trim().isEmpty) {
        errors.add('$id: title boş olamaz');
      }
      if (card.shortFact.trim().isEmpty) {
        errors.add('$id: shortFact boş olamaz');
      }
      if (card.category.trim().isEmpty) {
        errors.add('$id: category boş olamaz');
      }
    }

    for (final level in route.levels) {
      final allowedWords = <String>{
        ...level.targetWords.map(WordHuntPathEngine.normalizeWord),
        ...level.bonusWords.map(WordHuntPathEngine.normalizeWord),
      };

      final seenCardIds = <String>{};
      for (final cardId in level.infoCardIds) {
        final normalizedId = cardId.trim();
        if (normalizedId.isEmpty) {
          errors.add('${level.id}: boş bilgi kartı referansı olamaz');
          continue;
        }
        if (!seenCardIds.add(normalizedId)) {
          errors.add('${level.id}: bilgi kartı tekrarı: $normalizedId');
          continue;
        }

        final card = cardsById[normalizedId];
        if (card == null) {
          errors.add('${level.id}: bilgi kartı bulunamadı: $normalizedId');
          continue;
        }

        if (!allowedWords.contains(
          WordHuntPathEngine.normalizeWord(card.word),
        )) {
          errors.add(
            '${level.id}: bilgi kartı kelimesi bölüm hedef/bonus listesinde değil: ${card.word}',
          );
        }
      }

      for (final word in <String>[...level.targetWords, ...level.bonusWords]) {
        if (!_containsStraightWord(level.grid, word)) {
          errors.add(
            '${level.id}: kelime grid içinde düz 8 yönde bulunamadı: $word',
          );
        }
      }
    }

    return errors;
  }

  static bool _containsStraightWord(List<String> grid, String candidate) {
    if (grid.isEmpty) return false;

    final rows = grid.map((row) => row.runes.toList(growable: false)).toList();
    final width = rows.first.length;
    if (width == 0 || rows.any((row) => row.length != width)) return false;

    final word = WordHuntPathEngine.normalizeWord(candidate).runes.toList();
    if (word.isEmpty) return false;

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

    for (var startRow = 0; startRow < rows.length; startRow++) {
      for (var startColumn = 0; startColumn < width; startColumn++) {
        for (final direction in directions) {
          var matches = true;
          for (var index = 0; index < word.length; index++) {
            final row = startRow + direction.$1 * index;
            final column = startColumn + direction.$2 * index;
            if (row < 0 ||
                row >= rows.length ||
                column < 0 ||
                column >= width ||
                WordHuntPathEngine.normalizeWord(
                      String.fromCharCode(rows[row][column]),
                    ).runes.single !=
                    word[index]) {
              matches = false;
              break;
            }
          }
          if (matches) return true;
        }
      }
    }

    return false;
  }
}
