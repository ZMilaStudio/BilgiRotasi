import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_orman_content.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_themed_production_route_screen.dart';

/// Orman Yolu'nun gerçek production kompozisyonunu Android 16'da kanıtlayan
/// izole giriş noktasıdır. Production `lib/main.dart` bu dosyayı kullanmaz.
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
      WordHuntProgressSnapshot();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Orman Production Proof',
      home: _ReusableProofRuntimeProbe(
        child: WordHuntThemedProductionRouteScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: WordHuntRouteVisualThemes.ormanYolu,
          progress: _proofProgress,
          onBack: _noop,
          onInfo: _noop,
          onLevelTap: _noopLevel,
        ),
      ),
    );
  }

  static void _noop() {}
  static void _noopLevel(int _) {}
}

class _ReusableProofRuntimeProbe extends StatefulWidget {
  const _ReusableProofRuntimeProbe({required this.child});

  final Widget child;

  @override
  State<_ReusableProofRuntimeProbe> createState() =>
      _ReusableProofRuntimeProbeState();
}

class _ReusableProofRuntimeProbeState extends State<_ReusableProofRuntimeProbe> {
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final encoded = StringBuffer();
        for (final asset
            in WordHuntRouteVisualThemes.ormanYolu.backgroundBase64AssetParts) {
          encoded.write((await rootBundle.loadString(asset)).trim());
        }
        final bytes = base64Decode(encoded.toString());
        final codec = await ui.instantiateImageCodec(bytes);
        try {
          final frame = await codec.getNextFrame();
          try {
            debugPrint(
              '[WORD_HUNT_REUSABLE_MAP_PROOF_ARTWORK_READY] '
              'width=${frame.image.width} height=${frame.image.height}',
            );
          } finally {
            frame.image.dispose();
          }
        } finally {
          codec.dispose();
        }

        await Future<void>.delayed(const Duration(milliseconds: 200));
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        debugPrint('[WORD_HUNT_REUSABLE_MAP_PROOF_FRAME_READY]');
      } catch (error, stackTrace) {
        debugPrint('[WORD_HUNT_REUSABLE_MAP_PROOF_ERROR] error=$error');
        debugPrintStack(
          label: '[WORD_HUNT_REUSABLE_MAP_PROOF_ERROR_STACK]',
          stackTrace: stackTrace,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
