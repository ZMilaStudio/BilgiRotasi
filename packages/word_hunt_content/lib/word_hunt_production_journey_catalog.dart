import 'word_hunt_journey_catalog.dart';
import 'word_hunt_journey_gameplay_resolver.dart';
import 'word_hunt_models.dart';
import 'word_hunt_starter_content.dart';

/// Only actual canonical payloads are published; synthetic scale catalogs stay
/// in QA. Reject gaps/duplicates/missing resolver payloads before booting.
class ProductionJourneyCatalogFactory {
  static PublishedJourneyCatalog create({
    Iterable<WordHuntLevelDefinition>? levels,
    JourneyGameplayResolver? resolver,
  }) {
    final payloads =
        (levels ?? WordHuntStarterContent.baslangicLimani.levels).toList();
    final gameplay = resolver ?? JourneyGameplayResolver();
    final legacyIds = <String>{};
    for (var i = 0; i < payloads.length; i++) {
      final level = payloads[i];
      if (level.index != i + 1 || !legacyIds.add(level.id)) {
        throw StateError(
          'Canonical Journey content must be contiguous and unique',
        );
      }
    }
    final catalog = PublishedJourneyCatalog(
      levelCount: payloads.length,
      metadata: {
        for (final level in payloads)
          level.index: JourneyLevelMetadata(
            gameplayContentId: level.id,
            challenge: level.type == WordHuntLevelType.challenge,
          ),
      },
    );
    for (final level in payloads) {
      final record = catalog.recordForOrdinal(level.index)!;
      if (!gameplay.hasGameplayContent(record.stableId) ||
          !identical(gameplay.resolve(record), level)) {
        throw StateError(
          'Published Journey record lacks its canonical payload',
        );
      }
    }
    return catalog;
  }
}
