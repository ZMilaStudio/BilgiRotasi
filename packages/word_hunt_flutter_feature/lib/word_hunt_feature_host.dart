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

/// Names and scopes used by a host to persist Word Hunt progress.
///
/// The reusable feature owns progress payload semantics, while each host owns
/// its persistence namespace. This keeps a standalone app from reading or
/// writing Bilgi Rotasi progress keys.
abstract interface class WordHuntProgressStorageIdentity {
  String ownerScopeForUid(String? ownerUid);
  String progressStorageKeyForUid(String? ownerUid);
  String kristalRevealSeenKeyForUid(String? ownerUid);
}
