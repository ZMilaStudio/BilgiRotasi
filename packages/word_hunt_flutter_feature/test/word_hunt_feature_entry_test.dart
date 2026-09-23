import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_entry_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_host.dart';

class _MemoryProgressStore implements WordHuntProgressStore {
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}

void main() {
  testWidgets(
    'feature entry instantiates with a host-provided progress store',
    (tester) async {
      final store = _MemoryProgressStore();
      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntFeatureEntryScreen(
            route: WordHuntStarterContent.baslangicLimani,
            infoCards: WordHuntStarterContent.infoCards,
            routeSelectionEnabled: false,
            progressStore: store,
          ),
        ),
      );

      expect(find.byType(WordHuntFeatureEntryScreen), findsOneWidget);
    },
  );
}
