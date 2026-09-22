import 'dart:convert';

import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_orchestration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_global_level_numbering.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_rewards.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_scoring.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_segment_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const checkpointBRouteCount = 8;
  const checkpointBAvailableLevelCount = 100;

  test(
    'Checkpoint B discovers and validates the current production corpus',
    () {
      final entries = WordHuntRouteCatalog.entries;
      final discoveredLevelCount = entries.fold<int>(
        0,
        (total, entry) => total + entry.route.availableLevelCount,
      );

      expect(
        entries,
        hasLength(checkpointBRouteCount),
        reason: 'Checkpoint B başlangıç authority route count değişti.',
      );
      expect(
        discoveredLevelCount,
        checkpointBAvailableLevelCount,
        reason:
            'Checkpoint B başlangıç authority available level count değişti.',
      );
      expect(
        entries.map((entry) => entry.route.id).toList(growable: false),
        WordHuntGlobalLevelNumbering.routeOrder,
        reason: 'Production catalog ile global numbering route order ayrıştı.',
      );

      for (final entry in entries) {
        final route = entry.route;
        final errors = WordHuntContentValidator.validate(
          route: route,
          infoCards: entry.infoCards,
        );
        expect(
          errors,
          isEmpty,
          reason:
              '${route.id}: production definition/content validation failed: '
              '${errors.join(' | ')}',
        );
      }
    },
  );

  test('100/100 available levels are physically playable and scoreable', () {
    for (final entry in WordHuntRouteCatalog.entries) {
      final route = entry.route;

      for (final level in route.levels) {
        final context = '${route.id} / L${level.index} / ${level.id}';
        final foundTargets = <String>{};
        final foundBonuses = <String>{};

        for (final word in level.targetWords) {
          final path = _resolvePhysicalPath(level.grid, word);
          expect(
            path,
            isNotNull,
            reason: '$context / target=$word / physical path missing',
          );

          final selection = WordHuntPathEngine.evaluate(
            level: level,
            path: path!,
            foundTargetWords: foundTargets,
            foundBonusWords: foundBonuses,
          );
          expect(
            selection.kind,
            WordHuntSelectionKind.target,
            reason: '$context / target=$word / path engine mismatch',
          );
          expect(
            WordHuntPathEngine.normalizeWord(selection.canonicalWord ?? ''),
            WordHuntPathEngine.normalizeWord(word),
            reason: '$context / target=$word / canonical target mismatch',
          );
          foundTargets.add(selection.canonicalWord!);
        }

        for (final word in level.bonusWords) {
          final path = _resolvePhysicalPath(level.grid, word);
          expect(
            path,
            isNotNull,
            reason: '$context / bonus=$word / physical path missing',
          );

          final selection = WordHuntPathEngine.evaluate(
            level: level,
            path: path!,
            foundTargetWords: foundTargets,
            foundBonusWords: foundBonuses,
          );
          expect(
            selection.kind,
            WordHuntSelectionKind.bonus,
            reason: '$context / bonus=$word / path engine mismatch',
          );
          expect(
            WordHuntPathEngine.normalizeWord(selection.canonicalWord ?? ''),
            WordHuntPathEngine.normalizeWord(word),
            reason: '$context / bonus=$word / canonical bonus mismatch',
          );
          foundBonuses.add(selection.canonicalWord!);
        }

        expect(
          foundTargets,
          hasLength(level.targetWords.length),
          reason: '$context / not all targets reached found state',
        );
        expect(
          foundBonuses,
          hasLength(level.bonusWords.length),
          reason: '$context / not all bonuses reached found state',
        );

        final incomplete = WordHuntScoringEngine.calculate(
          level: level,
          foundTargetCount: level.targetWords.length - 1,
          mistakes: 0,
          elapsedSeconds: 0,
        );
        expect(
          incomplete.completed,
          isFalse,
          reason: '$context / incomplete target set completed unexpectedly',
        );
        expect(
          incomplete.stars,
          0,
          reason: '$context / incomplete target set produced stars',
        );

        final ideal = WordHuntScoringEngine.calculate(
          level: level,
          foundTargetCount: foundTargets.length,
          mistakes: 0,
          elapsedSeconds: 0,
        );
        expect(
          ideal.completed,
          isTrue,
          reason: '$context / all targets found but level not complete',
        );
        expect(
          ideal.stars,
          3,
          reason: '$context / ideal no-mistake completion is not 3-star',
        );

        _expectScoringTierReachability(level, context);
      }
    }
  });

  test(
    'route-local progression, frontier, reward, codec and numbering stay coherent',
    () {
      final entries = WordHuntRouteCatalog.entries;

      expect(WordHuntProgressCodec.schemaVersion, 3);
      _expectCodecRoundTrip(
        const WordHuntProgressSnapshot(),
        ownerScope: 'checkpoint-b-route-start',
        context: 'route start',
      );

      for (var entryIndex = 0; entryIndex < entries.length; entryIndex++) {
        final entry = entries[entryIndex];
        final route = entry.route;
        final segmented = WordHuntSegmentProjection.isSegmentedRoute(route);
        final completeV2 = WordHuntSegmentProjection.isCompleteV2Route(route);
        var progress = const WordHuntProgressSnapshot();

        for (
          var localIndex = 1;
          localIndex <= route.levels.length;
          localIndex++
        ) {
          final level = route.levels[localIndex - 1];
          final context = '${route.id} / L$localIndex / ${level.id}';

          expect(
            WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress),
            localIndex,
            reason: '$context / route-local next playable index skipped',
          );
          expect(
            WordHuntRouteProgressEngine.isLevelUnlocked(
              route,
              progress,
              localIndex,
            ),
            isTrue,
            reason: '$context / sequential level should be unlocked',
          );

          final globalDisplayNumber =
              WordHuntGlobalLevelNumbering.globalDisplayNumber(
                routeId: route.id,
                localIndex: localIndex,
              );
          expect(
            globalDisplayNumber,
            entryIndex * WordHuntGlobalLevelNumbering.levelsPerRoute +
                localIndex,
            reason: '$context / global presentation projection mismatch',
          );

          final before = progress;
          final transition = WordHuntRouteRewardEngine.recordLevelResult(
            route: route,
            progress: before,
            levelId: level.id,
            stars: 3,
            foundBonusCount: level.bonusWords.length,
          );
          progress = transition.progress;

          final destination = WordHuntCompletionCoordinator.resolve(
            route: route,
            completedLevelId: level.id,
            beforeProgress: before,
            afterProgress: progress,
            transition: transition,
            catalogEntries: entries,
          );

          expect(
            progress.starsFor(level.id),
            3,
            reason: '$context / completed level was not persisted by level id',
          );

          final isAvailableFrontier = localIndex == route.levels.length;
          if (!isAvailableFrontier) {
            expect(
              WordHuntRouteProgressEngine.nextPlayableLevelIndex(
                route,
                progress,
              ),
              localIndex + 1,
              reason: '$context / next local level was not exposed',
            );
            expect(
              transition.afterRouteComplete,
              isFalse,
              reason: '$context / route completed before available frontier',
            );
            expect(
              transition.rewardGranted,
              isFalse,
              reason: '$context / route reward granted before true completion',
            );

            final projection =
                segmented
                    ? WordHuntSegmentProjection.forLevel(route, localIndex)
                    : null;
            final expectedKind =
                projection?.isSegmentEnd ?? false
                    ? WordHuntCompletionDestinationKind.nextSegment
                    : WordHuntCompletionDestinationKind.nextLevel;
            expect(
              destination.kind,
              expectedKind,
              reason: '$context / completion destination mismatch',
            );

            if (projection?.isSegmentEnd ?? false) {
              _expectCodecRoundTrip(
                progress,
                ownerScope:
                    'checkpoint-b-${route.id}-segment-${projection!.segmentIndex}',
                context: '$context / segment boundary',
              );
            }
            continue;
          }

          expect(
            WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress),
            route.levels.length,
            reason: '$context / frontier navigated to nonexistent next level',
          );
          expect(
            WordHuntRouteProgressEngine.isLevelUnlocked(
              route,
              progress,
              route.levels.length + 1,
            ),
            isFalse,
            reason: '$context / nonexistent next level became unlocked',
          );

          final stagedFrontier =
              segmented &&
              !completeV2 &&
              route.availableLevelCount < route.plannedRouteLevelCount;
          final routeComplete = WordHuntRouteProgressEngine.isRouteComplete(
            route,
            progress,
          );

          if (stagedFrontier) {
            expect(
              routeComplete,
              isFalse,
              reason: '$context / staged frontier became fake route completion',
            );
            expect(
              destination.kind,
              WordHuntCompletionDestinationKind.contentFrontier,
              reason:
                  '$context / staged frontier did not stop at content frontier',
            );
            expect(
              destination.isTrueRouteFinal,
              isFalse,
              reason: '$context / staged frontier became true route final',
            );
            expect(
              transition.rewardGranted,
              isFalse,
              reason: '$context / staged frontier granted route reward',
            );
            if (entryIndex + 1 < entries.length) {
              expect(
                entries[entryIndex + 1].isUnlocked(progress),
                isFalse,
                reason: '$context / staged frontier unlocked next route',
              );
            }
          } else {
            expect(
              routeComplete,
              isTrue,
              reason: '$context / current route final did not complete route',
            );
            expect(
              transition.afterRouteComplete,
              isTrue,
              reason: '$context / reward engine missed route completion',
            );
            expect(
              transition.rewardGranted,
              isTrue,
              reason: '$context / first true route completion missed reward',
            );
            expect(
              progress.unlockedRouteRewardIds,
              contains(route.routeRewardId),
              reason: '$context / route reward identity not persisted',
            );

            if (entryIndex + 1 < entries.length) {
              expect(
                destination.kind,
                WordHuntCompletionDestinationKind.nextRoute,
                reason:
                    '$context / completed route did not point to next route',
              );
              expect(
                entries[entryIndex + 1].isUnlocked(progress),
                isTrue,
                reason: '$context / completed route did not unlock next route',
              );
            } else {
              expect(
                destination.kind,
                WordHuntCompletionDestinationKind.terminalRouteComplete,
                reason: '$context / terminal route completion mismatch',
              );
            }
          }

          _expectCodecRoundTrip(
            progress,
            ownerScope: 'checkpoint-b-${route.id}-frontier',
            context: '$context / current frontier',
          );

          final replay = WordHuntRouteRewardEngine.recordLevelResult(
            route: route,
            progress: progress,
            levelId: level.id,
            stars: 3,
            foundBonusCount: level.bonusWords.length,
          );
          expect(
            replay.rewardGranted,
            isFalse,
            reason: '$context / replay duplicated route reward',
          );
        }
      }
    },
  );
}

