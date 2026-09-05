import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';

/// Gökyüzü Adaları için telefon ekranına göre üretilmiş MASTER ART rota ekranı.
///
/// Görünür dünya tek raster tabandır. Flutter yalnız gerçek progression,
/// etkileşim ve zorunlu üst köşe kontrollerini bindirir. Alt bölümde standart
/// banner reklam yüksekliği kadar alan bilinçli olarak ayrılır.
abstract final class WordHuntGokyuzuMasterArtAssets {
  static const String masterArt =
      'assets/word_hunt/gokyuzu_adalari_master_art_v2.webp';
}

abstract final class WordHuntGokyuzuMasterArtLayout {
  static const Size sourceSize = Size(941, 1672);

  /// Mevcut monetization katmanı AdSize.banner (320x50 dp) kullanır.
  /// Bu ekran reklamı yeniden yüklemez; yalnız banner için 50 logical px ayırır.
  static const double bannerReserveHeight = 50;

  static const List<Offset> levelCenters = <Offset>[
    Offset(158, 414),
    Offset(455, 462),
    Offset(733, 576),
    Offset(198, 705),
    Offset(495, 799),
    Offset(757, 878),
    Offset(178, 968),
    Offset(465, 1063),
    Offset(198, 1234),
    Offset(736, 1248),
  ];

  static const List<double> levelHitboxDiameters = <double>[
    118,
    118,
    118,
    124,
    124,
    126,
    126,
    132,
    134,
    146,
  ];

  static const Offset compassCenter = Offset(96, 1485);
  static const Offset bookCenter = Offset(837, 1486);
  static const double bottomControlHitboxDiameter = 145;

  // Telefon MASTER ART'ında geri/bilgi sanatı bake edilmedi. Bunlar yalnız
  // gerekli navigation kontrolü olarak minimum görünür Flutter overlay'idir.
  static const Offset backCenter = Offset(58, 101);
  static const Offset infoCenter = Offset(883, 101);
  static const double topControlDiameter = 72;

  static const Rect progressCounterRect = Rect.fromLTWH(254, 188, 150, 48);
  static const Rect gateCounterRect = Rect.fromLTWH(579, 188, 170, 48);
}

class WordHuntGokyuzuMasterArtScreen extends StatelessWidget {
  const WordHuntGokyuzuMasterArtScreen({
    super.key,
    required this.route,
    this.progress = const WordHuntProgressSnapshot(),
    this.onBack,
    this.onInfo,
    this.onCompass,
    this.onBook,
    this.onLevelTap,
  });

  static const String routeId = 'gokyuzu-adalari';

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;
  final VoidCallback? onCompass;
  final VoidCallback? onBook;
  final ValueChanged<int>? onLevelTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('word_hunt_gokyuzu_master_art_route'),
      backgroundColor: const Color(0xFF072B58),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ClipRect(
              key: const Key('word_hunt_gokyuzu_master_art_phone_viewport'),
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                clipBehavior: Clip.hardEdge,
                child: SizedBox.fromSize(
                  key: const Key('word_hunt_gokyuzu_master_art_source_scene'),
                  size: WordHuntGokyuzuMasterArtLayout.sourceSize,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      IgnorePointer(
                        child: Image.asset(
                          WordHuntGokyuzuMasterArtAssets.masterArt,
                          key: const Key('word_hunt_gokyuzu_master_art_image'),
                          width:
                              WordHuntGokyuzuMasterArtLayout.sourceSize.width,
                          height:
                              WordHuntGokyuzuMasterArtLayout.sourceSize.height,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      _GokyuzuRuntimeOverlay(route: route, progress: progress),
                      for (
                        var index = 0;
                        index < route.levels.length &&
                            index <
                                WordHuntGokyuzuMasterArtLayout
                                    .levelCenters
                                    .length;
                        index++
                      )
                        _TransparentHitbox(
                          key: Key(
                            'word_hunt_gokyuzu_master_art_level_${index + 1}',
                          ),
                          center:
                              WordHuntGokyuzuMasterArtLayout
                                  .levelCenters[index],
                          diameter:
                              WordHuntGokyuzuMasterArtLayout
                                  .levelHitboxDiameters[index],
                          semanticLabel: 'Bölüm ${index + 1}',
                          onTap:
                              WordHuntRouteProgressEngine.isLevelUnlocked(
                                        route,
                                        progress,
                                        index + 1,
                                      ) &&
                                      onLevelTap != null
                                  ? () => onLevelTap!(index + 1)
                                  : null,
                        ),
                      _TransparentHitbox(
                        key: const Key('word_hunt_gokyuzu_master_art_compass'),
                        center: WordHuntGokyuzuMasterArtLayout.compassCenter,
                        diameter:
                            WordHuntGokyuzuMasterArtLayout
                                .bottomControlHitboxDiameter,
                        semanticLabel: 'Pusula',
                        onTap: onCompass,
                      ),
                      _TransparentHitbox(
                        key: const Key('word_hunt_gokyuzu_master_art_book'),
                        center: WordHuntGokyuzuMasterArtLayout.bookCenter,
                        diameter:
                            WordHuntGokyuzuMasterArtLayout
                                .bottomControlHitboxDiameter,
                        semanticLabel: 'Bilgi Kitabı',
                        onTap: onBook,
                      ),
                      _VisibleTopControl(
                        key: const Key('word_hunt_gokyuzu_master_art_back'),
                        center: WordHuntGokyuzuMasterArtLayout.backCenter,
                        semanticLabel: 'Geri',
                        icon: Icons.arrow_back_rounded,
                        onTap: onBack,
                      ),
                      _VisibleTopControl(
                        key: const Key('word_hunt_gokyuzu_master_art_info'),
                        center: WordHuntGokyuzuMasterArtLayout.infoCenter,
                        semanticLabel: 'Bilgi',
                        icon: Icons.info_outline_rounded,
                        onTap: onInfo,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            key: Key('word_hunt_gokyuzu_banner_reserve'),
            height: WordHuntGokyuzuMasterArtLayout.bannerReserveHeight,
            width: double.infinity,
            child: ColoredBox(color: Color(0xFF072B58)),
          ),
        ],
      ),
    );
  }
}

