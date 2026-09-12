import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_map_decoration.dart';

/// Bir Kelime Avı rotasının yalnız görsel skin verisini taşır.
///
/// Bilerek node koordinatı, hitbox, progression veya route-id özel widget
/// içermez. Yeni rota görselleştirmesi bu veri paketini değiştirerek yapılmalı;
/// ortak 1-10 geometri motoru değişmemelidir.
@immutable
class WordHuntRouteVisualTheme {
  const WordHuntRouteVisualTheme({
    required this.id,
    required this.mapTheme,
    required this.decorationSpec,
    required this.decorationPalette,
    this.decorationOpacity = 0.38,
    this.backgroundAsset,
    this.backgroundBase64AssetParts = const <String>[],
    this.backgroundFit = BoxFit.cover,
    this.backgroundAlignment = Alignment.center,
    this.backgroundBlurSigma = 0,
    this.backgroundOverlayColor = Colors.transparent,
    this.backgroundScale = 1,
    this.backgroundContrast = 1,
    this.backgroundSaturation = 1,
    this.backgroundVignetteColor = Colors.transparent,
    this.backgroundVignetteStrength = 0,
    this.overlayDecorationsOnArtwork = false,
  }) : assert(decorationOpacity >= 0 && decorationOpacity <= 1),
       assert(backgroundBlurSigma >= 0),
       assert(backgroundScale >= 1),
       assert(backgroundContrast >= 0),
       assert(backgroundSaturation >= 0),
       assert(backgroundVignetteStrength >= 0 && backgroundVignetteStrength <= 1);

  final String id;
  final WordHuntRouteMapTheme mapTheme;
  final WordHuntRouteDecorationSpec decorationSpec;
  final WordHuntRouteDecorationPalette decorationPalette;
  final double decorationOpacity;
  final String? backgroundAsset;
  final List<String> backgroundBase64AssetParts;
  final BoxFit backgroundFit;
  final Alignment backgroundAlignment;
  final double backgroundBlurSigma;
  final Color backgroundOverlayColor;
  final double backgroundScale;

  /// Raster sahnenin yalnız renk sunumunu değiştirir; node/path/hitbox
  /// geometrisine dokunmaz. Tema verisinden geldiği için route-id branch'i
  /// gerektirmeden farklı sahneler kendi color-grade değerlerini taşıyabilir.
  final double backgroundContrast;
  final double backgroundSaturation;

  /// Sahnenin kenarlarını doğal olarak geri çekip merkezdeki rota alanına
  /// derinlik verir. Yalnız sunum katmanıdır; canlı node ve hitbox geometrisi
  /// üzerinde hiçbir etkisi yoktur.
  final Color backgroundVignetteColor;
  final double backgroundVignetteStrength;
  final bool overlayDecorationsOnArtwork;

  bool get hasArtwork =>
      backgroundAsset != null || backgroundBase64AssetParts.isNotEmpty;
}

class WordHuntThemedRouteMapScreen extends StatelessWidget {
  const WordHuntThemedRouteMapScreen({
    super.key,
    required this.route,
    required this.visualTheme,
    this.progress = const WordHuntProgressSnapshot(),
    this.onLevelTap,
  });

  final WordHuntRouteDefinition route;
  final WordHuntRouteVisualTheme visualTheme;
  final WordHuntProgressSnapshot progress;
  final ValueChanged<int>? onLevelTap;

