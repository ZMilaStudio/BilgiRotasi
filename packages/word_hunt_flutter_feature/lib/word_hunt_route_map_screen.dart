import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_starter_content.dart';

/// Kullanıcı tarafından 20 Ağustos 2026'da onaylanan görsel yönü izole olarak
/// uygular. Mevcut Bilgi Rotası ana navigasyonuna veya eski rota ekranına bağlı
/// değildir.
class WordHuntRouteMapPrototypeScreen extends StatelessWidget {
  const WordHuntRouteMapPrototypeScreen({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.progress = const WordHuntProgressSnapshot(),
    this.onLevelTap,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final ValueChanged<int>? onLevelTap;

  static const List<Offset> _normalizedStops = <Offset>[
    Offset(0.16, 0.09),
    Offset(0.45, 0.15),
    Offset(0.70, 0.24),
    Offset(0.78, 0.36),
    Offset(0.29, 0.47),
    Offset(0.18, 0.59),
    Offset(0.45, 0.65),
    Offset(0.66, 0.73),
    Offset(0.22, 0.82),
    Offset(0.48, 0.90),
  ];

  @override
  Widget build(BuildContext context) {
    final routeStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final routeComplete = WordHuntRouteProgressEngine.isRouteComplete(
      route,
      progress,
    );
    final lastUnlocked = _lastUnlockedIndex();

    return Scaffold(
      backgroundColor: const Color(0xFF030716),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleSpacing: 8,
        foregroundColor: const Color(0xFFFFD27A),
        backgroundColor: Colors.transparent,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF080A22), Color(0xFF05091A)],
            ),
          ),
        ),
        title: const _GameTitle(),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: _HeaderInfoGlyph(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
          children: [
            _ApprovedRouteHeader(
              title: route.title,
              stars: routeStars,
              maximumStars: route.maximumStars,
              unlockStarsRequired: route.unlockStarsRequired,
              complete: routeComplete,
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 0.56,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  final points = _pointsFor(size)
                      .take(
                        math.min(route.levels.length, _normalizedStops.length),
                      )
                      .toList(growable: false);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF7A5B2F),
                        width: 1.2,
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                        BoxShadow(color: Color(0x226D28D9), blurRadius: 24),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: Stack(
                        children: [
                          const Positioned.fill(child: _HarborBackdrop()),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _RoutePathPainter(
                                points: points,
                                lastUnlockedIndex: lastUnlocked,
                                route: route,
                              ),
                            ),
                          ),
                          for (var index = 0; index < points.length; index++)
                            _positionedNode(
                              point: points[index],
                              level: route.levels[index],
                              stars: progress.starsFor(route.levels[index].id),
                              unlocked:
                                  WordHuntRouteProgressEngine.isLevelUnlocked(
                                    route,
                                    progress,
                                    index + 1,
                                  ),
                              size: size,
                            ),
                          const Positioned(
                            left: 14,
                            bottom: 14,
                            child: _MapSeal(icon: Icons.explore_rounded),
                          ),
                          const Positioned(
                            right: 14,
                            bottom: 14,
                            child: _MapSeal(icon: Icons.menu_book_rounded),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

  List<Offset> _pointsFor(Size size) {
    return _normalizedStops
        .map((stop) => Offset(stop.dx * size.width, stop.dy * size.height))
        .toList(growable: false);
  }

  Widget _positionedNode({
    required Offset point,
    required WordHuntLevelDefinition level,
    required int stars,
    required bool unlocked,
    required Size size,
  }) {
    final nodeSize = switch (level.type) {
      WordHuntLevelType.normal => 58.0,
      WordHuntLevelType.challenge => 66.0,
      WordHuntLevelType.bonus => 66.0,
      WordHuntLevelType.routeFinal => 76.0,
    };
    final special = level.type != WordHuntLevelType.normal;
    final boxWidth = special ? 174.0 : nodeSize + 8;
    final boxHeight = special ? nodeSize + 28 : nodeSize + 24;
    final left =
        (point.dx - nodeSize / 2)
            .clamp(0.0, math.max(0.0, size.width - boxWidth))
            .toDouble();
    final top =
        (point.dy - nodeSize / 2)
            .clamp(0.0, math.max(0.0, size.height - boxHeight))
            .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: boxWidth,
      height: boxHeight,
      child: _RouteMapNode(
        key: Key('word_hunt_map_level_${level.index}'),
        level: level,
        stars: stars,
        unlocked: unlocked,
        nodeSize: nodeSize,
        onTap:
            unlocked && onLevelTap != null
                ? () => onLevelTap!(level.index)
                : null,
      ),
    );
  }
}

class _GameTitle extends StatelessWidget {
  const _GameTitle();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          _TitleSparkLine(),
          SizedBox(width: 7),
          Text(
            'KELİME AVI',
            style: TextStyle(
              color: Color(0xFFE4B7FF),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              shadows: <Shadow>[
                Shadow(color: Color(0xFFB84CFF), blurRadius: 12),
              ],
            ),
          ),
          SizedBox(width: 7),
          _TitleSparkLine(),
        ],
      ),
    );
  }
}

