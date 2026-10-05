import 'package:word_hunt_domain/word_hunt_journey_catalog_contract.dart';

export 'package:word_hunt_domain/word_hunt_journey_catalog_contract.dart';

class JourneyLevelMetadata {
  const JourneyLevelMetadata({
    this.gameplayContentId,
    this.challenge = false,
    this.milestone = false,
  });
  final String? gameplayContentId;
  final bool challenge, milestone;
}

/// A contiguous published prefix. Records are computed, not frame-time scans.
class PublishedJourneyCatalog implements JourneyCatalog {
  PublishedJourneyCatalog({
    required this.levelCount,
    int? publishedLevelCount,
    Map<int, JourneyLevelMetadata> metadata = const {},
  }) : publishedLevelCount = publishedLevelCount ?? levelCount,
       _metadata = Map.unmodifiable(metadata) {
    if (levelCount < 0 ||
        this.publishedLevelCount < 0 ||
        this.publishedLevelCount > levelCount) {
      throw ArgumentError('Invalid published catalog range');
    }
    if (_metadata.keys.any((n) => n < 1 || n > levelCount)) {
      throw ArgumentError('Metadata outside catalog');
    }
  }
  final int levelCount;
  @override
  final int publishedLevelCount;
  final Map<int, JourneyLevelMetadata> _metadata;

  @override
  JourneyLevelRecord? recordForOrdinal(int ordinal) {
    if (ordinal < 1 || ordinal > levelCount) return null;
    final metadata = _metadata[ordinal];
    return JourneyLevelRecord(
      stableId: journeyStableId(ordinal),
      ordinal: ordinal,
      published: isPublished(ordinal),
      gameplayContentId: metadata?.gameplayContentId,
      challenge: metadata?.challenge ?? false,
      milestone: metadata?.milestone ?? false,
    );
  }

  @override
  JourneyLevelRecord? recordForStableId(String stableId) {
    if (!stableId.startsWith('level_')) return null;
    final ordinal = int.tryParse(stableId.substring(6));
    if (ordinal == null ||
        ordinal < 1 ||
        journeyStableId(ordinal) != stableId) {
      return null;
    }
    return recordForOrdinal(ordinal);
  }

  @override
  bool isPublished(int ordinal) =>
      ordinal >= 1 && ordinal <= publishedLevelCount;
  @override
  JourneyLevelRecord? get firstPublished =>
      publishedLevelCount == 0 ? null : recordForOrdinal(1);
  @override
  JourneyLevelRecord? get lastPublished =>
      publishedLevelCount == 0 ? null : recordForOrdinal(publishedLevelCount);
  @override
  int? nextOrdinal(int ordinal) =>
      isPublished(ordinal) && isPublished(ordinal + 1) ? ordinal + 1 : null;
  @override
  int? previousOrdinal(int ordinal) =>
      isPublished(ordinal) && ordinal > 1 ? ordinal - 1 : null;
}
