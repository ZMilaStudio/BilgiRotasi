import 'dart:convert';
import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_home_projection.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_production_entry_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave 4 account and product entry', () {
    testWidgets('undecided account still shows welcome screen', (tester) async {
      final previous = AccountCloudService.state.value;
      addTearDown(() => AccountCloudService.state.value = previous);
      AccountCloudService.state.value = const AccountSessionState(
        mode: AccountMode.undecided,
        firebaseReady: false,
      );

      await tester.pumpWidget(
        MaterialApp(home: AccountGate(questionBank: _emptyQuestionBank())),
      );

      expect(find.byType(AccountWelcomeScreen), findsOneWidget);
      expect(find.byType(ProductModeEntryScreen), findsNothing);
    });

    testWidgets('guest resolved session opens product mode entry', (
      tester,
    ) async {
      final previous = AccountCloudService.state.value;
      addTearDown(() => AccountCloudService.state.value = previous);
      AccountCloudService.state.value = const AccountSessionState(
        mode: AccountMode.guest,
        firebaseReady: false,
      );

      await tester.pumpWidget(
        MaterialApp(home: AccountGate(questionBank: _emptyQuestionBank())),
      );

      expect(find.byType(ProductModeEntryScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    test('signed-in username gate keeps setup and mode chooser boundaries', () {
      final account = File('lib/account_cloud.dart').readAsStringSync();
      final username = File('lib/player_username.dart').readAsStringSync();

      expect(account, contains('if (session.conflict != null)'));
      expect(account, contains('AccountCloudConflictScreen'));
      expect(account, contains('PlayerUsernameGate'));
      expect(account, contains('ownerUid: session.user?.uid'));
      expect(username, contains('PlayerUsernameSetupScreen'));
      expect(username, contains('return ProductModeEntryScreen('));
      expect(username, contains('ownerUid: widget.ownerUid'));
    });

    testWidgets('product chooser exposes exactly two equal primary choices', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProductModeEntryScreen(
            questionBank: _emptyQuestionBank(),
            ownerUid: 'wave4-user',
          ),
        ),
      );

      expect(
        find.byKey(const Key('product_mode_entry_screen')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('product_mode_main_logo')), findsOneWidget);
      expect(find.text('Bilgi Rotası & Kelime Avı'), findsOneWidget);
      expect(
        find.byKey(const Key('product_mode_bilgi_yarismasi')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('product_mode_kelime_avi')), findsOneWidget);
      expect(find.text('BİLGİ YARIŞMASI'), findsOneWidget);
      expect(find.text('KELİME AVI'), findsOneWidget);

      final source = File('lib/product_mode_entry.dart').readAsStringSync();
      expect(
        RegExp(r'_ProductModeCard\(').allMatches(source).length,
        greaterThanOrEqualTo(3),
      );
      expect(source, contains('minHeight: 188'));
    });

    testWidgets('Bilgi Yarışması opens existing HomeScreen', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        MaterialApp(
          home: ProductModeEntryScreen(
            questionBank: _emptyQuestionBank(),
            ownerUid: 'wave4-user',
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('product_mode_bilgi_yarismasi')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(MainNavigationGrid), findsOneWidget);
    });
  });

  group('Wave 4 Word Hunt home projection', () {
    test('empty progress continues from starter level 1', () {
      final projection = WordHuntHomeProjection.fromProgress(
        const WordHuntProgressSnapshot(),
      );
      final destination = projection.continueDestination;

      expect(destination.route.id, WordHuntRouteCatalog.starter.route.id);
      expect(destination.absoluteLevelIndex, 1);
      expect(destination.localLevelIndex, 1);
      expect(destination.activeSegmentIndex, 1);
      expect(
        destination.levelId,
        WordHuntRouteCatalog.starter.route.levels[0].id,
      );
      expect(projection.totalCompletedLevels, 0);
      expect(projection.totalStars, 0);
      expect(projection.completedRouteCount, 0);
      expect(
        projection.totalLevelCount,
        WordHuntRouteCatalog.entries.fold<int>(
          0,
          (total, entry) => total + entry.route.levels.length,
        ),
      );
    });

    test('valid unlocked lastActiveRouteId is preferred', () {
      final progress = _completedProductionRoutes(
        1,
        lastActiveRouteId: WordHuntRouteCatalog.gokyuzu.route.id,
      );

      final projection = WordHuntHomeProjection.fromProgress(progress);

      expect(
        projection.continueDestination.route.id,
        WordHuntRouteCatalog.gokyuzu.route.id,
      );
      expect(projection.continueDestination.absoluteLevelIndex, 1);
    });

    test(
      'invalid lastActive falls back to furthest unlocked incomplete route',
      () {
        final progress = _completedProductionRoutes(
          2,
          lastActiveRouteId: 'missing-route',
        );

        final projection = WordHuntHomeProjection.fromProgress(progress);

        expect(
          projection.continueDestination.route.id,
          WordHuntRouteCatalog.orman.route.id,
        );
        expect(projection.continueDestination.absoluteLevelIndex, 1);
      },
    );

    test('no lastActive uses current catalog unlock semantics', () {
      final progress = _completedProductionRoutes(1);
      final projection = WordHuntHomeProjection.fromProgress(progress);

      expect(
        projection.continueDestination.route.id,
        WordHuntRouteCatalog.gokyuzu.route.id,
      );
      for (final summary in projection.routeSummaries) {
        final entry = WordHuntRouteCatalog.entryForRouteId(summary.routeId);
        expect(entry, isNotNull);
        expect(summary.unlocked, entry!.isUnlocked(progress));
      }
    });

    test(
      'future 100-level continue resolves canonical segment/local identity',
      () {
        final route = _syntheticRoute();
        final entry = _syntheticEntry(route);

        for (final expected in <(int, int, int)>[
          (11, 2, 1),
          (37, 4, 7),
          (50, 5, 10),
          (91, 10, 1),
          (100, 10, 10),
        ]) {
          final progress = _syntheticProgressThrough(
            expected.$1 - 1,
            routeId: route.id,
          );
          final projection = WordHuntHomeProjection.fromProgress(
            progress,
            catalogEntries: <WordHuntRouteCatalogEntry>[entry],
          );
          final destination = projection.continueDestination;

          expect(destination.absoluteLevelIndex, expected.$1);
          expect(destination.activeSegmentIndex, expected.$2);
          expect(destination.localLevelIndex, expected.$3);
          expect(destination.levelId, 'wave4-' + expected.$1.toString());
        }
      },
    );

    test(
      'global totals come from catalog and bonus unknown stays explicit',
      () {
        final starter = WordHuntRouteCatalog.starter.route;
        final progress = WordHuntProgressSnapshot(
          bestStarsByLevelId: <String, int>{
            starter.levels[0].id: 2,
            starter.levels[1].id: 1,
            starter.levels[2].id: 1,
          },
          bestBonusFoundCountByLevelId: <String, int>{
            starter.levels[0].id: 0,
            starter.levels[1].id: 2,
          },
          unlockedInfoCardIds: const <String>{'card-a'},
        );
        final before = WordHuntProgressCodec.encode(
          progress,
          ownerScope: 'guest',
        );

        final projection = WordHuntHomeProjection.fromProgress(progress);
        final after = WordHuntProgressCodec.encode(
          progress,
          ownerScope: 'guest',
        );

        expect(projection.totalCompletedLevels, 3);
        expect(projection.totalStars, 4);
        expect(projection.unlockedInfoCardCount, 1);
        expect(projection.knownBonusFoundTotal, 2);
        expect(projection.hasUnknownBonusHistory, isTrue);
        expect(before, after);
      },
    );

    test(
      'schema remains v3 with no persisted product/home navigation state',
      () {
        expect(WordHuntProgressCodec.schemaVersion, 3);
        expect(
          WordHuntProgressCodec.storageKeyForUid(null),
          'bilgi_rotasi_word_hunt_progress_v1_guest',
        );

        final payload =
            jsonDecode(
                  WordHuntProgressCodec.encode(
                    const WordHuntProgressSnapshot(),
                    ownerScope: 'guest',
                  ),
                )
                as Map<String, dynamic>;

        for (final forbidden in <String>[
          'selectedProductMode',
          'selectedWordHuntSurface',
          'currentLevelId',
          'currentSegment',
          'routeSelectorPosition',
          'mapViewport',
          'continueDestination',
          'generalProgressTotals',
        ]) {
          expect(payload.containsKey(forbidden), isFalse, reason: forbidden);
        }
      },
    );
  });

  group('Wave 4 Word Hunt host and routes', () {
    testWidgets('catalog mode starts on WordHuntHomeScreen', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        const MaterialApp(home: WordHuntProductionEntryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('word_hunt_home_screen')), findsOneWidget);
      expect(find.byKey(const Key('word_hunt_route_selector')), findsNothing);
      expect(find.text('DEVAM ET'), findsOneWidget);
      expect(find.text('ROTALAR'), findsOneWidget);
      expect(find.text('GENEL İLERLEME'), findsOneWidget);
    });

    testWidgets('Rotalar reuses selector and back returns home', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        const MaterialApp(home: WordHuntProductionEntryScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('word_hunt_home_routes')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('word_hunt_route_selector')), findsOneWidget);

      await tester.tap(find.byKey(const Key('word_hunt_route_selector_back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('word_hunt_home_screen')), findsOneWidget);
    });

    testWidgets('direct QA route mode bypasses home and remains compatible', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        const MaterialApp(
          home: WordHuntProductionEntryScreen(routeSelectionEnabled: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('word_hunt_home_screen')), findsNothing);
      expect(
        find.byKey(const Key('word_hunt_production_entry_route')),
        findsOneWidget,
      );
    });

    test('PlayCenter removes only nested Word Hunt entry', () {
      final source = File('lib/main_navigation.dart').readAsStringSync();
      final start = source.indexOf('class PlayCenterScreen');
      final end = source.indexOf('class DailyCenterScreen', start);
      final playCenter = source.substring(start, end);

      expect(playCenter, isNot(contains('Kelime Avı')));
      expect(playCenter, contains('Standart Tahta Oyunu'));
      expect(playCenter, contains('Serbest Rota'));
      expect(playCenter, contains('Soru Maratonu'));
      expect(playCenter, contains('Meydan Okuma'));
      expect(playCenter, contains('Canlı Düello'));
      expect(playCenter, contains('Diğer Oyun Modları'));
    });
  });
}

