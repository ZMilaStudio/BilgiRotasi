import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_gokyuzu_gameplay_backgrounds.dart';
import 'word_hunt_gunes_imparatorlugu_visual_theme.dart';
import 'word_hunt_kayip_sehir_visual_theme.dart';
import 'word_hunt_kristal_visual_theme.dart';
import 'word_hunt_orman2_visual_theme.dart';
import 'word_hunt_orman_clean_environment_assets.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_yeralti_kralligi_visual_theme.dart';

@immutable
class WordHuntGameplaySceneDefinition {
  const WordHuntGameplaySceneDefinition({
    required this.id,
    this.assetPath,
    this.base64AssetParts = const <String>[],
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.backgroundColor = const Color(0xFF061425),
    this.overlayColor = Colors.transparent,
    this.vignetteColor = Colors.transparent,
  });

  final String id;
  final String? assetPath;
  final List<String> base64AssetParts;
  final BoxFit fit;
  final Alignment alignment;
  final Color backgroundColor;
  final Color overlayColor;
  final Color vignetteColor;

  bool get hasSingleSource =>
      (assetPath != null) != base64AssetParts.isNotEmpty;
}

@immutable
class WordHuntGameplaySceneSchedule {
  const WordHuntGameplaySceneSchedule({
    required this.defaultSceneId,
    this.segmentSceneIds = const <int, String>{},
    this.levelSceneIds = const <int, String>{},
  });

  final String defaultSceneId;
  final Map<int, String> segmentSceneIds;
  final Map<int, String> levelSceneIds;

  String sceneIdFor({required int levelIndex, int? segmentIndex}) {
    return levelSceneIds[levelIndex] ??
        (segmentIndex == null ? null : segmentSceneIds[segmentIndex]) ??
        defaultSceneId;
  }
}

@immutable
class WordHuntGameplaySkin {
  const WordHuntGameplaySkin({
    required this.id,
    required this.scaffoldColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.accentColor,
    required this.surfaceColor,
    required this.surfaceBorderColor,
    required this.targetSurfaceColor,
    required this.bonusSurfaceColor,
    required this.foundSurfaceColor,
    required this.gridIdleColor,
    required this.gridSelectedColor,
    required this.gridFoundColor,
    required this.gridErrorColor,
    required this.gridTextColor,
    required this.connectorColor,
    required this.connectorGlowColor,
    required this.instructionSurfaceColor,
    required this.finishButtonColor,
    required this.completionSurfaceTop,
    required this.completionSurfaceBottom,
    required this.completionIcon,
    this.backIconAsset,
    this.metricPanelAsset,
    this.targetPlateAsset,
    this.bonusPlateAsset,
    this.gridIdleAsset,
    this.gridSelectedAsset,
    this.instructionPanelAsset,
  });

  final String id;
  final Color scaffoldColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color accentColor;
  final Color surfaceColor;
  final Color surfaceBorderColor;
  final Color targetSurfaceColor;
  final Color bonusSurfaceColor;
  final Color foundSurfaceColor;
  final Color gridIdleColor;
  final Color gridSelectedColor;
  final Color gridFoundColor;
  final Color gridErrorColor;
  final Color gridTextColor;
  final Color connectorColor;
  final Color connectorGlowColor;
  final Color instructionSurfaceColor;
  final Color finishButtonColor;
  final Color completionSurfaceTop;
  final Color completionSurfaceBottom;
  final IconData completionIcon;
  final String? backIconAsset;
  final String? metricPanelAsset;
  final String? targetPlateAsset;
  final String? bonusPlateAsset;
  final String? gridIdleAsset;
  final String? gridSelectedAsset;
  final String? instructionPanelAsset;
}

@immutable
class WordHuntGameplayPresentation {
  const WordHuntGameplayPresentation({
    required this.profileId,
    required this.scene,
    required this.skin,
  });

  final String profileId;
  final WordHuntGameplaySceneDefinition scene;
  final WordHuntGameplaySkin skin;
}

@immutable
class WordHuntRoutePresentationProfile {
  const WordHuntRoutePresentationProfile({
    required this.id,
    required this.mapPresentationId,
    required this.gameplaySkin,
    required this.sceneCatalog,
    required this.sceneSchedule,
  });

  final String id;
  final String mapPresentationId;
  final WordHuntGameplaySkin gameplaySkin;
  final Map<String, WordHuntGameplaySceneDefinition> sceneCatalog;
  final WordHuntGameplaySceneSchedule sceneSchedule;

