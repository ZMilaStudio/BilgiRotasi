import 'dart:convert';
import 'dart:ui' as ui;

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
      home: const _ReusableProofRuntimeProbe(
        child: WordHuntThemedRouteMapScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: _visualTheme,
          progress: _proofProgress,
        ),
      ),
    );
  }
}

/// Android `reportedDrawn` bazı emulator/runner birleşimlerinde gerçek Flutter
/// frame'i çizilmiş olsa bile false kalabiliyor. Bu probe yalnız izole proof
/// binary'sinde artwork bundle'ının decode edildiğini ve ardından Flutter'ın
/// bir frame daha tamamladığını logcat'e yazar.
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

        // Background widget aynı küçük bundle'ı bağımsız yükler. Bir sonraki
        // frame sınırını beklemek screenshot'ın fallback renk üzerinde
        // yakalanmasını önler.
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
