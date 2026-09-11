import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_pixel_proof_screen.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_production_assets.dart';
import 'word_hunt_route_stop.dart';
import 'word_hunt_starter_content.dart';

/// Kullanıcının onayladığı Başlangıç Limanı referansının kod tarafındaki
/// bağlayıcı kompozisyon sözleşmesi.
///
/// Bu koordinatlar PR #98'de reddedilen geometriyi taşımaz. 1-10 hiyerarşisi,
/// proje hafızasında kayıtlı resmi referans kurallarından yeniden kurulmuştur.
class WordHuntReferenceRouteLayout {
  WordHuntReferenceRouteLayout._();

  static const Size canonicalSize = Size(1080, 1920);
  static const Offset backgroundSceneOffset = Offset(0, 90);

  static const List<Offset> stops = <Offset>[
    Offset(204.12, 456.96), // 1 - üst sol
    Offset(478.44, 493.44), // 2 - üst orta
    Offset(693.36, 585.60), // 3 - üst sağ
    Offset(867.24, 716.16), // 4 - sağdaki deniz feneri dönüşü
    Offset(361.80, 869.76), // 5 - meydan okuma
    Offset(180.36, 1059.84), // 6 - alt sol
    Offset(496.80, 1119.36), // 7 - merkez-alt
    Offset(721.44, 1182.72), // 8 - bonus, sağ
    Offset(254.88, 1338.24), // 9 - kilitli sol kol
    Offset(528.12, 1530.24), // 10 - rota finali
  ];

  static const Rect topPanel = Rect.fromLTRB(87.48, 134.40, 997.92, 303.36);

  static const List<Offset> bottomControlCenters = <Offset>[
    Offset(136.08, 1764.00),
    Offset(945.00, 1764.00),
  ];

  static const Map<int, Rect> specialPlaques = <int, Rect>{
    5: Rect.fromLTWH(426, 825, 324, 88),
    8: Rect.fromLTWH(785, 1142, 206, 82),
    10: Rect.fromLTWH(613, 1488, 250, 110),
  };

  static const Rect finalCrown = Rect.fromLTWH(451, 1417, 154, 94);

  /// Her segment için bağlayıcı referanstan ölçülen iki cubic Bézier kontrolü.
  static const List<(Offset, Offset)> routeControls = <(Offset, Offset)>[
    (Offset(291.60, 453.12), Offset(394.20, 464.64)),
    (Offset(556.20, 510.72), Offset(631.80, 549.12)),
    (Offset(760.32, 624.00), Offset(820.80, 668.16)),
    (Offset(840.24, 787.20), Offset(561.60, 812.16)),
    (Offset(270.00, 921.60), Offset(205.20, 988.80)),
    (Offset(264.60, 1084.80), Offset(388.80, 1104.00)),
    (Offset(577.80, 1132.80), Offset(658.80, 1157.76)),
    (Offset(648.00, 1238.40), Offset(361.80, 1267.20)),
    (Offset(243.00, 1432.32), Offset(410.40, 1488.00)),
  ];
}

/// Canonical 1080x1920 sahneyi viewport'a tek ölçek ve tek öteleme ile taşır.
/// Background ve bütün Flutter overlay'leri aynı sahnenin çocuğudur.
@immutable
class WordHuntCanonicalSceneTransform {
  const WordHuntCanonicalSceneTransform._({
    required this.viewportSize,
    required this.scale,
    required this.translation,
  });

  factory WordHuntCanonicalSceneTransform.cover(Size viewportSize) {
    final scale = math.max(
      viewportSize.width / WordHuntReferenceRouteLayout.canonicalSize.width,
      viewportSize.height / WordHuntReferenceRouteLayout.canonicalSize.height,
    );
    final scaledSize = WordHuntReferenceRouteLayout.canonicalSize * scale;
    return WordHuntCanonicalSceneTransform._(
      viewportSize: viewportSize,
      scale: scale,
      translation: Offset(
        (viewportSize.width - scaledSize.width) / 2,
        (viewportSize.height - scaledSize.height) / 2,
      ),
    );
  }

  final Size viewportSize;
  final double scale;
  final Offset translation;

  Rect get sceneRect =>
      translation & (WordHuntReferenceRouteLayout.canonicalSize * scale);

  Offset toViewport(Offset canonicalPoint) =>
      translation + canonicalPoint * scale;
}

