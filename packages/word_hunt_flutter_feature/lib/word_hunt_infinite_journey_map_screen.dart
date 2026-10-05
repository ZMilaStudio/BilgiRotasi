import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_journey_geometry.dart';

enum WordHuntJourneyNodeState {
  locked,
  current,
  completed1,
  completed2,
  completed3,
  challenge,
  milestone,
}

typedef WordHuntJourneyStateResolver =
    WordHuntJourneyNodeState Function(int ordinal);

class WordHuntInfiniteJourneyMapScreen extends StatefulWidget {
  const WordHuntInfiniteJourneyMapScreen({
    super.key,
    required this.publishedLevelCount,
    required this.stateForOrdinal,
    this.initialOrdinal = 1,
    this.levelsPerChunk = 20,
    this.onLevelTap,
  }) : assert(publishedLevelCount >= 1),
       assert(initialOrdinal >= 1);

  final int publishedLevelCount;
  final int initialOrdinal;
  final int levelsPerChunk;
  final WordHuntJourneyStateResolver stateForOrdinal;
  final ValueChanged<int>? onLevelTap;

  @override
  State<WordHuntInfiniteJourneyMapScreen> createState() =>
      _WordHuntInfiniteJourneyMapScreenState();
}

class _WordHuntInfiniteJourneyMapScreenState
    extends State<WordHuntInfiniteJourneyMapScreen> {
  late final ScrollController _controller;
  late final WordHuntJourneyGeometry _geometry;

  @override
  void initState() {
    super.initState();
    _geometry = WordHuntJourneyGeometry(
      levelsPerChunk: widget.levelsPerChunk,
    );
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jumpToLevel(widget.initialOrdinal);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void jumpToLevel(int ordinal) {
    if (!_controller.hasClients) return;
    final clamped = ordinal.clamp(1, widget.publishedLevelCount);
    final targetY = ((clamped - 1) * _geometry.rowPitch) -
        (MediaQuery.sizeOf(context).height * 0.35);
    final max = _controller.position.maxScrollExtent;
    _controller.jumpTo(targetY.clamp(0.0, max));
  }

  @override
  Widget build(BuildContext context) {
    final chunkCount =
        (widget.publishedLevelCount / widget.levelsPerChunk).ceil();

    return Scaffold(
      backgroundColor: const Color(0xFF0E2230),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                ListView.builder(
                  key: const Key('word_hunt_infinite_journey_list'),
                  controller: _controller,
                  itemExtent: _geometry.chunkExtent,
                  itemCount: chunkCount,
                  itemBuilder: (context, chunkIndex) {
                    final firstOrdinal =
                        (chunkIndex * widget.levelsPerChunk) + 1;
                    final lastOrdinal = math.min(
                      widget.publishedLevelCount,
                      firstOrdinal + widget.levelsPerChunk - 1,
                    );
                    return _JourneyChunk(
                      key: ValueKey('journey_chunk_$chunkIndex'),
                      geometry: _geometry,
                      chunkIndex: chunkIndex,
                      firstOrdinal: firstOrdinal,
                      lastOrdinal: lastOrdinal,
                      viewportWidth: constraints.maxWidth,
                      stateForOrdinal: widget.stateForOrdinal,
                      onLevelTap: widget.onLevelTap,
                    );
                  },
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    key: const Key('word_hunt_journey_continue'),
                    onPressed: () => jumpToLevel(widget.initialOrdinal),
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
}

class _JourneyChunk extends StatelessWidget {
  const _JourneyChunk({
    super.key,
    required this.geometry,
    required this.chunkIndex,
    required this.firstOrdinal,
    required this.lastOrdinal,
    required this.viewportWidth,
    required this.stateForOrdinal,
    this.onLevelTap,
  });

  final WordHuntJourneyGeometry geometry;
  final int chunkIndex;
  final int firstOrdinal;
  final int lastOrdinal;
  final double viewportWidth;
  final WordHuntJourneyStateResolver stateForOrdinal;
  final ValueChanged<int>? onLevelTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _JourneyRoutePainter(
                geometry: geometry,
                firstOrdinal: firstOrdinal,
                lastOrdinal: lastOrdinal,
                viewportWidth: viewportWidth,
              ),
            ),
          ),
          for (var ordinal = firstOrdinal; ordinal <= lastOrdinal; ordinal++)
            _JourneyNode(
              ordinal: ordinal,
              state: stateForOrdinal(ordinal),
              center: geometry.localCenterForOrdinal(ordinal, viewportWidth),
              hitSize: geometry.nodeHitSize,
              onTap: onLevelTap,
            ),
        ],
      ),
    );
  }
}

