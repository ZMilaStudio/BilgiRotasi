import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_gameplay_readability_contract.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_background.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_theme.dart';

void main() {
  final schedule = JourneyThemeSchedule.synthetic;
  test(
    'map dual-tone path and node plates remain readable across theme blend',
    () {
      double contrast(Color a, Color b) {
        final x = a.computeLuminance(), y = b.computeLuminance();
        return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
      }

      for (var ordinal = 1; ordinal <= 410; ordinal++) {
        final frame = schedule.transitionForOrdinal(ordinal);
        for (final background in [
          frame.top,
          frame.bottom,
          Color.lerp(frame.top, frame.bottom, .5)!,
        ]) {
          final core = contrast(const Color(0xFFD9C79A), background);
          final outline = contrast(const Color(0xFF08121D), background);
          expect(
            core > outline ? core : outline,
            greaterThanOrEqualTo(3),
            reason:
                'Separate map stroke visibility contract, not gameplay contrast.',
          );
        }
      }
      for (final plate in [
        const Color(0xFF5C6670),
        const Color(0xFF985700),
        const Color(0xFF22614E),
      ]) {
        expect(contrast(Colors.white, plate), greaterThanOrEqualTo(4.5));
      }
    },
  );
  test(
    'constant-size schedule, boundary blend, stable IDs and sparse landmarks',
    () {
      expect(schedule.themes.length, 4);
      for (final pair in [
        (50, 'coast_v1'),
        (150, 'forest_v1'),
        (250, 'sky_v1'),
        (350, 'night_v1'),
        (15000, 'forest_v1'),
      ]) {
        expect(schedule.themeForOrdinal(pair.$1).id, pair.$2);
      }
      expect(schedule.transitionForOrdinal(100).mix, 1);
      final first = schedule.transitionForOrdinal(101);
      expect(first.from.id, 'coast_v1');
      expect(first.to.id, 'forest_v1');
      expect(first.mix, .1);
      expect(first.top, Color.lerp(first.from.top, first.to.top, .1));
      expect(first.decorDensity, closeTo(.82, .00001));
      expect(schedule.transitionForOrdinal(110).mix, 1);
      expect(schedule.transitionForOrdinal(111).from.id, 'forest_v1');
      expect(schedule.transitionForOrdinal(401).from.id, 'night_v1');
      expect(schedule.landmarkForOrdinal(50), JourneyLandmarkKind.minor);
      expect(schedule.landmarkForOrdinal(100), JourneyLandmarkKind.major);
      expect(schedule.landmarkForOrdinal(1000), JourneyLandmarkKind.prestige);
      expect(schedule.landmarkForOrdinal(101), isNull);
      expect(() => schedule.themeForOrdinal(0), throwsRangeError);
      expect(
        () => JourneyThemeSchedule(themes: [], transitionLevels: 0),
        throwsArgumentError,
      );
      expect(
        () => JourneyThemeSchedule(
          themes: schedule.themes,
          transitionLevels: 101,
        ),
        throwsArgumentError,
      );
      expect(
        () => JourneyThemeSchedule(
          themes: [schedule.themes.first, schedule.themes.first],
        ),
        throwsArgumentError,
      );
    },
  );
  test('deterministic decor is local, bounded, and independent of state', () {
    final a = JourneyDecor.forChunk(4981, 20, 360, 112);
    final b = JourneyDecor.forChunk(4981, 20, 360, 112);
    expect(a.length, 40);
    for (var i = 0; i < a.length; i++) {
      expect(a[i].position, b[i].position);
      expect(a[i].radius, b[i].radius);
      expect(a[i].position.dy, inInclusiveRange(0, 2240));
      expect(a[i].position.dx, inInclusiveRange(0, 360));
    }
    expect(
      JourneyDecor.forChunk(5001, 20, 360, 112).first.position,
      isNot(a.first.position),
    );
  });
  test(
    'every theme guards all gradient/decor samples and all gameplay states',
    () {
      for (final theme in schedule.themes) {
        final resolved = theme.readability.resolve();
        expect(resolved.passesAll(theme.readability.samples), isTrue);
        expect(
          theme.readability.safeArea,
          const Rect.fromLTRB(.08, .18, .92, .82),
        );
        for (final state in WordHuntReadableState.values) {
          for (final sample in theme.readability.samples) {
            expect(
              resolved.contrastRatioAgainst(sample, state: state),
              greaterThanOrEqualTo(4.5),
            );
          }
        }
      }
    },
  );
  test(
    'Fırtına Geçidi / Kayıp Şehir similar-value palette corrected, not accepted blindly',
    () {
      const bad = WordHuntGameplayReadabilityContract(
        textMode: WordHuntTextMode.light,
        scrimColor: Colors.black,
        scrimOpacity: .05,
        stateForegrounds: {
          WordHuntReadableState.found: Color(0xFFDDDDDD),
          WordHuntReadableState.selected: Color(0xFFEEEEEE),
          WordHuntReadableState.hint: Color(0xFFE8E8E8),
        },
      );
      final profile = JourneyThemeReadability(
        contract: bad,
        samples: [const Color(0xFFCCCCCC), Colors.white],
      );
      expect(bad.passesAll(profile.samples), isFalse);
      expect(profile.resolve().scrimOpacity, greaterThan(bad.scrimOpacity));
      expect(profile.resolve().passesAll(profile.samples), isTrue);
    },
  );
  test('safe dark/light and uncorrectable state surface fail-closed', () {
    expect(
      JourneyThemeReadability(
        contract: WordHuntGameplayReadabilityPresets.lightOnDark,
        samples: [Colors.black],
      ).resolve().scrimOpacity,
      .56,
    );
    expect(
      JourneyThemeReadability(
        contract: WordHuntGameplayReadabilityPresets.darkOnLight,
        samples: [Colors.white],
      ).resolve().scrimOpacity,
      .62,
    );
    expect(
      () => JourneyThemeReadability(
        contract: const WordHuntGameplayReadabilityContract(
          textMode: WordHuntTextMode.light,
          scrimColor: Colors.black,
          scrimOpacity: .5,
          stateSurfaces: {WordHuntReadableState.hint: Colors.white},
        ),
        samples: [Colors.white],
      ),
      throwsStateError,
    );
    expect(
      () => JourneyThemeReadability(
        contract: WordHuntGameplayReadabilityPresets.lightOnDark,
        samples: [],
      ),
      throwsArgumentError,
    );
    expect(
      () => JourneyThemeReadability(
        contract: WordHuntGameplayReadabilityPresets.lightOnDark,
        samples: [Colors.black],
        safeArea: const Rect.fromLTRB(-.1, 0, 1, 1),
      ),
      throwsArgumentError,
    );
  });
  test(
    'future art metadata is validated; no node coordinates or eager resources',
    () {
      final art = JourneyArtAsset(
        path: 'future/coast.webp',
        intrinsicSize: const Size(941, 1672),
        sha256: List.filled(64, 'a').join(),
        focalPoint: const Alignment(.3, -.2),
      );
      expect(art.fit, BoxFit.cover);
      expect(art.intrinsicSize, const Size(941, 1672));
      expect(
        () => JourneyArtAsset(
          path: '',
          intrinsicSize: const Size(0, 1),
          sha256: 'bad',
        ),
        throwsArgumentError,
      );
      expect(schedule.themes.every((t) => t.art == null), isTrue);
    },
  );
}
