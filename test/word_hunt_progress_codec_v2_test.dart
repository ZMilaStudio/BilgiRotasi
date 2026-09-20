import 'dart:convert';

import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('schema 3 encode preserves historical schema2 fields', () {
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
    expect(payload['schema'], 3);

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
    expect(restored.bestBonusFoundCountByLevelId, isEmpty);
    expect(restored.grandfatheredUnlockedRouteIds, isEmpty);
    expect(restored.lastActiveRouteId, isNull);

    expect(raw.indexOf('baslangic-1'), lessThan(raw.indexOf('baslangic-2')));
    expect(raw.indexOf('kart-a'), lessThan(raw.indexOf('kart-z')));
    expect(
      raw.indexOf('badge-gokyuzu-kasifi'),
      lessThan(raw.indexOf('badge-kelime-yolcusu')),
    );
  });

  test('real schema 1 payload remains readable without progression loss', () {
    const raw =
        '{"schema":1,"ownerScope":"guest",'
        '"bestStarsByLevelId":{"baslangic-1":3,"baslangic-10":1},'
        '"unlockedInfoCardIds":["kart-a","kart-b"]}';

    final decoded = WordHuntProgressCodec.decodeWithMetadata(
      raw,
      expectedOwnerScope: 'guest',
    );

    expect(decoded.sourceSchemaVersion, 1);
    expect(decoded.requiresMigrationWriteback, isTrue);
    expect(decoded.snapshot.starsFor('baslangic-1'), 3);
    expect(decoded.snapshot.starsFor('baslangic-10'), 1);
    expect(decoded.snapshot.unlockedInfoCardIds, <String>{'kart-a', 'kart-b'});
    expect(decoded.snapshot.unlockedRouteRewardIds, isEmpty);
  });

  test('real schema 2 payload remains readable with route rewards', () {
    const raw =
        '{"schema":2,"ownerScope":"guest",'
        '"bestStarsByLevelId":{"baslangic-1":3},'
        '"unlockedInfoCardIds":["kart-a"],'
        '"unlockedRouteRewardIds":["badge-kelime-yolcusu"]}';

    final decoded = WordHuntProgressCodec.decodeWithMetadata(
      raw,
      expectedOwnerScope: 'guest',
    );

    expect(decoded.sourceSchemaVersion, 2);
    expect(decoded.requiresMigrationWriteback, isTrue);
    expect(decoded.snapshot.starsFor('baslangic-1'), 3);
    expect(decoded.snapshot.unlockedInfoCardIds, <String>{'kart-a'});
    expect(
      decoded.snapshot.unlockedRouteRewardIds,
      <String>{'badge-kelime-yolcusu'},
    );
    expect(decoded.snapshot.bestBonusFoundCountByLevelId, isEmpty);
  });

  test('unknown future schema remains fail-closed', () {
    const raw =
        '{"schema":4,"ownerScope":"guest","bestStarsByLevelId":{},'
        '"unlockedInfoCardIds":[],"unlockedRouteRewardIds":[],'
        '"bestBonusFoundCountByLevelId":{},'
        '"grandfatheredUnlockedRouteIds":[],"lastActiveRouteId":null}';

    expect(
      () => WordHuntProgressCodec.decode(raw, expectedOwnerScope: 'guest'),
      throwsFormatException,
    );
  });

  test('schema 2 still requires valid reward list', () {
    const missing =
        '{"schema":2,"ownerScope":"guest","bestStarsByLevelId":{},'
        '"unlockedInfoCardIds":[]}';
    const invalid =
        '{"schema":2,"ownerScope":"guest","bestStarsByLevelId":{},'
        '"unlockedInfoCardIds":[],"unlockedRouteRewardIds":[""]}';

    expect(
      () => WordHuntProgressCodec.decode(missing, expectedOwnerScope: 'guest'),
      throwsFormatException,
    );
    expect(
      () => WordHuntProgressCodec.decode(invalid, expectedOwnerScope: 'guest'),
      throwsFormatException,
    );
  });

  test('live v1 storage key prefix stays unchanged under schema 3', () {
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