class _TitleSparkLine extends StatelessWidget {
  const _TitleSparkLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0x006D28D9),
            Color(0xFFB865FF),
            Color(0x006D28D9),
          ],
        ),
      ),
    );
  }
}

class _HeaderInfoGlyph extends StatelessWidget {
  const _HeaderInfoGlyph();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0x66100B27),
          border: Border.all(color: const Color(0xFF9E6FCC), width: 1.2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x446D28D9), blurRadius: 10),
          ],
        ),
        child: const Icon(
          Icons.info_outline_rounded,
          size: 22,
          color: Color(0xFFE8D7FF),
        ),
      ),
    );
  }
}

class _ApprovedRouteHeader extends StatelessWidget {
  const _ApprovedRouteHeader({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.unlockStarsRequired,
    required this.complete,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final int unlockStarsRequired;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xE6110F20), Color(0xE60B1023)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF856338), width: 1.25),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
          BoxShadow(color: Color(0x225D2AA8), blurRadius: 14),
        ],
      ),
      child: Column(
        children: [
          Text(
            title.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFF8F3EC),
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              shadows: <Shadow>[
                Shadow(
                  color: Color(0xAA000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC94A),
                size: 27,
              ),
              const SizedBox(width: 5),
              Text(
                '$stars / $maximumStars',
                style: const TextStyle(
                  color: Color(0xFFFFE9B0),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      complete
                          ? 'ROTA TAMAMLANDI'
                          : 'Kapı: $unlockStarsRequired ⭐',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color:
                            complete
                                ? const Color(0xFF5EEAD4)
                                : const Color(0xFFFFE2A0),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HarborBackdrop extends StatelessWidget {
  const _HarborBackdrop();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _HarborScenePainter());
  }
}

class _MapSeal extends StatelessWidget {
  const _MapSeal({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: <Color>[Color(0xFF2A2117), Color(0xFF0D111C)],
          ),
          border: Border.all(color: const Color(0xFF9B7541), width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x55000000), blurRadius: 12),
            BoxShadow(color: Color(0x226F4B1A), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFD7B26D), size: 28),
      ),
    );
  }
}

