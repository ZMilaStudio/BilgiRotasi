import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_orman2_content.dart';
import 'word_hunt_orman2_visual_theme.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_themed_production_route_screen.dart';

/// Orman 2 pilotunun gerçek production kompozisyonunu Android 16'da kanıtlayan
/// proof-only entry point. Production `lib/main.dart` bunu kullanmaz.
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
  static const int _expectedWidth = 941;
  static const int _expectedHeight = 1672;
  static const int _expectedBytes = 1109268;

  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final route = WordHuntOrman2Content.orman2;
        const theme = WordHuntOrman2VisualTheme.production;
        const asset = WordHuntOrman2VisualTheme.assetPath;
        if (route.id != 'orman-2' ||
            theme.id != 'orman-2-production' ||
            theme.backgroundAsset != asset) {
          throw StateError(
            'Unexpected Orman 2 proof config: '
            'route=${route.id} theme=${theme.id} asset=${theme.backgroundAsset}',
          );
        }
        debugPrint(
          '[WORD_HUNT_ORMAN2_PROOF_CONFIG_READY] '
          'route=${route.id} theme=${theme.id} asset=$asset',
        );

        final data = await rootBundle.load(asset);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        if (bytes.length != _expectedBytes) {
          throw StateError(
            'Unexpected Orman 2 asset byte size: ${bytes.length}',
          );
        }

        final codec = await ui.instantiateImageCodec(bytes);
        try {
          final frame = await codec.getNextFrame();
          try {
            final width = frame.image.width;
            final height = frame.image.height;
            if (width != _expectedWidth || height != _expectedHeight) {
              throw StateError(
                'Unexpected Orman 2 raster size: ${width}x$height',
              );
            }
            debugPrint(
              '[WORD_HUNT_ORMAN2_PROOF_ARTWORK_READY] '
              'asset=$asset width=$width height=$height bytes=${bytes.length}',
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
