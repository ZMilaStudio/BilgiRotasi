import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const route = WordHuntOrmanContent.ormanYolu;

  const originalL1ToL7Grids = <List<String>>[
    <String>['ŞDKÇLŞVU', 'UÖAASYIÜ', 'KŞDĞREİU', 'EBİASPĞR', 'AİHORMAN', 'ÖUMNHLVY', 'ŞEİGGDHÇ', 'IZVBLYİÇ'],
    <String>['HÇEUHJÖO', 'İŞGKÖKNM', 'EÖUTVÜJL', 'İŞŞOÜUİN', 'JKERSARB', 'VNDMİİYU', 'NVAAZZRN', 'UÇKNİÖUS'],
    <String>['COSTKİÜS', 'ÜÖĞOEÜOZ', 'OUİPÇFVİ', 'GYARÇISŞ', 'JÖĞAVUYM', 'HKLKĞLEP', 'ADUGUŞMF', 'VNÇCEŞTĞ'],
    <String>['OZDERETR', 'ĞIGBAZOK', 'VİAÜTEPT', 'SGİUNGRU', 'SKOZALAK', 'ZÖKLMÖKÜ', 'ĞYDVIGĞĞ', 'RHJTOĞŞJ'],
    <String>['SSMIOAOH', 'DEREPŞKE', 'LBAFYGOF', 'ZKLKÇÖZM', 'OLTAİKAL', 'ÖİOSÇTLO', 'LÖYMEUAC', 'VÖŞĞKPKP'],
    <String>['ZSÜCNDHO', 'RAÖMNCTO', 'KOGKPLLZ', 'UKAYANEİ', 'JÜERCOÜI', 'TFDÇNETI', 'IGEYİKAD', 'DVHŞSÇJF'],
    <String>['GEYİKENŞ', 'ÇPACNİST', 'VGPVSÜİS', 'TDRÇTOYL', 'AYADJMFP', 'CĞKLĞYYC', 'ATÜVEDÖM', 'ÇİHNNEĞD'],
  ];
  const originalL1ToL7Targets = <List<String>>[
    <String>['AĞAÇ', 'YAPRAK', 'DAL', 'KÖK', 'ORMAN'],
    <String>['KÖK', 'ORMAN', 'ÇAM', 'MEŞE', 'KUŞ'],
    <String>['MEŞE', 'KUŞ', 'YUVA', 'TOPRAK'],
    <String>['TOPRAK', 'GÖLGE', 'MANTAR', 'KOZALAK', 'DERE'],
    <String>['KOZALAK', 'DERE', 'PATİKA', 'ÇİÇEK', 'OTLAR'],
    <String>['ÇİÇEK', 'OTLAR', 'KAYA', 'SİNCAP'],
    <String>['SİNCAP', 'GEYİK', 'AĞAÇ', 'YAPRAK', 'DAL'],
  ];
  const originalL1ToL7Bonus = <List<String>>[
    <String>[],
    <String>[],
    <String>['GÖLGE'],
    <String>[],
    <String>[],
    <String>['GEYİK'],
    <String>[],
  ];
  const originalL1ToL7Types = <WordHuntLevelType>[
    WordHuntLevelType.normal,
    WordHuntLevelType.normal,
    WordHuntLevelType.normal,
    WordHuntLevelType.normal,
    WordHuntLevelType.challenge,
    WordHuntLevelType.normal,
    WordHuntLevelType.normal,
  ];
  const originalL1ToL7Times = <int?>[null, null, null, null, 60, null, null];

  const oldL8ToL10Grids = <List<String>>[
    <String>['KNZGTŞĞR', 'BPVVIUNM', 'FRFÜKÖKÇ', 'TZODPAAR', 'HÖHNAMRO', 'ĞCMÖLÖPD', 'ĞRJOTYAT', 'KBİIİLYF'],
    <String>['RÜTAĞCÜĞ', 'ZŞFJBADA', 'BĞDĞZĞÜI', 'IPİİNÇYU', 'İPYEMİHK', 'ZKUŞTÇIT', 'ÜHVEANEC', 'ÖNAMROKÇ'],
    <String>['FKUEGLÖG', 'FŞÜVJMÖH', 'ZNİÖAŞİR', 'ÜÖTNFKUC', 'FMTOPRAK', 'VAVUYTDS', 'RŞOİZBRP', 'ZYOKÜÇSI'],
  ];

  test('Orman Yolu technical identity and 10-level contract stay stable', () {
    expect(route.id, 'orman-yolu');
    expect(route.title, 'Orman Yolu');
    expect(route.theme, 'orman');
    expect(route.routeRewardId, 'reward-orman-yolu');
    expect(route.levels, hasLength(10));

    expect(
      route.levels.map((level) => level.id).toList(),
      <String>[
        'orman-yolu-01',
        'orman-yolu-02',
        'orman-yolu-03',
        'orman-yolu-04',
        'orman-yolu-05',
        'orman-yolu-06',
        'orman-yolu-07',
        'orman-yolu-08',
        'orman-yolu-09',
        'orman-yolu-10',
      ],
    );
    expect(
      route.levels.map((level) => level.index).toList(),
      <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    );
    expect(
      route.levels.map((level) => level.type).toList(),
      <WordHuntLevelType>[
        WordHuntLevelType.normal,
        WordHuntLevelType.normal,
        WordHuntLevelType.normal,
        WordHuntLevelType.normal,
        WordHuntLevelType.challenge,
        WordHuntLevelType.normal,
        WordHuntLevelType.normal,
        WordHuntLevelType.normal,
        WordHuntLevelType.normal,
        WordHuntLevelType.routeFinal,
      ],
    );
  });

  test('definition and content validators accept polished Orman Yolu', () {
    expect(WordHuntDefinitionValidator.validateRoute(route), isEmpty);
    expect(
      WordHuntContentValidator.validate(
        route: route,
        infoCards: WordHuntOrmanContent.infoCards,
      ),
      isEmpty,
    );
  });

  test('L1-L7 gameplay payload remains unchanged except approved L5 balance', () {
    for (var index = 0; index < 7; index++) {
      final level = route.levels[index];
      expect(level.grid, originalL1ToL7Grids[index], reason: level.id);
      expect(level.targetWords, originalL1ToL7Targets[index], reason: level.id);
      expect(level.bonusWords, originalL1ToL7Bonus[index], reason: level.id);
      expect(level.type, originalL1ToL7Types[index], reason: level.id);
      expect(level.timeLimitSeconds, originalL1ToL7Times[index], reason: level.id);
      expect(level.starRules.threeStarMaxMistakes, 0, reason: level.id);
      if (index == 4) {
        expect(level.starRules.twoStarMaxMistakes, 1, reason: level.id);
        expect(level.starRules.twoStarMaxSeconds, 36, reason: level.id);
        expect(level.starRules.threeStarMaxSeconds, 25, reason: level.id);
      } else {
        expect(level.starRules.twoStarMaxMistakes, 2, reason: level.id);
        expect(level.starRules.twoStarMaxSeconds, isNull, reason: level.id);
        expect(level.starRules.threeStarMaxSeconds, isNull, reason: level.id);
      }
    }
  });

  test('L5 challenge and L10 route final progressive balance is exact', () {
    final l5 = route.levels[4];
    final l10 = route.levels[9];

    expect(l5.type, WordHuntLevelType.challenge);
    expect(l5.timeLimitSeconds, 60);
    expect(l5.starRules.twoStarMaxMistakes, 1);
    expect(l5.starRules.threeStarMaxMistakes, 0);
    expect(l5.starRules.twoStarMaxSeconds, 36);
    expect(l5.starRules.threeStarMaxSeconds, 25);

    expect(l10.type, WordHuntLevelType.routeFinal);
    expect(l10.timeLimitSeconds, 120);
    expect(l10.starRules.twoStarMaxMistakes, 2);
    expect(l10.starRules.threeStarMaxMistakes, 0);
    expect(l10.starRules.twoStarMaxSeconds, 66);
    expect(l10.starRules.threeStarMaxSeconds, 50);
  });

  test('Orman Yolu owns six exact Doğa info cards', () {
    final cards = WordHuntOrmanContent.infoCards;
    expect(cards, hasLength(6));
    expect(cards.map((card) => card.id).toSet(), hasLength(6));
    expect(cards.every((card) => card.category == 'Doğa'), isTrue);

    final byId = <String, WordHuntInfoCard>{for (final card in cards) card.id: card};

    void expectCard(String id, String word, String title, String shortFact) {
      final card = byId[id];
      expect(card, isNotNull);
      expect(card!.word, word);
      expect(card.title, title);
      expect(card.shortFact, shortFact);
      expect(card.category, 'Doğa');
    }

    expectCard(
      'orman-info-agac',
      'AĞAÇ',
      'Ağaç',
      'Ağaçların kökleri su ve mineralleri alırken gövdeleri yaprakları ışığa doğru taşır.',
    );
    expectCard(
      'orman-info-mese',
      'MEŞE',
      'Meşe',
      'Meşe ağaçlarının meyvesine palamut denir; palamutlar birçok orman canlısı için besin olabilir.',
    );
    expectCard(
      'orman-info-mantar',
      'MANTAR',
      'Mantar',
      'Mantarlar bitki değildir; birçok mantar, ormandaki organik maddelerin parçalanmasına katkı sağlar.',
    );
    expectCard(
      'orman-info-kozalak',
      'KOZALAK',
      'Kozalak',
      'Çam gibi bazı iğne yapraklı ağaçların tohumları kozalakların pulları arasında gelişir.',
    );
    expectCard(
      'orman-info-sincap',
      'SİNCAP',
      'Sincap',
      'Sincaplar bazı tohum ve yemişleri saklar; unutulanların bir kısmı yeni bitkilere dönüşebilir.',
    );
    expectCard(
      'orman-info-geyik',
      'GEYİK',
      'Geyik',
      'Geyikler ot, yaprak ve sürgünlerle beslenen otçul memelilerdir.',
    );
  });

  test('info card mapping is exact and other levels stay empty', () {
    expect(route.levels[0].infoCardIds, <String>['orman-info-agac']);
    expect(route.levels[1].infoCardIds, <String>['orman-info-mese']);
    expect(route.levels[2].infoCardIds, isEmpty);
    expect(route.levels[3].infoCardIds, <String>['orman-info-mantar']);
    expect(route.levels[4].infoCardIds, <String>['orman-info-kozalak']);
    expect(route.levels[5].infoCardIds, <String>['orman-info-sincap']);
    expect(route.levels[6].infoCardIds, <String>['orman-info-geyik']);
    expect(route.levels[7].infoCardIds, isEmpty);
    expect(route.levels[8].infoCardIds, isEmpty);
    expect(route.levels[9].infoCardIds, isEmpty);
  });

  test('L8 L9 L10 use exact polished target and bonus contracts', () {
    expect(
      route.levels[7].targetWords,
      <String>['YAĞMUR', 'ÇAMUR', 'DAMLA', 'DERE', 'PATİKA'],
    );
    expect(route.levels[7].bonusWords, <String>['ISLAK']);

    expect(
      route.levels[8].targetWords,
      <String>['İZLER', 'TÜY', 'TOYNAK', 'YEMİŞ', 'OYUK'],
    );
    expect(route.levels[8].bonusWords, <String>['KABUK']);

    expect(
      route.levels[9].targetWords,
      <String>['ORMAN', 'KEŞİF', 'YOLCULUK', 'CANLI', 'DOĞA', 'UYUM'],
    );
    expect(route.levels[9].bonusWords, <String>['MACERA']);
  });

  test('L8 L9 L10 grids are new and mutually distinct', () {
    final newGrids = route.levels
        .skip(7)
        .map((level) => level.grid.join('\n'))
        .toList(growable: false);

    expect(newGrids.toSet(), hasLength(3));
    for (var index = 0; index < 3; index++) {
      expect(
        route.levels[index + 7].grid,
        isNot(equals(oldL8ToL10Grids[index])),
      );
    }

    expect(
      route.levels.skip(7).map((level) => level.targetWords.join('|')).toSet(),
      hasLength(3),
    );
  });

  test('all target and bonus words are valid and have no overlap', () {
    for (final level in route.levels) {
      expect(
        level.targetWords.toSet().intersection(level.bonusWords.toSet()),
        isEmpty,
        reason: level.id,
      );

      for (final word in <String>[...level.targetWords, ...level.bonusWords]) {
        expect(
          _physicalOccurrenceCount(level.grid, word),
          1,
          reason: '${level.id} / $word',
        );
      }
    }
  });

  test('progression remains strictly 7 to 8 to 9 to 10', () {
    var progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (var index = 1; index <= 7; index++)
          'orman-yolu-${index.toString().padLeft(2, '0')}': 1,
      },
    );

    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 8), isTrue);
    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 9), isFalse);
    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10), isFalse);

    progress = progress.recordLevelResult(levelId: 'orman-yolu-08', stars: 1);
    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 9), isTrue);
    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10), isFalse);

    progress = progress.recordLevelResult(levelId: 'orman-yolu-09', stars: 1);
    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10), isTrue);
  });

  test('Kadim Orman prerequisite still depends only on Orman Yolu completion', () {
    final entry = WordHuntRouteCatalog.orman2Pilot;
    expect(entry.unlockRule.kind, WordHuntRouteUnlockKind.routeComplete);
    expect(entry.unlockRule.prerequisiteRoute?.id, route.id);
    expect(entry.isUnlocked(const WordHuntProgressSnapshot()), isFalse);

    final finalLevel = route.levels.last;
    final completed = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{finalLevel.id: 1},
    );
    expect(entry.isUnlocked(completed), isTrue);
    expect(entry.unlockRule.requiredStars, 0);
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
