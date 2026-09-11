import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WordHuntLevelDefinition level(int index, {bool finalLevel = false}) {
    return WordHuntLevelDefinition(
      id: 'level_$index',
      routeId: 'baslangic_limani',
      index: index,
      type:
          finalLevel ? WordHuntLevelType.routeFinal : WordHuntLevelType.normal,
      grid: const <String>['KAPI', 'ARMA', 'PUSU', 'ISIK'],
      targetWords: const <String>['KAPI'],
      starRules: const WordHuntStarRules(),
    );
  }

  WordHuntRouteDefinition route() {
    return WordHuntRouteDefinition(
      id: 'baslangic_limani',
      title: 'Başlangıç Limanı',
      theme: 'liman',
      unlockStarsRequired: 5,
      levels: <WordHuntLevelDefinition>[
        level(1),
        level(2),
        level(3, finalLevel: true),
      ],
      routeRewardId: 'rozet_kelime_yolcusu',
    );
  }

  test('ilk bolum acik, sonraki bolum onceki tamamlanmadan kilitli', () {
    final definition = route();
    const progress = WordHuntProgressSnapshot();

    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(definition, progress, 1),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(definition, progress, 2),
      isFalse,
    );
  });

  test('bir bolum tamamlaninca siradaki bolum acilir', () {
    final definition = route();
    final progress = const WordHuntProgressSnapshot().recordLevelResult(
      levelId: 'level_1',
      stars: 1,
    );

    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(definition, progress, 2),
      isTrue,
    );
    expect(
      WordHuntRouteProgressEngine.nextPlayableLevelIndex(definition, progress),
      2,
    );
  });

  test('Baslangic Limani 7-8-9-10 sirali ilerler', () {
    const definition = WordHuntStarterContent.baslangicLimani;
    const throughSeven = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 3,
        'baslangic-7': 3,
      },
    );
    const throughEight = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 3,
        'baslangic-7': 3,
        'baslangic-8': 3,
      },
    );
    const throughNine = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-1': 3,
        'baslangic-2': 3,
        'baslangic-3': 3,
        'baslangic-4': 3,
        'baslangic-5': 3,
        'baslangic-6': 3,
        'baslangic-7': 3,
        'baslangic-8': 3,
        'baslangic-9': 3,
      },
    );

    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(definition, throughSeven, 8),
      isTrue,
      reason: '7 tamamlanınca yalnız 8 açılmalıdır.',
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(definition, throughSeven, 9),
      isFalse,
      reason: '8 tamamlanmadan 9 açılmamalıdır.',
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(definition, throughEight, 9),
      isTrue,
      reason: '8 tamamlanınca 9 açılmalıdır.',
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(definition, throughEight, 10),
      isFalse,
      reason: '9 tamamlanmadan final 10 açılmamalıdır.',
    );
    expect(
      WordHuntRouteProgressEngine.isLevelUnlocked(definition, throughNine, 10),
      isTrue,
      reason: '9 tamamlanınca final 10 açılmalıdır.',
    );
  });

  test('dusuk tekrar sonucu daha iyi yildizi dusurmez', () {
    final first = const WordHuntProgressSnapshot().recordLevelResult(
      levelId: 'level_1',
      stars: 3,
      unlockedInfoCards: const <String>['kart_1'],
    );
    final second = first.recordLevelResult(
      levelId: 'level_1',
      stars: 1,
      unlockedInfoCards: const <String>['kart_2'],
    );

    expect(second.starsFor('level_1'), 3);
    expect(
      second.unlockedInfoCardIds,
      containsAll(<String>['kart_1', 'kart_2']),
    );
  });

  test('yildiz sonucu 0 ile 3 arasinda sinirlanir', () {
    final high = const WordHuntProgressSnapshot().recordLevelResult(
      levelId: 'level_1',
      stars: 8,
    );
    final low = const WordHuntProgressSnapshot().recordLevelResult(
      levelId: 'level_2',
      stars: -4,
    );

    expect(high.starsFor('level_1'), 3);
    expect(low.starsFor('level_2'), 0);
  });

  test('rota finali tek basina yetmez, yildiz esigi de gerekir', () {
    final definition = route();
    var progress = const WordHuntProgressSnapshot();
    progress = progress.recordLevelResult(levelId: 'level_1', stars: 1);
    progress = progress.recordLevelResult(levelId: 'level_2', stars: 1);
    progress = progress.recordLevelResult(levelId: 'level_3', stars: 1);

    expect(
      WordHuntRouteProgressEngine.isRouteComplete(definition, progress),
      isFalse,
    );

    progress = progress.recordLevelResult(levelId: 'level_1', stars: 3);
    expect(
      WordHuntRouteProgressEngine.isRouteComplete(definition, progress),
      isTrue,
    );
  });

  test('rota yildiz toplami yalniz kendi bolumlerini sayar', () {
    final definition = route();
    var progress = const WordHuntProgressSnapshot();
    progress = progress.recordLevelResult(levelId: 'level_1', stars: 3);
    progress = progress.recordLevelResult(levelId: 'level_2', stars: 2);
    progress = progress.recordLevelResult(levelId: 'baska_rota_1', stars: 3);

    expect(WordHuntRouteProgressEngine.totalStars(definition, progress), 5);
  });
}
