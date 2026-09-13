import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';

/// Raster artwork kullanan Kelime Avı rotaları için sade production katmanı.
///
/// Artwork zaten sahnenin görsel karakterini taşıdığı için bu renderer sahnenin
/// üstüne ikinci bir "çizim" bindirmez. Rota çizgisi özellikle görünmez bırakılır;
/// doğal artwork patikası yön duygusunu verir. Flutter yalnız gerçek progression,
/// erişilebilir hitbox, hafif cam medalyonlar ve durum işaretlerini bindirir.
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

  static const double _nodeBoxWidth = 82;
  static const double _nodeBoxHeight = 78;

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
            const SizedBox(height: 52),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
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
                    children: <Widget>[
                      const Positioned.fill(
                        key: Key('word_hunt_reusable_atmosphere_layer'),
                        child: IgnorePointer(child: SizedBox.expand()),
                      ),
                      const Positioned.fill(
                        key: Key('word_hunt_reusable_path_layer'),
                        child: IgnorePointer(
                          child: SizedBox.expand(
                            key: Key('word_hunt_reusable_route_path'),
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
      child: _ArtworkGlassNode(
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
    return Row(
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0x8A07110A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x2EFFFFFF)),
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  key: const Key('word_hunt_reusable_route_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
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
            ),
          ),
        ),
        const SizedBox(width: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0x8A07110A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x2EFFFFFF)),
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
          ),
        ),
      ],
    );
  }
}

class _ArtworkGlassNode extends StatelessWidget {
  const _ArtworkGlassNode({
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

  @override
  Widget build(BuildContext context) {
    final diameter = current ? 54.0 : 50.0;
    final borderColor = current
        ? theme.accentColor
        : completed
        ? theme.pathColor.withValues(alpha: 0.88)
        : unlocked
        ? const Color(0x88FFFFFF)
        : const Color(0x4DFFFFFF);
    final fillTop = unlocked
        ? const Color(0xA61A2A1D)
        : const Color(0xA6242925);
    final fillBottom = unlocked
        ? const Color(0xD90A100C)
        : const Color(0xD9181B18);

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
            width: 66,
            height: 68,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox.square(
                  dimension: 58,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      if (current)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: theme.accentColor.withValues(alpha: 0.52),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ClipOval(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            width: diameter,
                            height: diameter,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[fillTop, fillBottom],
                              ),
                              border: Border.all(
                                color: borderColor,
                                width: current ? 2.4 : 1.2,
                              ),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x66000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${level.index}',
                              style: TextStyle(
                                color: unlocked
                                    ? theme.textColor
                                    : theme.textColor.withValues(alpha: 0.82),
                                fontSize: current ? 20 : 18,
                                fontWeight: FontWeight.w900,
                                shadows: const <Shadow>[
                                  Shadow(
                                    color: Color(0xCC000000),
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!unlocked)
                        Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xE6151916),
                              border: Border.all(
                                color: const Color(0x44FFFFFF),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_rounded,
                              size: 10,
                              color: theme.textColor.withValues(alpha: 0.90),
                            ),
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
                          size: 9,
                          color: theme.accentColor,
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
