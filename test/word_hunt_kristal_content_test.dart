import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = WordHuntKristalContent.kristalVadisi;

  test(
    'Kristal Vadisi production identity and 10-level contract are exact',
    () {
      expect(route.id, 'kristal-vadisi');
      expect(route.title, 'Kristal Vadisi');
      expect(route.routeRewardId, 'badge-kristal-kasifi');
      expect(route.unlockStarsRequired, 0);
      expect(route.levels, hasLength(10));
      expect(route.levels.map((level) => level.id).toList(), <String>[
        'kristal-vadisi-01',
        'kristal-vadisi-02',
        'kristal-vadisi-03',
        'kristal-vadisi-04',
        'kristal-vadisi-05',
        'kristal-vadisi-06',
        'kristal-vadisi-07',
        'kristal-vadisi-08',
        'kristal-vadisi-09',
        'kristal-vadisi-10',
      ]);
      expect(route.levels[4].type, WordHuntLevelType.challenge);
      expect(route.levels[9].type, WordHuntLevelType.routeFinal);
      for (final index in <int>[0, 1, 2, 3, 5, 6, 7, 8]) {
        expect(route.levels[index].type, WordHuntLevelType.normal);
      }
    },
  );

  test('owner-approved content totals and uniqueness stay exact', () {
    final targets = route.levels.expand((level) => level.targetWords).toList();
    final bonuses = route.levels.expand((level) => level.bonusWords).toList();
    final listed = <String>[...targets, ...bonuses];

    expect(targets, hasLength(56));
    expect(bonuses, hasLength(14));
    expect(listed, hasLength(70));
    expect(listed.toSet(), hasLength(70));
    expect(route.levels.map((level) => level.id).toSet(), hasLength(10));

    for (final level in route.levels) {
      expect(level.grid, hasLength(8), reason: level.id);
      expect(
        level.grid.every((row) => row.runes.length == 8),
        isTrue,
        reason: level.id,
      );
      expect(
        level.targetWords.toSet().intersection(level.bonusWords.toSet()),
        isEmpty,
        reason: level.id,
      );
    }
  });

  test(
    'exact approved grids, targets and bonuses stay byte-for-text exact',
    () {
      const grids = <List<String>>[
        <String>[
          'ŞZÇLMHSŞ',
          'KGŞYİOŞG',
          'ÇALLNÇNE',
          'MFTDEDEA',
          'DTAMRTDD',
          'LJCKAYAÇ',
          'SÇDLLNMC',
          'NLIKAÇHF',
        ],
        <String>[
          'KMRTİRİP',
          'PLKALSİT',
          'RGUPMRBC',
          'FAVSAİEŞ',
          'İFADPVKİ',
          'IÜRLHDOA',
          'ARSEMGVB',
          'ÖERFÖLYD',
        ],
        <String>[
          'HCÜSHEEH',
          'ÇIHVTVHI',
          'ÜLSLENÜT',
          'DMAĞARAK',
          'ZİRSÇÇUU',
          'SOKVĞVĞY',
          'ŞÜIİOLTO',
          'UVTKTIEİ',
        ],
        <String>[
          'YBOAYVVY',
          'AMLIRIKI',
          'NPAAIOTF',
          'SKRNKLBH',
          'INVİIİIM',
          'MEÖRZŞGT',
          'ARAABMIÖ',
          'PPSAYDAM',
        ],
        <String>[
          'KNESKETS',
          'YRKÖŞEİA',
          'ÜSİPSMUD',
          'ZMÜSEGNY',
          'EKGTTNSC',
          'YGRFLAĞF',
          'HİÖŞNSLİ',
          'ÇFĞFÇATM',
        ],
        <String>[
          'VÖMKVFFV',
          'OPARLAKŞ',
          'GATKAGPİ',
          'KİLTRESK',
          'BGIDOMIB',
          'KZKDORID',
          'YİBKIKİP',
          'RÇGKRŞUC',
        ],
        <String>[
          'PLUTROTT',
          'OBSİDYEN',
          'MTMHŞFÇB',
          'ZİCEÜIAV',
          'ANDTRZŞN',
          'HAÇİAMSİ',
          'ERNLUGEÇ',
          'ÜGTİÜKDR',
        ],
        <String>[
          'FÇIYOLİF',
          'MHADMEFH',
          'EFATKVRM',
          'RKBZLHPT',
          'PÇNISABÖ',
          'EMANTOKZ',
          'DIÖYPKMR',
          'OZIZOHİN',
        ],
        <String>[
          'DÇSEDZZD',
          'LYKMCMDY',
          'EMRÜKSÜP',
          'AOEMKAÇM',
          'KCTEÜÜAU',
          'ELAVLGRM',
          'TSRBMHCT',
          'ĞMKAĞYZÖ',
        ],
        <String>[
          'ARSRİFAS',
          'IMİKİKAE',
          'ATEVİMOY',
          'ÖÜOTLNAD',
          'PRPEİKOP',
          'VMACUSKC',
          'FÜLTRYTO',
          'GZTOPAZU',
        ],
      ];
      const targets = <List<String>>[
        <String>['KAYAÇ', 'MİNERAL', 'KATMAN', 'ÇAKIL', 'MADEN'],
        <String>['KUVARS', 'KALSİT', 'MİKA', 'PİRİT', 'FELDSPAT'],
        <String>['MAĞARA', 'SARKIT', 'DİKİT', 'TÜNEL', 'OYUK'],
        <String>['PRİZMA', 'KIRILMA', 'YANSIMA', 'PARILTI', 'SAYDAM'],
        <String>['KRİSTAL', 'ÖRGÜ', 'EKSEN', 'SİMETRİ', 'KÖŞE', 'YÜZEY'],
        <String>['SERTLİK', 'DOKU', 'ÇİZGİ', 'PARLAK', 'KIRIK'],
        <String>['OBSİDYEN', 'GRANİT', 'BAZALT', 'MERMER', 'TORTUL', 'POMZA'],
        <String>['FAY', 'LEVHA', 'BASINÇ', 'ÇATLAK', 'DEPREM', 'ODAK'],
        <String>['MAGMA', 'LAV', 'KRATER', 'KÜKÜRT', 'PÜSKÜRME', 'KÜL'],
        <String>[
          'AMETİST',
          'ZÜMRÜT',
          'SAFİR',
          'YAKUT',
          'TOPAZ',
          'OPAL',
          'ONİKS',
        ],
      ];
      const bonuses = <List<String>>[
        <String>['SONDAJ'],
        <String>['CEVHER'],
        <String>['KOVUK'],
        <String>['IŞIN', 'RENK'],
        <String>['KÜP', 'İĞNE'],
        <String>['MATLIK'],
        <String>['TÜF'],
        <String>['MANTO'],
        <String>['BACA', 'KOR'],
        <String>['ELMAS', 'AKİK'],
      ];

      for (var i = 0; i < 10; i++) {
        expect(route.levels[i].grid, grids[i], reason: route.levels[i].id);
        expect(
          route.levels[i].targetWords,
          targets[i],
          reason: route.levels[i].id,
        );
        expect(
          route.levels[i].bonusWords,
          bonuses[i],
          reason: route.levels[i].id,
        );
      }
    },
  );

  test('strict production validators accept all Kristal content', () {
    expect(WordHuntDefinitionValidator.validateRoute(route), isEmpty);
    expect(
      WordHuntContentValidator.validate(
        route: route,
        infoCards: WordHuntKristalContent.infoCards,
      ),
      isEmpty,
    );
  });

  test(
    'every listed word has exactly one physical straight-eight occurrence',
    () {
      for (final level in route.levels) {
        for (final word in <String>[
          ...level.targetWords,
          ...level.bonusWords,
        ]) {
          expect(
            _physicalOccurrences(level.grid, word),
            1,
            reason: '${level.id}: $word',
          );
        }
      }
    },
  );

  test(
    'L5 and L10 progressive rules are exact and soft timer metadata remains',
    () {
      final l5 = route.levels[4];
      expect(l5.timeLimitSeconds, 60);
      expect(l5.starRules.threeStarMaxSeconds, 30);
      expect(l5.starRules.twoStarMaxSeconds, 44);
      expect(l5.starRules.threeStarMaxMistakes, 0);
      expect(l5.starRules.twoStarMaxMistakes, 1);

      final l10 = route.levels[9];
      expect(l10.timeLimitSeconds, 120);
      expect(l10.starRules.threeStarMaxSeconds, 58);
      expect(l10.starRules.twoStarMaxSeconds, 78);
      expect(l10.starRules.threeStarMaxMistakes, 0);
      expect(l10.starRules.twoStarMaxMistakes, 2);

      for (final i in <int>[0, 1, 2, 3, 5, 6, 7, 8]) {
        expect(route.levels[i].timeLimitSeconds, isNull);
        expect(route.levels[i].starRules.threeStarMaxSeconds, isNull);
        expect(route.levels[i].starRules.twoStarMaxSeconds, isNull);
      }
    },
  );

  test('six exact route-scoped info cards and level links stay isolated', () {
    final cards = WordHuntKristalContent.infoCards;
    expect(cards, hasLength(6));
    expect(cards.map((card) => card.id).toList(), <String>[
      'kristal-info-mineral',
      'kristal-info-kuvars',
      'kristal-info-kristal',
      'kristal-info-obsidyen',
      'kristal-info-fay',
      'kristal-info-ametist',
    ]);
    expect(route.levels[0].infoCardIds, <String>['kristal-info-mineral']);
    expect(route.levels[1].infoCardIds, <String>['kristal-info-kuvars']);
    expect(route.levels[4].infoCardIds, <String>['kristal-info-kristal']);
    expect(route.levels[6].infoCardIds, <String>['kristal-info-obsidyen']);
    expect(route.levels[7].infoCardIds, <String>['kristal-info-fay']);
    expect(route.levels[9].infoCardIds, <String>['kristal-info-ametist']);
    expect(route.levels[2].infoCardIds, isEmpty);
    expect(route.levels[3].infoCardIds, isEmpty);
    expect(route.levels[5].infoCardIds, isEmpty);
    expect(route.levels[8].infoCardIds, isEmpty);
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
          if (rr < 0 || rr >= rows.length || cc < 0 || cc >= rows[rr].length) {
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
          final canonical = cells.map((e) => '${e.$1}:${e.$2}').toList()
            ..sort();
          physical.add(canonical.join('|'));
        }
      }
    }
  }
  return physical.length;
}