class _JourneyNode extends StatelessWidget {
  const _JourneyNode({
    required this.ordinal,
    required this.state,
    required this.center,
    required this.hitSize,
    this.onTap,
  });

  final int ordinal;
  final WordHuntJourneyNodeState state;
  final Offset center;
  final double hitSize;
  final ValueChanged<int>? onTap;

  bool get unlocked => state != WordHuntJourneyNodeState.locked;

  int get stars => switch (state) {
        WordHuntJourneyNodeState.completed1 => 1,
        WordHuntJourneyNodeState.completed2 => 2,
        WordHuntJourneyNodeState.completed3 => 3,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    final label = [
      'Bölüm $ordinal',
      if (state == WordHuntJourneyNodeState.challenge) 'meydan okuma',
      if (state == WordHuntJourneyNodeState.milestone) 'kilometre taşı',
      unlocked ? 'açık' : 'kilitli',
      '$stars yıldız',
    ].join(', ');

    return Positioned(
      left: center.dx - (hitSize / 2),
      top: center.dy - (hitSize / 2),
      width: hitSize,
      height: hitSize,
      child: Semantics(
        label: label,
        button: unlocked,
        enabled: unlocked,
        onTap: unlocked && onTap != null ? () => onTap!(ordinal) : null,
        child: GestureDetector(
          key: Key('word_hunt_journey_level_$ordinal'),
          behavior: HitTestBehavior.opaque,
          onTap: unlocked && onTap != null ? () => onTap!(ordinal) : null,
          child: Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _fillColor(state),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.82),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 7,
                    offset: Offset(0, 3),
                    color: Color(0x66000000),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: state == WordHuntJourneyNodeState.locked
                  ? const Icon(Icons.lock_rounded, color: Colors.white)
                  : Text(
                      '$ordinal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Color _fillColor(WordHuntJourneyNodeState state) {
    return switch (state) {
      WordHuntJourneyNodeState.locked => const Color(0xFF5C6670),
      WordHuntJourneyNodeState.current => const Color(0xFFE39A28),
      WordHuntJourneyNodeState.completed1 => const Color(0xFF3B7F78),
      WordHuntJourneyNodeState.completed2 => const Color(0xFF347F6D),
      WordHuntJourneyNodeState.completed3 => const Color(0xFF2D8C65),
      WordHuntJourneyNodeState.challenge => const Color(0xFF8C4A74),
      WordHuntJourneyNodeState.milestone => const Color(0xFF8A6B2F),
    };
  }
}

class _JourneyRoutePainter extends CustomPainter {
  const _JourneyRoutePainter({
    required this.geometry,
    required this.firstOrdinal,
    required this.lastOrdinal,
    required this.viewportWidth,
  });

  final WordHuntJourneyGeometry geometry;
  final int firstOrdinal;
  final int lastOrdinal;
  final double viewportWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x99D9C79A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final first = geometry.localCenterForOrdinal(firstOrdinal, viewportWidth);
    path.moveTo(first.dx, first.dy);

    for (var ordinal = firstOrdinal + 1;
        ordinal <= lastOrdinal;
        ordinal++) {
      final next = geometry.localCenterForOrdinal(ordinal, viewportWidth);
      final previous =
          geometry.localCenterForOrdinal(ordinal - 1, viewportWidth);
      final midY = (previous.dy + next.dy) / 2;
      path.cubicTo(
        previous.dx,
        midY,
        next.dx,
        midY,
        next.dx,
        next.dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _JourneyRoutePainter oldDelegate) {
    return oldDelegate.firstOrdinal != firstOrdinal ||
        oldDelegate.lastOrdinal != lastOrdinal ||
        oldDelegate.viewportWidth != viewportWidth ||
        oldDelegate.geometry != geometry;
  }
}
