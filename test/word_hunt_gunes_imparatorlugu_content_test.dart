import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gunes_imparatorlugu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kayip_sehir_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_yeralti_kralligi_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = WordHuntGunesImparatorluguContent.gunesImparatorlugu;

  const expectedLevelNames = <String>['Işık Yolu', 'Güneş Sütunları', 'Gökyüzü Avlusu', 'Yıldız Haritası', 'Ekinoks Kapısı', 'Tören Yolu', 'Büyük Tapınak', 'Altın Çarklar', 'Kraliyet Salonu', 'Güneş Tahtı'];
  const expectedLevelIds = <String>['gunes-imparatorlugu-01', 'gunes-imparatorlugu-02', 'gunes-imparatorlugu-03', 'gunes-imparatorlugu-04', 'gunes-imparatorlugu-05', 'gunes-imparatorlugu-06', 'gunes-imparatorlugu-07', 'gunes-imparatorlugu-08', 'gunes-imparatorlugu-09', 'gunes-imparatorlugu-10'];
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
      'DHMKHÖNK',
      'LKEYDMEU',
      'IÖUGFÖUL',
      'ŞATSĞKGF',
      'AUJUBJZY',
      'FUFĞİÖIO',
      'AURZLKGL',
      'KIŞINUGF',
    ],
    <String>[
      'ABOMGSCJ',
      'RJBZVÜZI',
      'YGSAATTH',
      'FÖSZDUÖC',
      'TLNMONAR',
      'DGMÜAZKE',
      'KERBİHMH',
      'ÜLYHÇÇCF',
    ],
    <String>[
      'HŞZGJDÜU',
      'İHYEOOÜZ',
      'İNHZYHZI',
      'KASENUÜD',
      'ÖDİGMIYL',
      'PYMEUPKI',
      'ŞEGNÜRÖY',
      'GMEJZGGB',
    ],
    <String>[
      'ÖPUTUKLH',
      'RNRGİÜAM',
      'TRGKJRZŞ',
      'AÖNÖİEFI',
      'KVKTZMİT',
      'ILATFLÇU',
      'MERİDYEN',
      'GGAFHIÇM',
    ],
    <String>[
      'INÇNYTDE',
      'TAYNAEEK',
      'ODAKNFIİ',
      'JÖAGSRİN',
      'ŞLEIIRIO',
      'PZNLMÇCK',
      'NJMGAZLS',
      'TARGTKUA',
    ],
    <String>[
      'ŞLYZAÜJÜ',
      'ÇBVLEOVÖ',
      'MKACNASÜ',
      'SYOEAHSJ',
      'OÇRÜŞDTZ',
      'TÖBTİÇIT',
      'TLIÜNHBM',
      'ĞYKIZILB',
    ],
    <String>[
      'TULRŞSBP',
      'AGVAAAPO',
      'PEMKSZMR',
      'IDVAETKT',
      'NİMNİRUİ',
      'AAKUKBBK',
      'KKRSMMBÖ',
      'NIYAİVEV',
    ],
    <String>[
      'VBİHIİPJ',
      'YÜKRFÜYM',
      'ÇGPRRLIİ',
      'ÇNAMAZİS',
      'IÖEEİÇLV',
      'YDJSKYŞE',
      'ĞBTAKVİM',
      'PŞJEIEDĞ',
    ],
    <String>[
      'TBNHZNTS',
      'EGAÜLTAÇ',
      'YÖDKLRNÜ',
      'İKEÜİNAL',
      'LTNMPOTS',
      'AİADÜLLP',
      'RLHAZAAÜ',
      'KAMRASSA',
    ],
    <String>[
      'HFTAHTÇU',
      'MLÇFÜGYI',
      'KEŞĞÜGÇT',
      'ÖLKNAÖUL',
      'KMERKEZI',
      'EŞLYÖSMŞ',
      'NITLAGDI',
      'KİLRİBIF',
    ],
  ];
  const expectedTargets = <List<String>>[
    <String>[
      'IŞIK',
      'YOL',
      'ŞAFAK',
      'UFUK',
      'TAŞ',
    ],
    <String>[
      'SÜTUN',
      'GÖLGE',
      'YÖN',
      'HİZA',
      'SAAT',
    ],
    <String>[
      'GÖKYÜZÜ',
      'YILDIZ',
      'GEZEGEN',
      'MEYDAN',
      'YÖRÜNGE',
    ],
    <String>[
      'HARİTA',
      'TAKIM',
      'KUTUP',
      'GÖZLEM',
      'GÖK',
    ],
    <String>[
      'EKİNOKS',
      'AYNA',
      'YANSIMA',
      'AÇI',
      'DENGE',
      'ODAK',
    ],
    <String>[
      'TÖREN',
      'ALAY',
      'KIZIL',
      'SANCAK',
      'ADIM',
    ],
    <String>[
      'TAPINAK',
      'SUNAK',
      'BASAMAK',
      'KUBBE',
      'KUTSAL',
      'PORTİK',
    ],
    <String>[
      'ÇARK',
      'TAKVİM',
      'DİŞLİ',
      'EKSEN',
      'DÖNGÜ',
      'MEVSİM',
    ],
    <String>[
      'KRALİYET',
      'ARMA',
      'SALTANAT',
      'MİRAS',
      'HÜKÜMDAR',
      'SALON',
    ],
    <String>[
      'GÜNEŞ',
      'TAHT',
      'UYGARLIK',
      'BİRLİK',
      'MERKEZ',
      'GÖRKEM',
      'KÖKEN',
    ],
  ];
  const expectedBonuses = <List<String>>[
    <String>[
      'IŞIN',
    ],
    <String>[
      'İBRE',
    ],
    <String>[
      'SİMGE',
    ],
    <String>[
      'KÜRE',
      'MERİDYEN',
    ],
    <String>[
      'PLAKA',
      'KIRILMA',
    ],
    <String>[
      'NİŞAN',
    ],
    <String>[
      'KAİDE',
    ],
    <String>[
      'ZAMAN',
    ],
    <String>[
      'HANEDAN',
      'TAÇ',
    ],
    <String>[
      'IŞILTI',
      'ALTIN',
    ],
  ];
  const expectedCards = <({String id, int level, String word, String title, String category, String text})>[
    (
      id: 'gunes-info-safak',
      level: 1,
      word: 'ŞAFAK',
      title: 'Şafak',
      category: 'Atmosfer / Astronomi',
      text: 'Şafak, Güneş henüz doğmadan önce gökyüzünün aydınlanmaya başladığı dönemdir. Güneş ufkun altında olsa bile ışığı atmosferde saçılarak gözümüze ulaşabilir.',
    ),
    (
      id: 'gunes-info-golge',
      level: 2,
      word: 'GÖLGE',
      title: 'Gölgeyle Zaman',
      category: 'Astronomi / Zaman Ölçümü',
      text: 'Güneş saatleri, Güneş’in gökyüzündeki görünür hareketi nedeniyle bir göstergenin gölgesinin gün boyunca yer değiştirmesinden yararlanır. Böylece yerel güneş zamanı ölçülebilir.',
    ),
    (
      id: 'gunes-info-yorunge',
      level: 3,
      word: 'YÖRÜNGE',
      title: 'Yörünge',
      category: 'Astronomi',
      text: 'Yörünge, bir gökcisminin başka bir cisim çevresinde izlediği düzenli yoldur. Gezegenlerin Güneş çevresindeki yörüngeleri elipstir; çoğunda bu elips daireye oldukça yakındır.',
    ),
    (
      id: 'gunes-info-ekinoks',
      level: 5,
      word: 'EKİNOKS',
      title: 'Ekinoks',
      category: 'Astronomi',
      text: 'Ekinoks, Güneş’in gökyüzündeki görünür hareketinde gök ekvatorunu geçtiği ve yılda iki kez gerçekleşen andır. Bu tarihlerde gece ve gündüz süreleri birbirine çok yaklaşır; atmosferik kırılma ve Güneş diskinin görünür boyutu nedeniyle tam olarak eşit olmayabilir.',
    ),
    (
      id: 'gunes-info-portik',
      level: 7,
      word: 'PORTİK',
      title: 'Portik',
      category: 'Mimari',
      text: 'Portik, bir yapının girişinde sütunların taşıdığı üst örtüyle oluşturulan mimari giriş bölümüdür. Antik Yunan ve Roma tapınaklarında cepheyi vurgulayan önemli bir unsur olarak kullanılmıştır.',
    ),
    (
      id: 'gunes-info-takvim',
      level: 8,
      word: 'TAKVİM',
      title: 'Gökyüzünden Takvime',
      category: 'Astronomi / Zaman',
      text: 'Takvim, zamanı gün, ay ve yıl gibi birimlere düzenleyen sistemdir. Birçok takvim Dünya’nın dönüşü, Dünya’nın Güneş çevresindeki dolanımı veya Ay’ın döngüleri gibi astronomik hareketlerden yararlanır.',
    ),
  ];

  test('Güneş İmparatorluğu route identity, metadata, level IDs/names/types are exact', () {
    expect(route.id, 'gunes-imparatorlugu');
    expect(route.title, 'Güneş İmparatorluğu');
    expect(route.theme, 'solarSeal');
    expect(route.routeRewardId, 'badge-gunes-kasifi');
    expect(route.unlockStarsRequired, 0);
    expect(route.levels, hasLength(10));
    expect(WordHuntGunesImparatorluguContent.levelNames, expectedLevelNames);
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
        infoCards: WordHuntGunesImparatorluguContent.infoCards,
      ),
      isEmpty,
    );
  });

  test('A3 six info cards and exact level mapping stay byte-for-text exact', () {
    final cards = WordHuntGunesImparatorluguContent.infoCards;
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
    expect(l10.starRules.threeStarMaxSeconds, 65);
    expect(l10.starRules.twoStarMaxSeconds, 85);
    expect(l10.starRules.threeStarMaxMistakes, 0);
    expect(l10.starRules.twoStarMaxMistakes, 2);

    for (final i in <int>[0, 1, 2, 3, 5, 6, 7, 8]) {
      expect(route.levels[i].timeLimitSeconds, isNull);
      expect(route.levels[i].starRules.threeStarMaxSeconds, isNull);
      expect(route.levels[i].starRules.twoStarMaxSeconds, isNull);
    }
  });

  test('trilogy aggregate counts and IDs stay collision-free', () {
    final trilogyRoutes = <WordHuntRouteDefinition>[
      WordHuntKayipSehirContent.kayipSehir,
      WordHuntYeraltiKralligiContent.yeraltiKralligi,
      WordHuntGunesImparatorluguContent.gunesImparatorlugu,
    ];
    final routeIds = trilogyRoutes.map((route) => route.id).toList();
    final levelIds = trilogyRoutes
        .expand((route) => route.levels)
        .map((level) => level.id)
        .toList();
    final targetUsages = trilogyRoutes
        .expand((route) => route.levels)
        .expand((level) => level.targetWords)
        .toList();
    final bonusUsages = trilogyRoutes
        .expand((route) => route.levels)
        .expand((level) => level.bonusWords)
        .toList();
    final infoCardIds = <String>[
      ...WordHuntKayipSehirContent.infoCards.map((card) => card.id),
      ...WordHuntYeraltiKralligiContent.infoCards.map((card) => card.id),
      ...WordHuntGunesImparatorluguContent.infoCards.map((card) => card.id),
    ];
    const existingRouteIds = <String>{
      'baslangic-limani',
      'gokyuzu-adalari',
      'orman-yolu',
      'orman-2',
      'kristal-vadisi',
    };

    expect(routeIds.toSet(), hasLength(3));
    expect(levelIds, hasLength(30));
    expect(levelIds.toSet(), hasLength(30));
    expect(targetUsages, hasLength(168));
    expect(bonusUsages, hasLength(42));
    expect(<String>[...targetUsages, ...bonusUsages], hasLength(210));
    expect(infoCardIds, hasLength(18));
    expect(infoCardIds.toSet(), hasLength(18));
    expect(routeIds.toSet().intersection(existingRouteIds), isEmpty);
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
