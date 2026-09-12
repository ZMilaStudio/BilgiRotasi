import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';

/// Raster sahne kullanan bütün Kelime Avı rotaları için ortak premium harita
/// katmanı.
///
/// Bu widget rota kimliği veya rota-özel koordinat taşımaz. 1-10 merkezleri
/// doğrudan [WordHuntRouteMapGeometry] üzerinden gelir; hitbox sözleşmesi de
/// reusable haritanın 86x82 kutusuyla aynıdır. Artwork yalnız arka plandır;
/// progression, kilit ve dokunma durumları canlı kalır.
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

  static const double nodeDiameter = 54;
  static const double nodeBoxWidth = 86;
  static const double nodeBoxHeight = 82;

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
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 7, 9, 5),
              child: _ArtworkRouteHeader(
                title: route.title,
                stars: stars,
                maximumStars: route.maximumStars,
                theme: theme,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 3),
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

                    return DecoratedBox(
                      key: Key('word_hunt_reusable_surface_${theme.id}'),
                      decoration: const BoxDecoration(color: Colors.transparent),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          key: const Key('word_hunt_reusable_layer_stack'),
                          fit: StackFit.expand,
                          children: <Widget>[
                            const Positioned.fill(
                              key: Key('word_hunt_reusable_atmosphere_layer'),
                              child: IgnorePointer(child: SizedBox.expand()),
                            ),
                            Positioned.fill(
                              key: const Key('word_hunt_reusable_path_layer'),
                              child: IgnorePointer(
                                child: CustomPaint(
                                  key: const Key(
                                    'word_hunt_reusable_route_path',
                                  ),
                                  painter: _ArtworkTrailPainter(
                                    points: points,
                                    unlocked: unlocked,
                                    theme: theme,
                                  ),
                                ),
                              ),
                            ),
                            for (var index = 0; index < 10; index++)
                              _positionNode(
                                point: points[index],
                                level: route.levels[index],
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
                        ),
                      ),
                    );
                  },
                ),
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
    required bool unlocked,
    required bool completed,
    required bool current,
    required Size mapSize,
  }) {
    final left = (point.dx - nodeBoxWidth / 2)
        .clamp(0.0, math.max(0.0, mapSize.width - nodeBoxWidth))
        .toDouble();
    final top = (point.dy - nodeDiameter / 2)
        .clamp(0.0, math.max(0.0, mapSize.height - nodeBoxHeight))
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: nodeBoxWidth,
      height: nodeBoxHeight,
      child: _ArtworkRouteNode(
        key: Key('word_hunt_reusable_level_${level.index}'),
        level: level,
        unlocked: unlocked,
        completed: completed,
        current: current,
        theme: theme,
        onTap: unlocked && onLevelTap != null
            ? () => onLevelTap!(level.index)
            : null,
      ),
    );
  }
}

