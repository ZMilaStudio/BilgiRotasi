import 'package:bilgi_rotasi/word_hunt/word_hunt_edge_ambient.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gunes_imparatorlugu_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kayip_sehir_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_path_renderer.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_chrome_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_seal_renderer.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_yeralti_kralligi_visual_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Kayıp Şehir binds Ancient Seal + Ancient Waymarks exactly', () {
    final theme = WordHuntKayipSehirVisualTheme.production;
    final seal = theme.sealSpec!;
    final path = theme.pathSpec!;
    final chrome = theme.chromeTheme!;

    expect(
      theme.backgroundAsset,
      'assets/word_hunt/KAYIP_SEHIR_ENV_941x1672.webp',
    );
    expect(seal.id, 'ancient-seal');
    expect(seal.materialFamily, WordHuntSealMaterialFamily.ancientStone);
    expect(
      seal.challengeGeometry,
      WordHuntSealChallengeGeometry.radialFragments,
    );
    expect(seal.finalGeometry, WordHuntSealFinalGeometry.multiRingDescent);
    expect(path.id, 'ancient-waymarks');
    expect(path.family, WordHuntPathVisualFamily.ancientWaymarks);
    expect(path.material, WordHuntPathMaterial.weatheredStone);
    expect(path.jointStyle, WordHuntPathJointStyle.wornStud);
    expect(
      theme.tallAmbientMode,
      WordHuntTallAmbientMode.edgeDerivedLowFrequency,
    );
    expect(
      theme.presentationOrder,
      WordHuntRoutePresentationOrder.forward,
    );
    expect(chrome.materialFamily, WordHuntChromeMaterialFamily.carvedStone);
    _expectLiveIconChrome(chrome);
    _expectSpecialFootprintHierarchy(seal);
  });

  test(
    'Yeraltı Krallığı binds Mechanical Seal + Engineered Segmented Path',
    () {
      final theme = WordHuntYeraltiKralligiVisualTheme.production;
      final seal = theme.sealSpec!;
      final path = theme.pathSpec!;
      final chrome = theme.chromeTheme!;

      expect(
        theme.backgroundAsset,
        'assets/word_hunt/YERALTI_KRALLIGI_ENV_941x1672.webp',
      );
      expect(seal.id, 'mechanical-seal');
      expect(
        seal.materialFamily,
        WordHuntSealMaterialFamily.engineeredStoneCopper,
      );
      expect(
        seal.challengeGeometry,
        WordHuntSealChallengeGeometry.concentricLock,
      );
      expect(
        seal.finalGeometry,
        WordHuntSealFinalGeometry.celestialMechanism,
      );
      expect(path.id, 'engineered-segmented');
      expect(path.family, WordHuntPathVisualFamily.engineeredSegmented);
      expect(path.material, WordHuntPathMaterial.carvedStoneCopper);
      expect(path.jointStyle, WordHuntPathJointStyle.copperPlate);
      expect(
        theme.tallAmbientMode,
        WordHuntTallAmbientMode.edgeDerivedLowFrequency,
      );
      expect(
        theme.presentationOrder,
        WordHuntRoutePresentationOrder.forward,
      );
      expect(
        chrome.materialFamily,
        WordHuntChromeMaterialFamily.engineeredMetal,
      );
      _expectLiveIconChrome(chrome);
      _expectSpecialFootprintHierarchy(seal);
    },
  );

  test(
    'Güneş İmparatorluğu binds Solar Seal + Ceremonial Alignment Path',
    () {
      final theme = WordHuntGunesImparatorluguVisualTheme.production;
      final seal = theme.sealSpec!;
      final path = theme.pathSpec!;
      final chrome = theme.chromeTheme!;

      expect(
        theme.backgroundAsset,
        'assets/word_hunt/GUNES_IMPARATORLUGU_ENV_941x1672.webp',
      );
      expect(seal.id, 'solar-seal');
      expect(
        seal.materialFamily,
        WordHuntSealMaterialFamily.ceremonialSolarStone,
      );
      expect(
        seal.challengeGeometry,
        WordHuntSealChallengeGeometry.splitAlignment,
      );
      expect(seal.finalGeometry, WordHuntSealFinalGeometry.solarThrone);
      expect(path.id, 'ceremonial-alignment');
      expect(path.family, WordHuntPathVisualFamily.ceremonialAlignment);
      expect(path.material, WordHuntPathMaterial.ceremonialStoneGold);
      expect(path.jointStyle, WordHuntPathJointStyle.alignmentMarker);
      expect(
        theme.tallAmbientMode,
        WordHuntTallAmbientMode.edgeDerivedLowFrequency,
      );
      expect(
        theme.presentationOrder,
        WordHuntRoutePresentationOrder.reverse,
      );
      expect(
        chrome.materialFamily,
        WordHuntChromeMaterialFamily.ceremonialStone,
      );
      _expectLiveIconChrome(chrome);
      _expectSpecialFootprintHierarchy(seal);
    },
  );

  test('trilogy themes stay visually distinct and environment-only', () {
    final themes = <dynamic>[
      WordHuntKayipSehirVisualTheme.production,
      WordHuntYeraltiKralligiVisualTheme.production,
      WordHuntGunesImparatorluguVisualTheme.production,
    ];

    expect(themes.map((theme) => theme.id).toSet(), hasLength(3));
    expect(
      themes.map((theme) => theme.sealSpec!.id).toSet(),
      hasLength(3),
    );
    expect(
      themes.map((theme) => theme.pathSpec!.id).toSet(),
      hasLength(3),
    );
    expect(
      themes.map((theme) => theme.chromeTheme!.id).toSet(),
      hasLength(3),
    );

    for (final theme in themes) {
      expect(theme.overlayDecorationsOnArtwork, isFalse);
      expect(theme.backgroundBlurSigma, 0);
      expect(theme.backgroundScale, 1);
      expect(theme.backgroundContrast, 1);
      expect(theme.backgroundSaturation, 1);
      expect(theme.backgroundOverlayColor, Colors.transparent);
      expect(theme.extendTallAmbientFromArtworkEdges, isTrue);
      expect(
        theme.tallAmbientMode,
        isNot(WordHuntTallAmbientMode.legacyMirroredArtwork),
      );
    }
  });

  test('logical topology remains 1→...→10 with no direct 8→10', () {
    expect(WordHuntRouteMapGeometry.connections, <(int, int)>[
      (1, 2),
      (2, 3),
      (3, 4),
      (4, 5),
      (5, 6),
      (6, 7),
      (7, 8),
      (8, 9),
      (9, 10),
    ]);
    expect(WordHuntRouteMapGeometry.connections, contains((8, 9)));
    expect(WordHuntRouteMapGeometry.connections, contains((9, 10)));
    expect(WordHuntRouteMapGeometry.connections, isNot(contains((8, 10))));
  });

  test('reverse presentation reuses the same canonical point set', () {
    const size = Size(411, 731);
    final forward = WordHuntRouteMapGeometry.pointsFor(
      size,
      presentationOrder: WordHuntRoutePresentationOrder.forward,
    );
    final reverse = WordHuntRouteMapGeometry.pointsFor(
      size,
      presentationOrder: WordHuntRoutePresentationOrder.reverse,
    );

    expect(reverse, forward.reversed.toList());
    expect(reverse.first.dy, greaterThan(reverse.last.dy));
  });

  test('production registration preserves exact trilogy theme bindings', () {
    expect(WordHuntRouteCatalog.entries, hasLength(8));
    expect(
      WordHuntRouteCatalog.kayipSehir.visualTheme,
      same(WordHuntKayipSehirVisualTheme.production),
    );
    expect(
      WordHuntRouteCatalog.yeraltiKralligi.visualTheme,
      same(WordHuntYeraltiKralligiVisualTheme.production),
    );
    expect(
      WordHuntRouteCatalog.gunesImparatorlugu.visualTheme,
      same(WordHuntGunesImparatorluguVisualTheme.production),
    );
  });
}

void _expectSpecialFootprintHierarchy(WordHuntSealVisualSpec seal) {
  expect(seal.challengeFootprint, greaterThan(seal.normalFootprint));
  expect(seal.finalFootprint, greaterThan(seal.challengeFootprint));
}

void _expectLiveIconChrome(WordHuntRouteChromeTheme chrome) {
  for (final control in <WordHuntChromeControlSpec>[
    chrome.back,
    chrome.info,
    chrome.compass,
    chrome.codex,
  ]) {
    expect(control.kind, WordHuntChromeControlKind.icon);
    expect(control.icon, isNotNull);
    expect(control.assetPath, isNull);
  }
}
