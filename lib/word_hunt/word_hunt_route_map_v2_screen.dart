import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_starter_content.dart';

/// Görsel onay turu için izole V2 rota haritası.
///
/// - Mevcut Bilgi Oyunu navigasyonuna bağlı değildir.
/// - Oynanış/progression sözleşmesini değiştirmez.
/// - Arka plan için gerçek illüstrasyon asset'i takılabilecek ayrı bir katman
///   sunar; asset yokken yalnız geliştirme/CI için deterministik fallback çizer.
class WordHuntRouteMapV2Screen extends StatelessWidget {
  const WordHuntRouteMapV2Screen({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.progress = const WordHuntProgressSnapshot(),
    this.sceneAssetPath,
    this.onBack,
    this.onInfo,
    this.onCompass,
    this.onBook,
    this.onLevelTap,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final String? sceneAssetPath;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final VoidCallback? onCompass;
  final VoidCallback? onBook;
  final ValueChanged<int>? onLevelTap;

  static const List<Offset> _stops = <Offset>[
    Offset(0.14, 0.07),
    Offset(0.41, 0.14),
    Offset(0.65, 0.21),
    Offset(0.84, 0.39),
    Offset(0.32, 0.31),
    Offset(0.10, 0.45),
    Offset(0.36, 0.58),
    Offset(0.67, 0.63),
    Offset(0.21, 0.71),
    Offset(0.45, 0.82),
  ];

  @override
  Widget build(BuildContext context) {
    final routeStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final routeComplete = WordHuntRouteProgressEngine.isRouteComplete(
      route,
      progress,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF030711),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 10.0 : 14.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                18,
              ),
              child: Column(
                children: [
                  _TopNavigation(
                    onBack: onBack,
                    onInfo: onInfo,
                  ),
                  const SizedBox(height: 8),
                  _RouteHeaderPanel(
                    title: route.title,
                    stars: routeStars,
                    maximumStars: route.maximumStars,
                    unlockStarsRequired: route.unlockStarsRequired,
                    complete: routeComplete,
                  ),
                  const SizedBox(height: 8),
                  _MapScene(
                    route: route,
                    progress: progress,
                    sceneAssetPath: sceneAssetPath,
                    onLevelTap: onLevelTap,
                    onCompass: onCompass,
                    onBook: onBook,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation({this.onBack, this.onInfo});

  final VoidCallback? onBack;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          _RoundChromeButton(
            key: const Key('word_hunt_v2_back'),
            icon: Icons.arrow_back_rounded,
            semanticLabel: 'Geri',
            onTap: onBack,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'KELİME AVI',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFE9C7FF),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                    shadows: <Shadow>[
                      Shadow(color: Color(0xAA8B5CF6), blurRadius: 15),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                _TitleOrnament(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RoundChromeButton(
            key: const Key('word_hunt_v2_info'),
            icon: Icons.info_outline_rounded,
            semanticLabel: 'Bilgi',
            onTap: onInfo,
          ),
        ],
      ),
    );
  }
}

class _TitleOrnament extends StatelessWidget {
  const _TitleOrnament();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 38, height: 1, color: const Color(0x557C3AED)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.diamond_outlined,
            size: 8,
            color: Color(0xFFB37AFF),
          ),
        ),
        Container(width: 38, height: 1, color: const Color(0x557C3AED)),
      ],
    );
  }
}

class _RoundChromeButton extends StatelessWidget {
  const _RoundChromeButton({
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
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: <Color>[Color(0xFF1A1731), Color(0xFF080C18)],
              ),
              border: Border.all(color: const Color(0xFF8B6A40), width: 1.2),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x442A1753), blurRadius: 10),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFE7C57C), size: 25),
          ),
        ),
      ),
    );
  }
}

