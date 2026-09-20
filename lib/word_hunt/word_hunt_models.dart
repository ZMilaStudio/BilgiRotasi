enum WordHuntLevelType { normal, challenge, bonus, routeFinal }

class WordHuntInfoCard {
  const WordHuntInfoCard({
    required this.id,
    required this.word,
    required this.title,
    required this.shortFact,
    required this.category,
  });

  final String id;
  final String word;
  final String title;
  final String shortFact;
  final String category;
}

class WordHuntStarRules {
  const WordHuntStarRules({
    this.twoStarMaxMistakes,
    this.threeStarMaxMistakes,
    this.twoStarMaxSeconds,
    this.threeStarMaxSeconds,
  });

  final int? twoStarMaxMistakes;
  final int? threeStarMaxMistakes;
  final int? twoStarMaxSeconds;
  final int? threeStarMaxSeconds;
}

class WordHuntLevelDefinition {
  const WordHuntLevelDefinition({
    required this.id,
    required this.routeId,
    required this.index,
    required this.type,
    required this.grid,
    required this.targetWords,
    required this.starRules,
    this.displayName,
    this.bonusWords = const <String>[],
    this.infoCardIds = const <String>[],
    this.timeLimitSeconds,
  });

  final String id;
  final String routeId;
  final int index;
  final WordHuntLevelType type;
  final List<String> grid;
  final List<String> targetWords;
  final List<String> bonusWords;
  final WordHuntStarRules starRules;
  final String? displayName;
  final List<String> infoCardIds;
  final int? timeLimitSeconds;

  int get rowCount => grid.length;

  int get columnCount => grid.isEmpty ? 0 : grid.first.runes.length;

  String get displayNameOrFallback {
    final explicitName = displayName?.trim();
    if (explicitName == null || explicitName.isEmpty) {
      return 'Bölüm $index';
    }
    return explicitName;
  }
}

class WordHuntSegmentDefinition {
  const WordHuntSegmentDefinition({
    required this.id,
    required this.index,
    required this.displayName,
    required this.startLevelIndex,
    required this.endLevelIndex,
  });

  final String id;
  final int index;
  final String displayName;
  final int startLevelIndex;
  final int endLevelIndex;

  int get levelCount => endLevelIndex - startLevelIndex + 1;
}

class WordHuntRouteDefinition {
  const WordHuntRouteDefinition({
    required this.id,
    required this.title,
    required this.theme,
    required this.unlockStarsRequired,
    required this.levels,
    required this.routeRewardId,
    this.segments = const <WordHuntSegmentDefinition>[],
  });

  final String id;
  final String title;
  final String theme;
  final int unlockStarsRequired;
  final List<WordHuntLevelDefinition> levels;
  final String routeRewardId;
  final List<WordHuntSegmentDefinition> segments;

  int get maximumStars => levels.length * 3;
}

class WordHuntDefinitionValidator {
  WordHuntDefinitionValidator._();

  static List<String> validateLevel(WordHuntLevelDefinition level) {
    final errors = <String>[];

    if (level.id.trim().isEmpty) {
      errors.add('level.id boş olamaz');
    }
    if (level.routeId.trim().isEmpty) {
      errors.add('level.routeId boş olamaz');
    }
    if (level.index < 1) {
      errors.add('level.index 1 veya daha büyük olmalı');
    }
    if (level.displayName != null && level.displayName!.trim().isEmpty) {
      errors.add('level.displayName trim sonrası boş olamaz');
    }
    if (level.grid.isEmpty) {
      errors.add('grid boş olamaz');
    } else {
      final width = level.grid.first.runes.length;
      if (width == 0) {
        errors.add('grid satırları boş olamaz');
      }
      for (var rowIndex = 0; rowIndex < level.grid.length; rowIndex++) {
        final row = level.grid[rowIndex];
        if (row.runes.length != width) {
          errors.add('grid dikdörtgen olmalı: satır ${rowIndex + 1}');
        }
      }
    }

    final normalizedTargets = <String>{};
    for (final word in level.targetWords) {
      final normalized = word.trim();
      if (normalized.isEmpty) {
        errors.add('targetWords boş kelime içeremez');
        continue;
      }
      if (normalized.runes.length < 3) {
        errors.add('targetWords en az 3 harf olmalı: $normalized');
      }
      if (!normalizedTargets.add(normalized)) {
        errors.add('targetWords tekrar içeremez: $normalized');
      }
    }
    if (normalizedTargets.isEmpty) {
      errors.add('en az bir hedef kelime olmalı');
    }

    final normalizedBonus = <String>{};
    for (final word in level.bonusWords) {
      final normalized = word.trim();
      if (normalized.isEmpty) {
        errors.add('bonusWords boş kelime içeremez');
        continue;
      }
      if (normalized.runes.length < 3) {
        errors.add('bonusWords en az 3 harf olmalı: $normalized');
      }
      if (!normalizedBonus.add(normalized)) {
        errors.add('bonusWords tekrar içeremez: $normalized');
      }
      if (normalizedTargets.contains(normalized)) {
        errors.add('hedef ve bonus kelime çakışamaz: $normalized');
      }
    }

    if (level.timeLimitSeconds != null && level.timeLimitSeconds! <= 0) {
      errors.add('timeLimitSeconds pozitif olmalı');
    }

    final rules = level.starRules;
    for (final value in <int?>[
      rules.twoStarMaxMistakes,
      rules.threeStarMaxMistakes,
      rules.twoStarMaxSeconds,
      rules.threeStarMaxSeconds,
    ]) {
      if (value != null && value < 0) {
        errors.add('yıldız hedefleri negatif olamaz');
        break;
      }
    }

    if (rules.twoStarMaxMistakes != null &&
        rules.threeStarMaxMistakes != null &&
        rules.threeStarMaxMistakes! > rules.twoStarMaxMistakes!) {
      errors.add('3 yıldız hata hedefi 2 yıldızdan daha gevşek olamaz');
    }

    if (rules.twoStarMaxSeconds != null &&
        rules.threeStarMaxSeconds != null &&
        rules.threeStarMaxSeconds! > rules.twoStarMaxSeconds!) {
      errors.add('3 yıldız süre hedefi 2 yıldızdan daha gevşek olamaz');
    }

    return errors;
  }