enum WordHuntReferenceRouteSegmentStyle {
  normal,
  challenge,
  bonus,
  finalStop,
  locked,
}

/// Onaylı referanstaki rota ışık dilini oyun mantığından ayırır.
/// Kilit/progression yine [WordHuntRouteProgressEngine] tarafından belirlenir.
class WordHuntReferenceRouteVisualContract {
  WordHuntReferenceRouteVisualContract._();

  static WordHuntReferenceRouteSegmentStyle segmentStyleFor({
    required WordHuntLevelType destinationType,
    required bool unlocked,
  }) {
    if (!unlocked && destinationType != WordHuntLevelType.routeFinal) {
      return WordHuntReferenceRouteSegmentStyle.locked;
    }
    return switch (destinationType) {
      WordHuntLevelType.normal => WordHuntReferenceRouteSegmentStyle.normal,
      WordHuntLevelType.challenge =>
        WordHuntReferenceRouteSegmentStyle.challenge,
      WordHuntLevelType.bonus => WordHuntReferenceRouteSegmentStyle.bonus,
      WordHuntLevelType.routeFinal =>
        WordHuntReferenceRouteSegmentStyle.finalStop,
    };
  }
}

/// Başlangıç Limanı'nın production rota bileşeni.
///
/// Varsayılan rota, onaylı MASTER ART sahnesini şeffaf etkileşim hitbox'ları
/// ve yalnız gerekli state override'larıyla gösterir. `sceneAssetPath` yalnız
/// eski katmanlı geometri sözleşmesinin izole regresyon testleri içindir.
class WordHuntReferenceRouteScreen extends StatelessWidget {
  const WordHuntReferenceRouteScreen({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.progress = const WordHuntProgressSnapshot(),
    this.sceneAssetPath,
    this.onBack,
    this.onInfo,
    this.onCompass,
    this.onBook,
    this.onLevelTap,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final String? sceneAssetPath;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final VoidCallback? onCompass;
  final VoidCallback? onBook;
  final ValueChanged<int>? onLevelTap;

  static const WordHuntRouteStopMetrics _metrics =
      WordHuntRouteStopMetrics.referenceBaseline;

  @override
  Widget build(BuildContext context) {
    if (route.id == WordHuntStarterContent.baslangicLimani.id &&
        sceneAssetPath == null) {
      final nodeNineOpen = WordHuntRouteProgressEngine.isLevelUnlocked(
        route,
        progress,
        9,
      );
      return WordHuntPixelProofScreen(
        key: const Key('word_hunt_production_master_art_route'),
        route: route,
        progress: progress,
        nodeNineOpenOverride: nodeNineOpen,
        onBack: onBack,
        onInfo: onInfo,
        onCompass: onCompass,
        onBook: onBook,
        onLevelTap: onLevelTap,
      );
    }

    final totalStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final lastUnlocked = _lastUnlockedIndex();

    return Scaffold(
      backgroundColor: const Color(0xFF020611),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final sceneTransform = WordHuntCanonicalSceneTransform.cover(
            viewportSize,
          );
          const routeSize = WordHuntReferenceRouteLayout.canonicalSize;
          final points = WordHuntReferenceRouteLayout.stops
              .take(route.levels.length)
              .toList(growable: false);
          final levelTypes = route.levels
              .take(points.length)
              .map((level) => level.type)
              .toList(growable: false);

          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fromRect(
                  rect: sceneTransform.sceneRect,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox.fromSize(
                      key: const Key('word_hunt_reference_canonical_scene'),
                      size: WordHuntReferenceRouteLayout.canonicalSize,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _ReferenceBackground(assetPath: sceneAssetPath),
                          const _ReferenceLegibilityOverlay(),
                          const Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _ReferenceFramePainter(),
                              ),
                            ),
                          ),
                          _ReferenceTopChrome(
                            title: route.title,
                            stars: totalStars,
                            maximumStars: route.maximumStars,
                            unlockStarsRequired: route.unlockStarsRequired,
                            onBack: onBack,
                            onInfo: onInfo,
                          ),
                          Positioned.fill(
                            key: const Key('word_hunt_reference_route_area'),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _ReferenceRoutePainter(
                                      points: points,
                                      levelTypes: levelTypes,
                                      lastUnlockedIndex: lastUnlocked,
                                    ),
                                  ),
                                ),
                                for (
                                  var index = 0;
                                  index < points.length;
                                  index++
                                )
                                  _positionStop(
                                    point: points[index],
                                    level: route.levels[index],
                                    stars: progress.starsFor(
                                      route.levels[index].id,
                                    ),
                                    unlocked:
                                        WordHuntRouteProgressEngine.isLevelUnlocked(
                                          route,
                                          progress,
                                          index + 1,
                                        ),
                                    routeSize: routeSize,
                                  ),
                              ],
                            ),
                          ),
                          for (var index = 0; index < 2; index++)
                            Positioned(
                              left:
                                  WordHuntReferenceRouteLayout
                                      .bottomControlCenters[index]
                                      .dx -
                                  85,
                              top:
                                  WordHuntReferenceRouteLayout
                                      .bottomControlCenters[index]
                                      .dy -
                                  85,
                              child: _ReferenceBottomControl(
                                key: Key(
                                  index == 0
                                      ? 'word_hunt_reference_compass'
                                      : 'word_hunt_reference_book',
                                ),
                                assetPath:
                                    index == 0
                                        ? WordHuntProductionAssets.compassButton
                                        : WordHuntProductionAssets.bookButton,
                                semanticLabel:
                                    index == 0 ? 'Pusula' : 'Bilgi Kitabı',
                                onTap: index == 0 ? onCompass : onBook,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _lastUnlockedIndex() {
    var last = 0;
    for (var index = 1; index <= route.levels.length; index++) {
      if (WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, index)) {
        last = index;
      }
    }
    return last;
  }

  Widget _positionStop({
    required Offset point,
    required WordHuntLevelDefinition level,
    required int stars,
    required bool unlocked,
    required Size routeSize,
  }) {
    final special = level.type != WordHuntLevelType.normal;
    final width = _metrics.containerWidthFor(level.type);
    final height = _metrics.containerHeightFor(level.type);
    final diameter = _metrics.diameterFor(level.type);

    // Normal duraklarda bütün bileşen merkezi rota noktasına oturur. Özel
    // duraklarda rota noktası dairenin merkezidir; kart her zaman sağa açılır.
    final desiredLeft =
        special ? point.dx - diameter / 2 : point.dx - width / 2;
    final desiredTop =
        point.dy - height / 2 + (_metrics.starGap + _metrics.starSize) / 2;
    final left = desiredLeft.clamp(4.0, routeSize.width - width - 4).toDouble();
    final top = desiredTop.clamp(2.0, routeSize.height - height - 2).toDouble();

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: SizedBox(
        key: Key('word_hunt_reference_level_${level.index}'),
        width: width,
        height: height,
        child: WordHuntRouteStop(
          level: level,
          stars: stars,
          unlocked: unlocked,
          theme: WordHuntRouteStopTheme.harbor,
          metrics: _metrics,
          labelOnLeft: false,
          onTap:
              unlocked && onLevelTap != null
                  ? () => onLevelTap!(level.index)
                  : null,
        ),
      ),
    );
  }
}

