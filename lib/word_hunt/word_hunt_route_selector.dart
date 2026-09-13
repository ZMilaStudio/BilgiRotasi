import 'package:flutter/material.dart';

import 'word_hunt_progress.dart';
import 'word_hunt_route_catalog.dart';

/// Production Kelime Avı rota seçicisi.
///
/// Kart sayısı ve unlock koşulları widget içinde hard-code edilmez; bütün
/// görünür rotalar [WordHuntRouteCatalog.entries] üzerinden üretilir.
class WordHuntRouteSelector extends StatelessWidget {
  const WordHuntRouteSelector({
    super.key,
    required this.progress,
    required this.onRouteTap,
  });

  final WordHuntProgressSnapshot progress;
  final ValueChanged<WordHuntRouteCatalogEntry> onRouteTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('word_hunt_route_selector'),
      backgroundColor: const Color(0xFF071426),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071426),
        foregroundColor: Colors.white,
        elevation: 0,
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
                  const Text(
                    'Her rota 10 bölüm ve 30 yıldızlık ayrı bir macera.',
                    style: TextStyle(
                      color: Color(0xFFB7C7DA),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (var index = 0;
                      index < WordHuntRouteCatalog.entries.length;
                      index++) ...<Widget>[
                    _buildCatalogCard(WordHuntRouteCatalog.entries[index]),
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

  Widget _buildCatalogCard(WordHuntRouteCatalogEntry entry) {
    final unlocked = entry.isUnlocked(progress);
    final unlockRule = entry.unlockRule;
    final subtitle = unlocked
        ? '${entry.ordinalLabel} • 10 bölüm • 30 yıldız'
        : _lockedSubtitle(unlockRule);
    final progressText = unlocked
        ? '${WordHuntRouteProgressEngine.totalStars(entry.route, progress)} / ${entry.route.maximumStars}'
        : _lockedProgressText(unlockRule);

    return _WordHuntRouteCard(
      key: Key('word_hunt_route_card_${entry.cardKey}'),
      title: entry.route.title,
      subtitle: subtitle,
      progressText: progressText,
      icon: unlocked ? entry.icon : Icons.lock_rounded,
      colors: entry.colors,
      unlocked: unlocked,
      onTap: () => onRouteTap(entry),
    );
  }

  String _lockedSubtitle(WordHuntRouteUnlockRule rule) {
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
        return '${rule.currentStars(progress).clamp(0, rule.requiredStars)} / ${rule.requiredStars}';
      case WordHuntRouteUnlockKind.routeComplete:
        final totalLevels = prerequisite?.levels.length ?? 0;
        return '${rule.currentCompletedLevels(progress).clamp(0, totalLevels)} / $totalLevels bölüm';
    }
  }
}

class _WordHuntRouteCard extends StatelessWidget {
  const _WordHuntRouteCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progressText,
    required this.icon,
    required this.colors,
    required this.unlocked,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String progressText;
  final IconData icon;
  final List<Color> colors;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: unlocked,
      label: '$title, $subtitle, $progressText',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: unlocked
                    ? const Color(0x66FFFFFF)
                    : const Color(0x447A8CA5),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 14,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x33000000),
                    border: Border.all(color: const Color(0x55FFFFFF)),
                  ),
                  child: Icon(icon, color: Colors.white, size: 34),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
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
                      const SizedBox(height: 9),
                      Text(
                        progressText,
                        style: const TextStyle(
                          color: Color(0xFFFFE082),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  unlocked
                      ? Icons.chevron_right_rounded
                      : Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
