import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_path_renderer.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_chrome_theme.dart';
import 'word_hunt_route_map_decoration.dart';
import 'word_hunt_route_segment_host.dart';
import 'word_hunt_seal_renderer.dart';

/// Kelime Avı'nın bütün 10-bölümlük rotaları için tek geometri sözleşmesi.
///
/// Bu sınıf bilerek rota kimliği, asset yolu veya tema bilgisi içermez. Yeni bir
/// rota eklemek bu koordinatları değiştirmemeli; rota farkları yalnız tema ve
/// içerik verisinden gelmelidir.
enum WordHuntRoutePresentationOrder { forward, reverse }

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

  static List<Offset> pointsFor(
    Size size, {
    WordHuntRoutePresentationOrder presentationOrder =
        WordHuntRoutePresentationOrder.forward,
  }) {
    final points = normalizedStops
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList(growable: false);
    return presentationOrder == WordHuntRoutePresentationOrder.forward
        ? points
        : points.reversed.toList(growable: false);
  }
}

enum WordHuntRouteNodeVisualStyle { scenicWood, facetedCrystal }

/// facetedCrystal skin'in owner-approved görsel hiyerarşi metrikleri.
/// Hitbox ve canonical node merkezleri bu değerlerden etkilenmez.
abstract final class WordHuntFacetedCrystalMetrics {
  static const double normalScale = 1.00;
  static const double challengeScale = 1.06;
  static const double finalScale = 1.11;

  // 411 px proof'ta okunabilir gerçek çizim footprint'leri. Hitbox sabittir.
  static const double normalBodyWidth = 48;
  static const double normalBodyHeight = 46;
  static const double normalShardSilhouette = 58;
  static const double finalBodyWidth = 52;
  static const double finalBodyHeight = 50;
  static const double finalShardSilhouette = 62;
  static const double finalCrestWidth = 52;
  static const double finalCrestHeight = 32;
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
    this.sealSpec,
    this.pathSpec,
    this.chromeTheme,
    this.presentationOrder = WordHuntRoutePresentationOrder.forward,
    this.segmentIndex = 1,
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
  final WordHuntSealVisualSpec? sealSpec;
  final WordHuntPathVisualSpec? pathSpec;
  final WordHuntRouteChromeTheme? chromeTheme;
  final WordHuntRoutePresentationOrder presentationOrder;
  final int segmentIndex;

  // Hitbox sözleşmesi değişmez. Scenic skin yalnız bu kutunun içindeki görsel
  // medalyonu küçültür; test/tap geometrisi aynı kalır.
  static const double _nodeDiameter = 54;
  static const double _nodeBoxWidth = 86;
  static const double _nodeBoxHeight = 82;

