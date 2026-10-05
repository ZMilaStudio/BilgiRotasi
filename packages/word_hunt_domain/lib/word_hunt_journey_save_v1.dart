class WordHuntJourneySaveV1 {
  WordHuntJourneySaveV1({
    Map<String, int> bestStarsByStableId = const {},
    Map<String, int> bestBonusByStableId = const {},
    this.lastViewedLevelId,
  }) : bestStarsByStableId = Map.unmodifiable(bestStarsByStableId),
       bestBonusByStableId = Map.unmodifiable(bestBonusByStableId) {
    for (final entry in this.bestStarsByStableId.entries) {
      if (entry.key.isEmpty || entry.value < 0 || entry.value > 3) {
        throw ArgumentError('Stars must be 0..3 with a nonempty stable ID');
      }
    }
    for (final entry in this.bestBonusByStableId.entries) {
      if (entry.key.isEmpty || entry.value < 0) {
        throw ArgumentError('Bonus must be nonnegative with a stable ID');
      }
    }
    if (lastViewedLevelId != null && lastViewedLevelId!.isEmpty) {
      throw ArgumentError('Last viewed ID must be nonempty');
    }
  }
  static const schemaVersion = 1;
  final Map<String, int> bestStarsByStableId, bestBonusByStableId;
  final String? lastViewedLevelId;
  bool isCompleted(String stableId) => (bestStarsByStableId[stableId] ?? 0) > 0;
  int get totalStars => bestStarsByStableId.values.fold(0, (a, b) => a + b);
}
