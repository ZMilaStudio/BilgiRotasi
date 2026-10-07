import 'package:word_hunt_domain/word_hunt_journey_catalog_contract.dart';
import 'word_hunt_models.dart';
import 'word_hunt_starter_content.dart';

/// Only real canonical payloads. Publication/access remain catalog/progress
/// concerns; neither a synthetic published record nor a theme creates content.
class JourneyGameplayResolver {
  JourneyGameplayResolver()
    : _levels = Map.unmodifiable({
        for (final level in WordHuntStarterContent.baslangicLimani.levels)
          journeyStableId(level.index): level,
      });
  final Map<String, WordHuntLevelDefinition> _levels;
  bool hasGameplayContent(String stableId) => _levels.containsKey(stableId);
  WordHuntLevelDefinition? resolve(JourneyLevelRecord record) {
    if (!record.published ||
        record.ordinal < 1 ||
        record.stableId != journeyStableId(record.ordinal))
      return null;
    final level = _levels[record.stableId];
    if (record.gameplayContentId != null &&
        record.gameplayContentId != level?.id)
      return null;
    return level;
  }
}
