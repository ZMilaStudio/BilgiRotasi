import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum WordHuntTallAmbientMode {
  legacyMirroredArtwork,
  edgeDerivedLowFrequency,
  none,
}

enum WordHuntAmbientEdge { top, bottom }

/// Runtime-only tall-screen extension for immutable environment artwork.
///
/// The source image is never flipped or mirrored. A heavily blurred edge-aligned
/// sample is enlarged and feathered into the canonical artwork so recognizable
/// architecture is suppressed into a low-frequency color field.
class WordHuntEdgeDerivedAmbient extends StatelessWidget {
  const WordHuntEdgeDerivedAmbient({
    super.key,
    required this.assetPath,
    required this.edge,
    required this.fallbackColor,
    this.blurSigma = 28,
    this.sampleScale = 1.32,
    this.featherFraction = 0.42,
  }) : assert(blurSigma >= 18),
       assert(sampleScale >= 1),
       assert(featherFraction > 0 && featherFraction <= 1);

  final String assetPath;
  final WordHuntAmbientEdge edge;
  final Color fallbackColor;
  final double blurSigma;
  final double sampleScale;

  /// Fraction of this ambient band devoted to the transition into artwork.
  ///
  /// The parent sizes the band so this feather lives primarily over the
  /// immutable artwork edge rather than over the flat fallback background.
  final double featherFraction;

  @override
  Widget build(BuildContext context) {
    final isTop = edge == WordHuntAmbientEdge.top;
    final alignment = isTop ? Alignment.topCenter : Alignment.bottomCenter;
    final maskColors = isTop
        ? const <Color>[Colors.white, Colors.white, Colors.transparent]
        : const <Color>[Colors.transparent, Colors.white, Colors.white];
    final maskStops = isTop
        ? <double>[0, 1 - featherFraction, 1]
        : <double>[0, featherFraction, 1];

    return RepaintBoundary(
      key: Key(
        isTop
            ? 'word_hunt_edge_ambient_top'
            : 'word_hunt_edge_ambient_bottom',
      ),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: maskColors,
          stops: maskStops,
        ).createShader(bounds),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ColoredBox(color: fallbackColor),
              Transform.scale(
                scale: sampleScale,
                alignment: alignment,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: blurSigma,
                    sigmaY: blurSigma,
                  ),
                  child: Image.asset(
                    assetPath,
                    key: Key(
                      isTop
                          ? 'word_hunt_edge_ambient_source_top'
                          : 'word_hunt_edge_ambient_source_bottom',
                    ),
                    fit: BoxFit.cover,
                    alignment: alignment,
                    filterQuality: FilterQuality.low,
                  ),
                ),
              ),
              ColoredBox(
                color: fallbackColor.withValues(alpha: 0.28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
