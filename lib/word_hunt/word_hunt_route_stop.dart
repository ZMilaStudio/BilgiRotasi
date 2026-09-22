import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_production_assets.dart';

/// Kelime Avı rota düğümlerinin tema bağımsız, deterministik geometrisi.
///
/// Başlangıç Limanı için kullanıcı tarafından onaylanan referans küçük rota
/// medalyonlarını kullanır. Tema değişirken geometri değişmez; yeni temalar aynı
/// ölçüleri kendi renk/doku karakterleriyle yeniden kullanır.
@immutable
class WordHuntRouteStopMetrics {
  const WordHuntRouteStopMetrics({
    required this.normalDiameter,
    required this.lockedNormalDiameter,
    required this.challengeDiameter,
    required this.bonusDiameter,
    required this.finalDiameter,
    required this.normalContainerWidth,
    required this.normalContainerHeight,
    required this.challengeContainerWidth,
    required this.bonusContainerWidth,
    required this.finalContainerWidth,
    required this.specialContainerHeight,
    required this.challengeLabelGap,
    required this.bonusLabelGap,
    required this.finalLabelGap,
    required this.challengePlaqueHeight,
    required this.bonusPlaqueHeight,
    required this.finalPlaqueHeight,
    required this.starSize,
    required this.starGap,
  });

  static const referenceBaseline = WordHuntRouteStopMetrics(
    normalDiameter: 78,
    lockedNormalDiameter: 100,
    challengeDiameter: 104,
    bonusDiameter: 104,
    finalDiameter: 142,
    normalContainerWidth: 110,
    normalContainerHeight: 128,
    challengeContainerWidth: 440,
    bonusContainerWidth: 321,
    finalContainerWidth: 406,
    specialContainerHeight: 210,
    challengeLabelGap: 12,
    bonusLabelGap: 11,
    finalLabelGap: 14,
    challengePlaqueHeight: 88,
    bonusPlaqueHeight: 82,
    finalPlaqueHeight: 110,
    starSize: 24,
    starGap: 3,
  );

  final double normalDiameter;
  final double lockedNormalDiameter;
  final double challengeDiameter;
  final double bonusDiameter;
  final double finalDiameter;
  final double normalContainerWidth;
  final double normalContainerHeight;
  final double challengeContainerWidth;
  final double bonusContainerWidth;
  final double finalContainerWidth;
  final double specialContainerHeight;
  final double challengeLabelGap;
  final double bonusLabelGap;
  final double finalLabelGap;
  final double challengePlaqueHeight;
  final double bonusPlaqueHeight;
  final double finalPlaqueHeight;
  final double starSize;
  final double starGap;

  double diameterFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.normal => normalDiameter,
    WordHuntLevelType.challenge => challengeDiameter,
    WordHuntLevelType.bonus => bonusDiameter,
    WordHuntLevelType.routeFinal => finalDiameter,
  };

  double containerWidthFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.normal => normalContainerWidth,
    WordHuntLevelType.routeFinal => finalContainerWidth,
    WordHuntLevelType.challenge => challengeContainerWidth,
    WordHuntLevelType.bonus => bonusContainerWidth,
  };

  double containerHeightFor(WordHuntLevelType type) =>
      type == WordHuntLevelType.normal
          ? normalContainerHeight
          : specialContainerHeight;

  double labelGapFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.challenge => challengeLabelGap,
    WordHuntLevelType.bonus => bonusLabelGap,
    WordHuntLevelType.routeFinal => finalLabelGap,
    WordHuntLevelType.normal => 0,
  };

  double plaqueHeightFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.challenge => challengePlaqueHeight,
    WordHuntLevelType.bonus => bonusPlaqueHeight,
    WordHuntLevelType.routeFinal => finalPlaqueHeight,
    WordHuntLevelType.normal => 0,
  };
}

/// Rota düğümünün yalnız görsel tokenlarını taşır.
///
/// Oyun durumu, kilit mantığı veya yıldız hesabı bu sınıfa girmez. Böylece
/// Liman/Orman gibi temalar aynı geometriyi farklı renk ve yüzeylerle kullanır.
@immutable
class WordHuntRouteStopTheme {
  const WordHuntRouteStopTheme({
    required this.normalAccent,
    required this.challengeAccent,
    required this.bonusAccent,
    required this.finalAccent,
    required this.lockedAccent,
    required this.surfaceOuter,
    required this.surfaceInner,
    required this.textColor,
    required this.lockColor,
    required this.starFilled,
    required this.starEmpty,
    required this.labelSurface,
  });

