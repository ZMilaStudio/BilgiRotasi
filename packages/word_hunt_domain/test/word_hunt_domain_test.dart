import 'package:test/test.dart';
import 'package:word_hunt_domain/word_hunt_domain.dart';

void main() {
  const level = WordHuntLevelDefinition(
    id: 'route-1',
    routeId: 'route',
    index: 1,
    type: WordHuntLevelType.routeFinal,
    grid: <String>['KELIME'],
    targetWords: <String>['KELIME'],
    starRules: WordHuntStarRules(threeStarMaxMistakes: 0),
  );
  final route = WordHuntRouteDefinition(
    id: 'route',
    title: 'Route',
    theme: 'theme',
    unlockStarsRequired: 1,
    levels: <WordHuntLevelDefinition>[level],
    routeRewardId: 'route-reward',
  );

  group('shared pure-Dart domain boundary', () {
    test(
      'keeps path, scoring, codec, and frozen migration semantics available',
      () {
        final result = WordHuntPathEngine.evaluate(
          level: level,
          path: const <WordHuntCell>[
            WordHuntCell(0, 0),
            WordHuntCell(0, 1),
            WordHuntCell(0, 2),
            WordHuntCell(0, 3),
            WordHuntCell(0, 4),
            WordHuntCell(0, 5),
          ],
        );
        expect(result.kind, WordHuntSelectionKind.target);
        expect(
          WordHuntScoringEngine.calculate(
            level: level,
            foundTargetCount: 1,
            mistakes: 0,
            elapsedSeconds: 0,
          ).stars,
          3,
        );

        final decoded = WordHuntProgressCodec.decodeWithMetadata(
          '{"schema":2,"ownerScope":"guest","bestStarsByLevelId":{"route-1":1},"unlockedInfoCardIds":[],"unlockedRouteRewardIds":[]}',
          expectedOwnerScope: 'guest',
        );
        final migrated = WordHuntLegacyProgressMigration.migrate(
          decoded,
          frozenLegacyRoutes: <WordHuntRouteDefinition>[route],
        );
        expect(migrated.starsFor('route-1'), 1);
        expect(migrated.grandfatheredUnlockedRouteIds, <String>{'route'});
        expect(WordHuntProgressCodec.schemaVersion, 3);
        expect(WordHuntProgressCodec.storageKeyForUid(null), contains('guest'));
      },
    );
  });
}