class _RouteMapNode extends StatelessWidget {
  const _RouteMapNode({
    super.key,
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.nodeSize,
    this.onTap,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final double nodeSize;
  final VoidCallback? onTap;

  Color get _accent => switch (level.type) {
    WordHuntLevelType.normal => const Color(0xFF49E8F4),
    WordHuntLevelType.challenge => const Color(0xFFFFA726),
    WordHuntLevelType.bonus => const Color(0xFFC35CFF),
    WordHuntLevelType.routeFinal => const Color(0xFFFFD166),
  };

  String get _typeLabel => switch (level.type) {
    WordHuntLevelType.normal => '',
    WordHuntLevelType.challenge => 'MEYDAN OKUMA',
    WordHuntLevelType.bonus => 'BONUS DURAK',
    WordHuntLevelType.routeFinal => 'ROTA FİNALİ',
  };

  IconData get _typeIcon => switch (level.type) {
    WordHuntLevelType.challenge => Icons.sports_martial_arts_rounded,
    WordHuntLevelType.bonus => Icons.card_giftcard_rounded,
    WordHuntLevelType.routeFinal => Icons.inventory_2_rounded,
    WordHuntLevelType.normal => Icons.circle,
  };

  @override
  Widget build(BuildContext context) {
    final special = level.type != WordHuntLevelType.normal;
    final accent =
        unlocked
            ? _accent
            : special
            ? _accent.withValues(alpha: 0.52)
            : const Color(0xFF737985);
    final semanticLabel =
        unlocked
            ? 'Bölüm ${level.index}, ${_typeLabel.isEmpty ? 'Normal' : _typeLabel}, $stars yıldız, açık'
            : 'Bölüm ${level.index}, ${_typeLabel.isEmpty ? 'Normal' : _typeLabel}, kilitli';

    return Semantics(
      button: unlocked,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: _NodeDisc(
                level: level,
                nodeSize: nodeSize,
                accent: accent,
                unlocked: unlocked,
              ),
            ),
            Positioned(
              left: 2,
              top: nodeSize - 2,
              width: nodeSize - 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  3,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 15,
                    color:
                        index < stars
                            ? const Color(0xFFFFD15A)
                            : const Color(0xFF646777),
                    shadows:
                        index < stars
                            ? const <Shadow>[
                              Shadow(color: Color(0xAAFF9D00), blurRadius: 6),
                            ]
                            : null,
                  ),
                ),
              ),
            ),
            if (special)
              Positioned(
                left: nodeSize - 8,
                top: nodeSize * 0.22,
                child: _SpecialStopBadge(
                  label: _typeLabel,
                  icon: _typeIcon,
                  accent: accent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NodeDisc extends StatelessWidget {
  const _NodeDisc({
    required this.level,
    required this.nodeSize,
    required this.accent,
    required this.unlocked,
  });

  final WordHuntLevelDefinition level;
  final double nodeSize;
  final Color accent;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final special = level.type != WordHuntLevelType.normal;
    return Container(
      width: nodeSize,
      height: nodeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            accent.withValues(alpha: unlocked ? 0.48 : 0.22),
            const Color(0xFF0B1729),
            const Color(0xFF040A13),
          ],
          stops: const <double>[0, 0.62, 1],
        ),
        border: Border.all(
          color: accent,
          width: level.type == WordHuntLevelType.routeFinal ? 3.2 : 2.4,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: unlocked ? 0.55 : 0.2),
            blurRadius: unlocked ? 18 : 10,
            spreadRadius: unlocked ? 3 : 1,
          ),
          const BoxShadow(
            color: Color(0x88000000),
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (unlocked || special)
            Text(
              '${level.index}',
              style: TextStyle(
                color: unlocked ? Colors.white : const Color(0xFFB6B8C2),
                fontSize: level.type == WordHuntLevelType.routeFinal ? 28 : 23,
                fontWeight: FontWeight.w900,
                shadows: <Shadow>[
                  Shadow(color: accent.withValues(alpha: 0.75), blurRadius: 7),
                ],
              ),
            )
          else
            const Icon(Icons.lock_rounded, color: Color(0xFFB4B7C2), size: 25),
          if (!unlocked && special)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xDD0A0D14),
                  border: Border.all(color: const Color(0xFF727784)),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFFD0D2D8),
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpecialStopBadge extends StatelessWidget {
  const _SpecialStopBadge({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            const Color(0xE9111119),
            accent.withValues(alpha: 0.18),
          ],
        ),
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(4),
          right: Radius.circular(10),
        ),
        border: Border.all(color: accent.withValues(alpha: 0.85), width: 1.1),
        boxShadow: <BoxShadow>[
          BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 10),
          const BoxShadow(
            color: Color(0x55000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: accent,
                fontSize: 9.2,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: 0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePathPainter extends CustomPainter {
  const _RoutePathPainter({
    required this.points,
    required this.lastUnlockedIndex,
    required this.route,
  });

  final List<Offset> points;
  final int lastUnlockedIndex;
  final WordHuntRouteDefinition route;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final midpoint = Offset(
        (start.dx + end.dx) / 2 + (index.isEven ? 27 : -27),
        (start.dy + end.dy) / 2,
      );
      final path =
          Path()
            ..moveTo(start.dx, start.dy)
            ..quadraticBezierTo(midpoint.dx, midpoint.dy, end.dx, end.dy);

      final unlockedSegment = index + 2 <= lastUnlockedIndex;
      final destinationType =
          index + 1 < route.levels.length
              ? route.levels[index + 1].type
              : WordHuntLevelType.normal;
      final activeColor = switch (destinationType) {
        WordHuntLevelType.challenge => const Color(0xFFFFA726),
        WordHuntLevelType.bonus => const Color(0xFFC35CFF),
        WordHuntLevelType.routeFinal => const Color(0xFFFFD166),
        WordHuntLevelType.normal => const Color(0xFF5CF3FA),
      };

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..color =
              unlockedSegment
                  ? activeColor.withValues(alpha: 0.13)
                  : const Color(0x22000000),
      );

      if (unlockedSegment) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.8
            ..strokeCap = StrokeCap.round
            ..color = activeColor.withValues(alpha: 0.95),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.68),
        );
      } else {
        _drawDashedPath(
          canvas,
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xFF9EA4B2).withValues(alpha: 0.72),
        );
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + 8, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePathPainter oldDelegate) {
    return oldDelegate.lastUnlockedIndex != lastUnlockedIndex ||
        oldDelegate.points != points ||
        oldDelegate.route != route;
  }
}

