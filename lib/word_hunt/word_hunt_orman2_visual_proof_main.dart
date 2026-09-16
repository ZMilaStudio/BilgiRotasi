import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_orman2_content.dart';
import 'word_hunt_orman2_visual_theme.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_themed_production_route_screen.dart';

/// Orman 2 pilotunun gerçek themed production kompozisyonunu Android 16'da
/// kanıtlayan izole entry point. Production `lib/main.dart` bunu kullanmaz.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const _Orman2VisualProofApp());
}

class _Orman2VisualProofApp extends StatelessWidget {
  const _Orman2VisualProofApp();

  static const WordHuntProgressSnapshot _proofProgress =
      WordHuntProgressSnapshot();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Orman 2 Production Proof',
      home: _Orman2RuntimeProbe(
        child: WordHuntThemedProductionRouteScreen(
          route: WordHuntOrman2Content.orman2,
          visualTheme: WordHuntOrman2VisualTheme.production,
          progress: _proofProgress,
          onBack: _noop,
          onInfo: _noop,
          onCompass: _noop,
          onBook: _noop,
          onLevelTap: _noopLevel,
        ),
      ),
    );
  }

  static void _noop() {}
  static void _noopLevel(int _) {}
}

class _Orman2RuntimeProbe extends StatefulWidget {
  const _Orman2RuntimeProbe({required this.child});

  final Widget child;

  @override
  State<_Orman2RuntimeProbe> createState() => _Orman2RuntimeProbeState();
}

class _Orman2RuntimeProbeState extends State<_Orman2RuntimeProbe> {
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final asset = WordHuntOrman2VisualTheme.production.backgroundAsset!;
        final data = await rootBundle.load(asset);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        final codec = await ui.instantiateImageCodec(bytes);
        try {
          final frame = await codec.getNextFrame();
          try {
            debugPrint(
              '[WORD_HUNT_ORMAN2_PROOF_ARTWORK_READY] '
              'width=${frame.image.width} height=${frame.image.height} '
              'bytes=${bytes.length}',
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
        debugPrint('[WORD_HUNT_ORMAN2_PROOF_FRAME_READY]');
      } catch (error, stackTrace) {
        debugPrint('[WORD_HUNT_ORMAN2_PROOF_ERROR] error=$error');
        debugPrintStack(
          label: '[WORD_HUNT_ORMAN2_PROOF_ERROR_STACK]',
          stackTrace: stackTrace,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