  WordHuntGameplayPresentation gameplayForLevel({
    required int levelIndex,
    int? segmentIndex,
  }) {
    final sceneId = sceneSchedule.sceneIdFor(
      levelIndex: levelIndex,
      segmentIndex: segmentIndex,
    );
    final scene = sceneCatalog[sceneId];
    if (scene == null) {
      throw StateError('Profile $id scene catalog içinde $sceneId yok.');
    }
    if (!scene.hasSingleSource) {
      throw StateError('Profile $id scene $sceneId tek source taşımıyor.');
    }
    return WordHuntGameplayPresentation(
      profileId: id,
      scene: scene,
      skin: gameplaySkin,
    );
  }
}

abstract final class WordHuntRoutePresentationProfiles {
  static const String harborBackground =
      'assets/word_hunt/v5_reference_assets/harbor_background_1080x1920.png';

  static const WordHuntGameplaySkin harborSkin = WordHuntGameplaySkin(
    id: 'harbor',
    scaffoldColor: Color(0xFF061425),
    primaryTextColor: Color(0xFFFFF1D0),
    secondaryTextColor: Color(0xFF98A9B8),
    accentColor: Color(0xFFFFCA62),
    surfaceColor: Color(0xD9091827),
    surfaceBorderColor: Color(0x887C5A2A),
    targetSurfaceColor: Color(0xCC0B2137),
    bonusSurfaceColor: Color(0xCC4E3512),
    foundSurfaceColor: Color(0xFFC06B16),
    gridIdleColor: Color(0xFF102A45),
    gridSelectedColor: Color(0xFF6A4818),
    gridFoundColor: Color(0xFF8A5A16),
    gridErrorColor: Color(0xFF8A2732),
    gridTextColor: Color(0xFFFFF1D0),
    connectorColor: Color(0xFFFFCA62),
    connectorGlowColor: Color(0x99FFCA62),
    instructionSurfaceColor: Color(0xD9091827),
    finishButtonColor: Color(0xFF8A5A16),
    completionSurfaceTop: Color(0xFF0B2137),
    completionSurfaceBottom: Color(0xFF061525),
    completionIcon: Icons.anchor_rounded,
    backIconAsset: 'assets/word_hunt/v5_reference_assets/icon_back.png',
    metricPanelAsset:
        'assets/word_hunt/v5_reference_assets/status_panel_empty.png',
    targetPlateAsset:
        'assets/word_hunt/v5_reference_assets/word_plaque_empty.png',
    bonusPlateAsset:
        'assets/word_hunt/v5_reference_assets/bonus_plaque_empty.png',
    gridIdleAsset: 'assets/word_hunt/v5_reference_assets/cell_idle.png',
    gridSelectedAsset:
        'assets/word_hunt/v5_reference_assets/cell_selected_found.png',
    instructionPanelAsset:
        'assets/word_hunt/v5_reference_assets/instruction_panel_empty.png',
  );

  static final WordHuntRoutePresentationProfile starter =
      WordHuntRoutePresentationProfile(
        id: 'baslangic-limani-harbor',
        mapPresentationId: 'reference-route',
        gameplaySkin: harborSkin,
        sceneCatalog: const <String, WordHuntGameplaySceneDefinition>{
          'harbor': WordHuntGameplaySceneDefinition(
            id: 'harbor',
            assetPath: harborBackground,
            alignment: Alignment.topCenter,
          ),
        },
        sceneSchedule: const WordHuntGameplaySceneSchedule(
          defaultSceneId: 'harbor',
        ),
      );

