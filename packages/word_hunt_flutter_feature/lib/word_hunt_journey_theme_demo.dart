import 'package:flutter/material.dart';
import 'word_hunt_gameplay_readability_contract.dart';
import 'word_hunt_journey_background.dart';
import 'word_hunt_journey_theme.dart';

/// Synthetic visual proof; never imports real content or gameplay/storage.
class JourneyThemeReadabilityDemo extends StatelessWidget {
  const JourneyThemeReadabilityDemo({super.key, required this.theme});
  final JourneyThemeDefinition theme;
  @override
  Widget build(BuildContext context) => WordHuntGameplayReadabilitySurface(
    contract: theme.readability.contract,
    samples: theme.readability.samples,
    background: IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(painter: _DemoBackground(theme)),
      ),
    ),
    builder:
        (context, palette) => LayoutBuilder(
          builder: (context, constraints) {
            final zone = theme.readability.safeArea;
            return Stack(
              children: [
                Positioned(
                  left: constraints.maxWidth * zone.left,
                  top: constraints.maxHeight * zone.top,
                  width: constraints.maxWidth * zone.width,
                  height: constraints.maxHeight * zone.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final state in WordHuntReadableState.values)
                        Expanded(
                          child: Center(
                            child: ColoredBox(
                              key: ValueKey(
                                'journey_readability_${state.name}',
                              ),
                              color:
                                  palette.stateSurfaces[state] ??
                                  Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  '${state.name.toUpperCase()}  A V I',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: palette.foregroundFor(state),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
  );
}

class _DemoBackground extends CustomPainter {
  const _DemoBackground(this.theme);
  final JourneyThemeDefinition theme;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.top, theme.bottom],
        ).createShader(rect),
    );
    // Detail is constrained outside the gameplay safe area.
    for (final position in [const Offset(.04, .1), const Offset(.96, .9)]) {
      paintMotif(
        canvas,
        Offset(size.width * position.dx, size.height * position.dy),
        size.width * .035,
        theme.scenery,
        theme.accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DemoBackground old) => old.theme != theme;
}
