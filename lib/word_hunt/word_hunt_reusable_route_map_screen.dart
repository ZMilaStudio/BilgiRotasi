import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_map_decoration.dart';

/// Kelime Avı'nın bütün 10-bölümlük rotaları için tek geometri sözleşmesi.
///
/// Bu sınıf bilerek rota kimliği, asset yolu veya tema bilgisi içermez. Yeni bir
/// rota eklemek bu koordinatları değiştirmemeli; rota farkları yalnız tema ve
/// içerik verisinden gelmelidir.
abstract final class WordHuntRouteMapGeometry {
  static const List<Offset> normalizedStops = <Offset>[
    Offset(0.18, 0.10),
    Offset(0.48, 0.17),
    Offset(0.75, 0.27),
    Offset(0.66, 0.38),
    Offset(0.28, 0.47),
    Offset(0.18, 0.60),
    Offset(0.48, 0.67),
    Offset(0.78, 0.74),
    Offset(0.32, 0.82),
    Offset(0.60, 0.91),
  ];

  /// Canonical rota sıralıdır: 7→8→9→10. 8 normal bir bölümdür;
  /// bonus değildir ve 9 yalnız 8 tamamlandıktan sonra açılır.
  static const List<(int, int)> connections = <(int, int)>[
    (1, 2),
    (2, 3),
    (3, 4),
    (4, 5),
    (5, 6),
    (6, 7),
    (7, 8),
    (8, 9),
    (9, 10),
  ];

  static List<Offset> pointsFor(Size size) {
    return normalizedStops
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList(growable: false);
  }
}

/// Görsel tema yalnız boya ve metin token'larını taşır; geometri taşıyamaz.
@immutable
class WordHuntRouteMapTheme {
  const WordHuntRouteMapTheme({
    required this.id,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.pathColor,
    required this.lockedPathColor,
    required this.nodeColor,
    required this.lockedNodeColor,
    required this.accentColor,
    required this.textColor,
    this.sceneGlowColor,
    this.pathUnderlayColor = const Color(0x66000000),
    this.nodeShadowColor = const Color(0x99000000),
    this.sceneDepth = 0.28,
  }) : assert(sceneDepth >= 0 && sceneDepth <= 1);

  final String id;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color pathColor;
  final Color lockedPathColor;
  final Color nodeColor;
  final Color lockedNodeColor;
  final Color accentColor;
  final Color textColor;

  /// Yalnız görsel derinlik token'larıdır; node/path koordinatı taşımazlar.
  final Color? sceneGlowColor;
  final Color pathUnderlayColor;
  final Color nodeShadowColor;
  final double sceneDepth;

  Color get resolvedSceneGlowColor => sceneGlowColor ?? accentColor;

  /// Yalnız mimari kanıt için üç farklı tema. Hiçbiri production route asset'i
  /// veya route-id özel layout davranışı içermez.
  static const WordHuntRouteMapTheme harborProof = WordHuntRouteMapTheme(
    id: 'harbor-proof',
    backgroundColor: Color(0xFF071A2A),
    surfaceColor: Color(0xFF0C2B3C),
    pathColor: Color(0xFF58D5E6),
    lockedPathColor: Color(0xFF36505B),
    nodeColor: Color(0xFF1A9BB2),
    lockedNodeColor: Color(0xFF37474F),
    accentColor: Color(0xFFFFC857),
    textColor: Color(0xFFF5FAFF),
    sceneGlowColor: Color(0xFF58D5E6),
    pathUnderlayColor: Color(0xB3051520),
    nodeShadowColor: Color(0xCC031018),
    sceneDepth: 0.24,
  );

  static const WordHuntRouteMapTheme skyProof = WordHuntRouteMapTheme(
    id: 'sky-proof',
    backgroundColor: Color(0xFF172554),
    surfaceColor: Color(0xFF243B76),
    pathColor: Color(0xFFA5B4FC),
    lockedPathColor: Color(0xFF475569),
    nodeColor: Color(0xFF6366F1),
    lockedNodeColor: Color(0xFF475569),
    accentColor: Color(0xFFFDE68A),
    textColor: Color(0xFFF8FAFC),
    sceneGlowColor: Color(0xFFFDE68A),
    pathUnderlayColor: Color(0xA6111738),
    nodeShadowColor: Color(0xC90D1330),
    sceneDepth: 0.27,
  );