class _RouteHeaderPanel extends StatelessWidget {
  const _RouteHeaderPanel({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.unlockStarsRequired,
    required this.complete,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final int unlockStarsRequired;
  final bool complete;

  String _turkishUppercase(String value) {
    return value.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _OrnateFramePainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 13, 18, 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xED11101D),
              Color(0xEE07101E),
              Color(0xED0B0C18),
            ],
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 7)),
            BoxShadow(color: Color(0x338B5CF6), blurRadius: 16),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _turkishUppercase(title),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFF8E7),
                fontSize: 27,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                shadows: <Shadow>[
                  Shadow(color: Color(0xAA000000), offset: Offset(0, 2), blurRadius: 5),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC94A), size: 28),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '$stars / $maximumStars',
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: Color(0xFFFFF2D0),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          complete ? 'ROTA TAMAMLANDI' : 'Kapı: $unlockStarsRequired',
                          style: TextStyle(
                            color: complete
                                ? const Color(0xFF6EE7D6)
                                : const Color(0xFFFFE6A3),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC94A), size: 21),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapScene extends StatelessWidget {
  const _MapScene({
    required this.route,
    required this.progress,
    required this.sceneAssetPath,
    required this.onLevelTap,
    required this.onCompass,
    required this.onBook,
  });

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final String? sceneAssetPath;
  final ValueChanged<int>? onLevelTap;
  final VoidCallback? onCompass;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sceneHeight = (constraints.maxWidth * 1.42).clamp(470.0, 540.0);
        final size = Size(constraints.maxWidth, sceneHeight);
        final points = WordHuntRouteMapV2Screen._stops
            .take(route.levels.length)
            .map((stop) => Offset(stop.dx * size.width, stop.dy * size.height))
            .toList(growable: false);
        final lastUnlocked = _lastUnlockedIndex();

        return Container(
          key: const Key('word_hunt_v2_scene'),
          height: sceneHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF7D6039), width: 1.2),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0xAA000000), blurRadius: 20, offset: Offset(0, 10)),
              BoxShadow(color: Color(0x2245E6F2), blurRadius: 16),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _IllustratedSceneLayer(assetPath: sceneAssetPath),
                ),
                const Positioned.fill(child: _SceneLegibilityOverlay()),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _V2RoutePainter(
                      points: points,
                      route: route,
                      lastUnlockedIndex: lastUnlocked,
                    ),
                  ),
                ),
                for (var index = 0; index < points.length; index++)
                  _positionNode(
                    point: points[index],
                    level: route.levels[index],
                    stars: progress.starsFor(route.levels[index].id),
                    unlocked: WordHuntRouteProgressEngine.isLevelUnlocked(
                      route,
                      progress,
                      index + 1,
                    ),
                    sceneSize: size,
                  ),
                Positioned(
                  left: 18,
                  bottom: 14,
                  child: _BottomMapButton(
                    key: const Key('word_hunt_v2_compass'),
                    icon: Icons.explore_rounded,
                    label: 'Pusula',
                    onTap: onCompass,
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 14,
                  child: _BottomMapButton(
                    key: const Key('word_hunt_v2_book'),
                    icon: Icons.menu_book_rounded,
                    label: 'Bilgi Kitabı',
                    onTap: onBook,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _lastUnlockedIndex() {
    var last = 0;
    for (var index = 1; index <= route.levels.length; index++) {
      if (WordHuntRouteProgressEngine.isLevelUnlocked(route, progress, index)) {
        last = index;
      }
    }
    return last;
  }

  Widget _positionNode({
    required Offset point,
    required WordHuntLevelDefinition level,
    required int stars,
    required bool unlocked,
    required Size sceneSize,
  }) {
    final special = level.type != WordHuntLevelType.normal;
    final boxWidth = special ? 148.0 : 76.0;
    final boxHeight = special ? 92.0 : 78.0;
    const placeLabelToLeft = false;
    final centerX = special && !placeLabelToLeft ? 42.0 : boxWidth - 42.0;
    final left = (point.dx - centerX)
        .clamp(4.0, sceneSize.width - boxWidth - 4)
        .toDouble();
    final top = (point.dy - 39)
        .clamp(4.0, sceneSize.height - boxHeight - 4)
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: boxWidth,
      height: boxHeight,
      child: _RouteStop(
        key: Key('word_hunt_v2_level_${level.index}'),
        level: level,
        stars: stars,
        unlocked: unlocked,
        labelOnLeft: placeLabelToLeft,
        onTap: unlocked && onLevelTap != null
            ? () => onLevelTap!(level.index)
            : null,
      ),
    );
  }
}

class _IllustratedSceneLayer extends StatelessWidget {
  const _IllustratedSceneLayer({required this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(
        path,
        key: const Key('word_hunt_v2_illustrated_asset'),
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) {
          return const CustomPaint(painter: _FallbackHarborPainter());
        },
      );
    }

    return const CustomPaint(
      key: Key('word_hunt_v2_fallback_scene'),
      painter: _FallbackHarborPainter(),
    );
  }
}