class _ReferenceBackground extends StatelessWidget {
  const _ReferenceBackground({required this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path != null && path.isNotEmpty) {
      return ColoredBox(
        color: const Color(0xFF020611),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: WordHuntReferenceRouteLayout.backgroundSceneOffset.dx,
              top: WordHuntReferenceRouteLayout.backgroundSceneOffset.dy,
              width: 1080,
              height: 2340,
              child: Image.asset(
                path,
                key: const Key('word_hunt_reference_background_asset'),
                fit: BoxFit.fill,
                errorBuilder:
                    (context, error, stackTrace) => const _FallbackBackground(),
              ),
            ),
          ],
        ),
      );
    }
    return const _FallbackBackground();
  }
}

class _FallbackBackground extends StatelessWidget {
  const _FallbackBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      key: Key('word_hunt_reference_background_fallback'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF08172B),
            Color(0xFF0D2737),
            Color(0xFF06121F),
          ],
        ),
      ),
    );
  }
}

class _ReferenceLegibilityOverlay extends StatelessWidget {
  const _ReferenceLegibilityOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0x6E050817),
            Color(0x26020916),
            Color(0x08000000),
            Color(0x32020611),
            Color(0x8001060E),
          ],
          stops: <double>[0, 0.16, 0.39, 0.80, 1],
        ),
      ),
    );
  }
}