  static const WordHuntRouteMapTheme forestProof = WordHuntRouteMapTheme(
    id: 'forest-proof',
    backgroundColor: Color(0xFF10261B),
    surfaceColor: Color(0xFF173A28),
    pathColor: Color(0xFF86EFAC),
    lockedPathColor: Color(0xFF3F5B49),
    nodeColor: Color(0xFF2F855A),
    lockedNodeColor: Color(0xFF455A4C),
    accentColor: Color(0xFFF6C453),
    textColor: Color(0xFFF4FFF7),
    sceneGlowColor: Color(0xFFF6C453),
    pathUnderlayColor: Color(0xB308160E),
    nodeShadowColor: Color(0xD105120B),
    sceneDepth: 0.34,
  );
}

/// 20 rota için ortak 10-bölümlük harita iskeleti.
///
/// Yol, 1-10 düğümleri ve opsiyonel deterministik tema dekorunu tek ortak
/// renderer'da gösterir. Görsel derinlik de tema verisinden gelir; rota adına
/// göre layout veya painter seçimi yapılmaz.
class WordHuntReusableRouteMapScreen extends StatelessWidget {
  const WordHuntReusableRouteMapScreen({
    super.key,
    required this.route,
    required this.theme,
    this.progress = const WordHuntProgressSnapshot(),
    this.onLevelTap,
    this.decorationSpec,
    this.decorationPalette,
    this.decorationOpacity = 0.42,
  }) : assert(
         (decorationSpec == null) == (decorationPalette == null),
         'Decoration spec ve palette birlikte verilmelidir.',
       );

  final WordHuntRouteDefinition route;
  final WordHuntRouteMapTheme theme;
  final WordHuntProgressSnapshot progress;
  final ValueChanged<int>? onLevelTap;
  final WordHuntRouteDecorationSpec? decorationSpec;
  final WordHuntRouteDecorationPalette? decorationPalette;
  final double decorationOpacity;

  static const double _nodeDiameter = 54;
  static const double _nodeBoxWidth = 86;
  static const double _nodeBoxHeight = 82;

