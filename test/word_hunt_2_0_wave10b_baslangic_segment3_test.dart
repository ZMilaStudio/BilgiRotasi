import 'dart:convert';

import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_orchestration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_global_level_numbering.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_rewards.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_segment_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final route = WordHuntRouteCatalog.starter.route;

  test('Wave10B production authority is exact L21-L30 Segment3 content', () {
    expect(route.availableLevelCount, 40);
    expect(route.plannedRouteLevelCount, 100);
    expect(route.segments, hasLength(4));
    expect(
      route.levels.skip(20).take(10).map((level) => (level.id, level.index)).toList(),
      <(String, int)>[
        ('baslangic-21', 21),
        ('baslangic-22', 22),
        ('baslangic-23', 23),
        ('baslangic-24', 24),
        ('baslangic-25', 25),
        ('baslangic-26', 26),
        ('baslangic-27', 27),
        ('baslangic-28', 28),
        ('baslangic-29', 29),
        ('baslangic-30', 30),
      ],
    );

    final expected = <int, (List<String>, List<String>, WordHuntLevelType)>{
      21: (<String>['AVİZE', 'TABAK', 'ÇATAL', 'YORGAN', 'LAMBA', 'ÇARŞAF', 'YATAK', 'MİNDER'], <String>['KUPA'], WordHuntLevelType.normal),
      22: (<String>['KOLTUK', 'DOLAP', 'HAVLU', 'BANYO', 'LAVABO', 'MUSLUK', 'DUŞ', 'KİLİM'], <String>['SÜNGER'], WordHuntLevelType.normal),
      23: (<String>['OTOBÜS', 'TAKSİ', 'DURAK', 'BİLET', 'ŞOFÖR', 'TREN', 'TRAMVAY', 'METRO'], <String>['VAPUR'], WordHuntLevelType.normal),
      24: (<String>['EKMEK', 'PEYNİR', 'YOĞURT', 'REÇEL', 'ÇÖREK', 'SİMİT', 'POĞAÇA', 'TEREYAĞI'], <String>['KAŞIK'], WordHuntLevelType.normal),
      25: (<String>['MARKET', 'SEPET', 'KASA', 'PARA', 'FİŞ', 'ÜRÜN', 'İNDİRİM', 'MÜŞTERİ'], <String>['ETİKET'], WordHuntLevelType.normal),
      26: (<String>['RÜZGAR', 'DOLU', 'KIRAĞI', 'ŞİMŞEK', 'SAĞANAK', 'YAĞMUR', 'SİS', 'FIRTINA'], <String>['AYAZ'], WordHuntLevelType.normal),
      27: (<String>['BURUN', 'KULAK', 'PARMAK', 'OMUZ', 'DİZ', 'AYAK', 'DAMAR', 'BOYUN'], <String>['SAÇ'], WordHuntLevelType.normal),
      28: (<String>['KÖPEK', 'ZEBRA', 'BALIK', 'HOROZ', 'KELEBEK', 'KURT', 'ASLAN', 'TAVŞAN'], <String>['TİMSAH'], WordHuntLevelType.normal),
      29: (<String>['ROBOT', 'EKRAN', 'KLAVYE', 'TELEFON', 'KAMERA', 'TABLET', 'FARE', 'İNTERNET'], <String>['PİL'], WordHuntLevelType.normal),
      30: (<String>['TRAFİK', 'SOKAK', 'BİNA', 'PARK', 'FIRIN', 'CADDE', 'APARTMAN', 'OTEL'], <String>['ECZANE'], WordHuntLevelType.challenge),
    };

    for (final entry in expected.entries) {
      final level = route.levels[entry.key - 1];
      expect(level.targetWords, entry.value.$1, reason: 'L${entry.key} targets');
      expect(level.bonusWords, entry.value.$2, reason: 'L${entry.key} bonus');
      expect(level.type, entry.value.$3, reason: 'L${entry.key} type');
      expect(
        WordHuntGlobalLevelNumbering.globalDisplayNumber(
          routeId: route.id,
          localIndex: entry.key,
        ),
        entry.key,
      );
    }

    expect(route.levels[20].starRules.twoStarMaxMistakes, 3);
    expect(route.levels[20].starRules.threeStarMaxMistakes, 1);
    expect(route.levels[21].starRules.twoStarMaxMistakes, 3);
    expect(route.levels[21].starRules.threeStarMaxMistakes, 1);
    expect(route.levels[29].starRules.twoStarMaxMistakes, 2);
    expect(route.levels[29].starRules.threeStarMaxMistakes, 0);
    expect(route.levels[29].starRules.twoStarMaxSeconds, 100);
    expect(route.levels[29].starRules.threeStarMaxSeconds, 75);
    expect(route.levels[29].timeLimitSeconds, 120);
    expect(WordHuntContentValidator.validate(route: route, infoCards: WordHuntRouteCatalog.starter.infoCards), isEmpty);
  });

  test('L20 now transitions to Segment3 and L21-L30 unlock sequentially', () {
    final beforeTwenty = _progressThrough(route, 19);
    final afterTwenty = beforeTwenty.recordLevelResult(
      levelId: route.levels[19].id,
      stars: 1,
    );
    final destination = WordHuntCompletionCoordinator.resolve(
      route: route,
      completedLevelId: route.levels[19].id,
      beforeProgress: beforeTwenty,
      afterProgress: afterTwenty,
      transition: WordHuntRouteRewardTransition(
        progress: afterTwenty,
        beforeRouteComplete: false,
        afterRouteComplete: false,
        rewardGranted: false,
      ),
      catalogEntries: WordHuntRouteCatalog.entries,
    );

    expect(destination.kind, WordHuntCompletionDestinationKind.nextSegment);
    expect(destination.completedSegment, 2);
    expect(destination.nextPlayableSegment, 3);
    expect(destination.canonicalNextPlayableLevel, 21);

    var progress = afterTwenty;
    for (var index = 21; index <= 30; index++) {
      expect(
        WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, index),
        isTrue,
        reason: 'L$index should unlock after its predecessor',
      );
      expect(
        WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress),
        index,
      );
      if (index < 30) {
        progress = progress.recordLevelResult(
          levelId: route.levels[index - 1].id,
          stars: 1,
        );
      }
    }
  });

  test('L30 advances to Segment4, never true route final/reward', () {
    final before = _progressThrough(route, 29);
    final transition = WordHuntRouteRewardEngine.recordLevelResult(
      route: route,
      progress: before,
      levelId: route.levels[29].id,
      stars: 3,
      foundBonusCount: route.levels[29].bonusWords.length,
    );
    final destination = WordHuntCompletionCoordinator.resolve(
      route: route,
      completedLevelId: route.levels[29].id,
      beforeProgress: before,
      afterProgress: transition.progress,
      transition: transition,
      catalogEntries: WordHuntRouteCatalog.entries,
    );

    final projection = WordHuntSegmentProjection.forLevel(route, 30);
    expect(projection.segmentIndex, 3);
    expect(projection.isSegmentEnd, isTrue);
    expect(projection.isTrueRouteFinal, isFalse);
    expect(WordHuntRouteProgressEngine.isRouteComplete(route, transition.progress), isFalse);
    expect(transition.afterRouteComplete, isFalse);
    expect(transition.rewardGranted, isFalse);
    expect(destination.kind, WordHuntCompletionDestinationKind.nextSegment);
    expect(destination.isTrueRouteFinal, isFalse);
    expect(destination.routeCompletedNow, isFalse);
    expect(destination.rewardGrantedNow, isFalse);
    expect(destination.canonicalNextPlayableLevel, 31);
    expect(
      transition.progress.unlockedRouteRewardIds,
      isNot(contains(route.routeRewardId)),
    );
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(transition.progress), isFalse);
    expect(WordHuntRouteProgressEngine.isLevelUnlocked(route, transition.progress, 31), isTrue);
  });

  test('Wave10B persistence stays route-local and stores no global display identity', () {
    const progress = WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{'baslangic-30': 3},
      bestBonusFoundCountByLevelId: <String, int>{'baslangic-30': 1},
      lastActiveRouteId: 'baslangic-limani',
    );
    final raw = WordHuntProgressCodec.encode(progress, ownerScope: 'wave10b');
    final payload = jsonDecode(raw) as Map<String, dynamic>;

    expect(payload['bestStarsByLevelId'], <String, dynamic>{'baslangic-30': 3});
    expect(payload['bestBonusFoundCountByLevelId'], <String, dynamic>{'baslangic-30': 1});
    expect(raw, isNot(contains('globalDisplayNumber')));
    expect(
      WordHuntProgressCodec.decode(raw, expectedOwnerScope: 'wave10b').bestStarsByLevelId,
      <String, int>{'baslangic-30': 3},
    );
  });
}

WordHuntProgressSnapshot _progressThrough(
  WordHuntRouteDefinition route,
  int levelIndex,
) {
  return WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (final level in route.levels.take(levelIndex)) level.id: 1,
    },
  );
}
