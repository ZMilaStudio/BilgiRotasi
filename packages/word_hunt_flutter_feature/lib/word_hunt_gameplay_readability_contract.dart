import 'package:flutter/material.dart';

enum WordHuntTextMode { light, dark }

enum WordHuntReadableState { normal, found, selected, hint }

class WordHuntGameplayReadabilityContract {
  const WordHuntGameplayReadabilityContract({
    required this.textMode,
    required this.scrimColor,
    required this.scrimOpacity,
    this.minimumContrastRatio = 4.5,
    this.stateForegrounds = const {},
    this.stateSurfaces = const {},
  }) : assert(scrimOpacity >= 0 && scrimOpacity <= 1),
       assert(minimumContrastRatio >= 1);

  final WordHuntTextMode textMode;
  final Color scrimColor;
  final double scrimOpacity;
  final double minimumContrastRatio;
  final Map<WordHuntReadableState, Color> stateForegrounds;
  final Map<WordHuntReadableState, Color> stateSurfaces;

  Color foregroundFor(WordHuntReadableState state) =>
      stateForegrounds[state] ?? foregroundColor;
  Color backgroundFor(Color sample, WordHuntReadableState state) =>
      Color.alphaBlend(
        stateSurfaces[state] ?? const Color(0x00000000),
        compositeBackground(sample),
      );

  Color get foregroundColor =>
      textMode == WordHuntTextMode.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF111111);

  Color compositeBackground(Color representativeBackground) {
    return Color.alphaBlend(
      scrimColor.withValues(alpha: scrimOpacity),
      representativeBackground,
    );
  }

  double contrastRatioAgainst(
    Color representativeBackground, {
    WordHuntReadableState state = WordHuntReadableState.normal,
  }) {
    final background = backgroundFor(representativeBackground, state);
    final foreground = foregroundFor(state);
    if (representativeBackground.a != 1 || foreground.a != 1) {
      throw ArgumentError(
        'Contrast requires opaque background samples and text.',
      );
    }
    final a = foreground.computeLuminance();
    final b = background.computeLuminance();
    final lighter = a > b ? a : b;
    final darker = a > b ? b : a;
    return (lighter + 0.05) / (darker + 0.05);
  }

  bool passes(Color representativeBackground) =>
      WordHuntReadableState.values.every(
        (state) =>
            contrastRatioAgainst(representativeBackground, state: state) >=
            minimumContrastRatio,
      );

  bool passesAll(Iterable<Color> samples) {
    final values = samples.toList();
    if (values.isEmpty)
      throw ArgumentError('Representative samples must not be empty.');
    return values.every(passes);
  }

  WordHuntGameplayReadabilityContract _withOpacity(double value) =>
      WordHuntGameplayReadabilityContract(
        textMode: textMode,
        scrimColor: scrimColor,
        scrimOpacity: value,
        minimumContrastRatio: minimumContrastRatio,
        stateForegrounds: stateForegrounds,
        stateSurfaces: stateSurfaces,
      );

  /// Theme/gameplay integration API: samples must cover the board and every
  /// state surface. Never silently accepts an uncorrectable color combination.
  WordHuntGameplayReadabilityContract correctedFor(Iterable<Color> samples) {
    final values = samples.toList();
    if (passesAll(values)) return this;
    if (!_withOpacity(1).passesAll(values)) {
      throw StateError(
        'Text/state palette cannot meet the readability threshold.',
      );
    }
    var low = scrimOpacity;
    var high = 1.0;
    for (var i = 0; i < 32; i++) {
      final mid = (low + high) / 2;
      if (_withOpacity(mid).passesAll(values)) {
        high = mid;
      } else {
        low = mid;
      }
    }
    return _withOpacity(high);
  }
}

class WordHuntGameplayReadabilityPresets {
  static const lightOnDark = WordHuntGameplayReadabilityContract(
    textMode: WordHuntTextMode.light,
    scrimColor: Color(0xFF000000),
    scrimOpacity: 0.56,
  );

  static const darkOnLight = WordHuntGameplayReadabilityContract(
    textMode: WordHuntTextMode.dark,
    scrimColor: Color(0xFFFFFFFF),
    scrimOpacity: 0.62,
  );
}

/// Independent future gameplay surface; does not alter existing production UI.
/// The builder receives the validated palette for letters and all input states.
class WordHuntGameplayReadabilitySurface extends StatelessWidget {
  const WordHuntGameplayReadabilitySurface({
    super.key,
    required this.contract,
    required this.samples,
    required this.background,
    required this.builder,
  });
  final WordHuntGameplayReadabilityContract contract;
  final List<Color> samples;
  final Widget background;
  final Widget Function(BuildContext, WordHuntGameplayReadabilityContract)
  builder;
  @override
  Widget build(BuildContext context) {
    final resolved = contract.correctedFor(samples);
    return Stack(
      fit: StackFit.expand,
      children: [
        background,
        IgnorePointer(
          child: ExcludeSemantics(
            child: ColoredBox(
              color: resolved.scrimColor.withValues(
                alpha: resolved.scrimOpacity,
              ),
            ),
          ),
        ),
        builder(context, resolved),
      ],
    );
  }
}