  static const harbor = WordHuntRouteStopTheme(
    normalAccent: Color(0xFF4CE7ED),
    challengeAccent: Color(0xFFF3A744),
    bonusAccent: Color(0xFFB765FF),
    finalAccent: Color(0xFFFFC95D),
    lockedAccent: Color(0xFF8C939E),
    surfaceOuter: Color(0xFF050D14),
    surfaceInner: Color(0xFF0C2632),
    textColor: Color(0xFFFFFBF2),
    lockColor: Color(0xFFE7E8EC),
    starFilled: Color(0xFFFFC94A),
    starEmpty: Color(0xFF59616D),
    labelSurface: Color(0xEE090E16),
  );

  final Color normalAccent;
  final Color challengeAccent;
  final Color bonusAccent;
  final Color finalAccent;
  final Color lockedAccent;
  final Color surfaceOuter;
  final Color surfaceInner;
  final Color textColor;
  final Color lockColor;
  final Color starFilled;
  final Color starEmpty;
  final Color labelSurface;

  Color accentFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.normal => normalAccent,
    WordHuntLevelType.challenge => challengeAccent,
    WordHuntLevelType.bonus => bonusAccent,
    WordHuntLevelType.routeFinal => finalAccent,
  };

  WordHuntRouteStopTheme copyWith({
    Color? normalAccent,
    Color? challengeAccent,
    Color? bonusAccent,
    Color? finalAccent,
    Color? lockedAccent,
    Color? surfaceOuter,
    Color? surfaceInner,
    Color? textColor,
    Color? lockColor,
    Color? starFilled,
    Color? starEmpty,
    Color? labelSurface,
  }) {
    return WordHuntRouteStopTheme(
      normalAccent: normalAccent ?? this.normalAccent,
      challengeAccent: challengeAccent ?? this.challengeAccent,
      bonusAccent: bonusAccent ?? this.bonusAccent,
      finalAccent: finalAccent ?? this.finalAccent,
      lockedAccent: lockedAccent ?? this.lockedAccent,
      surfaceOuter: surfaceOuter ?? this.surfaceOuter,
      surfaceInner: surfaceInner ?? this.surfaceInner,
      textColor: textColor ?? this.textColor,
      lockColor: lockColor ?? this.lockColor,
      starFilled: starFilled ?? this.starFilled,
      starEmpty: starEmpty ?? this.starEmpty,
      labelSurface: labelSurface ?? this.labelSurface,
    );
  }
}

/// 1-10 rota duraklarının ortak görsel/etkileşim bileşeni.
///
/// - Açık/kilitli durum aynı geometriyi korur.
/// - Her durakta her zaman üç yıldız yuvası bulunur.
/// - Kilitli durak callback üretmez.
/// - Tema yalnız token değiştirir; ölçüler [metrics] tarafından sabitlenir.
class WordHuntRouteStop extends StatelessWidget {
  const WordHuntRouteStop({
    super.key,
    required this.level,
    required this.stars,
    required this.unlocked,
    this.theme = WordHuntRouteStopTheme.harbor,
    this.metrics = WordHuntRouteStopMetrics.referenceBaseline,
    this.labelOnLeft = false,
    this.onTap,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final WordHuntRouteStopTheme theme;
  final WordHuntRouteStopMetrics metrics;
  final bool labelOnLeft;
  final VoidCallback? onTap;

  String get _typeLabel => switch (level.type) {
    WordHuntLevelType.normal => '',
    WordHuntLevelType.challenge => 'MEYDAN OKUMA',
    WordHuntLevelType.bonus => 'BONUS DURAK',
    WordHuntLevelType.routeFinal => 'ROTA FİNALİ',
  };

  @override
  Widget build(BuildContext context) {
    final special = level.type != WordHuntLevelType.normal;
    final lockedFinal = level.type == WordHuntLevelType.routeFinal && !unlocked;
    final accent =
        lockedFinal
            ? theme.finalAccent
            : unlocked
            ? theme.accentFor(level.type)
            : theme.lockedAccent;
    final clampedStars = stars.clamp(0, 3).toInt();

    final stopWithStars = _StopMedallionAndStars(
      level: level,
      stars: clampedStars,
      unlocked: unlocked,
      lockedFinal: lockedFinal,
      theme: theme,
      metrics: metrics,
    );

    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label:
          unlocked
              ? '${level.displayNameOrFallback}, ${_typeLabel.isEmpty ? 'normal' : _typeLabel}, $clampedStars yıldız, açık'
              : '${level.displayNameOrFallback}, kilitli',
      child: SizedBox(
        key: Key('word_hunt_route_stop_${level.index}'),
        width: metrics.containerWidthFor(level.type),
        height: metrics.containerHeightFor(level.type),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: unlocked ? onTap : null,
            borderRadius: BorderRadius.circular(42),
            child:
                special
                    ? _SpecialRow(
                      level: level,
                      unlocked: unlocked,
                      lockedFinal: lockedFinal,
                      accent: accent,
                      label: _typeLabel,
                      iconAssetPath:
                          WordHuntProductionAssets.iconFor(level.type)!,
                      labelOnLeft: labelOnLeft,
                      metrics: metrics,
                      stopWithStars: stopWithStars,
                    )
                    : Center(child: stopWithStars),
          ),
        ),
      ),
    );
  }
}

