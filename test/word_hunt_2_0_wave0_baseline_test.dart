import 'dart:convert';

import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wave 0 migration baselines.
///
/// These snapshots lock immutable migration identities plus the reviewed current
/// Segment 1 content state. Content fingerprints are NOT an "immutable forever"
/// rule: Wave 8 applies the owner-approved legacy duplicate correction only to
/// the affected routes. The exact pre-Wave8 duplicate pairs remain frozen below
/// as historical migration evidence. Route IDs, level IDs, indexes and routeId
/// mappings remain immutable migration identities.
void main() {
  const expectedRouteIds = <String>[
    'baslangic-limani',
    'gokyuzu-adalari',
    'orman-yolu',
    'orman-2',
    'kristal-vadisi',
    'kayip-sehir',
    'yeralti-kralligi',
    'gunes-imparatorlugu',
  ];

  const expectedLevelIds = <String, List<String>>{
    'baslangic-limani': <String>[
      'baslangic-1',
      'baslangic-2',
      'baslangic-3',
      'baslangic-4',
      'baslangic-5',
      'baslangic-6',
      'baslangic-7',
      'baslangic-8',
      'baslangic-9',
      'baslangic-10',
    ],
    'gokyuzu-adalari': <String>[
      'gokyuzu-1',
      'gokyuzu-2',
      'gokyuzu-3',
      'gokyuzu-4',
      'gokyuzu-5',
      'gokyuzu-6',
      'gokyuzu-7',
      'gokyuzu-8',
      'gokyuzu-9',
      'gokyuzu-10',
    ],
    'orman-yolu': <String>[
      'orman-yolu-01',
      'orman-yolu-02',
      'orman-yolu-03',
      'orman-yolu-04',
      'orman-yolu-05',
      'orman-yolu-06',
      'orman-yolu-07',
      'orman-yolu-08',
      'orman-yolu-09',
      'orman-yolu-10',
    ],
    'orman-2': <String>[
      'orman-2-01',
      'orman-2-02',
      'orman-2-03',
      'orman-2-04',
      'orman-2-05',
      'orman-2-06',
      'orman-2-07',
      'orman-2-08',
      'orman-2-09',
      'orman-2-10',
    ],
    'kristal-vadisi': <String>[
      'kristal-vadisi-01',
      'kristal-vadisi-02',
      'kristal-vadisi-03',
      'kristal-vadisi-04',
      'kristal-vadisi-05',
      'kristal-vadisi-06',
      'kristal-vadisi-07',
      'kristal-vadisi-08',
      'kristal-vadisi-09',
      'kristal-vadisi-10',
    ],
    'kayip-sehir': <String>[
      'kayip-sehir-01',
      'kayip-sehir-02',
      'kayip-sehir-03',
      'kayip-sehir-04',
      'kayip-sehir-05',
      'kayip-sehir-06',
      'kayip-sehir-07',
      'kayip-sehir-08',
      'kayip-sehir-09',
      'kayip-sehir-10',
    ],
    'yeralti-kralligi': <String>[
      'yeralti-kralligi-01',
      'yeralti-kralligi-02',
      'yeralti-kralligi-03',
      'yeralti-kralligi-04',
      'yeralti-kralligi-05',
      'yeralti-kralligi-06',
      'yeralti-kralligi-07',
      'yeralti-kralligi-08',
      'yeralti-kralligi-09',
      'yeralti-kralligi-10',
    ],
    'gunes-imparatorlugu': <String>[
      'gunes-imparatorlugu-01',
      'gunes-imparatorlugu-02',
      'gunes-imparatorlugu-03',
      'gunes-imparatorlugu-04',
      'gunes-imparatorlugu-05',
      'gunes-imparatorlugu-06',
      'gunes-imparatorlugu-07',
      'gunes-imparatorlugu-08',
      'gunes-imparatorlugu-09',
      'gunes-imparatorlugu-10',
    ],
  };

  const expectedContentFingerprints = <String, String>{
    'baslangic-limani': '39462daa',
    'gokyuzu-adalari': '2fd4e4af',
    'orman-yolu': '7aae6da3',
    'orman-2': '71084c8f',
    'kristal-vadisi': 'fcd1e9ce',
    'kayip-sehir': '5c9041c4',
    'yeralti-kralligi': '71d752f6',
    'gunes-imparatorlugu': '0a6c7f40',
  };

  const preWave8DuplicateDebt = <String, List<String>>{
    'baslangic-limani': <String>[
      'KALEM|baslangic-1:TARGET|baslangic-3:TARGET',
      'ÇİÇEK|baslangic-6:TARGET|baslangic-7:TARGET',
      'DOĞA|baslangic-6:TARGET|baslangic-7:BONUS',
      'KOŞU|baslangic-4:BONUS|baslangic-8:TARGET',
      'BİLGİ|baslangic-1:TARGET|baslangic-10:TARGET',
      'YILDIZ|baslangic-9:TARGET|baslangic-10:TARGET',
      'HEDEF|baslangic-4:TARGET|baslangic-10:TARGET',
    ],
    'gokyuzu-adalari': <String>[
      'BULUT|gokyuzu-1:TARGET|gokyuzu-2:TARGET',
      'KANAT|gokyuzu-1:TARGET|gokyuzu-3:TARGET',
      'UÇUŞ|gokyuzu-1:TARGET|gokyuzu-3:TARGET',
      'RÜZGAR|gokyuzu-1:TARGET|gokyuzu-5:TARGET',
      'YAĞMUR|gokyuzu-4:TARGET|gokyuzu-5:TARGET',
      'BULUT|gokyuzu-1:TARGET|gokyuzu-5:TARGET',
      'IŞIK|gokyuzu-4:TARGET|gokyuzu-7:TARGET',
      'İSKELE|gokyuzu-6:TARGET|gokyuzu-7:TARGET',
      'GÖLGE|gokyuzu-2:TARGET|gokyuzu-7:TARGET',
      'YILDIZ|gokyuzu-7:TARGET|gokyuzu-9:TARGET',
      'IŞIK|gokyuzu-4:TARGET|gokyuzu-9:TARGET',
      'GÜNEŞ|gokyuzu-4:TARGET|gokyuzu-10:TARGET',
      'IŞIK|gokyuzu-4:TARGET|gokyuzu-10:TARGET',
      'GÖKYÜZÜ|gokyuzu-7:TARGET|gokyuzu-10:TARGET',
    ],
    'orman-yolu': <String>[
      'KÖK|orman-yolu-01:TARGET|orman-yolu-02:TARGET',
      'ORMAN|orman-yolu-01:TARGET|orman-yolu-02:TARGET',
      'MEŞE|orman-yolu-02:TARGET|orman-yolu-03:TARGET',
      'KUŞ|orman-yolu-02:TARGET|orman-yolu-03:TARGET',
      'TOPRAK|orman-yolu-03:TARGET|orman-yolu-04:TARGET',
      'GÖLGE|orman-yolu-03:BONUS|orman-yolu-04:TARGET',
      'KOZALAK|orman-yolu-04:TARGET|orman-yolu-05:TARGET',
      'DERE|orman-yolu-04:TARGET|orman-yolu-05:TARGET',
      'ÇİÇEK|orman-yolu-05:TARGET|orman-yolu-06:TARGET',
      'OTLAR|orman-yolu-05:TARGET|orman-yolu-06:TARGET',
      'SİNCAP|orman-yolu-06:TARGET|orman-yolu-07:TARGET',
      'GEYİK|orman-yolu-06:BONUS|orman-yolu-07:TARGET',
      'AĞAÇ|orman-yolu-01:TARGET|orman-yolu-07:TARGET',
      'YAPRAK|orman-yolu-01:TARGET|orman-yolu-07:TARGET',
      'DAL|orman-yolu-01:TARGET|orman-yolu-07:TARGET',
      'DERE|orman-yolu-04:TARGET|orman-yolu-08:TARGET',
      'PATİKA|orman-yolu-05:TARGET|orman-yolu-08:TARGET',
      'ORMAN|orman-yolu-01:TARGET|orman-yolu-10:TARGET',
    ],
    'orman-2': <String>[
      'YANKI|orman-2-02:BONUS|orman-2-05:BONUS',
      'AKINTI|orman-2-03:BONUS|orman-2-07:TARGET',
      'SERİN|orman-2-02:TARGET|orman-2-07:BONUS',
      'OYMA|orman-2-06:TARGET|orman-2-08:TARGET',
      'HALKA|orman-2-04:BONUS|orman-2-08:BONUS',
      'HALKA|orman-2-04:BONUS|orman-2-09:TARGET',
      'KABUK|orman-2-01:TARGET|orman-2-09:TARGET',
    ],
    'kristal-vadisi': <String>[],
    'kayip-sehir': <String>[],
    'yeralti-kralligi': <String>[],
    'gunes-imparatorlugu': <String>[],
  };

  test('Wave 0 locks exact production route IDs', () {
    expect(
      WordHuntRouteCatalog.entries.map((entry) => entry.route.id).toList(),
      expectedRouteIds,
    );
  });

  test('Wave 0 locks legacy level IDs indexes and route mapping', () {
    for (final entry in WordHuntRouteCatalog.entries) {
      final route = entry.route;
      final ids = expectedLevelIds[route.id];
      expect(ids, isNotNull, reason: 'Missing baseline for ${route.id}');
      expect(route.levels, hasLength(10), reason: route.id);
      expect(
        route.levels.map((level) => level.id).toList(),
        ids,
        reason: route.id,
      );

      for (var offset = 0; offset < route.levels.length; offset++) {
        final level = route.levels[offset];
        expect(level.index, offset + 1, reason: level.id);
        expect(level.routeId, route.id, reason: level.id);
      }
    }
  });

  test('Wave 0 locks reviewed Wave 8 Segment 1 content fingerprints', () {
    final actual = <String, String>{
      for (final entry in WordHuntRouteCatalog.entries)
        entry.route.id: _contentFingerprint(entry.route),
    };

    expect(actual, expectedContentFingerprints);
  });

  test('Wave 0 retains frozen pre-Wave8 duplicate debt evidence', () {
    expect(preWave8DuplicateDebt['baslangic-limani'], hasLength(7));
    expect(preWave8DuplicateDebt['gokyuzu-adalari'], hasLength(14));
    expect(preWave8DuplicateDebt['orman-yolu'], hasLength(18));
    expect(preWave8DuplicateDebt['orman-2'], hasLength(7));
    expect(preWave8DuplicateDebt['kristal-vadisi'], isEmpty);
    expect(preWave8DuplicateDebt['kayip-sehir'], isEmpty);
    expect(preWave8DuplicateDebt['yeralti-kralligi'], isEmpty);
    expect(preWave8DuplicateDebt['gunes-imparatorlugu'], isEmpty);
  });

  test(
    'Wave 0 current Segment 1 content has zero duplicate debt after Wave 8',
    () {
      for (final entry in WordHuntRouteCatalog.entries) {
        expect(_duplicateDebt(entry.route), isEmpty, reason: entry.route.id);
      }
    },
  );

  test('Wave 0 storage identity survives owner-approved Wave 2 schema v3', () {
    expect(WordHuntProgressCodec.schemaVersion, 3);

    const snapshot = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{'baslangic-1': 3, 'gokyuzu-1': 2},
      unlockedInfoCardIds: <String>{'kart-a', 'kart-b'},
      unlockedRouteRewardIds: <String>{
        'badge-kelime-yolcusu',
        'badge-gokyuzu-kasifi',
      },
    );

    final raw = WordHuntProgressCodec.encode(
      snapshot,
      ownerScope: 'user_wave0',
    );
    final payload = jsonDecode(raw) as Map<String, dynamic>;

    expect(payload['schema'], 3);
    expect(payload['ownerScope'], 'user_wave0');
    expect(payload.keys.toSet(), <String>{
      'schema',
      'ownerScope',
      'bestStarsByLevelId',
      'unlockedInfoCardIds',
      'unlockedRouteRewardIds',
      'bestBonusFoundCountByLevelId',
      'grandfatheredUnlockedRouteIds',
      'lastActiveRouteId',
    });

    final restored = WordHuntProgressCodec.decode(
      raw,
      expectedOwnerScope: 'user_wave0',
    );
    expect(restored.bestStarsByLevelId, snapshot.bestStarsByLevelId);
    expect(restored.unlockedInfoCardIds, snapshot.unlockedInfoCardIds);
    expect(restored.unlockedRouteRewardIds, snapshot.unlockedRouteRewardIds);
    expect(restored.bestBonusFoundCountByLevelId, isEmpty);
    expect(restored.grandfatheredUnlockedRouteIds, isEmpty);
    expect(restored.lastActiveRouteId, isNull);

    expect(
      () => WordHuntProgressCodec.decode(raw, expectedOwnerScope: 'user_other'),
      throwsFormatException,
    );

    expect(
      WordHuntProgressCodec.storageKeyForUid(null),
      'bilgi_rotasi_word_hunt_progress_v1_guest',
    );
    expect(
      WordHuntProgressCodec.storageKeyForUid('abc'),
      'bilgi_rotasi_word_hunt_progress_v1_user_abc',
    );
  });

  test('Wave 0 real schema 1 fixture remains readable after v3 migration', () {
    const raw =
        '{"schema":1,"ownerScope":"guest",'
        '"bestStarsByLevelId":{"baslangic-1":3,"baslangic-10":1},'
        '"unlockedInfoCardIds":["kart-a","kart-b"]}';

    final restored = WordHuntProgressCodec.decode(
      raw,
      expectedOwnerScope: 'guest',
    );

    expect(restored.starsFor('baslangic-1'), 3);
    expect(restored.starsFor('baslangic-10'), 1);
    expect(restored.unlockedInfoCardIds, <String>{'kart-a', 'kart-b'});
    expect(restored.unlockedRouteRewardIds, isEmpty);
  });
}

