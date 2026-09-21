import 'dart:convert';
import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_orchestration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_completion_presentations.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_content_validator.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gunes_imparatorlugu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kayip_sehir_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_milestone_info_rewards.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_segment_host.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_stop.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_segment_projection.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_yeralti_kralligi_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

const _expectedLevelIds = <String, List<String>>{
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

const _historicalDuplicateExtraOccurrences = <String, int>{
  'baslangic-limani': 7,
  'gokyuzu-adalari': 14,
  'orman-yolu': 18,
  'orman-2': 7,
  'kristal-vadisi': 0,
  'kayip-sehir': 0,
  'yeralti-kralligi': 0,
  'gunes-imparatorlugu': 0,
};

const _expectedContentFingerprints = <String, String>{
  'baslangic-limani': '39462daa',
  'gokyuzu-adalari': '2fd4e4af',
  'orman-yolu': '7aae6da3',
  'orman-2': '71084c8f',
  'kristal-vadisi': 'fcd1e9ce',
  'kayip-sehir': '5c9041c4',
  'yeralti-kralligi': '71d752f6',
  'gunes-imparatorlugu': '0a6c7f40',
};

const _reservedWordCounts = <String, int>{
  'baslangic-limani': 80,
  'gokyuzu-adalari': 80,
  'orman-yolu': 54,
  'orman-2': 67,
  'kristal-vadisi': 70,
  'kayip-sehir': 70,
  'yeralti-kralligi': 70,
  'gunes-imparatorlugu': 70,
};

const _changedLevelIds = <String>{
  'baslangic-3',
  'baslangic-7',
  'baslangic-8',
  'baslangic-10',
  'gokyuzu-1',
  'gokyuzu-3',
  'gokyuzu-4',
  'gokyuzu-5',
  'gokyuzu-7',
  'gokyuzu-9',
  'gokyuzu-10',
  'orman-yolu-02',
  'orman-yolu-03',
  'orman-yolu-04',
  'orman-yolu-05',
  'orman-yolu-06',
  'orman-yolu-07',
  'orman-yolu-08',
  'orman-yolu-10',
  'orman-2-05',
  'orman-2-07',
  'orman-2-08',
  'orman-2-09',
};

const _expectedWordCounts = <String, List<(int, int)>>{
  'baslangic-limani': <(int, int)>[
    (5, 1),
    (5, 1),
    (6, 1),
    (6, 1),
    (7, 1),
    (7, 1),
    (8, 1),
    (7, 2),
    (9, 1),
    (9, 1),
  ],
  'gokyuzu-adalari': <(int, int)>[
    (5, 1),
    (5, 1),
    (6, 1),
    (6, 1),
    (7, 1),
    (7, 1),
    (8, 1),
    (7, 2),
    (9, 1),
    (9, 1),
  ],
  'orman-yolu': <(int, int)>[
    (5, 0),
    (5, 0),
    (4, 1),
    (5, 0),
    (5, 0),
    (4, 1),
    (5, 0),
    (5, 1),
    (5, 1),
    (6, 1),
  ],
  'orman-2': <(int, int)>[
    (5, 0),
    (5, 1),
    (5, 1),
    (5, 1),
    (5, 2),
    (5, 2),
    (5, 2),
    (5, 2),
    (6, 2),
    (6, 2),
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave 8 Segment 1 migration identity', () {
    test('8 route IDs and all 80 legacy level identities stay exact', () {
      expect(
        WordHuntRouteCatalog.entries.map((entry) => entry.route.id).toList(),
        _expectedRouteIds,
      );

      final allIds = <String>{};
      for (final entry in WordHuntRouteCatalog.entries) {
        final route = entry.route;
        expect(route.levels, hasLength(10), reason: route.id);
        expect(
          route.levels.map((level) => level.id).toList(),
          _expectedLevelIds[route.id],
          reason: route.id,
        );
        for (var offset = 0; offset < route.levels.length; offset++) {
          final level = route.levels[offset];
          expect(level.index, offset + 1, reason: level.id);
          expect(level.routeId, route.id, reason: level.id);
          expect(allIds.add(level.id), isTrue, reason: level.id);
        }
      }
      expect(allIds, hasLength(80));
    });

    test('legacy adapter is canonical Segment 1 representation for all routes', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        final route = entry.route;
        expect(route.segments, isEmpty, reason: route.id);
        expect(
          WordHuntSegmentProjection.isExplicitV2Route(route),
          isFalse,
          reason: route.id,
        );
        final host = WordHuntRouteSegmentHost.forRoute(
          route: route,
          progress: const WordHuntProgressSnapshot(),
        );
        expect(host.isLegacySegmentOne, isTrue, reason: route.id);
        expect(host.segmentIndex, 1, reason: route.id);
        expect(host.nodes, hasLength(10), reason: route.id);
        for (var offset = 0; offset < host.nodes.length; offset++) {
          final node = host.nodes[offset];
          expect(node.localNodeIndex, offset + 1, reason: node.levelId);
          expect(node.absoluteLevelIndex, offset + 1, reason: node.levelId);
          expect(node.levelId, route.levels[offset].id);
        }
        expect(host.nodes.first.absoluteLevelIndex, 1);
        expect(host.nodes.last.absoluteLevelIndex, 10);
        expect(host.nodes.last.isSegmentEndpoint, isTrue);
      }
    });
  });

  group('Wave 8 progress and persistence safety', () {
    test('old snapshot resolves unchanged against exact legacy level IDs', () {
      const before = WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          'baslangic-1': 3,
          'baslangic-5': 2,
          'baslangic-10': 1,
          'orman-yolu-01': 2,
          'orman-yolu-05': 1,
          'orman-yolu-10': 3,
          'kayip-sehir-01': 1,
          'kayip-sehir-05': 2,
          'gunes-imparatorlugu-10': 3,
        },
        unlockedInfoCardIds: <String>{
          'info-deniz',
          'orman-info-geyik',
          'kayip-info-kervan',
        },
        unlockedRouteRewardIds: <String>{
          'badge-kelime-yolcusu',
          'badge-orman-kasifi',
        },
        bestBonusFoundCountByLevelId: <String, int>{
          'baslangic-8': 2,
          'orman-2-09': 1,
          'kayip-sehir-10': 2,
        },
        grandfatheredUnlockedRouteIds: <String>{
          'orman-2',
          'kristal-vadisi',
        },
        lastActiveRouteId: 'kayip-sehir',
      );

      final raw = WordHuntProgressCodec.encode(before, ownerScope: 'wave8');
      final after = WordHuntProgressCodec.decode(
        raw,
        expectedOwnerScope: 'wave8',
      );

      expect(WordHuntProgressCodec.schemaVersion, 3);
      expect(
        WordHuntProgressCodec.storageKeyForUid('wave8'),
        startsWith('bilgi_rotasi_word_hunt_progress_v1_'),
      );
      expect(after.bestStarsByLevelId, before.bestStarsByLevelId);
      expect(after.unlockedInfoCardIds, before.unlockedInfoCardIds);
      expect(after.unlockedRouteRewardIds, before.unlockedRouteRewardIds);
      expect(
        after.bestBonusFoundCountByLevelId,
        before.bestBonusFoundCountByLevelId,
      );
      expect(
        after.grandfatheredUnlockedRouteIds,
        before.grandfatheredUnlockedRouteIds,
      );
      expect(after.lastActiveRouteId, before.lastActiveRouteId);

      for (final entry in WordHuntRouteCatalog.entries) {
        for (final level in entry.route.levels) {
          expect(
            after.starsFor(level.id),
            before.starsFor(level.id),
            reason: level.id,
          );
        }
      }
    });
  });

  group('Wave 8 level display-name migration', () {
    test('locked trilogy names are wired in exact order', () {
      _expectNames(
        WordHuntRouteCatalog.kayipSehir.route,
        WordHuntKayipSehirContent.levelNames,
      );
      _expectNames(
        WordHuntRouteCatalog.yeraltiKralligi.route,
        WordHuntYeraltiKralligiContent.levelNames,
      );
      _expectNames(
        WordHuntRouteCatalog.gunesImparatorlugu.route,
        WordHuntGunesImparatorluguContent.levelNames,
      );
    });

    test('other five routes keep Bölüm N fallback without invented names', () {
      for (final entry in WordHuntRouteCatalog.entries.take(5)) {
        for (final level in entry.route.levels) {
          expect(level.displayName, isNull, reason: level.id);
          expect(
            level.displayNameOrFallback,
            'Bölüm ${level.index}',
            reason: level.id,
          );
        }
      }
    });

    testWidgets('map accessibility consumes exact displayName authority', (
      tester,
    ) async {
      final level = WordHuntRouteCatalog.kayipSehir.route.levels.first;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordHuntRouteStop(
              level: level,
              stars: 0,
              unlocked: true,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.byKey(const Key('word_hunt_route_stop_1')),
      );
      expect(semantics.label, 'Kervan İzi, normal, 0 yıldız, açık');
      expect(semantics.label, isNot(contains('Bölüm 1')));
    });

    testWidgets('gameplay header and completion surface consume exact name', (
      tester,
    ) async {
      final entry = WordHuntRouteCatalog.kayipSehir;
      final level = entry.route.levels.first;

      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntLevelProductionScreen(
            level: level,
            infoCards: entry.infoCards,
            routeTitle: entry.route.title,
            presentation: entry.presentationProfile.gameplayForLevel(
              levelIndex: level.index,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Kervan İzi'), findsOneWidget);
      expect(find.text('Bölüm 1'), findsNothing);

      final processed = await WordHuntCompletionOrchestrator.process(
        route: entry.route,
        beforeProgress: const WordHuntProgressSnapshot(),
        levelId: level.id,
        stars: 1,
        unlockedInfoCards: const <String>{},
        foundBonusCount: null,
        routeInfoCards: entry.infoCards,
        onProgressReady: (_) {},
        persistProgress: (_) async {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WordHuntCompletionPresentation(
                destination: processed.destination,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('word_hunt_completion_level_name')),
        findsOneWidget,
      );
      expect(find.text('Kervan İzi'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
    });
  });

  group('Wave 8 duplicate correction and content safety', () {
    test('pre-migration historical duplicate debt remains frozen', () {
      expect(_historicalDuplicateExtraOccurrences, <String, int>{
        'baslangic-limani': 7,
        'gokyuzu-adalari': 14,
        'orman-yolu': 18,
        'orman-2': 7,
        'kristal-vadisi': 0,
        'kayip-sehir': 0,
        'yeralti-kralligi': 0,
        'gunes-imparatorlugu': 0,
      });
    });

    test('all eight current Segment 1 datasets have strict route uniqueness', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        expect(_duplicateDebt(entry.route), isEmpty, reason: entry.route.id);
      }
    });

    test('every production word remains reachable and content validates', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        expect(
          WordHuntContentValidator.validate(
            route: entry.route,
            infoCards: entry.infoCards,
          ),
          isEmpty,
          reason: entry.route.id,
        );
      }
    });

    test('target/bonus counts and 8x8 dimensions remain migration-locked', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        final expectedCounts = _expectedWordCounts[entry.route.id];
        for (var offset = 0; offset < entry.route.levels.length; offset++) {
          final level = entry.route.levels[offset];
          expect(level.rowCount, 8, reason: level.id);
          expect(level.columnCount, 8, reason: level.id);
          if (expectedCounts != null) {
            expect(
              (level.targetWords.length, level.bonusWords.length),
              expectedCounts[offset],
              reason: level.id,
            );
          }
        }
      }
    });

    test('only owner-approved affected route fingerprints changed', () {
      final actual = <String, String>{
        for (final entry in WordHuntRouteCatalog.entries)
          entry.route.id: _contentFingerprint(entry.route),
      };
      expect(actual, _expectedContentFingerprints);
      expect(actual['kristal-vadisi'], 'fcd1e9ce');
      expect(actual['kayip-sehir'], '5c9041c4');
      expect(actual['yeralti-kralligi'], '71d752f6');
      expect(actual['gunes-imparatorlugu'], '0a6c7f40');
    });

    test('corrected Segment 1 reserved sets are deterministic from content', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        final words = <String>{
          for (final level in entry.route.levels)
            ...<String>[
              ...level.targetWords,
              ...level.bonusWords,
            ].map(WordHuntPathEngine.normalizeWord),
        };
        expect(words.length, _reservedWordCounts[entry.route.id], reason: entry.route.id);
        expect(
          words.length,
          entry.route.levels.fold<int>(
            0,
            (total, level) =>
                total + level.targetWords.length + level.bonusWords.length,
          ),
          reason: 'strict uniqueness makes listed count == reserved count: ${entry.route.id}',
        );
      }
    });

    test('all info-card IDs resolve and linked words remain in linked levels', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        final cardsById = <String, WordHuntInfoCard>{
          for (final card in entry.infoCards) card.id: card,
        };
        for (final level in entry.route.levels) {
          final listedWords = <String>{
            ...level.targetWords.map(WordHuntPathEngine.normalizeWord),
            ...level.bonusWords.map(WordHuntPathEngine.normalizeWord),
          };
          for (final cardId in level.infoCardIds) {
            final card = cardsById[cardId];
            expect(card, isNotNull, reason: '${level.id}:$cardId');
            expect(
              listedWords,
              contains(WordHuntPathEngine.normalizeWord(card!.word)),
              reason: '${level.id}:$cardId',
            );
          }
        }
      }
    });

    test('changed levels resolve every target/bonus through production input', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        for (final level in entry.route.levels) {
          if (!_changedLevelIds.contains(level.id)) continue;
          for (final word in level.targetWords) {
            final path = _findStraightPath(level.grid, word);
            expect(path, isNotNull, reason: '${level.id}:$word');
            final result = WordHuntPathEngine.evaluate(
              level: level,
              path: path!,
            );
            expect(result.kind, WordHuntSelectionKind.target, reason: '${level.id}:$word');
          }
          for (final word in level.bonusWords) {
            final path = _findStraightPath(level.grid, word);
            expect(path, isNotNull, reason: '${level.id}:$word');
            final result = WordHuntPathEngine.evaluate(
              level: level,
              path: path!,
            );
            expect(result.kind, WordHuntSelectionKind.bonus, reason: '${level.id}:$word');
          }
        }
      }
    });

    testWidgets('every changed level fits compact production gameplay surface', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final entry in WordHuntRouteCatalog.entries) {
        for (final level in entry.route.levels) {
          if (!_changedLevelIds.contains(level.id)) continue;
          await tester.pumpWidget(
            MaterialApp(
              home: WordHuntLevelProductionScreen(
                level: level,
                infoCards: entry.infoCards,
                routeTitle: entry.route.title,
                presentation: entry.presentationProfile.gameplayForLevel(
                  levelIndex: level.index,
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 60));

          expect(tester.takeException(), isNull, reason: level.id);

          final wordPlatesRect = tester.getRect(
            find.byKey(const Key('word_hunt_production_word_plates')),
          );
          expect(wordPlatesRect.left, greaterThanOrEqualTo(0), reason: level.id);
          expect(wordPlatesRect.right, lessThanOrEqualTo(360), reason: level.id);

          final gridSize = tester.getSize(
            find.byKey(const Key('word_hunt_production_grid')),
          );
          expect(gridSize.width, closeTo(gridSize.height, 0.01), reason: level.id);
          expect(gridSize.width, lessThanOrEqualTo(360), reason: level.id);
          expect(
            find.byKey(const Key('word_hunt_production_finish')),
            findsOneWidget,
            reason: level.id,
          );
        }
      }

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
    });
  });

  group('Wave 8 previous-wave regression', () {
    test('legacy L10 milestone projection still derives Segment 1 cards', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        final projection = WordHuntMilestoneInfoRewardEngine.project(
          route: entry.route,
          routeInfoCards: entry.infoCards,
          completedLevelId: entry.route.levels.last.id,
          beforeProgress: const WordHuntProgressSnapshot(),
        );
        final expectedCardIds = <String>{
          for (final level in entry.route.levels) ...level.infoCardIds,
        };
        expect(projection.milestoneEligible, isTrue, reason: entry.route.id);
        expect(projection.completedSegmentIndex, 1, reason: entry.route.id);
        expect(projection.candidateCardIds, expectedCardIds, reason: entry.route.id);
      }
    });

    test('legacy L10 completion and downstream catalog unlock remain valid', () {
      for (var index = 0; index < WordHuntRouteCatalog.entries.length; index++) {
        final entry = WordHuntRouteCatalog.entries[index];
        final progress = WordHuntProgressSnapshot(
          bestStarsByLevelId: <String, int>{
            for (final level in entry.route.levels) level.id: 3,
          },
        );
        expect(
          WordHuntRouteProgressEngine.isRouteComplete(entry.route, progress),
          isTrue,
          reason: entry.route.id,
        );
        if (index + 1 < WordHuntRouteCatalog.entries.length) {
          expect(
            WordHuntRouteCatalog.entries[index + 1].isUnlocked(progress),
            isTrue,
            reason: 'downstream from ${entry.route.id}',
          );
        }
      }
    });

    test('synthetic explicit V2 keeps L10/L50/L100 semantics distinct', () {
      final route = _v2Route();
      final l10 = WordHuntSegmentProjection.forLevel(route, 10);
      final l50 = WordHuntSegmentProjection.forLevel(route, 50);
      final l100 = WordHuntSegmentProjection.forLevel(route, 100);

      expect(l10.isSegmentMilestone, isTrue);
      expect(l10.isTrueRouteFinal, isFalse);
      expect(l50.isMajorMidpoint, isTrue);
      expect(l50.isTrueRouteFinal, isFalse);
      expect(l100.isTrueRouteFinal, isTrue);
    });

    test('Wave 7 book/compass removals remain absent', () {
      for (final path in <String>[
        'lib/word_hunt/word_hunt_reference_route_screen.dart',
        'lib/word_hunt/word_hunt_pixel_proof_screen.dart',
        'lib/word_hunt/word_hunt_gokyuzu_master_art_screen.dart',
        'lib/word_hunt/word_hunt_themed_production_route_screen.dart',
        'lib/word_hunt/word_hunt_production_entry_screen.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains('onCompass')), reason: path);
        expect(source, isNot(contains('onBook')), reason: path);
      }
    });

    test('schema v3 and historical storage prefix remain unchanged', () {
      expect(WordHuntProgressCodec.schemaVersion, 3);
      expect(
        WordHuntProgressCodec.storageKeyForUid(null),
        'bilgi_rotasi_word_hunt_progress_v1_guest',
      );
    });
  });
}

