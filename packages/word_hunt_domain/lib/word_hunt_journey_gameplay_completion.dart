/// Normalized outcome; identity always remains Journey identity, not legacy ID.
class JourneyGameplayCompletion {
  JourneyGameplayCompletion({
    required this.stableLevelId,
    required this.earnedStars,
    required this.bonusFoundCount,
    required this.completed,
    required this.challenge,
  }) {
    if (stableLevelId.isEmpty ||
        bonusFoundCount < 0 ||
        (completed ? earnedStars < 1 || earnedStars > 3 : earnedStars != 0)) {
      throw ArgumentError('Invalid Journey completion.');
    }
  }
  final String stableLevelId;
  final int earnedStars, bonusFoundCount;
  final bool completed, challenge;
}
