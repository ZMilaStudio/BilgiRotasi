import 'package:flutter/material.dart';

import 'word_hunt_home_projection.dart';

class WordHuntHomeScreen extends StatelessWidget {
  const WordHuntHomeScreen({
    super.key,
    required this.projection,
    required this.onContinue,
    required this.onRoutes,
  });

  final WordHuntHomeProjection projection;
  final ValueChanged<WordHuntContinueDestination> onContinue;
  final VoidCallback onRoutes;

  @override
  Widget build(BuildContext context) {
    final destination = projection.continueDestination;

    return Scaffold(
      key: const Key('word_hunt_home_screen'),
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: <Widget>[
            const Text(
              'DEVAM ET',
              key: Key('word_hunt_home_continue_heading'),
              style: TextStyle(
                color: Color(0xFFFFD978),
                fontSize: 13,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            _HomeActionCard(
              key: const Key('word_hunt_home_continue'),
              icon: Icons.play_arrow_rounded,
              title: destination.routeTitle,
              subtitle:
                  '${destination.displayName} • '
                  'Bölüm ${destination.absoluteLevelIndex} • '
                  'Bölge ${destination.activeSegmentIndex}',
              onTap: () => onContinue(destination),
            ),
            const SizedBox(height: 22),
            const Text(
              'ROTALAR',
              key: Key('word_hunt_home_routes_heading'),
              style: TextStyle(
                color: Color(0xFFFFD978),
                fontSize: 13,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            _HomeActionCard(
              key: const Key('word_hunt_home_routes'),
              icon: Icons.map_rounded,
              title: 'Rotalar',
              subtitle:
                  '${projection.routeSummaries.length} mevcut rotayı görüntüle',
              onTap: onRoutes,
            ),
            const SizedBox(height: 22),
            const Text(
              'GENEL İLERLEME',
              key: Key('word_hunt_home_progress_heading'),
              style: TextStyle(
                color: Color(0xFFFFD978),
                fontSize: 13,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              key: const Key('word_hunt_home_general_progress'),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF10243B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x334FC3F7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ProgressLine(
                    label: 'Tamamlanan bölüm',
                    value:
                        '${projection.totalCompletedLevels} / '
                        '${projection.totalLevelCount}',
                  ),
                  _ProgressLine(
                    label: 'Toplam yıldız',
                    value: '${projection.totalStars}',
                  ),
                  _ProgressLine(
                    label: 'Kaydedilen bonus',
                    value: '${projection.knownBonusFoundTotal}',
                  ),
                  _ProgressLine(
                    label: 'Tamamlanan rota',
                    value:
                        '${projection.completedRouteCount} / '
                        '${projection.routeSummaries.length}',
                  ),
                  if (projection.hasUnknownBonusHistory) ...<Widget>[
                    const SizedBox(height: 10),
                    const Text(
                      'Eski tamamlanan bölümlerde kaydedilmemiş bonus '
                      'geçmişi bulunuyor.',
                      key: Key('word_hunt_home_bonus_unknown'),
                      style: TextStyle(
                        color: Color(0xFFFFD79A),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF10243B),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0x2238BDF8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFFFD978), size: 30),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFB7C7DA),
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFFFD978)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB7C7DA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
