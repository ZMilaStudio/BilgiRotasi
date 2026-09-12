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

  /// Kanonik ilk açılış durumu: yalnız bölüm 1 açıktır.
  /// Bölüm 2, yalnız 1 tamamlandıktan sonra; her sonraki bölüm de yalnız
  /// kendinden önceki bölüm tamamlandıktan sonra açılır.
  static const WordHuntProgressSnapshot _proofProgress =
      WordHuntProgressSnapshot();

  /// Android screenshot artık proof presetini değil, Orman Yolu için ayrılan
  /// gerçek production skin verisini render eder. Böylece proof ve production
  /// arasında görsel preset sapması oluşmaz.
  static const WordHuntRouteVisualTheme _visualTheme =
      WordHuntRouteVisualThemes.ormanYolu;

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
