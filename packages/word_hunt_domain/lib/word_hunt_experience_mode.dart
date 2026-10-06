/// Default and rollback both preserve the existing legacy experience.
enum WordHuntExperienceMode { legacy, journey }

WordHuntExperienceMode parseWordHuntExperience(String value) =>
    value == 'journey'
        ? WordHuntExperienceMode.journey
        : WordHuntExperienceMode.legacy;

final configuredWordHuntExperience = parseWordHuntExperience(
  const String.fromEnvironment('WORD_HUNT_EXPERIENCE', defaultValue: 'legacy'),
);
