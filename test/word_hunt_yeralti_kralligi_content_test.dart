import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_yeralti_kralligi_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = WordHuntYeraltiKralligiContent.yeraltiKralligi;

  const expectedLevelNames = <String>['Gizli İniş', 'Taş Damarlar', 'Derin Sarnıç', 'Bakır Kanallar', 'Halka Kilidi', 'Taş Mekanizma', 'Gömülü Salon', 'Anıt Odası', 'Kraliyet Hazinesi', 'Göksel Mühür'];
  const expectedLevelIds = <String>['yeralti-kralligi-01', 'yeralti-kralligi-02', 'yeralti-kralligi-03', 'yeralti-kralligi-04', 'yeralti-kralligi-05', 'yeralti-kralligi-06', 'yeralti-kralligi-07', 'yeralti-kralligi-08', 'yeralti-kralligi-09', 'yeralti-kralligi-10'];
  const expectedTypes = <WordHuntLevelType>[
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
  ];
  const expectedGrids = <List<String>>[
    <String>[
      'GJZİNİŞU',
      'YMFİRÜAJ',
      'TKRULOME',
      'UEUEBHLM',
      'DBGLGAEE',
      'CAFFŞMFD',
      'VĞEEÇOEA',
      'VSMAĞFLK',
    ],
    <String>[
      'YPÖRCİRÜ',
      'KNĞNCBÖÇ',
      'DÖSYPCŞZ',
      'ZAKTÜNEL',
      'AHMUİBBJ',
      'CLKAYAEK',
      'RODİROKK',
      'DHİTMDEK',
    ],
    <String>[
      'TBOĞAEOJ',
      'UZAZSBÇT',
      'HAÇOİACİ',
      'AKINTIGL',
      'ZANOJBHI',
      'NVRTİPFZ',
      'EAAPAYEO',
      'CSSSSZOF',
    ],
    <String>[
      'IDŞÖACBK',
      'LPPMĞNZK',
      'DAJİBUAM',
      'AÖCTUNUV',
      'DSÖEAEKU',
      'MDBLCHRD',
      'ĞYGİOOUV',
      'RIKABZTR',
    ],
    <String>[
      'SIRAKLAH',
      'YÖKYEKİİ',
      'NKİTNEÇH',
      'ŞİFREÖUH',
      'PLHIZĞMO',
      'ĞİIŞÜNÖD',
      'ITMPDBDZ',
      'IÜEHKBUU',
    ],
    <String>[
      'VOKĞRÇOC',
      'SSOAFCVJ',
      'LMLĞNHAR',
      'ĞİZIDSBD',
      'MHARAKAM',
      'VVBLŞĞYK',
      'JEJIŞRCD',
      'MRİKMEUÇ',
    ],
    <String>[
      'YİVZHĞÇİ',
      'FÇĞEMNSM',
      'RLYACMİA',
      'IEKÜRSÜZ',
      'TAEKABUL',
      'MTZRCJÇA',
      'ŞMELBMAO',
      'LMİUTGİR',
    ],
    <String>[
      'BCĞHLBYT',
      'KOTKMŞEİ',
      'PİBTARİH',
      'SUTNOYPT',
      'TIZAYCIG',
      'EGLEBNÖT',
      'ÜAYŞAEAV',
      'MEYİÜŞÜB',
    ],
    <String>[
      'GYBİLGİZ',
      'ÜKIDNASL',
      'KEÇLÖAPT',
      'HAZİNEEZ',
      'USTURLAP',
      'ORGGBJIP',
      'ŞĞEAÇBUI',
      'ALTINJEO',
    ],
    <String>[
      'GÖVŞGKPM',
      'ÜÖUĞODÜU',
      'NNKZTHAN',
      'EBASÜTEO',
      'ŞÇVREUŞK',
      'ÖUZIDLIY',
      'MBURÇAPF',
      'BİPUCUKĞ',
    ],
  ];
  const expectedTargets = <List<String>>[
    <String>[
      'İNİŞ',
      'DEHLİZ',
      'DERİN',
      'MEŞALE',
      'KADEME',
    ],
    <String>[
      'TÜNEL',
      'ŞEBEKE',
      'OYUK',
      'KAYA',
      'DAMAR',
    ],
    <String>[
      'SARNIÇ',
      'AKINTI',
      'TONOZ',
      'PAYE',
      'HAZNE',
    ],
    <String>[
      'BAKIR',
      'KANAL',
      'HAT',
      'VANA',
      'BORU',
    ],
    <String>[
      'HALKA',
      'KİLİT',
      'DÜZENEK',
      'ŞİFRE',
      'DÖNÜŞ',
      'SIRA',
    ],
    <String>[
      'KASNAK',
      'MİL',
      'KOL',
      'AĞIRLIK',
      'MİHVER',
    ],
    <String>[
      'KABUL',
      'MERASİM',
      'AMBLEM',
      'MAKAM',
      'KÜRSÜ',
      'HEYET',
    ],
    <String>[
      'ANIT',
      'KİTABE',
      'YAZIT',
      'YONTU',
      'TARİH',
      'BELGE',
    ],
    <String>[
      'HAZİNE',
      'ALTIN',
      'TABLET',
      'PERGEL',
      'USTURLAP',
      'ÖLÇEK',
    ],
    <String>[
      'GÖKSEL',
      'MÜHÜR',
      'GÜNEŞ',
      'DOĞU',
      'BURÇ',
      'KONUM',
      'YILDIZ',
    ],
  ];
  const expectedBonuses = <List<String>>[
    <String>[
      'LOŞLUK',
    ],
    <String>[
      'KORİDOR',
    ],
    <String>[
      'SAVAK',
    ],
    <String>[
      'İLETİM',
      'TURKUAZ',
    ],
    <String>[
      'ÇENTİK',
      'PİM',
    ],
    <String>[
      'MAKARA',
    ],
    <String>[
      'ELÇİ',
    ],
    <String>[
      'KAYIT',
    ],
    <String>[
      'BİLGİ',
      'SANDIK',
    ],
    <String>[
      'İPUCU',
      'KADRAN',
    ],
  ];
  const expectedCards = <({String id, int level, String word, String title, String category, String text})>[
    (
      id: 'yeralti-info-dehliz',
      level: 1,
      word: 'DEHLİZ',
      title: 'Dehliz',
      category: 'Mimari',
      text: 'Dehliz, üstü kapalı, dar ve uzun geçit anlamına gelir. Yapıların farklı bölümlerini birbirine bağlayan koridor benzeri mekânlar için kullanılabilir.',
    ),
    (
      id: 'yeralti-info-tonoz',
      level: 3,
      word: 'TONOZ',
      title: 'Tonoz',
      category: 'Mimari',
      text: 'Tonoz, bir mekânı taş veya tuğlayla kemerli biçimde örten mimari örtüdür. En basit türlerinden beşik tonoz, uzatılmış bir kemer gibi düşünülebilir.',
    ),
    (
      id: 'yeralti-info-bakir',
      level: 4,
      word: 'BAKIR',
      title: 'Bakır',
      category: 'Malzeme / Teknoloji',
      text: 'Bakır kolay şekillenen, ısıyı ve elektriği iyi ileten bir metaldir. Kalayla alaşımlandığında tarih boyunca yaygın biçimde kullanılan bronz elde edilir.',
    ),
    (
      id: 'yeralti-info-mihver',
      level: 6,
      word: 'MİHVER',
      title: 'Mihver',
      category: 'Mekanik',
      text: 'Mihver, bir cismin veya parçanın çevresinde döndüğü ekseni anlatan bir terimdir. Çark ve kasnak gibi dönen parçaların hareketini tanımlarken dönüş eksenini belirtmek için kullanılabilir.',
    ),
    (
      id: 'yeralti-info-kitabe',
      level: 8,
      word: 'KİTABE',
      title: 'Kitabeler',
      category: 'Arkeoloji / Epigrafi',
      text: 'Kitabeler, taş veya metal gibi dayanıklı yüzeylere yazılmış tarihî yazıtlardır. Adlar, tarihler, unvanlar ve olaylar hakkında bilgi taşıdıkları için tarih araştırmalarında önemli kaynaklardır.',
    ),
    (
      id: 'yeralti-info-usturlap',
      level: 9,
      word: 'USTURLAP',
      title: 'Usturlap',
      category: 'Astronomi / Teknoloji',
      text: 'Usturlap, gökyüzünü düzlem üzerinde modelleyen tarihî bir astronomi aracıdır. Güneş ve yıldızların konumlarından yararlanarak zaman, yön ve göksel ölçümlerle ilgili hesaplar yapılabilir.',
    ),
  ];

  test('Yeraltı Krallığı route identity, metadata, level IDs/names/types are exact', () {
    expect(route.id, 'yeralti-kralligi');
    expect(route.title, 'Yeraltı Krallığı');
    expect(route.theme, 'mechanicalSeal');
    expect(route.routeRewardId, 'badge-yeralti-kasifi');
    expect(route.unlockStarsRequired, 0);
    expect(route.levels, hasLength(10));
    expect(WordHuntYeraltiKralligiContent.levelNames, expectedLevelNames);
    expect(route.levels.map((level) => level.id).toList(), expectedLevelIds);
    expect(route.levels.map((level) => level.type).toList(), expectedTypes);
  });

  test('A6 literal grids and authoritative TARGET/BONUS row order stay exact', () {
    for (var i = 0; i < route.levels.length; i++) {
      final level = route.levels[i];
      expect(level.grid, expectedGrids[i], reason: level.id);
      expect(level.targetWords, expectedTargets[i], reason: level.id);
      expect(level.bonusWords, expectedBonuses[i], reason: level.id);
      expect(level.grid, hasLength(8), reason: level.id);
      expect(
        level.grid.every((row) => row.runes.length == 8),
        isTrue,
        reason: level.id,
      );
    }
  });

  test('56 TARGET + 14 BONUS + exact-one physical occurrence stay locked', () {
    final targets = route.levels.expand((level) => level.targetWords).toList();
    final bonuses = route.levels.expand((level) => level.bonusWords).toList();

    expect(targets, hasLength(56));
    expect(bonuses, hasLength(14));
    expect(<String>[...targets, ...bonuses], hasLength(70));

    for (final level in route.levels) {
      for (final word in <String>[...level.targetWords, ...level.bonusWords]) {
        expect(
          _physicalOccurrences(level.grid, word),
          1,
          reason: '${level.id}: $word',
        );
      }
    }

    expect(
      WordHuntContentValidator.validate(
        route: route,
        infoCards: WordHuntYeraltiKralligiContent.infoCards,
      ),
      isEmpty,
    );
  });

  test('A3 six info cards and exact level mapping stay byte-for-text exact', () {
    final cards = WordHuntYeraltiKralligiContent.infoCards;
    expect(cards, hasLength(6));

    for (var i = 0; i < expectedCards.length; i++) {
      final expected = expectedCards[i];
      final actual = cards[i];
      expect(actual.id, expected.id);
      expect(actual.word, expected.word);
      expect(actual.title, expected.title);
      expect(actual.category, expected.category);
      expect(actual.shortFact, expected.text);
    }

    for (var level = 1; level <= 10; level++) {
      final ids = expectedCards
          .where((card) => card.level == level)
          .map((card) => card.id)
          .toList();
      expect(route.levels[level - 1].infoCardIds, ids);
    }

    for (final card in expectedCards) {
      final level = route.levels[card.level - 1];
      expect(
        <String>[...level.targetWords, ...level.bonusWords],
        contains(card.word),
        reason: card.id,
      );
    }
  });

  test('A7 L5/L10 timing and star thresholds are exact', () {
    final l5 = route.levels[4];
    final l10 = route.levels[9];

    expect(l5.type, WordHuntLevelType.challenge);
    expect(l5.timeLimitSeconds, 60);
    expect(l5.starRules.threeStarMaxSeconds, 30);
    expect(l5.starRules.twoStarMaxSeconds, 45);
    expect(l5.starRules.threeStarMaxMistakes, 0);
    expect(l5.starRules.twoStarMaxMistakes, 1);

    expect(l10.type, WordHuntLevelType.routeFinal);
    expect(l10.timeLimitSeconds, 120);
    expect(l10.starRules.threeStarMaxSeconds, 55);
    expect(l10.starRules.twoStarMaxSeconds, 75);
    expect(l10.starRules.threeStarMaxMistakes, 0);
    expect(l10.starRules.twoStarMaxMistakes, 2);

    for (final i in <int>[0, 1, 2, 3, 5, 6, 7, 8]) {
      expect(route.levels[i].timeLimitSeconds, isNull);
      expect(route.levels[i].starRules.threeStarMaxSeconds, isNull);
      expect(route.levels[i].starRules.twoStarMaxSeconds, isNull);
    }
  });
}

int _physicalOccurrences(List<String> grid, String candidate) {
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
  final physical = <String>{};

  for (var r = 0; r < rows.length; r++) {
    for (var c = 0; c < rows[r].length; c++) {
      for (final d in directions) {
        final cells = <(int, int)>[];
        var ok = true;
        for (var i = 0; i < word.length; i++) {
          final rr = r + d.$1 * i;
          final cc = c + d.$2 * i;
          if (rr < 0 ||
              rr >= rows.length ||
              cc < 0 ||
              cc >= rows[rr].length) {
            ok = false;
            break;
          }
          final cell = WordHuntPathEngine.normalizeWord(
            String.fromCharCode(rows[rr][cc]),
          ).runes.single;
          if (cell != word[i]) {
            ok = false;
            break;
          }
          cells.add((rr, cc));
        }
        if (ok) {
          final canonical = cells.map((cell) => '${cell.$1}:${cell.$2}').toList()
            ..sort();
          physical.add(canonical.join('|'));
        }
      }
    }
  }
  return physical.length;
}
