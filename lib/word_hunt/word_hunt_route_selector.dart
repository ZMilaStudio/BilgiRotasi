import 'package:flutter/material.dart';

import 'word_hunt_progress.dart';
import 'word_hunt_route_catalog.dart';
import 'word_hunt_route_rewards.dart';

/// Production Kelime Avı rota seçicisi.
///
/// Kart sayısı ve unlock koşulları widget içinde hard-code edilmez; bütün
/// görünür rotalar [WordHuntRouteCatalog.entries] üzerinden üretilir.
class WordHuntRouteSelector extends StatelessWidget {
  const WordHuntRouteSelector({
    super.key,
    required this.progress,
    required this.onRouteTap,
    this.onBack,
  });

  final WordHuntProgressSnapshot progress;
  final ValueChanged<WordHuntRouteCatalogEntry> onRouteTap;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final recommendedEntry = _recommendedEntry();
    final allRoutesComplete =
        WordHuntRouteCatalog.entries.isNotEmpty &&
        WordHuntRouteCatalog.entries.every(
          (entry) => WordHuntRouteProgressEngine.isRouteComplete(
            entry.route,
            progress,
          ),
        );

    return Scaffold(
      key: const Key('word_hunt_route_selector'),
      backgroundColor: const Color(0xFF071426),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071426),
        foregroundColor: Colors.white,
        elevation: 0,
        leading:
            onBack == null
                ? null
                : IconButton(
                  key: const Key('word_hunt_route_selector_back'),
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
        title: const Text(
          'Kelime Avı',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 390;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                compact ? 14 : 20,
                12,
                compact ? 14 : 20,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Rotanı seç',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 24 : 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    allRoutesComplete
                        ? 'Tüm mevcut rotaları tamamladın.'
                        : 'Her rota 10 bölüm ve 30 yıldızlık ayrı bir macera.',
                    key: const Key('word_hunt_route_selector_summary'),
                    style: const TextStyle(
                      color: Color(0xFFB7C7DA),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (
                    var index = 0;
                    index < WordHuntRouteCatalog.entries.length;
                    index++
                  ) ...<Widget>[
                    _buildCatalogCard(
                      context,
                      WordHuntRouteCatalog.entries[index],
                      recommendedEntry: recommendedEntry,
                      compact: compact,
                    ),
                    if (index < WordHuntRouteCatalog.entries.length - 1)
                      const SizedBox(height: 14),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  WordHuntRouteCatalogEntry? _recommendedEntry() {
    for (final entry in WordHuntRouteCatalog.entries) {
      if (entry.isUnlocked(progress) &&
          !WordHuntRouteProgressEngine.isRouteComplete(
            entry.route,
            progress,
          )) {
        return entry;
      }
    }
    return null;
  }

  Widget _buildCatalogCard(
    BuildContext context,
    WordHuntRouteCatalogEntry entry, {
    required WordHuntRouteCatalogEntry? recommendedEntry,
    required bool compact,
  }) {
    final unlocked = entry.isUnlocked(progress);
    final unlockRule = entry.unlockRule;
    final totalStars = WordHuntRouteProgressEngine.totalStars(
      entry.route,
      progress,
    );
    final routeComplete = WordHuntRouteProgressEngine.isRouteComplete(
      entry.route,
      progress,
    );
    final hasProgress = totalStars > 0;
    final recommended = identical(entry, recommendedEntry);
    final reward = WordHuntRouteRewardCatalog.forRoute(entry.route);
    final rewardEarned = progress.unlockedRouteRewardIds.contains(
      entry.route.routeRewardId,
    );
    final subtitle = unlocked
        ? '${entry.route.levels.length} bölüm • ${entry.route.maximumStars} yıldız'
        : _lockedSubtitle(entry);
    final progressText = unlocked
        ? '$totalStars / ${entry.route.maximumStars} yıldız'
        : _lockedProgressText(unlockRule);
    final stateLabel = !unlocked
        ? 'Kilitli'
        : routeComplete
        ? 'Tamamlandı'
        : recommended
        ? (hasProgress ? 'Devam Et' : 'Sıradaki')
        : null;

    void showLockedFeedback() {
      final message = entry.lockedMessage ?? _lockedSubtitle(entry);
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }

    return _WordHuntRouteCard(
      key: Key('word_hunt_route_card_${entry.cardKey}'),
      cardKey: entry.cardKey,
      title: entry.route.title,
      ordinalLabel: entry.ordinalLabel,
      subtitle: subtitle,
      progressText: progressText,
      icon: entry.icon,
      colors: entry.colors,
      unlocked: unlocked,
      routeComplete: routeComplete,
      recommended: recommended,
      stateLabel: stateLabel,
      earnedReward: rewardEarned ? reward : null,
      compact: compact,
      onTap: unlocked ? () => onRouteTap(entry) : null,
      onLockedTap: unlocked ? null : showLockedFeedback,
    );
  }

  String _lockedSubtitle(WordHuntRouteCatalogEntry entry) {
    final lockedMessage = entry.lockedMessage;
    if (lockedMessage != null) return lockedMessage;

    final rule = entry.unlockRule;
    final prerequisite = rule.prerequisiteRoute;
    switch (rule.kind) {
      case WordHuntRouteUnlockKind.always:
        return 'Henüz açık değil.';
      case WordHuntRouteUnlockKind.routeStars:
        if (prerequisite == null) return 'Henüz açık değil.';
        return 'Kapı: ${rule.requiredStars} ${prerequisite.title} yıldızı';
      case WordHuntRouteUnlockKind.routeComplete:
        if (prerequisite == null || prerequisite.levels.isEmpty) {
          return 'Henüz açık değil.';
        }
        return 'Kapı: ${prerequisite.title} ${prerequisite.levels.length}. bölümü tamamla';
    }
  }

  String _lockedProgressText(WordHuntRouteUnlockRule rule) {
    final prerequisite = rule.prerequisiteRoute;
    switch (rule.kind) {
      case WordHuntRouteUnlockKind.always:
        return 'Kilitli';
      case WordHuntRouteUnlockKind.routeStars:
        final current = rule.currentStars(progress).clamp(
          0,
          rule.requiredStars,
        );
        return '$current / ${rule.requiredStars} yıldız';
      case WordHuntRouteUnlockKind.routeComplete:
        if (prerequisite == null || prerequisite.levels.isEmpty) {
          return 'Kilitli';
        }

        final totalLevels = prerequisite.levels.length;
        final completedLevels = rule.currentCompletedLevels(progress).clamp(
          0,
          totalLevels,
        );
        final finalCompleted = WordHuntRouteProgressEngine.isLevelCompleted(
          prerequisite.levels.last,
          progress,
        );

        if (!finalCompleted) {
          return '$completedLevels / $totalLevels bölüm';
        }

        final requiredStars = prerequisite.unlockStarsRequired;
        final currentStars = WordHuntRouteProgressEngine.totalStars(
          prerequisite,
          progress,
        );
        if (requiredStars > 0 && currentStars < requiredStars) {
          return '${currentStars.clamp(0, requiredStars)} / $requiredStars yıldız';
        }

        return '$completedLevels / $totalLevels bölüm';
    }
  }
}

class _WordHuntRouteCard extends StatelessWidget {
  const _WordHuntRouteCard({
    super.key,
    required this.cardKey,
    required this.title,
    required this.ordinalLabel,
    required this.subtitle,
    required this.progressText,
    required this.icon,
    required this.colors,
    required this.unlocked,
    required this.routeComplete,
    required this.recommended,
    required this.stateLabel,
    required this.earnedReward,
    required this.compact,
    required this.onTap,
    required this.onLockedTap,
  });

  final String cardKey;
  final String title;
  final String ordinalLabel;
  final String subtitle;
  final String progressText;
  final IconData icon;
  final List<Color> colors;
  final bool unlocked;
  final bool routeComplete;
  final bool recommended;
  final String? stateLabel;
  final WordHuntRouteRewardDefinition? earnedReward;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onLockedTap;

  @override
  Widget build(BuildContext context) {
    final reward = earnedReward;
    final semanticsParts = <String>[
      title,
      if (stateLabel != null) stateLabel!,
      ordinalLabel,
      subtitle,
      progressText,
      if (reward != null) 'Rozet kazanıldı, ${reward.displayName}',
    ];

    final surfaceColors = colors
        .map(
          (color) => Color.alphaBlend(
            unlocked
                ? routeComplete
                      ? const Color(0x44071426)
                      : const Color(0x00000000)
                : const Color(0x88071426),
            color,
          ),
        )
        .toList(growable: false);

    final borderColor = recommended
        ? const Color(0xCCFFE082)
        : unlocked
        ? routeComplete
              ? const Color(0x557A8CA5)
              : const Color(0x66FFFFFF)
        : const Color(0x557A8CA5);

    final shadows = recommended
        ? const <BoxShadow>[
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x33FFE082),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ]
        : unlocked && !routeComplete
        ? const <BoxShadow>[
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ]
        : const <BoxShadow>[
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ];

    return Semantics(
      key: Key('word_hunt_route_semantics_$cardKey'),
      container: true,
      button: unlocked,
      enabled: unlocked,
      onTap: unlocked ? onTap : null,
      label: semanticsParts.join(', '),
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            excludeFromSemantics: true,
            onTap: unlocked ? onTap : onLockedTap,
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              padding: EdgeInsets.all(compact ? 14 : 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: surfaceColors,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: borderColor,
                  width: recommended ? 1.6 : 1,
                ),
                boxShadow: shadows,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: compact ? 48 : 64,
                    height: compact ? 48 : 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x33000000),
                      border: Border.all(
                        color: recommended
                            ? const Color(0x99FFE082)
                            : const Color(0x55FFFFFF),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: compact ? 28 : 34,
                    ),
                  ),
                  SizedBox(width: compact ? 10 : 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 18 : 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (stateLabel != null || reward != null) ...<Widget>[
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 7,
                            runSpacing: 6,
                            children: <Widget>[
                              if (stateLabel != null)
                                _RouteStatusChip(
                                  key: Key('word_hunt_route_state_$cardKey'),
                                  icon: !unlocked
                                      ? Icons.lock_outline_rounded
                                      : routeComplete
                                      ? Icons.check_circle_rounded
                                      : recommended
                                      ? Icons.play_arrow_rounded
                                      : Icons.circle_outlined,
                                  label: stateLabel!,
                                  accent: recommended
                                      ? const Color(0xFFFFE082)
                                      : routeComplete
                                      ? const Color(0xFFC9E6D2)
                                      : const Color(0xFFD5E0EC),
                                  compact: compact,
                                ),
                              if (reward != null)
                                _RouteStatusChip(
                                  key: Key(
                                    'word_hunt_route_reward_earned_${reward.id}',
                                  ),
                                  icon: reward.icon,
                                  label: 'Rozet kazanıldı',
                                  accent: const Color(0xFFFFE082),
                                  compact: compact,
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 7),
                        Text(
                          ordinalLabel,
                          key: Key('word_hunt_route_ordinal_$cardKey'),
                          style: const TextStyle(
                            color: Color(0xFFB8C7D8),
                            fontSize: 11,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFFE5ECF5),
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progressText,
                          key: Key('word_hunt_route_progress_$cardKey'),
                          style: TextStyle(
                            color: recommended
                                ? const Color(0xFFFFE082)
                                : const Color(0xFFD8E3EF),
                            fontSize: 13,
                            fontWeight: recommended
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 10),
                  Icon(
                    unlocked
                        ? Icons.chevron_right_rounded
                        : Icons.lock_outline_rounded,
                    color: unlocked
                        ? Colors.white
                        : const Color(0xFFD5E0EC),
                    size: compact ? 24 : 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteStatusChip extends StatelessWidget {
  const _RouteStatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 7,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0x26000000),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withAlpha(122)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 2,
        children: <Widget>[
          Icon(icon, size: compact ? 14 : 15, color: accent),
          Text(
            label,
            softWrap: true,
            style: TextStyle(
              color: accent,
              fontSize: compact ? 11.5 : 12,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
