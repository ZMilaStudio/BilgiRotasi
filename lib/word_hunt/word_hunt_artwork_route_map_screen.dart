import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_artwork_presentation.dart';
import 'word_hunt_models.dart';
import 'word_hunt_path_renderer.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reusable_route_map_screen.dart';
import 'word_hunt_route_chrome_theme.dart';
import 'word_hunt_seal_renderer.dart';
import 'word_hunt_route_ux_scope.dart';

/// Raster artwork üstünde ortak 1→10 geometriyi ve gerçek progression hitbox'ını
/// korur. Embedded dekoratif rota seçildiğinde path tekrar çizilmez.
class WordHuntArtworkRouteMapScreen extends StatelessWidget {
  const WordHuntArtworkRouteMapScreen({
    super.key,
    required this.route,
    required this.theme,
    this.overlayMode = WordHuntArtworkOverlayMode.reusable,
    this.progress = const WordHuntProgressSnapshot(),
    this.onLevelTap,
    this.sealSpec,
    this.pathSpec,
    this.chromeTheme,
    this.presentationOrder = WordHuntRoutePresentationOrder.forward,
  });

  final WordHuntRouteDefinition route;
  final WordHuntRouteMapTheme theme;
  final WordHuntArtworkOverlayMode overlayMode;
  final WordHuntProgressSnapshot progress;
  final ValueChanged<int>? onLevelTap;
  final WordHuntSealVisualSpec? sealSpec;
  final WordHuntPathVisualSpec? pathSpec;
  final WordHuntRouteChromeTheme? chromeTheme;
  final WordHuntRoutePresentationOrder presentationOrder;

  // Orman reference canvas compact ekranlarda birlikte ölçeklendiği için
  // görünmeyen hitbox biraz daha geniş tutulur. Görsel node offsetleri aşağıda
  // aynı mutlak merkezde kalacak şekilde telafi edilir.
  static const _hitW = 90.0;
  static const _hitH = 84.0;

