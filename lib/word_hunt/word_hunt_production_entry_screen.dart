import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_entry_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_host.dart';

import 'word_hunt_models.dart';
import 'word_hunt_starter_content.dart';

/// Bilgi Rotası-specific persistence adapter. The namespace and schema remain
/// feature-domain contracts; only the platform storage implementation stays here.
class WordHuntBilgiRotasiProgressStore implements WordHuntProgressStore {
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

/// Bilgi Rotası app-shell bridge for the reusable Word Hunt Flutter feature.
class WordHuntProductionEntryScreen extends StatelessWidget {
  const WordHuntProductionEntryScreen({
    super.key,
    this.ownerUid,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.infoCards = WordHuntStarterContent.infoCards,
    this.routeSelectionEnabled = true,
  });

  final String? ownerUid;
  final WordHuntRouteDefinition route;
  final List<WordHuntInfoCard> infoCards;
  final bool routeSelectionEnabled;

  @override
  Widget build(BuildContext context) => WordHuntFeatureEntryScreen(
    ownerUid: ownerUid,
    route: route,
    infoCards: infoCards,
    routeSelectionEnabled: routeSelectionEnabled,
    progressStore: WordHuntBilgiRotasiProgressStore(),
  );
}