  @override
  Widget build(BuildContext context) {
    assert(
      route.levels.length == 10,
      'Reusable Kelime Avı rota haritası tam 10 bölüm bekler.',
    );
    final stars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final currentLevelIndex = WordHuntRouteProgressEngine.nextPlayableLevelIndex(
      route,
      progress,
    );

    return Scaffold(
      key: const Key('word_hunt_reusable_route_map'),
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      route.title,
                      key: const Key('word_hunt_reusable_route_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$stars / ${route.maximumStars} ★',
                    key: const Key('word_hunt_reusable_route_stars'),
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.accentColor.withValues(alpha: 0.45),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: theme.nodeShadowColor.withValues(alpha: 0.32),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Stack(
                          key: const Key('word_hunt_reusable_layer_stack'),
                          fit: StackFit.expand,
                          children: <Widget>[
                            Positioned.fill(
                              key: const Key(
                                'word_hunt_reusable_atmosphere_layer',
                              ),
                              child: IgnorePointer(
                                child: CustomPaint(
                                  key: const Key(
                                    'word_hunt_reusable_route_atmosphere',
                                  ),
                                  painter: _ReusableRouteAtmospherePainter(
                                    theme: theme,
                                  ),
                                ),
                              ),
                            ),
                            if (decorationSpec != null &&
                                decorationPalette != null)
                              Positioned.fill(
                                key: const Key(
                                  'word_hunt_reusable_decoration_layer',
                                ),
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    key: const Key(
                                      'word_hunt_reusable_route_decoration',
                                    ),
                                    painter: WordHuntRouteDecorationPainter(
                                      spec: decorationSpec!,
                                      reservedPoints: WordHuntRouteMapGeometry
                                          .normalizedStops,
                                      palette: decorationPalette!,
                                      opacity: decorationOpacity,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              key: const Key('word_hunt_reusable_path_layer'),
                              child: CustomPaint(
                                key: const Key(
                                  'word_hunt_reusable_route_path',
                                ),
                                painter: _ReusableRoutePathPainter(
                                  points: points,
                                  unlocked: unlocked,
                                  theme: theme,
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
    final left = (point.dx - _nodeBoxWidth / 2)
        .clamp(0.0, math.max(0.0, mapSize.width - _nodeBoxWidth))
        .toDouble();
    final top = (point.dy - _nodeDiameter / 2)
        .clamp(0.0, math.max(0.0, mapSize.height - _nodeBoxHeight))
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: _nodeBoxWidth,
      height: _nodeBoxHeight,
      child: _ReusableRouteNode(
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

class _ReusableRouteNode extends StatelessWidget {
  const _ReusableRouteNode({
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

  String? get _endpointLabel {
    if (level.index == 1) return 'BAŞLANGIÇ';
    if (level.index == 10) return 'BİTİŞ';
    return null;
  }

  String get _visualState {
    if (completed) return 'completed';
    if (current) return 'current';
    if (unlocked) return 'open';
    return 'locked';
  }

  @override
  Widget build(BuildContext context) {
    final endpointLabel = _endpointLabel;
    final fillColor = unlocked ? theme.nodeColor : theme.lockedNodeColor;
    final borderColor = current
        ? theme.accentColor
        : completed
        ? theme.pathColor
        : unlocked
        ? theme.accentColor
        : theme.lockedPathColor;
    final displayFill = current
        ? Color.alphaBlend(
            theme.accentColor.withValues(alpha: 0.12),
            fillColor,
          )
        : fillColor;

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
            Container(
              key: Key(
                'word_hunt_reusable_node_${level.index}_$_visualState',
              ),
              width: WordHuntReusableRouteMapScreen._nodeDiameter,
              height: WordHuntReusableRouteMapScreen._nodeDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: displayFill,
                border: Border.all(
                  color: borderColor,
                  width: current ? 4 : 3,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: theme.nodeShadowColor.withValues(alpha: 0.68),
                    blurRadius: 11,
                    offset: const Offset(0, 5),
                  ),
                  if (current)
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.52),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Center(
                    child: Text(
                      '${level.index}',
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (completed)
                    Positioned(
                      right: 4,
                      bottom: 3,
                      child: Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: theme.textColor.withValues(alpha: 0.88),
                      ),
                    ),
                ],
              ),
            ),
            if (endpointLabel != null) ...<Widget>[
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  endpointLabel,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.90),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReusableRouteAtmospherePainter extends CustomPainter {
  const _ReusableRouteAtmospherePainter({required this.theme});

  final WordHuntRouteMapTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || theme.sceneDepth == 0) return;

    final rect = Offset.zero & size;
    final longestSide = math.max(size.width, size.height);
    final glowRect = Rect.fromCircle(
      center: Offset(size.width * 0.52, size.height * 0.16),
      radius: longestSide * 0.58,
    );
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          theme.resolvedSceneGlowColor.withValues(
            alpha: theme.sceneDepth * 0.34,
          ),
          Colors.transparent,
        ],
      ).createShader(glowRect);
    canvas.drawRect(rect, glowPaint);

    final depthPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.transparent,
          theme.backgroundColor.withValues(alpha: theme.sceneDepth * 0.54),
        ],
        stops: const <double>[0.42, 1],
      ).createShader(rect);
    canvas.drawRect(rect, depthPaint);

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        radius: 0.92,
        colors: <Color>[
          Colors.transparent,
          theme.backgroundColor.withValues(alpha: theme.sceneDepth * 0.48),
        ],
        stops: const <double>[0.60, 1],
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _ReusableRouteAtmospherePainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}

class _ReusableRoutePathPainter extends CustomPainter {
  const _ReusableRoutePathPainter({
    required this.points,
    required this.unlocked,
    required this.theme,
  });

  final List<Offset> points;
  final List<bool> unlocked;
  final WordHuntRouteMapTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final underlayPaint = Paint()
      ..color = theme.pathUnderlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final lockedPaint = Paint()
      ..color = theme.lockedPathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final unlockedPaint = Paint()
      ..color = theme.pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final unlockedHighlightPaint = Paint()
      ..color = theme.textColor.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var index = 0;
        index < WordHuntRouteMapGeometry.connections.length;
        index++) {
      final connection = WordHuntRouteMapGeometry.connections[index];
      final fromIndex = connection.$1 - 1;
      final toIndex = connection.$2 - 1;
      final path = _automaticCurve(
        points[fromIndex],
        points[toIndex],
        index,
      );
      final isUnlocked = unlocked[toIndex];
      canvas.drawPath(path, underlayPaint);
      canvas.drawPath(path, isUnlocked ? unlockedPaint : lockedPaint);
      if (isUnlocked) {
        canvas.drawPath(path, unlockedHighlightPaint);
      }
    }
  }

  Path _automaticCurve(Offset start, Offset end, int segmentIndex) {
    final delta = end - start;
    final length = delta.distance;
    if (length == 0) {
      return Path()..moveTo(start.dx, start.dy);
    }

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
  bool shouldRepaint(covariant _ReusableRoutePathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.unlocked != unlocked ||
        oldDelegate.theme != theme;
  }
}
