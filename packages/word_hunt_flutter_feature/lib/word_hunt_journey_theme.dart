import 'package:flutter/material.dart';
import 'word_hunt_gameplay_readability_contract.dart';

enum JourneyScenery { coast, forest, sky, night }

enum JourneyLandmarkKind { minor, major, prestige }

/// Future art metadata only. No image is decoded by the procedural prototype.
class JourneyArtAsset {
  JourneyArtAsset({
    required this.path,
    required this.intrinsicSize,
    required this.sha256,
    this.fit = BoxFit.cover,
    this.focalPoint = const Alignment(0, 0),
  }) {
    if (path.isEmpty ||
        intrinsicSize.width <= 0 ||
        intrinsicSize.height <= 0 ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256)) {
      throw ArgumentError('Invalid future background asset metadata.');
    }
  }
  final String path, sha256;
  final Size intrinsicSize;
  final BoxFit fit;
  final Alignment focalPoint;
}

class JourneyThemeReadability {
  JourneyThemeReadability({
    required this.contract,
    required List<Color> samples,
    this.safeArea = const Rect.fromLTRB(.08, .18, .92, .82),
  }) : samples = List.unmodifiable(samples) {
    if (safeArea.isEmpty ||
        safeArea.left < 0 ||
        safeArea.top < 0 ||
        safeArea.right > 1 ||
        safeArea.bottom > 1) {
      throw ArgumentError('Gameplay safe area must be a normalized rectangle.');
    }
    resolve(); // Empty/unsafe/uncorrectable palettes fail closed at construction.
  }
  final WordHuntGameplayReadabilityContract contract;
  final List<Color> samples;
  final Rect safeArea;
  WordHuntGameplayReadabilityContract resolve() =>
      contract.correctedFor(samples);
}

class JourneyThemeDefinition {
  JourneyThemeDefinition({
    required this.id,
    required this.scenery,
    required this.top,
    required this.bottom,
    required this.accent,
    required this.readability,
    this.decorDensity = 1,
    this.art,
  }) {
    if (id.isEmpty ||
        decorDensity < 0 ||
        decorDensity > 1 ||
        [top, bottom, accent].any((c) => c.a != 1) ||
        !readability.samples.contains(top) ||
        !readability.samples.contains(bottom)) {
      throw ArgumentError(
        'Theme requires opaque sampled palette and bounded decor.',
      );
    }
  }
  final String id;
  final JourneyScenery scenery;
  final Color top, bottom, accent;
  final double decorDensity;
  final JourneyThemeReadability readability;
  final JourneyArtAsset? art;
}

class JourneyThemeTransition {
  const JourneyThemeTransition(this.from, this.to, this.mix);
  final JourneyThemeDefinition from, to;
  final double mix;
  Color get top => Color.lerp(from.top, to.top, mix)!;
  Color get bottom => Color.lerp(from.bottom, to.bottom, mix)!;
  double get decorDensity =>
      from.decorDensity + (to.decorDensity - from.decorDensity) * mix;
}

/// Constant-size cyclic configuration; no catalog/progress/save dependency.
class JourneyThemeSchedule {
  JourneyThemeSchedule({
    required List<JourneyThemeDefinition> themes,
    this.levelsPerTheme = 100,
    this.transitionLevels = 10,
    Map<int, JourneyLandmarkKind> landmarks = const {},
  }) : themes = List.unmodifiable(themes),
       landmarks = Map.unmodifiable(landmarks) {
    if (themes.isEmpty ||
        levelsPerTheme < 1 ||
        transitionLevels < 0 ||
        transitionLevels > levelsPerTheme ||
        landmarks.keys.any((n) => n < 1) ||
        themes.map((t) => t.id).toSet().length != themes.length) {
      throw ArgumentError('Invalid theme schedule.');
    }
  }
  final List<JourneyThemeDefinition> themes;
  final int levelsPerTheme, transitionLevels;
  final Map<int, JourneyLandmarkKind> landmarks;
  JourneyThemeDefinition themeForOrdinal(int ordinal) {
    if (ordinal < 1) throw RangeError.range(ordinal, 1, null);
    return themes[((ordinal - 1) ~/ levelsPerTheme) % themes.length];
  }

  JourneyThemeTransition transitionForOrdinal(int ordinal) {
    final to = themeForOrdinal(ordinal);
    final block = (ordinal - 1) ~/ levelsPerTheme;
    final local = (ordinal - 1) % levelsPerTheme;
    final transitioning = block > 0 && local < transitionLevels;
    return JourneyThemeTransition(
      transitioning ? themes[(block - 1) % themes.length] : to,
      to,
      transitioning ? (local + 1) / transitionLevels : 1,
    );
  }

  JourneyLandmarkKind? landmarkForOrdinal(int ordinal) => landmarks[ordinal];

  static final synthetic = JourneyThemeSchedule(
    themes: [
      _theme(
        'coast_v1',
        JourneyScenery.coast,
        const Color(0xFF102E47),
        const Color(0xFF176B82),
        const Color(0xFFFFCB70),
        .8,
      ),
      _theme(
        'forest_v1',
        JourneyScenery.forest,
        const Color(0xFF102E27),
        const Color(0xFF356744),
        const Color(0xFF8DD293),
        1,
      ),
      _theme(
        'sky_v1',
        JourneyScenery.sky,
        const Color(0xFFB4DCEE),
        const Color(0xFFF5D9B0),
        const Color(0xFFFFFFFF),
        .5,
      ),
      _theme(
        'night_v1',
        JourneyScenery.night,
        const Color(0xFF111329),
        const Color(0xFF45365E),
        const Color(0xFFDBC7FF),
        .7,
      ),
    ],
    landmarks: const {
      50: JourneyLandmarkKind.minor,
      100: JourneyLandmarkKind.major,
      250: JourneyLandmarkKind.minor,
      500: JourneyLandmarkKind.major,
      1000: JourneyLandmarkKind.prestige,
    },
  );
  static JourneyThemeDefinition _theme(
    String id,
    JourneyScenery scenery,
    Color top,
    Color bottom,
    Color accent,
    double density,
  ) => JourneyThemeDefinition(
    id: id,
    scenery: scenery,
    top: top,
    bottom: bottom,
    accent: accent,
    decorDensity: density,
    readability: JourneyThemeReadability(
      contract:
          scenery == JourneyScenery.sky
              ? const WordHuntGameplayReadabilityContract(
                textMode: WordHuntTextMode.dark,
                scrimColor: Colors.white,
                scrimOpacity: .62,
                stateForegrounds: {
                  WordHuntReadableState.found: Color(0xFF093C21),
                  WordHuntReadableState.selected: Color(0xFF102E59),
                  WordHuntReadableState.hint: Color(0xFF41184D),
                },
              )
              : const WordHuntGameplayReadabilityContract(
                textMode: WordHuntTextMode.light,
                scrimColor: Colors.black,
                scrimOpacity: .56,
                stateForegrounds: {
                  WordHuntReadableState.found: Color(0xFFFFF2A3),
                  WordHuntReadableState.selected: Color(0xFFCAE6FF),
                  WordHuntReadableState.hint: Color(0xFFE8D4FF),
                },
              ),
      // White/black guard the full gradient/decor envelope, not just endpoints.
      samples: [top, bottom, Colors.white, Colors.black],
    ),
  );
}
