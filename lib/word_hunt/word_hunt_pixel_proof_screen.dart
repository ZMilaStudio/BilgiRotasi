import 'package:flutter/material.dart';

import 'word_hunt_master_art_progress_overlay.dart';
import 'word_hunt_production_assets.dart';
import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_segment_host.dart';
import 'word_hunt_starter_content.dart';

/// Issue #109 piksel kanıtına ait tek görünür raster kaynak.
///
/// Dosya, kullanıcının bağlayıcı 720x1280 Photo 1.jpg dosyasının byte düzeyinde
/// kopyasıdır. Onay sonrasında gerçek Başlangıç Limanı production rota
/// ekranının da görünür tabanı olmuştur.
abstract final class WordHuntPixelProofAssets {
  static const String masterArt =
      'assets/word_hunt/baslangic_limani_master_art_visual_proof.jpg';
  static const String nodeNineOpen = WordHuntProductionAssets.nodeNormal;
}

/// Flattened MASTER ART'ın üzerindeki görünmez etkileşim geometrisi.
/// Koordinatlar 720x1280 kaynak uzayındadır; görünür widget üretmez.
abstract final class WordHuntPixelProofLayout {
  static const Size sourceSize = Size(720, 1280);

  static const List<Offset> levelCenters = <Offset>[
    Offset(136.08, 304.64),
    Offset(318.96, 328.96),
    Offset(462.24, 390.40),
    Offset(578.16, 477.44),
    Offset(241.20, 579.84),
    Offset(120.24, 706.56),
    Offset(331.20, 746.24),
    Offset(480.96, 788.48),
    Offset(169.92, 892.16),
    Offset(352.08, 1020.16),
  ];

  static const List<double> levelHitboxDiameters = <double>[
    64,
    64,
    64,
    64,
    80,
    64,
    64,
    80,
    72,
    104,
  ];

  static const Offset compassCenter = Offset(90.72, 1176);
  static const Offset bookCenter = Offset(630, 1176);
  static const double controlHitboxDiameter = 120;
  static const Offset backCenter = Offset(60, 50);
  static const Offset infoCenter = Offset(660, 50);
  static const double topControlHitboxDiameter = 72;

  /// MASTER ART'taki kilitli node 9'u tamamen örten tek görünür override.
  static const Offset nodeNineCenter = Offset(169.92, 892.16);
  static const double nodeNineVisualDiameter = 72;
}

/// Kabul edilmiş MASTER ART raster sahnesini gerçek progression state'iyle
/// birlikte gösteren Başlangıç Limanı production/pixel-proof sahnesi.
///
/// MASTER ART görünür taban olarak korunur. Değişken oyun durumu yalnız küçük
/// state override'larıyla yansıtılır; etkileşimler görünmez hitbox'lardadır.
class WordHuntPixelProofScreen extends StatelessWidget {
  const WordHuntPixelProofScreen({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.progress = const WordHuntProgressSnapshot(),
    this.nodeNineOpenOverride = true,
    this.onBack,
    this.onInfo,
    this.onLevelTap,
    this.onCompass,
    this.onBook,
    this.segmentIndex = 1,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final bool nodeNineOpenOverride;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final ValueChanged<int>? onLevelTap;
  final VoidCallback? onCompass;
  final VoidCallback? onBook;
  final int segmentIndex;

  @override
  Widget build(BuildContext context) {
    final host = WordHuntRouteSegmentHost.forRoute(
      route: route,
      progress: progress,
      segmentIndex: segmentIndex,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: ClipRect(
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox.fromSize(
              key: const Key('word_hunt_pixel_proof_source_scene'),
              size: WordHuntPixelProofLayout.sourceSize,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    WordHuntPixelProofAssets.masterArt,
                    key: const Key('word_hunt_pixel_proof_master_art'),
                    width: WordHuntPixelProofLayout.sourceSize.width,
                    height: WordHuntPixelProofLayout.sourceSize.height,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                  WordHuntMasterArtProgressOverlay(
                    route: route,
                    progress: progress,
                  ),
                  if (nodeNineOpenOverride) const _NodeNineOpenOverride(),
                  for (
                    var index = 0;
                    index < host.nodes.length &&
                        index < WordHuntPixelProofLayout.levelCenters.length;
                    index++
                  )
                    _TransparentHitbox(
                      key: Key('word_hunt_pixel_proof_level_${index + 1}'),
                      center: WordHuntPixelProofLayout.levelCenters[index],
                      diameter:
                          WordHuntPixelProofLayout.levelHitboxDiameters[index],
                      onTap:
                          host.nodes[index].unlocked && onLevelTap != null
                              ? () => onLevelTap!(
                                host.nodes[index].absoluteLevelIndex,
                              )
                              : null,
                    ),
                  _TransparentHitbox(
                    key: const Key('word_hunt_pixel_proof_compass'),
                    center: WordHuntPixelProofLayout.compassCenter,
                    diameter: WordHuntPixelProofLayout.controlHitboxDiameter,
                    onTap: onCompass,
                  ),
                  _TransparentHitbox(
                    key: const Key('word_hunt_pixel_proof_book'),
                    center: WordHuntPixelProofLayout.bookCenter,
                    diameter: WordHuntPixelProofLayout.controlHitboxDiameter,
                    onTap: onBook,
                  ),
                  _TransparentHitbox(
                    key: const Key('word_hunt_pixel_proof_back'),
                    center: WordHuntPixelProofLayout.backCenter,
                    diameter: WordHuntPixelProofLayout.topControlHitboxDiameter,
                    onTap: onBack,
                  ),
                  _TransparentHitbox(
                    key: const Key('word_hunt_pixel_proof_info'),
                    center: WordHuntPixelProofLayout.infoCenter,
                    diameter: WordHuntPixelProofLayout.topControlHitboxDiameter,
                    onTap: onInfo,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NodeNineOpenOverride extends StatelessWidget {
  const _NodeNineOpenOverride();

  @override
  Widget build(BuildContext context) {
    const diameter = WordHuntPixelProofLayout.nodeNineVisualDiameter;
    const center = WordHuntPixelProofLayout.nodeNineCenter;
    return Positioned(
      key: const Key('word_hunt_pixel_proof_node_9_override'),
      left: center.dx - diameter / 2,
      top: center.dy - diameter / 2,
      width: diameter,
      height: diameter,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Transform.scale(
              scale: 1.08,
              child: Image.asset(
                WordHuntPixelProofAssets.nodeNineOpen,
                key: const Key('word_hunt_pixel_proof_node_9_asset'),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            const Center(
              child: Text(
                '9',
                key: Key('word_hunt_pixel_proof_node_9_number'),
                style: TextStyle(
                  color: Color(0xFFF6F1E3),
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  shadows: <Shadow>[
                    Shadow(
                      color: Color(0xE6000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransparentHitbox extends StatelessWidget {
  const _TransparentHitbox({
    super.key,
    required this.center,
    required this.diameter,
    this.onTap,
  });

  final Offset center;
  final double diameter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - diameter / 2,
      top: center.dy - diameter / 2,
      width: diameter,
      height: diameter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    );
  }
}
