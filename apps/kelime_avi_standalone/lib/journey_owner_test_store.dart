import 'journey_preferences_store.dart';
export 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';

typedef JourneyOwnerPreferences = JourneyPreferences;

/// Harness-only persistence. Never reads, migrates or writes legacy keys.
class JourneyOwnerTestRepository extends JourneyPreferencesRepository {
  JourneyOwnerTestRepository({super.preferences}) : super(storageKey: key);
  static const key = 'kelime_avi_journey_owner_test_save_v1';
}
