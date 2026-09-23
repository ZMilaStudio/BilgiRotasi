abstract final class WordHuntGokyuzuGameplayBackgrounds {
  static const String bright =
      'assets/word_hunt/gokyuzu_adalari/gameplay_bg_bright.webp';
  static const String storm =
      'assets/word_hunt/gokyuzu_adalari/gameplay_bg_storm.webp';
  static const String airship =
      'assets/word_hunt/gokyuzu_adalari/gameplay_bg_airship.webp';
  static const String moon =
      'assets/word_hunt/gokyuzu_adalari/gameplay_bg_moon.webp';

  static String forLevel(int levelIndex) => switch (levelIndex) {
    5 || 8 => storm,
    6 => airship,
    7 || 9 => moon,
    _ => bright,
  };
}
