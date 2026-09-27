import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_segment_host.dart';
import 'word_hunt_star_visuals.dart';

/// Owner-approved clean environments. Only scene art is raster; nodes, path,
/// stars, locks and all progression state are live Flutter overlays.
abstract final class WordHuntHarborSegmentArt {
  static const Size sourceSize = Size(941, 1672);
  static const String segment2 =
      'assets/word_hunt/harbor_segments/segment_02_clean.webp';
  static const String segment3 =
      'assets/word_hunt/harbor_segments/segment_03_clean.webp';

  // Measured from the separately approved map samples (941x1672), not reused
  // Segment 1 coordinates. These are medallion centers in scene pixel space.
  // Same scene coordinate space as the approved 941x1672 raster.
  // Composition envelopes (68dp touch, 54dp ring, centered 49dp stars,
  // 132dp final challenge badge) were checked at both target viewports.
  static const List<Offset> segment2Centers = <Offset>[
    Offset(180, 350), Offset(405, 465), Offset(625, 565),
    Offset(816, 697), Offset(535, 824), Offset(316, 951),
    Offset(125, 1085), Offset(410, 1194), Offset(724, 1322),
    Offset(390, 1420),
  ];
  static const List<Offset> segment3Centers = <Offset>[
    Offset(174, 385), Offset(409, 488), Offset(625, 588),
    Offset(814, 715), Offset(550, 839), Offset(325, 970),
    Offset(130, 1085), Offset(415, 1200), Offset(735, 1330),
    Offset(390, 1425),
  ];

  static String assetFor(int index) => switch (index) {
    2 => segment2,
    3 => segment3,
    _ => throw RangeError.range(index, 2, 3, 'segmentIndex'),
  };

  static List<Offset> centersFor(int index) => switch (index) {
    2 => segment2Centers,
    3 => segment3Centers,
    _ => throw RangeError.range(index, 2, 3, 'segmentIndex'),
  };
}