class _SceneLegibilityOverlay extends StatelessWidget {
  const _SceneLegibilityOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            const Color(0xFF020817).withValues(alpha: 0.15),
            Colors.transparent,
            Colors.transparent,
            const Color(0xFF030512).withValues(alpha: 0.30),
          ],
          stops: const <double>[0, 0.22, 0.72, 1],
        ),
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({
    super.key,
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.labelOnLeft,
    this.onTap,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final bool labelOnLeft;
  final VoidCallback? onTap;

  Color get typeColor => switch (level.type) {
    WordHuntLevelType.normal => const Color(0xFF32E6E7),
    WordHuntLevelType.challenge => const Color(0xFFFF9E2B),
    WordHuntLevelType.bonus => const Color(0xFFC45CFF),
    WordHuntLevelType.routeFinal => const Color(0xFFFFD268),
  };

  String get typeLabel => switch (level.type) {
    WordHuntLevelType.normal => '',
    WordHuntLevelType.challenge => 'MEYDAN OKUMA',
    WordHuntLevelType.bonus => 'BONUS DURAK',
    WordHuntLevelType.routeFinal => 'ROTA FİNALİ',
  };

  IconData get typeIcon => switch (level.type) {
    WordHuntLevelType.normal => Icons.circle,
    WordHuntLevelType.challenge => Icons.sports_martial_arts_rounded,
    WordHuntLevelType.bonus => Icons.card_giftcard_rounded,
    WordHuntLevelType.routeFinal => Icons.inventory_2_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final accent = !unlocked && level.type == WordHuntLevelType.normal
        ? const Color(0xFF7A8190)
        : typeColor;
    final node = _NodeOrb(
      level: level,
      unlocked: unlocked,
      accent: accent,
    );
    final label = level.type == WordHuntLevelType.normal
        ? const SizedBox.shrink()
        : Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: labelOnLeft ? 0 : 4,
                right: labelOnLeft ? 4 : 0,
                top: 4,
              ),
              child: _SpecialStopLabel(
                label: typeLabel,
                icon: typeIcon,
                accent: accent,
                dimmed: !unlocked,
              ),
            ),
          );

    return Semantics(
      button: unlocked,
      label: unlocked
          ? 'Bölüm ${level.index}, ${typeLabel.isEmpty ? 'normal' : typeLabel}, $stars yıldız, açık'
          : 'Bölüm ${level.index}, kilitli',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: labelOnLeft
                    ? <Widget>[label, node]
                    : <Widget>[node, label],
              ),
              SizedBox(
                width: level.type == WordHuntLevelType.normal ? 76 : 82,
                child: _StarStrip(stars: stars, unlocked: unlocked),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NodeOrb extends StatelessWidget {
  const _NodeOrb({
    required this.level,
    required this.unlocked,
    required this.accent,
  });

  final WordHuntLevelDefinition level;
  final bool unlocked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final size = switch (level.type) {
      WordHuntLevelType.normal => 60.0,
      WordHuntLevelType.challenge => 68.0,
      WordHuntLevelType.bonus => 68.0,
      WordHuntLevelType.routeFinal => 74.0,
    };
    final finalNode = level.type == WordHuntLevelType.routeFinal;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (finalNode)
            Positioned(
              top: -15,
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 28,
                color: accent,
                shadows: <Shadow>[
                  Shadow(color: accent.withValues(alpha: 0.75), blurRadius: 12),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: unlocked ? 0.60 : 0.26),
                  blurRadius: unlocked ? 18 : 9,
                  spreadRadius: unlocked ? 4 : 1,
                ),
                const BoxShadow(color: Color(0xAA000000), blurRadius: 5, offset: Offset(0, 4)),
              ],
              border: Border.all(
                color: accent.withValues(alpha: unlocked ? 0.95 : 0.60),
                width: finalNode ? 3.2 : 2.4,
              ),
              gradient: RadialGradient(
                colors: <Color>[
                  accent.withValues(alpha: unlocked ? 0.42 : 0.16),
                  const Color(0xFF10202B),
                  const Color(0xFF071019),
                ],
                stops: const <double>[0, 0.62, 1],
              ),
            ),
          ),
          Container(
            width: size - 12,
            height: size - 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.48), width: 1),
            ),
          ),
          if (!unlocked && level.type == WordHuntLevelType.normal)
            const Icon(Icons.lock_rounded, color: Color(0xFFE6E7EB), size: 26)
          else
            Text(
              '${level.index}',
              style: TextStyle(
                color: unlocked
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFFD8D8D8),
                fontSize: finalNode ? 28 : 24,
                fontWeight: FontWeight.w900,
                shadows: const <Shadow>[
                  Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SpecialStopLabel extends StatelessWidget {
  const _SpecialStopLabel({
    required this.label,
    required this.icon,
    required this.accent,
    required this.dimmed,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.68 : 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: <Color>[
              const Color(0xF20C0B14),
              accent.withValues(alpha: 0.18),
              const Color(0xF20C0B14),
            ],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.72), width: 1.1),
          boxShadow: <BoxShadow>[
            BoxShadow(color: accent.withValues(alpha: 0.24), blurRadius: 9),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                style: TextStyle(
                  color: accent,
                  fontSize: 9.4,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarStrip extends StatelessWidget {
  const _StarStrip({required this.stars, required this.unlocked});

  final int stars;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        3,
        (index) => Icon(
          Icons.star_rounded,
          size: 18,
          color: index < stars
              ? const Color(0xFFFFC94A)
              : unlocked
                  ? const Color(0xFF6E7482)
                  : const Color(0xFF535866),
          shadows: index < stars
              ? const <Shadow>[
                  Shadow(color: Color(0x99FFB52E), blurRadius: 6),
                ]
              : const <Shadow>[],
        ),
      ),
    );
  }
}

class _BottomMapButton extends StatelessWidget {
  const _BottomMapButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: <Color>[Color(0xFF241C18), Color(0xFF090B10)],
              ),
              border: Border.all(color: const Color(0xFF9B7440), width: 2),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x99000000), blurRadius: 9, offset: Offset(0, 4)),
                BoxShadow(color: Color(0x338B6B40), blurRadius: 8),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFDAB66D), size: 30),
          ),
        ),
      ),
    );
  }
}

