import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_hunt_domain/word_hunt_progress_codec.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_host.dart';

/// Platform-neutral key/value boundary, kept injectable for standalone tests.
abstract interface class WordHuntStandalonePreferences {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
}

class WordHuntStandaloneProgressStore implements WordHuntProgressStore {
  WordHuntStandaloneProgressStore({WordHuntStandalonePreferences? preferences})
    : _preferences = preferences ?? _SharedPreferencesAdapter();

  final WordHuntStandalonePreferences _preferences;

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<bool?> getBool(String key) => _preferences.getBool(key);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);
}

class WordHuntStandaloneProgressStorageIdentity
    implements WordHuntProgressStorageIdentity {
  const WordHuntStandaloneProgressStorageIdentity();

  static const String progressPrefix = 'kelime_avi_standalone_progress_v1_';
  static const String kristalRevealSeenPrefix =
      'kelime_avi_standalone_seen_kristal_vadisi_reveal_v1_';

  @override
  String ownerScopeForUid(String? ownerUid) =>
      WordHuntProgressCodec.scopeForUid(ownerUid);

  @override
  String progressStorageKeyForUid(String? ownerUid) =>
      '$progressPrefix${ownerScopeForUid(ownerUid)}';

  @override
  String kristalRevealSeenKeyForUid(String? ownerUid) =>
      '$kristalRevealSeenPrefix${ownerScopeForUid(ownerUid)}';
}

class _SharedPreferencesAdapter implements WordHuntStandalonePreferences {
  SharedPreferencesAsync? _instance;

  SharedPreferencesAsync get _preferences =>
      _instance ??= SharedPreferencesAsync();

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<bool?> getBool(String key) => _preferences.getBool(key);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);
}