/// Segment selector is distinct from the route-exit back button.
/// It exposes only published and already-accessible segment ranges.
class WordHuntHarborSegmentNavigation extends StatelessWidget {
  const WordHuntHarborSegmentNavigation({
    super.key,
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
  Widget build(BuildContext context) {
    return Container(
      key: const Key('word_hunt_harbor_segment_navigation'),
      padding: const EdgeInsets.fromLTRB(7, 8, 7, 8),
      decoration: const BoxDecoration(color: Color(0xEE081729)),
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
                  label: 'Segment $index, bölümler ${(index - 1) * 10 + 1}–${index * 10}',
                  child: Material(
                    color: index == selected
                        ? const Color(0xFF244B53)
                        : const Color(0xD9193040),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      key: Key('word_hunt_harbor_segment_$index'),
                      onTap: index <= furthestAccessible
                          ? () => onSelect(index)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: index == selected
                                ? const Color(0xFFFFD45B)
                                : const Color(0xFF748997),
                            width: index == selected ? 1.6 : 0.8,
                          ),
                        ),
                        child: Text(
                          '${(index - 1) * 10 + 1}–${index * 10}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: index == selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: index <= furthestAccessible
                                ? const Color(0xFFFFF7E8)
                                : const Color(0xFF77838D),
                          ),
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
}

class WordHuntHarborSegmentScreen extends StatelessWidget {
  const WordHuntHarborSegmentScreen({
    super.key,
    required this.route,
    required this.progress,
    required this.segmentIndex,
    required this.furthestAccessibleSegment,
    this.onBack,
    this.onInfo,
    this.onLevelTap,
    this.onSegmentSelect,
  }) : assert(segmentIndex == 2 || segmentIndex == 3);

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final int segmentIndex;
  final int furthestAccessibleSegment;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final ValueChanged<int>? onLevelTap;
  final ValueChanged<int>? onSegmentSelect;

  @override
  Widget build(BuildContext context) {
    final host = WordHuntRouteSegmentHost.forRoute(
      route: route,
      progress: progress,
      segmentIndex: segmentIndex,
    );
    final totalStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    return Scaffold(
      key: Key('word_hunt_harbor_segment_screen_$segmentIndex'),
      backgroundColor: const Color(0xFF071629),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: 76,
              color: const Color(0xEE081729),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          key: const Key('word_hunt_harbor_back'),
                          tooltip: 'Haritadan çık',
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFFFD45B)),
                        ),
                        Expanded(
                          child: Text(
                            route.title.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFF4DE),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('word_hunt_harbor_info'),
                          tooltip: 'Bilgi',
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          onPressed: onInfo,
                          icon: const Icon(Icons.info_outline_rounded, color: Color(0xFFFFD45B)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    segmentIndex == 2 ? 'AÇIK DENİZ GEÇİDİ  •  $totalStars / ${route.maximumStars} ★'
                        : 'ESKİ TERSANE  •  $totalStars / ${route.maximumStars} ★',
                    style: const TextStyle(color: Color(0xFFE3D6B6), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewport = constraints.biggest;
                  final source = WordHuntHarborSegmentArt.sourceSize;
                  final scale = math.max(viewport.width / source.width,
                      viewport.height / source.height);
                  final imageSize = source * scale;
                  final translation = Offset((viewport.width - imageSize.width) / 2,
                      (viewport.height - imageSize.height) / 2);
                  final points = WordHuntHarborSegmentArt.centersFor(segmentIndex)
                      .map((point) => translation + point * scale)
                      .toList(growable: false);
                  return ClipRect(
                    key: Key('word_hunt_harbor_scene_$segmentIndex'),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Positioned.fromRect(
                          rect: translation & imageSize,
                          child: Image.asset(
                            WordHuntHarborSegmentArt.assetFor(segmentIndex),
                            key: Key('word_hunt_harbor_scene_asset_$segmentIndex'),
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image_rounded,
                                  key: Key('word_hunt_harbor_missing_asset'), color: Colors.red),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              key: Key('word_hunt_harbor_path_$segmentIndex'),
                              painter: _HarborRoutePathPainter(points: points, nodes: host.nodes),
                            ),
                          ),
                        ),
                        // The painted ring and the 68dp touch target have
                        // the very same projected center. Stars/badges are
                        // overflow-visible decorations anchored to that center,
                        // never extra independent map coordinates.
                        for (var i = 0; i < host.nodes.length; i++)
                          Positioned(
                            left: points[i].dx - WordHuntHarborNodeGeometry.hitboxSize / 2,
                            top: points[i].dy - WordHuntHarborNodeGeometry.hitboxSize / 2,
                            width: WordHuntHarborNodeGeometry.hitboxSize,
                            height: WordHuntHarborNodeGeometry.hitboxSize,
                            child: _HarborNode(
                              node: host.nodes[i],
                              earned: progress.starsFor(host.nodes[i].levelId),
                              onTap: host.nodes[i].unlocked && onLevelTap != null
                                  ? () => onLevelTap!(host.nodes[i].absoluteLevelIndex)
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (onSegmentSelect != null)
              WordHuntHarborSegmentNavigation(
                selected: segmentIndex,
                available: route.segments.length,
                furthestAccessible: furthestAccessibleSegment,
                onSelect: onSegmentSelect!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Geometry shared by the touch target, star anchor, challenge badge and
/// route painter. All offsets are logical pixels from the 68dp touch box.
abstract final class WordHuntHarborNodeGeometry {
  static const double hitboxSize = 68;
  static const double ringSize = 54;
  static const double ringInset = 7;
  static const double starTop = 68;
  static const double challengeTop = 94;
  static const double challengeWidth = 132;
  static const double challengeHeight = 22;

  /// Exact mathematical connection endpoints, shared with the painter.
  /// Keep these independent of PathMetric's approximate tangent sampling.
  static (Offset, Offset) connectionEndpoints(Offset from, Offset to) {
    final direction = to.dx >= from.dx ? 1.0 : -1.0;
    final start = from + Offset(direction * 31, -6);
    final finish = to + Offset(-direction * 31, -6);
    return (start, finish);
  }

  /// Run the water-light trail between ring *edges* and above star rows,
  /// rather than drawing a bright center-to-center line through the UI.
  static Path connection(Offset from, Offset to) {
    final (start, finish) = connectionEndpoints(from, to);
    final delta = finish - start;
    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + delta.dx * 0.36,
        start.dy + delta.dy * 0.13 - 5,
        start.dx + delta.dx * 0.64,
        finish.dy - delta.dy * 0.13 - 8,
        finish.dx,
        finish.dy,
      );
  }
}

class _HarborNode extends StatelessWidget {
  const _HarborNode({required this.node, required this.earned, this.onTap});

  final WordHuntRouteMapNodeProjection node;
  final int earned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final number = node.absoluteLevelIndex;
    final challenge = node.gameplayType == WordHuntLevelType.challenge;
    final rim = challenge
        ? (node.unlocked ? const Color(0xFFF4BB60) : const Color(0xFFAD9064))
        : !node.unlocked
            ? const Color(0xFF82939E)
            : const Color(0xFF70E4E6);
    return Semantics(
      button: node.unlocked,
      enabled: node.unlocked,
      label: 'Bölüm $number, ${challenge ? 'meydan okuma, ' : ''}${node.unlocked ? 'açık' : 'kilitli'}, $earned yıldız',
      child: GestureDetector(
        key: Key('word_hunt_harbor_level_$number'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: WordHuntHarborNodeGeometry.ringInset,
              top: WordHuntHarborNodeGeometry.ringInset,
              width: WordHuntHarborNodeGeometry.ringSize,
              height: WordHuntHarborNodeGeometry.ringSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  DecoratedBox(
                    key: Key('word_hunt_harbor_medallion_$number'),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: node.unlocked
                            ? const <Color>[Color(0xFF214A4B), Color(0xFF071B2D)]
                            : const <Color>[Color(0xFF374752), Color(0xFF101B28)],
                      ),
                      border: Border.all(color: rim, width: node.current ? 3 : 2),
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: rim.withValues(alpha: node.current ? 0.65 : 0.28), blurRadius: 7),
                        const BoxShadow(color: Color(0xA6000000), blurRadius: 4),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$number',
                        key: Key('word_hunt_harbor_number_$number'),
                        style: const TextStyle(color: Color(0xFFFFF5E8),
                            fontSize: 19, fontWeight: FontWeight.w900,
                            shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 3)]),
                      ),
                    ),
                  ),
                  if (!node.unlocked)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(color: Color(0xFF202C36), shape: BoxShape.circle),
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(Icons.lock_rounded, size: 12, color: Color(0xFFD3DBE2)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Every star plaque is centered on its own ring; its 7dp visual
            // gap below the rim is independent of its earned star count.
            Positioned(
              left: 0,
              right: 0,
              top: WordHuntHarborNodeGeometry.starTop,
              child: Center(
                child: DecoratedBox(
                  key: Key('word_hunt_harbor_star_backplate_$number'),
                  decoration: BoxDecoration(color: const Color(0xCE081725),
                      borderRadius: BorderRadius.circular(9)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    child: WordHuntProgressStars(
                      keyPrefix: 'word_hunt_harbor_star_${number}_',
                      earned: earned,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ),
            if (challenge)
              Positioned(
                left: (WordHuntHarborNodeGeometry.hitboxSize -
                    WordHuntHarborNodeGeometry.challengeWidth) / 2,
                top: WordHuntHarborNodeGeometry.challengeTop,
                width: WordHuntHarborNodeGeometry.challengeWidth,
                height: WordHuntHarborNodeGeometry.challengeHeight,
                child: IgnorePointer(
                  child: DecoratedBox(
                    key: Key('word_hunt_harbor_challenge_$number'),
                    decoration: BoxDecoration(
                      color: const Color(0xE318202C),
                      border: Border.all(
                        color: node.unlocked
                            ? const Color(0xC2E2B669)
                            : const Color(0xA68F8068),
                      ),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(color: Color(0x66000000), blurRadius: 6),
                      ],
                    ),
                    child: Center(
                      child: Text('MEYDAN OKUMA',
                          style: TextStyle(
                            color: node.unlocked
                                ? const Color(0xFFFFDA85)
                                : const Color(0xFFBDB197),
                            fontSize: 10.5, fontWeight: FontWeight.w900,
                            letterSpacing: 0.45,
                          )),
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

class _HarborRoutePathPainter extends CustomPainter {
  const _HarborRoutePathPainter({required this.points, required this.nodes});
  final List<Offset> points;
  final List<WordHuntRouteMapNodeProjection> nodes;

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index + 1 < points.length; index++) {
      final path = WordHuntHarborNodeGeometry.connection(
        points[index], points[index + 1],
      );
      final lit = nodes[index + 1].unlocked;
      // Restrained underlay and slim water-light core. The path never draws
      // over star plates, numbers or the integrated challenge badge.
      canvas.drawPath(path, Paint()
        ..color = lit ? const Color(0x3543BEB1) : const Color(0x254A6572)
        ..style = PaintingStyle.stroke ..strokeWidth = lit ? 4 : 3
        ..strokeCap = StrokeCap.round);
      canvas.drawPath(path, Paint()
        ..color = lit ? const Color(0xB8A0E8D4) : const Color(0x82778E9A)
        ..style = PaintingStyle.stroke ..strokeWidth = lit ? 1.6 : 1.1
        ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant _HarborRoutePathPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.nodes != nodes;
}