  static final WordHuntRoutePresentationProfile gokyuzu =
      WordHuntRoutePresentationProfile(
        id: 'gokyuzu-adalari-sky',
        mapPresentationId: 'gokyuzu-master-art',
        gameplaySkin: const WordHuntGameplaySkin(
          id: 'gokyuzu',
          scaffoldColor: Color(0xFF111A4A),
          primaryTextColor: Color(0xFFF4F2FF),
          secondaryTextColor: Color(0xFFC9D2FF),
          accentColor: Color(0xFFFFD76C),
          surfaceColor: Color(0xCC28317A),
          surfaceBorderColor: Color(0xAA91A7FF),
          targetSurfaceColor: Color(0xD927347A),
          bonusSurfaceColor: Color(0xD9553A83),
          foundSurfaceColor: Color(0xFF3979A8),
          gridIdleColor: Color(0xCC243C80),
          gridSelectedColor: Color(0xFF6D56A8),
          gridFoundColor: Color(0xFF2C8FA3),
          gridErrorColor: Color(0xFF923C65),
          gridTextColor: Color(0xFFF7F4FF),
          connectorColor: Color(0xFFF7D66B),
          connectorGlowColor: Color(0x997FDBFF),
          instructionSurfaceColor: Color(0xD91C2862),
          finishButtonColor: Color(0xFF5B4AA8),
          completionSurfaceTop: Color(0xFF303D91),
          completionSurfaceBottom: Color(0xFF131B4A),
          completionIcon: Icons.cloud_rounded,
        ),
        sceneCatalog: const <String, WordHuntGameplaySceneDefinition>{
          'bright': WordHuntGameplaySceneDefinition(
            id: 'bright',
            assetPath: WordHuntGokyuzuGameplayBackgrounds.bright,
          ),
          'storm': WordHuntGameplaySceneDefinition(
            id: 'storm',
            assetPath: WordHuntGokyuzuGameplayBackgrounds.storm,
          ),
          'airship': WordHuntGameplaySceneDefinition(
            id: 'airship',
            assetPath: WordHuntGokyuzuGameplayBackgrounds.airship,
          ),
          'moon': WordHuntGameplaySceneDefinition(
            id: 'moon',
            assetPath: WordHuntGokyuzuGameplayBackgrounds.moon,
          ),
        },
        sceneSchedule: const WordHuntGameplaySceneSchedule(
          defaultSceneId: 'bright',
          levelSceneIds: <int, String>{
            5: 'storm',
            6: 'airship',
            7: 'moon',
            8: 'storm',
            9: 'moon',
          },
        ),
      );

  static final WordHuntRoutePresentationProfile ormanYolu = _fromVisualTheme(
    profileId: 'orman-yolu-forest',
    theme: WordHuntRouteVisualThemes.ormanYolu,
    scene: const WordHuntGameplaySceneDefinition(
      id: 'forest',
      base64AssetParts: wordHuntOrmanCleanEnvironmentAssetParts,
      backgroundColor: Color(0xFF07150D),
    ),
    completionIcon: Icons.park_rounded,
  );

  static final WordHuntRoutePresentationProfile orman2 = _fromVisualTheme(
    profileId: 'orman-2-ancient-forest',
    theme: WordHuntOrman2VisualTheme.production,
    scene: const WordHuntGameplaySceneDefinition(
      id: 'ancient-forest',
      assetPath: WordHuntOrman2VisualTheme.assetPath,
      backgroundColor: Color(0xFF07150D),
    ),
    completionIcon: Icons.forest_rounded,
  );

  static final WordHuntRoutePresentationProfile kristal = _fromVisualTheme(
    profileId: 'kristal-vadisi-crystal',
    theme: WordHuntKristalVisualTheme.production,
    scene: const WordHuntGameplaySceneDefinition(
      id: 'crystal',
      assetPath: WordHuntKristalVisualTheme.assetPath,
      backgroundColor: Color(0xFF090B20),
    ),
    completionIcon: Icons.diamond_rounded,
  );

  static final WordHuntRoutePresentationProfile kayipSehir = _fromVisualTheme(
    profileId: 'kayip-sehir-archaeological',
    theme: WordHuntKayipSehirVisualTheme.production,
    scene: const WordHuntGameplaySceneDefinition(
      id: 'lost-city',
      assetPath: WordHuntKayipSehirVisualTheme.assetPath,
      backgroundColor: Color(0xFF46362B),
    ),
    completionIcon: Icons.account_balance_rounded,
  );

  static final WordHuntRoutePresentationProfile yeraltiKralligi =
      _fromVisualTheme(
        profileId: 'yeralti-kralligi-engineered',
        theme: WordHuntYeraltiKralligiVisualTheme.production,
        scene: const WordHuntGameplaySceneDefinition(
          id: 'underground',
          assetPath: WordHuntYeraltiKralligiVisualTheme.assetPath,
          backgroundColor: Color(0xFF111A23),
        ),
        completionIcon: Icons.settings_rounded,
      );