String _contentFingerprint(WordHuntRouteDefinition route) {
  final lines = <String>[route.id];

  for (final level in route.levels) {
    lines
      ..add('${level.index}|${level.id}|${level.routeId}')
      ..add('G:${level.grid.join("/")}')
      ..add('T:${level.targetWords.join("|")}')
      ..add('B:${level.bonusWords.join("|")}');
  }

  return _fnv1a32Hex(lines.join('\n'));
}

List<String> _duplicateDebt(WordHuntRouteDefinition route) {
  final firstUse = <String, String>{};
  final debt = <String>[];

  void record(WordHuntLevelDefinition level, String role, String rawWord) {
    final normalized = WordHuntPathEngine.normalizeWord(rawWord);
    final current = '${level.id}:$role';
    final first = firstUse[normalized];

    if (first == null) {
      firstUse[normalized] = current;
      return;
    }

    debt.add('$normalized|$first|$current');
  }

  for (final level in route.levels) {
    for (final word in level.targetWords) {
      record(level, 'TARGET', word);
    }
    for (final word in level.bonusWords) {
      record(level, 'BONUS', word);
    }
  }

  return debt;
}

String _fnv1a32Hex(String value) {
  const offsetBasis = 0x811c9dc5;
  const prime = 0x01000193;
  const mask32 = 0xffffffff;

  var hash = offsetBasis;
  for (final byte in utf8.encode(value)) {
    hash ^= byte;
    hash = (hash * prime) & mask32;
  }

  return hash.toRadixString(16).padLeft(8, '0');
}
