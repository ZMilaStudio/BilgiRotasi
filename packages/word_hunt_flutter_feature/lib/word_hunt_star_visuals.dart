import 'package:flutter/material.dart';

/// KARARLAR.md 0B: star ownership is visual only; never computes score.
abstract final class WordHuntStarVisuals {
  static const Color filled = Color(0xFFFFD45B);
  static const Color empty = Color(0xFF65717D);

  static Icon icon({
    required bool earned,
    required double size,
    Key? key,
  }) => Icon(
    earned ? Icons.star_rounded : Icons.star_outline_rounded,
    key: key,
    size: size,
    color: earned ? filled : empty,
    shadows: earned
        ? const <Shadow>[
            Shadow(color: Color(0xA6FFB52B), blurRadius: 5),
            Shadow(color: Color(0x99000000), blurRadius: 2),
          ]
        : const <Shadow>[Shadow(color: Color(0x99000000), blurRadius: 1)],
  );
}

class WordHuntProgressStars extends StatelessWidget {
  const WordHuntProgressStars({
    super.key,
    required this.earned,
    required this.keyPrefix,
    this.size = 17,
  });

  final int earned;
  final String keyPrefix;
  final double size;

  @override
  Widget build(BuildContext context) {
    final count = earned.clamp(0, 3);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (index) => WordHuntStarVisuals.icon(
        earned: index < count,
        size: size,
        key: Key('$keyPrefix$index'),
      )),
    );
  }
}