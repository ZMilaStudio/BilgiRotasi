import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kayip_sehir_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = WordHuntKayipSehirContent.kayipSehir;

  const expectedLevelNames = <String>['Kervan İzi', 'Sessiz Kumlar', 'Gömülü Cephe', 'Eski Kapı', 'Fırtına Geçidi', 'Unutulmuş Çarşı', 'Sütunlu Avlu', 'Kurumuş Sarnıç', 'Kırık Saray', 'Yeraltı Mührü'];
  const expectedLevelIds = <String>['kayip-sehir-01', 'kayip-sehir-02', 'kayip-sehir-03', 'kayip-sehir-04', 'kayip-sehir-05', 'kayip-sehir-06', 'kayip-sehir-07', 'kayip-sehir-08', 'kayip-sehir-09', 'kayip-sehir-10'];
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
      'YÜKSRKSS',
      'SÜVESOMU',
      'TİCARETN',
      'NÇAENVFA',
      'AUIZDKAM',
      'JLİZLERN',
      'LLCLERJN',
      'BUARİĞIJ',
    ],
    <String>[
      'TŞÖYEZÜY',
      'MYRURNÜA',
      'BBUÜOÜİJ',
      'KÜÖNZYKŞ',
      'IUBCYGHT',
      'ZAMYOFÂO',
      'ĞRKUNÜFR',
      'DÜOGLTUS',
    ],
    <String>[
      'EHPECÜLJ',
      'OGİDIKAU',
      'AINUTÜSS',
      'LGÇVNZBP',
      'MPDAICŞĞ',
      'IGÇRLÜTÇ',
      'FÜİRAMİM',
      'REMEKZĞU',
    ],
    <String>[
      'KTİÇEGOS',
      'AHVELİUÖ',
      'PYTLŞRİS',
      'IĞIUEİFÜ',
      'PAŞKBŞKH',
      'FMAÇPNMH',
      'ÜPLLĞGÇÇ',
      'JCUDEÜFO',
    ],
    <String>[
      'HÜŞFLISD',
      'EFIRTINA',
      'DTOIĞMLŞ',
      'EEJICURŞ',
      'FRNİSTÜK',
      'HAPURRTG',
      'KŞPHÖOUR',
      'OİEGZHIJ',
    ],
    <String>[
      'MZŞĞÜPMD',
      'ŞIHHNSTL',
      'İŞIAMEÜR',
      'BRONZRCS',
      'CAEGFACN',
      'EÇÂKUMAŞ',
      'LHHYPİRV',
      'PADYNKZM',
    ],
    <String>[
      'İJAUNSTO',
      'ŞJZAKAZÜ',
      'LAUKEÇYU',
      'EUJKRAAU',
      'MOZAİKLF',
      'EOŞVDVDH',
      'LKZEACID',
      'ICMRCIZS',
    ],
    <String>[
      'ÜVMBZRAE',
      'ÜTSKULOĞ',
      'ZPOAUBNG',
      'ÇĞÇRRYDS',
      'ZAAUTNUĞ',
      'DRRKAUIG',
      'KMFLIÇVÇ',
      'RNNHLŞİÇ',
    ],
    <String>[
      'JRFRESKG',
      'BYUTEBAM',
      'RPMYFLBİ',
      'ADOAETAN',
      'EATRRMRŞ',
      'ÇMİAMBTT',
      'DGFSAMMŞ',
      'PAİBNVAO',
    ],
    <String>[
      'ÇŞDCNJTY',
      'IŞİYESIR',
      'ÇTDNVLCA',
      'ESLNİODT',
      'MÜÇADBUH',
      'BRKFRMLA',
      'EGAEEEHN',
      'RÜHÜMSYA',
    ],
  ];
  const expectedTargets = <List<String>>[
    <String>[
      'KERVAN',
      'İZLER',
      'ROTA',
      'YÜK',
      'MENZİL',
    ],
    <String>[
      'KUM',
      'KUMUL',
      'RÜZGÂR',
      'OYMA',
      'YÜZEY',
    ],
    <String>[
      'CEPHE',
      'SÜTUN',
      'KEMER',
      'DUVAR',
      'KALINTI',
    ],
    <String>[
      'KAPI',
      'EŞİK',
      'SUR',
      'LEVHA',
      'KULE',
    ],
    <String>[
      'FIRTINA',
      'PUSULA',
      'GÖRÜŞ',
      'HEDEF',
      'SIĞINAK',
      'İŞARET',
    ],
    <String>[
      'ÇARŞI',
      'TEZGÂH',
      'TÜCCAR',
      'BRONZ',
      'KUMAŞ',
    ],
    <String>[
      'AVLU',
      'REVAK',
      'DİREK',
      'SAÇAK',
      'İŞLEME',
      'MOZAİK',
    ],
    <String>[
      'SARNIÇ',
      'ARK',
      'AKIŞ',
      'KUYU',
      'OLUK',
      'TORTU',
    ],
    <String>[
      'SARAY',
      'MOTİF',
      'KABARTMA',
      'DAMGA',
      'GALERİ',
      'MABET',
    ],
    <String>[
      'MÜHÜR',
      'SEMBOL',
      'SÜRGÜ',
      'ÇEMBER',
      'MERDİVEN',
      'YERALTI',
      'SIR',
    ],
  ];
  const expectedBonuses = <List<String>>[
    <String>[
      'TİCARET',
    ],
    <String>[
      'EROZYON',
    ],
    <String>[
      'MİMARİ',
    ],
    <String>[
      'GEÇİT',
      'GİRİŞ',
    ],
    <String>[
      'TOZ',
      'HORTUM',
    ],
    <String>[
      'SERAMİK',
    ],
    <String>[
      'YALDIZ',
    ],
    <String>[
      'KURAK',
    ],
    <String>[
      'FRESK',
      'FERMAN',
    ],
    <String>[
      'ANAHTAR',
      'İNİŞ',
    ],
  ];
  const expectedCards = <({String id, int level, String word, String title, String category, String text})>[
    (
      id: 'kayip-info-kervan',
      level: 1,
      word: 'KERVAN',
      title: 'Kervanlar',
      category: 'Tarih / Ticaret',
      text: 'Kervanlar, uzun yolculuklarda birlikte hareket eden yolcu ve yük gruplarıydı. Özellikle çöl ve ticaret yollarında toplu ilerlemek güvenlik ve taşıma açısından avantaj sağlardı.',
    ),
    (
      id: 'kayip-info-sutun',
      level: 3,
      word: 'SÜTUN',
      title: 'Sütun',
      category: 'Mimari',
      text: 'Sütunlar, tavan ve çatı gibi üst yapıların yükünü taşıyan düşey mimari elemanlardır. Büyük sütun dizileri tarihî yapılarda hem taşıyıcı görev görmüş hem de anıtsal mekânlar oluşturmuştur.',
    ),
    (
      id: 'kayip-info-revak',
      level: 7,
      word: 'REVAK',
      title: 'Revak',
      category: 'Mimari',
      text: 'Revak, genellikle bir yapıya bitişik, üstü örtülü ve önü açık galeri biçimindeki mekândır. Sütun ve kemerlerle kurulan revaklar özellikle sıcak iklimlerde gölgeli alan oluşturur.',
    ),
    (
      id: 'kayip-info-sarnic',
      level: 8,
      word: 'SARNIÇ',
      title: 'Sarnıç',
      category: 'Su Mimarisi',
      text: 'Sarnıç, suyu depolamak için yapılan su geçirmez haznedir ve yağmur suyunun biriktirilmesinde de kullanılabilir. Tarihî sarnıçların iç yüzeylerinde sızıntıyı azaltan özel sıvalara rastlanır.',
    ),
    (
      id: 'kayip-info-kabartma',
      level: 9,
      word: 'KABARTMA',
      title: 'Kabartma Sanatı',
      category: 'Arkeoloji / Sanat',
      text: 'Kabartmada figür veya desenler düz bir yüzeyden yükseliyormuş gibi işlenir ve arka zemine bağlı kalır. Çıkıntının derinliğine göre alçak ve yüksek kabartma gibi türlere ayrılır.',
    ),
    (
      id: 'kayip-info-muhur',
      level: 10,
      word: 'MÜHÜR',
      title: 'Antik Mühürler',
      category: 'Arkeoloji',
      text: 'Antik dünyada mühürler sahiplik ve kimlik belirtmek, kapları kapatmak veya belgeleri doğrulamak için kullanıldı. Mezopotamya’daki silindir mühürler kil üzerinde yuvarlanarak ayrıntılı izler bırakabiliyordu.',
    ),
  ];

  test('Kayıp Şehir route identity, metadata, level IDs/names/types are exact', () {
    expect(route.id, 'kayip-sehir');
    expect(route.title, 'Kayıp Şehir');
    expect(route.theme, 'ancientSeal');
    expect(route.routeRewardId, 'badge-kayip-sehir-kasifi');
    expect(route.unlockStarsRequired, 0);
    expect(route.levels, hasLength(10));
    expect(WordHuntKayipSehirContent.levelNames, expectedLevelNames);
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
        infoCards: WordHuntKayipSehirContent.infoCards,
      ),
      isEmpty,
    );
  });

  test('A3 six info cards and exact level mapping stay byte-for-text exact', () {
    final cards = WordHuntKayipSehirContent.infoCards;
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
    expect(l5.starRules.threeStarMaxSeconds, 35);
    expect(l5.starRules.twoStarMaxSeconds, 50);
    expect(l5.starRules.threeStarMaxMistakes, 0);
    expect(l5.starRules.twoStarMaxMistakes, 1);

    expect(l10.type, WordHuntLevelType.routeFinal);
    expect(l10.timeLimitSeconds, 120);
    expect(l10.starRules.threeStarMaxSeconds, 60);
    expect(l10.starRules.twoStarMaxSeconds, 80);
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
