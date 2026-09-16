import 'word_hunt_models.dart';

/// Kadim Orman'ın production gameplay içeriği.
///
/// Teknik route/progression identity pilot döneminden korunur; grid, hedef,
/// bonus ve bilgi kartı içeriği bu dosyada özgün ve statik olarak tanımlıdır.
abstract final class WordHuntOrman2Content {
  static const List<WordHuntInfoCard> infoCards = <WordHuntInfoCard>[
    WordHuntInfoCard(
      id: 'kadim-info-egrelti',
      word: 'EĞRELTİ',
      title: 'Eğrelti',
      shortFact:
          'Eğreltiler çiçek ve tohum oluşturmak yerine sporlarla çoğalan damarlı bitkilerdir.',
      category: 'Doğa',
    ),
    WordHuntInfoCard(
      id: 'kadim-info-sis',
      word: 'SİS',
      title: 'Sis',
      shortFact:
          'Sis, yere yakın havada asılı duran çok küçük su damlacıkları veya uygun koşullarda buz kristallerinden oluşur.',
      category: 'Doğa',
    ),
    WordHuntInfoCard(
      id: 'kadim-info-misel',
      word: 'MİSEL',
      title: 'Misel',
      shortFact:
          'Misel, mantarın çoğu zaman gözden uzakta kalan ince ipliksi yapılardan oluşan ağıdır.',
      category: 'Doğa',
    ),
    WordHuntInfoCard(
      id: 'kadim-info-baykus',
      word: 'BAYKUŞ',
      title: 'Baykuş',
      shortFact:
          'Birçok baykuş türü, düşük ışıkta avlanmaya yardımcı olan görme ve işitme uyumlarına sahiptir.',
      category: 'Doğa',
    ),
    WordHuntInfoCard(
      id: 'kadim-info-kaynak',
      word: 'KAYNAK',
      title: 'Kaynak',
      shortFact: 'Kaynak, yer altı suyunun doğal olarak yeryüzüne çıktığı yerdir.',
      category: 'Doğa',
    ),
    WordHuntInfoCard(
      id: 'kadim-info-cinar',
      word: 'ÇINAR',
      title: 'Çınar',
      shortFact:
          'Çınarlar uzun yıllar yaşayabilir; gövdelerindeki büyüme halkaları geçmiş büyüme hakkında bilgi verebilir.',
      category: 'Doğa',
    ),
  ];