class _GokyuzuRuntimeOverlay extends StatelessWidget {
  const _GokyuzuRuntimeOverlay({required this.route, required this.progress});

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final totalStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (totalStars != 0)
            _CounterPatch(
              key: const Key('word_hunt_gokyuzu_master_art_progress'),
              rect: WordHuntGokyuzuMasterArtLayout.progressCounterRect,
              text: '$totalStars / ${route.maximumStars}',
            ),
          if (route.unlockStarsRequired != 18)
            _CounterPatch(
              key: const Key('word_hunt_gokyuzu_master_art_gate'),
              rect: WordHuntGokyuzuMasterArtLayout.gateCounterRect,
              text: 'Kapı: ${route.unlockStarsRequired}',
            ),
          for (
            var index = 0;
            index < route.levels.length &&
                index < WordHuntGokyuzuMasterArtLayout.levelCenters.length;
            index++
          )
            if (!WordHuntRouteProgressEngine.isLevelUnlocked(
              route,
              progress,
              index + 1,
            ))
              _LockBadge(
                key: Key(
                  'word_hunt_gokyuzu_master_art_level_${index + 1}_locked',
                ),
                center: WordHuntGokyuzuMasterArtLayout.levelCenters[index],
              ),
        ],
      ),
    );
  }
}

class _CounterPatch extends StatelessWidget {
  const _CounterPatch({super.key, required this.rect, required this.text});

  final Rect rect;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xEC09284C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFC52F), width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x88000000), blurRadius: 5),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 3)],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge({super.key, required this.center});

  final Offset center;

  @override
  Widget build(BuildContext context) {
    const diameter = 46.0;
    final badgeCenter = center + const Offset(38, -27);
    return Positioned(
      left: badgeCenter.dx - diameter / 2,
      top: badgeCenter.dy - diameter / 2,
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xE8092443),
          border: Border.all(color: const Color(0xFFFFC52F), width: 2.5),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x99000000), blurRadius: 6),
          ],
        ),
        child: const Icon(
          Icons.lock_rounded,
          color: Color(0xFFF7F4E9),
          size: 22,
        ),
      ),
    );
  }
}

class _VisibleTopControl extends StatelessWidget {
  const _VisibleTopControl({
    super.key,
    required this.center,
    required this.semanticLabel,
    required this.icon,
    this.onTap,
  });

  final Offset center;
  final String semanticLabel;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final diameter = WordHuntGokyuzuMasterArtLayout.topControlDiameter;
    return Positioned(
      left: center.dx - diameter / 2,
      top: center.dy - diameter / 2,
      width: diameter,
      height: diameter,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xF2082F63),
              border: Border.all(color: const Color(0xFFFFC52F), width: 4),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFFFD45A), size: 38),
          ),
        ),
      ),
    );
  }
}

class _TransparentHitbox extends StatelessWidget {
  const _TransparentHitbox({
    super.key,
    required this.center,
    required this.diameter,
    required this.semanticLabel,
    this.onTap,
  });

  final Offset center;
  final double diameter;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - diameter / 2,
      top: center.dy - diameter / 2,
      width: diameter,
      height: diameter,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