QuestionBank _emptyQuestionBank() {
  return QuestionBank(const <int, List<QuizQuestion>>{});
}

WordHuntProgressSnapshot _completedProductionRoutes(
  int count, {
  String? lastActiveRouteId,
}) {
  final stars = <String, int>{};
  for (final entry in WordHuntRouteCatalog.entries.take(count)) {
    for (final level in entry.route.levels) {
      stars[level.id] = 3;
    }
  }
  return WordHuntProgressSnapshot(
    bestStarsByLevelId: stars,
    lastActiveRouteId: lastActiveRouteId,
  );
}

WordHuntRouteDefinition _syntheticRoute() {
  const routeId = 'wave4-synthetic';
  final levels = List<WordHuntLevelDefinition>.generate(100, (zeroIndex) {
    final index = zeroIndex + 1;
    return WordHuntLevelDefinition(
      id: 'wave4-$index',
      routeId: routeId,
      index: index,
      displayName: 'Wave 4 $index',
      type:
          index == 100
              ? WordHuntLevelType.routeFinal
              : WordHuntLevelType.normal,
      grid: const <String>['AAA', 'AAA', 'AAA'],
      targetWords: const <String>['AAA'],
      starRules: const WordHuntStarRules(),
    );
  }, growable: false);
  final segments = List<WordHuntSegmentDefinition>.generate(10, (zeroIndex) {
    final segmentIndex = zeroIndex + 1;
    final start = zeroIndex * 10 + 1;
    return WordHuntSegmentDefinition(
      id: 'wave4-segment-$segmentIndex',
      index: segmentIndex,
      displayName: 'Bölge $segmentIndex',
      startLevelIndex: start,
      endLevelIndex: start + 9,
    );
  }, growable: false);

  return WordHuntRouteDefinition(
    id: routeId,
    title: 'Wave 4 Synthetic',
    theme: 'wave4',
    unlockStarsRequired: 0,
    levels: levels,
    routeRewardId: 'wave4-reward',
    segments: segments,
  );
}

WordHuntRouteCatalogEntry _syntheticEntry(WordHuntRouteDefinition route) {
  return WordHuntRouteCatalogEntry(
    cardKey: 'wave4-synthetic',
    route: route,
    infoCards: const <WordHuntInfoCard>[],
    ordinalLabel: 'Synthetic',
    icon: Icons.route_rounded,
    colors: const <Color>[Color(0xFF123456), Color(0xFF654321)],
    unlockRule: const WordHuntRouteUnlockRule.always(),
    presentationKind: WordHuntRoutePresentationKind.referenceRoute,
  );
}

WordHuntProgressSnapshot _syntheticProgressThrough(
  int completedLevels, {
  required String routeId,
}) {
  return WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (var index = 1; index <= completedLevels; index++) 'wave4-$index': 1,
    },
    lastActiveRouteId: routeId,
  );
}
