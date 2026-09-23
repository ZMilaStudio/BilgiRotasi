import 'package:test/test.dart';
import 'package:word_hunt_content/word_hunt_content.dart';
import 'package:word_hunt_domain/word_hunt_models.dart';

void main() {
  group('WordHuntProductionContentCatalog', () {
    test(
      'keeps the exact eight-route production order and level authority',
      () {
        final routes = WordHuntProductionContentCatalog.entries
            .map((entry) => entry.route)
            .toList(growable: false);

        expect(routes.map((route) => route.id), <String>[
          'baslangic-limani',
          'gokyuzu-adalari',
          'orman-yolu',
          'orman-2',
          'kristal-vadisi',
          'kayip-sehir',
          'yeralti-kralligi',
          'gunes-imparatorlugu',
        ]);
        expect(
          routes.fold<int>(0, (total, route) => total + route.levels.length),
          100,
        );
        for (final route in routes) {
          expect(
            WordHuntDefinitionValidator.validateRoute(route),
            isEmpty,
            reason: 'shared content validation failed',
          );
        }
      },
    );

    test('keeps Baslangic Limani frontier and reserved-word authority', () {
      final starter = WordHuntProductionContentCatalog.starter.route;
      final reservedWords = <String>{
        for (final level in starter.levels) ...level.targetWords,
        for (final level in starter.levels) ...level.bonusWords,
      };
      final level30 = starter.levels.singleWhere((level) => level.index == 30);

      expect(starter.availableLevelCount, 30);
      expect(starter.plannedRouteLevelCount, 100);
      expect(
        starter.segments.map(
          (segment) => (segment.startLevelIndex, segment.endLevelIndex),
        ),
        <(int, int)>[(1, 10), (11, 20), (21, 30)],
      );
      expect(reservedWords, hasLength(196));
      expect(level30.type, WordHuntLevelType.challenge);
      expect(level30.type, isNot(WordHuntLevelType.routeFinal));
      expect(starter.levels.any((level) => level.index == 31), isFalse);
    });

    test('keeps pure unlock prerequisite identity in route order', () {
      final entries = WordHuntProductionContentCatalog.entries;
      expect(
        entries.first.unlockRule.kind,
        WordHuntContentRouteUnlockKind.always,
      );
      for (var index = 1; index < entries.length; index++) {
        expect(
          entries[index].unlockRule.kind,
          WordHuntContentRouteUnlockKind.routeComplete,
        );
        expect(
          entries[index].unlockRule.prerequisiteRouteId,
          entries[index - 1].route.id,
        );
      }
    });
  });
}