  @override
  Widget build(BuildContext context) {
    final host = WordHuntRouteSegmentHost.forRoute(
      route: route,
      progress: progress,
      segmentIndex: segmentIndex,
    );
    final stars = WordHuntRouteProgressEngine.totalStars(route, progress);
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
                chromeTheme: chromeTheme,
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
                    final points = WordHuntRouteMapGeometry.pointsFor(
                      size,
                      presentationOrder: presentationOrder,
                    );
                    final unlocked = host.nodes
                        .map((node) => node.unlocked)
                        .toList(growable: false);
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
                                painter: pathSpec == null
                                    ? _ReusableRoutePathPainter(
                                        points: points,
                                        unlocked: unlocked,
                                        theme: theme,
                                      )
                                    : WordHuntPathPainter(
                                        segments: _pathSegments(
                                          points: points,
                                          unlocked: unlocked,
                                        ),
                                        spec: pathSpec!,
                                      ),
                              ),
                            ),
                            for (var index = 0; index < 10; index++)
                              _positionNode(
                                point: points[index],
                                node: host.nodes[index],
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

  List<WordHuntPathSegment> _pathSegments({
    required List<Offset> points,
    required List<bool> unlocked,
  }) {
    return WordHuntRouteMapGeometry.connections
        .map(
          (connection) {
            final destination = WordHuntRouteSegmentHost.forRoute(
              route: route,
              progress: progress,
              segmentIndex: segmentIndex,
            ).nodes[connection.$2 - 1];
            final approach = destination.isTrueRouteFinal
                ? WordHuntPathApproach.finalNode
                : switch (destination.gameplayType) {
                    WordHuntLevelType.challenge =>
                      WordHuntPathApproach.challenge,
                    WordHuntLevelType.normal ||
                    WordHuntLevelType.bonus ||
                    WordHuntLevelType.routeFinal =>
                      WordHuntPathApproach.normal,
                  };
            return WordHuntPathSegment(
              start: points[connection.$1 - 1],
              end: points[connection.$2 - 1],
              active: unlocked[connection.$2 - 1],
              approach: approach,
            );
          },
        )
        .toList(growable: false);
  }

  Widget _positionNode({
    required Offset point,
    required WordHuntRouteMapNodeProjection node,
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
        key: Key('word_hunt_reusable_level_${node.absoluteLevelIndex}'),
        level: node.level,
        unlocked: node.unlocked,
        completed: node.completed,
        current: node.current,
        theme: theme,
        sealSpec: sealSpec,
        onTap: node.unlocked && onLevelTap != null
            ? () => onLevelTap!(node.absoluteLevelIndex)
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
    this.chromeTheme,
    this.showBackButton = true,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final WordHuntRouteMapTheme theme;
  final WordHuntRouteChromeTheme? chromeTheme;
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
    final panelTop = chromeTheme == null
        ? scenic
              ? panelTopOpaque.withValues(alpha: 0.78)
              : panelTopOpaque
        : chromeTheme!.headerTint.withValues(alpha: scenic ? 0.90 : 1);
    final panelBottom = chromeTheme == null
        ? scenic
              ? panelBottomOpaque.withValues(alpha: 0.88)
              : panelBottomOpaque
        : chromeTheme!.surfaceTint.withValues(alpha: scenic ? 0.94 : 1);
    final edgeColor = chromeTheme == null
        ? scenic
              ? theme.accentColor.withValues(alpha: 0.38)
              : theme.accentColor.withValues(alpha: 0.62)
        : theme.accentColor.withValues(
            alpha: switch (chromeTheme!.materialFamily) {
              WordHuntChromeMaterialFamily.legacyGlass => 0.44,
              WordHuntChromeMaterialFamily.carvedStone => 0.56,
              WordHuntChromeMaterialFamily.engineeredMetal => 0.64,
              WordHuntChromeMaterialFamily.ceremonialStone => 0.60,
            },
          );
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
            key: const Key('word_hunt_reusable_route_header_panel'),
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
    this.sealSpec,
    this.onTap,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final bool completed;
  final bool current;
  final WordHuntRouteMapTheme theme;
  final WordHuntSealVisualSpec? sealSpec;
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
            if (sealSpec != null)
              _buildSealNode()
            else if (scenic)
              _buildScenicNode()
            else
              _buildOrbNode(),
            if (sealSpec == null &&
                completed &&
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
                height: sealSpec != null
                    ? 0
                    : completed
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

  Widget _buildSealNode() {
    final state = completed
        ? WordHuntSealNodeState.completed
        : current
        ? WordHuntSealNodeState.current
        : unlocked
        ? WordHuntSealNodeState.normal
        : WordHuntSealNodeState.locked;
    return KeyedSubtree(
      key: Key('word_hunt_reusable_node_${level.index}_$_visualState'),
      child: WordHuntSealNode(
        levelIndex: level.index,
        levelType: level.type,
        state: state,
        spec: sealSpec!,
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
            theme.nodeColor.withValues(alpha: 0.34),
            theme.lockedNodeColor,
          );
    final nodeCanvasWidth = isFinal ? 64.0 : 60.0;
    final nodeCanvasHeight = isFinal ? 60.0 : 58.0;

    return SizedBox(
      key: Key('word_hunt_reusable_node_${level.index}_$_visualState'),
      width: 72,
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
                              .withValues(alpha: isFinal ? 0.24 : 0.15),
                      blurRadius: isFinal ? 13 : 8,
                      spreadRadius: isFinal ? 0.35 : 0,
                    ),
                  ],
                ),
              ),
            ),
          Transform.scale(
            scale: scale,
            child: SizedBox(
              key: Key('word_hunt_faceted_node_${level.index}'),
              width: nodeCanvasWidth,
              height: nodeCanvasHeight,
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
                              alpha: unlocked ? 0.28 : 0.22,
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
                    alignment: Alignment(0, completed ? -0.10 : -0.02),
                    child: Text(
                      '${level.index}',
                      key: Key('word_hunt_faceted_number_${level.index}'),
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: isFinal ? 18 : 17.5,
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
                      bottom: 2,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 15,
                          child: CustomPaint(
                            key: Key('word_hunt_faceted_lock_${level.index}'),
                            painter: _CrystalLockBadgePainter(
                              fillColor: crystalFill,
                              edgeColor: theme.lockedPathColor,
                              shadowColor: theme.nodeShadowColor,
                            ),
                            child: Icon(
                              Icons.lock_rounded,
                              size: 9,
                              color: theme.textColor.withValues(alpha: 0.86),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (completed)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -1,
                      child: Center(
                        child: Container(
                          key: Key('word_hunt_faceted_stars_${level.index}'),
                          width: 31,
                          height: 10,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.nodeShadowColor.withValues(
                              alpha: 0.56,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.accentColor.withValues(alpha: 0.52),
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(
                              3,
                              (_) => Icon(
                                Icons.star_rounded,
                                size: 8,
                                color: theme.accentColor.withValues(
                                  alpha: 0.96,
                                ),
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
              top: -24,
              width: WordHuntFacetedCrystalMetrics.finalCrestWidth,
              height: WordHuntFacetedCrystalMetrics.finalCrestHeight,
              child: CustomPaint(
                key: const Key('word_hunt_faceted_final_crest'),
                painter: _CrystalFinalCrestPainter(
                  crystalColor: activeFinal ? theme.nodeColor : crystalFill,
                  edgeColor: activeFinal
                      ? theme.resolvedFinalAccentColor
                      : theme.lockedPathColor,
                  accentColor: activeFinal
                      ? theme.pathColor
                      : theme.lockedPathColor.withValues(alpha: 0.70),
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

  Path _gemPath(Rect rect) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final left = rect.left;
    final right = rect.right;
    final top = rect.top;
    final bottom = rect.bottom;
    return Path()
      ..moveTo(cx, top)
      ..lineTo(right - rect.width * 0.18, top + rect.height * 0.10)
      ..lineTo(right, cy - rect.height * 0.12)
      ..lineTo(right - rect.width * 0.05, cy + rect.height * 0.24)
      ..lineTo(cx + rect.width * 0.26, bottom)
      ..lineTo(cx - rect.width * 0.26, bottom)
      ..lineTo(left + rect.width * 0.05, cy + rect.height * 0.24)
      ..lineTo(left, cy - rect.height * 0.12)
      ..lineTo(left + rect.width * 0.18, top + rect.height * 0.10)
      ..close();
  }

  Path _shardPath(
    Offset center,
    double angle,
    double innerRadius,
    double outerRadius,
    double halfWidth,
  ) {
    final direction = Offset(math.cos(angle), math.sin(angle));
    final perpendicular = Offset(-direction.dy, direction.dx);
    final base = center + direction * innerRadius;
    final shoulder = center + direction * (outerRadius - 6.5);
    final tip = center + direction * outerRadius;
    return Path()
      ..moveTo(
        base.dx + perpendicular.dx * halfWidth,
        base.dy + perpendicular.dy * halfWidth,
      )
      ..lineTo(
        shoulder.dx + perpendicular.dx * halfWidth * 0.42,
        shoulder.dy + perpendicular.dy * halfWidth * 0.42,
      )
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(
        shoulder.dx - perpendicular.dx * halfWidth * 0.42,
        shoulder.dy - perpendicular.dy * halfWidth * 0.42,
      )
      ..lineTo(
        base.dx - perpendicular.dx * halfWidth,
        base.dy - perpendicular.dy * halfWidth,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.50, size.height * 0.49);
    final bodyWidth = finalNode
        ? WordHuntFacetedCrystalMetrics.finalBodyWidth
        : WordHuntFacetedCrystalMetrics.normalBodyWidth;
    final bodyHeight = finalNode
        ? WordHuntFacetedCrystalMetrics.finalBodyHeight
        : WordHuntFacetedCrystalMetrics.normalBodyHeight;
    final shardSilhouette = finalNode
        ? WordHuntFacetedCrystalMetrics.finalShardSilhouette
        : WordHuntFacetedCrystalMetrics.normalShardSilhouette;
    final bodyRect = Rect.fromCenter(
      center: center,
      width: bodyWidth,
      height: bodyHeight,
    );
    final bodyPath = _gemPath(bodyRect);
    final innerRadius = math.min(bodyWidth, bodyHeight) * 0.39;
    final outerRadius = shardSilhouette * 0.50;
    final shardHalfWidth = finalNode ? 6.2 : 5.4;

    final shadowPath = bodyPath.shift(const Offset(1.4, 2.4));
    canvas.drawPath(
      shadowPath,
      Paint()..color = shadowColor.withValues(alpha: locked ? 0.62 : 0.84),
    );

    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final shard = _shardPath(
        center,
        angle,
        innerRadius,
        outerRadius,
        shardHalfWidth,
      );
      final goldShard = challenge && !locked && (i == 0 || i == 2 || i == 4);
      final shardColor = goldShard ? accentColor : rimColor;
      canvas.drawPath(
        shard,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.alphaBlend(
                textColor.withValues(alpha: locked ? 0.04 : 0.14),
                shardColor,
              ),
              shardColor.withValues(alpha: locked ? 0.70 : 0.92),
            ],
          ).createShader(shard.getBounds()),
      );
      canvas.drawPath(
        shard,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = finalNode ? 1.35 : 1.15
          ..strokeJoin = StrokeJoin.round
          ..color = innerRimColor.withValues(alpha: locked ? 0.46 : 0.72),
      );
    }

    final mineralBase = Color.alphaBlend(
      Colors.black.withValues(alpha: locked ? 0.32 : 0.18),
      fillColor,
    );
    canvas.drawPath(bodyPath, Paint()..color = mineralBase);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.30, -0.32),
          radius: 0.95,
          colors: <Color>[
            Color.alphaBlend(
              textColor.withValues(alpha: locked ? 0.06 : 0.20),
              fillColor,
            ),
            fillColor,
            Color.alphaBlend(
              Colors.black.withValues(alpha: locked ? 0.36 : 0.24),
              fillColor,
            ),
          ],
          stops: const <double>[0.0, 0.52, 1.0],
        ).createShader(bodyRect),
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = finalNode
            ? 3.6
            : challenge
            ? 3.1
            : 2.9
        ..strokeJoin = StrokeJoin.round
        ..color = rimColor.withValues(alpha: locked ? 0.76 : 0.98),
    );

    final innerRect = bodyRect.deflate(finalNode ? 5.0 : 4.5);
    canvas.drawPath(
      _gemPath(innerRect),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = finalNode ? 2.0 : 1.7
        ..strokeJoin = StrokeJoin.round
        ..color = innerRimColor.withValues(alpha: locked ? 0.60 : 0.92),
    );
    if (finalNode) {
      canvas.drawPath(
        _gemPath(bodyRect.inflate(2.2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeJoin = StrokeJoin.round
          ..color = rimColor.withValues(alpha: locked ? 0.50 : 0.86),
      );
    }

    canvas.save();
    canvas.clipPath(bodyPath);
    final top = Offset(center.dx, bodyRect.top);
    final left = Offset(bodyRect.left, center.dy - bodyHeight * 0.10);
    final right = Offset(bodyRect.right, center.dy - bodyHeight * 0.10);
    final bottom = Offset(center.dx, bodyRect.bottom);
    final centerPoint = Offset(center.dx, center.dy + 1);

    final leftPlane = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(centerPoint.dx, centerPoint.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(
        bodyRect.left + bodyWidth * 0.20,
        bodyRect.top + bodyHeight * 0.12,
      )
      ..close();
    canvas.drawPath(
      leftPlane,
      Paint()..color = textColor.withValues(alpha: locked ? 0.045 : 0.13),
    );

    final rightPlane = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(
        bodyRect.right - bodyWidth * 0.18,
        bodyRect.top + bodyHeight * 0.12,
      )
      ..lineTo(right.dx, right.dy)
      ..lineTo(centerPoint.dx, centerPoint.dy)
      ..close();
    canvas.drawPath(
      rightPlane,
      Paint()..color = innerRimColor.withValues(alpha: locked ? 0.04 : 0.10),
    );

    final bottomPlane = Path()
      ..moveTo(left.dx, left.dy)
      ..lineTo(centerPoint.dx, centerPoint.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..close();
    canvas.drawPath(
      bottomPlane,
      Paint()..color = Colors.black.withValues(alpha: locked ? 0.16 : 0.10),
    );
    canvas.restore();

    final highlight = Path()
      ..moveTo(
        bodyRect.left + bodyWidth * 0.18,
        bodyRect.top + bodyHeight * 0.18,
      )
      ..quadraticBezierTo(
        center.dx,
        bodyRect.top - 1,
        bodyRect.right - bodyWidth * 0.18,
        bodyRect.top + bodyHeight * 0.16,
      );
    canvas.drawPath(
      highlight,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.45
        ..strokeCap = StrokeCap.round
        ..color = textColor.withValues(alpha: locked ? 0.16 : 0.34),
    );
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

class _CrystalLockBadgePainter extends CustomPainter {
  const _CrystalLockBadgePainter({
    required this.fillColor,
    required this.edgeColor,
    required this.shadowColor,
  });

  final Color fillColor;
  final Color edgeColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.22, 1)
      ..lineTo(size.width * 0.78, 1)
      ..lineTo(size.width - 1, size.height * 0.34)
      ..lineTo(size.width * 0.86, size.height - 1)
      ..lineTo(size.width * 0.14, size.height - 1)
      ..lineTo(1, size.height * 0.34)
      ..close();
    canvas.drawPath(
      path.shift(const Offset(0.7, 1.0)),
      Paint()..color = shadowColor.withValues(alpha: 0.78),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.alphaBlend(edgeColor.withValues(alpha: 0.18), fillColor),
            Color.alphaBlend(Colors.black.withValues(alpha: 0.28), fillColor),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = edgeColor.withValues(alpha: 0.84),
    );
  }

  @override
  bool shouldRepaint(covariant _CrystalLockBadgePainter old) =>
      old.fillColor != fillColor ||
      old.edgeColor != edgeColor ||
      old.shadowColor != shadowColor;
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

  Path _prism(double cx, double baseY, double height, double width) {
    final top = baseY - height;
    return Path()
      ..moveTo(cx, top)
      ..lineTo(cx + width * 0.50, top + height * 0.24)
      ..lineTo(cx + width * 0.38, baseY)
      ..lineTo(cx - width * 0.38, baseY)
      ..lineTo(cx - width * 0.50, top + height * 0.24)
      ..close();
  }

  void _paintPrism(
    Canvas canvas,
    Path prism,
    Rect bounds, {
    required bool centerPrism,
  }) {
    final fillBase = centerPrism
        ? crystalColor
        : Color.alphaBlend(
            accentColor.withValues(alpha: active ? 0.16 : 0.10),
            crystalColor,
          );
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color.alphaBlend(
            Colors.white.withValues(alpha: active ? 0.22 : 0.10),
            fillBase,
          ),
          fillBase,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.24), fillBase),
        ],
        stops: const <double>[0, 0.56, 1],
      ).createShader(bounds);
    canvas.drawPath(prism, fillPaint);
    canvas.drawPath(
      prism,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = centerPrism ? 1.45 : 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = edgeColor.withValues(alpha: active ? 0.98 : 0.82),
    );

    final top = Offset(bounds.center.dx, bounds.top);
    final base = Offset(bounds.center.dx, bounds.bottom - 0.5);
    canvas.drawLine(
      top,
      base,
      Paint()
        ..strokeWidth = 0.85
        ..color = accentColor.withValues(alpha: active ? 0.62 : 0.30),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height * 0.79;
    final prisms = <(Path, Rect, bool)>[];

    void addPrism(double cx, double height, double width, bool centerPrism) {
      final prism = _prism(cx, baseY, height, width);
      prisms.add((prism, prism.getBounds(), centerPrism));
    }

    addPrism(size.width * 0.50, 28, 13, true);
    addPrism(size.width * 0.30, 21, 11, false);
    addPrism(size.width * 0.70, 21, 11, false);
    addPrism(size.width * 0.14, 15, 9, false);
    addPrism(size.width * 0.86, 15, 9, false);

    final shadowPath = Path();
    for (final prism in prisms) {
      shadowPath.addPath(prism.$1, const Offset(1.0, 1.5));
    }
    canvas.drawPath(
      shadowPath,
      Paint()..color = shadowColor.withValues(alpha: active ? 0.82 : 0.68),
    );

    for (final prism in prisms) {
      _paintPrism(canvas, prism.$1, prism.$2, centerPrism: prism.$3);
    }

    final base = Path()
      ..moveTo(size.width * 0.07, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.91,
        size.width * 0.93,
        size.height * 0.75,
      )
      ..lineTo(size.width * 0.86, size.height * 0.95)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height,
        size.width * 0.14,
        size.height * 0.95,
      )
      ..close();
    canvas.drawPath(
      base,
      Paint()..color = edgeColor.withValues(alpha: active ? 0.92 : 0.76),
    );
    canvas.drawPath(
      base,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = accentColor.withValues(alpha: active ? 0.86 : 0.40),
    );

    final settingLine = Path()
      ..moveTo(size.width * 0.18, size.height * 0.81)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.91,
        size.width * 0.82,
        size.height * 0.81,
      );
    canvas.drawPath(
      settingLine,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round
        ..color = accentColor.withValues(alpha: active ? 0.82 : 0.36),
    );

    final gemCenter = Offset(size.width * 0.50, size.height * 0.84);
    final gem = Path()
      ..moveTo(gemCenter.dx, gemCenter.dy - 3.2)
      ..lineTo(gemCenter.dx + 3.2, gemCenter.dy)
      ..lineTo(gemCenter.dx, gemCenter.dy + 3.2)
      ..lineTo(gemCenter.dx - 3.2, gemCenter.dy)
      ..close();
    canvas.drawPath(
      gem,
      Paint()..color = accentColor.withValues(alpha: active ? 0.96 : 0.50),
    );
    canvas.drawPath(
      gem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = edgeColor.withValues(alpha: active ? 0.98 : 0.72),
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
