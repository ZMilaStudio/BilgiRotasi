import 'word_hunt_models.dart';
import 'word_hunt_orman_content.dart';

/// Orman 2 asset-reuse pilotunun bağımsız route identity'si.
///
/// Pilot yalnız runtime/environment ölçeklenmesini kanıtladığı için gameplay
/// verisini Orman Yolu'ndan reuse eder; level ve route kimlikleri ayrıdır, bu
/// nedenle progression iki rota arasında karışmaz.
abstract final class WordHuntOrman2Content {
  static const List<WordHuntInfoCard> infoCards = WordHuntOrmanContent.infoCards;

  static final WordHuntRouteDefinition orman2 = WordHuntRouteDefinition(
    id: 'orman-2',
    title: 'Orman 2',
    theme: 'orman',
    unlockStarsRequired: 0,
    routeRewardId: 'reward-orman-2',
    levels: _clonePilotLevels(),
  );

  static List<WordHuntLevelDefinition> _clonePilotLevels() =>
      List<WordHuntLevelDefinition>.unmodifiable(
        WordHuntOrmanContent.ormanYolu.levels.map((source) {
          final suffix = source.index.toString().padLeft(2, '0');
          return WordHuntLevelDefinition(
            id: 'orman-2-$suffix',
            routeId: 'orman-2',
            index: source.index,
            type: source.type,
            grid: source.grid,
            targetWords: source.targetWords,
            bonusWords: source.bonusWords,
            starRules: source.starRules,
            infoCardIds: source.infoCardIds,
            timeLimitSeconds: source.timeLimitSeconds,
          );
        }),
      );
}
