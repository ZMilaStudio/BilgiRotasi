import 'dart:convert';

import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('schema 2 roundtrip preserves stars infoCards and route rewards', () {
    const snapshot = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        'baslangic-2': 3,
        'baslangic-1': 2,
      },
      unlockedInfoCardIds: <String>{'kart-z', 'kart-a'},
      unlockedRouteRewardIds: <String>{
        'badge-gokyuzu-kasifi',
        'badge-kelime-yolcusu',
      },
    );

    final raw = WordHuntProgressCodec.encode(snapshot, ownerScope: 'user_abc');
    final payload = jsonDecode(raw) as Map<String, dynamic>;
    expect(payload['schema'], 2);

    final restored = WordHuntProgressCodec.decode(
      raw,
      expectedOwnerScope: 'user_abc',
    );
    expect(restored.bestStarsByLevelId, snapshot.bestStarsByLevelId);
    expect(restored.unlockedInfoCardIds, snapshot.unlockedInfoCardIds);
    expect(
      restored.unlockedRouteRewardIds,
      snapshot.unlockedRouteRewardIds,
    );

    expect(raw.indexOf('baslangic-1'), lessThan(raw.indexOf('baslangic-2')));
    expect(raw.indexOf('kart-a'), lessThan(raw.indexOf('kart-z')));
    expect(
      raw.indexOf('badge-gokyuzu-kasifi'),
      lessThan(raw.indexOf('badge-kelime-yolcusu')),
    );
  });

  test('real schema 1 payload decodes without losing progression', () {
    const raw = '''{"schema":1,"ownerScope":"guest","bestStarsByLevelId":{"baslangic-1":3,"baslangic-10":1},"unlockedInfoCardIds":["kart-a","kart-b"]}''';

    final restored = WordHuntProgressCodec.decode(
      raw,
      expectedOwnerScope: 'guest',
    );

    expect(restored.starsFor('baslangic-1'), 3);
    expect(restored.starsFor('baslangic-10'), 1);
    expect(restored.unlockedInfoCardIds, <String>{'kart-a', 'kart-b'});
    expect(restored.unlockedRouteRewardIds, isEmpty);
  });

  test('unknown future schema remains fail-closed', () {
    const raw = '''{"schema":3,"ownerScope":"guest","bestStarsByLevelId":{},"unlockedInfoCardIds":[],"unlockedRouteRewardIds":[]}''';

    expect(
      () => WordHuntProgressCodec.decode(raw, expectedOwnerScope: 'guest'),
      throwsFormatException,
    );
  });

  test('schema 2 requires valid reward list', () {
    const missing = '''{"schema":2,"ownerScope":"guest","bestStarsByLevelId":{},"unlockedInfoCardIds":[]}''';
    const invalid = '''{"schema":2,"ownerScope":"guest","bestStarsByLevelId":{},"unlockedInfoCardIds":[],"unlockedRouteRewardIds":[""]}''';

    expect(
      () => WordHuntProgressCodec.decode(missing, expectedOwnerScope: 'guest'),
      throwsFormatException,
    );
    expect(
      () => WordHuntProgressCodec.decode(invalid, expectedOwnerScope: 'guest'),
      throwsFormatException,
    );
  });

  test('live v1 storage key prefix stays unchanged', () {
    expect(
      WordHuntProgressCodec.storageKeyForUid(null),
      'bilgi_rotasi_word_hunt_progress_v1_guest',
    );
    expect(
      WordHuntProgressCodec.storageKeyForUid('  uid123  '),
      'bilgi_rotasi_word_hunt_progress_v1_user_uid123',
    );
  });
}
