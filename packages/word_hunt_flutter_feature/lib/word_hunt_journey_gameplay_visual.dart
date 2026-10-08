import 'package:flutter/material.dart';
import 'word_hunt_gameplay_presentation.dart';
import 'word_hunt_gameplay_readability_contract.dart';
import 'word_hunt_journey_theme.dart';

/// Journey-only production readability seam. Opaque cell/panel plates make
/// contrast independent of raster art, filtering, and background sampling.
/// Legacy profiles and all gameplay/input/scoring behavior remain unchanged.
class JourneyGameplayVisual {
  static WordHuntGameplayPresentation forOrdinal(
    int ordinal, {
    JourneyThemeSchedule? schedule,
  }) {
    final theme = (schedule ?? JourneyThemeSchedule.production).themeForOrdinal(
      ordinal,
    );
    final policy = theme.readability.resolve();
    final plate = policy.compositeBackground(theme.top).withValues(alpha: 1);
    final light = policy.textMode == WordHuntTextMode.light;
    final states = {
      WordHuntReadableState.normal: plate,
      WordHuntReadableState.found:
          light ? const Color(0xFF173E35) : const Color(0xFFC8E8D5),
      WordHuntReadableState.selected:
          light ? const Color(0xFF173B59) : const Color(0xFFCEE2F5),
      WordHuntReadableState.hint:
          light ? const Color(0xFF512B38) : const Color(0xFFF5D7E0),
    };
    // The actual rendered states, not approximate background samples, must pass.
    final text = policy.foregroundColor;
    final cells = WordHuntGameplayReadabilityContract(
      textMode: policy.textMode,
      scrimColor: plate,
      scrimOpacity: 1,
      stateSurfaces: states,
    );
    if (!cells.passesAll([Colors.black, Colors.white])) {
      throw StateError('Journey gameplay cell palette is unreadable.');
    }
    final legacy = WordHuntRoutePresentationProfiles.starter.gameplayForLevel(
      levelIndex: ordinal,
      segmentIndex: (ordinal - 1) ~/ 10 + 1,
    );
    final skin = WordHuntGameplaySkin(
      id: '${theme.id}_readable',
      scaffoldColor: theme.top,
      primaryTextColor: text,
      secondaryTextColor: text,
      accentColor: theme.accent,
      surfaceColor: plate,
      surfaceBorderColor: theme.accent,
      targetSurfaceColor: plate,
      bonusSurfaceColor: plate,
      foundSurfaceColor: states[WordHuntReadableState.found]!,
      gridIdleColor: plate,
      gridSelectedColor: states[WordHuntReadableState.selected]!,
      gridFoundColor: states[WordHuntReadableState.found]!,
      gridErrorColor: states[WordHuntReadableState.hint]!,
      gridTextColor: text,
      connectorColor: theme.accent,
      connectorGlowColor: theme.accent,
      instructionSurfaceColor: plate,
      finishButtonColor: plate,
      completionSurfaceTop: plate,
      completionSurfaceBottom: theme.top,
      completionIcon: legacy.skin.completionIcon,
    );
    return WordHuntGameplayPresentation(
      profileId: 'journey_visual_v1',
      scene: legacy.scene,
      skin: skin,
    );
  }
}
