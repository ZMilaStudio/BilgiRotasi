import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_avi_standalone/main.dart';
import 'package:kelime_avi_standalone/word_hunt_standalone_progress_store.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_entry_screen.dart';

class _MemoryPreferences implements WordHuntStandalonePreferences {
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;
}

void main() {
  test('standalone namespace is schema 3 compatible and distinct', () {
    const identity = WordHuntStandaloneProgressStorageIdentity();

    expect(identity.ownerScopeForUid(null), 'guest');
    expect(
      identity.progressStorageKeyForUid(null),
      'kelime_avi_standalone_progress_v1_guest',
    );
    expect(identity.progressStorageKeyForUid('owner'), contains('user_owner'));
    expect(
      identity.progressStorageKeyForUid('owner'),
      isNot(contains('bilgi_rotasi')),
    );
  });

  test(
    'standalone progress store saves and loads through its host boundary',
    () async {
      final preferences = _MemoryPreferences();
      final store = WordHuntStandaloneProgressStore(preferences: preferences);

      await store.setString(
        'kelime_avi_standalone_progress_v1_guest',
        'payload',
      );
      await store.setBool('kelime_avi_standalone_seen', true);

      expect(
        await store.getString('kelime_avi_standalone_progress_v1_guest'),
        'payload',
      );
      expect(await store.getBool('kelime_avi_standalone_seen'), isTrue);
    },
  );

  testWidgets('standalone shell enters the reusable Word Hunt feature', (
    tester,
  ) async {
    final store = WordHuntStandaloneProgressStore(
      preferences: _MemoryPreferences(),
    );
    await tester.pumpWidget(KelimeAviStandaloneApp(progressStore: store));

    expect(find.text('Kelime Avı'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('kelime_avi_standalone_play_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WordHuntFeatureEntryScreen), findsOneWidget);
  });
}