List<WordHuntCell>? _resolvePhysicalPath(List<String> grid, String rawWord) {
  if (grid.isEmpty) return null;

  final rows = grid
      .map(
        (row) =>
            WordHuntPathEngine.normalizeWord(row).runes.toList(growable: false),
      )
      .toList(growable: false);
  final width = rows.first.length;
  if (width == 0 || rows.any((row) => row.length != width)) return null;

  final word = WordHuntPathEngine.normalizeWord(
    rawWord,
  ).runes.toList(growable: false);
  if (word.isEmpty) return null;

  const directions = <(int, int)>[
    (-1, -1),
    (-1, 0),
    (-1, 1),
    (0, -1),
    (0, 1),
    (1, -1),
    (1, 0),
    (1, 1),
  ];

  for (var startRow = 0; startRow < rows.length; startRow++) {
    for (var startColumn = 0; startColumn < width; startColumn++) {
      for (final direction in directions) {
        final path = <WordHuntCell>[];
        var matches = true;

        for (var index = 0; index < word.length; index++) {
          final row = startRow + direction.$1 * index;
          final column = startColumn + direction.$2 * index;
          if (row < 0 ||
              row >= rows.length ||
              column < 0 ||
              column >= width ||
              rows[row][column] != word[index]) {
            matches = false;
            break;
          }
          path.add(WordHuntCell(row, column));
        }

        if (matches) return List<WordHuntCell>.unmodifiable(path);
      }
    }
  }

  return null;
}

