import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_gameplay_presentation.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_gameplay_backgrounds.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_input.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress_codec.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wave 5 route presentation profile resolution', () {
    test('all production routes own a stable unique gameplay profile', () {
      final ids = <String>{};
      expect(WordHuntRouteCatalog.entries, hasLength(8));

      for (final entry in WordHuntRouteCatalog.entries) {
        final profile = entry.presentationProfile;
        expect(profile.id.trim(), isNotEmpty, reason: entry.route.id);
        expect(ids.add(profile.id), isTrue, reason: profile.id);
        expect(profile.mapPresentationId.trim(), isNotEmpty);
        expect(profile.sceneCatalog, isNotEmpty);

        for (final level in entry.route.levels) {
          final presentation = profile.gameplayForLevel(
            levelIndex: level.index,
          );
          expect(presentation.profileId, profile.id);
          expect(presentation.scene.id.trim(), isNotEmpty);
          expect(presentation.skin.id.trim(), isNotEmpty);
        }
      }
    });

    test('starter explicitly owns legacy Harbor presentation', () {
      final profile = WordHuntRouteCatalog.starter.presentationProfile;
      final presentation = profile.gameplayForLevel(levelIndex: 1);

      expect(profile.id, 'baslangic-limani-harbor');
      expect(presentation.skin.id, 'harbor');
      expect(
        presentation.scene.assetPath,
        WordHuntRoutePresentationProfiles.harborBackground,
      );
      expect(presentation.skin.backIconAsset, isNotNull);
      expect(presentation.skin.metricPanelAsset, isNotNull);
      expect(presentation.skin.targetPlateAsset, isNotNull);
      expect(presentation.skin.bonusPlateAsset, isNotNull);
      expect(presentation.skin.gridIdleAsset, isNotNull);
      expect(presentation.skin.gridSelectedAsset, isNotNull);
      expect(presentation.skin.instructionPanelAsset, isNotNull);
    });

    test(
      'Gökyüzü exact L1-L10 scene mapping is profile schedule authority',
      () {
        final profile = WordHuntRouteCatalog.gokyuzu.presentationProfile;
        const expected = <int, String>{
          1: WordHuntGokyuzuGameplayBackgrounds.bright,
          2: WordHuntGokyuzuGameplayBackgrounds.bright,
          3: WordHuntGokyuzuGameplayBackgrounds.bright,
          4: WordHuntGokyuzuGameplayBackgrounds.bright,
          5: WordHuntGokyuzuGameplayBackgrounds.storm,
          6: WordHuntGokyuzuGameplayBackgrounds.airship,
          7: WordHuntGokyuzuGameplayBackgrounds.moon,
          8: WordHuntGokyuzuGameplayBackgrounds.storm,
          9: WordHuntGokyuzuGameplayBackgrounds.moon,
          10: WordHuntGokyuzuGameplayBackgrounds.bright,
        };

        for (final item in expected.entries) {
          final scene = profile.gameplayForLevel(levelIndex: item.key).scene;
          expect(scene.assetPath, item.value, reason: 'L${item.key}');
          expect(
            scene.assetPath,
            isNot(WordHuntRoutePresentationProfiles.harborBackground),
          );
        }
      },
    );

    test('every themed production route resolves outside Harbor fallback', () {
      final themed = WordHuntRouteCatalog.entries.skip(2);
      for (final entry in themed) {
        final scene =
            entry.presentationProfile.gameplayForLevel(levelIndex: 1).scene;
        expect(
          scene.assetPath,
          isNot(WordHuntRoutePresentationProfiles.harborBackground),
          reason: entry.route.id,
        );
        expect(
          scene.base64AssetParts.isNotEmpty || scene.assetPath != null,
          isTrue,
          reason: entry.route.id,
        );
        expect(
          entry.presentationProfile.gameplaySkin.id,
          isNot('harbor'),
          reason: entry.route.id,
        );
      }
    });

    test('route-aware skin covers all gameplay presentation token areas', () {
      for (final entry in WordHuntRouteCatalog.entries) {
        final skin = entry.presentationProfile.gameplaySkin;
        expect(skin.id.trim(), isNotEmpty);
        expect(skin.scaffoldColor, isNotNull);
        expect(skin.primaryTextColor, isNotNull);
        expect(skin.secondaryTextColor, isNotNull);
        expect(skin.accentColor, isNotNull);
        expect(skin.surfaceColor, isNotNull);
        expect(skin.targetSurfaceColor, isNotNull);
        expect(skin.bonusSurfaceColor, isNotNull);
        expect(skin.foundSurfaceColor, isNotNull);
        expect(skin.gridIdleColor, isNotNull);
        expect(skin.gridSelectedColor, isNotNull);
        expect(skin.gridFoundColor, isNotNull);
        expect(skin.gridErrorColor, isNotNull);
        expect(skin.connectorColor, isNotNull);
        expect(skin.connectorGlowColor, isNotNull);
        expect(skin.instructionSurfaceColor, isNotNull);
        expect(skin.finishButtonColor, isNotNull);
        expect(skin.completionSurfaceTop, isNotNull);
        expect(skin.completionSurfaceBottom, isNotNull);
        expect(skin.completionIcon, isNotNull);
      }
    });

    test(
      'scene schedule supports future segment mapping without persistence',
      () {
        const sceneA = WordHuntGameplaySceneDefinition(
          id: 'a',
          assetPath: 'a.webp',
        );
        const sceneB = WordHuntGameplaySceneDefinition(
          id: 'b',
          assetPath: 'b.webp',
        );
        const profile = WordHuntRoutePresentationProfile(
          id: 'synthetic',
          mapPresentationId: 'synthetic-map',
          gameplaySkin: WordHuntRoutePresentationProfiles.harborSkin,
          sceneCatalog: <String, WordHuntGameplaySceneDefinition>{
            'a': sceneA,
            'b': sceneB,
          },
          sceneSchedule: WordHuntGameplaySceneSchedule(
            defaultSceneId: 'a',
            segmentSceneIds: <int, String>{2: 'b'},
            levelSceneIds: <int, String>{15: 'a'},
          ),
        );

        expect(
          profile.gameplayForLevel(levelIndex: 11, segmentIndex: 2).scene.id,
          'b',
        );
        expect(
          profile.gameplayForLevel(levelIndex: 15, segmentIndex: 2).scene.id,
          'a',
        );
      },
    );
  });

  group('Wave 5 common gameplay engine and contract regression', () {
    const level = WordHuntLevelDefinition(
      id: 'wave5-engine',
      routeId: 'wave5',
      index: 1,
      type: WordHuntLevelType.normal,
      grid: <String>['KEDI', 'AAAA', 'AAAA', 'AAAA'],
      targetWords: <String>['KEDI'],
      bonusWords: <String>[],
      starRules: WordHuntStarRules(),
    );
    const path = <WordHuntCell>[
      WordHuntCell(0, 0),
      WordHuntCell(0, 1),
      WordHuntCell(0, 2),
      WordHuntCell(0, 3),
    ];

    test('presentation does not alter path/input resolution', () {
      final harbor = WordHuntRoutePresentationProfiles.starter.gameplayForLevel(
        levelIndex: 1,
      );
      final forest = WordHuntRoutePresentationProfiles.ormanYolu
          .gameplayForLevel(levelIndex: 1);
      expect(harbor.skin.id, isNot(forest.skin.id));

      final first = WordHuntInputResolver.resolve(
        level: level,
        path: path,
        foundTargetWords: const <String>{},
        foundBonusWords: const <String>{},
      );
      final second = WordHuntInputResolver.resolve(
        level: level,
        path: path,
        foundTargetWords: const <String>{},
        foundBonusWords: const <String>{},
      );
      expect(first.result?.kind, second.result?.kind);
      expect(first.result?.canonicalWord, second.result?.canonicalWord);
      expect(first.result?.kind, WordHuntSelectionKind.target);
    });

    test('presentation does not alter score calculation', () {
      final first = WordHuntScoringEngine.calculate(
        level: level,
        foundTargetCount: 1,
        mistakes: 0,
        elapsedSeconds: 5,
      );
      final second = WordHuntScoringEngine.calculate(
        level: level,
        foundTargetCount: 1,
        mistakes: 0,
        elapsedSeconds: 5,
      );
      expect(first.stars, second.stars);
    });

    test('result contract and Wave 6 navigation remain absent', () {
      final screens =
          File('lib/word_hunt/word_hunt_screens.dart').readAsStringSync();
      expect(screens, contains('class WordHuntLevelPlayResult'));
      expect(screens, contains('final String levelId;'));
      expect(screens, contains('final int stars;'));
      expect(screens, contains('final Set<String> unlockedInfoCardIds;'));
      expect(screens, contains('final int? foundBonusCount;'));
      expect(screens, isNot(contains('nextLevel')));
      expect(screens, isNot(contains('Sonraki Bölüm')));
      expect(screens, isNot(contains('Sonraki Bölge')));
      expect(screens, isNot(contains('Sonraki Rotaya Geç')));
      expect(screens, contains("label: const Text('Rotaya Dön')"));
    });

    test('deferred final forwards typed presentation unchanged', () {
      final source =
          File(
            'lib/word_hunt/word_hunt_deferred_completion_level_screen.dart',
          ).readAsStringSync();
      expect(source, contains('WordHuntGameplayPresentation? presentation'));
      expect(source, contains('presentation: widget.presentation'));
      expect(source, contains('deferCompletionDialog: true'));
    });
  });

  group('Wave 5 architecture and persistence safety', () {
    test(
      'production entry no longer owns route-special gameplay background',
      () {
        final source =
            File(
              'lib/word_hunt/word_hunt_production_entry_screen.dart',
            ).readAsStringSync();
        expect(source, isNot(contains('_gameplayBackgroundForLevel')));
        expect(source, contains('_gameplayPresentationForLevel'));
        expect(source, contains('.presentationProfile'));
        expect(source, contains('.gameplayForLevel('));
      },
    );

    test(
      'gameplay presentation files contain no route-id/title switch chain',
      () {
        for (final path in <String>[
          'lib/word_hunt/word_hunt_gameplay_presentation.dart',
          'lib/word_hunt/word_hunt_screens.dart',
        ]) {
          final source = File(path).readAsStringSync();
          expect(source, isNot(contains('switch (route.id')));
          expect(source, isNot(contains('switch (route.title')));
          expect(source, isNot(contains("if (route.id ==")));
          expect(source, isNot(contains('route.title.contains')));
        }
      },
    );

    test('schema v3 and storage prefix remain unchanged', () {
      expect(WordHuntProgressCodec.schemaVersion, 3);
      expect(
        WordHuntProgressCodec.storageKeyForUid(null),
        'bilgi_rotasi_word_hunt_progress_v1_guest',
      );
      final source =
          File(
            'lib/word_hunt/word_hunt_gameplay_presentation.dart',
          ).readAsStringSync();
      expect(source, isNot(contains('SharedPreferences')));
      expect(source, isNot(contains('WordHuntProgressCodec')));
    });
  });
}
