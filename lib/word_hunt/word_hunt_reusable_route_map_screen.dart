import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';

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

  /// Bonus bölüm 8 ana ilerleme kapısı değildir. Bu nedenle yol 7'den hem 8'e
  /// hem 9'a ayrılır; final 10 ise yalnız 9 üzerinden devam eder.
  static const List<(int, int)> connections = <(int, int)>[
    (1, 2),
    (2, 3),
    (3, 4),
    (4, 5),
    (5, 6),
    (6, 7),
    (7, 8),
    (7, 9),
    (9, 10),
  ];

  static List<Offset> pointsFor(Size size) {
    return normalizedStops
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList(growable: false);
  }
}

/// Görsel tema yalnız boya ve metin renklerini taşır; geometri taşıyamaz.
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
  });

  final String id;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color pathColor;
  final Color lockedPathColor;
  final Color nodeColor;
  final Color lockedNodeColor;
  final Color accentColor;
  final Color textColor;

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
  );
}

/// 20 rota için ortak 10-bölümlük harita iskeleti.
///
/// Bu ekran henüz production kataloğuna bağlı değildir. İlk kabul aşamasında
/// yalnız yol, 1-10 düğümleri ve başlangıç/bitiş işaretlerini gösterir.
class WordHuntReusableRouteMapScreen extends StatelessWidget {
  const WordHuntReusableRouteMapScreen({
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
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Positioned.fill(
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
    required this.theme,
    this.onTap,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final WordHuntRouteMapTheme theme;
  final VoidCallback? onTap;

  String? get _endpointLabel {
    if (level.index == 1) return 'BAŞLANGIÇ';
    if (level.index == 10) return 'BİTİŞ';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final endpointLabel = _endpointLabel;
    final fillColor = unlocked ? theme.nodeColor : theme.lockedNodeColor;
    final borderColor = unlocked ? theme.accentColor : theme.lockedPathColor;

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label: 'Bölüm ${level.index}${unlocked ? ', açık' : ', kilitli'}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: WordHuntReusableRouteMapScreen._nodeDiameter,
              height: WordHuntReusableRouteMapScreen._nodeDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fillColor,
                border: Border.all(color: borderColor, width: 3),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.22),
                    blurRadius: 8,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '${level.index}',
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
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
    final lockedPaint = Paint()
      ..color = theme.lockedPathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final unlockedPaint = Paint()
      ..color = theme.pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
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
      canvas.drawPath(
        path,
        unlocked[toIndex] ? unlockedPaint : lockedPaint,
      );
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