void _expectScoringTierReachability(
  WordHuntLevelDefinition level,
  String context,
) {
  final rules = level.starRules;

  final threeStarBoundary = WordHuntScoringEngine.calculate(
    level: level,
    foundTargetCount: level.targetWords.length,
    mistakes: rules.threeStarMaxMistakes ?? 0,
    elapsedSeconds: rules.threeStarMaxSeconds ?? 0,
  );
  expect(
    threeStarBoundary.stars,
    3,
    reason: '$context / configured 3-star boundary is not reachable',
  );

  int? twoStarMistakes;
  int? twoStarSeconds;

  final threeMistakes = rules.threeStarMaxMistakes;
  final twoMistakes = rules.twoStarMaxMistakes;
  if (threeMistakes != null &&
      (twoMistakes == null || threeMistakes < twoMistakes)) {
    twoStarMistakes = threeMistakes + 1;
    twoStarSeconds = 0;
  }

  final threeSeconds = rules.threeStarMaxSeconds;
  final twoSeconds = rules.twoStarMaxSeconds;
  if (twoStarMistakes == null &&
      threeSeconds != null &&
      (twoSeconds == null || threeSeconds < twoSeconds)) {
    twoStarMistakes = 0;
    twoStarSeconds = threeSeconds + 1;
  }

  if (twoStarMistakes != null && twoStarSeconds != null) {
    final twoStarBoundary = WordHuntScoringEngine.calculate(
      level: level,
      foundTargetCount: level.targetWords.length,
      mistakes: twoStarMistakes,
      elapsedSeconds: twoStarSeconds,
    );
    expect(
      twoStarBoundary.stars,
      2,
      reason: '$context / configured 2-star band is not reachable',
    );
  }
}

