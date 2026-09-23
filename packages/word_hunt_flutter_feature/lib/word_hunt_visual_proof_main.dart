import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_pixel_proof_screen.dart';
import 'word_hunt_progress.dart';

/// Yalnız görsel inceleme/kanıt için kullanılan izole giriş noktası.
/// Production `lib/main.dart` ve mevcut uygulama navigasyonuna bağlı değildir.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const _WordHuntVisualProofApp());
}

class _WordHuntVisualProofApp extends StatelessWidget {
  const _WordHuntVisualProofApp();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Pixel Proof',
      home: const _AssetRuntimeProbe(
        child: WordHuntPixelProofScreen(progress: _proofProgress),
      ),
    );
  }
}

class _AssetRuntimeProbe extends StatefulWidget {
  const _AssetRuntimeProbe({required this.child});

  final Widget child;

  @override
  State<_AssetRuntimeProbe> createState() => _AssetRuntimeProbeState();
}

class _AssetRuntimeProbeState extends State<_AssetRuntimeProbe> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      String? loadingPath;
      try {
        for (final path in const <String>[
          WordHuntPixelProofAssets.masterArt,
          WordHuntPixelProofAssets.nodeNineOpen,
        ]) {
          loadingPath = path;
          await precacheImage(AssetImage(path), context);
          debugPrint('[WORD_HUNT_PIXEL_PROOF_ASSET_LOADED] path=$path');
        }
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        debugPrint('[WORD_HUNT_VISUAL_PROOF_FRAME_READY]');
      } catch (error, stackTrace) {
        debugPrint(
          '[WORD_HUNT_PIXEL_PROOF_ASSET_ERROR] '
          'path=$loadingPath error=$error',
        );
        debugPrintStack(
          label: '[WORD_HUNT_PIXEL_PROOF_ASSET_ERROR_STACK]',
          stackTrace: stackTrace,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