  static final WordHuntRoutePresentationProfile gunesImparatorlugu =
      _fromVisualTheme(
        profileId: 'gunes-imparatorlugu-imperial',
        theme: WordHuntGunesImparatorluguVisualTheme.production,
        scene: const WordHuntGameplaySceneDefinition(
          id: 'sun-empire',
          assetPath: WordHuntGunesImparatorluguVisualTheme.assetPath,
          backgroundColor: Color(0xFF182B52),
        ),
        completionIcon: Icons.wb_sunny_rounded,
      );

  static WordHuntRoutePresentationProfile _fromVisualTheme({
    required String profileId,
    required WordHuntRouteVisualTheme theme,
    required WordHuntGameplaySceneDefinition scene,
    required IconData completionIcon,
  }) {
    final map = theme.mapTheme;
    return WordHuntRoutePresentationProfile(
      id: profileId,
      mapPresentationId: theme.id,
      gameplaySkin: WordHuntGameplaySkin(
        id: profileId,
        scaffoldColor: map.backgroundColor,
        primaryTextColor: map.textColor,
        secondaryTextColor: map.textColor.withValues(alpha: 0.76),
        accentColor: map.accentColor,
        surfaceColor: map.surfaceColor.withValues(alpha: 0.88),
        surfaceBorderColor: map.accentColor.withValues(alpha: 0.55),
        targetSurfaceColor: map.surfaceColor.withValues(alpha: 0.88),
        bonusSurfaceColor: map.accentColor.withValues(alpha: 0.22),
        foundSurfaceColor: map.accentColor.withValues(alpha: 0.60),
        gridIdleColor: map.surfaceColor.withValues(alpha: 0.92),
        gridSelectedColor: map.accentColor.withValues(alpha: 0.48),
        gridFoundColor: map.pathColor.withValues(alpha: 0.55),
        gridErrorColor: const Color(0xFF8B3140),
        gridTextColor: map.textColor,
        connectorColor: map.pathColor,
        connectorGlowColor: map.resolvedSceneGlowColor.withValues(alpha: 0.70),
        instructionSurfaceColor: map.surfaceColor.withValues(alpha: 0.90),
        finishButtonColor: map.nodeColor,
        completionSurfaceTop: map.surfaceColor,
        completionSurfaceBottom: map.backgroundColor,
        completionIcon: completionIcon,
      ),
      sceneCatalog: <String, WordHuntGameplaySceneDefinition>{scene.id: scene},
      sceneSchedule: WordHuntGameplaySceneSchedule(defaultSceneId: scene.id),
    );
  }
}

class WordHuntGameplaySceneBackground extends StatefulWidget {
  const WordHuntGameplaySceneBackground({super.key, required this.scene});

  final WordHuntGameplaySceneDefinition scene;

  @override
  State<WordHuntGameplaySceneBackground> createState() =>
      _WordHuntGameplaySceneBackgroundState();
}

class _WordHuntGameplaySceneBackgroundState
    extends State<WordHuntGameplaySceneBackground> {
  Future<Uint8List>? _bytes;

  @override
  void initState() {
    super.initState();
    _syncBytes();
  }

  @override
  void didUpdateWidget(covariant WordHuntGameplaySceneBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id ||
        oldWidget.scene.base64AssetParts.join('|') !=
            widget.scene.base64AssetParts.join('|')) {
      _syncBytes();
    }
  }

  void _syncBytes() {
    _bytes = widget.scene.base64AssetParts.isEmpty ? null : _loadBytes();
  }

  Future<Uint8List> _loadBytes() async {
    final encoded = StringBuffer();
    for (final path in widget.scene.base64AssetParts) {
      encoded.write((await rootBundle.loadString(path)).trim());
    }
    return base64Decode(encoded.toString());
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    Widget image;
    if (scene.assetPath != null) {
      image = Image.asset(
        scene.assetPath!,
        fit: scene.fit,
        alignment: scene.alignment,
        filterQuality: FilterQuality.high,
      );
    } else {
      image = FutureBuilder<Uint8List>(
        future: _bytes,
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null) return ColoredBox(color: scene.backgroundColor);
          return Image.memory(
            bytes,
            fit: scene.fit,
            alignment: scene.alignment,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          );
        },
      );
    }

    return ColoredBox(
      color: scene.backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          image,
          if (scene.overlayColor != Colors.transparent)
            ColoredBox(color: scene.overlayColor),
          if (scene.vignetteColor != Colors.transparent)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.95,
                  colors: <Color>[Colors.transparent, scene.vignetteColor],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
