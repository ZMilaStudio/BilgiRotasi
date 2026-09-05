import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';

/// Gökyüzü Adaları için Levent'in 5 Eylül 2026'da yeniden teyit ettiği
/// onaylı V2 master-art rota ekranı.
///
/// Görünür dünya tek raster master art'tır. Flutter yalnız etkileşim hitbox'ları
/// ve gerekli minimum progression override'larını üretir; rota/adalar/chrome
/// yeniden çizilmez.
abstract final class WordHuntGokyuzuMasterArtAssets {
  static const String masterArt =
      'assets/word_hunt/gokyuzu_adalari_master_art_v2.jpg';
}

abstract final class WordHuntGokyuzuMasterArtLayout {
  /// Repository'ye alınan onaylı V2 kaynağının normalize edilmiş raster boyutu.
  static const Size sourceSize = Size(720, 1019);

  static const List<Offset> levelCenters = <Offset>[
    Offset(115, 223),
    Offset(337, 268),
    Offset(535, 354),
    Offset(146, 440),
    Offset(367, 520),
    Offset(558, 568),
    Offset(131, 635),
    Offset(341, 701),
    Offset(160, 817),
    Offset(558, 824),
  ];

  static const List<double> levelHitboxDiameters = <double>[
    76,
    76,
    76,
    82,
    82,
    88,
    82,
    88,
    88,
    98,
  ];

  static const Offset compassCenter = Offset(63, 938);
  static const Offset bookCenter = Offset(660, 938);
  static const double bottomControlHitboxDiameter = 108;

  static const Offset backCenter = Offset(44, 24);
  static const Offset infoCenter = Offset(676, 24);
  static const double topControlHitboxDiameter = 72;

  static const Rect progressCounterRect = Rect.fromLTWH(201, 71, 96, 31);
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
      backgroundColor: const Color(0xFF07162C),
      body: ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fill,
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
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  _ProgressCounter(route: route, progress: progress),
                  for (
                    var index = 0;
                    index < WordHuntGokyuzuMasterArtLayout.levelCenters.length &&
                        index < route.levels.length;
                    index++
                  ) ...<Widget>[
                    if (!WordHuntRouteProgressEngine.isLevelUnlocked(
                      route,
                      progress,
                      index + 1,
                    ))
                      _LockedMarker(
                        key: Key('word_hunt_gokyuzu_level_${index + 1}_locked'),
                        center:
                            WordHuntGokyuzuMasterArtLayout.levelCenters[index],
                      ),
                    _TransparentHitbox(
                      key: Key('word_hunt_gokyuzu_level_${index + 1}'),
                      center:
                          WordHuntGokyuzuMasterArtLayout.levelCenters[index],
                      diameter: WordHuntGokyuzuMasterArtLayout
                          .levelHitboxDiameters[index],
                      onTap: WordHuntRouteProgressEngine.isLevelUnlocked(
                                route,
                                progress,
                                index + 1,
                              ) &&
                              onLevelTap != null
                          ? () => onLevelTap!(index + 1)
                          : null,
                    ),
                  ],
                  _TransparentHitbox(
                    key: const Key('word_hunt_gokyuzu_compass'),
                    center: WordHuntGokyuzuMasterArtLayout.compassCenter,
                    diameter: WordHuntGokyuzuMasterArtLayout
                        .bottomControlHitboxDiameter,
                    onTap: onCompass,
                  ),
                  _TransparentHitbox(
                    key: const Key('word_hunt_gokyuzu_book'),
                    center: WordHuntGokyuzuMasterArtLayout.bookCenter,
                    diameter: WordHuntGokyuzuMasterArtLayout
                        .bottomControlHitboxDiameter,
                    onTap: onBook,
                  ),
                  _TransparentHitbox(
                    key: const Key('word_hunt_gokyuzu_back'),
                    center: WordHuntGokyuzuMasterArtLayout.backCenter,
                    diameter:
                        WordHuntGokyuzuMasterArtLayout.topControlHitboxDiameter,
                    onTap: onBack,
                  ),
                  _TransparentHitbox(
                    key: const Key('word_hunt_gokyuzu_info'),
                    center: WordHuntGokyuzuMasterArtLayout.infoCenter,
                    diameter:
                        WordHuntGokyuzuMasterArtLayout.topControlHitboxDiameter,
                    onTap: onInfo,
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

class _ProgressCounter extends StatelessWidget {
  const _ProgressCounter({required this.route, required this.progress});

  final WordHuntRouteDefinition route;
  final WordHuntProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final stars = WordHuntRouteProgressEngine.totalStars(route, progress);
    return Positioned.fromRect(
      rect: WordHuntGokyuzuMasterArtLayout.progressCounterRect,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xE8091A33),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$stars / ${route.maximumStars}',
              key: const Key('word_hunt_gokyuzu_progress_text'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1,
                shadows: <Shadow>[
                  Shadow(color: Colors.black, blurRadius: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedMarker extends StatelessWidget {
  const _LockedMarker({super.key, required this.center});

  final Offset center;

  @override
  Widget build(BuildContext context) {
    const size = 38.0;
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xD31B2430),
            border: Border.all(color: const Color(0xFFE8EDF5), width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x99000000), blurRadius: 5),
            ],
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: Color(0xFFF2F4F8),
            size: 22,
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
    this.onTap,
  });

  final Offset center;
  final double diameter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - diameter / 2,
      top: center.dy - diameter / 2,
      width: diameter,
      height: diameter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    );
  }
}