class _HarborScenePainter extends CustomPainter {
  const _HarborScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF07152C),
            Color(0xFF07314A),
            Color(0xFF05283D),
            Color(0xFF071A31),
            Color(0xFF090F22),
          ],
          stops: <double>[0, 0.24, 0.5, 0.76, 1],
        ).createShader(rect),
    );

    _drawMoonAndReflection(canvas, size);
    _drawIsland(canvas, size, const Rect.fromLTWH(-0.08, 0.08, 0.56, 0.24), 0);
    _drawIsland(canvas, size, const Rect.fromLTWH(0.55, 0.16, 0.54, 0.27), 1);
    _drawIsland(canvas, size, const Rect.fromLTWH(-0.12, 0.43, 0.52, 0.28), 2);
    _drawIsland(canvas, size, const Rect.fromLTWH(0.57, 0.48, 0.52, 0.30), 3);
    _drawIsland(canvas, size, const Rect.fromLTWH(-0.09, 0.72, 0.50, 0.25), 4);
    _drawIsland(canvas, size, const Rect.fromLTWH(0.55, 0.76, 0.54, 0.25), 5);

    _drawLighthouse(
      canvas,
      size,
      Offset(size.width * 0.84, size.height * 0.22),
    );
    _drawSailboat(
      canvas,
      size,
      Offset(size.width * 0.22, size.height * 0.32),
      1.0,
    );
    _drawSailboat(
      canvas,
      size,
      Offset(size.width * 0.43, size.height * 0.27),
      0.72,
    );
    _drawDocks(canvas, size);
    _drawChest(canvas, size, Offset(size.width * 0.82, size.height * 0.92));
    _drawForegroundVignette(canvas, size);
  }

  void _drawMoonAndReflection(Canvas canvas, Size size) {
    final moon = Offset(size.width * 0.67, size.height * 0.065);
    for (var radius = 46.0; radius >= 15; radius -= 8) {
      canvas.drawCircle(
        moon,
        radius,
        Paint()
          ..color = const Color(
            0xFFE7F4FF,
          ).withValues(alpha: 0.012 + (46 - radius) / 900),
      );
    }
    canvas.drawCircle(
      moon,
      14,
      Paint()..color = const Color(0xFFE8EDF3).withValues(alpha: 0.92),
    );

    for (var i = 0; i < 10; i++) {
      final y = size.height * (0.10 + i * 0.026);
      final halfWidth = 10.0 + i * 4.6;
      canvas.drawLine(
        Offset(moon.dx - halfWidth, y),
        Offset(moon.dx + halfWidth, y),
        Paint()
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFC6E8FF).withValues(alpha: 0.28 - i * 0.018),
      );
    }
  }

  void _drawIsland(Canvas canvas, Size size, Rect normalized, int variant) {
    final rect = Rect.fromLTWH(
      normalized.left * size.width,
      normalized.top * size.height,
      normalized.width * size.width,
      normalized.height * size.height,
    );
    final path =
        Path()
          ..moveTo(rect.left + rect.width * 0.08, rect.top + rect.height * 0.50)
          ..cubicTo(
            rect.left + rect.width * 0.02,
            rect.top + rect.height * 0.24,
            rect.left + rect.width * 0.28,
            rect.top + rect.height * 0.02,
            rect.left + rect.width * 0.52,
            rect.top + rect.height * 0.11,
          )
          ..cubicTo(
            rect.left + rect.width * 0.80,
            rect.top + rect.height * 0.02,
            rect.right - rect.width * 0.01,
            rect.top + rect.height * 0.25,
            rect.right - rect.width * 0.04,
            rect.top + rect.height * 0.55,
          )
          ..cubicTo(
            rect.right - rect.width * 0.10,
            rect.bottom - rect.height * 0.04,
            rect.left + rect.width * 0.56,
            rect.bottom - rect.height * 0.02,
            rect.left + rect.width * 0.30,
            rect.bottom - rect.height * 0.08,
          )
          ..cubicTo(
            rect.left + rect.width * 0.10,
            rect.bottom - rect.height * 0.10,
            rect.left + rect.width * 0.01,
            rect.top + rect.height * 0.72,
            rect.left + rect.width * 0.08,
            rect.top + rect.height * 0.50,
          )
          ..close();

    canvas.drawShadow(path, const Color(0xAA000000), 12, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              variant.isEven
                  ? const <Color>[
                    Color(0xFF183D3E),
                    Color(0xFF0C202D),
                    Color(0xFF07131F),
                  ]
                  : const <Color>[
                    Color(0xFF1B3438),
                    Color(0xFF10222C),
                    Color(0xFF07121D),
                  ],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF38575A).withValues(alpha: 0.55),
    );

    final lightPaint = Paint()..color = const Color(0xFFFFC869);
    final glowPaint =
        Paint()..color = const Color(0xFFFFA62B).withValues(alpha: 0.18);
    final positions = <Offset>[
      Offset(0.25, 0.42),
      Offset(0.40, 0.58),
      Offset(0.58, 0.36),
      Offset(0.72, 0.60),
      Offset(0.50, 0.72),
    ];
    for (final p in positions) {
      final center = Offset(
        rect.left + rect.width * p.dx,
        rect.top + rect.height * p.dy,
      );
      canvas.drawCircle(center, 7, glowPaint);
      canvas.drawRect(
        Rect.fromCenter(center: center, width: 4, height: 3),
        lightPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy + 2),
        Offset(center.dx, center.dy + 7),
        Paint()
          ..strokeWidth = 1.2
          ..color = const Color(0xFF5B4332),
      );
    }
  }

  void _drawLighthouse(Canvas canvas, Size size, Offset base) {
    final towerHeight = size.height * 0.105;
    final towerWidth = size.width * 0.045;
    final top = Offset(base.dx, base.dy - towerHeight);

    final beam =
        Path()
          ..moveTo(top.dx - 4, top.dy + 6)
          ..lineTo(size.width * 0.63, top.dy - 8)
          ..lineTo(size.width * 0.63, top.dy + 18)
          ..close();
    canvas.drawPath(
      beam,
      Paint()..color = const Color(0xFFFFE6A6).withValues(alpha: 0.08),
    );

    final tower =
        Path()
          ..moveTo(base.dx - towerWidth * 0.62, base.dy)
          ..lineTo(top.dx - towerWidth * 0.34, top.dy + 11)
          ..lineTo(top.dx + towerWidth * 0.34, top.dy + 11)
          ..lineTo(base.dx + towerWidth * 0.62, base.dy)
          ..close();
    canvas.drawShadow(tower, const Color(0xAA000000), 8, true);
    canvas.drawPath(
      tower,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const <Color>[Color(0xFFC6B995), Color(0xFF6C6251)],
        ).createShader(Rect.fromLTWH(base.dx - 20, top.dy, 40, towerHeight)),
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(top.dx, top.dy + 8),
        width: towerWidth * 1.3,
        height: 8,
      ),
      Paint()..color = const Color(0xFF2C2520),
    );
    canvas.drawCircle(
      Offset(top.dx, top.dy + 6),
      14,
      Paint()..color = const Color(0xFFFFC766).withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      Offset(top.dx, top.dy + 6),
      4.5,
      Paint()..color = const Color(0xFFFFE1A0),
    );
  }

  void _drawSailboat(Canvas canvas, Size size, Offset center, double scale) {
    final hull =
        Path()
          ..moveTo(center.dx - 22 * scale, center.dy)
          ..quadraticBezierTo(
            center.dx,
            center.dy + 12 * scale,
            center.dx + 24 * scale,
            center.dy,
          )
          ..lineTo(center.dx + 17 * scale, center.dy + 9 * scale)
          ..lineTo(center.dx - 14 * scale, center.dy + 9 * scale)
          ..close();
    canvas.drawShadow(hull, const Color(0x99000000), 5, true);
    canvas.drawPath(hull, Paint()..color = const Color(0xFF4A3024));

    final mastTop = Offset(center.dx, center.dy - 34 * scale);
    canvas.drawLine(
      center,
      mastTop,
      Paint()
        ..strokeWidth = 2 * scale
        ..color = const Color(0xFF8B6F53),
    );
    final sail =
        Path()
          ..moveTo(mastTop.dx, mastTop.dy + 2 * scale)
          ..lineTo(center.dx + 17 * scale, center.dy - 5 * scale)
          ..lineTo(center.dx, center.dy - 5 * scale)
          ..close();
    canvas.drawPath(
      sail,
      Paint()..color = const Color(0xFFD3C39E).withValues(alpha: 0.78),
    );
  }

  void _drawDocks(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF5A3D2C).withValues(alpha: 0.78);
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.39),
      Offset(size.width * 0.31, size.height * 0.39),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.66, size.height * 0.58),
      Offset(size.width * 0.88, size.height * 0.57),
      paint,
    );
  }

  void _drawChest(Canvas canvas, Size size, Offset center) {
    final rect = Rect.fromCenter(center: center, width: 34, height: 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF6B3F1F),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFC79643),
    );
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 5, height: 7),
      Paint()..color = const Color(0xFFE4BD63),
    );
    canvas.drawCircle(
      center,
      20,
      Paint()..color = const Color(0xFFFFB847).withValues(alpha: 0.07),
    );
  }

  void _drawForegroundVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.18),
          radius: 1.05,
          colors: <Color>[
            Colors.transparent,
            const Color(0xFF02040C).withValues(alpha: 0.10),
            const Color(0xFF010208).withValues(alpha: 0.48),
          ],
          stops: const <double>[0.48, 0.78, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _HarborScenePainter oldDelegate) => false;
}
