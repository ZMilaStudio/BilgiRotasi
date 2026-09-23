import 'word_hunt_models.dart';
import 'word_hunt_path.dart';

class WordHuntInputResolution {
  const WordHuntInputResolution._({required this.path, required this.result});

  const WordHuntInputResolution.ignored()
    : this._(path: const <WordHuntCell>[], result: null);

  final List<WordHuntCell> path;
  final WordHuntSelectionResult? result;

  bool get isIgnored => result == null;
}

/// Dokunma gürültüsünü oyun kurallarına ulaşmadan önce normalize eder.
///
/// Çok kısa temaslar seçim sayılmaz. Anlamlı bir düz seçim yalnızca son
/// hücresi çıkarıldığında gerçek bir hedefe dönüşüyorsa tek hücrelik taşma
/// affedilir. Böylece yakın kelime tahmini yapılmadan parmak kalınlığından
/// kaynaklanan son-harf taşmaları giderilir.
class WordHuntInputResolver {
  WordHuntInputResolver._();

  static WordHuntInputResolution resolve({
    required WordHuntLevelDefinition level,
    required List<WordHuntCell> path,
    Set<String> foundTargetWords = const <String>{},
    Set<String> foundBonusWords = const <String>{},
  }) {
    final minimumLength = <String>[...level.targetWords, ...level.bonusWords]
        .map((word) => WordHuntPathEngine.normalizeWord(word).runes.length)
        .reduce((left, right) => left < right ? left : right);

    if (path.length < minimumLength) {
      return const WordHuntInputResolution.ignored();
    }

    final originalPath = List<WordHuntCell>.unmodifiable(path);
    final originalResult = WordHuntPathEngine.evaluate(
      level: level,
      path: originalPath,
      foundTargetWords: foundTargetWords,
      foundBonusWords: foundBonusWords,
    );
    if (originalResult.kind != WordHuntSelectionKind.notAWord ||
        path.length <= minimumLength) {
      return WordHuntInputResolution._(
        path: originalPath,
        result: originalResult,
      );
    }

    final trimmedPath = List<WordHuntCell>.unmodifiable(
      path.sublist(0, path.length - 1),
    );
    final trimmedResult = WordHuntPathEngine.evaluate(
      level: level,
      path: trimmedPath,
      foundTargetWords: foundTargetWords,
      foundBonusWords: foundBonusWords,
    );
    if (trimmedResult.accepted ||
        trimmedResult.kind == WordHuntSelectionKind.alreadyFound) {
      return WordHuntInputResolution._(
        path: trimmedPath,
        result: trimmedResult,
      );
    }

    return WordHuntInputResolution._(
      path: originalPath,
      result: originalResult,
    );
  }
}