class _ReferenceTopChrome extends StatelessWidget {
  const _ReferenceTopChrome({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.unlockStarsRequired,
    this.onBack,
    this.onInfo,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final int unlockStarsRequired;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final panel = WordHuntReferenceRouteLayout.topPanel;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: 45,
            right: 45,
            top: 32,
            child: SizedBox(
              height: 78,
              child: Row(
                children: [
                  _ReferenceRoundButton(
                    key: const Key('word_hunt_reference_back'),
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: 'Geri',
                    onTap: onBack,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          const Expanded(
                            child: _ReferenceTitleFlourish(reverse: false),
                          ),
                          const SizedBox(width: 18),
                          const Text(
                            'KELİME AVI',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFF4E7FF),
                              fontFamily: 'serif',
                              fontSize: 45,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.8,
                              shadows: <Shadow>[
                                Shadow(
                                  color: Color(0xD99C4DFF),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          const Expanded(
                            child: _ReferenceTitleFlourish(reverse: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _ReferenceRoundButton(
                    key: const Key('word_hunt_reference_info'),
                    icon: Icons.info_outline_rounded,
                    semanticLabel: 'Bilgi',
                    onTap: onInfo,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            key: const Key('word_hunt_reference_top_panel'),
            left: panel.left,
            top: panel.top,
            width: panel.width,
            height: panel.height,
            child: CustomPaint(
              foregroundPainter: const _ReferencePanelOrnamentPainter(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(42, 14, 42, 10),
                decoration: BoxDecoration(
                  color: const Color(0xE308101B),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xD0B68B45),
                    width: 2.6,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x88000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(color: Color(0x2D8B5CF6), blurRadius: 26),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.toUpperCase().replaceFirst('LIMANI', 'LİMANI'),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFF7E7),
                        fontFamily: 'serif',
                        fontSize: 49,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        shadows: <Shadow>[
                          Shadow(color: Color(0x99000000), blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC94A),
                          size: 38,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$stars / $maximumStars',
                          style: const TextStyle(
                            color: Color(0xFFFFE9B0),
                            fontFamily: 'serif',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Kapı: $unlockStarsRequired',
                          style: const TextStyle(
                            color: Color(0xFFF3E6C9),
                            fontFamily: 'serif',
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC94A),
                          size: 36,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferencePanelOrnamentPainter extends CustomPainter {
  const _ReferencePanelOrnamentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = const Color(0xC6D1A45B);
    const inset = 10.0;
    const arm = 28.0;
    for (final corner in <(Offset, double, double)>[
      (const Offset(inset, inset), 1, 1),
      (Offset(size.width - inset, inset), -1, 1),
      (Offset(inset, size.height - inset), 1, -1),
      (Offset(size.width - inset, size.height - inset), -1, -1),
    ]) {
      final origin = corner.$1;
      canvas.drawLine(origin, origin + Offset(corner.$2 * arm, 0), paint);
      canvas.drawLine(origin, origin + Offset(0, corner.$3 * arm), paint);
      final diamond =
          Path()
            ..moveTo(origin.dx, origin.dy - 5)
            ..lineTo(origin.dx + 5, origin.dy)
            ..lineTo(origin.dx, origin.dy + 5)
            ..lineTo(origin.dx - 5, origin.dy)
            ..close();
      canvas.drawPath(diamond, paint);
    }
    final midpoint = Offset(size.width / 2, inset);
    final diamond =
        Path()
          ..moveTo(midpoint.dx, midpoint.dy - 6)
          ..lineTo(midpoint.dx + 7, midpoint.dy)
          ..lineTo(midpoint.dx, midpoint.dy + 6)
          ..lineTo(midpoint.dx - 7, midpoint.dy)
          ..close();
    canvas.drawPath(diamond, paint);
  }

  @override
  bool shouldRepaint(covariant _ReferencePanelOrnamentPainter oldDelegate) =>
      false;
}

class _ReferenceTitleFlourish extends StatelessWidget {
  const _ReferenceTitleFlourish({required this.reverse});

  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: reverse ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: reverse ? Alignment.centerRight : Alignment.centerLeft,
                end: reverse ? Alignment.centerLeft : Alignment.centerRight,
                colors: const <Color>[Color(0x007B3BB5), Color(0xA88A4FC5)],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xB9A764DD), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReferenceRoundButton extends StatelessWidget {
  const _ReferenceRoundButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x660A111D),
              border: Border.all(color: const Color(0xBBA57A3D)),
            ),
            child: Icon(icon, color: const Color(0xFFE8C678), size: 44),
          ),
        ),
      ),
    );
  }
}

class _ReferenceBottomControl extends StatelessWidget {
  const _ReferenceBottomControl({
    super.key,
    required this.assetPath,
    required this.semanticLabel,
    this.onTap,
  });

  final String assetPath;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 170,
            child: Image.asset(
              assetPath,
              key: Key(
                semanticLabel == 'Pusula'
                    ? 'word_hunt_reference_compass_asset'
                    : 'word_hunt_reference_book_asset',
              ),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferenceFramePainter extends CustomPainter {
  const _ReferenceFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(9, 9, size.width - 18, size.height - 18),
      const Radius.circular(54),
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
      const Radius.circular(44),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0x7AB78A3E),
    );
    canvas.drawRRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0x554A3A25),
    );
  }

  @override
  bool shouldRepaint(covariant _ReferenceFramePainter oldDelegate) => false;
}

class _ReferenceRoutePainter extends CustomPainter {
  const _ReferenceRoutePainter({
    required this.points,
    required this.levelTypes,
    required this.lastUnlockedIndex,
  });

  final List<Offset> points;
  final List<WordHuntLevelType> levelTypes;
  final int lastUnlockedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || levelTypes.length < points.length) return;

    final shadow =
        Paint()
          ..color = const Color(0xA8000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    for (var index = 0; index < points.length - 1; index++) {
      final from = points[index];
      final to = points[index + 1];
      final controls = WordHuntReferenceRouteLayout.routeControls[index];
      final control1 = controls.$1;
      final control2 = controls.$2;
      final path =
          Path()
            ..moveTo(from.dx, from.dy)
            ..cubicTo(
              control1.dx,
              control1.dy,
              control2.dx,
              control2.dy,
              to.dx,
              to.dy,
            );

      canvas.drawPath(path, shadow);

      final unlockedSegment = index + 2 <= lastUnlockedIndex;
      final style = WordHuntReferenceRouteVisualContract.segmentStyleFor(
        destinationType: levelTypes[index + 1],
        unlocked: unlockedSegment,
      );

      if (style == WordHuntReferenceRouteSegmentStyle.locked) {
        final dormantGlow =
            Paint()
              ..color = const Color(0x305B7589)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8.0
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        final dormant =
            Paint()
              ..color = const Color(0xB59AA5B2)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.2
              ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, dormantGlow);
        _drawDashedPath(canvas, path, dormant);
        continue;
      }

      final (coreColor, glowColor) = switch (style) {
        WordHuntReferenceRouteSegmentStyle.normal => (
          const Color(0xFF76F7FF),
          const Color(0x7047EAF1),
        ),
        WordHuntReferenceRouteSegmentStyle.challenge => (
          const Color(0xFFFFC45F),
          const Color(0x70F39B38),
        ),
        WordHuntReferenceRouteSegmentStyle.bonus => (
          const Color(0xFFC06BFF),
          const Color(0x70A94AF3),
        ),
        WordHuntReferenceRouteSegmentStyle.finalStop => (
          const Color(0xFFFFD76B),
          const Color(0x70F6B83D),
        ),
        WordHuntReferenceRouteSegmentStyle.locked =>
          throw StateError(
            'Locked segment is handled before active palette selection.',
          ),
      };

      final glow =
          Paint()
            ..color = glowColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9.0
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.8);
      final core =
          Paint()
            ..color = coreColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;

      if (style == WordHuntReferenceRouteSegmentStyle.finalStop) {
        _drawFinalGradient(canvas, path, glow, core);
      } else {
        canvas.drawPath(path, glow);
        canvas.drawPath(path, core);
      }
    }
  }

  void _drawFinalGradient(Canvas canvas, Path path, Paint glow, Paint core) {
    for (final metric in path.computeMetrics()) {
      final split = metric.length * 0.52;
      final purple = metric.extractPath(0, split);
      final gold = metric.extractPath(split, metric.length);
      canvas.drawPath(purple, glow..color = const Color(0x70A94AF3));
      canvas.drawPath(purple, core..color = const Color(0xFFC06BFF));
      canvas.drawPath(gold, glow..color = const Color(0x70F6B83D));
      canvas.drawPath(gold, core..color = const Color(0xFFFFD76B));
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 16.0;
    const gapLength = 12.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end =
            (distance + dashLength).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReferenceRoutePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.levelTypes != levelTypes ||
        oldDelegate.lastUnlockedIndex != lastUnlockedIndex;
  }
}
