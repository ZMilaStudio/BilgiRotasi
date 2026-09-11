import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_starter_content.dart';

/// Yalnız reusable 10-bölümlük harita motorunun gerçek Flutter/Android görsel
/// kanıtı için kullanılan izole giriş noktasıdır.
/// Production `lib/main.dart`, katalog ve navigasyon bu dosyayı kullanmaz.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const _ReusableRouteMapVisualProofApp());
}

class _ReusableRouteMapVisualProofApp extends StatelessWidget {
  const _ReusableRouteMapVisualProofApp();

  static const WordHuntProgressSnapshot _proofProgress =
      WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{
          'baslangic-1': 3,
          'baslangic-2': 3,
          'baslangic-3': 3,
          'baslangic-4': 3,
          'baslangic-5': 3,
          'baslangic-6': 3,
          'baslangic-7': 3,
        },
      );

  static const WordHuntRouteVisualTheme _visualTheme =
      WordHuntRouteVisualThemeProofs.forest;

  WordHuntRouteDefinition get _proofRoute {
    final source = WordHuntStarterContent.baslangicLimani;
    return WordHuntRouteDefinition(
      id: source.id,
      title: 'Orman Yolu',
      theme: _visualTheme.id,
      unlockStarsRequired: source.unlockStarsRequired,
      levels: source.levels,
      routeRewardId: 'proof-only-forest-route',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Reusable Route Map Proof',
      home: WordHuntReusableRouteMapScreen(
        route: _proofRoute,
        theme: _visualTheme.mapTheme,
        progress: _proofProgress,
        decorationSpec: _visualTheme.decorationSpec,
        decorationPalette: _visualTheme.decorationPalette,
        decorationOpacity: _visualTheme.decorationOpacity,
      ),
    );
  }
}
