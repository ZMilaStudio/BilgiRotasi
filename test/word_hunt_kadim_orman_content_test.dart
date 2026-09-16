import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = WordHuntOrman2Content.orman2;
  final ormanYolu = WordHuntOrmanContent.ormanYolu;

  test('Kadim Orman technical identity and level contract stay stable', () {
    expect(route.id, 'orman-2');
    expect(route.title, 'Kadim Orman');
    expect(route.theme, 'orman');
    expect(route.routeRewardId, 'reward-orman-2');
    expect(route.levels, hasLength(10));

    expect(
      route.levels.map((level) => level.id).toList(),
      <String>[
        'orman-2-01',
        'orman-2-02',
        'orman-2-03',
        'orman-2-04',
        'orman-2-05',
        'orman-2-06',
        'orman-2-07',
        'orman-2-08',
        'orman-2-09',
        'orman-2-10',
      ],
    );
    expect(
      route.levels.map((level) => level.index).toList(),
      <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    );
    expect(
      route.levels.map((level) => level.type).toList(),
      <WordHuntLevelType>[
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
      ],
    );
  });

  test('Kadim Orman preserves pilot timing and star difficulty contract', () {
    for (var index = 0; index < route.levels.length; index++) {
      final level = route.levels[index];
      final baseline = ormanYolu.levels[index];

      expect(level.timeLimitSeconds, baseline.timeLimitSeconds);
      expect(
        level.starRules.twoStarMaxMistakes,
        baseline.starRules.twoStarMaxMistakes,
      );
      expect(
        level.starRules.threeStarMaxMistakes,
        baseline.starRules.threeStarMaxMistakes,
      );
      expect(
        level.starRules.twoStarMaxSeconds,
        baseline.starRules.twoStarMaxSeconds,
      );
      expect(
        level.starRules.threeStarMaxSeconds,
        baseline.starRules.threeStarMaxSeconds,
      );
    }
  });

  test('definition and content validators accept all original content', () {
    expect(WordHuntDefinitionValidator.validateRoute(route), isEmpty);
    expect(
      WordHuntContentValidator.validate(
        route: route,
        infoCards: WordHuntOrman2Content.infoCards,
      ),
      isEmpty,
    );
  });

  test('all Kadim Orman grids are unique and independent from Orman Yolu', () {
    final kadimGridSignatures =
        route.levels.map((level) => level.grid.join('\n')).toList();
    final ormanGridSignatures =
        ormanYolu.levels.map((level) => level.grid.join('\n')).toSet();

    expect(kadimGridSignatures.toSet(), hasLength(10));
    for (final signature in kadimGridSignatures) {
      expect(ormanGridSignatures, isNot(contains(signature)));
    }

    for (var index = 0; index < route.levels.length; index++) {
      expect(
        route.levels[index].targetWords,
        isNot(equals(ormanYolu.levels[index].targetWords)),
      );
    }
  });

  test('target and bonus words never overlap', () {
    for (final level in route.levels) {
      expect(
        level.targetWords.toSet().intersection(level.bonusWords.toSet()),
        isEmpty,
        reason: level.id,
      );
    }
  });

  test('Kadim Orman owns six unique route-scoped info cards', () {
    final cards = WordHuntOrman2Content.infoCards;
    expect(cards, hasLength(6));
    expect(cards.map((card) => card.id).toSet(), hasLength(6));
    expect(
      cards.map((card) => card.id).toList(),
      <String>[
        'kadim-info-egrelti',
        'kadim-info-sis',
        'kadim-info-misel',
        'kadim-info-baykus',
        'kadim-info-kaynak',
        'kadim-info-cinar',
      ],
    );
    expect(cards.every((card) => card.category == 'Doğa'), isTrue);
  });

  test('Kadim Orman info card copy is exact and cautious', () {
    final cardsById = <String, WordHuntInfoCard>{
      for (final card in WordHuntOrman2Content.infoCards) card.id: card,
    };

    expect(cardsById['kadim-info-egrelti']?.word, 'EĞRELTİ');
    expect(cardsById['kadim-info-egrelti']?.title, 'Eğrelti');
    expect(
      cardsById['kadim-info-egrelti']?.shortFact,
      'Eğreltiler çiçek ve tohum oluşturmak yerine sporlarla çoğalan damarlı bitkilerdir.',
    );

    expect(cardsById['kadim-info-sis']?.word, 'SİS');
    expect(cardsById['kadim-info-sis']?.title, 'Sis');
    expect(
      cardsById['kadim-info-sis']?.shortFact,
      'Sis, yere yakın havada asılı duran çok küçük su damlacıkları veya uygun koşullarda buz kristallerinden oluşur.',
    );

    expect(cardsById['kadim-info-misel']?.word, 'MİSEL');
    expect(cardsById['kadim-info-misel']?.title, 'Misel');
    expect(
      cardsById['kadim-info-misel']?.shortFact,
      'Misel, mantarın çoğu zaman gözden uzakta kalan ince ipliksi yapılardan oluşan ağıdır.',
    );

    expect(cardsById['kadim-info-baykus']?.word, 'BAYKUŞ');
    expect(cardsById['kadim-info-baykus']?.title, 'Baykuş');
    expect(
      cardsById['kadim-info-baykus']?.shortFact,
      'Birçok baykuş türü, düşük ışıkta avlanmaya yardımcı olan görme ve işitme uyumlarına sahiptir.',
    );

    expect(cardsById['kadim-info-kaynak']?.word, 'KAYNAK');
    expect(cardsById['kadim-info-kaynak']?.title, 'Kaynak');
    expect(
      cardsById['kadim-info-kaynak']?.shortFact,
      'Kaynak, yer altı suyunun doğal olarak yeryüzüne çıktığı yerdir.',
    );

    expect(cardsById['kadim-info-cinar']?.word, 'ÇINAR');
    expect(cardsById['kadim-info-cinar']?.title, 'Çınar');
    expect(
      cardsById['kadim-info-cinar']?.shortFact,
      'Çınarlar uzun yıllar yaşayabilir; gövdelerindeki büyüme halkaları geçmiş büyüme hakkında bilgi verebilir.',
    );
  });

  test('info cards are connected only to approved levels', () {
    expect(route.levels[0].infoCardIds, <String>['kadim-info-egrelti']);
    expect(route.levels[1].infoCardIds, <String>['kadim-info-sis']);
    expect(route.levels[2].infoCardIds, isEmpty);
    expect(route.levels[3].infoCardIds, <String>['kadim-info-misel']);
    expect(route.levels[4].infoCardIds, <String>['kadim-info-baykus']);
    expect(route.levels[5].infoCardIds, isEmpty);
    expect(route.levels[6].infoCardIds, <String>['kadim-info-kaynak']);
    expect(route.levels[7].infoCardIds, isEmpty);
    expect(route.levels[8].infoCardIds, <String>['kadim-info-cinar']);
    expect(route.levels[9].infoCardIds, isEmpty);
  });

  test('production content source has no Orman Yolu clone/reuse debt', () {
    final source = File(
      'lib/word_hunt/word_hunt_orman2_content.dart',
    ).readAsStringSync();

    expect(source, isNot(contains("import 'word_hunt_orman_content.dart'")));
    expect(source, isNot(contains('WordHuntOrmanContent.infoCards')));
    expect(source, isNot(contains('WordHuntOrmanContent.ormanYolu.levels')));
    expect(source, isNot(contains('_clonePilotLevels')));
  });
}
