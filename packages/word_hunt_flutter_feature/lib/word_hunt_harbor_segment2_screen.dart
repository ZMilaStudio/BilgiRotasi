import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_harbor_layout_manifest.dart';
import 'word_hunt_harbor_segment_screen.dart';
import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_segment_host.dart';
import 'word_hunt_star_visuals.dart';

/// Segment 2 only. Art is reusable material; all progression is supplied by
/// the existing route host, never by the illustrative reference screenshot.
class WordHuntHarborSegment2Screen extends StatefulWidget {
  const WordHuntHarborSegment2Screen({
    super.key,
    required this.route,
    required this.progress,
    required this.furthestAccessibleSegment,
    this.onBack,
    this.onInfo,
    this.onLevelTap,
    this.onSegmentSelect,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final int furthestAccessibleSegment;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final ValueChanged<int>? onLevelTap;
  final ValueChanged<int>? onSegmentSelect;

  @override
  State<WordHuntHarborSegment2Screen> createState() =>
      _WordHuntHarborSegment2ScreenState();
}

class _WordHuntHarborSegment2ScreenState
    extends State<WordHuntHarborSegment2Screen> {
  static const _ui = 'assets/word_hunt/harbor_segments/segment_02_ui/';
  Future<HarborLayoutManifest>? _layout;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _layout ??= _loadLayout(DefaultAssetBundle.of(context));
  }

  Future<HarborLayoutManifest> _loadLayout(AssetBundle bundle) async {
    final json = await bundle.loadString('${_ui}layout_schema_v2.json');
    return HarborLayoutManifest.parseJson(
      json,
      resolveAsset:
          (path) =>
              path == WordHuntHarborSegmentArt.segment2
                  ? const HarborSceneAssetMetadata(
                    assetPath: WordHuntHarborSegmentArt.segment2,
                    width: 941,
                    height: 1672,
                    sha256: HarborLayoutManifest.segment2SceneSha256,
                  )
                  : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final host = WordHuntRouteSegmentHost.forRoute(
      route: widget.route,
      progress: widget.progress,
      segmentIndex: 2,
    );
    return Scaffold(
      key: const Key('word_hunt_harbor_segment_screen_2'),
      backgroundColor: const Color(0xFF071629),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _HarborPremiumHeader(
              title: widget.route.title,
              totalStars: WordHuntRouteProgressEngine.totalStars(
                widget.route,
                widget.progress,
              ),
              maximumStars: widget.route.maximumStars,
              onBack: widget.onBack,
              onInfo: widget.onInfo,
            ),
            Expanded(
              child: FutureBuilder<HarborLayoutManifest>(
                future: _layout,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Harita yerleşimi yüklenemedi',
                        key: Key('word_hunt_harbor_layout_error_2'),
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final manifest = snapshot.requireData;
                  final expected = <String>[
                    for (final node in host.nodes) node.level.id,
                  ];
                  final actual = <String>[
                    for (final node in manifest.nodes) node.levelId,
                  ];
                  if (expected.length != 10 ||
                      manifest.connections.length != 9 ||
                      !listEqualsExact(expected, actual)) {
                    return const Center(
                      child: Text(
                        'Harita bölüm kimliği uyuşmuyor',
                        key: Key('word_hunt_harbor_identity_error_2'),
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder:
                        (context, constraints) =>
                            _scene(manifest, host.nodes, constraints.biggest),
                  );
                },
              ),
            ),
            if (widget.onSegmentSelect != null)
              _HarborPremiumSegmentNavigation(
                selected: 2,
                available: widget.route.segments.length,
                furthestAccessible: widget.furthestAccessibleSegment,
                onSelect: widget.onSegmentSelect!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _scene(
    HarborLayoutManifest manifest,
    List<WordHuntRouteMapNodeProjection> nodes,
    Size viewport,
  ) {
    final transform = HarborLayoutManifest.sceneToViewportTransform(
      sceneWidth: manifest.scene.width.toDouble(),
      sceneHeight: manifest.scene.height.toDouble(),
      viewportWidth: viewport.width,
      viewportHeight: viewport.height,
    );
    Offset point(HarborLayoutPoint source) {
      final projected = transform.projectScene(source);
      return Offset(projected.x, projected.y);
    }

    final curves = <Path>[
      for (final edge in manifest.connections)
        Path()
          ..moveTo(point(edge.start).dx, point(edge.start).dy)
          ..cubicTo(
            point(edge.control1).dx,
            point(edge.control1).dy,
            point(edge.control2).dx,
            point(edge.control2).dy,
            point(edge.end).dx,
            point(edge.end).dy,
          ),
    ];
    final sceneWidth = manifest.scene.width * transform.scale;
    final sceneHeight = manifest.scene.height * transform.scale;
    final lanterns = <Widget>[];
    for (final (edgeIndex, fraction) in const <(int, double)>[
      (1, .50),
      (4, .47),
      (5, .53),
      (6, .55),
      (7, .53),
      (8, .52),
    ]) {
      final metric = curves[edgeIndex].computeMetrics().first;
      final tangent = metric.getTangentForOffset(metric.length * fraction);
      if (tangent == null) continue;
      lanterns.add(
        Positioned(
          left: tangent.position.dx - 9,
          top: tangent.position.dy + 1,
          width: 18,
          height: 27,
          child: IgnorePointer(
            child: Image.asset(
              '${_ui}hanging_lantern.png',
              key: Key('word_hunt_harbor_lantern_${edgeIndex + 1}_2'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    return ClipRect(
      key: const Key('word_hunt_harbor_scene_2'),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            left: transform.translationX,
            top: transform.translationY,
            width: sceneWidth,
            height: sceneHeight,
            child: Image.asset(
              manifest.scene.assetPath,
              key: const Key('word_hunt_harbor_scene_asset_2'),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                key: const Key('word_hunt_harbor_path_2'),
                painter: HarborRopePainter(curves),
              ),
            ),
          ),
          ...lanterns,
          for (var index = 0; index < nodes.length; index++)
            _positionedNode(
              manifest.nodes[index],
              nodes[index],
              point(manifest.nodes[index].center),
            ),
        ],
      ),
    );
  }

  Widget _positionedNode(
    HarborLayoutNode layout,
    WordHuntRouteMapNodeProjection node,
    Offset center,
  ) {
    final number = node.absoluteLevelIndex;
    return Positioned(
      left: center.dx - 34,
      top: center.dy - 34,
      width: 68,
      height: 68,
      child: _HarborPremiumNode(
        node: node,
        earned: widget.progress.starsFor(node.level.id),
        starOffset: Offset(layout.starAnchor.x, layout.starAnchor.y),
        challengeOffset:
            layout.challengeAnchor == null
                ? null
                : Offset(layout.challengeAnchor!.x, layout.challengeAnchor!.y),
        onTap:
            node.unlocked && widget.onLevelTap != null
                ? () => widget.onLevelTap!(number)
                : null,
      ),
    );
  }
}

bool listEqualsExact(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _HarborPremiumNode extends StatelessWidget {
  const _HarborPremiumNode({
    required this.node,
    required this.earned,
    required this.starOffset,
    required this.challengeOffset,
    this.onTap,
  });

  static const _ui = 'assets/word_hunt/harbor_segments/segment_02_ui/';
  final WordHuntRouteMapNodeProjection node;
  // Brown interior measured in the approved 1252x1203 combined artwork,
  // excluding the gold border, bolts and transparent margins. The manifest's
  // separate-badge anchor is not the text anchor of this combined artwork.
  static const _challengeAssetSize = Size(1252, 1203);
  static const _challengePaintedInterior = Rect.fromLTRB(160, 865, 1092, 1055);
  final int earned;
  final Offset starOffset;
  final Offset? challengeOffset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final number = node.absoluteLevelIndex;
    final challenge = node.gameplayType == WordHuntLevelType.challenge;
    final locked = !node.unlocked;
    final visual =
        locked
            ? 'locked_medallion.png'
            : challenge
            ? 'challenge_combined_blank.png'
            : 'medallion_blank.png';
    final visualWidth =
        locked
            ? 50.0
            : challenge
            ? 107.0
            : 62.0;
    final visualHeight =
        locked
            ? 53.0
            : challenge
            ? 96.0
            : 65.0;
    final visualDy = challenge && !locked ? 24.0 : 0.0;
    final artworkOrigin = Offset(
      34 - visualWidth / 2,
      34 + visualDy - visualHeight / 2,
    );
    final plaqueScaleX = visualWidth / _challengeAssetSize.width;
    final plaqueScaleY = visualHeight / _challengeAssetSize.height;
    final plaqueInterior = Rect.fromLTWH(
      artworkOrigin.dx + _challengePaintedInterior.left * plaqueScaleX,
      artworkOrigin.dy + _challengePaintedInterior.top * plaqueScaleY,
      _challengePaintedInterior.width * plaqueScaleX,
      _challengePaintedInterior.height * plaqueScaleY,
    );
    return Semantics(
      button: node.unlocked,
      enabled: node.unlocked,
      label:
          'Bölüm $number, ${challenge ? 'meydan okuma, ' : ''}'
          '${locked ? 'kilitli' : 'açık'}, $earned yıldız',
      child: GestureDetector(
        key: Key('word_hunt_harbor_level_$number'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            if (node.current && !locked)
              Positioned(
                left: 34 - visualWidth / 2,
                top: 34 + visualDy - visualWidth / 2,
                width: visualWidth,
                height: visualWidth,
                child: IgnorePointer(
                  child: DecoratedBox(
                    key: Key('word_hunt_harbor_current_glow_$number'),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: Color(0x66F4C66B), blurRadius: 10),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 34 - visualWidth / 2,
              top: 34 + visualDy - visualHeight / 2,
              width: visualWidth,
              height: visualHeight,
              child: Image.asset(
                '$_ui$visual',
                key: Key('word_hunt_harbor_medallion_$number'),
                fit: BoxFit.fill,
              ),
            ),
            if (!locked)
              Positioned(
                left: 4,
                top: challenge ? 35 : 19,
                width: 60,
                height: 30,
                child: Center(
                  child: Text(
                    '$number',
                    key: Key('word_hunt_harbor_number_$number'),
                    style: TextStyle(
                      color: const Color(0xFFFFE5A6),
                      fontFamily: 'serif',
                      fontSize: challenge ? 25 : 23,
                      fontWeight: FontWeight.bold,
                      shadows: const <Shadow>[
                        Shadow(color: Color(0xFF1F1B19), blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
            if (!locked)
              Positioned(
                left: 34 + starOffset.dx - 32.5,
                // The combined challenge artwork already contains its plaque.
                // Keep earned stars below that artwork, not over its caption.
                top:
                    challenge
                        ? artworkOrigin.dy + visualHeight + 2
                        : 34 + starOffset.dy - 12,
                width: 65,
                height: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Image.asset(
                      '${_ui}star_socket_blank.png',
                      key: Key('word_hunt_harbor_star_backplate_$number'),
                      fit: BoxFit.fill,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        3,
                        (i) => Icon(
                          Icons.star_rounded,
                          key: Key('word_hunt_harbor_star_${number}_$i'),
                          size: 17,
                          color:
                              i < earned
                                  ? WordHuntStarVisuals.filled
                                  : WordHuntStarVisuals.empty,
                          shadows:
                              i < earned
                                  ? const <Shadow>[
                                    Shadow(
                                      color: Color(0xD9EBA82D),
                                      blurRadius: 2,
                                    ),
                                  ]
                                  : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (challenge && !locked && challengeOffset != null)
              Positioned.fromRect(
                rect: plaqueInterior,
                child: SizedBox(
                  key: Key('word_hunt_harbor_challenge_$number'),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Meydan Okuma',
                        maxLines: 1,
                        style: const TextStyle(
                          color: Color(0xFFFFE5A6),
                          fontFamily: 'serif',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(color: Colors.black, blurRadius: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HarborRopePainter extends CustomPainter {
  const HarborRopePainter(this.curves);
  final List<Path> curves;

  @override
  void paint(Canvas canvas, Size size) {
    for (final curve in curves) {
      for (final (color, width) in const <(Color, double)>[
        (Color(0xE6231309), 5.6),
        (Color(0xFF8E5C2B), 4.5),
        (Color(0xF5E7B960), 2.0),
        (Color(0xB4FFDC8E), .6),
      ]) {
        canvas.drawPath(
          curve,
          Paint()
            ..color = color
            ..strokeWidth = width
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
      }
      for (final metric in curve.computeMetrics()) {
        for (var distance = 5.0; distance < metric.length - 5; distance += 7) {
          final tangent = metric.getTangentForOffset(distance);
          if (tangent == null) continue;
          final normal = Offset(
            -math.sin(tangent.angle),
            math.cos(tangent.angle),
          );
          final p = tangent.position;
          canvas.drawLine(
            p - normal * 1.7,
            p + normal * 1.7,
            Paint()
              ..color = const Color(0xA6593415)
              ..strokeWidth = .8,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant HarborRopePainter oldDelegate) =>
      oldDelegate.curves != curves;
}

class _HarborPremiumHeader extends StatelessWidget {
  const _HarborPremiumHeader({
    required this.title,
    required this.totalStars,
    required this.maximumStars,
    this.onBack,
    this.onInfo,
  });
  final String title;
  final int totalStars;
  final int maximumStars;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) => Container(
    height: 66,
    color: const Color(0xFF05192A),
    child: Stack(
      children: <Widget>[
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title.toUpperCase(),
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8E7BF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'AÇIK DENİZ GEÇİDİ · $totalStars / $maximumStars ★',
                style: const TextStyle(fontSize: 9, color: Color(0xFFDCBA78)),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            key: const Key('word_hunt_harbor_back'),
            tooltip: 'Haritadan çık',
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFF2BB64),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            key: const Key('word_hunt_harbor_info'),
            tooltip: 'Bilgi',
            onPressed: onInfo,
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFF2BB64),
            ),
          ),
        ),
      ],
    ),
  );
}

class _HarborPremiumSegmentNavigation extends StatelessWidget {
  const _HarborPremiumSegmentNavigation({
    required this.selected,
    required this.available,
    required this.furthestAccessible,
    required this.onSelect,
  });
  final int selected;
  final int available;
  final int furthestAccessible;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('word_hunt_harbor_segment_navigation'),
    height: 72,
    padding: const EdgeInsets.fromLTRB(7, 8, 7, 8),
    color: const Color(0xFF041A28),
    child: Row(
      children: <Widget>[
        for (var index = 1; index <= available; index++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Semantics(
                button: true,
                enabled: index <= furthestAccessible,
                selected: index == selected,
                label:
                    'Segment $index, bölümler ${(index - 1) * 10 + 1}–${index * 10}',
                child: InkWell(
                  key: Key('word_hunt_harbor_segment_$index'),
                  onTap:
                      index <= furthestAccessible
                          ? () => onSelect(index)
                          : null,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color:
                          index == selected
                              ? const Color(0xFF14424C)
                              : const Color(0xFF0C2837),
                      border: Border.all(
                        color:
                            index == selected
                                ? const Color(0xFFFAC55D)
                                : const Color(0xFFB98B4C),
                        width: index == selected ? 3 : 2,
                      ),
                    ),
                    child: Text(
                      '${(index - 1) * 10 + 1}–${index * 10}',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF6E8D0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
