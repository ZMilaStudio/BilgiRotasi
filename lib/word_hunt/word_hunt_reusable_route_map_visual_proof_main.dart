import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_map_decoration.dart';
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

  WordHuntRouteDefinition get _proofRoute {
    final source = WordHuntStarterContent.baslangicLimani;
    return WordHuntRouteDefinition(
      id: source.id,
      title: 'Orman Yolu',
      theme: 'forest-proof',
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
      home: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          WordHuntReusableRouteMapScreen(
            route: _proofRoute,
            theme: WordHuntRouteMapTheme.forestProof,
            progress: _proofProgress,
          ),
          const _ForestDecorationOverlay(),
        ],
      ),
    );
  }
}

class _ForestDecorationOverlay extends StatelessWidget {
  const _ForestDecorationOverlay();

  static const WordHuntRouteDecorationSpec _spec = WordHuntRouteDecorationSpec(
    kind: WordHuntRouteDecorationKind.forest,
    seed: 20260912,
    count: 18,
  );

  static const WordHuntRouteDecorationPalette _palette =
      WordHuntRouteDecorationPalette(
        primary: Color(0xFF4F8D62),
        secondary: Color(0xFF72533A),
        accent: Color(0xFFF3D47A),
      );

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 54, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: CustomPaint(
              key: const Key('word_hunt_forest_decoration_proof'),
              painter: const WordHuntRouteDecorationPainter(
                spec: _spec,
                reservedPoints: WordHuntRouteMapGeometry.normalizedStops,
                palette: _palette,
                opacity: 0.38,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
