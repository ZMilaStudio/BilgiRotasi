import 'package:bilgi_rotasi/word_hunt/word_hunt_input.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/word_hunt_canonical_paths.dart';

void main() {
  final level = WordHuntStarterContent.baslangicLimani.levels[4];

  final fixture = extendableTarget(level);
  final targetPath = fixture.$2;

  test('kelime olamayacak kadar kısa temas seçim sayılmaz', () {
    final result = WordHuntInputResolver.resolve(
      level: level,
      path: targetPath.take(2).toList(),
    );

    expect(result.isIgnored, isTrue);
  });

  test('hedefin ardındaki tek fazla hücre güvenle kırpılır', () {
    final result = WordHuntInputResolver.resolve(
      level: level,
      path: extendPath(targetPath, 1),
    );

    expect(result.path, targetPath);
    expect(result.result?.kind, WordHuntSelectionKind.target);
    expect(result.result?.canonicalWord, fixture.$1);
  });

  test('iki fazla hücre otomatik düzeltilmez', () {
    final result = WordHuntInputResolver.resolve(
      level: level,
      path: extendPath(targetPath, 2),
    );

    expect(result.path, extendPath(targetPath, 2));
    expect(result.result?.kind, WordHuntSelectionKind.notAWord);
  });

  test('anlamlı gerçek yanlış seçim hata adayı olarak korunur', () {
    final result = WordHuntInputResolver.resolve(
      level: level,
      path: wrongSelection(level),
    );

    expect(result.isIgnored, isFalse);
    expect(result.result?.kind, WordHuntSelectionKind.notAWord);
  });
}
