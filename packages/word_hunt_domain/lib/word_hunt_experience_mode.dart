/// Journey is the default; legacy remains an explicit rollback option.
enum WordHuntExperienceMode { legacy, journey }

WordHuntExperienceMode parseWordHuntExperience(String value) =>
    value == 'legacy'
        ? WordHuntExperienceMode.legacy
        : WordHuntExperienceMode.journey;

final configuredWordHuntExperience = parseWordHuntExperience(
  const String.fromEnvironment('WORD_HUNT_EXPERIENCE', defaultValue: 'journey'),
);
