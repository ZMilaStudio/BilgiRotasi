import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'word_hunt_journey_geometry.dart';
import 'word_hunt_journey_background.dart';
import 'word_hunt_journey_art.dart';
import 'word_hunt_journey_theme.dart';

enum WordHuntJourneyNodeState {
  locked,
  current,
  completed1,
  completed2,
  completed3,
}

/// Modifiers never grant access or replace earned stars.
class WordHuntJourneyNodePresentation {
  const WordHuntJourneyNodePresentation(
    this.state, {
    this.challenge = false,
    this.milestone = false,
  });
  final WordHuntJourneyNodeState state;
  final bool challenge, milestone;
  bool get unlocked => state != WordHuntJourneyNodeState.locked;
  int get stars => switch (state) {
    WordHuntJourneyNodeState.completed1 => 1,
    WordHuntJourneyNodeState.completed2 => 2,
    WordHuntJourneyNodeState.completed3 => 3,
    _ => 0,
  };
}

typedef WordHuntJourneyStateResolver =
    WordHuntJourneyNodePresentation Function(int ordinal);

/// No save writes. Pre-attachment requests are retained.
class WordHuntJourneyMapController {
  void Function(int)? _jump;
  int? _pending;
  void jumpToLevel(int ordinal) {
    if (_jump == null) {
      _pending = ordinal;
    } else {
      _jump!(ordinal);
    }
  }
}

