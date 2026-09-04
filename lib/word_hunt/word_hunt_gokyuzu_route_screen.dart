import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';

class WordHuntGokyuzuRouteScreen extends StatelessWidget {
  const WordHuntGokyuzuRouteScreen({
    super.key,
    required this.route,
    this.progress = const WordHuntProgressSnapshot(),
    this.onBack,
    this.onInfo,
    this.onCompass,
    this.onBook,
    this.onLevelTap,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final VoidCallback? onCompass;
  final VoidCallback? onBook;
  final ValueChanged<int>? onLevelTap;

  static const Size canonicalSize = Size(1080, 1920);
  static const String _assetRoot = 'assets/word_hunt/gokyuzu_adalari';

  static const List<Offset> _stops = <Offset>[
    Offset(220, 430),
    Offset(520, 520),
    Offset(810, 650),
    Offset(650, 805),
    Offset(300, 930),
    Offset(185, 1095),
    Offset(500, 1210),
    Offset(830, 1315),
    Offset(535, 1470),
    Offset(705, 1645),
  ];

  static const List<String> _titles = <String>[
    'Rüzgâr Kapısı',
    'Bulut Bahçesi',
    'Kuş Geçidi',
    'Gökkuşağı Köprüsü',
    'Fırtına Kulesi',
    'Hava Gemisi Limanı',
    'Ay İskelesi',
    'Gizli Ada',
    'Yıldız Gözlemevi',
    'Güneş Sarayı',
  ];

  @override
  Widget build(BuildContext context) {
    final totalStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    return Scaffold(
      key: const Key('word_hunt_gokyuzu_route'),
      backgroundColor: const Color(0xFF79DDF4),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox.fromSize(
                  size: canonicalSize,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color(0xFF7CE1F5),
                          Color(0xFF55CDEB),
                          Color(0xFF6BD8D2),
                          Color(0xFF9CE8D2),
                        ],
                        stops: <double>[0, 0.42, 0.76, 1],
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: <Widget>[
                        ..._atmosphere(),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _GokyuzuRoutePainter(
                                points: _stops
                                    .take(route.levels.length)
                                    .toList(growable: false),
                                unlocked: List<bool>.generate(
                                  math.min(route.levels.length, _stops.length),
                                  (index) =>
                                      WordHuntRouteProgressEngine.isLevelUnlocked(
                                        route,
                                        progress,
                                        index + 1,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ..._decor(),
                        for (
                          var index = 0;
                          index < math.min(route.levels.length, _stops.length);
                          index++
                        )
                          _positionStop(index),
                        _topChrome(totalStars),
                        _bottomControl(
                          key: const Key('word_hunt_gokyuzu_compass'),
                          left: 72,
                          icon: Icons.explore_rounded,
                          semanticLabel: 'Pusula',
                          onTap: onCompass,
                        ),
                        _bottomControl(
                          key: const Key('word_hunt_gokyuzu_book'),
                          right: 72,
                          icon: Icons.menu_book_rounded,
                          semanticLabel: 'Bilgi Kitabı',
                          onTap: onBook,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 36,
                          child: Center(
                            child: Text(
                              'Gökyüzü Adaları',
                              key: const Key('word_hunt_gokyuzu_footer'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.74),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                shadows: const <Shadow>[
                                  Shadow(
                                    color: Color(0x66005A73),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _atmosphere() => <Widget>[
    _asset('cloud_far_01.webp', left: -80, top: 240, width: 330, opacity: .76),
    _asset('cloud_far_02.webp', right: -50, top: 300, width: 360, opacity: .70),
    _asset('cloud_mid_01.webp', left: 330, top: 350, width: 300, opacity: .84),
    _asset('cloud_mid_02.webp', right: 120, top: 940, width: 300, opacity: .76),
    _asset('wind_streak_01.webp', left: 60, top: 590, width: 260, opacity: .68),
    _asset(
      'sparkle_cluster_01.webp',
      right: 80,
      top: 430,
      width: 150,
      opacity: .86,
    ),
    _asset(
      'cloud_front_01.webp',
      left: -110,
      bottom: 100,
      width: 430,
      opacity: .92,
    ),
    _asset(
      'cloud_front_02.webp',
      right: -120,
      bottom: 160,
      width: 440,
      opacity: .92,
    ),
  ];

  List<Widget> _decor() => <Widget>[
    _asset('balloon_01.webp', left: 80, top: 690, width: 82),
    _asset('balloon_02.webp', right: 72, top: 1010, width: 78),
    _asset('bird_flock.webp', right: 115, top: 410, width: 125),
    _asset('airship_small.webp', left: 390, top: 1030, width: 150),
    _asset('airship_large.webp', right: 48, top: 1510, width: 180),
    _asset('sky_windmill.webp', left: 50, top: 1280, width: 112),
    _asset('flower_cluster.webp', left: 350, top: 1500, width: 105),
  ];

  Widget _positionStop(int zeroBasedIndex) {
    final index = zeroBasedIndex + 1;
    final level = route.levels[zeroBasedIndex];
    final center = _stops[zeroBasedIndex];
    final stars = progress.starsFor(level.id);
    final unlocked = WordHuntRouteProgressEngine.isLevelUnlocked(
      route,
      progress,
      index,
    );
    final completed = stars > 0;
    const width = 270.0;
    const height = 250.0;
    return Positioned(
      left: center.dx - width / 2,
      top: center.dy - height / 2,
      width: width,
      height: height,
      child: Semantics(
        button: unlocked,
        enabled: unlocked,
        label: '${_titles[zeroBasedIndex]}, Bölüm $index',
        child: GestureDetector(
          key: Key('word_hunt_gokyuzu_level_$index'),
          behavior: HitTestBehavior.opaque,
          onTap:
              unlocked && onLevelTap != null ? () => onLevelTap!(index) : null,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 20,
                child: Image.asset(
                  '$_assetRoot/island_variant_${((zeroBasedIndex % 7) + 1).toString().padLeft(2, '0')}.webp',
                  width: 225,
                  height: 126,
                  fit: BoxFit.contain,
                  errorBuilder: _imageError,
                ),
              ),
              Positioned(
                top: 0,
                child: Image.asset(
                  '$_assetRoot/scene_level_${index.toString().padLeft(2, '0')}.webp',
                  key: Key('word_hunt_gokyuzu_scene_$index'),
                  width: index == 10 ? 205 : 178,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: _imageError,
                ),
              ),
              Positioned(
                top: 104,
                child: _node(
                  index: index,
                  level: level,
                  stars: stars,
                  unlocked: unlocked,
                  completed: completed,
                ),
              ),
              Positioned(
                bottom: 2,
                left: 10,
                right: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xE6FFFFFF),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x33005F73),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Text(
                      _titles[zeroBasedIndex],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            unlocked
                                ? const Color(0xFF075D70)
                                : const Color(0xFF6A8790),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _node({
    required int index,
    required WordHuntLevelDefinition level,
    required int stars,
    required bool unlocked,
    required bool completed,
  }) {
    return SizedBox(
      width: 126,
      height: 118,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            '$_assetRoot/route_node_base.webp',
            width: 104,
            errorBuilder: _imageError,
          ),
          if (completed)
            Image.asset(
              '$_assetRoot/route_node_completed_ring.webp',
              width: 114,
              errorBuilder: _imageError,
            )
          else if (unlocked)
            Image.asset(
              '$_assetRoot/route_node_active_ring.webp',
              width: 114,
              errorBuilder: _imageError,
            ),
          if (!unlocked)
            Image.asset(
              '$_assetRoot/route_node_locked_overlay.webp',
              key: Key('word_hunt_gokyuzu_level_${index}_locked'),
              width: 112,
              errorBuilder: _imageError,
            ),
          if (level.type == WordHuntLevelType.bonus)
            Positioned(
              right: 0,
              top: 0,
              child: Image.asset(
                '$_assetRoot/route_node_bonus_badge.webp',
                width: 44,
                errorBuilder: _imageError,
              ),
            ),
          if (level.type == WordHuntLevelType.routeFinal)
            Positioned(
              top: -2,
              child: Image.asset(
                '$_assetRoot/route_crown.webp',
                width: 54,
                errorBuilder: _imageError,
              ),
            ),
          Text(
            '$index',
            style: TextStyle(
              color: unlocked ? Colors.white : const Color(0xFFB8C7CB),
              fontSize: 30,
              fontWeight: FontWeight.w900,
              shadows: const <Shadow>[
                Shadow(color: Color(0x66005D70), blurRadius: 7),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(3, (starIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Image.asset(
                    '$_assetRoot/${starIndex < stars ? 'route_star_filled' : 'route_star_empty'}.webp',
                    width: 22,
                    height: 22,
                    errorBuilder: _imageError,
                  ),
                );
              }),
            ),
          ),
          if (!unlocked)
            Positioned(
              right: 5,
              bottom: 7,
              child: Image.asset(
                '$_assetRoot/route_lock.webp',
                width: 26,
                errorBuilder: _imageError,
              ),
            ),
        ],
      ),
    );
  }

  Widget _topChrome(int totalStars) {
    return Positioned(
      left: 58,
      right: 58,
      top: 48,
      height: 218,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE8FFFFFF),
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: const Color(0xB3FFFFFF), width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x3000677D),
              blurRadius: 30,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'GÖKYÜZÜ ADALARI',
                    key: Key('word_hunt_gokyuzu_title'),
                    style: TextStyle(
                      color: Color(0xFF075F72),
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$totalStars / ${route.maximumStars} ⭐',
                    key: const Key('word_hunt_gokyuzu_stars'),
                    style: const TextStyle(
                      color: Color(0xFFE6A21A),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              top: 58,
              child: _chromeButton(
                key: const Key('word_hunt_gokyuzu_back'),
                icon: Icons.arrow_back_rounded,
                semanticLabel: 'Geri',
                onTap: onBack,
              ),
            ),
            Positioned(
              right: 24,
              top: 58,
              child: _chromeButton(
                key: const Key('word_hunt_gokyuzu_info'),
                icon: Icons.info_outline_rounded,
                semanticLabel: 'Bilgi',
                onTap: onInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomControl({
    required Key key,
    double? left,
    double? right,
    required IconData icon,
    required String semanticLabel,
    required VoidCallback? onTap,
  }) {
    return Positioned(
      left: left,
      right: right,
      bottom: 72,
      child: _chromeButton(
        key: key,
        icon: icon,
        semanticLabel: semanticLabel,
        onTap: onTap,
        size: 94,
      ),
    );
  }

  Widget _chromeButton({
    required Key key,
    required IconData icon,
    required String semanticLabel,
    required VoidCallback? onTap,
    double size = 82,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 7,
        child: InkWell(
          key: key,
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, color: const Color(0xFF08758B), size: size * .48),
          ),
        ),
      ),
    );
  }

  Widget _asset(
    String name, {
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double width,
    double opacity = 1,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            '$_assetRoot/$name',
            width: width,
            fit: BoxFit.contain,
            errorBuilder: _imageError,
          ),
        ),
      ),
    );
  }

  static Widget _imageError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) => const SizedBox.shrink();
}

class _GokyuzuRoutePainter extends CustomPainter {
  const _GokyuzuRoutePainter({required this.points, required this.unlocked});

  final List<Offset> points;
  final List<bool> unlocked;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final base =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: .50);
    final active =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFC93B).withValues(alpha: .92);

    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final controlDx = (end.dx - start.dx) * .55;
      final path =
          Path()
            ..moveTo(start.dx, start.dy)
            ..cubicTo(
              start.dx + controlDx,
              start.dy + 24,
              end.dx - controlDx,
              end.dy - 24,
              end.dx,
              end.dy,
            );
      canvas.drawPath(path, base);
      if (i + 1 < unlocked.length && unlocked[i + 1]) {
        canvas.drawPath(path, active);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GokyuzuRoutePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.unlocked != unlocked;
  }
}
