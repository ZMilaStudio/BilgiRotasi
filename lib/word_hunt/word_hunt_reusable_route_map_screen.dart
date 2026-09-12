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
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
              child: _ReusableRouteHeader(
                title: route.title,
                stars: stars,
                maximumStars: route.maximumStars,
                theme: theme,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: theme.accentColor.withValues(
                            alpha: theme.artworkMode ? 0.08 : 0.30,
                          ),
                          width: theme.artworkMode ? 0.8 : 1.2,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: theme.nodeShadowColor.withValues(
                              alpha: theme.artworkMode ? 0.06 : 0.48,
                            ),
                            blurRadius: theme.artworkMode ? 8 : 22,
                            offset: Offset(0, theme.artworkMode ? 2 : 9),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
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
    final panelTop = Color.alphaBlend(
      theme.textColor.withValues(alpha: theme.artworkMode ? 0.13 : 0.09),
      theme.nodeColor,
    );
    final panelBottom = Color.alphaBlend(
      Colors.black.withValues(alpha: theme.artworkMode ? 0.33 : 0.24),
      theme.nodeColor,
    );
    final edgeColor = theme.artworkMode
        ? Color.alphaBlend(
            theme.accentColor.withValues(alpha: 0.38),
            const Color(0xFF5B381D),
          )
        : theme.accentColor.withValues(alpha: 0.62);

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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[panelTop, panelBottom],
                ),
                border: Border.all(
                  color: theme.artworkMode
                      ? edgeColor
                      : theme.accentColor.withValues(alpha: 0.72),
                  width: theme.artworkMode ? 2.6 : 2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: theme.nodeShadowColor.withValues(
                      alpha: theme.artworkMode ? 0.54 : 0.62,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.textColor,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: theme.artworkMode ? 58 : 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[panelTop, panelBottom],
              ),
              borderRadius: BorderRadius.circular(theme.artworkMode ? 20 : 16),
              border: Border.all(
                color: edgeColor,
                width: theme.artworkMode ? 2.2 : 1.6,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: theme.nodeShadowColor.withValues(alpha: 0.54),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
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
                fontSize: theme.artworkMode ? 25 : 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
                shadows: <Shadow>[
                  Shadow(
                    color: theme.nodeShadowColor.withValues(alpha: 0.72),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[panelTop, panelBottom],
            ),
            borderRadius: BorderRadius.circular(theme.artworkMode ? 18 : 15),
            border: Border.all(
              color: theme.artworkMode
                  ? edgeColor
                  : theme.accentColor.withValues(alpha: 0.70),
              width: theme.artworkMode ? 2 : 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.nodeShadowColor.withValues(alpha: 0.48),
                blurRadius: 9,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.star_rounded, color: theme.accentColor, size: 21),
              const SizedBox(width: 4),
              Text(
                '$stars / $maximumStars',
                key: const Key('word_hunt_reusable_route_stars'),
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 13,
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
            if (theme.artworkMode) _buildScenicNode() else _buildOrbNode(),
            if (completed) ...<Widget>[
              const SizedBox(height: 1),
              SizedBox(
                height: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    3,
                    (_) => Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: theme.accentColor,
                      shadows: <Shadow>[
                        Shadow(
                          color: theme.nodeShadowColor.withValues(alpha: 0.72),
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
              SizedBox(height: completed ? 0 : 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  endpointLabel,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.94),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.45,
                    shadows: <Shadow>[
                      Shadow(
                        color: theme.nodeShadowColor.withValues(alpha: 0.88),
                        blurRadius: 3,
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
            alignment: const Alignment(0, -0.18),
            child: Text(
              '${level.index}',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                shadows: <Shadow>[
                  Shadow(
                    color: theme.nodeShadowColor.withValues(alpha: 0.92),
                    blurRadius: 3,
                    offset: const Offset(0, 1.6),
                  ),
                ],
              ),
            ),
          ),
          if (!unlocked)
            Positioned(
              right: 4,
              bottom: 3,
              child: Container(
                width: 19,
                height: 19,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.nodeShadowColor.withValues(alpha: 0.82),
                  border: Border.all(
                    color: theme.textColor.withValues(alpha: 0.28),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 12,
                  color: theme.textColor.withValues(alpha: 0.94),
                ),
              ),
            ),
        ],
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
        ..color = accentColor.withValues(alpha: 0.48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, size.height * 0.43),
          width: 62,
          height: 47,
        ),
        glowPaint,
      );
    }

    final shadowPaint = Paint()
      ..color = shadowColor.withValues(alpha: locked ? 0.48 : 0.58);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 1, size.height * 0.72),
        width: 58,
        height: 21,
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
      Rect.fromLTWH(9, 23, size.width - 18, 25),
      const Radius.circular(8),
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
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (final dx in <double>[17, 27, 40, 51]) {
      canvas.drawLine(Offset(dx, 31), Offset(dx - 1.5, 43), barkPaint);
    }

    final topRect = Rect.fromLTWH(3, 4, size.width - 6, 42);
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.26, -0.32),
        radius: 0.92,
        colors: <Color>[
          Color.alphaBlend(textColor.withValues(alpha: 0.16), fillColor),
          fillColor,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.28), fillColor),
        ],
        stops: const <double>[0, 0.58, 1],
      ).createShader(topRect);
    canvas.drawOval(topRect, topPaint);

    final edgePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = current ? 4.2 : 3.0;
    canvas.drawOval(topRect.deflate(1.4), edgePaint);

    final ringPaint = Paint()
      ..color = textColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    canvas.drawOval(topRect.deflate(7), ringPaint);
    canvas.drawOval(topRect.deflate(12), ringPaint);

    final splitPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final split = Path()
      ..moveTo(size.width * 0.31, 18)
      ..quadraticBezierTo(size.width * 0.39, 24, size.width * 0.36, 30);
    canvas.drawPath(split, splitPaint);
  }

  void _paintLockedRock(Canvas canvas, Size size) {
    final rockRect = Rect.fromLTWH(4, 5, size.width - 8, 45);
    final rockPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.28, -0.38),
        radius: 0.94,
        colors: <Color>[
          Color.alphaBlend(textColor.withValues(alpha: 0.09), fillColor),
          fillColor,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.28), fillColor),
        ],
        stops: const <double>[0, 0.60, 1],
      ).createShader(rockRect);
    canvas.drawOval(rockRect, rockPaint);

    final edgePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(rockRect.deflate(1.4), edgePaint);

    final innerPaint = Paint()
      ..color = textColor.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawOval(rockRect.deflate(7), innerPaint);

    final crackPaint = Paint()
      ..color = shadowColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final crack = Path()
      ..moveTo(size.width * 0.34, 15)
      ..lineTo(size.width * 0.40, 21)
      ..lineTo(size.width * 0.36, 27)
      ..lineTo(size.width * 0.43, 31);
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
        alpha: artworkMode ? 0.08 : 0.42,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = artworkMode ? 11 : 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final earthPaint = Paint()
      ..color = theme.pathUnderlayColor.withValues(
        alpha: artworkMode ? 0.16 : 0.78,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = artworkMode ? 7 : 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final unlockedStonePaint = Paint()
      ..color = theme.pathColor.withValues(alpha: artworkMode ? 0.94 : 1)
      ..style = PaintingStyle.fill;
    final lockedStonePaint = Paint()
      ..color = theme.lockedPathColor.withValues(alpha: artworkMode ? 0.82 : 1)
      ..style = PaintingStyle.fill;
    final stoneHighlightPaint = Paint()
      ..color = theme.textColor.withValues(alpha: artworkMode ? 0.22 : 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = artworkMode ? 0.9 : 1.2;

    for (var index = 0;
        index < WordHuntRouteMapGeometry.connections.length;
        index++) {
      final connection = WordHuntRouteMapGeometry.connections[index];
      final fromIndex = connection.$1 - 1;
      final toIndex = connection.$2 - 1;
      final path = _automaticCurve(points[fromIndex], points[toIndex], index);
      final isUnlocked = unlocked[toIndex];

      if (!artworkMode || broadShadowPaint.color.a > 0) {
        canvas.drawPath(path, broadShadowPaint);
      }
      if (!artworkMode || earthPaint.color.a > 0) {
        canvas.drawPath(path, earthPaint);
      }
      _paintSteppingStones(
        canvas,
        path,
        isUnlocked ? unlockedStonePaint : lockedStonePaint,
        stoneHighlightPaint,
        artworkMode: artworkMode,
      );
    }
  }

  void _paintSteppingStones(
    Canvas canvas,
    Path path,
    Paint fillPaint,
    Paint highlightPaint, {
    required bool artworkMode,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = artworkMode ? 10.0 : 8.0;
      while (distance < metric.length - 6) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.save();
          canvas.translate(tangent.position.dx, tangent.position.dy);
          canvas.rotate(tangent.angle);
          final stoneRect = Rect.fromCenter(
            center: Offset.zero,
            width: artworkMode ? 10.5 : 13,
            height: artworkMode ? 5.5 : 7.5,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              stoneRect,
              Radius.circular(artworkMode ? 3 : 4),
            ),
            fillPaint,
          );
          canvas.drawArc(
            stoneRect.deflate(0.8),
            math.pi * 1.05,
            math.pi * 0.70,
            false,
            highlightPaint,
          );
          canvas.restore();
        }
        distance += artworkMode ? 23 : 19;
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