void _expectNames(WordHuntRouteDefinition route, List<String> expected) {
  expect(route.levels, hasLength(expected.length));
  for (var index = 0; index < expected.length; index++) {
    final level = route.levels[index];
    expect(level.displayName, expected[index], reason: level.id);
    expect(level.displayNameOrFallback, expected[index], reason: level.id);
  }
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
    } else {
      debt.add('$normalized|$first|$current');
    }
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

List<WordHuntCell>? _findStraightPath(List<String> grid, String rawWord) {
  final rows = grid.map((row) => row.runes.toList(growable: false)).toList();
  if (rows.isEmpty || rows.first.isEmpty) return null;
  final word = WordHuntPathEngine.normalizeWord(rawWord).runes.toList();
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
    for (var startColumn = 0; startColumn < rows.first.length; startColumn++) {
      for (final direction in directions) {
        final path = <WordHuntCell>[];
        var matches = true;
        for (var index = 0; index < word.length; index++) {
          final row = startRow + direction.$1 * index;
          final column = startColumn + direction.$2 * index;
          if (row < 0 ||
              row >= rows.length ||
              column < 0 ||
              column >= rows.first.length ||
              WordHuntPathEngine.normalizeWord(
                    String.fromCharCode(rows[row][column]),
                  ).runes.single !=
                  word[index]) {
            matches = false;
            break;
          }
          path.add(WordHuntCell(row, column));
        }
        if (matches) return path;
      }
    }
  }
  return null;
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

WordHuntRouteDefinition _v2Route() {
  const routeId = 'wave8-v2';
  return WordHuntRouteDefinition(
    id: routeId,
    title: 'Wave 8 V2',
    theme: 'wave8',
    unlockStarsRequired: 0,
    routeRewardId: 'wave8-v2-reward',
    levels: List<WordHuntLevelDefinition>.generate(100, (zeroIndex) {
      final index = zeroIndex + 1;
      return WordHuntLevelDefinition(
        id: 'wave8-v2-$index',
        routeId: routeId,
        index: index,
        type:
            index == 100
                ? WordHuntLevelType.routeFinal
                : WordHuntLevelType.normal,
        grid: const <String>['AAA', 'AAA', 'AAA'],
        targetWords: const <String>['AAA'],
        starRules: const WordHuntStarRules(),
      );
    }, growable: false),
    segments: List<WordHuntSegmentDefinition>.generate(10, (zeroIndex) {
      final index = zeroIndex + 1;
      final start = zeroIndex * 10 + 1;
      return WordHuntSegmentDefinition(
        id: 'wave8-segment-$index',
        index: index,
        displayName: 'Segment $index',
        startLevelIndex: start,
        endLevelIndex: start + 9,
      );
    }, growable: false),
  );
}

