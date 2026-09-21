import 'dart:convert';
import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

const _lockPath = 'tools/word_hunt_segment1_source_lock.json';

const _expectedRouteIds = <String>[
  'baslangic-limani',
  'gokyuzu-adalari',
  'orman-yolu',
  'orman-2',
  'kristal-vadisi',
  'kayip-sehir',
  'yeralti-kralligi',
  'gunes-imparatorlugu',
];

const _expectedFingerprints = <String, String>{
  'baslangic-limani': '39462daa',
  'gokyuzu-adalari': '2fd4e4af',
  'orman-yolu': 'de4fe1f9',
  'orman-2': '71084c8f',
  'kristal-vadisi': 'fcd1e9ce',
  'kayip-sehir': '5c9041c4',
  'yeralti-kralligi': '71d752f6',
  'gunes-imparatorlugu': '0a6c7f40',
};

const _expectedReservedCounts = <String, int>{
  'baslangic-limani': 80,
  'gokyuzu-adalari': 80,
  'orman-yolu': 54,
  'orman-2': 67,
  'kristal-vadisi': 70,
  'kayip-sehir': 70,
  'yeralti-kralligi': 70,
  'gunes-imparatorlugu': 70,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave 9 Segment 1 source lock', () {
    test('checked-in lock is mechanically identical to production catalog', () {
      final decoded =
          jsonDecode(File(_lockPath).readAsStringSync()) as Map<String, dynamic>;
      expect(decoded['schemaVersion'], 1);
      expect(decoded['lockVersion'], 'wave8-segment1-v1');
      expect(
        decoded['wave8ImplementationAuthority'],
        'd07ec30d82ca97931d0a72589d649ff93daae366',
      );
      expect(
        decoded['wave8FinalIntegrationAuthority'],
        'c289b09b186d3e97d7b13413f84ebc7c994a52f4',
      );

      final lockedRoutes =
          (decoded['routes'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(
        lockedRoutes.map((route) => route['routeId']).toList(),
        _expectedRouteIds,
      );
      expect(
        WordHuntRouteCatalog.entries.map((entry) => entry.route.id).toList(),
        _expectedRouteIds,
      );

      for (var offset = 0; offset < WordHuntRouteCatalog.entries.length; offset++) {
        final route = WordHuntRouteCatalog.entries[offset].route;
        final locked = lockedRoutes[offset];

        expect(route.levels, hasLength(10), reason: route.id);
        expect(
          route.levels.map((level) => level.index).toList(),
          List<int>.generate(10, (index) => index + 1),
          reason: route.id,
        );

        final fingerprint = _contentFingerprint(route);
        expect(fingerprint, _expectedFingerprints[route.id], reason: route.id);
        expect(locked['contentFingerprint'], fingerprint, reason: route.id);

        final origins = <String, Map<String, Object>>{};
        for (final level in route.levels) {
          expect(level.routeId, route.id, reason: level.id);
          for (final word in level.targetWords) {
            _recordOrigin(origins, route, level, word, 'TARGET');
          }
          for (final word in level.bonusWords) {
            _recordOrigin(origins, route, level, word, 'BONUS');
          }
        }

        final reservedWords = origins.keys.toList()..sort();
        expect(
          reservedWords.length,
          _expectedReservedCounts[route.id],
          reason: route.id,
        );
        expect(locked['reservedWordCount'], reservedWords.length, reason: route.id);
        expect(
          (locked['reservedWords'] as List<dynamic>).cast<String>(),
          reservedWords,
          reason: route.id,
        );

        final lockedOrigins =
            (locked['wordOrigins'] as List<dynamic>).cast<Map<String, dynamic>>();
        final actualOrigins = <Map<String, Object>>[
          for (final word in reservedWords) origins[word]!,
        ];
        expect(lockedOrigins, actualOrigins, reason: route.id);
      }
    });

    test('runtime normalization parity covers Turkish i and ı', () {
      expect(WordHuntPathEngine.normalizeWord('i'), 'İ');
      expect(WordHuntPathEngine.normalizeWord('ı'), 'I');
      expect(WordHuntPathEngine.normalizeWord('  bilgi  '), 'BİLGİ');
      expect(WordHuntPathEngine.normalizeWord('güneş'), 'GÜNEŞ');
    });
  });
}

void _recordOrigin(
  Map<String, Map<String, Object>> origins,
  WordHuntRouteDefinition route,
  WordHuntLevelDefinition level,
  String rawWord,
  String role,
) {
  final word = WordHuntPathEngine.normalizeWord(rawWord);
  final previous = origins[word];
  expect(
    previous,
    isNull,
    reason:
        'Segment1 duplicate debt must stay zero: '
        '${route.id} / $word / first=$previous / new=${level.id}:$role',
  );
  origins[word] = <String, Object>{
    'word': word,
    'levelId': level.id,
    'index': level.index,
    'role': role,
  };
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
