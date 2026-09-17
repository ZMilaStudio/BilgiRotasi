import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_kristal_runtime_proof.dart';
import 'word_hunt_themed_production_route_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const _KristalRuntimeProofApp());
}

class _KristalRuntimeProofApp extends StatelessWidget {
  const _KristalRuntimeProofApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Kristal Vadisi Runtime Proof',
      home: _KristalRuntimeProbe(
        child: WordHuntThemedProductionRouteScreen(
          route: WordHuntKristalRuntimeProof.route,
          visualTheme: WordHuntKristalRuntimeProof.visualTheme,
          progress: WordHuntKristalRuntimeProof.progress,
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

class _KristalRuntimeProbe extends StatefulWidget {
  const _KristalRuntimeProbe({required this.child});
  final Widget child;

  @override
  State<_KristalRuntimeProbe> createState() => _KristalRuntimeProbeState();
}

class _KristalRuntimeProbeState extends State<_KristalRuntimeProbe> {
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final route = WordHuntKristalRuntimeProof.route;
        const theme = WordHuntKristalRuntimeProof.visualTheme;
        const asset = WordHuntKristalRuntimeProof.artworkAsset;
        if (route.id != 'kristal-vadisi-runtime-proof' ||
            theme.id != 'kristal-vadisi-runtime-proof' ||
            theme.backgroundAsset != asset) {
          throw StateError(
            'Unexpected Kristal proof config: '
            'route=${route.id} theme=${theme.id} asset=${theme.backgroundAsset}',
          );
        }
        debugPrint(
          '[WORD_HUNT_KRISTAL_PROOF_CONFIG_READY] '
          'route=${route.id} theme=${theme.id} asset=$asset',
        );

        final data = await rootBundle.load(asset);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        if (bytes.length != WordHuntKristalRuntimeProof.artworkBytes) {
          throw StateError('Unexpected Kristal artwork bytes: ${bytes.length}');
        }
        final codec = await ui.instantiateImageCodec(bytes);
        try {
          final frame = await codec.getNextFrame();
          try {
            if (frame.image.width != WordHuntKristalRuntimeProof.artworkWidth ||
                frame.image.height != WordHuntKristalRuntimeProof.artworkHeight) {
              throw StateError(
                'Unexpected Kristal artwork size: '
                '${frame.image.width}x${frame.image.height}',
              );
            }
            debugPrint(
              '[WORD_HUNT_KRISTAL_PROOF_ARTWORK_READY] '
              'asset=$asset width=${frame.image.width} '
              'height=${frame.image.height} bytes=${bytes.length}',
            );
          } finally {
            frame.image.dispose();
          }
        } finally {
          codec.dispose();
        }

        debugPrint(
          '[WORD_HUNT_KRISTAL_PROOF_STATE_READY] '
          'completed=1,2,3,4 current=5 locked=6,7,8,9,10',
        );
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        debugPrint('[WORD_HUNT_KRISTAL_PROOF_FRAME_READY]');
      } catch (error, stackTrace) {
        debugPrint('[WORD_HUNT_KRISTAL_PROOF_ERROR] error=$error');
        debugPrintStack(
          label: '[WORD_HUNT_KRISTAL_PROOF_ERROR_STACK]',
          stackTrace: stackTrace,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
