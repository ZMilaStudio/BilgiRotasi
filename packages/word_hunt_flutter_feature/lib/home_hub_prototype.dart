import 'package:flutter/material.dart';

class HomeHubPrototypeData {
  const HomeHubPrototypeData({
    this.username = '@levent',
    this.level = 12,
    this.currentXp = 3450,
    this.nextLevelXp = 6000,
    this.dailyCompleted = 2,
    this.dailyTotal = 5,
  });

  final String username;
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int dailyCompleted;
  final int dailyTotal;

  double get xpProgress =>
      nextLevelXp <= 0 ? 0 : (currentXp / nextLevelXp).clamp(0.0, 1.0);
}

/// Yeni Bilgi Rotası ana ekranı için tamamen izole görsel/etkileşim prototipi.
///
/// Bu widget mevcut Home/MainNavigation akışına bağlı değildir. Entegrasyon
/// ancak ayrı kullanıcı onayı sonrası yapılacaktır.
class BilgiRotasiHomeHubPrototype extends StatelessWidget {
  const BilgiRotasiHomeHubPrototype({
    super.key,
    this.data = const HomeHubPrototypeData(),
    this.onProfile,
    this.onSettings,
    this.onNotifications,
    this.onBilgiOyunu,
    this.onKelimeAvi,
    this.onDaily,
  });

  final HomeHubPrototypeData data;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onNotifications;
  final VoidCallback? onBilgiOyunu;
  final VoidCallback? onKelimeAvi;
  final VoidCallback? onDaily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04132D),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 380;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                compact ? 14 : 18,
                14,
                compact ? 14 : 18,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(
                    data: data,
                    onProfile: onProfile,
                    onSettings: onSettings,
                    onNotifications: onNotifications,
                  ),
                  const SizedBox(height: 18),
                  const _BrandHero(),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _GameModeCard(
                          key: const Key('home_hub_bilgi_oyunu'),
                          title: 'Bilgi Oyunu',
                          subtitle: 'Sorular, maraton ve meydan okumalar',
                          accent: const Color(0xFF12B8B0),
                          darkAccent: const Color(0xFF075A6A),
                          icon: Icons.casino_rounded,
                          buttonText: 'Oyna',
                          onTap: onBilgiOyunu,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GameModeCard(
                          key: const Key('home_hub_kelime_avi'),
                          title: 'Kelime Avı',
                          subtitle: 'Rotalar, yıldızlar ve kelime macerası',
                          accent: const Color(0xFFA855F7),
                          darkAccent: const Color(0xFF4C1D95),
                          icon: Icons.manage_search_rounded,
                          buttonText: 'Başla',
                          onTap: onKelimeAvi,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DailyCard(data: data, onTap: onDaily),
                  const SizedBox(height: 14),
                  const _FutureModesCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.data,
    required this.onProfile,
    required this.onSettings,
    required this.onNotifications,
  });

  final HomeHubPrototypeData data;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            key: const Key('home_hub_profile'),
            onTap: onProfile,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0A3650),
                      border: Border.all(
                        color: const Color(0xFFFFC857),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFFFD89A),
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A5260),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFC857),
                                ),
                              ),
                              child: Text(
                                '${data.level}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: LinearProgressIndicator(
                                  minHeight: 8,
                                  value: data.xpProgress,
                                  backgroundColor: const Color(0xFF172B45),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF22D3C5),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.currentXp} / ${data.nextLevelXp} XP',
                          style: const TextStyle(
                            color: Color(0xFFA9C0D8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _CircleAction(
          key: const Key('home_hub_settings'),
          icon: Icons.settings_rounded,
          semanticLabel: 'Ayarlar',
          onTap: onSettings,
        ),
        const SizedBox(width: 8),
        _CircleAction(
          key: const Key('home_hub_notifications'),
          icon: Icons.notifications_rounded,
          semanticLabel: 'Bildirimler',
          onTap: onNotifications,
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0C2341),
              border: Border.all(color: const Color(0xFFB68432)),
            ),
            child: Icon(icon, color: const Color(0xFFFFD166), size: 23),
          ),
        ),
      ),
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: <Color>[Color(0xFF0E4160), Color(0xFF06142E)],
            ),
            border: Border.all(color: const Color(0xFFFFC857), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55FFC857),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.explore_rounded, color: Color(0xFFFFC857), size: 84),
              Text(
                'BR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'BİLGİ ROTASI',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.7,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Zarı at, bilginle yolu aç.',
          style: TextStyle(
            color: Color(0xFF7EE7E0),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GameModeCard extends StatelessWidget {
  const _GameModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.darkAccent,
    required this.icon,
    required this.buttonText,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Color darkAccent;
  final IconData icon;
  final String buttonText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 270),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            darkAccent.withValues(alpha: 0.92),
            const Color(0xFF0A1632),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.85), width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(color: accent.withValues(alpha: 0.16), blurRadius: 18),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 72, color: accent),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD2D9E8),
              height: 1.35,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: accent.withValues(alpha: 0.28),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: accent),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonText,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.data, this.onTap});

  final HomeHubPrototypeData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final total = data.dailyTotal <= 0 ? 1 : data.dailyTotal;
    final progress = (data.dailyCompleted / total).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('home_hub_daily'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF17355C), Color(0xFF0B2444)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF586E91)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D1F2C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFFFF8A80),
                  size: 31,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günlük Görevler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Her gün yeni görevler, ödüller ve XP.',
                      style: TextStyle(color: Color(0xFFC9D4E5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Text(
                    '${data.dailyCompleted}/${data.dailyTotal}',
                    style: const TextStyle(
                      color: Color(0xFFFFD166),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 58,
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: progress,
                      borderRadius: BorderRadius.circular(20),
                      backgroundColor: const Color(0xFF1A2A42),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF22D3C5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFFFD166)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FutureModesCard extends StatelessWidget {
  const _FutureModesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_hub_future_modes'),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0x770A1A34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2C8790),
          style: BorderStyle.solid,
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF0B4F59),
            child: Icon(Icons.add_rounded, color: Color(0xFF4DE4D5)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeni modlar yolda!',
                  style: TextStyle(
                    color: Color(0xFF4DE4D5),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Bilgi Rotası yeni oyunlarla büyümeye devam edecek.',
                  style: TextStyle(color: Color(0xFF7895B3), fontSize: 11.5),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded, color: Color(0xFF46617D)),
        ],
      ),
    );
  }
}
