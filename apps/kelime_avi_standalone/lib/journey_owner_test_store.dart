import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_codec.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';
export 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';

abstract interface class JourneyOwnerPreferences {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class _DevicePreferences implements JourneyOwnerPreferences {
  final _preferences = SharedPreferencesAsync();
  @override
  Future<String?> read(String key) => _preferences.getString(key);
  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
  @override
  Future<void> remove(String key) => _preferences.remove(key);
}

/// Harness-only persistence. Never reads, migrates or writes legacy keys.
class JourneyOwnerTestRepository implements JourneySaveRepository {
  JourneyOwnerTestRepository({JourneyOwnerPreferences? preferences})
    : _preferences = preferences ?? _DevicePreferences();
  static const key = 'kelime_avi_journey_owner_test_save_v1';
  final JourneyOwnerPreferences _preferences;
  final _codec = const WordHuntJourneySaveCodec();
  @override
  Future<WordHuntJourneySaveV1?> load() async {
    final raw = await _preferences.read(key);
    if (raw == null) return null;
    final save = _codec.decode(raw);
    if (save == null) throw const FormatException('Invalid owner-test save');
    return save;
  }

  @override
  Future<void> save(WordHuntJourneySaveV1 snapshot) =>
      _preferences.write(key, _codec.encode(snapshot));
  @override
  Future<void> clear() => _preferences.remove(key);
}