void _expectCodecRoundTrip(
  WordHuntProgressSnapshot progress, {
  required String ownerScope,
  required String context,
}) {
  final raw = WordHuntProgressCodec.encode(progress, ownerScope: ownerScope);
  final payload = jsonDecode(raw) as Map<String, dynamic>;

  expect(
    payload['schema'],
    WordHuntProgressCodec.schemaVersion,
    reason: context,
  );
  expect(
    payload.containsKey('globalDisplayNumber'),
    isFalse,
    reason: '$context / global display number leaked into persistence',
  );
  expect(
    payload.containsKey('globalLevelNumber'),
    isFalse,
    reason: '$context / global level number leaked into persistence',
  );

  final decoded = WordHuntProgressCodec.decodeWithMetadata(
    raw,
    expectedOwnerScope: ownerScope,
  );
  expect(
    decoded.sourceSchemaVersion,
    3,
    reason: '$context / schema v3 was not preserved',
  );
  expect(
    decoded.snapshot.bestStarsByLevelId,
    progress.bestStarsByLevelId,
    reason:
        '$context / route-local level identity changed after codec roundtrip',
  );
  expect(
    decoded.snapshot.unlockedInfoCardIds,
    progress.unlockedInfoCardIds,
    reason: '$context / info-card identity changed after codec roundtrip',
  );
  expect(
    decoded.snapshot.unlockedRouteRewardIds,
    progress.unlockedRouteRewardIds,
    reason: '$context / reward identity changed after codec roundtrip',
  );
  expect(
    decoded.snapshot.bestBonusFoundCountByLevelId,
    progress.bestBonusFoundCountByLevelId,
    reason: '$context / bonus identity changed after codec roundtrip',
  );
  expect(
    decoded.snapshot.grandfatheredUnlockedRouteIds,
    progress.grandfatheredUnlockedRouteIds,
    reason: '$context / grandfathered route identity changed after roundtrip',
  );
  expect(
    decoded.snapshot.lastActiveRouteId,
    progress.lastActiveRouteId,
    reason: '$context / last-active route identity changed after roundtrip',
  );
}