class _StopMedallionAndStars extends StatelessWidget {
  const _StopMedallionAndStars({
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.lockedFinal,
    required this.theme,
    required this.metrics,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final bool lockedFinal;
  final WordHuntRouteStopTheme theme;
  final WordHuntRouteStopMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RouteStopOrb(
          level: level,
          unlocked: unlocked,
          lockedFinal: lockedFinal,
          theme: theme,
          diameter:
              level.type == WordHuntLevelType.normal && !unlocked
                  ? metrics.lockedNormalDiameter
                  : metrics.diameterFor(level.type),
        ),
        SizedBox(height: metrics.starGap),
        _RouteStopStars(
          levelIndex: level.index,
          stars: stars,
          unlocked: unlocked,
          goldTarget: level.type == WordHuntLevelType.routeFinal,
          theme: theme,
          starSize: metrics.starSize,
        ),
      ],
    );
  }
}

class _SpecialRow extends StatelessWidget {
  const _SpecialRow({
    required this.level,
    required this.unlocked,
    required this.lockedFinal,
    required this.accent,
    required this.label,
    required this.iconAssetPath,
    required this.labelOnLeft,
    required this.metrics,
    required this.stopWithStars,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final bool lockedFinal;
  final Color accent;
  final String label;
  final String iconAssetPath;
  final bool labelOnLeft;
  final WordHuntRouteStopMetrics metrics;
  final Widget stopWithStars;

  @override
  Widget build(BuildContext context) {
    final diameter = metrics.diameterFor(level.type);
    final labelWidth =
        metrics.containerWidthFor(level.type) -
        diameter -
        metrics.labelGapFor(level.type);
    final stopLabel = Transform.translate(
      offset: Offset(
        0,
        level.type == WordHuntLevelType.routeFinal
            ? 0
            : -(metrics.starGap + metrics.starSize) / 2,
      ),
      child: SizedBox(
        width: labelWidth,
        height: metrics.plaqueHeightFor(level.type),
        child: _SpecialStopLabel(
          levelIndex: level.index,
          type: level.type,
          label: label,
          iconAssetPath: iconAssetPath,
          accent: accent,
          dimmed: !unlocked && !lockedFinal,
          emphasized: level.type == WordHuntLevelType.routeFinal,
        ),
      ),
    );
    final gap = SizedBox(width: metrics.labelGapFor(level.type));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:
          labelOnLeft
              ? <Widget>[stopLabel, gap, stopWithStars]
              : <Widget>[stopWithStars, gap, stopLabel],
    );
  }
}

class _RouteStopOrb extends StatelessWidget {
  const _RouteStopOrb({
    required this.level,
    required this.unlocked,
    required this.lockedFinal,
    required this.theme,
    required this.diameter,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final bool lockedFinal;
  final WordHuntRouteStopTheme theme;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final numberSize = switch (level.type) {
      WordHuntLevelType.normal => 30.0,
      WordHuntLevelType.challenge => 39.0,
      WordHuntLevelType.bonus => 40.0,
      WordHuntLevelType.routeFinal => 58.0,
    };
    final visuallyHighlighted = unlocked || lockedFinal;
    final numberIsBakedIntoBindingSource =
        level.type == WordHuntLevelType.challenge ||
        level.type == WordHuntLevelType.routeFinal;
    final assetPath = WordHuntProductionAssets.nodeFor(
      type: level.type,
      unlocked: unlocked,
    );

    return SizedBox.square(
      key: Key('word_hunt_route_stop_orb_${level.index}'),
      dimension: diameter,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            assetPath,
            key: Key('word_hunt_route_stop_asset_${level.index}'),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          Center(
            child:
                visuallyHighlighted
                    ? numberIsBakedIntoBindingSource
                        ? const SizedBox.shrink()
                        : Text(
                          '${level.index}',
                          key: Key(
                            'word_hunt_route_stop_number_${level.index}',
                          ),
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: numberSize,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            shadows: const <Shadow>[
                              Shadow(
                                color: Color(0xDD000000),
                                blurRadius: 3,
                                offset: Offset(0, 1.5),
                              ),
                            ],
                          ),
                        )
                    : Icon(
                      Icons.lock_rounded,
                      key: Key('word_hunt_route_stop_lock_${level.index}'),
                      color: theme.lockColor,
                      size: 34,
                      shadows: const <Shadow>[
                        Shadow(color: Color(0xCC000000), blurRadius: 3),
                      ],
                    ),
          ),
          if (level.type == WordHuntLevelType.routeFinal)
            Positioned(
              key: Key('word_hunt_route_stop_crown_${level.index}'),
              top: -42,
              left: -6,
              width: 154,
              height: 94,
              child: Image.asset(
                WordHuntProductionAssets.finalCrown,
                key: Key('word_hunt_route_stop_crown_asset_${level.index}'),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
        ],
      ),
    );
  }
}

class _RouteStopStars extends StatelessWidget {
  const _RouteStopStars({
    required this.levelIndex,
    required this.stars,
    required this.unlocked,
    required this.goldTarget,
    required this.theme,
    required this.starSize,
  });