class _V2RoutePainter extends CustomPainter {
  const _V2RoutePainter({
    required this.points,
    required this.route,
    required this.lastUnlockedIndex,
  });

  final List<Offset> points;
  final WordHuntRouteDefinition route;
  final int lastUnlockedIndex;

  Color _typeColor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.normal => const Color(0xFF32E6E7),
    WordHuntLevelType.challenge => const Color(0xFFFF9E2B),
    WordHuntLevelType.bonus => const Color(0xFFC45CFF),
    WordHuntLevelType.routeFinal => const Color(0xFFFFD268),
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final bendX = (start.dx + end.dx) / 2 + (index.isEven ? 24 : -24);
      final bendY = (start.dy + end.dy) / 2 + (index == 7 ? 18 : 0);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(bendX, bendY, end.dx, end.dy);

      final nextType = route.levels[index + 1].type;
      final segmentUnlocked = index + 2 <= lastUnlockedIndex;
      final accent = _typeColor(nextType);

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 9
          ..color = const Color(0x88000308),
      );

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = segmentUnlocked ? 6 : 3.5
          ..color = segmentUnlocked
              ? accent.withValues(alpha: 0.34)
              : const Color(0xFFCBD5E1).withValues(alpha: 0.28),
      );

      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = segmentUnlocked ? 2.8 : 2
        ..color = segmentUnlocked
            ? accent.withValues(alpha: 0.96)
            : const Color(0xFFD6D8DF).withValues(alpha: 0.58);
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _V2RoutePainter oldDelegate) {
    return oldDelegate.lastUnlockedIndex != lastUnlockedIndex ||
        oldDelegate.points != points ||
        oldDelegate.route != route;
  }
}

