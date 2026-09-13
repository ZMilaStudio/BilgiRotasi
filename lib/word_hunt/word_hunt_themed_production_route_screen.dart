import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_production_assets.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_visual_theme.dart';

/// Reusable/themed Kelime Avı rotalarının production chrome katmanı.
///
/// Raster artwork kullanan rotalarda ayrı bir araç çubuğu açılmaz. Başlangıç
/// Limanı ve Gökyüzü Adaları ile aynı hiyerarşi korunur: geri/bilgi üst
/// köşelerde, pusula/kitap alt köşelerde ve artwork ekranın tamamında görünür.
class WordHuntThemedProductionRouteScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = visualTheme.mapTheme;
    final map = WordHuntThemedRouteMapScreen(
      route: route,
      visualTheme: visualTheme,
      progress: progress,
      onLevelTap: onLevelTap,
    );

    if (visualTheme.hasArtwork) {
      return Scaffold(
        key: const Key('word_hunt_themed_production_route'),
        backgroundColor: theme.backgroundColor,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(child: map),
            Positioned.fill(
              child: IgnorePointer(
                child: SafeArea(
                  minimum: const EdgeInsets.all(5),
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
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
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
                        onPressed: onBack,
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
                        onPressed: onInfo,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: _ArtworkAssetButton(
                        key: const Key('word_hunt_themed_chrome_compass'),
                        assetPath: WordHuntProductionAssets.compassButton,
                        semanticLabel: 'Pusula',
                        onPressed: onCompass,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: _ArtworkAssetButton(
                        key: const Key('word_hunt_themed_chrome_book'),
                        assetPath: WordHuntProductionAssets.bookButton,
                        semanticLabel: 'Kitap',
                        onPressed: onBook,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                    onPressed: onBack,
                  ),
                  _ChromeButton(
                    key: const Key('word_hunt_themed_chrome_info'),
                    icon: Icons.info_outline_rounded,
                    tooltip: 'Bilgi',
                    color: theme.textColor,
                    onPressed: onInfo,
                  ),
                  _ChromeButton(
                    key: const Key('word_hunt_themed_chrome_compass'),
                    icon: Icons.explore_outlined,
                    tooltip: 'Pusula',
                    color: theme.accentColor,
                    onPressed: onCompass,
                  ),
                  _ChromeButton(
                    key: const Key('word_hunt_themed_chrome_book'),
                    icon: Icons.menu_book_rounded,
                    tooltip: 'Kitap',
                    color: theme.textColor,
                    onPressed: onBook,
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
                      colors: <Color>[Color(0xD91C2E20), Color(0xE308120C)],
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
          dimension: 64,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
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