class WordHuntInfiniteJourneyMapScreen extends StatefulWidget {
  const WordHuntInfiniteJourneyMapScreen({
    super.key,
    required this.publishedLevelCount,
    required this.stateForOrdinal,
    this.initialOrdinal = 1,
    this.currentOrdinal = 1,
    this.levelsPerChunk = 20,
    this.onLevelTap,
    this.controller,
    this.showContinueControl = true,
    this.themeSchedule,
    this.artRegistry,
    this.artProvider,
  }) : assert(publishedLevelCount >= 1),
       assert(initialOrdinal >= 1),
       assert(currentOrdinal >= 1),
       assert(levelsPerChunk > 0);
  final int publishedLevelCount, initialOrdinal, currentOrdinal, levelsPerChunk;
  final WordHuntJourneyStateResolver stateForOrdinal;
  final ValueChanged<int>? onLevelTap;
  final WordHuntJourneyMapController? controller;
  final bool showContinueControl;
  final JourneyThemeSchedule? themeSchedule;
  final JourneyArtRegistry? artRegistry;
  final JourneyArtProvider? artProvider;
  @override
  State<WordHuntInfiniteJourneyMapScreen> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<WordHuntInfiniteJourneyMapScreen> {
  ScrollController? _scroll;
  double _height = 0;
  WordHuntJourneyGeometry get geometry =>
      WordHuntJourneyGeometry(levelsPerChunk: widget.levelsPerChunk);
  @override
  void initState() {
    super.initState();
    widget.controller?._jump = _jump;
  }

  @override
  void didUpdateWidget(covariant WordHuntInfiniteJourneyMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._jump = null;
      widget.controller?._jump = _jump;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pending = widget.controller?._pending;
      if (pending != null) {
        widget.controller?._pending = null;
        _jump(pending);
      }
      if (_scroll!.hasClients) {
        final p = _scroll!.position;
        if (p.pixels > p.maxScrollExtent) _scroll!.jumpTo(p.maxScrollExtent);
      }
    });
  }

  void _jump(int ordinal) {
    if (_scroll == null ||
        !_scroll!.hasClients ||
        !_scroll!.position.hasContentDimensions) {
      widget.controller?._pending = ordinal;
      return;
    }
    _scroll!.jumpTo(
      geometry.offsetForOrdinal(ordinal, widget.publishedLevelCount, _height),
    );
  }

  @override
  void dispose() {
    widget.controller?._jump = null;
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0E2230),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _height = constraints.maxHeight;
          if (_scroll == null) {
            final initial =
                widget.controller?._pending ?? widget.initialOrdinal;
            widget.controller?._pending = null;
            _scroll = ScrollController(
              initialScrollOffset: geometry.offsetForOrdinal(
                initial,
                widget.publishedLevelCount,
                _height,
              ),
            );
          }
          return Stack(
            children: [
              AnimatedBuilder(
                animation: _scroll!,
                builder: (context, _) {
                  final offset =
                      _scroll!.hasClients
                          ? _scroll!.offset
                          : _scroll!.initialScrollOffset;
                  final visible = Rect.fromLTWH(
                    0,
                    offset,
                    constraints.maxWidth,
                    _height,
                  );
                  return ListView.builder(
                    key: const Key('word_hunt_infinite_journey_list'),
                    controller: _scroll,
                    padding: EdgeInsets.zero,
                    itemExtent: geometry.chunkExtent,
                    scrollCacheExtent: ScrollCacheExtent.pixels(_height),
                    addAutomaticKeepAlives: false,
                    itemCount:
                        (widget.publishedLevelCount +
                            widget.levelsPerChunk -
                            1) ~/
                        widget.levelsPerChunk,
                    itemBuilder:
                        (context, chunk) => _JourneyChunk(
                          key: ValueKey('journey_chunk_$chunk'),
                          geometry: geometry,
                          chunk: chunk,
                          count: widget.publishedLevelCount,
                          width: constraints.maxWidth,
                          visible: visible,
                          resolver: widget.stateForOrdinal,
                          onTap: widget.onLevelTap,
                          themeSchedule: widget.themeSchedule,
                          artRegistry: widget.artRegistry,
                          artProvider: widget.artProvider,
                        ),
                  );
                },
              ),
              if (widget.showContinueControl)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    key: const Key('word_hunt_journey_continue'),
                    tooltip: 'Devam Et',
                    onPressed: () => _jump(widget.currentOrdinal),
                    child: const Icon(Icons.my_location),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}

class _JourneyChunk extends StatelessWidget {
  const _JourneyChunk({
    super.key,
    required this.geometry,
    required this.chunk,
    required this.count,
    required this.width,
    required this.visible,
    required this.resolver,
    this.onTap,
    this.themeSchedule,
    this.artRegistry,
    this.artProvider,
  });
  final WordHuntJourneyGeometry geometry;
  final int chunk, count;
  final double width;
  final Rect visible;
  final WordHuntJourneyStateResolver resolver;
  final ValueChanged<int>? onTap;
  final JourneyThemeSchedule? themeSchedule;
  final JourneyArtRegistry? artRegistry;
  final JourneyArtProvider? artProvider;
  @override
  Widget build(BuildContext context) {
    final first = chunk * geometry.levelsPerChunk + 1;
    final last = math.min(count, first + geometry.levelsPerChunk - 1);
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (themeSchedule != null)
            Positioned.fill(
              child: JourneyChunkBackground(
                key: ValueKey('journey_background_$chunk'),
                schedule: themeSchedule!,
                firstOrdinal: first,
                rows: last - first + 1,
                rowPitch: geometry.rowPitch,
              ),
            ),
          if (themeSchedule != null)
            Positioned.fill(
              child: JourneyRasterBackground(
                registry: artRegistry ?? JourneyArtRegistry.production,
                provider: artProvider,
                schedule: themeSchedule!,
                geometry: geometry,
                chunk: chunk,
                count: count,
                width: width,
                visible: visible,
              ),
            ),
          if (themeSchedule != null)
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    key: ValueKey('journey_readability_corridor_$chunk'),
                    painter: JourneyReadabilityCorridor(
                      geometry: geometry,
                      chunk: chunk,
                      count: count,
                      width: width,
                      schedule: themeSchedule!,
                      registry: artRegistry ?? JourneyArtRegistry.production,
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(
                painter: _JourneyRoutePainter(
                  geometry: geometry,
                  chunk: chunk,
                  count: count,
                  width: width,
                ),
              ),
            ),
          ),
          for (var ordinal = first; ordinal <= last; ordinal++)
            if (geometry
                .globalHitRect(ordinal, width)
                .overlaps(visible.inflate(geometry.nodeHitSize)))
              _node(ordinal),
        ],
      ),
    );
  }

  Widget _node(int ordinal) {
    final model = resolver(ordinal);
    final center = geometry.localCenterForOrdinal(ordinal, width);
    final action =
        model.unlocked && onTap != null ? () => onTap!(ordinal) : null;
    final label =
        'Bölüm $ordinal, ${model.challenge ? "meydan okuma, " : ""}'
        '${model.milestone ? "kilometre taşı, " : ""}'
        '${model.unlocked ? "açık" : "kilitli"}, ${model.stars} yıldız';
    return Positioned(
      left: center.dx - 34,
      top: center.dy - 34,
      width: 68,
      height: 68,
      child: ExcludeSemantics(
        excluding: !geometry.globalHitRect(ordinal, width).overlaps(visible),
        child: Semantics(
          label: label,
          button: model.unlocked,
          enabled: model.unlocked,
          onTap: action,
          excludeSemantics: true,
          child: GestureDetector(
            key: Key('word_hunt_journey_level_$ordinal'),
            behavior: HitTestBehavior.opaque,
            onTap: action,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    !model.unlocked
                        ? const Color(0xFF5C6670)
                        : model.state == WordHuntJourneyNodeState.current
                        ? const Color(0xFF985700)
                        : const Color(0xFF22614E),
                border: Border.all(
                  color: model.challenge ? Colors.amber : Colors.white,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF08121D),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!model.unlocked)
                    const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  SizedBox(
                    width: 60,
                    height: 20,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$ordinal',
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  if (model.stars > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < 3; i++)
                          Icon(
                            i < model.stars ? Icons.star : Icons.star_outline,
                            size: 14,
                            color:
                                i < model.stars
                                    ? Colors.amber
                                    : const Color(0xFFB4BFC9),
                          ),
                      ],
                    ),
                  if (model.milestone)
                    const Icon(Icons.flag, size: 10, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyRoutePainter extends CustomPainter {
  const _JourneyRoutePainter({
    required this.geometry,
    required this.chunk,
    required this.count,
    required this.width,
  });
  final WordHuntJourneyGeometry geometry;
  final int chunk, count;
  final double width;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final paint =
        Paint()
          ..color = const Color(0xFFD9C79A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.butt;
    final path = Path();
    for (final curve in geometry.curvesForChunk(chunk, count, width)) {
      path.moveTo(curve.start.dx, curve.start.dy);
      path.cubicTo(
        curve.control1.dx,
        curve.control1.dy,
        curve.control2.dx,
        curve.control2.dy,
        curve.end.dx,
        curve.end.dy,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF08121D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.butt,
    );
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _JourneyRoutePainter old) =>
      old.chunk != chunk ||
      old.count != count ||
      old.width != width ||
      old.geometry.levelsPerChunk != geometry.levelsPerChunk;
}
