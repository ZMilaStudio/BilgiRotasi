import 'journey_preferences_store.dart';

class WordHuntProductionJourneyRepository extends JourneyPreferencesRepository {
  WordHuntProductionJourneyRepository({super.preferences})
    : super(storageKey: key);
  static const key = 'kelime_avi_journey_save_v1';
}
