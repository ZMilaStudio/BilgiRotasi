import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_codec.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';

abstract interface class JourneyPreferences {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class _DevicePreferences implements JourneyPreferences {
  final _preferences = SharedPreferencesAsync();
  @override
  Future<String?> read(String key) => _preferences.getString(key);
  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
  @override
  Future<void> remove(String key) => _preferences.remove(key);
}

/// Single-key Save v1 persistence. No legacy import, enumeration, or migration.
class JourneyPreferencesRepository implements JourneySaveRepository {
  JourneyPreferencesRepository({
    required this.storageKey,
    JourneyPreferences? preferences,
  }) : _preferences = preferences ?? _DevicePreferences();
  final String storageKey;
  final JourneyPreferences _preferences;
  final _codec = const WordHuntJourneySaveCodec();
  @override
  Future<WordHuntJourneySaveV1?> load() async {
    final raw = await _preferences.read(storageKey);
    if (raw == null) return null;
    final save = _codec.decode(raw);
    if (save == null) throw const FormatException('Invalid Journey save');
    return save;
  }

  @override
  Future<void> save(WordHuntJourneySaveV1 snapshot) =>
      _preferences.write(storageKey, _codec.encode(snapshot));
  @override
  Future<void> clear() => _preferences.remove(storageKey);
}
