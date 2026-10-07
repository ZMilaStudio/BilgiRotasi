import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_v1.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_codec.dart';

void main() {
  const codec = WordHuntJourneySaveCodec();
  test('duplicate JSON identity and escaped aliases fail closed', () {
    const tail = ',"bestBonusByLevelId":{},"lastViewedLevelId":null}';
    expect(
      codec.decode(
        '{"schemaVersion":1,"bestStarsByLevelId":{"level_000001":3,"level_000001":1}$tail',
      ),
      isNull,
    );
    expect(
      codec.decode(
        r'{"schemaVersion":1,"bestStarsByLevelId":{"id":3,"\u0069d":1},"bestBonusByLevelId":{}}',
      ),
      isNull,
    );
    expect(
      codec.decode(
        '{"schemaVersion":1,"schemaVersion":1,"bestStarsByLevelId":{}$tail',
      ),
      isNull,
    );
    final save = WordHuntJourneySaveV1(bestStarsByStableId: {'future"\\id': 3});
    expect(
      codec.decode(codec.encode(save))!.bestStarsByStableId,
      save.bestStarsByStableId,
    );
  });
  test(
    'deterministic JSON, immutable maps and future IDs survive roundtrip',
    () {
      final source = {'level_000002': 2, 'level_000001': 3, 'level_099999': 1};
      final save = WordHuntJourneySaveV1(
        bestStarsByStableId: source,
        bestBonusByStableId: {'level_099999': 5},
        lastViewedLevelId: 'level_099999',
      );
      source.clear();
      expect(save.bestStarsByStableId.length, 3);
      expect(() => save.bestStarsByStableId['x'] = 1, throwsUnsupportedError);
      final encoded = codec.encode(save);
      final decoded = codec.decode(encoded)!;
      expect(decoded.bestStarsByStableId, save.bestStarsByStableId);
      expect(decoded.bestBonusByStableId, save.bestBonusByStableId);
      expect(decoded.lastViewedLevelId, 'level_099999');
      expect(decoded.totalStars, 6);
      expect(codec.encode(decoded), encoded);
      final reordered = WordHuntJourneySaveV1(
        bestStarsByStableId: {
          'level_099999': 1,
          'level_000001': 3,
          'level_000002': 2,
        },
        bestBonusByStableId: save.bestBonusByStableId,
        lastViewedLevelId: save.lastViewedLevelId,
      );
      expect(codec.encode(reordered), encoded);
      final raw = jsonDecode(encoded) as Map<String, dynamic>;
      raw['futureMetadata'] = {'unknown': true};
      expect(
        codec.decode(jsonEncode(raw))!.bestStarsByStableId,
        save.bestStarsByStableId,
      );
    },
  );
  test(
    'corrupt/unsupported input returns null, no partial salvage or clamping',
    () {
      final good =
          jsonDecode(codec.encode(WordHuntJourneySaveV1()))
              as Map<String, dynamic>;
      for (final input in ['', '{', 'null', '[]', '1']) {
        expect(codec.decode(input), isNull);
      }
      for (final schema in [null, 0, 2, '1', 1.0]) {
        expect(
          codec.decode(jsonEncode({...good, 'schemaVersion': schema})),
          isNull,
        );
      }
      for (final stars in [-1, 4, 1.5, '2', null, true]) {
        expect(
          codec.decode(
            jsonEncode({
              ...good,
              'bestStarsByLevelId': {'id': stars},
            }),
          ),
          isNull,
        );
      }
      for (final bonus in [-1, 1.5, '2', null]) {
        expect(
          codec.decode(
            jsonEncode({
              ...good,
              'bestBonusByLevelId': {'id': bonus},
            }),
          ),
          isNull,
        );
      }
      expect(
        codec.decode(
          jsonEncode({
            ...good,
            'bestStarsByLevelId': {'': 1},
          }),
        ),
        isNull,
      );
      expect(
        codec.decode(jsonEncode({...good, 'lastViewedLevelId': 123})),
        isNull,
      );
      expect(
        codec.decode(jsonEncode({...good, 'lastViewedLevelId': ''})),
        isNull,
      );
      expect(
        codec.decode(jsonEncode({...good, 'bestBonusByLevelId': []})),
        isNull,
      );
      final zero = WordHuntJourneySaveV1(
        bestStarsByStableId: {'level_000001': 0},
      );
      expect(
        codec.decode(codec.encode(zero))!.isCompleted('level_000001'),
        isFalse,
      );
    },
  );
  test(
    'in-memory repository load/save/clear isolates snapshots without legacy storage',
    () async {
      final repository = InMemoryJourneySaveRepository();
      expect(await repository.load(), isNull);
      final save = WordHuntJourneySaveV1(
        bestStarsByStableId: {'level_000001': 2},
        bestBonusByStableId: {'level_000001': 3},
        lastViewedLevelId: 'level_000001',
      );
      await repository.save(save);
      final loaded = (await repository.load())!;
      expect(loaded, isNot(same(save)));
      expect(loaded.bestStarsByStableId, save.bestStarsByStableId);
      expect(loaded.bestBonusByStableId, save.bestBonusByStableId);
      expect(loaded.lastViewedLevelId, save.lastViewedLevelId);
      await repository.clear();
      expect(await repository.load(), isNull);
      expect(
        await InMemoryJourneySaveRepository(initialJson: 'broken').load(),
        isNull,
      );
    },
  );
}