  @override
  Widget build(BuildContext context) {
    final hasArtwork = visualTheme.hasArtwork;
    final effectiveMapTheme = hasArtwork
        ? _transparentSceneTheme(visualTheme.mapTheme)
        : visualTheme.mapTheme;
    final showProceduralDecorations =
        !hasArtwork || visualTheme.overlayDecorationsOnArtwork;

    final map = WordHuntReusableRouteMapScreen(
      route: route,
      theme: effectiveMapTheme,
      progress: progress,
      onLevelTap: onLevelTap,
      decorationSpec: showProceduralDecorations
          ? visualTheme.decorationSpec
          : null,
      decorationPalette: showProceduralDecorations
          ? visualTheme.decorationPalette
          : null,
      decorationOpacity: showProceduralDecorations
          ? visualTheme.decorationOpacity
          : 0,
    );

    if (!hasArtwork) return map;

    Widget artwork = _buildArtwork();
    if (visualTheme.backgroundContrast != 1 ||
        visualTheme.backgroundSaturation != 1) {
      artwork = ColorFiltered(
        key: const Key('word_hunt_route_background_color_filter'),
        colorFilter: _sceneColorFilter(),
        child: artwork,
      );
    }
    if (visualTheme.backgroundScale > 1) {
      artwork = Transform.scale(
        key: const Key('word_hunt_route_background_scale'),
        scale: visualTheme.backgroundScale,
        alignment: visualTheme.backgroundAlignment,
        child: artwork,
      );
    }
    if (visualTheme.backgroundBlurSigma > 0) {
      artwork = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: visualTheme.backgroundBlurSigma,
          sigmaY: visualTheme.backgroundBlurSigma,
        ),
        child: artwork,
      );
    }

    return Stack(
      key: const Key('word_hunt_themed_artwork_stack'),
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(child: artwork),
        if (visualTheme.backgroundOverlayColor.a > 0)
          Positioned.fill(
            key: const Key('word_hunt_route_background_overlay'),
            child: ColoredBox(color: visualTheme.backgroundOverlayColor),
          ),
        if (visualTheme.backgroundVignetteStrength > 0)
          Positioned.fill(
            key: const Key('word_hunt_route_background_vignette'),
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.10),
                    radius: 0.96,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.transparent,
                      visualTheme.backgroundVignetteColor.withValues(
                        alpha: visualTheme.backgroundVignetteStrength * 0.45,
                      ),
                      visualTheme.backgroundVignetteColor.withValues(
                        alpha: visualTheme.backgroundVignetteStrength,
                      ),
                    ],
                    stops: const <double>[0.0, 0.48, 0.78, 1.0],
                  ),
                ),
              ),
            ),
          ),
        Positioned.fill(child: map),
      ],
    );
  }

  ColorFilter _sceneColorFilter() {
    final saturation = visualTheme.backgroundSaturation;
    final contrast = visualTheme.backgroundContrast;
    const redLuma = 0.2126;
    const greenLuma = 0.7152;
    const blueLuma = 0.0722;
    final inverseSaturation = 1 - saturation;
    final contrastOffset = 128 * (1 - contrast);

    return ColorFilter.matrix(<double>[
      contrast * (inverseSaturation * redLuma + saturation),
      contrast * inverseSaturation * greenLuma,
      contrast * inverseSaturation * blueLuma,
      0,
      contrastOffset,
      contrast * inverseSaturation * redLuma,
      contrast * (inverseSaturation * greenLuma + saturation),
      contrast * inverseSaturation * blueLuma,
      0,
      contrastOffset,
      contrast * inverseSaturation * redLuma,
      contrast * inverseSaturation * greenLuma,
      contrast * (inverseSaturation * blueLuma + saturation),
      0,
      contrastOffset,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  Widget _buildArtwork() {
    final base64Parts = visualTheme.backgroundBase64AssetParts;
    if (base64Parts.isNotEmpty) {
      return _Base64AssetArtwork(
        key: const Key('word_hunt_route_background_asset'),
        partAssets: base64Parts,
        fit: visualTheme.backgroundFit,
        alignment: visualTheme.backgroundAlignment,
        fallbackColor: visualTheme.mapTheme.backgroundColor,
      );
    }

    return Image.asset(
      visualTheme.backgroundAsset!,
      key: const Key('word_hunt_route_background_asset'),
      fit: visualTheme.backgroundFit,
      alignment: visualTheme.backgroundAlignment,
      filterQuality: FilterQuality.high,
    );
  }

  WordHuntRouteMapTheme _transparentSceneTheme(WordHuntRouteMapTheme source) {
    return WordHuntRouteMapTheme(
      id: source.id,
      backgroundColor: Colors.transparent,
      surfaceColor: Colors.transparent,
      pathColor: source.pathColor,
      lockedPathColor: source.lockedPathColor,
      nodeColor: source.nodeColor,
      lockedNodeColor: source.lockedNodeColor,
      accentColor: source.accentColor,
      textColor: source.textColor,
      sceneGlowColor: Colors.transparent,
      pathUnderlayColor: source.pathUnderlayColor,
      nodeShadowColor: source.nodeShadowColor,
      sceneDepth: 0,
    );
  }
}

class _Base64AssetArtwork extends StatefulWidget {
  const _Base64AssetArtwork({
    super.key,
    required this.partAssets,
    required this.fit,
    required this.alignment,
    required this.fallbackColor,
  });

  final List<String> partAssets;
  final BoxFit fit;
  final Alignment alignment;
  final Color fallbackColor;

  @override
  State<_Base64AssetArtwork> createState() => _Base64AssetArtworkState();
}

class _Base64AssetArtworkState extends State<_Base64AssetArtwork> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = _loadBytes();
  }

  @override
  void didUpdateWidget(covariant _Base64AssetArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.partAssets.join('|') != widget.partAssets.join('|')) {
      _bytes = _loadBytes();
    }
  }

  Future<Uint8List> _loadBytes() async {
    final encoded = StringBuffer();
    for (final asset in widget.partAssets) {
      encoded.write((await rootBundle.loadString(asset)).trim());
    }
    return base64Decode(encoded.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return ColoredBox(color: widget.fallbackColor);
        }
        return Image.memory(
          bytes,
          fit: widget.fit,
          alignment: widget.alignment,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
        );
      },
    );
  }
}

