import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_edge_ambient.dart';
import 'word_hunt_models.dart';
import 'word_hunt_production_assets.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_chrome_theme.dart';
import 'word_hunt_route_ux_scope.dart';
import 'word_hunt_route_visual_theme.dart';

class WordHuntThemedProductionRouteScreen extends StatefulWidget {
  const WordHuntThemedProductionRouteScreen({
    super.key,
    required this.route,
    required this.visualTheme,
    required this.progress,
    required this.onBack,
    required this.onInfo,
    required this.onCompass,
    required this.onBook,
    required this.onLevelTap,
    this.segmentIndex = 1,
  });

  final WordHuntRouteDefinition route;
  final WordHuntRouteVisualTheme visualTheme;
  final WordHuntProgressSnapshot progress;
  final VoidCallback onBack;
  final VoidCallback onInfo;
  final VoidCallback onCompass;
  final VoidCallback onBook;
  final ValueChanged<int> onLevelTap;
  final int segmentIndex;

  @override
  State<WordHuntThemedProductionRouteScreen> createState() =>
      _WordHuntThemedProductionRouteScreenState();
}

class _WordHuntThemedProductionRouteScreenState
    extends State<WordHuntThemedProductionRouteScreen> {
  static const double _ormanAmbientBandThreshold = 12;
  static const double _ormanAmbientFeatherOverlap = 8;
  static const double _edgeAmbientFeatherOverlap = 48;
  static const double _compactReferenceScaleThreshold = 0.95;
  static const double _compactTopControlExtent = 48;
  static const double _compactTopControlVisualExtent = 40;

  int? _highlightedLevelIndex;
  int _highlightEpoch = 0;
  Timer? _highlightTimer;

  bool get _usesOrmanReferenceCanvas =>
      widget.visualTheme.referenceCanvasSize != null;

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _handleCompass() {
    _highlightTimer?.cancel();
    if (!WordHuntRouteProgressEngine.isRouteComplete(
      widget.route,
      widget.progress,
    )) {
      final level = WordHuntRouteProgressEngine.nextPlayableLevelIndex(
        widget.route,
        widget.progress,
      );
      final epoch = _highlightEpoch + 1;
      setState(() {
        _highlightedLevelIndex = level;
        _highlightEpoch = epoch;
      });
      _highlightTimer = Timer(const Duration(milliseconds: 1050), () {
        if (!mounted || epoch != _highlightEpoch) return;
        setState(() => _highlightedLevelIndex = null);
      });
    }
    widget.onCompass();
  }

  Widget _withOpeningTransition(Widget child) {
    return TweenAnimationBuilder<double>(
      key: const Key('word_hunt_orman_opening_transition'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      child: child,
      builder:
          (context, value, animatedChild) => Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.992 + (0.008 * value),
              alignment: Alignment.center,
              child: animatedChild,
            ),
          ),
    );
  }

  Widget _artworkFrame(WordHuntRouteMapTheme theme) {
    final chromeTheme = widget.visualTheme.chromeTheme;
    final frameColor = chromeTheme?.headerTint ?? theme.accentColor;
    final frameWidth = switch (chromeTheme?.materialFamily) {
      WordHuntChromeMaterialFamily.engineeredMetal => 1.5,
      WordHuntChromeMaterialFamily.carvedStone => 1.3,
      WordHuntChromeMaterialFamily.ceremonialStone => 1.4,
      WordHuntChromeMaterialFamily.legacyGlass || null => 1.1,
    };
    return IgnorePointer(
      child: DecoratedBox(
        key: const Key('word_hunt_themed_artwork_frame'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: frameColor.withValues(alpha: 0.34),
            width: frameWidth,
          ),
        ),
      ),
    );
  }

  WordHuntChromeControlSpec? _controlSpec(_WordHuntChromeSlot slot) {
    final chrome = widget.visualTheme.chromeTheme;
    if (chrome == null) return null;
    return switch (slot) {
      _WordHuntChromeSlot.back => chrome.back,
      _WordHuntChromeSlot.info => chrome.info,
      _WordHuntChromeSlot.compass => chrome.compass,
      _WordHuntChromeSlot.codex => chrome.codex,
    };
  }

  Widget _artworkControl({
    required Key key,
    required _WordHuntChromeSlot slot,
    required String label,
    required IconData legacyIcon,
    required WordHuntRouteMapTheme theme,
    required VoidCallback onPressed,
    String? legacyAssetPath,
  }) {
    final configured = _controlSpec(slot);
    if (configured == null) {
      if (legacyAssetPath != null) {
        return _ArtworkAssetButton(
          key: key,
          assetPath: legacyAssetPath,
          semanticLabel: label,
          onPressed: onPressed,
        );
      }
      return _ArtworkChromeButton(
        key: key,
        icon: legacyIcon,
        tooltip: label,
        accent: theme.accentColor,
        textColor: theme.textColor,
        surfaceTint: null,
        materialFamily: WordHuntChromeMaterialFamily.legacyGlass,
        onPressed: onPressed,
      );
    }

    if (configured.kind == WordHuntChromeControlKind.asset) {
      return _ArtworkAssetButton(
        key: key,
        assetPath: configured.assetPath!,
        semanticLabel: label,
        onPressed: onPressed,
      );
    }

    return _ArtworkChromeButton(
      key: key,
      icon: configured.icon!,
      tooltip: label,
      accent: theme.accentColor,
      textColor: theme.textColor,
      surfaceTint: widget.visualTheme.chromeTheme?.surfaceTint,
      materialFamily:
          widget.visualTheme.chromeTheme?.materialFamily ??
          WordHuntChromeMaterialFamily.legacyGlass,
      onPressed: onPressed,
    );
  }

  Widget _referenceTopArtworkControl({
    required Key key,
    required _WordHuntChromeSlot slot,
    required String label,
    required IconData legacyIcon,
    required WordHuntRouteMapTheme theme,
    required VoidCallback onPressed,
    required bool compact,
  }) {
    final visualExtent = compact ? _compactTopControlVisualExtent : 52.0;
    return SizedBox.expand(
      key: key,
      child: Center(
        child: SizedBox.square(
          key: Key('word_hunt_reference_${slot.name}_visual_control'),
          dimension: visualExtent,
          child: FittedBox(
            fit: BoxFit.contain,
            child: _artworkControl(
              key: Key('word_hunt_reference_${slot.name}_inner_control'),
              slot: slot,
              label: label,
              legacyIcon: legacyIcon,
              theme: theme,
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fixedArtworkChrome({
    required WordHuntRouteMapTheme theme,
    required Widget map,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(child: _withOpeningTransition(map)),
        Positioned.fill(
          child: SafeArea(
            minimum: const EdgeInsets.all(5),
            child: _artworkFrame(theme),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: _artworkControl(
                    key: const Key('word_hunt_themed_chrome_back'),
                    slot: _WordHuntChromeSlot.back,
                    label: 'Geri',
                    legacyIcon: Icons.arrow_back_rounded,
                    theme: theme,
                    onPressed: widget.onBack,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: _artworkControl(
                    key: const Key('word_hunt_themed_chrome_info'),
                    slot: _WordHuntChromeSlot.info,
                    label: 'Bilgi',
                    legacyIcon: Icons.info_outline_rounded,
                    theme: theme,
                    onPressed: widget.onInfo,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _artworkControl(
                    key: const Key('word_hunt_themed_chrome_compass'),
                    slot: _WordHuntChromeSlot.compass,
                    label: 'Pusula',
                    legacyIcon: Icons.explore_outlined,
                    legacyAssetPath: WordHuntProductionAssets.compassButton,
                    theme: theme,
                    onPressed: _handleCompass,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _artworkControl(
                    key: const Key('word_hunt_themed_chrome_book'),
                    slot: _WordHuntChromeSlot.codex,
                    label: 'Kitap',
                    legacyIcon: Icons.menu_book_rounded,
                    legacyAssetPath: WordHuntProductionAssets.bookButton,
                    theme: theme,
                    onPressed: widget.onBook,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ormanAmbientBackground(
    WordHuntRouteMapTheme theme, {
    required bool isTop,
  }) {
    final parts = widget.visualTheme.backgroundBase64AssetParts;
    final asset = widget.visualTheme.backgroundAsset;
    final alignment = isTop ? Alignment.topCenter : Alignment.bottomCenter;

    Widget artwork;
    if (parts.isNotEmpty) {
      artwork = _AmbientBase64Artwork(
        partAssets: parts,
        isTop: isTop,
        fallbackColor: theme.backgroundColor,
      );
    } else if (asset != null) {
      artwork = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(1, -1, 1),
        child: Transform.scale(
          scale: 1.08,
          alignment: alignment,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              alignment: alignment,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      );
    } else {
      artwork = ColoredBox(color: theme.backgroundColor);
    }

    final ambientEdge = theme.backgroundColor.withValues(alpha: 0.34);
    final ambientMid = theme.backgroundColor.withValues(alpha: 0.10);
    final ambientClear = theme.backgroundColor.withValues(alpha: 0);

    return IgnorePointer(
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(child: artwork),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isTop
                            ? <Color>[ambientEdge, ambientMid, ambientClear]
                            : <Color>[ambientClear, ambientMid, ambientEdge],
                    stops: const <double>[0, 0.68, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ormanAmbientBand({
    required WordHuntRouteMapTheme theme,
    required double extent,
    required double featherExtent,
    required bool isTop,
  }) {
    if (extent <= _ormanAmbientBandThreshold ||
        widget.visualTheme.tallAmbientMode == WordHuntTallAmbientMode.none) {
      return const SizedBox.shrink();
    }

    final featherRatio = (featherExtent / extent).clamp(0.0, 1.0).toDouble();

    if (widget.visualTheme.tallAmbientMode ==
        WordHuntTallAmbientMode.edgeDerivedLowFrequency) {
      final asset = widget.visualTheme.backgroundAsset;
      if (asset == null) {
        return ColoredBox(color: theme.backgroundColor);
      }
      return WordHuntEdgeDerivedAmbient(
        assetPath: asset,
        edge: isTop ? WordHuntAmbientEdge.top : WordHuntAmbientEdge.bottom,
        fallbackColor: theme.backgroundColor,
        featherFraction: featherRatio,
      );
    }

    final stops =
        isTop ? <double>[0, 1 - featherRatio, 1] : <double>[0, featherRatio, 1];
    final colors =
        isTop
            ? const <Color>[Colors.white, Colors.white, Colors.transparent]
            : const <Color>[Colors.transparent, Colors.white, Colors.white];

    return RepaintBoundary(
      key: Key(
        isTop
            ? 'word_hunt_orman_ambient_top_band'
            : 'word_hunt_orman_ambient_bottom_band',
      ),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback:
            (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
              stops: stops,
            ).createShader(bounds),
        child: _ormanAmbientBackground(theme, isTop: isTop),
      ),
    );
  }

  Widget _ormanReferenceChrome({
    required WordHuntRouteMapTheme theme,
    required Widget map,
  }) {
    final referenceCanvasSize = widget.visualTheme.referenceCanvasSize!;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.biggest;
          final fitted =
              applyBoxFit(
                BoxFit.contain,
                referenceCanvasSize,
                available,
              ).destination;
          final left = math.max(0.0, (available.width - fitted.width) / 2);
          final top = math.max(0.0, (available.height - fitted.height) / 2);
          final right = math.max(0.0, available.width - left - fitted.width);
          final bottom = math.max(0.0, available.height - top - fitted.height);
          final referenceScale = fitted.width / referenceCanvasSize.width;
          final compactTopChrome =
              referenceScale < _compactReferenceScaleThreshold;
          final topControlExtent =
              compactTopChrome ? _compactTopControlExtent : 52.0;
          final topControlInset = compactTopChrome ? 0.0 : 6.0;
          final edgeAmbientFeatherOverlap =
              widget.visualTheme.tallAmbientMode ==
                      WordHuntTallAmbientMode.edgeDerivedLowFrequency
                  ? _edgeAmbientFeatherOverlap
                  : _ormanAmbientFeatherOverlap;
          final boardMediaQuery = MediaQuery.of(context).copyWith(
            size: referenceCanvasSize,
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          );

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned.fill(child: ColoredBox(color: theme.backgroundColor)),
              Positioned(
                left: left,
                top: top,
                width: fitted.width,
                height: fitted.height,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox(
                    key: const Key('word_hunt_orman_reference_canvas'),
                    width: referenceCanvasSize.width,
                    height: referenceCanvasSize.height,
                    child: MediaQuery(
                      data: boardMediaQuery,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Positioned.fill(child: _withOpeningTransition(map)),
                          Positioned.fill(child: _artworkFrame(theme)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.visualTheme.extendTallAmbientFromArtworkEdges &&
                  top > _ormanAmbientBandThreshold)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: top + edgeAmbientFeatherOverlap,
                  child: _ormanAmbientBand(
                    theme: theme,
                    extent: top + edgeAmbientFeatherOverlap,
                    featherExtent: edgeAmbientFeatherOverlap,
                    isTop: true,
                  ),
                ),
              if (widget.visualTheme.extendTallAmbientFromArtworkEdges &&
                  bottom > _ormanAmbientBandThreshold)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: bottom + edgeAmbientFeatherOverlap,
                  child: _ormanAmbientBand(
                    theme: theme,
                    extent: bottom + edgeAmbientFeatherOverlap,
                    featherExtent: edgeAmbientFeatherOverlap,
                    isTop: false,
                  ),
                ),
              Positioned(
                left: left + 8,
                top: top + topControlInset,
                width: topControlExtent,
                height: topControlExtent,
                child: _referenceTopArtworkControl(
                  key: const Key('word_hunt_themed_chrome_back'),
                  slot: _WordHuntChromeSlot.back,
                  label: 'Geri',
                  legacyIcon: Icons.arrow_back_rounded,
                  theme: theme,
                  onPressed: widget.onBack,
                  compact: compactTopChrome,
                ),
              ),
              Positioned(
                right: right + 8,
                top: top + topControlInset,
                width: topControlExtent,
                height: topControlExtent,
                child: _referenceTopArtworkControl(
                  key: const Key('word_hunt_themed_chrome_info'),
                  slot: _WordHuntChromeSlot.info,
                  label: 'Bilgi',
                  legacyIcon: Icons.info_outline_rounded,
                  theme: theme,
                  onPressed: widget.onInfo,
                  compact: compactTopChrome,
                ),
              ),
              Positioned(
                left: left + 8,
                bottom: bottom + 8,
                child: _artworkControl(
                  key: const Key('word_hunt_themed_chrome_compass'),
                  slot: _WordHuntChromeSlot.compass,
                  label: 'Pusula',
                  legacyIcon: Icons.explore_outlined,
                  legacyAssetPath: WordHuntProductionAssets.compassButton,
                  theme: theme,
                  onPressed: _handleCompass,
                ),
              ),
              Positioned(
                right: right + 8,
                bottom: bottom + 8,
                child: _artworkControl(
                  key: const Key('word_hunt_themed_chrome_book'),
                  slot: _WordHuntChromeSlot.codex,
                  label: 'Kitap',
                  legacyIcon: Icons.menu_book_rounded,
                  legacyAssetPath: WordHuntProductionAssets.bookButton,
                  theme: theme,
                  onPressed: widget.onBook,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.visualTheme.mapTheme;
    final map = WordHuntRouteUxScope(
      highlightedLevelIndex: _highlightedLevelIndex,
      highlightEpoch: _highlightEpoch,
      child: WordHuntThemedRouteMapScreen(
        route: widget.route,
        visualTheme: widget.visualTheme,
        progress: widget.progress,
        onLevelTap: widget.onLevelTap,
        segmentIndex: widget.segmentIndex,
      ),
    );

    if (widget.visualTheme.hasArtwork) {
      return Scaffold(
        key: const Key('word_hunt_themed_production_route'),
        backgroundColor: theme.backgroundColor,
        body:
            _usesOrmanReferenceCanvas
                ? _ormanReferenceChrome(theme: theme, map: map)
                : _fixedArtworkChrome(theme: theme, map: map),
      );
    }

    return Scaffold(
      key: const Key('word_hunt_themed_production_route'),
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _ChromeButton(
                    key: const Key('word_hunt_themed_chrome_back'),
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Geri',
                    color: theme.textColor,
                    onPressed: widget.onBack,
                  ),
                  _ChromeButton(
                    key: const Key('word_hunt_themed_chrome_info'),
                    icon: Icons.info_outline_rounded,
                    tooltip: 'Bilgi',
                    color: theme.textColor,
                    onPressed: widget.onInfo,
                  ),
                  _ChromeButton(
                    key: const Key('word_hunt_themed_chrome_compass'),
                    icon: Icons.explore_outlined,
                    tooltip: 'Pusula',
                    color: theme.accentColor,
                    onPressed: _handleCompass,
                  ),
                  _ChromeButton(
                    key: const Key('word_hunt_themed_chrome_book'),
                    icon: Icons.menu_book_rounded,
                    tooltip: 'Kitap',
                    color: theme.textColor,
                    onPressed: widget.onBook,
                  ),
                ],
              ),
            ),
            Expanded(child: map),
          ],
        ),
      ),
    );
  }
}

class _AmbientBase64Artwork extends StatefulWidget {
  const _AmbientBase64Artwork({
    required this.partAssets,
    required this.isTop,
    required this.fallbackColor,
  });

  final List<String> partAssets;
  final bool isTop;
  final Color fallbackColor;

  @override
  State<_AmbientBase64Artwork> createState() => _AmbientBase64ArtworkState();
}

class _AmbientBase64ArtworkState extends State<_AmbientBase64Artwork> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = _loadBytes();
  }

  @override
  void didUpdateWidget(covariant _AmbientBase64Artwork oldWidget) {
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

        final alignment =
            widget.isTop ? Alignment.topCenter : Alignment.bottomCenter;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(1, -1, 1),
          child: Transform.scale(
            scale: 1.08,
            alignment: alignment,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                alignment: alignment,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _WordHuntChromeSlot { back, info, compass, codex }

class _ArtworkChromeButton extends StatelessWidget {
  const _ArtworkChromeButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.accent,
    required this.textColor,
    required this.onPressed,
    this.surfaceTint,
    this.materialFamily = WordHuntChromeMaterialFamily.legacyGlass,
  });

  final IconData icon;
  final String tooltip;
  final Color accent;
  final Color textColor;
  final Color? surfaceTint;
  final WordHuntChromeMaterialFamily materialFamily;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final blurSigma = switch (materialFamily) {
      WordHuntChromeMaterialFamily.legacyGlass => 7.0,
      WordHuntChromeMaterialFamily.carvedStone => 4.0,
      WordHuntChromeMaterialFamily.engineeredMetal => 5.0,
      WordHuntChromeMaterialFamily.ceremonialStone => 4.5,
    };
    final borderWidth = switch (materialFamily) {
      WordHuntChromeMaterialFamily.legacyGlass => 1.4,
      WordHuntChromeMaterialFamily.carvedStone => 1.7,
      WordHuntChromeMaterialFamily.engineeredMetal => 1.6,
      WordHuntChromeMaterialFamily.ceremonialStone => 1.8,
    };

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox.square(
              dimension: 52,
              child: Center(
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: blurSigma,
                      sigmaY: blurSigma,
                    ),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            (surfaceTint ?? const Color(0xFF1C2E20)).withValues(
                              alpha: 0.85,
                            ),
                            Color.alphaBlend(
                              Colors.black.withValues(alpha: 0.55),
                              surfaceTint ?? const Color(0xFF08120C),
                            ).withValues(alpha: 0.90),
                          ],
                        ),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.76),
                          width: borderWidth,
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x77000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: textColor, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtworkAssetButton extends StatelessWidget {
  const _ArtworkAssetButton({
    super.key,
    required this.assetPath,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String assetPath;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: 72,
          child: Center(
            child: SizedBox.square(
              dimension: 64,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChromeButton extends StatelessWidget {
  const _ChromeButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: color),
    );
  }
}