  static const WordHuntRouteDefinition orman2 = WordHuntRouteDefinition(
    id: 'orman-2',
    title: 'Kadim Orman',
    theme: 'orman',
    unlockStarsRequired: 0,
    routeRewardId: 'reward-orman-2',
    levels: <WordHuntLevelDefinition>[
      // 1. KÖKLERİN KAPISI
      WordHuntLevelDefinition(
        id: 'orman-2-01',
        routeId: 'orman-2',
        index: 1,
        type: WordHuntLevelType.normal,
        grid: <String>[
          'JKIAJTFB',
          'İIDRDAOZ',
          'TŞŞTIKZK',
          'LAYOSUNO',
          'EMVLTBÜB',
          'RRBĞAAUR',
          'ĞABÖİKĞİ',
          'ESHMVÇOŞ',
        ],
        targetWords: <String>['YOSUN', 'KABUK', 'SARMAŞIK', 'EĞRELTİ', 'ÇİĞ'],
        infoCardIds: <String>['kadim-info-egrelti'],
        starRules: WordHuntStarRules(
          twoStarMaxMistakes: 2,
          threeStarMaxMistakes: 0,
        ),
      ),
      // 2. SİS KORİDORU
      WordHuntLevelDefinition(
        id: 'orman-2-02',
        routeId: 'orman-2',
        index: 2,
        type: WordHuntLevelType.normal,
        grid: <String>[
          'GYGNİRES',
          'ÜGSHUĞİB',
          'OTTBÜSUP',
          'ÇMMYCDYC',
          'KYPIASAĞ',
          'IAŞMENHN',
          'UÇLTUHKT',
          'İAİABRHI',
        ],
        targetWords: <String>['SİS', 'PUS', 'NEM', 'SERİN', 'DAMLA'],
        bonusWords: <String>['YANKI'],
        infoCardIds: <String>['kadim-info-sis'],
        starRules: WordHuntStarRules(
          twoStarMaxMistakes: 2,
          threeStarMaxMistakes: 0,
        ),
      ),
      // 3. ESKİ KÖPRÜ
      WordHuntLevelDefinition(
        id: 'orman-2-03',
        routeId: 'orman-2',
        index: 3,
        type: WordHuntLevelType.normal,
        grid: <String>[
          'IVÇĞÜCUG',
          'TOVRÜUEL',
          'NAPRIÇAU',
          'IÖHSİVİÇ',
          'KÖATSCHD',
          'AGLLAONÜ',
          'MRAVDCNG',
          'MBTÜMÖRL',
        ],
        targetWords: <String>['KÖPRÜ', 'TAHTA', 'HALAT', 'GEÇİT', 'ÇİVİ'],
        bonusWords: <String>['AKINTI'],
        starRules: WordHuntStarRules(
          twoStarMaxMistakes: 2,
          threeStarMaxMistakes: 0,
        ),
      ),
      // 4. MANTAR ÇEMBERİ
      WordHuntLevelDefinition(
        id: 'orman-2-04',
        routeId: 'orman-2',
        index: 4,
        type: WordHuntLevelType.normal,
        grid: <String>[
          'ÖÖDADİHO',
          'IOĞIĞOHB',
          'MTUHJJLŞ',
          'ÖSMANTAR',
          'İHİLFPĞO',
          'PCSKKGAP',
          'RCEAELÖS',
          'ŞOLÖCTFÇ',
        ],
        targetWords: <String>['MANTAR', 'MİSEL', 'SPOR', 'ŞAPKA', 'SAP'],
        bonusWords: <String>['HALKA'],
        infoCardIds: <String>['kadim-info-misel'],
        starRules: WordHuntStarRules(
          twoStarMaxMistakes: 2,
          threeStarMaxMistakes: 0,
        ),
      ),
      // 5. GECE GÖZLERİ
      WordHuntLevelDefinition(
        id: 'orman-2-05',
        routeId: 'orman-2',
        index: 5,
        type: WordHuntLevelType.challenge,
        grid: <String>[
          'GECEITLÜ',
          'GÇUYĞAFL',
          'FNNAINOŞ',
          'YEKRŞAUI',
          'SPCAIKKV',
          'GSĞSYNIE',
          'MZÜAATPA',
          'PDBYŞEUT',
        ],
        targetWords: <String>['BAYKUŞ', 'YARASA', 'GECE', 'PENÇE', 'KANAT'],
        bonusWords: <String>['YANKI', 'AYIŞIĞI'],
        infoCardIds: <String>['kadim-info-baykus'],
        timeLimitSeconds: 60,
        starRules: WordHuntStarRules(
          twoStarMaxSeconds: 35,
          threeStarMaxSeconds: 24,
          twoStarMaxMistakes: 1,
          threeStarMaxMistakes: 0,
        ),
      ),
      // 6. UNUTULMUŞ HARABE
      WordHuntLevelDefinition(
        id: 'orman-2-06',
        routeId: 'orman-2',
        index: 6,
        type: WordHuntLevelType.normal,
        grid: <String>[
          'NDŞPYRVF',
          'JUŞTVFFK',
          'SHTFAKÜE',
          'OBDÜKRBM',
          'JYİRSATE',
          'LOMŞRVPR',
          'UJRAVUAI',
          'PPHTTDNZ',
        ],
        targetWords: <String>['HARABE', 'SÜTUN', 'KEMER', 'DUVAR', 'OYMA'],
        bonusWords: <String>['TAŞ', 'KAPI'],
        starRules: WordHuntStarRules(
          twoStarMaxMistakes: 2,
          threeStarMaxMistakes: 0,
        ),
      ),
      // 7. GİZLİ KAYNAK
      WordHuntLevelDefinition(
        id: 'orman-2-07',
        routeId: 'orman-2',
        index: 7,
        type: WordHuntLevelType.normal,
        grid: <String>[
          'NİÇYÜNTÜ',
          'AGSERİNK',
          'YKIYIEBV',
          'GÖLETLZE',
          'PKAYNAKÖ',
          'ZÇAKILZŞ',
          'RESÖKESA',
          'UZLBAŞFG',
        ],
        targetWords: <String>['KAYNAK', 'ŞELALE', 'AKINTI', 'GÖLET', 'ÇAKIL'],
        bonusWords: <String>['KIYI', 'SERİN'],
        infoCardIds: <String>['kadim-info-kaynak'],
        starRules: WordHuntStarRules(
          twoStarMaxMistakes: 2,
          threeStarMaxMistakes: 0,
        ),
      ),
      // 8. KADİM İŞARETLER
      WordHuntLevelDefinition(
        id: 'orman-2-08',
        routeId: 'orman-2',
        index: 8,
        type: WordHuntLevelType.normal,
        grid: <String>[
          'İBGZCJÖD',
          'BLMŞİFRE',
          'İOÜGZCUS',
          'EBHALKAE',
          'FMÜCKPMN',
          'TERAŞİYC',
          'DSTJEGOB',
          'YAÜSDFIU',
        ],
        targetWords: <String>['SEMBOL', 'İŞARET', 'MÜHÜR', 'OYMA', 'DESEN'],
        bonusWords: <String>['HALKA', 'ŞİFRE'],
        starRules: WordHuntStarRules(
          twoStarMaxMistakes: 2,
          threeStarMaxMistakes: 0,
        ),
      ),
      // 9. ORMANIN HAFIZASI
      WordHuntLevelDefinition(
        id: 'orman-2-09',
        routeId: 'orman-2',
        index: 9,
        type: WordHuntLevelType.normal,
        grid: <String>[
          'MİSVEMÇS',
          'RÇMAZUIJ',
          'APCATHNT',
          'ERMGAOAA',
          'ÇABLĞTRD',
          'NMKFCEÇÇ',
          'KABUKMGY',
          'EDVÖGPCL',
        ],
        targetWords: <String>[
          'TOHUM',
          'ÇINAR',
          'HALKA',
          'KABUK',
          'DAMAR',
          'ZAMAN',
        ],
        bonusWords: <String>['GÖVDE', 'MEVSİM'],
        infoCardIds: <String>['kadim-info-cinar'],
        starRules: WordHuntStarRules(
          twoStarMaxMistakes: 2,
          threeStarMaxMistakes: 0,
        ),
      ),
      // 10. ORMANIN KALBİ
      WordHuntLevelDefinition(
        id: 'orman-2-10',
        routeId: 'orman-2',
        index: 10,
        type: WordHuntLevelType.routeFinal,
        grid: <String>[
          'PĞNSPGDE',
          'NÇADAÖPF',
          'TYTKEKUS',
          'ÇAIUANBA',
          'ÇŞMDRLGN',
          'IAİFCOPE',
          'LMEZİGKĞ',
          'ÜHNGRDÖD',
        ],
        targetWords: <String>[
          'KADİM',
          'DENGE',
          'YAŞAM',
          'IŞIK',
          'GİZEM',
          'EFSANE',
        ],
        bonusWords: <String>['KALP', 'KORU'],
        timeLimitSeconds: 120,
        starRules: WordHuntStarRules(
          twoStarMaxSeconds: 64,
          threeStarMaxSeconds: 48,
          twoStarMaxMistakes: 2,
          threeStarMaxMistakes: 0,
        ),
      ),
    ],
  );
}
