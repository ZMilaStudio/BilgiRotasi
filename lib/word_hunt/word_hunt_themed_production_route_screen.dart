import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_models.dart';
import 'word_hunt_production_assets.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
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
  });

  final WordHuntRouteDefinition route;
  final WordHuntRouteVisualTheme visualTheme;
  final WordHuntProgressSnapshot progress;
  final VoidCallback onBack;
  final VoidCallback onInfo;
  final VoidCallback onCompass;
  final VoidCallback onBook;
  final ValueChanged<int> onLevelTap;

  @override
  State<WordHuntThemedProductionRouteScreen> createState() =>
      _WordHuntThemedProductionRouteScreenState();
}

class _WordHuntThemedProductionRouteScreenState
    extends State<WordHuntThemedProductionRouteScreen> {
  static const Size _ormanReferenceLogicalSize = Size(411, 731);

  int? _highlightedLevelIndex;
  int _highlightEpoch = 0;
  Timer? _highlightTimer;

  bool get _usesOrmanReferenceCanvas =>
      widget.visualTheme.id == 'orman-yolu-production';

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
      builder: (context, value, animatedChild) => Opacity(
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
    return IgnorePointer(
      child: DecoratedBox(
        key: const Key('word_hunt_themed_artwork_frame'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.34),
            width: 1.1,
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
                  child: _ArtworkChromeButton(
                    key: const Key('word_hunt_themed_chrome_back'),
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Geri',
                    accent: theme.accentColor,
                    textColor: theme.textColor,
                    onPressed: widget.onBack,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: _ArtworkChromeButton(
                    key: const Key('word_hunt_themed_chrome_info'),
                    icon: Icons.info_outline_rounded,
                    tooltip: 'Bilgi',
                    accent: theme.accentColor,
                    textColor: theme.textColor,
                    onPressed: widget.onInfo,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _ArtworkAssetButton(
                    key: const Key('word_hunt_themed_chrome_compass'),
                    assetPath: WordHuntProductionAssets.compassButton,
                    semanticLabel: 'Pusula',
                    onPressed: _handleCompass,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _ArtworkAssetButton(
                    key: const Key('word_hunt_themed_chrome_book'),
                    assetPath: WordHuntProductionAssets.bookButton,
                    semanticLabel: 'Kitap',
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

  Widget _ormanAmbientBackground(WordHuntRouteMapTheme theme) {
    final parts = widget.visualTheme.backgroundBase64AssetParts;
    final asset = widget.visualTheme.backgroundAsset;

    Widget artwork;
    if (parts.isNotEmpty) {
      artwork = _AmbientBase64Artwork(
        partAssets: parts,
        alignment: widget.visualTheme.backgroundAlignment,
        fallbackColor: theme.backgroundColor,
      );
    } else if (asset != null) {
      artwork = Image.asset(
        asset,
        fit: BoxFit.cover,
        alignment: widget.visualTheme.backgroundAlignment,
        filterQuality: FilterQuality.medium,
      );
    } else {
      artwork = ColoredBox(color: theme.backgroundColor);
    }

    return RepaintBoundary(
      key: const Key('word_hunt_orman_ambient_background'),
      child: IgnorePointer(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.06,
                  alignment: widget.visualTheme.backgroundAlignment,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: artwork,
                  ),
                ),
              ),
              const Positioned.fill(
                child: ColoredBox(color: Color(0x4206110A)),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0x36030B07),
                        Color(0x12030B07),
                        Color(0x12030B07),
                        Color(0x46030B07),
                      ],
                      stops: <double>[0, 0.22, 0.72, 1],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ormanReferenceChrome({
    required WordHuntRouteMapTheme theme,
    required Widget map,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(child: _ormanAmbientBackground(theme)),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final available = constraints.biggest;
              final fitted = applyBoxFit(
                BoxFit.contain,
                _ormanReferenceLogicalSize,
                available,
              ).destination;
              final left = math.max(0.0, (available.width - fitted.width) / 2);
              final top = math.max(0.0, (available.height - fitted.height) / 2);
              final right = math.max(
                0.0,
                available.width - left - fitted.width,
              );
              final bottom = math.max(
                0.0,
                available.height - top - fitted.height,
              );
              final boardMediaQuery = MediaQuery.of(context).copyWith(
                size: _ormanReferenceLogicalSize,
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
                viewInsets: EdgeInsets.zero,
              );

              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    left: left,
                    top: top,
                    width: fitted.width,
                    height: fitted.height,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SizedBox(
                        key: const Key('word_hunt_orman_reference_canvas'),
                        width: _ormanReferenceLogicalSize.width,
                        height: _ormanReferenceLogicalSize.height,
                        child: MediaQuery(
                          data: boardMediaQuery,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Positioned.fill(
                                child: _withOpeningTransition(map),
                              ),
                              Positioned.fill(child: _artworkFrame(theme)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: left + 8,
                    top: top + 6,
                    child: _ArtworkChromeButton(
                      key: const Key('word_hunt_themed_chrome_back'),
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Geri',
                      accent: theme.accentColor,
                      textColor: theme.textColor,
                      onPressed: widget.onBack,
                    ),
                  ),
                  Positioned(
                    right: right + 8,
                    top: top + 6,
                    child: _ArtworkChromeButton(
                      key: const Key('word_hunt_themed_chrome_info'),
                      icon: Icons.info_outline_rounded,
                      tooltip: 'Bilgi',
                      accent: theme.accentColor,
                      textColor: theme.textColor,
                      onPressed: widget.onInfo,
                    ),
                  ),
                  Positioned(
                    left: left + 8,
                    bottom: bottom + 8,
                    child: _ArtworkAssetButton(
                      key: const Key('word_hunt_themed_chrome_compass'),
                      assetPath: WordHuntProductionAssets.compassButton,
                      semanticLabel: 'Pusula',
                      onPressed: _handleCompass,
                    ),
                  ),
                  Positioned(
                    right: right + 8,
                    bottom: bottom + 8,
                    child: _ArtworkAssetButton(
                      key: const Key('word_hunt_themed_chrome_book'),
                      assetPath: WordHuntProductionAssets.bookButton,
                      semanticLabel: 'Kitap',
                      onPressed: widget.onBook,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
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
      ),
    );

    if (widget.visualTheme.hasArtwork) {
      return Scaffold(
        key: const Key('word_hunt_themed_production_route'),
        backgroundColor: theme.backgroundColor,
        body: _usesOrmanReferenceCanvas
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
    required this.alignment,
    required this.fallbackColor,
  });

  final List<String> partAssets;
  final Alignment alignment;
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
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          alignment: widget.alignment,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
        );
      },
    );
  }
}

class _ArtworkChromeButton extends StatelessWidget {
  const _ArtworkChromeButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.accent,
    required this.textColor,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color accent;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
                    filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color(0xD91C2E20),
                            Color(0xE308120C),
                          ],
                        ),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.76),
                          width: 1.4,
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
