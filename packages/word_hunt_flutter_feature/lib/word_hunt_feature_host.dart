/// Persistence boundary supplied by the application host.
///
/// The reusable feature intentionally has no dependency on SharedPreferences,
/// Firebase, or a Bilgi Rotasi application shell.
abstract interface class WordHuntProgressStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
}
