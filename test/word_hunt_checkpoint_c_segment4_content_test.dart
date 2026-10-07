import 'package:word_hunt_flutter_feature/word_hunt_completion_orchestration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_models.dart';
import 'package:word_hunt_domain/word_hunt_path.dart';
import 'package:word_hunt_domain/word_hunt_progress.dart';
import 'package:word_hunt_domain/word_hunt_segment_projection.dart';
import 'package:word_hunt_flutter_feature/word_hunt_route_rewards.dart';
import 'package:word_hunt_flutter_feature/word_hunt_route_catalog.dart';
import 'word_hunt_checkpoint_a_content_test.dart' show pathsFor;

void main() {
  const route = WordHuntStarterContent.baslangicLimani;
  test('L31: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[30];
    expect(level.id, 'baslangic-31');
    expect(level.grid, <String>[
      'PSÜRAHİK',
      'İİYKABVE',
      'İMNVACPP',
      'ESAUEÇJÇ',
      'DTPZHMIE',
      'NŞVEAADB',
      'EEGŞTĞÖL',
      'RĞACPRNC',
    ]);
    expect(level.targetWords, <String>[
      'TAVA',
      'BIÇAK',
      'RENDE',
      'TEPSİ',
      'SÜRAHİ',
      'CEZVE',
      'KEPÇE',
      'MAŞA',
    ]);
    expect(level.bonusWords, <String>['HUNİ']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(5, 7),
        WordHuntCell(4, 6),
        WordHuntCell(3, 5),
        WordHuntCell(2, 4),
        WordHuntCell(1, 3),
      ];
      expect(pathsFor(level, 'BIÇAK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'BIÇAK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(2, 5),
        WordHuntCell(3, 4),
        WordHuntCell(4, 3),
        WordHuntCell(5, 2),
        WordHuntCell(6, 1),
      ];
      expect(pathsFor(level, 'CEZVE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'CEZVE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(4, 4),
        WordHuntCell(3, 3),
        WordHuntCell(2, 2),
        WordHuntCell(1, 1),
      ];
      expect(pathsFor(level, 'HUNİ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'HUNİ');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 7),
        WordHuntCell(1, 7),
        WordHuntCell(2, 7),
        WordHuntCell(3, 7),
        WordHuntCell(4, 7),
      ];
      expect(pathsFor(level, 'KEPÇE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'KEPÇE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(4, 5),
        WordHuntCell(5, 4),
        WordHuntCell(6, 3),
        WordHuntCell(7, 2),
      ];
      expect(pathsFor(level, 'MAŞA'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MAŞA');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 0),
        WordHuntCell(6, 0),
        WordHuntCell(5, 0),
        WordHuntCell(4, 0),
        WordHuntCell(3, 0),
      ];
      expect(pathsFor(level, 'RENDE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'RENDE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 1),
        WordHuntCell(0, 2),
        WordHuntCell(0, 3),
        WordHuntCell(0, 4),
        WordHuntCell(0, 5),
        WordHuntCell(0, 6),
      ];
      expect(pathsFor(level, 'SÜRAHİ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'SÜRAHİ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(4, 1),
        WordHuntCell(3, 2),
        WordHuntCell(2, 3),
        WordHuntCell(1, 4),
      ];
      expect(pathsFor(level, 'TAVA'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'TAVA');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 4),
        WordHuntCell(5, 3),
        WordHuntCell(4, 2),
        WordHuntCell(3, 1),
        WordHuntCell(2, 0),
      ];
      expect(pathsFor(level, 'TEPSİ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'TEPSİ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
  });
  test('L32: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[31];
    expect(level.id, 'baslangic-32');
    expect(level.grid, <String>[
      'JOTIERGĞ',
      'KÖOKLYÖK',
      'RTBTDBME',
      'AFEAİVLM',
      'VKIKVVEE',
      'AURKEDKR',
      'TIEINCŞJ',
      'KETEHCAN',
    ]);
    expect(level.targetWords, <String>[
      'ETEK',
      'CEKET',
      'GÖMLEK',
      'KEMER',
      'BOT',
      'ATKI',
      'ELDİVEN',
      'HIRKA',
    ]);
    expect(level.bonusWords, <String>['KRAVAT']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 3),
        WordHuntCell(2, 3),
        WordHuntCell(1, 3),
        WordHuntCell(0, 3),
      ];
      expect(pathsFor(level, 'ATKI'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ATKI');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(2, 2),
        WordHuntCell(1, 2),
        WordHuntCell(0, 2),
      ];
      expect(pathsFor(level, 'BOT'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'BOT');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 5),
        WordHuntCell(5, 4),
        WordHuntCell(4, 3),
        WordHuntCell(3, 2),
        WordHuntCell(2, 1),
      ];
      expect(pathsFor(level, 'CEKET'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'CEKET');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 4),
        WordHuntCell(1, 4),
        WordHuntCell(2, 4),
        WordHuntCell(3, 4),
        WordHuntCell(4, 4),
        WordHuntCell(5, 4),
        WordHuntCell(6, 4),
      ];
      expect(pathsFor(level, 'ELDİVEN'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ELDİVEN');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 3),
        WordHuntCell(7, 2),
        WordHuntCell(7, 1),
        WordHuntCell(7, 0),
      ];
      expect(pathsFor(level, 'ETEK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ETEK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 6),
        WordHuntCell(1, 6),
        WordHuntCell(2, 6),
        WordHuntCell(3, 6),
        WordHuntCell(4, 6),
        WordHuntCell(5, 6),
      ];
      expect(pathsFor(level, 'GÖMLEK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'GÖMLEK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 4),
        WordHuntCell(6, 3),
        WordHuntCell(5, 2),
        WordHuntCell(4, 1),
        WordHuntCell(3, 0),
      ];
      expect(pathsFor(level, 'HIRKA'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'HIRKA');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(1, 7),
        WordHuntCell(2, 7),
        WordHuntCell(3, 7),
        WordHuntCell(4, 7),
        WordHuntCell(5, 7),
      ];
      expect(pathsFor(level, 'KEMER'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'KEMER');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(1, 0),
        WordHuntCell(2, 0),
        WordHuntCell(3, 0),
        WordHuntCell(4, 0),
        WordHuntCell(5, 0),
        WordHuntCell(6, 0),
      ];
      expect(pathsFor(level, 'KRAVAT'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'KRAVAT');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
  });
  test('L33: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[32];
    expect(level.id, 'baslangic-33');
    expect(level.grid, <String>[
      'İÇTFİÇIT',
      'ICRMKNÇE',
      'GRERİEŞR',
      'POPEAKAZ',
      'İTOBCMAİ',
      'LKLRÜMİH',
      'OOİEİŞGM',
      'TDSBHTAK',
    ]);
    expect(level.targetWords, <String>[
      'DOKTOR',
      'MİMAR',
      'AŞÇI',
      'TERZİ',
      'POLİS',
      'HAKİM',
      'ÇİFTÇİ',
      'BERBER',
    ]);
    expect(level.bonusWords, <String>['PİLOT']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 6),
        WordHuntCell(2, 6),
        WordHuntCell(1, 6),
        WordHuntCell(0, 6),
      ];
      expect(pathsFor(level, 'AŞÇI'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'AŞÇI');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 3),
        WordHuntCell(6, 3),
        WordHuntCell(5, 3),
        WordHuntCell(4, 3),
        WordHuntCell(3, 3),
        WordHuntCell(2, 3),
      ];
      expect(pathsFor(level, 'BERBER'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'BERBER');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 1),
        WordHuntCell(6, 1),
        WordHuntCell(5, 1),
        WordHuntCell(4, 1),
        WordHuntCell(3, 1),
        WordHuntCell(2, 1),
      ];
      expect(pathsFor(level, 'DOKTOR'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'DOKTOR');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(5, 7),
        WordHuntCell(4, 6),
        WordHuntCell(3, 5),
        WordHuntCell(2, 4),
        WordHuntCell(1, 3),
      ];
      expect(pathsFor(level, 'HAKİM'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'HAKİM');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 7),
        WordHuntCell(5, 6),
        WordHuntCell(4, 5),
        WordHuntCell(3, 4),
        WordHuntCell(2, 3),
      ];
      expect(pathsFor(level, 'MİMAR'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MİMAR');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 2),
        WordHuntCell(4, 2),
        WordHuntCell(5, 2),
        WordHuntCell(6, 2),
        WordHuntCell(7, 2),
      ];
      expect(pathsFor(level, 'POLİS'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'POLİS');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 0),
        WordHuntCell(4, 0),
        WordHuntCell(5, 0),
        WordHuntCell(6, 0),
        WordHuntCell(7, 0),
      ];
      expect(pathsFor(level, 'PİLOT'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'PİLOT');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 7),
        WordHuntCell(1, 7),
        WordHuntCell(2, 7),
        WordHuntCell(3, 7),
        WordHuntCell(4, 7),
      ];
      expect(pathsFor(level, 'TERZİ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'TERZİ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 5),
        WordHuntCell(0, 4),
        WordHuntCell(0, 3),
        WordHuntCell(0, 2),
        WordHuntCell(0, 1),
        WordHuntCell(0, 0),
      ];
      expect(pathsFor(level, 'ÇİFTÇİ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ÇİFTÇİ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
  });
  test('L34: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[33];
    expect(level.id, 'baslangic-34');
    expect(level.grid, <String>[
      'ORTAYİTS',
      'NTZEPEHT',
      'AİOTZAAA',
      'KMAPSÜKD',
      'KZETANMY',
      'ÜCANARYU',
      'DNİBİAKM',
      'EENATSOP',
    ]);
    expect(level.targetWords, <String>[
      'MÜZE',
      'SİNEMA',
      'TİYATRO',
      'BANKA',
      'POSTANE',
      'HASTANE',
      'STADYUM',
      'DÜKKAN',
    ]);
    expect(level.bonusWords, <String>['OTOPARK']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 3),
        WordHuntCell(5, 4),
        WordHuntCell(4, 5),
        WordHuntCell(3, 6),
        WordHuntCell(2, 7),
      ];
      expect(pathsFor(level, 'BANKA'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'BANKA');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 0),
        WordHuntCell(5, 0),
        WordHuntCell(4, 0),
        WordHuntCell(3, 0),
        WordHuntCell(2, 0),
        WordHuntCell(1, 0),
      ];
      expect(pathsFor(level, 'DÜKKAN'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'DÜKKAN');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(1, 6),
        WordHuntCell(2, 5),
        WordHuntCell(3, 4),
        WordHuntCell(4, 3),
        WordHuntCell(5, 2),
        WordHuntCell(6, 1),
        WordHuntCell(7, 0),
      ];
      expect(pathsFor(level, 'HASTANE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'HASTANE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(4, 6),
        WordHuntCell(3, 5),
        WordHuntCell(2, 4),
        WordHuntCell(1, 3),
      ];
      expect(pathsFor(level, 'MÜZE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MÜZE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 0),
        WordHuntCell(1, 1),
        WordHuntCell(2, 2),
        WordHuntCell(3, 3),
        WordHuntCell(4, 4),
        WordHuntCell(5, 5),
        WordHuntCell(6, 6),
      ];
      expect(pathsFor(level, 'OTOPARK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'OTOPARK');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 7),
        WordHuntCell(7, 6),
        WordHuntCell(7, 5),
        WordHuntCell(7, 4),
        WordHuntCell(7, 3),
        WordHuntCell(7, 2),
        WordHuntCell(7, 1),
      ];
      expect(pathsFor(level, 'POSTANE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'POSTANE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 7),
        WordHuntCell(1, 7),
        WordHuntCell(2, 7),
        WordHuntCell(3, 7),
        WordHuntCell(4, 7),
        WordHuntCell(5, 7),
        WordHuntCell(6, 7),
      ];
      expect(pathsFor(level, 'STADYUM'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'STADYUM');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 5),
        WordHuntCell(6, 4),
        WordHuntCell(5, 3),
        WordHuntCell(4, 2),
        WordHuntCell(3, 1),
        WordHuntCell(2, 0),
      ];
      expect(pathsFor(level, 'SİNEMA'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'SİNEMA');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 6),
        WordHuntCell(0, 5),
        WordHuntCell(0, 4),
        WordHuntCell(0, 3),
        WordHuntCell(0, 2),
        WordHuntCell(0, 1),
        WordHuntCell(0, 0),
      ];
      expect(pathsFor(level, 'TİYATRO'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'TİYATRO');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
  });
  test('L35: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[34];
    expect(level.id, 'baslangic-35');
    expect(level.grid, <String>[
      'KADNAMKK',
      'EİULCHAU',
      'ŞNTÇİŞZV',
      'EEVNKMNA',
      'AKDÖIUİT',
      'ÇİKHYÇPÜ',
      'PÜUOEZGL',
      'ZIKKYTCÜ',
    ]);
    expect(level.targetWords, <String>[
      'MANDA',
      'İNEK',
      'KOYUN',
      'KEÇİ',
      'TAVUK',
      'HİNDİ',
      'ÖKÜZ',
      'EŞEK',
    ]);
    expect(level.bonusWords, <String>['KAZ']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 0),
        WordHuntCell(2, 0),
        WordHuntCell(1, 0),
        WordHuntCell(0, 0),
      ];
      expect(pathsFor(level, 'EŞEK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'EŞEK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(1, 5),
        WordHuntCell(2, 4),
        WordHuntCell(3, 3),
        WordHuntCell(4, 2),
        WordHuntCell(5, 1),
      ];
      expect(pathsFor(level, 'HİNDİ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'HİNDİ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 6),
        WordHuntCell(1, 6),
        WordHuntCell(2, 6),
      ];
      expect(pathsFor(level, 'KAZ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'KAZ');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 3),
        WordHuntCell(6, 4),
        WordHuntCell(5, 5),
        WordHuntCell(4, 6),
      ];
      expect(pathsFor(level, 'KEÇİ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'KEÇİ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 2),
        WordHuntCell(6, 3),
        WordHuntCell(5, 4),
        WordHuntCell(4, 5),
        WordHuntCell(3, 6),
      ];
      expect(pathsFor(level, 'KOYUN'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'KOYUN');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 5),
        WordHuntCell(0, 4),
        WordHuntCell(0, 3),
        WordHuntCell(0, 2),
        WordHuntCell(0, 1),
      ];
      expect(pathsFor(level, 'MANDA'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MANDA');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(4, 7),
        WordHuntCell(3, 7),
        WordHuntCell(2, 7),
        WordHuntCell(1, 7),
        WordHuntCell(0, 7),
      ];
      expect(pathsFor(level, 'TAVUK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'TAVUK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(4, 3),
        WordHuntCell(5, 2),
        WordHuntCell(6, 1),
        WordHuntCell(7, 0),
      ];
      expect(pathsFor(level, 'ÖKÜZ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ÖKÜZ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(1, 1),
        WordHuntCell(2, 1),
        WordHuntCell(3, 1),
        WordHuntCell(4, 1),
      ];
      expect(pathsFor(level, 'İNEK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'İNEK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
  });
  test('L36: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[35];
    expect(level.id, 'baslangic-36');
    expect(level.grid, <String>[
      'NBNAĞOSP',
      'ADİAGVAI',
      'COGBĞÜRR',
      'IMKÇEŞIA',
      'LAACURMS',
      'TTBRSVSA',
      'AEAKUĞAL',
      'PSKJÇLKH',
    ]);
    expect(level.targetWords, <String>[
      'DOMATES',
      'BİBER',
      'PIRASA',
      'PATLICAN',
      'SOĞAN',
      'SARIMSAK',
      'HAVUÇ',
      'MARUL',
    ]);
    expect(level.bonusWords, <String>['KABAK']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 1),
        WordHuntCell(1, 2),
        WordHuntCell(2, 3),
        WordHuntCell(3, 4),
        WordHuntCell(4, 5),
      ];
      expect(pathsFor(level, 'BİBER'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'BİBER');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(1, 1),
        WordHuntCell(2, 1),
        WordHuntCell(3, 1),
        WordHuntCell(4, 1),
        WordHuntCell(5, 1),
        WordHuntCell(6, 1),
        WordHuntCell(7, 1),
      ];
      expect(pathsFor(level, 'DOMATES'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'DOMATES');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 7),
        WordHuntCell(6, 6),
        WordHuntCell(5, 5),
        WordHuntCell(4, 4),
        WordHuntCell(3, 3),
      ];
      expect(pathsFor(level, 'HAVUÇ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'HAVUÇ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 2),
        WordHuntCell(6, 2),
        WordHuntCell(5, 2),
        WordHuntCell(4, 2),
        WordHuntCell(3, 2),
      ];
      expect(pathsFor(level, 'KABAK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'KABAK');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 1),
        WordHuntCell(4, 2),
        WordHuntCell(5, 3),
        WordHuntCell(6, 4),
        WordHuntCell(7, 5),
      ];
      expect(pathsFor(level, 'MARUL'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MARUL');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 0),
        WordHuntCell(6, 0),
        WordHuntCell(5, 0),
        WordHuntCell(4, 0),
        WordHuntCell(3, 0),
        WordHuntCell(2, 0),
        WordHuntCell(1, 0),
        WordHuntCell(0, 0),
      ];
      expect(pathsFor(level, 'PATLICAN'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'PATLICAN');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 7),
        WordHuntCell(1, 7),
        WordHuntCell(2, 7),
        WordHuntCell(3, 7),
        WordHuntCell(4, 7),
        WordHuntCell(5, 7),
      ];
      expect(pathsFor(level, 'PIRASA'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'PIRASA');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 6),
        WordHuntCell(1, 6),
        WordHuntCell(2, 6),
        WordHuntCell(3, 6),
        WordHuntCell(4, 6),
        WordHuntCell(5, 6),
        WordHuntCell(6, 6),
        WordHuntCell(7, 6),
      ];
      expect(pathsFor(level, 'SARIMSAK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'SARIMSAK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 6),
        WordHuntCell(0, 5),
        WordHuntCell(0, 4),
        WordHuntCell(0, 3),
        WordHuntCell(0, 2),
      ];
      expect(pathsFor(level, 'SOĞAN'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'SOĞAN');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
  });
  test('L37: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[36];
    expect(level.id, 'baslangic-37');
    expect(level.grid, <String>[
      'ÇİKEÇÇAL',
      'EBNÜİNEP',
      'SCDVAREA',
      'NBİHEARK',
      'ETTTSDTT',
      'PASÇKİEA',
      'RENCRVMM',
      'TNUMOSKE',
    ]);
    expect(level.targetWords, <String>[
      'ÇEKİÇ',
      'PENSE',
      'TESTERE',
      'MATKAP',
      'VİDA',
      'ÇİVİ',
      'ANAHTAR',
      'SOMUN',
    ]);
    expect(level.bonusWords, <String>['METRE']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 6),
        WordHuntCell(1, 5),
        WordHuntCell(2, 4),
        WordHuntCell(3, 3),
        WordHuntCell(4, 2),
        WordHuntCell(5, 1),
        WordHuntCell(6, 0),
      ];
      expect(pathsFor(level, 'ANAHTAR'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ANAHTAR');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 7),
        WordHuntCell(5, 7),
        WordHuntCell(4, 7),
        WordHuntCell(3, 7),
        WordHuntCell(2, 7),
        WordHuntCell(1, 7),
      ];
      expect(pathsFor(level, 'MATKAP'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MATKAP');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 6),
        WordHuntCell(5, 6),
        WordHuntCell(4, 6),
        WordHuntCell(3, 6),
        WordHuntCell(2, 6),
      ];
      expect(pathsFor(level, 'METRE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'METRE');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(5, 0),
        WordHuntCell(4, 0),
        WordHuntCell(3, 0),
        WordHuntCell(2, 0),
        WordHuntCell(1, 0),
      ];
      expect(pathsFor(level, 'PENSE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'PENSE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 5),
        WordHuntCell(7, 4),
        WordHuntCell(7, 3),
        WordHuntCell(7, 2),
        WordHuntCell(7, 1),
      ];
      expect(pathsFor(level, 'SOMUN'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'SOMUN');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 0),
        WordHuntCell(6, 1),
        WordHuntCell(5, 2),
        WordHuntCell(4, 3),
        WordHuntCell(3, 4),
        WordHuntCell(2, 5),
        WordHuntCell(1, 6),
      ];
      expect(pathsFor(level, 'TESTERE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'TESTERE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 5),
        WordHuntCell(5, 5),
        WordHuntCell(4, 5),
        WordHuntCell(3, 5),
      ];
      expect(pathsFor(level, 'VİDA'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'VİDA');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 4),
        WordHuntCell(0, 3),
        WordHuntCell(0, 2),
        WordHuntCell(0, 1),
        WordHuntCell(0, 0),
      ];
      expect(pathsFor(level, 'ÇEKİÇ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ÇEKİÇ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 5),
        WordHuntCell(1, 4),
        WordHuntCell(2, 3),
        WordHuntCell(3, 2),
      ];
      expect(pathsFor(level, 'ÇİVİ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ÇİVİ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
  });
  test('L38: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[37];
    expect(level.id, 'baslangic-38');
    expect(level.grid, <String>[
      'PÇNİVESÇ',
      'ĞUYMERAK',
      'İGSFEKFÖ',
      'UHUALGÖİ',
      'TKÜRBĞRN',
      'UVRZUICE',
      'MELOÜRRŞ',
      'UKBHKNVE',
    ]);
    expect(level.targetWords, <String>[
      'SEVİNÇ',
      'ÖFKE',
      'KORKU',
      'MERAK',
      'SABIR',
      'UMUT',
      'NEŞE',
      'HÜZÜN',
    ]);
    expect(level.bonusWords, <String>['GURUR']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(2, 1),
        WordHuntCell(3, 2),
        WordHuntCell(4, 3),
        WordHuntCell(5, 4),
        WordHuntCell(6, 5),
      ];
      expect(pathsFor(level, 'GURUR'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'GURUR');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 1),
        WordHuntCell(4, 2),
        WordHuntCell(5, 3),
        WordHuntCell(6, 4),
        WordHuntCell(7, 5),
      ];
      expect(pathsFor(level, 'HÜZÜN'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'HÜZÜN');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 4),
        WordHuntCell(6, 3),
        WordHuntCell(5, 2),
        WordHuntCell(4, 1),
        WordHuntCell(3, 0),
      ];
      expect(pathsFor(level, 'KORKU'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'KORKU');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(1, 3),
        WordHuntCell(1, 4),
        WordHuntCell(1, 5),
        WordHuntCell(1, 6),
        WordHuntCell(1, 7),
      ];
      expect(pathsFor(level, 'MERAK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MERAK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(4, 7),
        WordHuntCell(5, 7),
        WordHuntCell(6, 7),
        WordHuntCell(7, 7),
      ];
      expect(pathsFor(level, 'NEŞE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'NEŞE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(2, 2),
        WordHuntCell(3, 3),
        WordHuntCell(4, 4),
        WordHuntCell(5, 5),
        WordHuntCell(6, 6),
      ];
      expect(pathsFor(level, 'SABIR'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'SABIR');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 6),
        WordHuntCell(0, 5),
        WordHuntCell(0, 4),
        WordHuntCell(0, 3),
        WordHuntCell(0, 2),
        WordHuntCell(0, 1),
      ];
      expect(pathsFor(level, 'SEVİNÇ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'SEVİNÇ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 0),
        WordHuntCell(6, 0),
        WordHuntCell(5, 0),
        WordHuntCell(4, 0),
      ];
      expect(pathsFor(level, 'UMUT'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'UMUT');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(2, 7),
        WordHuntCell(2, 6),
        WordHuntCell(2, 5),
        WordHuntCell(2, 4),
      ];
      expect(pathsFor(level, 'ÖFKE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ÖFKE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
  });
  test('L39: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[38];
    expect(level.id, 'baslangic-39');
    expect(level.grid, <String>[
      'ÜİAVTLPF',
      'CETHTORO',
      'PTSÜTEMT',
      'UEOOBDEO',
      'TZPAEİSĞ',
      'KAHRZVAR',
      'EGGEPCJA',
      'MİOYDARF',
    ]);
    expect(level.targetWords, <String>[
      'RADYO',
      'GAZETE',
      'DERGİ',
      'HABER',
      'MEKTUP',
      'POSTA',
      'FOTOĞRAF',
      'VİDEO',
    ]);
    expect(level.bonusWords, <String>['MESAJ']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 5),
        WordHuntCell(4, 4),
        WordHuntCell(5, 3),
        WordHuntCell(6, 2),
        WordHuntCell(7, 1),
      ];
      expect(pathsFor(level, 'DERGİ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'DERGİ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 7),
        WordHuntCell(1, 7),
        WordHuntCell(2, 7),
        WordHuntCell(3, 7),
        WordHuntCell(4, 7),
        WordHuntCell(5, 7),
        WordHuntCell(6, 7),
        WordHuntCell(7, 7),
      ];
      expect(pathsFor(level, 'FOTOĞRAF'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'FOTOĞRAF');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 1),
        WordHuntCell(5, 1),
        WordHuntCell(4, 1),
        WordHuntCell(3, 1),
        WordHuntCell(2, 1),
        WordHuntCell(1, 1),
      ];
      expect(pathsFor(level, 'GAZETE'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'GAZETE');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(5, 2),
        WordHuntCell(4, 3),
        WordHuntCell(3, 4),
        WordHuntCell(2, 5),
        WordHuntCell(1, 6),
      ];
      expect(pathsFor(level, 'HABER'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'HABER');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 0),
        WordHuntCell(6, 0),
        WordHuntCell(5, 0),
        WordHuntCell(4, 0),
        WordHuntCell(3, 0),
        WordHuntCell(2, 0),
      ];
      expect(pathsFor(level, 'MEKTUP'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MEKTUP');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(2, 6),
        WordHuntCell(3, 6),
        WordHuntCell(4, 6),
        WordHuntCell(5, 6),
        WordHuntCell(6, 6),
      ];
      expect(pathsFor(level, 'MESAJ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MESAJ');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(4, 2),
        WordHuntCell(3, 2),
        WordHuntCell(2, 2),
        WordHuntCell(1, 2),
        WordHuntCell(0, 2),
      ];
      expect(pathsFor(level, 'POSTA'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'POSTA');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(7, 6),
        WordHuntCell(7, 5),
        WordHuntCell(7, 4),
        WordHuntCell(7, 3),
        WordHuntCell(7, 2),
      ];
      expect(pathsFor(level, 'RADYO'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'RADYO');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(5, 5),
        WordHuntCell(4, 5),
        WordHuntCell(3, 5),
        WordHuntCell(2, 5),
        WordHuntCell(1, 5),
      ];
      expect(pathsFor(level, 'VİDEO'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'VİDEO');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
  });
  test('L40: exact accepted grid, words and reversible unique paths', () {
    final level = route.levels[39];
    expect(level.id, 'baslangic-40');
    expect(level.grid, <String>[
      'KMNİSANV',
      'HIAŞUBAT',
      'SALYRZJT',
      'EOZAIYEE',
      'YUCİRSKM',
      'LUĞARAİM',
      'ÜLIYKAMU',
      'LUFZÖÖNZ',
    ]);
    expect(level.targetWords, <String>[
      'OCAK',
      'ŞUBAT',
      'NİSAN',
      'MAYIS',
      'HAZİRAN',
      'TEMMUZ',
      'EYLÜL',
      'EKİM',
      'ARALIK',
    ]);
    expect(level.bonusWords, <String>['YIL']);
    {
      final cells = <WordHuntCell>[
        WordHuntCell(5, 5),
        WordHuntCell(4, 4),
        WordHuntCell(3, 3),
        WordHuntCell(2, 2),
        WordHuntCell(1, 1),
        WordHuntCell(0, 0),
      ];
      expect(pathsFor(level, 'ARALIK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ARALIK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 6),
        WordHuntCell(4, 6),
        WordHuntCell(5, 6),
        WordHuntCell(6, 6),
      ];
      expect(pathsFor(level, 'EKİM'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'EKİM');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 0),
        WordHuntCell(4, 0),
        WordHuntCell(5, 0),
        WordHuntCell(6, 0),
        WordHuntCell(7, 0),
      ];
      expect(pathsFor(level, 'EYLÜL'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'EYLÜL');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(1, 0),
        WordHuntCell(2, 1),
        WordHuntCell(3, 2),
        WordHuntCell(4, 3),
        WordHuntCell(5, 4),
        WordHuntCell(6, 5),
        WordHuntCell(7, 6),
      ];
      expect(pathsFor(level, 'HAZİRAN'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'HAZİRAN');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 1),
        WordHuntCell(1, 2),
        WordHuntCell(2, 3),
        WordHuntCell(3, 4),
        WordHuntCell(4, 5),
      ];
      expect(pathsFor(level, 'MAYIS'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'MAYIS');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(0, 2),
        WordHuntCell(0, 3),
        WordHuntCell(0, 4),
        WordHuntCell(0, 5),
        WordHuntCell(0, 6),
      ];
      expect(pathsFor(level, 'NİSAN'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'NİSAN');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(3, 1),
        WordHuntCell(4, 2),
        WordHuntCell(5, 3),
        WordHuntCell(6, 4),
      ];
      expect(pathsFor(level, 'OCAK'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'OCAK');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(2, 7),
        WordHuntCell(3, 7),
        WordHuntCell(4, 7),
        WordHuntCell(5, 7),
        WordHuntCell(6, 7),
        WordHuntCell(7, 7),
      ];
      expect(pathsFor(level, 'TEMMUZ'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'TEMMUZ');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(6, 3),
        WordHuntCell(6, 2),
        WordHuntCell(6, 1),
      ];
      expect(pathsFor(level, 'YIL'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'YIL');
        expect(result.kind, WordHuntSelectionKind.bonus);
      }
    }
    {
      final cells = <WordHuntCell>[
        WordHuntCell(1, 3),
        WordHuntCell(1, 4),
        WordHuntCell(1, 5),
        WordHuntCell(1, 6),
        WordHuntCell(1, 7),
      ];
      expect(pathsFor(level, 'ŞUBAT'), hasLength(1));
      for (final path in [cells, cells.reversed.toList()]) {
        final result = WordHuntPathEngine.evaluate(level: level, path: path);
        expect(result.canonicalWord, 'ŞUBAT');
        expect(result.kind, WordHuntSelectionKind.target);
      }
    }
  });
  test('40 available, 100 planned; L40 challenge is not route completion', () {
    expect(route.availableLevelCount, 40);
    expect(route.plannedRouteLevelCount, 100);
    expect(route.segments.map((s) => s.index), [1, 2, 3, 4]);
    final end = route.levels.last;
    expect(end.type, WordHuntLevelType.challenge);
    expect(end.timeLimitSeconds, 120);
    expect(end.starRules.twoStarMaxSeconds, 100);
    expect(end.starRules.threeStarMaxSeconds, 75);
    expect(end.starRules.twoStarMaxMistakes, 2);
    expect(end.starRules.threeStarMaxMistakes, 0);
    final before = WordHuntProgressSnapshot(
      bestStarsByLevelId: {
        for (final level in route.levels.take(39)) level.id: 1,
      },
    );
    final transition = WordHuntRouteRewardEngine.recordLevelResult(
      route: route,
      progress: before,
      levelId: end.id,
      stars: 3,
    );
    expect(
      WordHuntRouteProgressEngine.isRouteComplete(route, transition.progress),
      isFalse,
    );
    expect(
      WordHuntSegmentProjection.forLevel(route, 40).isTrueRouteFinal,
      isFalse,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(
        route,
        transition.progress,
        41,
      ),
      isFalse,
    );
    expect(transition.routeCompletedNow, isFalse);
    expect(transition.rewardGranted, isFalse);
    final destination = WordHuntCompletionCoordinator.resolve(
      route: route,
      completedLevelId: end.id,
      beforeProgress: before,
      afterProgress: transition.progress,
      transition: transition,
      catalogEntries: WordHuntRouteCatalog.entries,
    );
    expect(destination.kind, WordHuntCompletionDestinationKind.contentFrontier);
    expect(destination.isTrueRouteFinal, isFalse);
    expect(
      WordHuntRouteCatalog.gokyuzu.unlockRule.currentStars(
        WordHuntProgressSnapshot(
          bestStarsByLevelId: {
            for (final level in route.levels.take(30)) level.id: 1,
            for (final level in route.levels.skip(30)) level.id: 3,
          },
        ),
      ),
      30,
    );
  });
}
