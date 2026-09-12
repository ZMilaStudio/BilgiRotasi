import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_visual_theme.dart';

/// Reusable/themed Kelime Avı rotalarının production chrome katmanı.
///
/// Ortak 1-10 geometriyi veya tema dekorasyonunu değiştirmez. Yalnız mevcut
/// production rotalarında bulunan geri / bilgi / pusula / kitap kontrollerini
/// generic themed renderer'ın üzerine ekler. Proof ekranları bu wrapper'ı
/// kullanmadığı için görsel kanıt iskeleti değişmeden kalır.
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
            Expanded(
              child: WordHuntThemedRouteMapScreen(
                route: route,
                visualTheme: visualTheme,
                progress: progress,
                onLevelTap: onLevelTap,
              ),
            ),
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
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: color),
    );
  }
}
