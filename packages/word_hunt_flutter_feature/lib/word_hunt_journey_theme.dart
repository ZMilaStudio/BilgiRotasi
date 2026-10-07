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

/// Presentation ranges only: never publish content or unlock a level.
class JourneyThemeBand {
  const JourneyThemeBand(this.first, this.last, this.theme);
  final int first, last;
  final JourneyThemeDefinition theme;
}

/// Constant-size cyclic configuration; no catalog/progress/save dependency.
class JourneyThemeSchedule {
  JourneyThemeSchedule({
    required List<JourneyThemeDefinition> themes,
    this.levelsPerTheme = 100,
    this.transitionLevels = 10,
    Map<int, JourneyLandmarkKind> landmarks = const {},
    List<JourneyThemeBand> bands = const [],
  }) : themes = List.unmodifiable(themes),
       landmarks = Map.unmodifiable(landmarks),
       bands = List.unmodifiable(bands) {
    if (themes.isEmpty ||
        levelsPerTheme < 1 ||
        transitionLevels < 0 ||
        transitionLevels > levelsPerTheme ||
        landmarks.keys.any((n) => n < 1) ||
        themes.map((t) => t.id).toSet().length != themes.length) {
      throw ArgumentError('Invalid theme schedule.');
    }
    for (var i = 0; i < bands.length; i++) {
      final band = bands[i];
      if (band.first < 1 ||
          band.last < band.first ||
          (i > 0 && bands[i - 1].last + 1 != band.first)) {
        throw ArgumentError('Visual bands must be ordered, contiguous ranges.');
      }
    }
  }
  final List<JourneyThemeDefinition> themes;
  final int levelsPerTheme, transitionLevels;
  final Map<int, JourneyLandmarkKind> landmarks;
  final List<JourneyThemeBand> bands;
  JourneyThemeDefinition themeForOrdinal(int ordinal) {
    if (ordinal < 1) throw RangeError.range(ordinal, 1, null);
    for (final band in bands) {
      if (ordinal >= band.first && ordinal <= band.last) return band.theme;
    }
    return themes[((ordinal - 1) ~/ levelsPerTheme) % themes.length];
  }

  JourneyThemeTransition transitionForOrdinal(int ordinal) {
    final to = themeForOrdinal(ordinal);
    for (final band in bands) {
      if (ordinal >= band.first && ordinal <= band.last) {
        final local = ordinal - band.first;
        final window = transitionLevels.clamp(0, band.last - band.first + 1);
        final blending = band.first > 1 && local < window;
        return JourneyThemeTransition(
          blending ? themeForOrdinal(band.first - 1) : to,
          to,
          blending ? (local + 1) / window : 1,
        );
      }
    }
    final block = (ordinal - 1) ~/ levelsPerTheme;
    final local = (ordinal - 1) % levelsPerTheme;
    final transitioning = block > 0 && local < transitionLevels;
    return JourneyThemeTransition(
      transitioning ? themeForOrdinal(block * levelsPerTheme) : to,
      to,
      transitioning ? (local + 1) / transitionLevels : 1,
    );
  }

  JourneyLandmarkKind? landmarkForOrdinal(int ordinal) => landmarks[ordinal];

  /// Procedural production foundation. No final raster art is claimed here.
  /// Future biomes reuse the same schedule/background/landmark contract.
  static final production = JourneyThemeSchedule(
    themes: synthetic.themes,
    bands: [
      JourneyThemeBand(
        1,
        20,
        _theme(
          'fener_shore_v1',
          JourneyScenery.coast,
          const Color(0xFF102E47),
          const Color(0xFF155067),
          const Color(0xFFFFCB70),
          .35,
        ),
      ),
      JourneyThemeBand(
        21,
        50,
        _theme(
          'fener_cliffs_v1',
          JourneyScenery.coast,
          const Color(0xFF142D48),
          const Color(0xFF17445B),
          const Color(0xFFFFCB70),
          .5,
        ),
      ),
      JourneyThemeBand(
        51,
        75,
        _theme(
          'fener_approach_v1',
          JourneyScenery.coast,
          const Color(0xFF151F3D),
          const Color(0xFF19374F),
          const Color(0xFFFFCB70),
          .65,
        ),
      ),
      JourneyThemeBand(
        76,
        100,
        _theme(
          'fener_beacon_v1',
          JourneyScenery.coast,
          const Color(0xFF131C36),
          const Color(0xFF183246),
          const Color(0xFFFFD78A),
          .75,
        ),
      ),
    ],
    landmarks: const {
      1: JourneyLandmarkKind.minor,
      20: JourneyLandmarkKind.minor,
      50: JourneyLandmarkKind.major,
      75: JourneyLandmarkKind.major,
      100: JourneyLandmarkKind.prestige,
      250: JourneyLandmarkKind.minor,
      500: JourneyLandmarkKind.major,
      1000: JourneyLandmarkKind.prestige,
    },
  );

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
