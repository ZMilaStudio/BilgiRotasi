import 'package:flutter/material.dart';

import 'word_hunt_completion_orchestration.dart';
import 'word_hunt_models.dart';

enum WordHuntCompletionUiAction { primary, returnToRoute, routes, home }

class WordHuntCompletionPresentation extends StatelessWidget {
  const WordHuntCompletionPresentation({super.key, required this.destination});

  final WordHuntCompletionDestination destination;

  bool get _strong =>
      destination.routeCompletedNow || destination.isTrueRouteFinal;

  String get _title {
    if (_strong) return 'Rota Tamamlandı';
    if (destination.segmentCompletedNow) return 'Bölge Tamamlandı';
    return 'Bölüm Tamamlandı';
  }

  String get _primaryLabel {
    return switch (destination.kind) {
      WordHuntCompletionDestinationKind.nextLevel => 'Sonraki Bölüm',
      WordHuntCompletionDestinationKind.nextSegment => 'Sonraki Bölge',
      WordHuntCompletionDestinationKind.nextRoute => 'Sonraki Rotaya Geç',
      WordHuntCompletionDestinationKind.returnToRoute => 'Haritaya Dön',
      WordHuntCompletionDestinationKind.terminalRouteComplete => 'Rotalar',
    };
  }

  @override
  Widget build(BuildContext context) {
    final summary = destination.summary;
    final skin = summary.presentationProfile.gameplaySkin;
    final reward = summary.reward;
    final infoReward = destination.milestoneInfoReward;
    final nextRoute = summary.nextUnlockedRoute;
    final bonusText =
        summary.hasUnknownBonusHistory
            ? 'Kaydedilen bonus: ' +
                summary.knownBonusFoundTotal.toString() +
                ' / ' +
                summary.maximumBonusTotal.toString() +
                ' • Eski bölümlerde bilinmeyen kayıt var'
            : 'Bonus: ' +
                summary.knownBonusFoundTotal.toString() +
                ' / ' +
                summary.maximumBonusTotal.toString();

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final surfaceHeight = (viewportHeight * (_strong ? 0.90 : 0.78)).clamp(
      360.0,
      720.0,
    );

    return Dialog(
      key: Key(
        _strong
            ? 'word_hunt_route_completion_surface'
            : 'word_hunt_level_completion_surface',
      ),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.all(_strong ? 10 : 22),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _strong ? 460 : 390,
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: Container(
          height: surfaceHeight,
          padding: EdgeInsets.fromLTRB(
            _strong ? 24 : 20,
            _strong ? 26 : 20,
            _strong ? 24 : 20,
            18,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                skin.completionSurfaceTop,
                skin.completionSurfaceBottom,
              ],
            ),
            borderRadius: BorderRadius.circular(_strong ? 30 : 24),
            border: Border.all(
              color: skin.accentColor,
              width: _strong ? 1.8 : 1.2,
            ),
            boxShadow: <BoxShadow>[
              const BoxShadow(
                color: Color(0xB0000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
              BoxShadow(
                color: skin.connectorGlowColor,
                blurRadius: _strong ? 24 : 14,
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        skin.completionIcon,
                        key: const Key('word_hunt_completion_profile_icon'),
                        color: skin.accentColor,
                        size: _strong ? 52 : 34,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _title,
                        key: const Key('word_hunt_completion_title'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: skin.primaryTextColor,
                          fontSize: _strong ? 28 : 23,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        summary.routeTitle,
                        key: const Key('word_hunt_completion_route_title'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: skin.accentColor,
                          fontSize: _strong ? 17 : 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (destination.isMajorMidpoint) ...<Widget>[
                        const SizedBox(height: 9),
                        Text(
                          'Yolun yarısı tamamlandı',
                          key: const Key('word_hunt_completion_midpoint'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: skin.primaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _SummaryMetric(
                        label: 'Yıldız',
                        value:
                            summary.totalStars.toString() +
                            ' / ' +
                            summary.maximumStars.toString(),
                        color: skin.primaryTextColor,
                        surface: skin.surfaceColor,
                        border: skin.surfaceBorderColor,
                      ),
                      const SizedBox(height: 8),
                      _SummaryMetric(
                        key: const Key('word_hunt_completion_bonus_summary'),
                        label: 'Bonus',
                        value: bonusText,
                        color: skin.primaryTextColor,
                        surface: skin.surfaceColor,
                        border: skin.surfaceBorderColor,
                      ),
                      if (infoReward.shouldPresent) ...<Widget>[
                        const SizedBox(height: 12),
                        _MilestoneInfoRewardSection(
                          cards: infoReward.newlyGrantedCards,
                          accent: skin.accentColor,
                          primaryText: skin.primaryTextColor,
                          secondaryText: skin.secondaryTextColor,
                          surface: skin.bonusSurfaceColor,
                          border: skin.surfaceBorderColor,
                        ),
                      ],
                      if (_strong && reward != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Container(
                          key: const Key('word_hunt_completion_reward'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: skin.bonusSurfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: skin.surfaceBorderColor),
                          ),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                reward.icon,
                                color: skin.accentColor,
                                size: 32,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                summary.rewardGrantedNow
                                    ? 'Rozet Kazandın'
                                    : 'Rota Rozeti',
                                style: TextStyle(
                                  color: skin.secondaryTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                reward.displayName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: skin.primaryTextColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_strong) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          nextRoute != null
                              ? nextRoute.route.title + ' rotası hazır.'
                              : summary.terminal
                              ? 'Tüm mevcut rotaları tamamladın.'
                              : 'Rotaya dönebilirsin.',
                          key: const Key(
                            'word_hunt_completion_next_route_state',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: skin.secondaryTextColor,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  key: const Key('word_hunt_completion_primary'),
                  onPressed:
                      () => Navigator.of(context).pop(
                        destination.kind ==
                                WordHuntCompletionDestinationKind
                                    .terminalRouteComplete
                            ? WordHuntCompletionUiAction.routes
                            : WordHuntCompletionUiAction.primary,
                      ),
                  style: FilledButton.styleFrom(
                    backgroundColor: skin.finishButtonColor,
                    foregroundColor: skin.primaryTextColor,
                    side: BorderSide(color: skin.accentColor),
                  ),
                  child: Text(_primaryLabel),
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  key: const Key('word_hunt_completion_return_route'),
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).pop(WordHuntCompletionUiAction.returnToRoute),
                  style: TextButton.styleFrom(
                    foregroundColor: skin.primaryTextColor,
                  ),
                  child: const Text('Haritaya Dön'),
                ),
              ),
              if (summary.terminal) ...<Widget>[
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    key: const Key('word_hunt_completion_home'),
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pop(WordHuntCompletionUiAction.home),
                    style: TextButton.styleFrom(
                      foregroundColor: skin.secondaryTextColor,
                    ),
                    child: const Text('Kelime Avı Ana Sayfa'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class _MilestoneInfoRewardSection extends StatelessWidget {
  const _MilestoneInfoRewardSection({
    required this.cards,
    required this.accent,
    required this.primaryText,
    required this.secondaryText,
    required this.surface,
    required this.border,
  });

  final List<WordHuntInfoCard> cards;
  final Color accent;
  final Color primaryText;
  final Color secondaryText;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('word_hunt_completion_info_reward'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            cards.length == 1 ? 'Yeni Bilgi Kartı' : 'Bilgi Kartları Açıldı',
            key: const Key('word_hunt_completion_info_reward_title'),
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < cards.length; index++) ...<Widget>[
            if (index > 0) Divider(height: 18, color: border),
            Text(
              cards[index].title,
              key: Key('word_hunt_completion_info_card_${cards[index].id}'),
              style: TextStyle(
                color: primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              cards[index].shortFact,
              style: TextStyle(
                color: primaryText,
                fontSize: 12.5,
                height: 1.28,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              cards[index].category,
              style: TextStyle(
                color: secondaryText,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.surface,
    required this.border,
  });

  final String label;
  final String value;
  final Color color;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: .72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
