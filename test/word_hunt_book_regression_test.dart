import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('existing info-card ownership survives unrelated progress writes', () {
    const before = WordHuntProgressSnapshot(
      unlockedInfoCardIds: <String>{'info-deniz', 'gok-info-ruzgar'},
    );
    final after = before.recordLevelResult(
      levelId: WordHuntStarterContent.baslangicLimani.levels.first.id,
      stars: 1,
    );

    expect(
      after.unlockedInfoCardIds,
      containsAll(<String>{'info-deniz', 'gok-info-ruzgar'}),
    );
  });

  test('schema v3 roundtrip preserves historical unlocked cards without book UI', () {
    const before = WordHuntProgressSnapshot(
      unlockedInfoCardIds: <String>{
        'info-deniz',
        'gok-info-ruzgar',
        'historical-card-id',
      },
    );
    final encoded = WordHuntProgressCodec.encode(before, ownerScope: 'wave7');
    final decoded = WordHuntProgressCodec.decode(
      encoded,
      expectedOwnerScope: 'wave7',
    );

    expect(WordHuntProgressCodec.schemaVersion, 3);
    expect(
      WordHuntProgressCodec.storageKeyForUid('owner'),
      startsWith('bilgi_rotasi_word_hunt_progress_v1_'),
    );
    expect(decoded.unlockedInfoCardIds, before.unlockedInfoCardIds);
  });

  test('existing level info-card metadata remains canonical', () {
    final starterIds = <String>{
      for (final level in WordHuntStarterContent.baslangicLimani.levels)
        ...level.infoCardIds,
    };
    final skyIds = <String>{
      for (final level in WordHuntGokyuzuContent.gokyuzuAdalari.levels)
        ...level.infoCardIds,
    };

    expect(
      WordHuntStarterContent.infoCards
          .map((card) => card.id)
          .toSet()
          .containsAll(starterIds),
      isTrue,
    );
    expect(
      WordHuntGokyuzuContent.infoCards
          .map((card) => card.id)
          .toSet()
          .containsAll(skyIds),
      isTrue,
    );
  });

  test('production entry has no book or compass callback dependency', () {
    final source = File(
      'lib/word_hunt/word_hunt_production_entry_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('_showBook')));
    expect(source, isNot(contains('_showCompassHint')));
    expect(source, isNot(contains('onBook:')));
    expect(source, isNot(contains('onCompass:')));
    expect(source, contains('routeInfoCards: _activeInfoCards'));
  });
}
