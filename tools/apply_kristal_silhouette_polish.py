from __future__ import annotations

from pathlib import Path
import re
import subprocess
import sys

EXPECTED_HEAD = "bbce317939dbf24916c86d869fcdadcecba778c3"
root = Path(sys.argv[1]).resolve()
renderer_path = root / "lib/word_hunt/word_hunt_reusable_route_map_screen.dart"
test_path = root / "test/word_hunt_kristal_renderer_test.dart"

head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
if head != EXPECTED_HEAD:
    raise SystemExit(f"Unexpected feature HEAD: {head}; expected {EXPECTED_HEAD}")

renderer = renderer_path.read_text(encoding="utf-8")

old_metrics = """abstract final class WordHuntFacetedCrystalMetrics {\n  static const double normalScale = 1.00;\n  static const double challengeScale = 1.06;\n  static const double finalScale = 1.11;\n}\n"""
new_metrics = """abstract final class WordHuntFacetedCrystalMetrics {\n  static const double normalScale = 1.00;\n  static const double challengeScale = 1.06;\n  static const double finalScale = 1.11;\n\n  // 411 px proof'ta okunabilir gerçek çizim footprint'leri. Hitbox sabittir.\n  static const double normalBodyWidth = 48;\n  static const double normalBodyHeight = 46;\n  static const double normalShardSilhouette = 58;\n  static const double finalBodyWidth = 52;\n  static const double finalBodyHeight = 50;\n  static const double finalShardSilhouette = 62;\n  static const double finalCrestWidth = 52;\n  static const double finalCrestHeight = 32;\n}\n"""
if renderer.count(old_metrics) != 1:
    raise SystemExit("Crystal metrics block did not match exactly once")
renderer = renderer.replace(old_metrics, new_metrics, 1)

new_method = r'''  Widget _buildFacetedCrystalNode() {
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
                            color: theme.nodeShadowColor.withValues(alpha: 0.96),
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
                            color: theme.nodeShadowColor.withValues(alpha: 0.56),
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

  Widget _buildOrbNode() {'''
method_pattern = re.compile(
    r"  Widget _buildFacetedCrystalNode\(\) \{.*?\n  Widget _buildOrbNode\(\) \{",
    re.S,
)
renderer, method_count = method_pattern.subn(new_method, renderer, count=1)
if method_count != 1:
    raise SystemExit(f"Expected one faceted node method; replaced {method_count}")

new_painters = r'''class _FacetedCrystalNodePainter extends CustomPainter {
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
        ..strokeWidth = finalNode ? 3.6 : challenge ? 3.1 : 2.9
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
      ..lineTo(bodyRect.left + bodyWidth * 0.20, bodyRect.top + bodyHeight * 0.12)
      ..close();
    canvas.drawPath(
      leftPlane,
      Paint()..color = textColor.withValues(alpha: locked ? 0.045 : 0.13),
    );

    final rightPlane = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(bodyRect.right - bodyWidth * 0.18, bodyRect.top + bodyHeight * 0.12)
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
      ..moveTo(bodyRect.left + bodyWidth * 0.18, bodyRect.top + bodyHeight * 0.18)
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
      _paintPrism(
        canvas,
        prism.$1,
        prism.$2,
        centerPrism: prism.$3,
      );
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

'''
painter_pattern = re.compile(
    r"class _FacetedCrystalNodePainter extends CustomPainter \{.*?(?=class _ScenicRouteNodePainter extends CustomPainter \{)",
    re.S,
)
renderer, painter_count = painter_pattern.subn(new_painters, renderer, count=1)
if painter_count != 1:
    raise SystemExit(f"Expected one crystal painter block; replaced {painter_count}")

renderer_path.write_text(renderer, encoding="utf-8")

test_text = test_path.read_text(encoding="utf-8")
needle = """    expect(WordHuntFacetedCrystalMetrics.finalScale, 1.11);\n"""
addition = """    expect(WordHuntFacetedCrystalMetrics.finalScale, 1.11);\n    expect(WordHuntFacetedCrystalMetrics.normalBodyWidth, 48);\n    expect(WordHuntFacetedCrystalMetrics.normalBodyHeight, 46);\n    expect(WordHuntFacetedCrystalMetrics.normalShardSilhouette, 58);\n    expect(WordHuntFacetedCrystalMetrics.finalBodyWidth, 52);\n    expect(WordHuntFacetedCrystalMetrics.finalBodyHeight, 50);\n    expect(WordHuntFacetedCrystalMetrics.finalCrestWidth, 52);\n    expect(WordHuntFacetedCrystalMetrics.finalCrestHeight, 32);\n"""
if test_text.count(needle) != 1:
    raise SystemExit("Renderer metric expectation anchor was not unique")
test_text = test_text.replace(needle, addition, 1)

test_path.write_text(test_text, encoding="utf-8")
print("Applied bigger/simpler Kristal silhouette polish to exactly two files.")