class _OrnateFramePainter extends CustomPainter {
  const _OrnateFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF9B7440).withValues(alpha: 0.78);
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFFE7C57C).withValues(alpha: 0.25);

    final outerRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
      const Radius.circular(13),
    );
    canvas.drawRRect(outerRect, border);
    canvas.drawRRect(innerRect, inner);

    final corner = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFD9B46B).withValues(alpha: 0.64);
    const length = 15.0;
    canvas.drawLine(const Offset(6, 6), const Offset(6 + length, 6), corner);
    canvas.drawLine(const Offset(6, 6), const Offset(6, 6 + length), corner);
    canvas.drawLine(Offset(size.width - 6, 6), Offset(size.width - 6 - length, 6), corner);
    canvas.drawLine(Offset(size.width - 6, 6), Offset(size.width - 6, 6 + length), corner);
  }

  @override
  bool shouldRepaint(covariant _OrnateFramePainter oldDelegate) => false;
}

/// Yalnız asset henüz bağlanmadığında CI ve erken görsel prototip için kullanılır.
/// Final hedef, bu katmanın gerçek illüstrasyon asset'i ile değiştirilmesidir.
class _FallbackHarborPainter extends CustomPainter {
  const _FallbackHarborPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF071027),
            Color(0xFF072A42),
            Color(0xFF06324A),
            Color(0xFF08182B),
            Color(0xFF120B20),
          ],
          stops: <double>[0, 0.24, 0.48, 0.74, 1],
        ).createShader(rect),
    );

    _drawMoon(canvas, size);
    _drawMoonReflection(canvas, size);
    _drawIsland(canvas, size, const Offset(-0.13, 0.06), const Size(0.52, 0.26));
    _drawIsland(canvas, size, const Offset(0.70, 0.18), const Size(0.43, 0.27));
    _drawIsland(canvas, size, const Offset(-0.18, 0.38), const Size(0.48, 0.30));
    _drawIsland(canvas, size, const Offset(0.64, 0.48), const Size(0.52, 0.32));
    _drawIsland(canvas, size, const Offset(-0.14, 0.72), const Size(0.52, 0.30));
    _drawIsland(canvas, size, const Offset(0.58, 0.78), const Size(0.55, 0.30));

    _drawLighthouse(canvas, size);
    _drawSailboat(canvas, size, Offset(size.width * 0.12, size.height * 0.30), 0.78);
    _drawSailboat(canvas, size, Offset(size.width * 0.28, size.height * 0.39), 0.58);
    _drawVillageLights(canvas, size);
    _drawWaterLines(canvas, size);
  }

  void _drawMoon(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.73, size.height * 0.08);
    canvas.drawCircle(
      center,
      size.width * 0.075,
      Paint()
        ..color = const Color(0xFFFFF1C8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      center,
      size.width * 0.055,
      Paint()..color = const Color(0xFFFFF8E6),
    );
  }

  void _drawMoonReflection(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x99CFEFFF);
    for (var i = 0; i < 14; i++) {
      final y = size.height * (0.13 + i * 0.026);
      final half = size.width * (0.015 + i * 0.006);
      paint.strokeWidth = i.isEven ? 2 : 1;
      final centerX = size.width * 0.73;
      canvas.drawLine(Offset(centerX - half, y), Offset(centerX + half, y), paint);
    }
  }

  void _drawIsland(
    Canvas canvas,
    Size size,
    Offset normalizedOrigin,
    Size normalizedSize,
  ) {
    final rect = Rect.fromLTWH(
      normalizedOrigin.dx * size.width,
      normalizedOrigin.dy * size.height,
      normalizedSize.width * size.width,
      normalizedSize.height * size.height,
    );
    final path = Path()
      ..moveTo(rect.left, rect.center.dy)
      ..quadraticBezierTo(rect.left + rect.width * 0.12, rect.top, rect.center.dx, rect.top + rect.height * 0.08)
      ..quadraticBezierTo(rect.right - rect.width * 0.07, rect.top, rect.right, rect.center.dy)
      ..quadraticBezierTo(rect.right - rect.width * 0.15, rect.bottom, rect.center.dx, rect.bottom - rect.height * 0.08)
      ..quadraticBezierTo(rect.left + rect.width * 0.06, rect.bottom, rect.left, rect.center.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1A423D), Color(0xFF172B32), Color(0xFF0D1725)],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x554EE7C8),
    );
  }

  void _drawLighthouse(Canvas canvas, Size size) {
    final baseX = size.width * 0.86;
    final baseY = size.height * 0.30;
    final body = Path()
      ..moveTo(baseX - 8, baseY)
      ..lineTo(baseX - 4, baseY - 54)
      ..lineTo(baseX + 4, baseY - 54)
      ..lineTo(baseX + 8, baseY)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFFD8D0BE));
    canvas.drawRect(
      Rect.fromCenter(center: Offset(baseX, baseY - 59), width: 18, height: 8),
      Paint()..color = const Color(0xFF50382A),
    );
    canvas.drawCircle(
      Offset(baseX, baseY - 60),
      4,
      Paint()
        ..color = const Color(0xFFFFD36E)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  void _drawSailboat(Canvas canvas, Size size, Offset origin, double scale) {
    final hull = Path()
      ..moveTo(origin.dx - 20 * scale, origin.dy)
      ..lineTo(origin.dx + 21 * scale, origin.dy)
      ..lineTo(origin.dx + 12 * scale, origin.dy + 8 * scale)
      ..lineTo(origin.dx - 13 * scale, origin.dy + 8 * scale)
      ..close();
    canvas.drawPath(hull, Paint()..color = const Color(0xFF5B3C24));
    canvas.drawLine(
      Offset(origin.dx, origin.dy),
      Offset(origin.dx, origin.dy - 42 * scale),
      Paint()
        ..strokeWidth = 2 * scale
        ..color = const Color(0xFFB99667),
    );
    final sail = Path()
      ..moveTo(origin.dx - 2 * scale, origin.dy - 40 * scale)
      ..lineTo(origin.dx - 2 * scale, origin.dy - 5 * scale)
      ..lineTo(origin.dx - 23 * scale, origin.dy - 12 * scale)
      ..close();
    canvas.drawPath(sail, Paint()..color = const Color(0xFFC4B18E));
  }

  void _drawVillageLights(Canvas canvas, Size size) {
    final lights = <Offset>[
      Offset(0.08, 0.20), Offset(0.17, 0.22), Offset(0.24, 0.18),
      Offset(0.82, 0.28), Offset(0.91, 0.34), Offset(0.12, 0.49),
      Offset(0.20, 0.56), Offset(0.75, 0.55), Offset(0.87, 0.62),
      Offset(0.08, 0.78), Offset(0.18, 0.84), Offset(0.72, 0.84),
      Offset(0.86, 0.89),
    ];
    for (final light in lights) {
      final point = Offset(light.dx * size.width, light.dy * size.height);
      canvas.drawCircle(
        point,
        2.6,
        Paint()
          ..color = const Color(0xFFFFB84C)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(point, 1.2, Paint()..color = const Color(0xFFFFE2A1));
    }
  }

  void _drawWaterLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0x224DEBFF);
    for (var y = size.height * 0.12; y < size.height; y += 28) {
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x < size.width; x += 32) {
        path.quadraticBezierTo(x + 8, y + 2, x + 16, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FallbackHarborPainter oldDelegate) => false;
}
