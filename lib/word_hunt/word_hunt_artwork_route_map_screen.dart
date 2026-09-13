import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_production_assets.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';

/// Raster sahneli rotalar için production harita katmanı.
///
/// Arka plan artwork'ü [WordHuntThemedRouteMapScreen] tarafından sağlanır. Bu
/// sınıf yalnız canlı progression/hitbox katmanını çizer. Görünür düğümler,
/// Başlangıç Limanı'nda onaylanmış production asset ailesini kullanır; Flutter
/// ile sahte ahşap/taş şekilleri çizilmez.
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

  static const double _nodeBoxWidth = 86;
  static const double _nodeBoxHeight = 82;

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
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: _ArtworkHeader(
                title: route.title,
                stars: stars,
                maximumStars: route.maximumStars,
                theme: theme,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
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

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(18),
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
                                key: const Key('word_hunt_reusable_route_path'),
                                painter: _QuietTrailPainter(
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
    final top = (point.dy - _nodeBoxHeight / 2)
        .clamp(0.0, math.max(0.0, mapSize.height - _nodeBoxHeight))
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: _nodeBoxWidth,
      height: _nodeBoxHeight,
      child: _ArtworkAssetNode(
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
    final glass = theme.nodeShadowColor.withValues(alpha: 0.70);
    final border = theme.textColor.withValues(alpha: 0.16);

    return Row(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: Navigator.of(context).canPop()
                ? () => Navigator.of(context).pop()
                : null,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glass,
                border: Border.all(color: border),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.textColor,
                size: 19,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: glass,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              key: const Key('word_hunt_reusable_route_title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
                shadows: const <Shadow>[
                  Shadow(color: Color(0xCC000000), blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: glass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.star_rounded, color: theme.accentColor, size: 18),
              const SizedBox(width: 4),
              Text(
                '$stars / $maximumStars',
                key: const Key('word_hunt_reusable_route_stars'),
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArtworkAssetNode extends StatelessWidget {
  const _ArtworkAssetNode({
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

  double get _diameter => switch (level.type) {
    WordHuntLevelType.normal => unlocked ? 54 : 58,
    WordHuntLevelType.challenge => 62,
    WordHuntLevelType.bonus => 62,
    WordHuntLevelType.routeFinal => 70,
  };

  bool get _numberBakedIntoAsset =>
      level.type == WordHuntLevelType.challenge ||
      level.type == WordHuntLevelType.routeFinal;

  @override
  Widget build(BuildContext context) {
    final assetPath = WordHuntProductionAssets.nodeFor(
      type: level.type,
      unlocked: unlocked,
    );

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label:
          'Bölüm ${level.index}${unlocked ? ', açık' : ', kilitli'}'
          '${completed ? ', tamamlandı' : current ? ', sıradaki' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: SizedBox(
            key: Key('word_hunt_reusable_node_${level.index}_$_visualState'),
            width: _diameter,
            height: _diameter + (completed ? 12 : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox.square(
                  dimension: _diameter,
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      if (current)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: theme.accentColor.withValues(alpha: 0.72),
                                blurRadius: 22,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      Image.asset(
                        assetPath,
                        key: Key('word_hunt_artwork_node_asset_${level.index}'),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                      if (unlocked && !_numberBakedIntoAsset)
                        Center(
                          child: Text(
                            '${level.index}',
                            style: TextStyle(
                              color: const Color(0xFFFFFBF2),
                              fontSize: level.type == WordHuntLevelType.bonus
                                  ? 20
                                  : 19,
                              fontWeight: FontWeight.w900,
                              shadows: const <Shadow>[
                                Shadow(
                                  color: Color(0xDD000000),
                                  blurRadius: 3,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!unlocked &&
                          level.type == WordHuntLevelType.routeFinal)
                        const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Color(0xFFF0F1F3),
                            size: 22,
                            shadows: <Shadow>[
                              Shadow(color: Color(0xCC000000), blurRadius: 3),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (completed)
                  SizedBox(
                    height: 11,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        3,
                        (_) => Icon(
                          Icons.star_rounded,
                          size: 10,
                          color: theme.accentColor,
                          shadows: const <Shadow>[
                            Shadow(color: Color(0xAA000000), blurRadius: 2),
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
  }
}

class _QuietTrailPainter extends CustomPainter {
  const _QuietTrailPainter({
    required this.points,
    required this.unlocked,
    required this.theme,
  });

  final List<Offset> points;
  final List<bool> unlocked;
  final WordHuntRouteMapTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final active = unlocked[index] && unlocked[index + 1];
      final underlay = Paint()
        ..color = Colors.black.withValues(alpha: active ? 0.18 : 0.10)
        ..strokeWidth = active ? 5.0 : 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final line = Paint()
        ..color = (active ? theme.pathColor : theme.lockedPathColor).withValues(
          alpha: active ? 0.36 : 0.20,
        )
        ..strokeWidth = active ? 2.2 : 1.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, underlay);
      canvas.drawLine(start, end, line);
    }
  }

  @override
  bool shouldRepaint(covariant _QuietTrailPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.unlocked != unlocked ||
        oldDelegate.theme != theme;
  }
}
