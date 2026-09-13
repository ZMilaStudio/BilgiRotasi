import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_visual_theme.dart';

/// Reusable/themed Kelime Avı rotalarının production chrome katmanı.
///
/// Raster artwork kullanan rotalarda chrome sahnenin üstünde yüzen hafif cam
/// kontrollerdir; ayrı bir üst şerit açıp artwork'ü aşağı itmez. Artwork olmayan
/// reusable/proof temalar mevcut column sözleşmesini korur.
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
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    children: <Widget>[
                      _ChromeButton(
                        key: const Key('word_hunt_themed_chrome_back'),
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Geri',
                        color: theme.textColor,
                        onPressed: onBack,
                      ),
                      const Spacer(),
                      _ChromeButton(
                        key: const Key('word_hunt_themed_chrome_info'),
                        icon: Icons.info_outline_rounded,
                        tooltip: 'Bilgi',
                        color: theme.textColor,
                        onPressed: onInfo,
                      ),
                      const SizedBox(width: 8),
                      _ChromeButton(
                        key: const Key('word_hunt_themed_chrome_compass'),
                        icon: Icons.explore_outlined,
                        tooltip: 'Pusula',
                        color: theme.accentColor,
                        onPressed: onCompass,
                      ),
                      const SizedBox(width: 8),
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
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x8A07110A),
                  border: Border.all(color: const Color(0x2EFFFFFF)),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 21),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
