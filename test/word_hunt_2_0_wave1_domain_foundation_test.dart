import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_segment_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wave 1 legacy compatibility', () {
    test('current production 8 routes still validate', () {
      expect(WordHuntRouteCatalog.entries, hasLength(8));

      for (final entry in WordHuntRouteCatalog.entries) {
        expect(
          WordHuntDefinitionValidator.validateRoute(entry.route),
          isEmpty,
          reason: entry.route.id,
        );
        expect(entry.route.levels, hasLength(10), reason: entry.route.id);
        expect(entry.route.segments, isEmpty, reason: entry.route.id);
      }
    });

    test('missing displayName keeps deterministic legacy fallback', () {
      final level = _level(index: 7);
      expect(level.displayName, isNull);
      expect(level.displayNameOrFallback, 'Bölüm 7');
    });

    test('explicit displayName is first-class and returned exactly', () {
      final level = _level(index: 7, displayName: 'Sisli Geçit');
      expect(level.displayName, 'Sisli Geçit');
      expect(level.displayNameOrFallback, 'Sisli Geçit');
      expect(WordHuntDefinitionValidator.validateLevel(level), isEmpty);
    });

    test(
      'explicit blank displayName is rejected without breaking fallback',
      () {
        final level = _level(index: 7, displayName: '   ');
        expect(level.displayNameOrFallback, 'Bölüm 7');
        expect(
          WordHuntDefinitionValidator.validateLevel(level),
          contains('level.displayName trim sonrası boş olamaz'),
        );
      },
    );
  });

  group('Wave 1 explicit 2.0 segment foundation', () {
    final route = _v2Route();

    test('synthetic 100-level route validates with exact 10 segments', () {
      expect(route.levels, hasLength(100));
      expect(route.segments, hasLength(10));
      expect(WordHuntSegmentProjection.isExplicitV2Route(route), isTrue);
      expect(WordHuntDefinitionValidator.validateRoute(route), isEmpty);

      for (var offset = 0; offset < route.segments.length; offset++) {
        final segment = route.segments[offset];
        expect(segment.index, offset + 1);
        expect(segment.startLevelIndex, offset * 10 + 1);
        expect(segment.endLevelIndex, offset * 10 + 10);
        expect(segment.levelCount, 10);
      }
    });

    test('absolute/local/segment boundary projection is exact', () {
      const expected = <int, (int, int, int, int)>{
        1: (1, 1, 1, 10),
        10: (1, 10, 1, 10),
        11: (2, 1, 11, 20),
        20: (2, 10, 11, 20),
        21: (3, 1, 21, 30),
        50: (5, 10, 41, 50),
        51: (6, 1, 51, 60),
        90: (9, 10, 81, 90),
        91: (10, 1, 91, 100),
        100: (10, 10, 91, 100),
      };

      for (final entry in expected.entries) {
        final projection = WordHuntSegmentProjection.forLevel(route, entry.key);
        final expectedValue = entry.value;

        expect(projection.absoluteLevelIndex, entry.key);
        expect(projection.segmentIndex, expectedValue.$1);
        expect(projection.localLevelIndex, expectedValue.$2);
        expect(projection.segmentStartLevelIndex, expectedValue.$3);
        expect(projection.segmentEndLevelIndex, expectedValue.$4);
        expect(projection.level.index, entry.key);
        expect(projection.segment.index, expectedValue.$1);
        expect(
          projection.isSegmentStart,
          entry.key == expectedValue.$3,
          reason: 'absolute ${entry.key}',
        );
        expect(
          projection.isSegmentEnd,
          entry.key == expectedValue.$4,
          reason: 'absolute ${entry.key}',
        );
      }
    });

    test('every tenth absolute level is a segment milestone', () {
      for (var absolute = 10; absolute <= 100; absolute += 10) {
        expect(
          WordHuntSegmentProjection.forLevel(
            route,
            absolute,
          ).isSegmentMilestone,
          isTrue,
          reason: 'absolute $absolute',
        );
      }

      for (final absolute in <int>[1, 9, 11, 19, 21, 49, 51, 91, 99]) {
        expect(
          WordHuntSegmentProjection.forLevel(
            route,
            absolute,
          ).isSegmentMilestone,
          isFalse,
          reason: 'absolute $absolute',
        );
      }
    });

    test('only level 50 is the 2.0 major midpoint', () {
      expect(
        WordHuntSegmentProjection.forLevel(route, 49).isMajorMidpoint,
        isFalse,
      );
      expect(
        WordHuntSegmentProjection.forLevel(route, 50).isMajorMidpoint,
        isTrue,
      );
      expect(
        WordHuntSegmentProjection.forLevel(route, 51).isMajorMidpoint,
        isFalse,
      );
    });

    test('only absolute level 100 is the true 2.0 route final', () {
      expect(
        WordHuntSegmentProjection.forLevel(route, 99).isTrueRouteFinal,
        isFalse,
      );
      expect(
        WordHuntSegmentProjection.forLevel(route, 100).isTrueRouteFinal,
        isTrue,
      );
    });

    test('legacy raw routeFinal at L10 is not future true-final authority', () {
      expect(route.levels[9].type, WordHuntLevelType.routeFinal);
      expect(
        WordHuntSegmentProjection.forLevel(route, 10).isTrueRouteFinal,
        isFalse,
      );
      expect(route.levels[99].type, WordHuntLevelType.routeFinal);
      expect(
        WordHuntSegmentProjection.forLevel(route, 100).isTrueRouteFinal,
        isTrue,
      );
    });

    test('segment overlap gap and invalid range are rejected', () {
      final overlap = _v2Route(
        segments: <WordHuntSegmentDefinition>[
          ..._segments().take(1),
          const WordHuntSegmentDefinition(
            id: 'segment-2',
            index: 2,
            displayName: 'Segment 2',
            startLevelIndex: 10,
            endLevelIndex: 20,
          ),
          ..._segments().skip(2),
        ],
      );
      expect(
        WordHuntDefinitionValidator.validateRoute(overlap),
        contains('segment-2: segment aralıkları çakışamaz'),
      );

      final gap = _v2Route(
        segments: <WordHuntSegmentDefinition>[
          ..._segments().take(1),
          const WordHuntSegmentDefinition(
            id: 'segment-2',
            index: 2,
            displayName: 'Segment 2',
            startLevelIndex: 12,
            endLevelIndex: 20,
          ),
          ..._segments().skip(2),
        ],
      );
      expect(
        WordHuntDefinitionValidator.validateRoute(gap),
        contains('segment-2: segment aralıklarında boşluk olamaz'),
      );

      final invalidRange = _v2Route(
        segments: <WordHuntSegmentDefinition>[
          const WordHuntSegmentDefinition(
            id: 'segment-1',
            index: 1,
            displayName: 'Segment 1',
            startLevelIndex: 10,
            endLevelIndex: 1,
          ),
          ..._segments().skip(1),
        ],
      );
      expect(
        WordHuntDefinitionValidator.validateRoute(invalidRange),
        contains('segment-1: segment başlangıcı bitişten büyük olamaz'),
      );
    });

    test('segment identity and display metadata rules are enforced', () {
      final invalid = _v2Route(
        segments: <WordHuntSegmentDefinition>[
          const WordHuntSegmentDefinition(
            id: '',
            index: 1,
            displayName: ' ',
            startLevelIndex: 1,
            endLevelIndex: 10,
          ),
          const WordHuntSegmentDefinition(
            id: 'same',
            index: 2,
            displayName: 'Segment 2',
            startLevelIndex: 11,
            endLevelIndex: 20,
          ),
          const WordHuntSegmentDefinition(
            id: 'same',
            index: 2,
            displayName: 'Segment 3',
            startLevelIndex: 21,
            endLevelIndex: 30,
          ),
          ..._segments().skip(3),
        ],
      );

      final errors = WordHuntDefinitionValidator.validateRoute(invalid);
      expect(errors, contains('segment.id boş olamaz'));
      expect(errors, contains('#1: segment.displayName boş olamaz'));
      expect(errors, contains('segment.id tekrar ediyor: same'));
      expect(errors, contains('segment.index tekrar ediyor: 2'));
      expect(errors, contains('same: segment.index 1..N sıralı olmalı'));
    });

    test('variable target and bonus counts remain valid', () {
      final oneTargetNoBonus = _level(index: 1);
      final twoTargetsOneBonus = _level(
        index: 2,
        targetWords: const <String>['ABC', 'DEF'],
        bonusWords: const <String>['GHI'],
      );
      final challengeNoBonus = _level(
        index: 3,
        type: WordHuntLevelType.challenge,
        targetWords: const <String>['ABC', 'DEF', 'GHI'],
      );

      expect(
        WordHuntDefinitionValidator.validateLevel(oneTargetNoBonus),
        isEmpty,
      );
      expect(
        WordHuntDefinitionValidator.validateLevel(twoTargetsOneBonus),
        isEmpty,
      );
      expect(
        WordHuntDefinitionValidator.validateLevel(challengeNoBonus),
        isEmpty,
      );
    });
  });
}

