from pathlib import Path


def replace_one(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text(encoding='utf-8')
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{path}: expected one match, found {count}: {old[:80]!r}')
    file.write_text(text.replace(old, new, 1), encoding='utf-8')


reusable = 'lib/word_hunt/word_hunt_reusable_route_map_screen.dart'
visual_theme = 'lib/word_hunt/word_hunt_route_visual_theme.dart'
artwork_map = 'lib/word_hunt/word_hunt_artwork_route_map_screen.dart'
themed_screen = 'lib/word_hunt/word_hunt_themed_production_route_screen.dart'

# Generic, data-driven node presentation token. Existing routes keep scenicWood.
replace_one(
    reusable,
    "/// Görsel tema yalnız boya ve metin token'larını taşır; geometri taşıyamaz.\n@immutable\nclass WordHuntRouteMapTheme {",
    "enum WordHuntRouteNodeVisualStyle { scenicWood, facetedCrystal }\n\n/// Görsel tema yalnız boya ve metin token'larını taşır; geometri taşıyamaz.\n@immutable\nclass WordHuntRouteMapTheme {",
)
replace_one(
    reusable,
    "    this.nodeShadowColor = const Color(0x99000000),\n    this.sceneDepth = 0.28,\n  }) : assert(sceneDepth >= 0 && sceneDepth <= 1);",
    "    this.nodeShadowColor = const Color(0x99000000),\n    this.sceneDepth = 0.28,\n    this.finalAccentColor,\n    this.nodeVisualStyle = WordHuntRouteNodeVisualStyle.scenicWood,\n  }) : assert(sceneDepth >= 0 && sceneDepth <= 1);",
)
replace_one(
    reusable,
    "  final Color nodeShadowColor;\n  final double sceneDepth;\n\n  Color get resolvedSceneGlowColor => sceneGlowColor ?? accentColor;",
    "  final Color nodeShadowColor;\n  final double sceneDepth;\n  final Color? finalAccentColor;\n  final WordHuntRouteNodeVisualStyle nodeVisualStyle;\n\n  Color get resolvedSceneGlowColor => sceneGlowColor ?? accentColor;\n  Color get resolvedFinalAccentColor => finalAccentColor ?? accentColor;",
)

# Artwork-hosted reusable maps reserve the top chrome row and do not render a
# second back button. Title/stars remain one clean live header below chrome.
replace_one(
    reusable,
    "    this.decorationOpacity = 0.42,\n  }) : assert(",
    "    this.decorationOpacity = 0.42,\n    this.hostedByArtworkChrome = false,\n  }) : assert(",
)
replace_one(
    reusable,
    "  final double decorationOpacity;\n\n  // Hitbox sözleşmesi değişmez.",
    "  final double decorationOpacity;\n  final bool hostedByArtworkChrome;\n\n  // Hitbox sözleşmesi değişmez.",
)
replace_one(
    reusable,
    "          children: <Widget>[\n            Padding(\n              padding: EdgeInsets.fromLTRB(\n                scenic ? 10 : 12,\n                scenic ? 8 : 10,\n                scenic ? 10 : 12,\n                scenic ? 6 : 9,\n              ),\n              child: _ReusableRouteHeader(\n                title: route.title,\n                stars: stars,\n                maximumStars: route.maximumStars,\n                theme: theme,\n              ),\n            ),",
    "          children: <Widget>[\n            if (hostedByArtworkChrome) const SizedBox(height: 48),\n            Padding(\n              padding: EdgeInsets.fromLTRB(\n                scenic ? 10 : 12,\n                hostedByArtworkChrome ? 2 : scenic ? 8 : 10,\n                scenic ? 10 : 12,\n                scenic ? 6 : 9,\n              ),\n              child: _ReusableRouteHeader(\n                title: route.title,\n                stars: stars,\n                maximumStars: route.maximumStars,\n                theme: theme,\n                showBackButton: !hostedByArtworkChrome,\n              ),\n            ),",
)
replace_one(
    reusable,
    "  const _ReusableRouteHeader({\n    required this.title,\n    required this.stars,\n    required this.maximumStars,\n    required this.theme,\n  });",
    "  const _ReusableRouteHeader({\n    required this.title,\n    required this.stars,\n    required this.maximumStars,\n    required this.theme,\n    this.showBackButton = true,\n  });",
)
replace_one(
    reusable,
    "  final WordHuntRouteMapTheme theme;\n\n  @override\n  Widget build(BuildContext context) {",
    "  final WordHuntRouteMapTheme theme;\n  final bool showBackButton;\n\n  @override\n  Widget build(BuildContext context) {",
)
replace_one(
    reusable,
    "    return Row(\n      children: <Widget>[\n        Material(\n          color: Colors.transparent,",
    "    return Row(\n      children: <Widget>[\n        if (showBackButton)\n          Material(\n          color: Colors.transparent,",
)

# Faceted mineral proof skin. Hitbox and canonical geometry are untouched.
replace_one(
    reusable,
    "  Widget _buildScenicNode() {\n    final fillColor = unlocked ? theme.nodeColor : theme.lockedNodeColor;",
    "  Widget _buildScenicNode() {\n    if (theme.nodeVisualStyle == WordHuntRouteNodeVisualStyle.facetedCrystal) {\n      return _buildFacetedCrystalNode();\n    }\n    final fillColor = unlocked ? theme.nodeColor : theme.lockedNodeColor;",
)
faceted_method = r'''
  Widget _buildFacetedCrystalNode() {
    final isFinal = level.type == WordHuntLevelType.routeFinal;
    final fillColor = unlocked ? theme.nodeColor : theme.lockedNodeColor;
    final borderColor = isFinal
        ? theme.resolvedFinalAccentColor
        : current
        ? theme.accentColor
        : unlocked
        ? theme.pathColor
        : theme.lockedPathColor;
    final nodeWidth = current ? 60.0 : 56.0;
    final nodeHeight = current ? 50.0 : 46.0;

    return SizedBox(
      key: Key('word_hunt_reusable_node_${level.index}_$_visualState'),
      width: 68,
      height: WordHuntReusableRouteMapScreen._nodeDiameter,
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
                      color: theme.accentColor.withValues(alpha: 0.46),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(
            key: Key('word_hunt_faceted_node_${level.index}'),
            width: nodeWidth,
            height: nodeHeight,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: <Widget>[
                CustomPaint(
                  painter: _FacetedCrystalNodePainter(
                    fillColor: fillColor,
                    borderColor: borderColor,
                    shadowColor: theme.nodeShadowColor,
                    textColor: theme.textColor,
                    locked: !unlocked,
                    current: current,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.02),
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
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.nodeShadowColor.withValues(alpha: 0.88),
                        border: Border.all(
                          color: theme.textColor.withValues(alpha: 0.26),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 10,
                        color: theme.textColor.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isFinal)
            Positioned(
              top: -16,
              width: 30,
              height: 18,
              child: CustomPaint(
                key: const Key('word_hunt_faceted_final_crown'),
                painter: _CrystalFinalCrownPainter(
                  color: theme.resolvedFinalAccentColor,
                  shadowColor: theme.nodeShadowColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

'''
replace_one(
    reusable,
    "  Widget _buildOrbNode() {",
    faceted_method + "  Widget _buildOrbNode() {",
)
faceted_painters = r'''
class _FacetedCrystalNodePainter extends CustomPainter {
  const _FacetedCrystalNodePainter({
    required this.fillColor,
    required this.borderColor,
    required this.shadowColor,
    required this.textColor,
    required this.locked,
    required this.current,
  });

  final Color fillColor;
  final Color borderColor;
  final Color shadowColor;
  final Color textColor;
  final bool locked;
  final bool current;

  Path _hex(Size size, {double inset = 0}) {
    final left = inset;
    final top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;
    final shoulder = (right - left) * 0.20;
    return Path()
      ..moveTo(left + shoulder, top)
      ..lineTo(right - shoulder, top)
      ..lineTo(right, (top + bottom) / 2)
      ..lineTo(right - shoulder, bottom)
      ..lineTo(left + shoulder, bottom)
      ..lineTo(left, (top + bottom) / 2)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPath = _hex(size).shift(const Offset(1.5, 3));
    canvas.drawPath(
      shadowPath,
      Paint()..color = shadowColor.withValues(alpha: locked ? 0.52 : 0.68),
    );

    final bodyPath = _hex(size, inset: 1.2);
    final rect = Offset.zero & size;
    final light = Color.alphaBlend(
      textColor.withValues(alpha: locked ? 0.04 : 0.13),
      fillColor,
    );
    final dark = Color.alphaBlend(
      Colors.black.withValues(alpha: locked ? 0.34 : 0.22),
      fillColor,
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[light, fillColor, dark],
          stops: const <double>[0, 0.52, 1],
        ).createShader(rect),
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = current ? 3.2 : 2.2
        ..color = borderColor,
    );

    final facet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = textColor.withValues(alpha: locked ? 0.08 : 0.18);
    final center = Offset(size.width * 0.50, size.height * 0.48);
    canvas.drawLine(Offset(size.width * 0.21, 1.8), center, facet);
    canvas.drawLine(Offset(size.width * 0.79, 1.8), center, facet);
    canvas.drawLine(center, Offset(size.width * 0.82, size.height * 0.88), facet);
    canvas.drawLine(center, Offset(size.width * 0.18, size.height * 0.88), facet);
  }

  @override
  bool shouldRepaint(covariant _FacetedCrystalNodePainter oldDelegate) =>
      oldDelegate.fillColor != fillColor ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.shadowColor != shadowColor ||
      oldDelegate.textColor != textColor ||
      oldDelegate.locked != locked ||
      oldDelegate.current != current;
}

class _CrystalFinalCrownPainter extends CustomPainter {
  const _CrystalFinalCrownPainter({required this.color, required this.shadowColor});

  final Color color;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final crown = Path()
      ..moveTo(size.width * 0.08, size.height * 0.82)
      ..lineTo(size.width * 0.14, size.height * 0.24)
      ..lineTo(size.width * 0.34, size.height * 0.56)
      ..lineTo(size.width * 0.50, size.height * 0.08)
      ..lineTo(size.width * 0.66, size.height * 0.56)
      ..lineTo(size.width * 0.86, size.height * 0.24)
      ..lineTo(size.width * 0.92, size.height * 0.82)
      ..close();
    canvas.drawPath(crown.shift(const Offset(1, 2)), Paint()..color = shadowColor.withValues(alpha: 0.80));
    canvas.drawPath(crown, Paint()..color = color);
    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.82),
      Offset(size.width * 0.90, size.height * 0.82),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.58)
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _CrystalFinalCrownPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.shadowColor != shadowColor;
}

'''
replace_one(
    reusable,
    "class _ScenicRouteNodePainter extends CustomPainter {",
    faceted_painters + "class _ScenicRouteNodePainter extends CustomPainter {",
)

# The artwork overlay host marks the reusable map as externally chromed.
replace_one(
    artwork_map,
    "      return WordHuntReusableRouteMapScreen(\n        route: route,\n        theme: theme,\n        progress: progress,",
    "      return WordHuntReusableRouteMapScreen(\n        route: route,\n        theme: theme,\n        progress: progress,\n        hostedByArtworkChrome: true,",
)

# Preserve the new generic theme tokens through transparent artwork themes.
replace_one(
    visual_theme,
    "      nodeShadowColor: source.nodeShadowColor,\n      sceneDepth: 0,",
    "      nodeShadowColor: source.nodeShadowColor,\n      sceneDepth: 0,\n      finalAccentColor: source.finalAccentColor,\n      nodeVisualStyle: source.nodeVisualStyle,",
)

# Tall ambient edge tint derives from route theme instead of forest-era constants.
replace_one(
    themed_screen,
    "    return IgnorePointer(\n      child: ClipRect(\n        child: Stack(\n          fit: StackFit.expand,\n          children: <Widget>[",
    "    final ambientEdge = theme.backgroundColor.withValues(alpha: 0.34);\n    final ambientMid = theme.backgroundColor.withValues(alpha: 0.10);\n    final ambientClear = theme.backgroundColor.withValues(alpha: 0);\n\n    return IgnorePointer(\n      child: ClipRect(\n        child: Stack(\n          fit: StackFit.expand,\n          children: <Widget>[",
)
replace_one(
    themed_screen,
    "                    colors: isTop\n                        ? const <Color>[\n                            Color(0x24030B07),\n                            Color(0x0806110A),\n                            Color(0x0006110A),\n                          ]\n                        : const <Color>[\n                            Color(0x0006110A),\n                            Color(0x0806110A),\n                            Color(0x24030B07),\n                          ],",
    "                    colors: isTop\n                        ? <Color>[ambientEdge, ambientMid, ambientClear]\n                        : <Color>[ambientClear, ambientMid, ambientEdge],",
)

print('Kristal runtime proof renderer patch applied successfully.')
