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

  /// Raster artwork bağlandığında themed wrapper arka plan ve yüzeyi
  /// transparanlaştırır. Bu generic işaret route-id kontrolü olmadan renderer'ın
  /// gerçek sahneyle uyumlu, daha doğal yol/node skinine geçmesini sağlar.
  bool get artworkMode => backgroundColor.a == 0 && surfaceColor.a == 0;

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
    backgroundColor: Color(0xFF07150D),
    surfaceColor: Color(0xFF143420),
    pathColor: Color(0xFFEBD49B),
    lockedPathColor: Color(0xFF657066),
    nodeColor: Color(0xFF81542F),
    lockedNodeColor: Color(0xFF4A5050),
    accentColor: Color(0xFFFFD96B),
    textColor: Color(0xFFFFF7E2),
    sceneGlowColor: Color(0xFFFFE7A8),
    pathUnderlayColor: Color(0xA7352416),
    nodeShadowColor: Color(0xD407100A),
    sceneDepth: 0.58,
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

  // Hitbox sözleşmesi değişmez. Scenic skin yalnız bu kutunun içindeki görsel
  // medalyonu küçültür; test/tap geometrisi aynı kalır.
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
    final scenic = theme.artworkMode;

    return Scaffold(
      key: const Key('word_hunt_reusable_route_map'),
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                scenic ? 10 : 12,
                scenic ? 8 : 10,
                scenic ? 10 : 12,
                scenic ? 6 : 9,
              ),
              child: _ReusableRouteHeader(
                title: route.title,
                stars: stars,
                maximumStars: route.maximumStars,
                theme: theme,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  scenic ? 4 : 8,
                  0,
                  scenic ? 4 : 8,
                  scenic ? 4 : 8,
                ),
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
                    final surfaceRadius = scenic ? 18.0 : 26.0;

                    return DecoratedBox(
                      key: Key('word_hunt_reusable_surface_${theme.id}'),
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(surfaceRadius),
                        border: Border.all(
                          color: scenic
                              ? Colors.transparent
                              : theme.accentColor.withValues(alpha: 0.30),
                          width: scenic ? 0 : 1.2,
                        ),
                        boxShadow: scenic
                            ? const <BoxShadow>[]
                            : <BoxShadow>[
                                BoxShadow(
                                  color: theme.nodeShadowColor.withValues(
                                    alpha: 0.48,
                                  ),
                                  blurRadius: 22,
                                  offset: const Offset(0, 9),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(surfaceRadius),
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

class _ReusableRouteHeader extends StatelessWidget {
  const _ReusableRouteHeader({
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
    final scenic = theme.artworkMode;
    final panelTopOpaque = Color.alphaBlend(
      theme.textColor.withValues(alpha: scenic ? 0.08 : 0.09),
      theme.nodeColor,
    );
    final panelBottomOpaque = Color.alphaBlend(
      Colors.black.withValues(alpha: scenic ? 0.38 : 0.24),
      theme.nodeColor,
    );
    final panelTop = scenic
        ? panelTopOpaque.withValues(alpha: 0.78)
        : panelTopOpaque;
    final panelBottom = scenic
        ? panelBottomOpaque.withValues(alpha: 0.88)
        : panelBottomOpaque;
    final edgeColor = scenic
        ? theme.accentColor.withValues(alpha: 0.38)
        : theme.accentColor.withValues(alpha: 0.62);
    final shadowColor = theme.nodeShadowColor.withValues(
      alpha: scenic ? 0.38 : 0.54,
    );

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
              width: scenic ? 44 : 50,
              height: scenic ? 44 : 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[panelTop, panelBottom],
                ),
                border: Border.all(
                  color: edgeColor,
                  width: scenic ? 1.4 : 2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: scenic ? 8 : 10,
                    offset: Offset(0, scenic ? 3 : 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.textColor,
                size: scenic ? 20 : 24,
              ),
            ),
          ),
        ),
        SizedBox(width: scenic ? 6 : 8),
        Expanded(
          child: Container(
            height: scenic ? 48 : 56,
            padding: EdgeInsets.symmetric(horizontal: scenic ? 12 : 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[panelTop, panelBottom],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: edgeColor,
                width: scenic ? 1.2 : 1.6,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: shadowColor,
                  blurRadius: scenic ? 9 : 12,
                  offset: Offset(0, scenic ? 3 : 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              key: const Key('word_hunt_reusable_route_title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textColor,
                fontSize: scenic ? 21 : 24,
                fontWeight: FontWeight.w900,
                letterSpacing: scenic ? 0.1 : 0.2,
                shadows: <Shadow>[
                  Shadow(
                    color: theme.nodeShadowColor.withValues(
                      alpha: scenic ? 0.56 : 0.72,
                    ),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: scenic ? 6 : 8),
        Container(
          height: scenic ? 42 : 48,
          padding: EdgeInsets.symmetric(horizontal: scenic ? 8 : 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[panelTop, panelBottom],
            ),
            borderRadius: BorderRadius.circular(scenic ? 14 : 15),
            border: Border.all(
              color: edgeColor,
              width: scenic ? 1.1 : 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: shadowColor,
                blurRadius: scenic ? 7 : 9,
                offset: Offset(0, scenic ? 3 : 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.star_rounded,
                color: theme.accentColor,
                size: scenic ? 18 : 21,
              ),
              SizedBox(width: scenic ? 3 : 4),
              Text(
                '$stars / $maximumStars',
                key: const Key('word_hunt_reusable_route_stars'),
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: scenic ? 12 : 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
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
    final scenic = theme.artworkMode;

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
            if (scenic) _buildScenicNode() else _buildOrbNode(),
            if (completed) ...<Widget>[
              SizedBox(height: scenic ? 0 : 1),
              SizedBox(
                height: scenic ? 10 : 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    3,
                    (_) => Icon(
                      Icons.star_rounded,
                      size: scenic ? 10 : 12,
                      color: theme.accentColor,
                      shadows: <Shadow>[
                        Shadow(
                          color: theme.nodeShadowColor.withValues(alpha: 0.68),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (endpointLabel != null) ...<Widget>[
              SizedBox(height: completed ? 0 : scenic ? 2 : 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  endpointLabel,
                  style: TextStyle(
                    color: theme.textColor.withValues(
                      alpha: scenic ? 0.90 : 0.94,
                    ),
                    fontSize: scenic ? 8.5 : 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: scenic ? 0.35 : 0.45,
                    shadows: <Shadow>[
                      Shadow(
                        color: theme.nodeShadowColor.withValues(alpha: 0.92),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScenicNode() {
    final fillColor = unlocked ? theme.nodeColor : theme.lockedNodeColor;
    final borderColor = current
        ? theme.accentColor
        : completed
        ? theme.pathColor
        : unlocked
        ? theme.pathColor
        : theme.lockedPathColor;

    return SizedBox(
      key: Key('word_hunt_reusable_node_${level.index}_$_visualState'),
      width: 68,
      height: WordHuntReusableRouteMapScreen._nodeDiameter,
      child: Center(
        child: SizedBox(
          width: current ? 60 : 56,
          height: current ? 48 : 46,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: _ScenicRouteNodePainter(
                    fillColor: fillColor,
                    borderColor: borderColor,
                    shadowColor: theme.nodeShadowColor,
                    accentColor: theme.accentColor,
                    textColor: theme.textColor,
                    locked: !unlocked,
                    current: current,
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.14),
                child: Text(
                  '${level.index}',
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: current ? 18 : 17,
                    fontWeight: FontWeight.w900,
                    shadows: <Shadow>[
                      Shadow(
                        color: theme.nodeShadowColor.withValues(alpha: 0.94),
                        blurRadius: 3,
                        offset: const Offset(0, 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              if (!unlocked)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.nodeShadowColor.withValues(alpha: 0.80),
                      border: Border.all(
                        color: theme.textColor.withValues(alpha: 0.20),
                        width: 0.8,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.30),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 9,
                      color: theme.textColor.withValues(alpha: 0.88),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrbNode() {
    final fillColor = unlocked ? theme.nodeColor : theme.lockedNodeColor;
    final borderColor = current
        ? theme.accentColor
        : completed
        ? theme.pathColor
        : unlocked
        ? theme.accentColor
        : theme.lockedPathColor;
    final lightFill = Color.alphaBlend(
      theme.textColor.withValues(alpha: unlocked ? 0.09 : 0.03),
      fillColor,
    );
    final darkFill = Color.alphaBlend(
      Colors.black.withValues(alpha: unlocked ? 0.22 : 0.30),
      fillColor,
    );

    return Container(
      key: Key('word_hunt_reusable_node_${level.index}_$_visualState'),
      width: WordHuntReusableRouteMapScreen._nodeDiameter,
      height: WordHuntReusableRouteMapScreen._nodeDiameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.30, -0.38),
          colors: <Color>[lightFill, fillColor, darkFill],
          stops: const <double>[0.0, 0.58, 1.0],
        ),
        border: Border.all(
          color: borderColor,
          width: current ? 4.2 : 3.2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.nodeShadowColor.withValues(alpha: 0.78),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          if (current)
            BoxShadow(
              color: theme.accentColor.withValues(alpha: 0.74),
              blurRadius: 24,
              spreadRadius: 3,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Container(
              width: 41,
              height: 41,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.textColor.withValues(
                    alpha: unlocked ? 0.17 : 0.08,
                  ),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${level.index}',
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  shadows: <Shadow>[
                    Shadow(
                      color: theme.nodeShadowColor.withValues(alpha: 0.82),
                      blurRadius: 3,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!unlocked)
            Positioned(
              right: 3,
              bottom: 2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.nodeShadowColor.withValues(alpha: 0.78),
                  border: Border.all(
                    color: theme.textColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 11,
                  color: theme.textColor.withValues(alpha: 0.88),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScenicRouteNodePainter extends CustomPainter {
  const _ScenicRouteNodePainter({
    required this.fillColor,
    required this.borderColor,
    required this.shadowColor,
    required this.accentColor,
    required this.textColor,
    required this.locked,
    required this.current,
  });

  final Color fillColor;
  final Color borderColor;
  final Color shadowColor;
  final Color accentColor;
  final Color textColor;
  final bool locked;
  final bool current;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    if (current) {
      final glowPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, size.height * 0.43),
          width: size.width * 0.96,
          height: size.height * 0.80,
        ),
        glowPaint,
      );
    }

    final shadowPaint = Paint()
      ..color = shadowColor.withValues(alpha: locked ? 0.34 : 0.50);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 1, size.height * 0.78),
        width: size.width * 0.76,
        height: size.height * 0.25,
      ),
      shadowPaint,
    );

    if (locked) {
      _paintLockedRock(canvas, size);
    } else {
      _paintWoodStump(canvas, size);
    }
  }

  void _paintWoodStump(Canvas canvas, Size size) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.42,
        size.width * 0.68,
        size.height * 0.40,
      ),
      Radius.circular(size.height * 0.13),
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color.alphaBlend(textColor.withValues(alpha: 0.04), fillColor),
          Color.alphaBlend(Colors.black.withValues(alpha: 0.34), fillColor),
        ],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    final barkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    for (final factor in <double>[0.29, 0.42, 0.57, 0.70]) {
      final dx = size.width * factor;
      canvas.drawLine(
        Offset(dx, size.height * 0.56),
        Offset(dx - 1.2, size.height * 0.75),
        barkPaint,
      );
    }

    final topRect = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.08,
      size.width * 0.90,
      size.height * 0.67,
    );
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.26, -0.32),
        radius: 0.92,
        colors: <Color>[
          Color.alphaBlend(textColor.withValues(alpha: 0.15), fillColor),
          fillColor,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.30), fillColor),
        ],
        stops: const <double>[0, 0.58, 1],
      ).createShader(topRect);
    canvas.drawOval(topRect, topPaint);

    final edgePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = current ? 3.6 : 2.2;
    canvas.drawOval(topRect.deflate(1.1), edgePaint);

    final ringPaint = Paint()
      ..color = textColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawOval(topRect.deflate(size.width * 0.10), ringPaint);
    canvas.drawOval(topRect.deflate(size.width * 0.18), ringPaint);
  }

  void _paintLockedRock(Canvas canvas, Size size) {
    final rockRect = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.12,
      size.width * 0.84,
      size.height * 0.68,
    );
    final rockPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.30, -0.36),
        radius: 0.98,
        colors: <Color>[
          Color.alphaBlend(textColor.withValues(alpha: 0.06), fillColor),
          fillColor,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.36), fillColor),
        ],
        stops: const <double>[0, 0.58, 1],
      ).createShader(rockRect);
    canvas.drawOval(rockRect, rockPaint);

    final edgePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawOval(rockRect.deflate(0.9), edgePaint);

    final innerPaint = Paint()
      ..color = textColor.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawOval(rockRect.deflate(size.width * 0.11), innerPaint);

    final crackPaint = Paint()
      ..color = shadowColor.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    final crack = Path()
      ..moveTo(size.width * 0.35, size.height * 0.28)
      ..lineTo(size.width * 0.41, size.height * 0.39)
      ..lineTo(size.width * 0.37, size.height * 0.49)
      ..lineTo(size.width * 0.44, size.height * 0.57);
    canvas.drawPath(crack, crackPaint);
  }

  @override
  bool shouldRepaint(covariant _ScenicRouteNodePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.locked != locked ||
        oldDelegate.current != current;
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
      center: Offset(size.width * 0.50, size.height * 0.10),
      radius: longestSide * 0.62,
    );
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          theme.resolvedSceneGlowColor.withValues(
            alpha: theme.sceneDepth * 0.42,
          ),
          theme.surfaceColor.withValues(alpha: theme.sceneDepth * 0.12),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.42, 1.0],
      ).createShader(glowRect);
    canvas.drawRect(rect, glowPaint);

    final depthPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.transparent,
          theme.backgroundColor.withValues(alpha: theme.sceneDepth * 0.18),
          theme.backgroundColor.withValues(alpha: theme.sceneDepth * 0.62),
        ],
        stops: const <double>[0.20, 0.62, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, depthPaint);

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        radius: 0.88,
        colors: <Color>[
          Colors.transparent,
          theme.backgroundColor.withValues(alpha: theme.sceneDepth * 0.62),
        ],
        stops: const <double>[0.54, 1],
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
    final artworkMode = theme.artworkMode;
    final broadShadowPaint = Paint()
      ..color = theme.nodeShadowColor.withValues(
        alpha: artworkMode ? 0.0 : 0.42,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = artworkMode ? 0 : 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final earthPaint = Paint()
      ..color = theme.pathUnderlayColor.withValues(
        alpha: artworkMode ? 0.0 : 0.78,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = artworkMode ? 0 : 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final unlockedStonePaint = Paint()
      ..color = theme.pathColor.withValues(alpha: artworkMode ? 0.86 : 1)
      ..style = PaintingStyle.fill;
    final lockedStonePaint = Paint()
      ..color = theme.lockedPathColor.withValues(
        alpha: artworkMode ? 0.48 : 1,
      )
      ..style = PaintingStyle.fill;
    final stoneHighlightPaint = Paint()
      ..color = theme.textColor.withValues(
        alpha: artworkMode ? 0.12 : 0.30,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = artworkMode ? 0.7 : 1.2;

    for (var index = 0;
        index < WordHuntRouteMapGeometry.connections.length;
        index++) {
      final connection = WordHuntRouteMapGeometry.connections[index];
      final fromIndex = connection.$1 - 1;
      final toIndex = connection.$2 - 1;
      final path = _automaticCurve(points[fromIndex], points[toIndex], index);
      final isUnlocked = unlocked[toIndex];

      if (!artworkMode) {
        canvas.drawPath(path, broadShadowPaint);
        canvas.drawPath(path, earthPaint);
      }
      _paintSteppingStones(
        canvas,
        path,
        isUnlocked ? unlockedStonePaint : lockedStonePaint,
        stoneHighlightPaint,
        artworkMode: artworkMode,
        emphasized: isUnlocked,
      );
    }
  }

  void _paintSteppingStones(
    Canvas canvas,
    Path path,
    Paint fillPaint,
    Paint highlightPaint, {
    required bool artworkMode,
    required bool emphasized,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = artworkMode ? 11.0 : 8.0;
      while (distance < metric.length - 6) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.save();
          canvas.translate(tangent.position.dx, tangent.position.dy);
          canvas.rotate(tangent.angle);
          final stoneRect = Rect.fromCenter(
            center: Offset.zero,
            width: artworkMode ? (emphasized ? 8.5 : 6.5) : 13,
            height: artworkMode ? (emphasized ? 4.5 : 3.2) : 7.5,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              stoneRect,
              Radius.circular(artworkMode ? 2.4 : 4),
            ),
            fillPaint,
          );
          if (!artworkMode || emphasized) {
            canvas.drawArc(
              stoneRect.deflate(0.6),
              math.pi * 1.05,
              math.pi * 0.70,
              false,
              highlightPaint,
            );
          }
          canvas.restore();
        }
        distance += artworkMode ? (emphasized ? 23 : 28) : 19;
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
