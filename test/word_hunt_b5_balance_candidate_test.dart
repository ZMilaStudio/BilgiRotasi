import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/word_hunt_canonical_paths.dart';

void main() {
  final level = WordHuntStarterContent.baslangicLimani.levels[4];

  test('B5 60s tuning adayı içerik sözleşmesini korur', () {
    expect(level.index, 5);
    expect(level.type, WordHuntLevelType.challenge);
    expect(level.rowCount, 8);
    expect(level.columnCount, 8);
    expect(level.targetWords, const <String>[
      'ANKARA',
      'ŞEHİR',
      'TÜRKİYE',
      'BAŞKENT',
      'MECLİS',
      'KULE',
    ]);
    expect(level.bonusWords, const <String>['ANIT']);
    expect(level.timeLimitSeconds, 60);
    expect(level.starRules.twoStarMaxSeconds, 50);
    expect(level.starRules.threeStarMaxSeconds, 35);
    expect(level.starRules.twoStarMaxMistakes, 1);
    expect(level.starRules.threeStarMaxMistakes, 0);
  });

  test('B5 tuning adayı her kelimeyi tek fiziksel hatta taşır', () {
    expect(level.grid, <String>[
      'BZAPTİKÖ',
      'AĞNUÜÖUD',
      'ŞUKLRHLM',
      'KŞACKĞEE',
      'EERÇİRJC',
      'NHAIYRGL',
      'TİGİEARİ',
      'CRÜANITS',
    ]);
    const expected = <String, String>{
      'ANKARA': '0,2|5,2',
      'ŞEHİR': '3,1|7,1',
      'TÜRKİYE': '0,4|6,4',
      'BAŞKENT': '0,0|6,0',
      'MECLİS': '2,7|7,7',
      'KULE': '0,6|3,6',
      'ANIT': '7,3|7,6',
    };
    expect(expected.keys.toSet(), {...level.targetWords, ...level.bonusWords});
    for (final entry in expected.entries) {
      final path = canonicalPath(level, entry.key);
      expect(
        '${path.first.row},${path.first.column}|${path.last.row},${path.last.column}',
        entry.value,
        reason: entry.key,
      );
    }
  });

  test(
    'B5 owner-approved introductory grid uses horizontal/vertical paths',
    () {
      final families = <String>{};
      for (final word in [...level.targetWords, ...level.bonusWords]) {
        final path = canonicalPath(level, word);
        final dr = path.last.row - path.first.row;
        final dc = path.last.column - path.first.column;
        families.add(
          dr == 0
              ? 'horizontal'
              : dc == 0
              ? 'vertical'
              : 'diagonal',
        );
      }
      expect(families, {'horizontal', 'vertical'});
    },
  );
}