  @override
  Widget build(BuildContext context) {
    if (overlayMode != WordHuntArtworkOverlayMode.embeddedRouteLiveNodes) {
      return WordHuntReusableRouteMapScreen(
        route: route,
        theme: theme,
        progress: progress,
        onLevelTap: onLevelTap,
        hostedByArtworkChrome: true,
        sealSpec: sealSpec,
        pathSpec: pathSpec,
        chromeTheme: chromeTheme,
        presentationOrder: presentationOrder,
      );
    }

    final totalStars = WordHuntRouteProgressEngine.totalStars(route, progress);
    final current = WordHuntRouteProgressEngine.nextPlayableLevelIndex(
      route,
      progress,
    );
    final ux = WordHuntRouteUxScope.maybeOf(context);

    return Scaffold(
      key: const Key('word_hunt_reusable_route_map'),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
              child: _ForestHeader(
                title: route.title,
                stars: totalStars,
                maximumStars: route.maximumStars,
                accent: theme.accentColor,
                textColor: theme.textColor,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final points = WordHuntRouteMapGeometry.pointsFor(
                    size,
                    presentationOrder: presentationOrder,
                  );
                  return Stack(
                    key: const Key('word_hunt_reusable_layer_stack'),
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      const Positioned.fill(
                        key: Key('word_hunt_reusable_atmosphere_layer'),
                        child: IgnorePointer(child: SizedBox.expand()),
                      ),
                      const Positioned.fill(
                        key: Key('word_hunt_reusable_path_layer'),
                        child: IgnorePointer(
                          child: SizedBox.expand(
                            key: Key('word_hunt_reusable_route_path'),
                          ),
                        ),
                      ),
                      for (var i = 0; i < 10; i++)
                        _node(
                          point: points[i],
                          mapSize: size,
                          level: route.levels[i],
                          stars: progress.starsFor(route.levels[i].id),
                          unlocked: WordHuntRouteProgressEngine.isLevelUnlocked(
                            route,
                            progress,
                            i + 1,
                          ),
                          completed:
                              WordHuntRouteProgressEngine.isLevelCompleted(
                                route.levels[i],
                                progress,
                              ),
                          current: current == i + 1,
                          highlighted: ux?.highlightedLevelIndex == i + 1,
                          highlightEpoch: ux?.highlightEpoch ?? 0,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _node({
    required Offset point,
    required Size mapSize,
    required WordHuntLevelDefinition level,
    required int stars,
    required bool unlocked,
    required bool completed,
    required bool current,
    required bool highlighted,
    required int highlightEpoch,
  }) {
    final left = (point.dx - _hitW / 2)
        .clamp(0.0, math.max(0.0, mapSize.width - _hitW))
        .toDouble();
    final top = (point.dy - _hitH / 2)
        .clamp(0.0, math.max(0.0, mapSize.height - _hitH))
        .toDouble();
    final state = completed
        ? 'completed'
        : current && unlocked
        ? 'current'
        : unlocked
        ? 'open'
        : 'locked';
    final isFinal = level.type == WordHuntLevelType.routeFinal;

    return Positioned(
      left: left,
      top: top,
      width: _hitW,
      height: _hitH,
      child: Semantics(
        button: unlocked,
        enabled: unlocked,
        label: 'Bölüm ${level.index}${unlocked ? ', açık' : ', kilitli'}',
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: isFinal ? -14 : -1,
              top: isFinal ? -20 : -11,
              width: isFinal ? 118 : 92,
              height: isFinal ? 143 : 112,
              child: IgnorePointer(
                child: Transform.scale(
                  scale: .62,
                  alignment: Alignment.center,
                  child: _ForestStop(
                    level: level,
                    stars: stars,
                    unlocked: unlocked,
                    current: current && unlocked && !completed,
                    highlighted: highlighted,
                    highlightEpoch: highlightEpoch,
                  ),
                ),
              ),
            ),
            if (level.type == WordHuntLevelType.challenge)
              const SizedBox.shrink(key: Key('word_hunt_route_stop_plaque_5')),
            if (isFinal)
              const SizedBox.shrink(key: Key('word_hunt_route_stop_plaque_10')),
            Positioned.fill(
              child: GestureDetector(
                key: Key('word_hunt_reusable_level_${level.index}'),
                behavior: HitTestBehavior.opaque,
                onTap: unlocked && onLevelTap != null
                    ? () => onLevelTap!(level.index)
                    : null,
                child: SizedBox.expand(
                  key: Key('word_hunt_reusable_node_${level.index}_$state'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForestStop extends StatelessWidget {
  const _ForestStop({
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.current,
    required this.highlighted,
    required this.highlightEpoch,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final bool current;
  final bool highlighted;
  final int highlightEpoch;

  @override
  Widget build(BuildContext context) {
    final isFinal = level.type == WordHuntLevelType.routeFinal;
    final asset = isFinal
        ? 'assets/word_hunt/orman_node_final.b64'
        : unlocked
        ? 'assets/word_hunt/orman_node_open.b64'
        : 'assets/word_hunt/orman_node_locked.b64';
    final size = isFinal
        ? 112.0
        : unlocked
        ? 84.0
        : 88.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox.square(
          dimension: size,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: <Widget>[
              if (current && !isFinal)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFFFFD15A).withValues(alpha: .54),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              if (highlighted)
                Positioned.fill(
                  child: _CompassPulse(
                    key: ValueKey<String>(
                      'word_hunt_route_stop_compass_highlight_${level.index}_$highlightEpoch',
                    ),
                  ),
                ),
              Opacity(
                opacity: isFinal && !unlocked ? .72 : 1,
                child: _Base64Image(
                  asset: asset,
                  key: Key('word_hunt_route_stop_asset_${level.index}'),
                ),
              ),
              if (isFinal && !unlocked)
                Align(
                  alignment: const Alignment(0, .03),
                  child: Container(
                    key: const Key('word_hunt_route_final_lock'),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xE31A1712),
                      border: Border.all(
                        color: const Color(0xFFB6A274),
                        width: 2.2,
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0xB3000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFFE4DED0),
                      size: 29,
                    ),
                  ),
                ),
              if (unlocked && !isFinal)
                Align(
                  alignment: const Alignment(0, -.02),
                  child: Text(
                    '${level.index}',
                    key: Key('word_hunt_route_stop_number_${level.index}'),
                    style: const TextStyle(
                      color: Color(0xFFFFF8E8),
                      fontFamily: 'serif',
                      fontSize: 29,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      shadows: <Shadow>[
                        Shadow(
                          color: Color(0xE6000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Transform.translate(
          // Scenic artwork üzerinde dekoratif yıldız işaretleri bulunduğu için
          // canlı yıldız sırasını onların üstüne hizalayıp tek okunur sıra
          // bırakıyoruz. Final assetinde bu dekoratif sıra yok; eski hizası kalır.
          offset: Offset(0, isFinal ? -5 : 14),
          child: _Stars(
            stars: !unlocked ? 0 : stars.clamp(0, 3).toInt(),
            muted: !unlocked,
            size: isFinal ? 21 : 18,
          ),
        ),
      ],
    );
  }
}

class _CompassPulse extends StatelessWidget {
  const _CompassPulse({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: (1 - value).clamp(0, 1),
          child: Transform.scale(scale: .86 + (.44 * value), child: child),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFDF77), width: 4),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0xB8FFD35A),
              blurRadius: 22,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.stars, required this.muted, required this.size});
  final int stars;
  final bool muted;
  final double size;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xE8070A08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(3, (i) {
          final filled = i < stars;
          final color = muted
              ? const Color(0xFFA7ADA6)
              : filled
              ? const Color(0xFFFFC928)
              : const Color(0xFF9DA39C);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Icon(
                  Icons.star_rounded,
                  size: size + 4,
                  color: const Color(0xE5231C12),
                ),
                Icon(
                  Icons.star_rounded,
                  size: size,
                  color: color,
                  shadows: filled
                      ? const <Shadow>[
                          Shadow(color: Color(0xCCF58D00), blurRadius: 5),
                        ]
                      : null,
                ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}

class _ForestHeader extends StatelessWidget {
  const _ForestHeader({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.accent,
    required this.textColor,
  });
  final String title;
  final int stars;
  final int maximumStars;
  final Color accent;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 338),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xF20A2115),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: accent.withValues(alpha: .84), width: 1.4),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x92000000),
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Container(
          key: const Key('word_hunt_orman_header_panel'),
          height: 47,
          padding: const EdgeInsets.fromLTRB(12, 3, 10, 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x38FFF2C2)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xF01B3A24), Color(0xF00A1A10)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'KELİME AVI',
                style: TextStyle(
                  color: accent.withValues(alpha: .96),
                  fontFamily: 'serif',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      key: const Key('word_hunt_reusable_route_title'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'serif',
                        fontSize: 19,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        shadows: const <Shadow>[
                          Shadow(color: Color(0xCC000000), blurRadius: 5),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    key: const Key('word_hunt_reusable_route_stars'),
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xD006130C),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: accent.withValues(alpha: .62)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.star_rounded, color: accent, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '$stars / $maximumStars',
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'serif',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Base64Image extends StatefulWidget {
  const _Base64Image({super.key, required this.asset});
  final String asset;

  @override
  State<_Base64Image> createState() => _Base64ImageState();
}

class _Base64ImageState extends State<_Base64Image> {
  late Future<Uint8List> bytes;

  @override
  void initState() {
    super.initState();
    bytes = _load();
  }

  @override
  void didUpdateWidget(covariant _Base64Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) bytes = _load();
  }

  Future<Uint8List> _load() async =>
      base64Decode((await rootBundle.loadString(widget.asset)).trim());

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: bytes,
    builder: (context, snapshot) => snapshot.data == null
        ? const SizedBox.expand()
        : Image.memory(
            snapshot.data!,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
  );
}