  final int levelIndex;
  final int stars;
  final bool unlocked;
  final bool goldTarget;
  final WordHuntRouteStopTheme theme;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (index) {
        final earned = index < stars || goldTarget;
        return Icon(
          earned ? Icons.star_rounded : Icons.star_border_rounded,
          key: Key('word_hunt_route_stop_star_${levelIndex}_$index'),
          size: starSize,
          color:
              earned
                  ? theme.starFilled
                  : theme.starEmpty.withValues(alpha: unlocked ? 1 : 0.72),
          shadows:
              earned
                  ? <Shadow>[
                    Shadow(
                      color: theme.starFilled.withValues(alpha: 0.55),
                      blurRadius: 4,
                    ),
                  ]
                  : const <Shadow>[],
        );
      }),
    );
  }
}

class _SpecialStopLabel extends StatelessWidget {
  const _SpecialStopLabel({
    required this.levelIndex,
    required this.type,
    required this.label,
    required this.iconAssetPath,
    required this.accent,
    required this.dimmed,
    required this.emphasized,
  });

  final int levelIndex;
  final WordHuntLevelType type;
  final String label;
  final String iconAssetPath;
  final Color accent;
  final bool dimmed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final plaquePath = WordHuntProductionAssets.plaqueFor(type);
    final iconScale = switch (type) {
      WordHuntLevelType.challenge => 2.2,
      WordHuntLevelType.bonus => 2.0,
      WordHuntLevelType.routeFinal => 1.55,
      WordHuntLevelType.normal => 1.0,
    };
    assert(plaquePath != null);
    return Opacity(
      opacity: dimmed ? 0.72 : 1,
      child: SizedBox.expand(
        key: Key('word_hunt_route_stop_plaque_$levelIndex'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              plaquePath!,
              key: Key('word_hunt_route_stop_plaque_asset_$levelIndex'),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: emphasized ? 42 : 38,
                    child: ClipRect(
                      child: Transform.scale(
                        key: Key(
                          'word_hunt_route_stop_special_icon_scale_$levelIndex',
                        ),
                        scale: iconScale,
                        child: Image.asset(
                          iconAssetPath,
                          key: Key(
                            'word_hunt_route_stop_special_icon_$levelIndex',
                          ),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: label == 'MEYDAN OKUMA' ? 1 : 2,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent,
                        fontFamily: 'serif',
                        fontSize:
                            label == 'MEYDAN OKUMA'
                                ? 24.0
                                : emphasized
                                ? 29.0
                                : 24.0,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
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
}