class _ArtworkRouteHeader extends StatelessWidget {
  const _ArtworkRouteHeader({
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
    return Row(
      children: <Widget>[
        _ArtworkWoodButton(
          onTap: Navigator.of(context).canPop()
              ? () => Navigator.of(context).pop()
              : null,
          theme: theme,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.textColor,
            size: 19,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 50,
            child: CustomPaint(
              painter: _WoodPlaquePainter(theme: theme),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    title,
                    key: const Key('word_hunt_reusable_route_title'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.15,
                      shadows: <Shadow>[
                        Shadow(
                          color: theme.nodeShadowColor.withValues(alpha: 0.88),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          height: 44,
          child: CustomPaint(
            painter: _WoodPlaquePainter(theme: theme, compact: true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.star_rounded,
                    color: theme.accentColor,
                    size: 19,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$stars / $maximumStars',
                    key: const Key('word_hunt_reusable_route_stars'),
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      shadows: <Shadow>[
                        Shadow(
                          color: theme.nodeShadowColor.withValues(alpha: 0.84),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArtworkWoodButton extends StatelessWidget {
  const _ArtworkWoodButton({
    required this.onTap,
    required this.theme,
    required this.child,
  });

  final VoidCallback? onTap;
  final WordHuntRouteMapTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 43,
          height: 43,
          child: CustomPaint(
            painter: _WoodDiscPainter(theme: theme),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _WoodPlaquePainter extends CustomPainter {
  const _WoodPlaquePainter({required this.theme, this.compact = false});

  final WordHuntRouteMapTheme theme;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 3);
    final radius = Radius.circular(compact ? 14 : 16);
    final plaque = RRect.fromRectAndRadius(rect, radius);

    final shadow = Paint()
      ..color = theme.nodeShadowColor.withValues(alpha: 0.48)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(plaque.shift(const Offset(0, 3)), shadow);

    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color.alphaBlend(
            theme.textColor.withValues(alpha: 0.10),
            theme.nodeColor,
          ),
          theme.nodeColor,
          Color.alphaBlend(
            Colors.black.withValues(alpha: 0.30),
            theme.nodeColor,
          ),
        ],
        stops: const <double>[0, 0.48, 1],
      ).createShader(rect);
    canvas.drawRRect(plaque, base);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = theme.accentColor.withValues(alpha: 0.46);
    canvas.drawRRect(plaque.deflate(0.8), edge);

    final innerEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = theme.textColor.withValues(alpha: 0.14);
    canvas.drawRRect(plaque.deflate(4), innerEdge);

    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = theme.nodeShadowColor.withValues(alpha: 0.20);
    for (var row = 0; row < 3; row++) {
      final y = size.height * (0.28 + row * 0.22);
      final path = Path()
        ..moveTo(size.width * 0.08, y)
        ..quadraticBezierTo(
          size.width * (0.32 + row * 0.04),
          y - 1.8,
          size.width * 0.56,
          y + 0.8,
        )
        ..quadraticBezierTo(
          size.width * 0.76,
          y + 2.0,
          size.width * 0.92,
          y - 0.7,
        );
      canvas.drawPath(path, grain);
    }

    final nail = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.055, size.height * 0.50), 1.8, nail);
    canvas.drawCircle(Offset(size.width * 0.945, size.height * 0.50), 1.8, nail);
  }

  @override
  bool shouldRepaint(covariant _WoodPlaquePainter oldDelegate) {
    return oldDelegate.theme != theme || oldDelegate.compact != compact;
  }
}

class _WoodDiscPainter extends CustomPainter {
  const _WoodDiscPainter({required this.theme});

  final WordHuntRouteMapTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 1.5;

    final shadow = Paint()
      ..color = theme.nodeShadowColor.withValues(alpha: 0.50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center + const Offset(0, 2.5), radius, shadow);

    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.28, -0.32),
        colors: <Color>[
          Color.alphaBlend(
            theme.textColor.withValues(alpha: 0.12),
            theme.nodeColor,
          ),
          theme.nodeColor,
          Color.alphaBlend(
            Colors.black.withValues(alpha: 0.28),
            theme.nodeColor,
          ),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, fill);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = theme.accentColor.withValues(alpha: 0.48);
    canvas.drawCircle(center, radius - 0.8, edge);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = theme.textColor.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius * 0.68, ring);
  }

  @override
  bool shouldRepaint(covariant _WoodDiscPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}

class _ArtworkRouteNode extends StatelessWidget {
  const _ArtworkRouteNode({
    super.key,
    required this.level,
    required this.unlocked,
    required this.completed,
    required this.current,
    required this.theme,
    this.onTap,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final bool completed;
  final bool current;
  final WordHuntRouteMapTheme theme;
  final VoidCallback? onTap;

  String get _visualState {
    if (completed) return 'completed';
    if (current) return 'current';
    if (unlocked) return 'open';
    return 'locked';
  }

  String? get _endpointLabel {
    if (level.index == 1) return 'BAŞLANGIÇ';
    if (level.index == 10) return 'BİTİŞ';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final endpointLabel = _endpointLabel;

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label:
          'Bölüm ${level.index}${unlocked ? ', açık' : ', kilitli'}'
          '${completed ? ', tamamlandı' : current ? ', sıradaki' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              key: Key(
                'word_hunt_reusable_node_${level.index}_$_visualState',
              ),
              width: 64,
              height: 49,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ArtworkNodePainter(
                        fillColor:
                            unlocked ? theme.nodeColor : theme.lockedNodeColor,
                        edgeColor: current
                            ? theme.accentColor
                            : completed || unlocked
                            ? theme.pathColor
                            : theme.lockedPathColor,
                        shadowColor: theme.nodeShadowColor,
                        textColor: theme.textColor,
                        accentColor: theme.accentColor,
                        locked: !unlocked,
                        current: current,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, -0.13),
                    child: Text(
                      '${level.index}',
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: current ? 19 : 18,
                        fontWeight: FontWeight.w900,
                        shadows: <Shadow>[
                          Shadow(
                            color: theme.nodeShadowColor.withValues(alpha: 0.96),
                            blurRadius: 3,
                            offset: const Offset(0, 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!unlocked)
                    Positioned(
                      right: 8,
                      bottom: 7,
                      child: Icon(
                        Icons.lock_rounded,
                        size: 10,
                        color: theme.textColor.withValues(alpha: 0.66),
                        shadows: <Shadow>[
                          Shadow(
                            color: theme.nodeShadowColor.withValues(alpha: 0.94),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (completed)
              SizedBox(
                height: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    3,
                    (_) => Icon(
                      Icons.star_rounded,
                      size: 10,
                      color: theme.accentColor,
                      shadows: <Shadow>[
                        Shadow(
                          color: theme.nodeShadowColor.withValues(alpha: 0.78),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (endpointLabel != null)
              Padding(
                padding: EdgeInsets.only(top: completed ? 0 : 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    endpointLabel,
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.94),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.38,
                      shadows: <Shadow>[
                        Shadow(
                          color: theme.nodeShadowColor.withValues(alpha: 0.98),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkNodePainter extends CustomPainter {
  const _ArtworkNodePainter({
    required this.fillColor,
    required this.edgeColor,
    required this.shadowColor,
    required this.textColor,
    required this.accentColor,
    required this.locked,
    required this.current,
  });

  final Color fillColor;
  final Color edgeColor;
  final Color shadowColor;
  final Color textColor;
  final Color accentColor;
  final bool locked;
  final bool current;

  @override
  void paint(Canvas canvas, Size size) {
    if (current) {
      final glow = Paint()
        ..color = accentColor.withValues(alpha: 0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.46),
          width: size.width * 0.94,
          height: size.height * 0.76,
        ),
        glow,
      );
    }

    final groundShadow = Paint()
      ..color = shadowColor.withValues(alpha: locked ? 0.34 : 0.52)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2 + 1, size.height * 0.78),
        width: size.width * 0.72,
        height: size.height * 0.20,
      ),
      groundShadow,
    );

    if (locked) {
      _paintRock(canvas, size);
    } else {
      _paintStump(canvas, size);
    }
  }

  void _paintStump(Canvas canvas, Size size) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.40,
        size.width * 0.68,
        size.height * 0.40,
      ),
      Radius.circular(size.height * 0.12),
    );
    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          fillColor,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.34), fillColor),
        ],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, body);

    final bark = Paint()
      ..color = shadowColor.withValues(alpha: 0.36)
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    for (final x in <double>[0.29, 0.43, 0.58, 0.70]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.55),
        Offset(size.width * (x - 0.015), size.height * 0.72),
        bark,
      );
    }

    final topRect = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.07,
      size.width * 0.90,
      size.height * 0.67,
    );
    final top = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.26, -0.34),
        radius: 0.92,
        colors: <Color>[
          Color.alphaBlend(textColor.withValues(alpha: 0.17), fillColor),
          fillColor,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.32), fillColor),
        ],
        stops: const <double>[0, 0.58, 1],
      ).createShader(topRect);
    canvas.drawOval(topRect, top);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = current ? 3.5 : 2.3
      ..color = edgeColor.withValues(alpha: current ? 0.96 : 0.78);
    canvas.drawOval(topRect.deflate(1.0), edge);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = textColor.withValues(alpha: 0.13);
    canvas.drawOval(topRect.deflate(size.width * 0.10), ring);
    canvas.drawOval(topRect.deflate(size.width * 0.18), ring);
  }

  void _paintRock(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(
      size.width * 0.07,
      size.height * 0.10,
      size.width * 0.86,
      size.height * 0.70,
    );
    final rock = Path()
      ..moveTo(bounds.left + bounds.width * 0.12, bounds.top + bounds.height * 0.55)
      ..quadraticBezierTo(
        bounds.left + bounds.width * 0.05,
        bounds.top + bounds.height * 0.28,
        bounds.left + bounds.width * 0.27,
        bounds.top + bounds.height * 0.10,
      )
      ..quadraticBezierTo(
        bounds.left + bounds.width * 0.48,
        bounds.top - bounds.height * 0.02,
        bounds.left + bounds.width * 0.68,
        bounds.top + bounds.height * 0.10,
      )
      ..quadraticBezierTo(
        bounds.right + bounds.width * 0.03,
        bounds.top + bounds.height * 0.30,
        bounds.right - bounds.width * 0.08,
        bounds.top + bounds.height * 0.59,
      )
      ..quadraticBezierTo(
        bounds.right - bounds.width * 0.13,
        bounds.bottom - bounds.height * 0.03,
        bounds.left + bounds.width * 0.60,
        bounds.bottom,
      )
      ..quadraticBezierTo(
        bounds.left + bounds.width * 0.29,
        bounds.bottom + bounds.height * 0.02,
        bounds.left + bounds.width * 0.12,
        bounds.top + bounds.height * 0.55,
      )
      ..close();

    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.32, -0.40),
        radius: 1.0,
        colors: <Color>[
          Color.alphaBlend(textColor.withValues(alpha: 0.10), fillColor),
          fillColor,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.32), fillColor),
        ],
        stops: const <double>[0, 0.58, 1],
      ).createShader(bounds);
    canvas.drawPath(rock, fill);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.55
      ..strokeJoin = StrokeJoin.round
      ..color = edgeColor.withValues(alpha: 0.54);
    canvas.drawPath(rock, edge);

    final highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..color = textColor.withValues(alpha: 0.10);
    final highlightPath = Path()
      ..moveTo(bounds.left + bounds.width * 0.22, bounds.top + bounds.height * 0.26)
      ..quadraticBezierTo(
        bounds.left + bounds.width * 0.47,
        bounds.top + bounds.height * 0.11,
        bounds.left + bounds.width * 0.70,
        bounds.top + bounds.height * 0.22,
      );
    canvas.drawPath(highlightPath, highlight);

    final crack = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..color = shadowColor.withValues(alpha: 0.42);
    final crackPath = Path()
      ..moveTo(size.width * 0.36, size.height * 0.27)
      ..lineTo(size.width * 0.42, size.height * 0.37)
      ..lineTo(size.width * 0.38, size.height * 0.48)
      ..lineTo(size.width * 0.45, size.height * 0.56);
    canvas.drawPath(crackPath, crack);
  }

  @override
  bool shouldRepaint(covariant _ArtworkNodePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.edgeColor != edgeColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.locked != locked ||
        oldDelegate.current != current;
  }
}

class _ArtworkTrailPainter extends CustomPainter {
  const _ArtworkTrailPainter({
    required this.points,
    required this.unlocked,
    required this.theme,
  });

  final List<Offset> points;
  final List<bool> unlocked;
  final WordHuntRouteMapTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    for (var index = 0;
        index < WordHuntRouteMapGeometry.connections.length;
        index++) {
      final connection = WordHuntRouteMapGeometry.connections[index];
      final fromIndex = connection.$1 - 1;
      final toIndex = connection.$2 - 1;
      final path = _curve(points[fromIndex], points[toIndex], index);
      final isUnlocked = unlocked[toIndex];

      final softGround = Paint()
        ..color = theme.pathUnderlayColor.withValues(
          alpha: isUnlocked ? 0.30 : 0.20,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = isUnlocked ? 11 : 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawPath(path, softGround);

      final trail = Paint()
        ..color = (isUnlocked ? theme.pathColor : theme.lockedPathColor)
            .withValues(alpha: isUnlocked ? 0.48 : 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isUnlocked ? 4.0 : 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, trail);

      _paintStones(
        canvas,
        path,
        color: isUnlocked ? theme.pathColor : theme.lockedPathColor,
        highlighted: isUnlocked,
      );
    }
  }

  void _paintStones(
    Canvas canvas,
    Path path, {
    required Color color,
    required bool highlighted,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 11.0;
      var stoneIndex = 0;
      while (distance < metric.length - 7) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final wobble = math.sin(stoneIndex * 1.73) * 1.4;
          final normal = Offset(-math.sin(tangent.angle), math.cos(tangent.angle));
          final center = tangent.position + normal * wobble;
          final width = highlighted
              ? 8.5 + (stoneIndex % 3) * 0.8
              : 7.0 + (stoneIndex % 2) * 0.7;
          final height = highlighted ? 4.2 : 3.5;

          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(tangent.angle + math.sin(stoneIndex * 0.9) * 0.05);
          final rect = Rect.fromCenter(
            center: Offset.zero,
            width: width,
            height: height,
          );
          final fill = Paint()
            ..color = color.withValues(alpha: highlighted ? 0.76 : 0.56);
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2.4)),
            fill,
          );
          final shine = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6
            ..color = theme.textColor.withValues(
              alpha: highlighted ? 0.18 : 0.10,
            );
          canvas.drawArc(
            rect.deflate(0.5),
            math.pi * 1.06,
            math.pi * 0.66,
            false,
            shine,
          );
          canvas.restore();
        }
        stoneIndex++;
        distance += highlighted ? 21 : 23;
      }
    }
  }

  Path _curve(Offset start, Offset end, int segmentIndex) {
    final delta = end - start;
    final length = delta.distance;
    if (length == 0) return Path()..moveTo(start.dx, start.dy);

    final midpoint = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
    final normal = Offset(-delta.dy / length, delta.dx / length);
    final direction = segmentIndex.isEven ? 1.0 : -1.0;
    final control = midpoint + normal * (length * 0.08 * direction);

    return Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
  }

  @override
  bool shouldRepaint(covariant _ArtworkTrailPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.unlocked != unlocked ||
        oldDelegate.theme != theme;
  }
}
