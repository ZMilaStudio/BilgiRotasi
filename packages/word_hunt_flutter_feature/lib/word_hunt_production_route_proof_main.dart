import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_progress.dart';
import 'word_hunt_pixel_proof_screen.dart';
import 'word_hunt_reference_route_screen.dart';

/// Gerçek production rota bileşenini Android 16 üzerinde doğrulayan izole
/// giriş noktası. Aynı APK içinde production ve pixel-proof ekranlarını ayrı
/// screenshot olarak yakalatır; production `lib/main.dart`ı değiştirmez.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const _WordHuntProductionRouteProofApp());
}

class _WordHuntProductionRouteProofApp extends StatefulWidget {
  const _WordHuntProductionRouteProofApp();

  @override
  State<_WordHuntProductionRouteProofApp> createState() =>
      _WordHuntProductionRouteProofAppState();
}

class _WordHuntProductionRouteProofAppState
    extends State<_WordHuntProductionRouteProofApp> {
  static const WordHuntProgressSnapshot _productionProgress =
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Production Route Proof',
      home: _ProductionRouteRuntimeProbe(child: _buildProofScreen()),
    );
  }

  bool _showPixelProof = false;

  Widget _buildProofScreen() {
    void onLevelTap(int level) {
      debugPrint('[WORD_HUNT_PRODUCTION_NODE_TAP] level=$level');
    }

    if (_showPixelProof) {
      return WordHuntPixelProofScreen(
        progress: _productionProgress,
        onLevelTap: onLevelTap,
        onBack: () {
          debugPrint('[WORD_HUNT_PIXEL_PROOF_CAPTURED]');
          setState(() => _showPixelProof = false);
        },
      );
    }

    return WordHuntReferenceRouteScreen(
      progress: _productionProgress,
      onLevelTap: onLevelTap,
      onInfo: () {
        debugPrint('[WORD_HUNT_PRODUCTION_ROUTE_CAPTURED]');
        setState(() => _showPixelProof = true);
      },
    );
  }
}

class _ProductionRouteRuntimeProbe extends StatefulWidget {
  const _ProductionRouteRuntimeProbe({required this.child});

  final Widget child;

  @override
  State<_ProductionRouteRuntimeProbe> createState() =>
      _ProductionRouteRuntimeProbeState();
}

class _ProductionRouteRuntimeProbeState
    extends State<_ProductionRouteRuntimeProbe> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[WORD_HUNT_PRODUCTION_ROUTE_READY]');
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
