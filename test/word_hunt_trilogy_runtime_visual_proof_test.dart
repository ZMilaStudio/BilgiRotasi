import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_trilogy_visual_proof_main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('proof routes resolve production catalog entries and exact themes', () {
    expect(wordHuntTrilogyProofRouteIds, <String>[
      'kayip-sehir',
      'yeralti-kralligi',
      'gunes-imparatorlugu',
    ]);

    for (final routeId in wordHuntTrilogyProofRouteIds) {
      final entry = wordHuntTrilogyProofEntry(routeId);
      expect(entry.route.id, routeId);
      expect(
        entry.presentationKind,
        WordHuntRoutePresentationKind.themedReusable,
      );
      expect(entry.visualTheme, isNotNull);
      expect(
        WordHuntRouteCatalog.entryForRouteId(routeId)?.visualTheme,
        same(entry.visualTheme),
      );
    }
  });

  test('L5-current completes exactly L1-L4 and leaves L5 current', () {
    for (final routeId in wordHuntTrilogyProofRouteIds) {
      final route = wordHuntTrilogyProofEntry(routeId).route;
      final progress = wordHuntTrilogyProofProgress(
        route,
        WordHuntTrilogyProofState.l5Current,
      );

      expect(
        route.levels.where((level) => progress.starsFor(level.id) > 0),
        hasLength(4),
        reason: routeId,
      );
      for (final level in route.levels.take(4)) {
        expect(progress.starsFor(level.id), 3, reason: level.id);
      }
      expect(progress.starsFor(route.levels[4].id), 0, reason: routeId);
      expect(
        WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 5),
        isTrue,
        reason: routeId,
      );
      expect(
        WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 6),
        isFalse,
        reason: routeId,
      );
      expect(
        WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress),
        5,
        reason: routeId,
      );
    }
  });

  test('L10-current completes exactly L1-L9 and leaves L10 current', () {
    for (final routeId in wordHuntTrilogyProofRouteIds) {
      final route = wordHuntTrilogyProofEntry(routeId).route;
      final progress = wordHuntTrilogyProofProgress(
        route,
        WordHuntTrilogyProofState.l10Current,
      );

      expect(
        route.levels.where((level) => progress.starsFor(level.id) > 0),
        hasLength(9),
        reason: routeId,
      );
      for (final level in route.levels.take(9)) {
        expect(progress.starsFor(level.id), 3, reason: level.id);
      }
      expect(progress.starsFor(route.levels[9].id), 0, reason: routeId);
      expect(
        WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, 10),
        isTrue,
        reason: routeId,
      );
      expect(
        WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress),
        10,
        reason: routeId,
      );
    }
  });

  test('completed proof marks all ten levels completed with three stars', () {
    for (final routeId in wordHuntTrilogyProofRouteIds) {
      final route = wordHuntTrilogyProofEntry(routeId).route;
      final progress = wordHuntTrilogyProofProgress(
        route,
        WordHuntTrilogyProofState.completed,
      );

      expect(
        route.levels.where((level) => progress.starsFor(level.id) > 0),
        hasLength(10),
        reason: routeId,
      );
      for (final level in route.levels) {
        expect(progress.starsFor(level.id), 3, reason: level.id);
      }
      expect(
        WordHuntRouteProgressEngine.isRouteComplete(route, progress),
        isTrue,
        reason: routeId,
      );
    }
  });

  test('proof harness has no production persistence dependency', () {
    final source = File(
      'lib/word_hunt/word_hunt_trilogy_visual_proof_main.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('SharedPreferences')));
    expect(source, isNot(contains('WordHuntProgressCodec')));
    expect(source, isNot(contains('setString(')));
    expect(source, isNot(contains('setInt(')));
    expect(source, isNot(contains('setBool(')));
  });
}
