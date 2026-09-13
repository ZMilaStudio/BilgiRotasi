import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_stop.dart';

/// Raster artwork kullanan Kelime Avı rotaları için production harita katmanı.
///
/// Sahnenin resmini tekrar çizmeye çalışmaz. Arka plan artwork'ünün üstünde
/// onaylı Başlangıç Limanı component ailesinden küçültülmüş rota durakları,
/// hafif bir ışık rotası ve gerçek progression hitbox'ları bulunur. Böylece
/// Orman Yolu başka bir oyundan gelmiş gibi durmaz; Kelime Avı'nın aynı görsel
/// dilini korurken ormanın kendi artwork'ü sahnenin ana karakteri olmaya devam
/// eder.
class WordHuntArtworkRouteMapScreen extends StatelessWidget {
  const WordHuntArtworkRouteMapScreen({
    super.key,
    required this.route,
    required this.theme,
    this.progress = const WordHuntProgressSnapshot(),
    this.onLevelTap,
  });

  final WordHuntRouteDefinition route;
  final WordHuntRouteMapTheme theme;
  final WordHuntProgressSnapshot progress;
  final ValueChanged<int>? onLevelTap;

  static const double _nodeHitboxWidth = 82;
  static const double _nodeHitboxHeight = 78;
  static const WordHuntRouteStopMetrics _referenceMetrics =
      WordHuntRouteStopMetrics.referenceBaseline;

