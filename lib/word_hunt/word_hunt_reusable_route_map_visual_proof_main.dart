import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_orman_content.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_visual_theme.dart';

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
          'orman-yolu-01': 3,
          'orman-yolu-02': 3,
          'orman-yolu-03': 3,
          'orman-yolu-04': 3,
          'orman-yolu-05': 3,
          'orman-yolu-06': 3,
          'orman-yolu-07': 3,
        },
      );

  static const WordHuntRouteVisualTheme _visualTheme =
      WordHuntRouteVisualThemeProofs.forest;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Reusable Route Map Proof',
      home: WordHuntThemedRouteMapScreen(
        route: WordHuntOrmanContent.ormanYolu,
        visualTheme: _visualTheme,
        progress: _proofProgress,
      ),
    );
  }
}
