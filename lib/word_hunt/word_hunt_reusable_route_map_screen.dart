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

enum WordHuntRouteNodeVisualStyle { scenicWood, facetedCrystal }

/// facetedCrystal skin'in owner-approved görsel hiyerarşi metrikleri.
/// Hitbox ve canonical node merkezleri bu değerlerden etkilenmez.
abstract final class WordHuntFacetedCrystalMetrics {
  static const double normalScale = 1.00;
  static const double challengeScale = 1.06;
  static const double finalScale = 1.11;
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
    this.finalAccentColor,
    this.nodeVisualStyle = WordHuntRouteNodeVisualStyle.scenicWood,
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
  final Color? finalAccentColor;
  final WordHuntRouteNodeVisualStyle nodeVisualStyle;

  Color get resolvedSceneGlowColor => sceneGlowColor ?? accentColor;
  Color get resolvedFinalAccentColor => finalAccentColor ?? accentColor;

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
    this.hostedByArtworkChrome = false,
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
  final bool hostedByArtworkChrome;

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
    final currentLevelIndex =
        WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress);
    final scenic = theme.artworkMode;

    return Scaffold(
      key: const Key('word_hunt_reusable_route_map'),
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (hostedByArtworkChrome) const SizedBox(height: 48),
            Padding(
              padding: EdgeInsets.fromLTRB(
                scenic ? 10 : 12,
                hostedByArtworkChrome
                    ? 2
                    : scenic
                    ? 8
                    : 10,
                scenic ? 10 : 12,
                scenic ? 6 : 9,
              ),
              child: _ReusableRouteHeader(
                title: route.title,
                stars: stars,
                maximumStars: route.maximumStars,
                theme: theme,
                showBackButton: !hostedByArtworkChrome,
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
                                key: const Key('word_hunt_reusable_route_path'),
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
                                current:
                                    unlocked[index] &&
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
    this.showBackButton = true,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final WordHuntRouteMapTheme theme;
  final bool showBackButton;

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
        if (showBackButton)
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
                  border: Border.all(color: edgeColor, width: scenic ? 1.4 : 2),
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
              border: Border.all(color: edgeColor, width: scenic ? 1.2 : 1.6),
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
            border: Border.all(color: edgeColor, width: scenic ? 1.1 : 1.5),
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
          '${completed
              ? ', tamamlandı'
              : current
              ? ', sıradaki'
              : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (scenic) _buildScenicNode() else _buildOrbNode(),
            if (completed &&
                theme.nodeVisualStyle !=
                    WordHuntRouteNodeVisualStyle.facetedCrystal) ...<Widget>[
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
              SizedBox(
                height: completed
                    ? 0
                    : scenic
                    ? 2
                    : 3,
              ),
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
    if (theme.nodeVisualStyle == WordHuntRouteNodeVisualStyle.facetedCrystal) {
      return _buildFacetedCrystalNode();
    }
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

  Widget _buildFacetedCrystalNode() {
    final isFinal = level.type == WordHuntLevelType.routeFinal;
    final isChallenge = level.type == WordHuntLevelType.challenge;
    final activeFinal = isFinal && unlocked;
    final activeChallenge = isChallenge && current && unlocked;
    final scale = isFinal
        ? WordHuntFacetedCrystalMetrics.finalScale
        : isChallenge
        ? WordHuntFacetedCrystalMetrics.challengeScale
        : WordHuntFacetedCrystalMetrics.normalScale;
    final rimColor = isFinal
        ? activeFinal
              ? theme.resolvedFinalAccentColor
              : theme.lockedPathColor
        : isChallenge
        ? unlocked
              ? theme.accentColor
              : theme.lockedPathColor
        : unlocked
        ? theme.pathColor
        : theme.lockedPathColor;
    final crystalFill = unlocked
        ? theme.nodeColor
        : Color.alphaBlend(
            theme.nodeColor.withValues(alpha: 0.28),
            theme.lockedNodeColor,
          );

    return SizedBox(
      key: Key('word_hunt_reusable_node_${level.index}_$_visualState'),
      width: 68,
      height: WordHuntReusableRouteMapScreen._nodeDiameter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          if (activeChallenge || (activeFinal && current))
            Positioned.fill(
              child: DecoratedBox(
                key: Key(
                  isFinal
                      ? 'word_hunt_faceted_final_active_glow'
                      : 'word_hunt_faceted_challenge_glow',
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color:
                          (isFinal
                                  ? theme.resolvedFinalAccentColor
                                  : theme.accentColor)
                              .withValues(alpha: isFinal ? 0.25 : 0.17),
                      blurRadius: isFinal ? 13 : 9,
                      spreadRadius: isFinal ? 0.4 : 0.0,
                    ),
                  ],
                ),
              ),
            ),
          Transform.scale(
            scale: scale,
            child: SizedBox(
              key: Key('word_hunt_faceted_node_${level.index}'),
              width: 54,
              height: 46,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: <Widget>[
                  CustomPaint(
                    key: Key('word_hunt_faceted_medallion_${level.index}'),
                    painter: _FacetedCrystalNodePainter(
                      fillColor: crystalFill,
                      rimColor: rimColor,
                      innerRimColor: isFinal && unlocked
                          ? theme.pathColor
                          : theme.textColor.withValues(
                              alpha: unlocked ? 0.24 : 0.18,
                            ),
                      accentColor: theme.accentColor,
                      shadowColor: theme.nodeShadowColor,
                      textColor: theme.textColor,
                      locked: !unlocked,
                      challenge: isChallenge,
                      finalNode: isFinal,
                      active: current && unlocked,
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, completed ? -0.12 : -0.04),
                    child: Text(
                      '${level.index}',
                      key: Key('word_hunt_faceted_number_${level.index}'),
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: isFinal ? 17.5 : 17,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        shadows: <Shadow>[
                          Shadow(
                            color: theme.nodeShadowColor.withValues(
                              alpha: 0.96,
                            ),
                            blurRadius: 3,
                            offset: const Offset(0, 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!unlocked)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0.5,
                      child: Center(
                        child: Container(
                          key: Key('word_hunt_faceted_lock_${level.index}'),
                          width: 16,
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                theme.lockedPathColor.withValues(alpha: 0.28),
                                theme.nodeShadowColor.withValues(alpha: 0.86),
                              ],
                            ),
                            border: Border.all(
                              color: theme.lockedPathColor.withValues(alpha: 0.70),
                              width: 0.8,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: theme.nodeShadowColor.withValues(alpha: 0.72),
                                blurRadius: 2.2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 7.5,
                            color: theme.textColor.withValues(alpha: 0.86),
                          ),
                        ),
                      ),
                    ),
                  if (completed)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0.5,
                      child: Center(
                        child: Container(
                          key: Key('word_hunt_faceted_stars_${level.index}'),
                          width: 28,
                          height: 9,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                theme.accentColor.withValues(alpha: 0.24),
                                theme.nodeShadowColor.withValues(alpha: 0.80),
                              ],
                            ),
                            border: Border.all(
                              color: theme.accentColor.withValues(alpha: 0.58),
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List<Widget>.generate(
                              3,
                              (_) => Icon(
                                Icons.star_rounded,
                                size: 6.2,
                                color: theme.accentColor.withValues(alpha: 0.96),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isFinal)
            Positioned(
              key: Key(
                'word_hunt_faceted_final_crest_state_${activeFinal ? 'active' : 'locked'}',
              ),
              top: -18,
              width: 44,
              height: 25,
              child: CustomPaint(
                key: const Key('word_hunt_faceted_final_crest'),
                painter: _CrystalFinalCrestPainter(
                  crystalColor: activeFinal
                      ? theme.nodeColor
                      : crystalFill,
                  edgeColor: activeFinal
                      ? theme.resolvedFinalAccentColor
                      : theme.lockedPathColor,
                  accentColor: activeFinal
                      ? theme.pathColor
                      : theme.lockedPathColor.withValues(alpha: 0.48),
                  shadowColor: theme.nodeShadowColor,
                  active: activeFinal,
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
        border: Border.all(color: borderColor, width: current ? 4.2 : 3.2),
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

class _FacetedCrystalNodePainter extends CustomPainter {
  const _FacetedCrystalNodePainter({
    required this.fillColor,
    required this.rimColor,
    required this.innerRimColor,
    required this.accentColor,
    required this.shadowColor,
    required this.textColor,
    required this.locked,
    required this.challenge,
    required this.finalNode,
    required this.active,
  });

  final Color fillColor;
  final Color rimColor;
  final Color innerRimColor;
  final Color accentColor;
  final Color shadowColor;
  final Color textColor;
  final bool locked;
  final bool challenge;
  final bool finalNode;
  final bool active;

  Path _shard({
    required Offset center,
    required double angle,
    required double innerRadius,
    required double outerRadius,
    required double halfWidth,
  }) {
    final direction = Offset(math.cos(angle), math.sin(angle));
    final normal = Offset(-direction.dy, direction.dx);
    final base = center + direction * innerRadius;
    final tip = center + direction * outerRadius;
    return Path()
      ..moveTo(
        base.dx + normal.dx * halfWidth,
        base.dy + normal.dy * halfWidth,
      )
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(
        base.dx - normal.dx * halfWidth,
        base.dy - normal.dy * halfWidth,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.50, size.height * 0.49);
    final medallionRect = Rect.fromCenter(
      center: center,
      width: finalNode ? 38 : 36,
      height: finalNode ? 36 : 34,
    );
    final coreRect = medallionRect.deflate(finalNode ? 5.0 : 4.5);
    final baseOuterRadius = finalNode
        ? 21.5
        : challenge
        ? 20.5
        : 20.0;

    final shardShadowPaint = Paint()
      ..color = shadowColor.withValues(alpha: locked ? 0.48 : 0.66);
    final shardPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = rimColor.withValues(alpha: locked ? 0.46 : 0.84);
    final shardEdgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65
      ..strokeJoin = StrokeJoin.round
      ..color = textColor.withValues(alpha: locked ? 0.10 : 0.26);

    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + (math.pi * 2 * i / 8);
      final horizontalFinal = finalNode && (i == 2 || i == 6);
      final outerRadius = horizontalFinal ? 24.0 : baseOuterRadius;
      final shard = _shard(
        center: center,
        angle: angle,
        innerRadius: finalNode ? 17.2 : 16.4,
        outerRadius: outerRadius,
        halfWidth: finalNode ? 2.5 : 2.1,
      );
      canvas.drawPath(shard.shift(const Offset(0.8, 1.4)), shardShadowPaint);
      final useChallengeGold = challenge && !locked && i.isEven;
      canvas.drawPath(
        shard,
        useChallengeGold
            ? (Paint()
                ..color = accentColor.withValues(alpha: active ? 0.92 : 0.76))
            : shardPaint,
      );
      canvas.drawPath(shard, shardEdgePaint);
    }

    canvas.drawOval(
      medallionRect.shift(const Offset(1.1, 2.0)),
      Paint()..color = shadowColor.withValues(alpha: locked ? 0.62 : 0.82),
    );

    final mineralBase = Color.alphaBlend(
      Colors.black.withValues(alpha: locked ? 0.28 : 0.18),
      fillColor,
    );
    canvas.drawOval(medallionRect, Paint()..color = mineralBase);
    canvas.drawOval(
      medallionRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = finalNode
            ? 3.4
            : challenge
            ? 2.8
            : 2.5
        ..color = rimColor.withValues(alpha: locked ? 0.70 : 0.96),
    );

    if (finalNode) {
      canvas.drawOval(
        medallionRect.deflate(2.6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.25
          ..color = innerRimColor.withValues(alpha: locked ? 0.52 : 0.94),
      );
    }

    final light = Color.alphaBlend(
      textColor.withValues(alpha: locked ? 0.06 : 0.22),
      fillColor,
    );
    final dark = Color.alphaBlend(
      Colors.black.withValues(alpha: locked ? 0.44 : 0.30),
      fillColor,
    );
    canvas.drawOval(
      coreRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.34, -0.40),
          radius: 1.0,
          colors: <Color>[light, fillColor, dark],
          stops: const <double>[0.0, 0.54, 1.0],
        ).createShader(coreRect),
    );

    final corePath = Path()..addOval(coreRect);
    canvas.save();
    canvas.clipPath(corePath);
    final c = coreRect.center;
    final top = Offset(c.dx, coreRect.top);
    final right = Offset(coreRect.right, c.dy);
    final bottom = Offset(c.dx, coreRect.bottom);
    final left = Offset(coreRect.left, c.dy);
    final facetPlanes = <(Path, Color)>[
      (
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(left.dx, left.dy)
          ..lineTo(coreRect.left + coreRect.width * 0.22, coreRect.top)
          ..lineTo(top.dx, top.dy)
          ..close(),
        textColor.withValues(alpha: locked ? 0.025 : 0.10),
      ),
      (
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(top.dx, top.dy)
          ..lineTo(coreRect.right - coreRect.width * 0.18, coreRect.top + 1)
          ..lineTo(right.dx, right.dy)
          ..close(),
        innerRimColor.withValues(alpha: locked ? 0.035 : 0.12),
      ),
      (
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(right.dx, right.dy)
          ..lineTo(coreRect.right - coreRect.width * 0.18, coreRect.bottom - 1)
          ..lineTo(bottom.dx, bottom.dy)
          ..close(),
        Colors.black.withValues(alpha: locked ? 0.12 : 0.08),
      ),
      (
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(bottom.dx, bottom.dy)
          ..lineTo(coreRect.left + coreRect.width * 0.18, coreRect.bottom - 1)
          ..lineTo(left.dx, left.dy)
          ..close(),
        rimColor.withValues(alpha: locked ? 0.025 : 0.07),
      ),
    ];
    for (final plane in facetPlanes) {
      canvas.drawPath(plane.$1, Paint()..color = plane.$2);
    }
    canvas.restore();

    canvas.drawOval(
      coreRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = finalNode ? 1.35 : 1.05
        ..color = innerRimColor.withValues(alpha: locked ? 0.40 : 0.82),
    );

    final facetLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65
      ..strokeCap = StrokeCap.round
      ..color = textColor.withValues(alpha: locked ? 0.08 : 0.20);
    canvas.drawLine(coreRect.topLeft + const Offset(4, 3), c, facetLine);
    canvas.drawLine(coreRect.topRight + const Offset(-4, 3), c, facetLine);
    canvas.drawLine(c, coreRect.bottomRight + const Offset(-4, -3), facetLine);
    canvas.drawLine(c, coreRect.bottomLeft + const Offset(4, -3), facetLine);

    canvas.drawArc(
      coreRect.deflate(1.2),
      math.pi * 1.05,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round
        ..color = textColor.withValues(alpha: locked ? 0.10 : 0.34),
    );

    if (challenge && !locked) {
      final studPaint = Paint()
        ..color = accentColor.withValues(alpha: active ? 0.96 : 0.78);
      for (final point in <Offset>[
        Offset(center.dx, medallionRect.top + 1.4),
        Offset(medallionRect.right - 1.4, center.dy),
        Offset(center.dx, medallionRect.bottom - 1.4),
        Offset(medallionRect.left + 1.4, center.dy),
      ]) {
        canvas.drawCircle(point, 1.05, studPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FacetedCrystalNodePainter old) =>
      old.fillColor != fillColor ||
      old.rimColor != rimColor ||
      old.innerRimColor != innerRimColor ||
      old.accentColor != accentColor ||
      old.shadowColor != shadowColor ||
      old.textColor != textColor ||
      old.locked != locked ||
      old.challenge != challenge ||
      old.finalNode != finalNode ||
      old.active != active;
}

class _CrystalFinalCrestPainter extends CustomPainter {
  const _CrystalFinalCrestPainter({
    required this.crystalColor,
    required this.edgeColor,
    required this.accentColor,
    required this.shadowColor,
    required this.active,
  });

  final Color crystalColor;
  final Color edgeColor;
  final Color accentColor;
  final Color shadowColor;
  final bool active;

  Path _prism({
    required Size size,
    required double centerX,
    required double tipY,
    required double baseLeft,
    required double baseRight,
    required double shoulderY,
  }) {
    final shoulderHalf = (baseRight - baseLeft) * 0.28;
    final cx = size.width * centerX;
    return Path()
      ..moveTo(size.width * baseLeft, size.height * 0.84)
      ..lineTo(
        cx - size.width * shoulderHalf,
        size.height * shoulderY,
      )
      ..lineTo(cx, size.height * tipY)
      ..lineTo(
        cx + size.width * shoulderHalf,
        size.height * shoulderY,
      )
      ..lineTo(size.width * baseRight, size.height * 0.84)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final prisms = <Path>[
      _prism(
        size: size,
        centerX: .15,
        tipY: .47,
        baseLeft: .07,
        baseRight: .27,
        shoulderY: .62,
      ),
      _prism(
        size: size,
        centerX: .33,
        tipY: .22,
        baseLeft: .22,
        baseRight: .44,
        shoulderY: .47,
      ),
      _prism(
        size: size,
        centerX: .50,
        tipY: .02,
        baseLeft: .38,
        baseRight: .62,
        shoulderY: .38,
      ),
      _prism(
        size: size,
        centerX: .67,
        tipY: .22,
        baseLeft: .56,
        baseRight: .78,
        shoulderY: .47,
      ),
      _prism(
        size: size,
        centerX: .85,
        tipY: .47,
        baseLeft: .73,
        baseRight: .93,
        shoulderY: .62,
      ),
    ];

    final crystalPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color.alphaBlend(
            Colors.white.withValues(alpha: active ? .24 : .08),
            crystalColor,
          ),
          crystalColor,
          Color.alphaBlend(
            Colors.black.withValues(alpha: active ? .18 : .30),
            crystalColor,
          ),
        ],
        stops: const <double>[0, .52, 1],
      ).createShader(Offset.zero & size);
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 1.35 : 1.05
      ..strokeJoin = StrokeJoin.round
      ..color = edgeColor.withValues(alpha: active ? .98 : .72);

    for (final prism in prisms) {
      canvas.drawPath(
        prism.shift(const Offset(0.8, 1.35)),
        Paint()..color = shadowColor.withValues(alpha: active ? .78 : .62),
      );
      canvas.drawPath(prism, crystalPaint);
      canvas.drawPath(prism, edgePaint);
    }

    final facetPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.62
      ..strokeCap = StrokeCap.round
      ..color = active
          ? accentColor.withValues(alpha: .58)
          : edgeColor.withValues(alpha: .24);
    final prismCenters = <(double, double, double)>[
      (.15, .47, .17),
      (.33, .22, .33),
      (.50, .02, .50),
      (.67, .22, .67),
      (.85, .47, .83),
    ];
    for (final p in prismCenters) {
      canvas.drawLine(
        Offset(size.width * p.$1, size.height * p.$2),
        Offset(size.width * p.$3, size.height * .80),
        facetPaint,
      );
    }

    final setting = Path()
      ..moveTo(size.width * .11, size.height * .80)
      ..quadraticBezierTo(
        size.width * .50,
        size.height * 1.00,
        size.width * .89,
        size.height * .80,
      );
    canvas.drawPath(
      setting,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = active ? 2.0 : 1.55
        ..strokeCap = StrokeCap.round
        ..color = edgeColor.withValues(alpha: active ? .94 : .64),
    );
    final innerSetting = Path()
      ..moveTo(size.width * .22, size.height * .82)
      ..quadraticBezierTo(
        size.width * .50,
        size.height * .93,
        size.width * .78,
        size.height * .82,
      );
    canvas.drawPath(
      innerSetting,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..strokeCap = StrokeCap.round
        ..color = accentColor.withValues(alpha: active ? .76 : .28),
    );

    final gemCenter = Offset(size.width * .50, size.height * .82);
    final gem = Path()
      ..moveTo(gemCenter.dx, gemCenter.dy - 2.2)
      ..lineTo(gemCenter.dx + 2.2, gemCenter.dy)
      ..lineTo(gemCenter.dx, gemCenter.dy + 2.2)
      ..lineTo(gemCenter.dx - 2.2, gemCenter.dy)
      ..close();
    canvas.drawPath(
      gem,
      Paint()..color = accentColor.withValues(alpha: active ? .92 : .42),
    );
    canvas.drawPath(
      gem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7
        ..color = edgeColor.withValues(alpha: active ? .96 : .62),
    );
  }

  @override
  bool shouldRepaint(covariant _CrystalFinalCrestPainter old) =>
      old.crystalColor != crystalColor ||
      old.edgeColor != edgeColor ||
      old.accentColor != accentColor ||
      old.shadowColor != shadowColor ||
      old.active != active;
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
      ..color = theme.lockedPathColor.withValues(alpha: artworkMode ? 0.48 : 1)
      ..style = PaintingStyle.fill;
    final stoneHighlightPaint = Paint()
      ..color = theme.textColor.withValues(alpha: artworkMode ? 0.12 : 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = artworkMode ? 0.7 : 1.2;

    for (
      var index = 0;
      index < WordHuntRouteMapGeometry.connections.length;
      index++
    ) {
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

    final midpoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
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
