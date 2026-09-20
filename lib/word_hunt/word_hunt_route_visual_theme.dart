import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_artwork_presentation.dart';
import 'word_hunt_artwork_route_map_screen.dart';
import 'word_hunt_edge_ambient.dart';
import 'word_hunt_models.dart';
import 'word_hunt_path_renderer.dart';
import 'word_hunt_orman_clean_environment_assets.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_chrome_theme.dart';
import 'word_hunt_route_map_decoration.dart';
import 'word_hunt_seal_renderer.dart';

/// Bir Kelime Avı rotasının yalnız görsel skin verisini taşır.
///
/// Node koordinatı, hitbox ve progression bu modelde tutulmaz; bunların tamamı
/// ortak 1-10 rota motorunun sorumluluğundadır.
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
    this.artworkOverlayMode = WordHuntArtworkOverlayMode.reusable,
    this.referenceCanvasSize,
    this.extendTallAmbientFromArtworkEdges = false,
    this.sealSpec,
    this.pathSpec,
    this.chromeTheme,
    this.tallAmbientMode = WordHuntTallAmbientMode.legacyMirroredArtwork,
    this.presentationOrder = WordHuntRoutePresentationOrder.forward,
  }) : assert(decorationOpacity >= 0 && decorationOpacity <= 1),
       assert(backgroundBlurSigma >= 0),
       assert(backgroundScale >= 1),
       assert(backgroundContrast >= 0),
       assert(backgroundSaturation >= 0),
       assert(
         backgroundVignetteStrength >= 0 && backgroundVignetteStrength <= 1,
       );

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
  final double backgroundContrast;
  final double backgroundSaturation;
  final Color backgroundVignetteColor;
  final double backgroundVignetteStrength;
  final bool overlayDecorationsOnArtwork;
  final WordHuntArtworkOverlayMode artworkOverlayMode;
  final Size? referenceCanvasSize;
  final bool extendTallAmbientFromArtworkEdges;
  final WordHuntSealVisualSpec? sealSpec;
  final WordHuntPathVisualSpec? pathSpec;
  final WordHuntRouteChromeTheme? chromeTheme;
  final WordHuntTallAmbientMode tallAmbientMode;
  final WordHuntRoutePresentationOrder presentationOrder;

  bool get hasArtwork =>
      backgroundAsset != null || backgroundBase64AssetParts.isNotEmpty;
}

/// Tema/artwork verisini ortak 1-10 geometri ve progression sözleşmesine bağlar.
/// Raster artwork kullanan rotalar generic premium artwork renderer'ını;
/// procedural proof temaları reusable temel renderer'ı kullanır. Seçim route-id
/// üzerinden yapılmaz.
class WordHuntThemedRouteMapScreen extends StatelessWidget {
  const WordHuntThemedRouteMapScreen({
    super.key,
    required this.route,
    required this.visualTheme,
    this.progress = const WordHuntProgressSnapshot(),
    this.onLevelTap,
    this.segmentIndex = 1,
  });

  final WordHuntRouteDefinition route;
  final WordHuntRouteVisualTheme visualTheme;
  final WordHuntProgressSnapshot progress;
  final ValueChanged<int>? onLevelTap;
  final int segmentIndex;

  @override
  Widget build(BuildContext context) {
    final hasArtwork = visualTheme.hasArtwork;
    final effectiveMapTheme = hasArtwork
        ? _transparentSceneTheme(visualTheme.mapTheme)
        : visualTheme.mapTheme;
    final showProceduralDecorations =
        !hasArtwork || visualTheme.overlayDecorationsOnArtwork;

    final Widget map = hasArtwork && !showProceduralDecorations
        ? WordHuntArtworkRouteMapScreen(
            route: route,
            theme: effectiveMapTheme,
            overlayMode: visualTheme.artworkOverlayMode,
            progress: progress,
            onLevelTap: onLevelTap,
            sealSpec: visualTheme.sealSpec,
            pathSpec: visualTheme.pathSpec,
            chromeTheme: visualTheme.chromeTheme,
            presentationOrder: visualTheme.presentationOrder,
            segmentIndex: segmentIndex,
          )
        : WordHuntReusableRouteMapScreen(
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
            sealSpec: visualTheme.sealSpec,
            pathSpec: visualTheme.pathSpec,
            chromeTheme: visualTheme.chromeTheme,
            presentationOrder: visualTheme.presentationOrder,
            segmentIndex: segmentIndex,
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
                    stops: const <double>[0, 0.48, 0.78, 1],
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
      finalAccentColor: source.finalAccentColor,
      nodeVisualStyle: source.nodeVisualStyle,
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
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        );
      },
    );
  }
}

/// Production için kullanılabilecek reusable rota skinleri.
abstract final class WordHuntRouteVisualThemes {
  static const WordHuntRouteVisualTheme ormanYolu = WordHuntRouteVisualTheme(
    id: 'orman-yolu-production',
    mapTheme: WordHuntRouteMapTheme(
      id: 'orman-yolu-production',
      backgroundColor: Color(0xFF07150D),
      surfaceColor: Color(0xFF143420),
      pathColor: Color(0xFFE7CB83),
      lockedPathColor: Color(0xFFB5A276),
      nodeColor: Color(0xFF693C1E),
      lockedNodeColor: Color(0xFF56594F),
      accentColor: Color(0xFFFFD567),
      textColor: Color(0xFFFFF5DE),
      sceneGlowColor: Color(0xFFFFE7A8),
      pathUnderlayColor: Color(0xFF342416),
      nodeShadowColor: Color(0xFF08120D),
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
    backgroundBase64AssetParts: wordHuntOrmanCleanEnvironmentAssetParts,
    backgroundFit: BoxFit.cover,
    backgroundAlignment: Alignment.center,
    backgroundBlurSigma: 0,
    backgroundOverlayColor: Colors.transparent,
    backgroundContrast: 1.05,
    backgroundSaturation: 1.04,
    backgroundVignetteColor: Color(0xFF06110A),
    backgroundVignetteStrength: 0.20,
    overlayDecorationsOnArtwork: false,
    artworkOverlayMode: WordHuntArtworkOverlayMode.embeddedRouteLiveNodes,
    referenceCanvasSize: Size(411, 731),
    extendTallAmbientFromArtworkEdges: true,
  );
}

/// Production kararı değil; ortak renderer'ın farklı skin verileriyle aynı
/// geometriyi koruduğunu kanıtlayan presetlerdir.
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

  static const List<WordHuntRouteVisualTheme> all = <WordHuntRouteVisualTheme>[
    forest,
    sky,
    harbor,
  ];
}
