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
    this.overlayDecorationsOnArtwork = false,
  }) : assert(decorationOpacity >= 0 && decorationOpacity <= 1),
       assert(backgroundBlurSigma >= 0),
       assert(backgroundScale >= 1);

  final String id;
  final WordHuntRouteMapTheme mapTheme;
  final WordHuntRouteDecorationSpec decorationSpec;
  final WordHuntRouteDecorationPalette decorationPalette;
  final double decorationOpacity;

  /// Opsiyonel gerçek rota artwork'ü. Görsel yalnız sahne tabanıdır; node,
  /// hitbox, yıldız, kilit veya progression state'i asset içine bake edilmez.
  /// Böylece aynı canonical 1-10 motoru raster sahne üzerinde de çalışır.
  final String? backgroundAsset;

  /// Binary asset yükleme imkanı olmayan üretim akışlarında aynı rasterın
  /// base64 metin parçaları kullanılabilir. Renderer parçaları sırayla
  /// birleştirip bellekte decode eder; bu alan da yalnız sahne tabanıdır.
  /// İki kaynak aynı anda verilirse base64 parçaları önceliklidir.
  final List<String> backgroundBase64AssetParts;

  final BoxFit backgroundFit;
  final Alignment backgroundAlignment;
  final double backgroundBlurSigma;
  final Color backgroundOverlayColor;

  /// Artwork kadrajını tema verisinden yakınlaştırmaya yarar. Geometriyi veya
  /// hitbox'ları değiştirmez; yalnız raster sahnenin kadrajıdır.
  final double backgroundScale;

  /// Final raster sahne varken procedural ağaç/mantar/dekor tekrar çizilmez.
  /// Bu değer yalnız bilinçli bir hibrit tema istendiğinde true yapılmalıdır.
  final bool overlayDecorationsOnArtwork;

  bool get hasArtwork =>
      backgroundAsset != null || backgroundBase64AssetParts.isNotEmpty;
}

/// Bütün temalı 10-bölümlük rotalar için tek generic bağlayıcı.
///
/// Rota ile görsel skin paketini ortak motora aktarır. Rota adına göre branch,
/// ayrı widget veya koordinat üretmez. Production host, catalog entry içindeki
/// visualTheme verisini bu ortak bağlayıcıya aktarabilir.
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
        Positioned.fill(child: map),
      ],
    );
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
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        );
      },
    );
  }
}

/// Oyunda kullanılacak reusable rota skinleri.
///
/// Bu sınıf proof/QA presetlerinden ayrıdır. Production host gerçek rota için
/// buradaki veriyi kullanır; node koordinatı, hitbox ve progression yine ortak
/// reusable motor tarafından yönetilir.
abstract final class WordHuntRouteVisualThemes {
  static const WordHuntRouteVisualTheme ormanYolu = WordHuntRouteVisualTheme(
    id: 'orman-yolu-production',
    mapTheme: WordHuntRouteMapTheme(
      id: 'orman-yolu-production',
      backgroundColor: Color(0xFF07150D),
      surfaceColor: Color(0xFF143420),
      pathColor: Color(0xFFF2D994),
      lockedPathColor: Color(0xFF72776C),
      nodeColor: Color(0xFF8A5A30),
      lockedNodeColor: Color(0xFF4B5050),
      accentColor: Color(0xFFFFD75A),
      textColor: Color(0xFFFFF8E7),
      sceneGlowColor: Color(0xFFFFE7A8),
      pathUnderlayColor: Color(0xB03B2818),
      nodeShadowColor: Color(0xDB07100A),
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
    backgroundBlurSigma: 0.55,
    backgroundOverlayColor: Color(0x18020A05),
    overlayDecorationsOnArtwork: false,
  );
}

/// Production görsel kararı değildir; reusable motorun farklı skin verileriyle
/// çalışabildiğini kanıtlayan veri-only preset'lerdir.
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
