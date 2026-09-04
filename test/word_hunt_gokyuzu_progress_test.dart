import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WordHuntLevelDefinition level(int index, WordHuntLevelType type) {
    return WordHuntLevelDefinition(
      id: 'gokyuzu-$index',
      routeId: 'gokyuzu-adalari',
      index: index,
      type: type,
      grid: const <String>[
        'KAPILARM',
        'ABCDEFGH',
        'IJKLMNOP',
        'QRSTUVYZ',
        'ABCDEFGH',
        'IJKLMNOP',
        'QRSTUVYZ',
        'ABCDEFGH',
      ],
      targetWords: const <String>['KAPI'],
      starRules: const WordHuntStarRules(),
    );
  }

  WordHuntRouteDefinition gokyuzu() => WordHuntRouteDefinition(
    id: 'gokyuzu-adalari',
    title: 'Gökyüzü Adaları',
    theme: 'gokyuzu',
    unlockStarsRequired: 18,
    routeRewardId: 'badge-gokyuzu-kasifi',
    levels: <WordHuntLevelDefinition>[
      for (var i = 1; i <= 7; i++) level(i, WordHuntLevelType.normal),
      level(8, WordHuntLevelType.bonus),
      level(9, WordHuntLevelType.normal),
      level(10, WordHuntLevelType.routeFinal),
    ],
  );

  test('Gökyüzü 7 sonrası bonus 8 ve normal 9 birlikte açılır', () {
    final route = gokyuzu();
    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{'gokyuzu-7': 1},
    );

    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 8),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 9),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10),
      isFalse,
    );
  });

  test('Gökyüzü final 10 için normal 9 tamamlanmış olmalıdır', () {
    final route = gokyuzu();
    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{'gokyuzu-7': 1, 'gokyuzu-9': 1},
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10),
      isTrue,
    );
  });

  test('Başlangıç Limanı bonus bypass davranışı korunur', () {
    const route = WordHuntStarterContent.baslangicLimani;
    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{'baslangic-7': 1},
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 8),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 9),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10),
      isFalse,
    );
  });
}
