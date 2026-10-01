import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/word_hunt_canonical_paths.dart';

void main() {
  final level = WordHuntStarterContent.baslangicLimani.levels.first;

  WordHuntSelectionResult evaluate(
    List<WordHuntCell> path, {
    Set<String> foundTargets = const <String>{},
    Set<String> foundBonus = const <String>{},
  }) => WordHuntPathEngine.evaluate(
    level: level,
    path: path,
    foundTargetWords: foundTargets,
    foundBonusWords: foundBonus,
  );

  test('Bölüm 1 canonical KALEM ileri ve ters yönde hedef olur', () {
    final forward = canonicalPath(level, 'KALEM');
    final reverse = forward.reversed.toList(growable: false);
    expect(evaluate(forward).kind, WordHuntSelectionKind.target);
    expect(evaluate(forward).canonicalWord, 'KALEM');
    expect(evaluate(reverse).kind, WordHuntSelectionKind.target);
    expect(evaluate(reverse).canonicalWord, 'KALEM');
  });

  test('Bölüm 1 yatay/dikey ve reverse targetları çözer', () {
    final families = <String>{};
    for (final word in level.targetWords) {
      final path = canonicalPath(level, word);
      families.add(path.first.row == path.last.row ? 'horizontal' : 'vertical');
      expect(evaluate(path).kind, WordHuntSelectionKind.target);
      expect(evaluate(path).canonicalWord, word);
      expect(
        evaluate(path.reversed.toList()).kind,
        WordHuntSelectionKind.target,
      );
      expect(evaluate(path.reversed.toList()).canonicalWord, word);
    }
    expect(families, {'horizontal', 'vertical'});
  });

  test('ELMA bonus olur ve bonus completion için zorunlu değildir', () {
    final elma = canonicalPath(level, level.bonusWords.single);
    expect(evaluate(elma).kind, WordHuntSelectionKind.bonus);
    expect(evaluate(elma).canonicalWord, 'ELMA');
    expect(level.targetWords, isNot(contains(level.bonusWords.single)));
    expect(level.bonusWords, <String>['ELMA']);
  });

  test('tekrar target ödül üretmez; bilinmeyen ve kıvrılan yol ayrışır', () {
    final kalem = canonicalPath(level, 'KALEM');
    expect(
      evaluate(kalem, foundTargets: const <String>{'KALEM'}).kind,
      WordHuntSelectionKind.alreadyFound,
    );
    expect(
      evaluate(const <WordHuntCell>[
        WordHuntCell(0, 0),
        WordHuntCell(0, 1),
      ]).kind,
      WordHuntSelectionKind.notAWord,
    );
    expect(
      evaluate(const <WordHuntCell>[
        WordHuntCell(0, 0),
        WordHuntCell(0, 1),
        WordHuntCell(1, 1),
      ]).kind,
      WordHuntSelectionKind.invalidPath,
    );
  });
}
