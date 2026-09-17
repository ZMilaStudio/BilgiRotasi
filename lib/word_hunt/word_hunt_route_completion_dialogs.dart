import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_route_rewards.dart';

enum WordHuntRouteCompletionAction { returnToRoute, showRouteSelector }

class WordHuntRouteCompletionDialog extends StatelessWidget {
  const WordHuntRouteCompletionDialog({
    super.key,
    required this.route,
    required this.reward,
    required this.totalStars,
    required this.routeColors,
    this.nextRouteTitle,
  });

  final WordHuntRouteDefinition route;
  final WordHuntRouteRewardDefinition reward;
  final int totalStars;
  final List<Color> routeColors;
  final String? nextRouteTitle;

  @override
  Widget build(BuildContext context) {
    final colors = routeColors.length >= 2
        ? routeColors
        : const <Color>[Color(0xFF17324B), Color(0xFF081623)];
    final hasNextRoute = nextRouteTitle != null;

    return Dialog(
      key: const Key('word_hunt_route_completion_dialog'),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[colors.first, colors.last],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFFFD166), width: 1.4),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Rota Tamamlandı!',
                  key: Key('word_hunt_route_completion_title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  route.title,
                  key: const Key('word_hunt_route_completion_route_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE8A3),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                TweenAnimationBuilder<double>(
                  key: const Key('word_hunt_route_reward_reveal'),
                  tween: Tween<double>(begin: 0.88, end: 1),
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value.clamp(0, 1), child: child),
                  ),
                  child: Semantics(
                    label: 'Rozet Kazandın, ${reward.displayName}',
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x22111111),
                        border: Border.all(
                          color: const Color(0xFFFFD166),
                          width: 2.2,
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(color: Color(0x66FFD166), blurRadius: 18),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        reward.icon,
                        key: const Key('word_hunt_route_reward_icon'),
                        color: const Color(0xFFFFD166),
                        size: 54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Rozet Kazandın',
                  key: Key('word_hunt_route_reward_reveal_label'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.displayName,
                  key: const Key('word_hunt_route_reward_name'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$totalStars / ${route.maximumStars} yıldız',
                  key: const Key('word_hunt_route_completion_stars'),
                  style: const TextStyle(
                    color: Color(0xFFE8EEF5),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  hasNextRoute
                      ? '${nextRouteTitle!} açıldı.'
                      : 'Tüm mevcut rotaları tamamladın.',
                  key: Key(
                    hasNextRoute
                        ? 'word_hunt_next_route_unlocked_message'
                        : 'word_hunt_terminal_route_message',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                if (hasNextRoute) ...<Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('word_hunt_show_new_route'),
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(WordHuntRouteCompletionAction.showRouteSelector),
                      icon: const Icon(Icons.map_rounded),
                      label: const Text('Yeni Rotayı Gör'),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    key: const Key('word_hunt_route_completion_return'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(WordHuntRouteCompletionAction.returnToRoute),
                    child: const Text('Rotaya Dön'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WordHuntFinalIncompleteDialog extends StatelessWidget {
  const WordHuntFinalIncompleteDialog({
    super.key,
    required this.route,
    required this.totalStars,
  });

  final WordHuntRouteDefinition route;
  final int totalStars;

  @override
  Widget build(BuildContext context) {
    final missingStars = (route.unlockStarsRequired - totalStars).clamp(
      0,
      route.unlockStarsRequired,
    );

    return AlertDialog(
      key: const Key('word_hunt_final_incomplete_dialog'),
      title: const Text('Final Tamamlandı'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Rotayı tamamlamak için $missingStars yıldız daha kazan.',
            key: const Key('word_hunt_final_incomplete_message'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '$totalStars / ${route.unlockStarsRequired} yıldız',
            key: const Key('word_hunt_final_incomplete_stars'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      actions: <Widget>[
        FilledButton(
          key: const Key('word_hunt_final_incomplete_return'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Rotaya Dön'),
        ),
      ],
    );
  }
}
