/// Greenfield identity and metadata: no route, theme or save ordinal keys.
class JourneyLevelRecord {
  const JourneyLevelRecord({
    required this.stableId,
    required this.ordinal,
    required this.published,
    this.gameplayContentId,
    this.challenge = false,
    this.milestone = false,
  });
  final String stableId;
  final int ordinal;
  final bool published;
  final String? gameplayContentId;
  final bool challenge, milestone;
}

String journeyStableId(int ordinal) {
  if (ordinal < 1) throw RangeError.range(ordinal, 1, null, 'ordinal');
  return 'level_${ordinal.toString().padLeft(6, '0')}';
}

abstract interface class JourneyCatalog {
  int get publishedLevelCount;
  JourneyLevelRecord? recordForOrdinal(int ordinal);
  JourneyLevelRecord? recordForStableId(String stableId);
  bool isPublished(int ordinal);
  JourneyLevelRecord? get firstPublished;
  JourneyLevelRecord? get lastPublished;
  int? nextOrdinal(int ordinal);
  int? previousOrdinal(int ordinal);
}
