import 'dart:ui';

enum WordHuntTextMode { light, dark }

class WordHuntGameplayReadabilityContract {
  const WordHuntGameplayReadabilityContract({
    required this.textMode,
    required this.scrimColor,
    required this.scrimOpacity,
    this.minimumContrastRatio = 4.5,
  }) : assert(scrimOpacity >= 0 && scrimOpacity <= 1),
       assert(minimumContrastRatio >= 1);

  final WordHuntTextMode textMode;
  final Color scrimColor;
  final double scrimOpacity;
  final double minimumContrastRatio;

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

  double contrastRatioAgainst(Color representativeBackground) {
    final background = compositeBackground(representativeBackground);
    final a = foregroundColor.computeLuminance();
    final b = background.computeLuminance();
    final lighter = a > b ? a : b;
    final darker = a > b ? b : a;
    return (lighter + 0.05) / (darker + 0.05);
  }

  bool passes(Color representativeBackground) =>
      contrastRatioAgainst(representativeBackground) >= minimumContrastRatio;
}

class WordHuntGameplayReadabilityPresets {
  static const lightOnDark = WordHuntGameplayReadabilityContract(
    textMode: WordHuntTextMode.light,
    scrimColor: Color(0xFF000000),
    scrimOpacity: 0.52,
  );

  static const darkOnLight = WordHuntGameplayReadabilityContract(
    textMode: WordHuntTextMode.dark,
    scrimColor: Color(0xFFFFFFFF),
    scrimOpacity: 0.62,
  );
}