abstract final class WordHuntRouteVisualThemes {
  static const WordHuntRouteVisualTheme ormanYolu = WordHuntRouteVisualTheme(
    id: 'orman-yolu-production',
    mapTheme: WordHuntRouteMapTheme(
      id: 'orman-yolu-production',
      backgroundColor: Color(0xFF07150D),
      surfaceColor: Color(0xFF143420),
      pathColor: Color(0xFFFFF0C2),
      lockedPathColor: Color(0xFFC6C4BB),
      nodeColor: Color(0xFF8B592E),
      lockedNodeColor: Color(0xFF5D6460),
      accentColor: Color(0xFFFFD34E),
      textColor: Color(0xFFFFF8E7),
      sceneGlowColor: Color(0xFFFFE7A8),
      pathUnderlayColor: Color(0xFFB08A52),
      nodeShadowColor: Color(0xFF34452F),
      sceneDepth: 0.58,
    ),
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 20260912,
      count: 28,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF4F8A45),
      secondary: Color(0xFF6A4328),
      accent: Color(0xFFFFE08A),
    ),
    decorationOpacity: 0.94,
    backgroundBase64AssetParts: <String>[
      'assets/word_hunt/orman_yolu_scene_00.b64',
      'assets/word_hunt/orman_yolu_scene_01.b64',
      'assets/word_hunt/orman_yolu_scene_02.b64',
      'assets/word_hunt/orman_yolu_scene_03.b64',
      'assets/word_hunt/orman_yolu_scene_04.b64',
      'assets/word_hunt/orman_yolu_scene_05.b64',
      'assets/word_hunt/orman_yolu_scene_06.b64',
    ],
    backgroundFit: BoxFit.cover,
    backgroundAlignment: Alignment.center,
    backgroundBlurSigma: 0,
    backgroundOverlayColor: Colors.transparent,
    backgroundContrast: 1.12,
    backgroundSaturation: 1.14,
    backgroundVignetteColor: Color(0xFF06110A),
    backgroundVignetteStrength: 0.38,
    overlayDecorationsOnArtwork: false,
  );
}

abstract final class WordHuntRouteVisualThemeProofs {
  static const WordHuntRouteVisualTheme forest = WordHuntRouteVisualTheme(
    id: 'forest-proof',
    mapTheme: WordHuntRouteMapTheme(
      id: 'forest-proof',
      backgroundColor: Color(0xFF07150D),
      surfaceColor: Color(0xFF143420),
      pathColor: Color(0xFFEBD49B),
      lockedPathColor: Color(0xFF657066),
      nodeColor: Color(0xFF81542F),
      lockedNodeColor: Color(0xFF4A5050),
      accentColor: Color(0xFFFFD96B),
      textColor: Color(0xFFFFF7E2),
      sceneGlowColor: Color(0xFFFFE7A8),
      pathUnderlayColor: Color(0xA7352416),
      nodeShadowColor: Color(0xD407100A),
      sceneDepth: 0.58,
    ),
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.forest,
      seed: 20260912,
      count: 28,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF4F8A45),
      secondary: Color(0xFF6A4328),
      accent: Color(0xFFFFE08A),
    ),
    decorationOpacity: 0.94,
  );

  static const WordHuntRouteVisualTheme sky = WordHuntRouteVisualTheme(
    id: 'sky-proof',
    mapTheme: WordHuntRouteMapTheme.skyProof,
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.sky,
      seed: 20260913,
      count: 16,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFFB9D7FF),
      secondary: Color(0xFF7C8CCF),
      accent: Color(0xFFFDE68A),
    ),
  );

  static const WordHuntRouteVisualTheme harbor = WordHuntRouteVisualTheme(
    id: 'harbor-proof',
    mapTheme: WordHuntRouteMapTheme.harborProof,
    decorationSpec: WordHuntRouteDecorationSpec(
      kind: WordHuntRouteDecorationKind.harbor,
      seed: 20260914,
      count: 14,
    ),
    decorationPalette: WordHuntRouteDecorationPalette(
      primary: Color(0xFF58D5E6),
      secondary: Color(0xFF0C2B3C),
      accent: Color(0xFFFFC857),
    ),
  );

  static const List<WordHuntRouteVisualTheme> all =
      <WordHuntRouteVisualTheme>[forest, sky, harbor];
}