  static List<String> validateRoute(WordHuntRouteDefinition route) {
    final errors = <String>[];

    if (route.id.trim().isEmpty) {
      errors.add('route.id boş olamaz');
    }
    if (route.title.trim().isEmpty) {
      errors.add('route.title boş olamaz');
    }
    if (route.theme.trim().isEmpty) {
      errors.add('route.theme boş olamaz');
    }
    if (route.routeRewardId.trim().isEmpty) {
      errors.add('routeRewardId boş olamaz');
    }
    if (route.levels.isEmpty) {
      errors.add('route en az bir bölüm içermeli');
      return errors;
    }

    if (route.unlockStarsRequired < 0 ||
        route.unlockStarsRequired > route.maximumStars) {
      errors.add('unlockStarsRequired rota yıldız aralığında olmalı');
    }

    final levelIds = <String>{};
    for (var i = 0; i < route.levels.length; i++) {
      final level = route.levels[i];
      if (level.routeId != route.id) {
        errors.add('bölüm rota kimliği eşleşmiyor: ${level.id}');
      }
      if (level.index != i + 1) {
        errors.add('bölüm indeksleri 1..N sıralı olmalı: ${level.id}');
      }
      if (!levelIds.add(level.id)) {
        errors.add('bölüm kimliği tekrar ediyor: ${level.id}');
      }
      errors.addAll(validateLevel(level).map((error) => '${level.id}: $error'));
    }

    if (route.levels.last.type != WordHuntLevelType.routeFinal) {
      errors.add('rotanın son bölümü rota finali olmalı');
    }

    _validateSegments(route, errors);

    return errors;
  }

  static void _validateSegments(
    WordHuntRouteDefinition route,
    List<String> errors,
  ) {
    if (route.segments.isEmpty) {
      return;
    }

    final segmentIds = <String>{};
    final segmentIndexes = <int>{};
    var expectedStart = 1;

    for (var offset = 0; offset < route.segments.length; offset++) {
      final segment = route.segments[offset];
      final label = segment.id.trim().isEmpty ? '#${offset + 1}' : segment.id;

      if (segment.id.trim().isEmpty) {
        errors.add('segment.id boş olamaz');
      } else if (!segmentIds.add(segment.id)) {
        errors.add('segment.id tekrar ediyor: ${segment.id}');
      }

      if (segment.displayName.trim().isEmpty) {
        errors.add('$label: segment.displayName boş olamaz');
      }

      if (!segmentIndexes.add(segment.index)) {
        errors.add('segment.index tekrar ediyor: ${segment.index}');
      }
      if (segment.index != offset + 1) {
        errors.add('$label: segment.index 1..N sıralı olmalı');
      }

      if (segment.startLevelIndex < 1 || segment.endLevelIndex < 1) {
        errors.add('$label: segment aralığı 1 veya daha büyük olmalı');
      }
      if (segment.startLevelIndex > segment.endLevelIndex) {
        errors.add('$label: segment başlangıcı bitişten büyük olamaz');
      }
      if (segment.endLevelIndex > route.levels.length) {
        errors.add('$label: segment rota bölüm sınırını aşamaz');
      }

      if (segment.startLevelIndex != expectedStart) {
        if (segment.startLevelIndex < expectedStart) {
          errors.add('$label: segment aralıkları çakışamaz');
        } else {
          errors.add('$label: segment aralıklarında boşluk olamaz');
        }
      }

      expectedStart = segment.endLevelIndex + 1;
    }

    if (expectedStart != route.levels.length + 1) {
      errors.add('segment aralıkları tüm rota bölümlerini kapsamalı');
    }

    if (route.levels.length == 100) {
      if (route.segments.length != 10) {
        errors.add('100 bölümlük 2.0 rota tam olarak 10 segment içermeli');
      }

      for (var offset = 0; offset < route.segments.length; offset++) {
        final segment = route.segments[offset];
        final expectedIndex = offset + 1;
        final expectedSegmentStart = offset * 10 + 1;
        final expectedSegmentEnd = expectedSegmentStart + 9;

        if (segment.index != expectedIndex ||
            segment.startLevelIndex != expectedSegmentStart ||
            segment.endLevelIndex != expectedSegmentEnd ||
            segment.levelCount != 10) {
          errors.add(
            '${segment.id}: 100 bölümlük 2.0 rotada segment '
            '$expectedIndex aralığı $expectedSegmentStart-$expectedSegmentEnd olmalı',
          );
        }
      }
    }
  }
}
