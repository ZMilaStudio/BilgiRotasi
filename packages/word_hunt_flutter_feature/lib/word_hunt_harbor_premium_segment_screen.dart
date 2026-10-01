import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'word_hunt_harbor_layout_manifest.dart';
import 'word_hunt_harbor_segment_registry.dart';
import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_segment_host.dart';
import 'word_hunt_star_visuals.dart';

/// New registered segments only; accepted Segment 1–3 renderers stay isolated.
class WordHuntHarborPremiumSegmentScreen extends StatefulWidget {
  const WordHuntHarborPremiumSegmentScreen({
    super.key,
    required this.route,
    required this.progress,
    required this.segmentIndex,
    required this.furthestAccessibleSegment,
    this.onBack,
    this.onInfo,
    this.onLevelTap,
    this.onSegmentSelect,
  });
  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final int segmentIndex;
  final int furthestAccessibleSegment;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final ValueChanged<int>? onLevelTap;
  final ValueChanged<int>? onSegmentSelect;
  @override
  State<WordHuntHarborPremiumSegmentScreen> createState() =>
      _PremiumSegmentState();
}

class _PremiumSegmentState extends State<WordHuntHarborPremiumSegmentScreen> {
  Future<HarborLayoutManifest>? _layout;
  AssetBundle? _bundle;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bundle = DefaultAssetBundle.of(context);
    if (!identical(bundle, _bundle)) {
      _bundle = bundle;
      _layout = _load(bundle);
    }
  }

  @override
  void didUpdateWidget(WordHuntHarborPremiumSegmentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segmentIndex != widget.segmentIndex) {
      _layout = _load(_bundle!);
    }
  }

  Future<HarborLayoutManifest> _load(AssetBundle bundle) async {
    final art = WordHuntHarborSegmentRegistry.forSegment(widget.segmentIndex);
    if (art == null) throw StateError('Unregistered Harbor segment');
    final bytes = await bundle.load(art.sceneAsset);
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    final frame = await codec.getNextFrame();
    final width = frame.image.width;
    final height = frame.image.height;
    frame.image.dispose();
    codec.dispose();
    return HarborLayoutManifest.parseJson(
      await bundle.loadString(art.manifestAsset, cache: false),
      resolveAsset:
          (path) =>
              path == art.sceneAsset
                  ? HarborSceneAssetMetadata(
                    assetPath: path,
                    width: width,
                    height: height,
                    sha256: art.sceneSha256,
                  )
                  : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final art = WordHuntHarborSegmentRegistry.forSegment(widget.segmentIndex);
    final host = WordHuntRouteSegmentHost.forRoute(
      route: widget.route,
      progress: widget.progress,
      segmentIndex: widget.segmentIndex,
    );
    return Scaffold(
      key: Key('word_hunt_harbor_segment_screen_${widget.segmentIndex}'),
      backgroundColor: const Color(0xFF071629),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 66,
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    tooltip: 'Haritadan çık',
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFFFD45B),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: Text(
                            art?.title ?? 'Harita',
                            style: const TextStyle(
                              color: Color(0xFFF8E7BF),
                              fontFamily: 'serif',
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${art?.firstLevel ?? 0}–${art?.lastLevel ?? 0} · '
                          '${WordHuntRouteProgressEngine.totalStars(widget.route, widget.progress)}'
                          ' / ${widget.route.maximumStars} ★',
                          style: const TextStyle(
                            color: Color(0xFFDCBA78),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('word_hunt_harbor_info'),
                    onPressed: widget.onInfo,
                    tooltip: 'Bilgi',
                    icon: const Icon(
                      Icons.info_outline,
                      color: Color(0xFFFFD45B),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<HarborLayoutManifest>(
                future: _layout,
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(
                      child: Text(
                        'Harita yerleşimi yüklenemedi',
                        key: Key(
                          'word_hunt_harbor_layout_error_${widget.segmentIndex}',
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final manifest = snapshot.requireData;
                  if (manifest.segmentIndex != widget.segmentIndex ||
                      !listEquals(
                        manifest.nodes.map((n) => n.levelId).toList(),
                        host.nodes.map((n) => n.levelId).toList(),
                      )) {
                    return const Center(
                      child: Text(
                        'Harita bölüm kimliği uyuşmuyor',
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
              SizedBox(
                height: 72,
                child: ListView(
                  key: const Key('word_hunt_harbor_segment_navigation'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  children: [
                    for (final segment in widget.route.segments)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Semantics(
                          selected: segment.index == widget.segmentIndex,
                          child: OutlinedButton(
                            key: Key(
                              'word_hunt_harbor_segment_${segment.index}',
                            ),
                            onPressed:
                                segment.index <=
                                        widget.furthestAccessibleSegment
                                    ? () =>
                                        widget.onSegmentSelect!(segment.index)
                                    : null,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(76, 48),
                              foregroundColor: const Color(0xFFFFD45B),
                              backgroundColor:
                                  segment.index == widget.segmentIndex
                                      ? const Color(0xFF244B53)
                                      : const Color(0xFF102633),
                            ),
                            child: Text(
                              '${segment.startLevelIndex}–${segment.endLevelIndex}',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _scene(
    HarborLayoutManifest manifest,
    List<WordHuntRouteMapNodeProjection> nodes,
    Size size,
  ) {
    final transform = HarborLayoutManifest.sceneToViewportTransform(
      sceneWidth: manifest.scene.width.toDouble(),
      sceneHeight: manifest.scene.height.toDouble(),
      viewportWidth: size.width,
      viewportHeight: size.height,
    );
    return ClipRect(
      child: Stack(
        key: Key('word_hunt_harbor_scene_${widget.segmentIndex}'),
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: transform.translationX,
            top: transform.translationY,
            width: manifest.scene.width * transform.scale,
            height: manifest.scene.height * transform.scale,
            child: Image.asset(
              manifest.scene.assetPath,
              key: Key('word_hunt_harbor_scene_asset_${widget.segmentIndex}'),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: CustomPaint(painter: _PremiumRope(manifest, transform)),
              ),
            ),
          ),
          for (var i = 0; i < nodes.length; i++)
            _node(nodes[i], manifest.nodes[i], transform),
        ],
      ),
    );
  }

  Widget _node(
    WordHuntRouteMapNodeProjection node,
    HarborLayoutNode layout,
    HarborSceneViewportTransform transform,
  ) {
    final center = transform.projectScene(layout.center);
    final number = node.absoluteLevelIndex;
    final challenge = node.gameplayType == WordHuntLevelType.challenge;
    final stars = widget.progress.starsFor(node.levelId);
    final label =
        'Bölüm $number, ${challenge ? "meydan okuma, " : ""}'
        '${node.unlocked ? "açık" : "kilitli"}, $stars yıldız';
    final star = transform.projectNodeOffset(layout.center, layout.starAnchor);
    final plaque =
        layout.challengeAnchor == null
            ? null
            : transform.projectNodeOffset(
              layout.center,
              layout.challengeAnchor!,
            );
    return Positioned(
      left: center.x - 34,
      top: center.y - 34,
      child: Semantics(
        label: label,
        button: node.unlocked,
        enabled: node.unlocked,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: node.unlocked ? () => widget.onLevelTap?.call(number) : null,
          child: SizedBox(
            width: 68,
            height: 68,
            key: Key('word_hunt_harbor_level_$number'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          challenge
                              ? Border.all(
                                color: const Color(0xFFFFD45B),
                                width: 3,
                              )
                              : null,
                      boxShadow:
                          node.current
                              ? const [
                                BoxShadow(
                                  color: Color(0x99FFB52B),
                                  blurRadius: 12,
                                ),
                              ]
                              : null,
                    ),
                  ),
                ),
                Center(
                  child: Image.asset(
                    'assets/word_hunt/harbor_segments/segment_02_ui/'
                    '${node.unlocked ? "medallion_blank.png" : "locked_medallion.png"}',
                    key: Key('word_hunt_harbor_medallion_$number'),
                    width: node.unlocked ? 62 : 50,
                    height: node.unlocked ? 65 : 53,
                  ),
                ),
                Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFE4A1),
                      shadows: [Shadow(blurRadius: 2)],
                    ),
                  ),
                ),
                if (challenge && plaque != null)
                  Positioned(
                    left: plaque.x - center.x + 34 - 66,
                    top: plaque.y - center.y + 34 - 11,
                    child: IgnorePointer(
                      child: Container(
                        key: Key('word_hunt_harbor_challenge_$number'),
                        width: 132,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF503121),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: const Color(0xFFCD9C51)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: FittedBox(
                            child: Text(
                              'Meydan Okuma',
                              style: TextStyle(
                                color: Color(0xFFFFD45B),
                                fontSize: 12,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (node.unlocked)
                  Positioned(
                    left: star.x - center.x + 34 - 32.5,
                    top: star.y - center.y + 34 - 12,
                    child: IgnorePointer(
                      child: Container(
                        key: Key('word_hunt_harbor_stars_$number'),
                        width: 65,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xDD10202E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: WordHuntProgressStars(
                          earned: stars,
                          keyPrefix: 'word_hunt_harbor_star_${number}_',
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

class _PremiumRope extends CustomPainter {
  const _PremiumRope(this.manifest, this.transform);
  final HarborLayoutManifest manifest;
  final HarborSceneViewportTransform transform;
  @override
  void paint(Canvas canvas, Size size) {
    final excluded = Path();
    for (final node in manifest.nodes) {
      final center = transform.projectScene(node.center);
      final star = transform.projectNodeOffset(node.center, node.starAnchor);
      excluded.addOval(
        Rect.fromCircle(center: Offset(center.x, center.y), radius: 34),
      );
      excluded.addRect(
        Rect.fromCenter(center: Offset(star.x, star.y), width: 69, height: 28),
      );
      if (node.challengeAnchor case final anchor?) {
        final plaque = transform.projectNodeOffset(node.center, anchor);
        excluded.addRect(
          Rect.fromCenter(
            center: Offset(plaque.x, plaque.y),
            width: 136,
            height: 26,
          ),
        );
      }
    }
    canvas.save();
    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        excluded,
      ),
    );
    for (final edge in manifest.connections) {
      final a = transform.projectScene(edge.start);
      final b = transform.projectScene(edge.control1);
      final c = transform.projectScene(edge.control2);
      final d = transform.projectScene(edge.end);
      final path =
          Path()
            ..moveTo(a.x, a.y)
            ..cubicTo(b.x, b.y, c.x, c.y, d.x, d.y);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = const Color(0xFF15202A),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFD1A05B),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PremiumRope old) =>
      old.manifest != manifest || old.transform != transform;
}
