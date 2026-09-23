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

/// Yeni Bilgi Rotası ana ekranının izole ve responsive prototipi.
/// Mevcut uygulama navigasyonuna bilerek bağlı değildir.
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
            final compact = constraints.maxWidth < 390;
            final horizontalPadding = compact ? 12.0 : 18.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ResponsiveTopBar(
                    data: data,
                    compact: compact,
                    onProfile: onProfile,
                    onSettings: onSettings,
                    onNotifications: onNotifications,
                  ),
                  SizedBox(height: compact ? 12 : 18),
                  _BrandHero(compact: compact),
                  SizedBox(height: compact ? 16 : 22),
                  _MainModes(
                    compact: compact,
                    onBilgiOyunu: onBilgiOyunu,
                    onKelimeAvi: onKelimeAvi,
                  ),
                  const SizedBox(height: 14),
                  _DailyCard(data: data, onTap: onDaily, compact: compact),
                  const SizedBox(height: 12),
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

class _ResponsiveTopBar extends StatelessWidget {
  const _ResponsiveTopBar({
    required this.data,
    required this.compact,
    this.onProfile,
    this.onSettings,
    this.onNotifications,
  });

  final HomeHubPrototypeData data;
  final bool compact;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    final actionSize = compact ? 38.0 : 44.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            key: const Key('home_hub_profile'),
            onTap: onProfile,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: compact ? 48 : 58,
                    height: compact ? 48 : 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0A3650),
                      border: Border.all(
                        color: const Color(0xFFFFC857),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: const Color(0xFFFFD89A),
                      size: compact ? 28 : 34,
                    ),
                  ),
                  SizedBox(width: compact ? 7 : 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 16 : 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: LinearProgressIndicator(
                                  minHeight: 7,
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
                        const SizedBox(height: 3),
                        Text(
                          '${data.currentXp} / ${data.nextLevelXp} XP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFFA9C0D8),
                            fontSize: compact ? 9.5 : 10.5,
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
        SizedBox(width: compact ? 5 : 10),
        _CircleAction(
          key: const Key('home_hub_settings'),
          icon: Icons.settings_rounded,
          semanticLabel: 'Ayarlar',
          size: actionSize,
          onTap: onSettings,
        ),
        SizedBox(width: compact ? 4 : 8),
        _CircleAction(
          key: const Key('home_hub_notifications'),
          icon: Icons.notifications_rounded,
          semanticLabel: 'Bildirimler',
          size: actionSize,
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
    required this.size,
    this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final double size;
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
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0C2341),
              border: Border.all(color: const Color(0xFFB68432)),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFD166),
              size: size * 0.52,
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 92.0 : 118.0;
    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: <Color>[Color(0xFF0E4160), Color(0xFF06142E)],
            ),
            border: Border.all(color: const Color(0xFFFFC857), width: 3),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x55FFC857),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.explore_rounded,
                color: const Color(0xFFFFC857),
                size: logoSize * 0.72,
              ),
              Text(
                'BR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 15 : 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'BİLGİ ROTASI',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 25 : 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Zarı at, bilginle yolu aç.',
          style: TextStyle(
            color: const Color(0xFF7EE7E0),
            fontSize: compact ? 12.5 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MainModes extends StatelessWidget {
  const _MainModes({
    required this.compact,
    this.onBilgiOyunu,
    this.onKelimeAvi,
  });

  final bool compact;
  final VoidCallback? onBilgiOyunu;
  final VoidCallback? onKelimeAvi;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            compact: compact,
            onTap: onBilgiOyunu,
          ),
        ),
        SizedBox(width: compact ? 8 : 12),
        Expanded(
          child: _GameModeCard(
            key: const Key('home_hub_kelime_avi'),
            title: 'Kelime Avı',
            subtitle: 'Rotalar, yıldızlar ve kelime macerası',
            accent: const Color(0xFFA855F7),
            darkAccent: const Color(0xFF4C1D95),
            icon: Icons.manage_search_rounded,
            buttonText: 'Başla',
            compact: compact,
            onTap: onKelimeAvi,
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
    required this.compact,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Color darkAccent;
  final IconData icon;
  final String buttonText;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 230 : 270),
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 14,
        compact ? 14 : 18,
        compact ? 10 : 14,
        compact ? 10 : 14,
      ),
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
          Icon(icon, size: compact ? 52 : 72, color: accent),
          SizedBox(height: compact ? 10 : 16),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: compact ? 3 : 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFFD2D9E8),
              height: 1.3,
              fontSize: compact ? 10.5 : 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 16 : 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: accent.withValues(alpha: 0.28),
                foregroundColor: Colors.white,
                minimumSize: Size(0, compact ? 40 : 46),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 6 : 12,
                  vertical: compact ? 9 : 13,
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: accent),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonText,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.data, required this.compact, this.onTap});

  final HomeHubPrototypeData data;
  final bool compact;
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
          padding: EdgeInsets.all(compact ? 12 : 16),
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
                width: compact ? 44 : 54,
                height: compact ? 44 : 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D1F2C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: const Color(0xFFFF8A80),
                  size: compact ? 25 : 31,
                ),
              ),
              SizedBox(width: compact ? 9 : 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günlük Görevler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 15 : 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Her gün yeni görevler, ödüller ve XP.',
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFC9D4E5),
                        fontSize: compact ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: compact ? 48 : 58,
                child: Column(
                  children: [
                    Text(
                      '${data.dailyCompleted}/${data.dailyTotal}',
                      style: const TextStyle(
                        color: Color(0xFFFFD166),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      minHeight: 7,
                      value: progress,
                      borderRadius: BorderRadius.circular(20),
                      backgroundColor: const Color(0xFF1A2A42),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF22D3C5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x770A1A34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C8790)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF0B4F59),
            child: Icon(Icons.add_rounded, color: Color(0xFF4DE4D5)),
          ),
          SizedBox(width: 10),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF7895B3), fontSize: 11),
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