  @override
  Widget build(BuildContext context) {
    assert(
      route.levels.length == 10,
      'Artwork Kelime Avı rota haritası tam 10 bölüm bekler.',
    );

    final stars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final currentLevelIndex = WordHuntRouteProgressEngine.nextPlayableLevelIndex(
      route,
      progress,
    );

    return Scaffold(
      key: const Key('word_hunt_reusable_route_map'),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: _ArtworkHeader(
                title: route.title,
                stars: stars,
                maximumStars: route.maximumStars,
                theme: theme,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final points = WordHuntRouteMapGeometry.pointsFor(size);
                  final unlocked = List<bool>.generate(
                    10,
                    (index) => WordHuntRouteProgressEngine.isLevelUnlocked(
                      route,
                      progress,
                      index + 1,
                    ),
                    growable: false,
                  );

                  return Stack(
                    key: const Key('word_hunt_reusable_layer_stack'),
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      const Positioned.fill(
                        key: Key('word_hunt_reusable_atmosphere_layer'),
                        child: IgnorePointer(child: SizedBox.expand()),
                      ),
                      Positioned.fill(
                        key: const Key('word_hunt_reusable_path_layer'),
                        child: IgnorePointer(
                          child: CustomPaint(
                            key: const Key('word_hunt_reusable_route_path'),
                            painter: _ArtworkRoutePainter(
                              points: points,
                              unlocked: unlocked,
                              levels: route.levels,
                              theme: theme,
                            ),
                          ),
                        ),
                      ),
                      for (var index = 0; index < 10; index++)
                        _positionNode(
                          point: points[index],
                          level: route.levels[index],
                          stars: progress.starsFor(route.levels[index].id),
                          unlocked: unlocked[index],
                          completed:
                              WordHuntRouteProgressEngine.isLevelCompleted(
                                route.levels[index],
                                progress,
                              ),
                          current: unlocked[index] &&
                              index + 1 == currentLevelIndex &&
                              !WordHuntRouteProgressEngine.isLevelCompleted(
                                route.levels[index],
                                progress,
                              ),
                          mapSize: size,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _positionNode({
    required Offset point,
    required WordHuntLevelDefinition level,
    required int stars,
    required bool unlocked,
    required bool completed,
    required bool current,
    required Size mapSize,
  }) {
    final left = (point.dx - _nodeHitboxWidth / 2)
        .clamp(0.0, math.max(0.0, mapSize.width - _nodeHitboxWidth))
        .toDouble();
    final top = (point.dy - _nodeHitboxHeight / 2)
        .clamp(0.0, math.max(0.0, mapSize.height - _nodeHitboxHeight))
        .toDouble();
    final labelOnLeft = point.dx > mapSize.width * 0.52;
    final visual = _ArtworkStopVisual.forLevel(
      level: level,
      unlocked: unlocked,
      labelOnLeft: labelOnLeft,
    );
    final state = completed
        ? 'completed'
        : current
        ? 'current'
        : unlocked
        ? 'open'
        : 'locked';

    return Positioned(
      left: left,
      top: top,
      width: _nodeHitboxWidth,
      height: _nodeHitboxHeight,
      child: Semantics(
        button: unlocked,
        enabled: unlocked,
        label:
            'Bölüm ${level.index}${unlocked ? ', açık' : ', kilitli'}'
            '${completed ? ', tamamlandı' : current ? ', sıradaki' : ''}',
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: visual.left,
              top: visual.top,
              width: visual.width,
              height: visual.height,
              child: ExcludeSemantics(
                child: IgnorePointer(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    clipBehavior: Clip.none,
                    child: SizedBox(
                      width: _referenceMetrics.containerWidthFor(level.type),
                      height: _referenceMetrics.containerHeightFor(level.type),
                      child: WordHuntRouteStop(
                        level: level,
                        stars: stars,
                        unlocked: unlocked,
                        theme: WordHuntRouteStopTheme.harbor,
                        metrics: _referenceMetrics,
                        labelOnLeft: labelOnLeft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                key: Key('word_hunt_reusable_level_${level.index}'),
                behavior: HitTestBehavior.opaque,
                onTap: unlocked && onLevelTap != null
                    ? () => onLevelTap!(level.index)
                    : null,
                child: SizedBox.expand(
                  key: Key('word_hunt_reusable_node_${level.index}_$state'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkStopVisual {
  const _ArtworkStopVisual({
    required this.width,
    required this.height,
    required this.left,
    required this.top,
  });

  final double width;
  final double height;
  final double left;
  final double top;

  static _ArtworkStopVisual forLevel({
    required WordHuntLevelDefinition level,
    required bool unlocked,
    required bool labelOnLeft,
  }) {
    const metrics = WordHuntRouteStopMetrics.referenceBaseline;
    final targetHeight = switch (level.type) {
      WordHuntLevelType.normal => unlocked ? 74.0 : 78.0,
      WordHuntLevelType.challenge => 94.0,
      WordHuntLevelType.bonus => 94.0,
      WordHuntLevelType.routeFinal => 112.0,
    };
    final baselineHeight = metrics.containerHeightFor(level.type);
    final baselineWidth = metrics.containerWidthFor(level.type);
    final scale = targetHeight / baselineHeight;
    final targetWidth = baselineWidth * scale;
    final baselineOrbDiameter =
        level.type == WordHuntLevelType.normal && !unlocked
        ? metrics.lockedNormalDiameter
        : metrics.diameterFor(level.type);
    final orbDiameter = baselineOrbDiameter * scale;
    const hitboxCenter = Offset(
      WordHuntArtworkRouteMapScreen._nodeHitboxWidth / 2,
      WordHuntArtworkRouteMapScreen._nodeHitboxHeight / 2,
    );

    final left = level.type == WordHuntLevelType.normal
        ? hitboxCenter.dx - targetWidth / 2
        : labelOnLeft
        ? hitboxCenter.dx - (targetWidth - orbDiameter / 2)
        : hitboxCenter.dx - orbDiameter / 2;
    final top = hitboxCenter.dy - targetHeight / 2;

    return _ArtworkStopVisual(
      width: targetWidth,
      height: targetHeight,
      left: left,
      top: top,
    );
  }
}

class _ArtworkHeader extends StatelessWidget {
  const _ArtworkHeader({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.theme,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final WordHuntRouteMapTheme theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xD707160D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.72),
              width: 1.25,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x7A000000),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Container(
            height: 62,
            padding: const EdgeInsets.fromLTRB(14, 5, 12, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0x28FFF2C2)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xD91A2E1C), Color(0xE00B160E)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'KELİME AVI',
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.92),
                    fontFamily: 'serif',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                    shadows: const <Shadow>[
                      Shadow(color: Color(0x99000000), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        key: const Key('word_hunt_reusable_route_title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.textColor,
                          fontFamily: 'serif',
                          fontSize: 22,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          shadows: const <Shadow>[
                            Shadow(
                              color: Color(0xCC000000),
                              blurRadius: 5,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      key: const Key('word_hunt_reusable_route_stars'),
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x5A000000),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.accentColor.withValues(alpha: 0.48),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.star_rounded,
                            color: theme.accentColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$stars / $maximumStars',
                            style: TextStyle(
                              color: theme.textColor,
                              fontFamily: 'serif',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtworkRoutePainter extends CustomPainter {
  const _ArtworkRoutePainter({
    required this.points,
    required this.unlocked,
    required this.levels,
    required this.theme,
  });

  final List<Offset> points;
  final List<bool> unlocked;
  final List<WordHuntLevelDefinition> levels;
  final WordHuntRouteMapTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final delta = end - start;
      final distance = delta.distance;
      if (distance <= 0) continue;

      final normal = Offset(-delta.dy / distance, delta.dx / distance);
      final bend = math.min(16.0, distance * 0.10) *
          (index.isEven ? 1.0 : -1.0);
      final control = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      ) + normal * bend;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

      final destinationUnlocked = unlocked[index + 1];
      final segmentActive = unlocked[index] && destinationUnlocked;
      final destinationType = levels[index + 1].type;
      final accent = switch (destinationType) {
        WordHuntLevelType.challenge => const Color(0xFFFFB54D),
        WordHuntLevelType.bonus => const Color(0xFFC785FF),
        WordHuntLevelType.routeFinal => const Color(0xFFFFD567),
        WordHuntLevelType.normal => const Color(0xFFBFF7D7),
      };

      final underlay = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = segmentActive ? 6.0 : 4.8
        ..color = const Color(0x99000000);
      canvas.drawPath(path, underlay);

      if (segmentActive) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5.2
          ..color = accent.withValues(alpha: 0.40)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5.5);
        final core = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.2
          ..color = accent.withValues(alpha: 0.92);
        canvas.drawPath(path, glow);
        canvas.drawPath(path, core);
      } else {
        final locked = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.0
          ..color = accent.withValues(alpha: 0.48);
        _drawDashedPath(canvas, path, locked);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dash = 7.0;
    const gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ArtworkRoutePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.unlocked != unlocked ||
        oldDelegate.levels != levels ||
        oldDelegate.theme != theme;
  }
}