WordHuntLevelDefinition _level({
  required int index,
  String? displayName,
  WordHuntLevelType type = WordHuntLevelType.normal,
  List<String> targetWords = const <String>['ABC'],
  List<String> bonusWords = const <String>[],
}) {
  return WordHuntLevelDefinition(
    id: 'synthetic-$index',
    routeId: 'synthetic-route',
    index: index,
    type: type,
    grid: const <String>['ABC', 'DEF', 'GHI'],
    targetWords: targetWords,
    bonusWords: bonusWords,
    starRules: const WordHuntStarRules(),
    displayName: displayName,
  );
}

List<WordHuntSegmentDefinition> _segments() {
  return List<WordHuntSegmentDefinition>.generate(10, (offset) {
    final index = offset + 1;
    final start = offset * 10 + 1;
    return WordHuntSegmentDefinition(
      id: 'segment-$index',
      index: index,
      displayName: 'Segment $index',
      startLevelIndex: start,
      endLevelIndex: start + 9,
    );
  }, growable: false);
}

WordHuntRouteDefinition _v2Route({List<WordHuntSegmentDefinition>? segments}) {
  final levels = List<WordHuntLevelDefinition>.generate(100, (offset) {
    final index = offset + 1;
    return _level(
      index: index,
      type:
          index == 10 || index == 100
              ? WordHuntLevelType.routeFinal
              : index == 50
              ? WordHuntLevelType.challenge
              : WordHuntLevelType.normal,
      targetWords:
          index == 50 ? const <String>['ABC', 'DEF'] : const <String>['ABC'],
      bonusWords: index == 20 ? const <String>['GHI'] : const <String>[],
    );
  }, growable: false);

  return WordHuntRouteDefinition(
    id: 'synthetic-route',
    title: 'Synthetic 2.0 Route',
    theme: 'synthetic',
    unlockStarsRequired: 0,
    levels: levels,
    routeRewardId: 'synthetic-reward',
    segments: segments ?? _segments(),
  );
}
