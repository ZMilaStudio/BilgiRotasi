import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum WordHuntRouteDecorationKind { harbor, sky, forest }

@immutable
class WordHuntRouteDecorationSpec {
  const WordHuntRouteDecorationSpec({
    required this.kind,
    required this.seed,
    this.count = 18,
  }) : assert(count >= 0 && count <= 40);

  final WordHuntRouteDecorationKind kind;
  final int seed;
  final int count;
}

@immutable
class WordHuntRouteDecorationMark {
  const WordHuntRouteDecorationMark({
    required this.center,
    required this.scale,
    required this.rotationTurns,
  });

  final Offset center;
  final double scale;
  final double rotationTurns;
}

/// Rota dekorlarını piksel veya rota-id özel koordinat listesi olmadan üretir.
///
/// Bütün konumlar 0..1 normalize yüzeydedir. Aynı seed + aynı reserved noktalar
/// her cihazda aynı dekor yerleşimini üretir. `reservedPoints` tipik olarak
/// ortak 1-10 node geometrisidir; dekorlar bu alanların yakınına yerleşmez.
abstract final class WordHuntRouteDecorationLayout {
  static const double _minimumReservedDistance = 0.115;
  static const double _edgeInset = 0.035;

  static List<WordHuntRouteDecorationMark> generate({
    required WordHuntRouteDecorationSpec spec,
    required List<Offset> reservedPoints,
  }) {
    if (spec.count == 0) {
      return const <WordHuntRouteDecorationMark>[];
    }

    final random = math.Random(spec.seed);
    final marks = <WordHuntRouteDecorationMark>[];
    var attempts = 0;
    final maxAttempts = math.max(200, spec.count * 80);

    while (marks.length < spec.count && attempts < maxAttempts) {
      attempts++;
      final candidate = Offset(
        _edgeInset + random.nextDouble() * (1 - 2 * _edgeInset),
        _edgeInset + random.nextDouble() * (1 - 2 * _edgeInset),
      );

      if (_isReserved(candidate, reservedPoints)) {
        continue;
      }
      if (_isTooCloseToExisting(candidate, marks)) {
        continue;
      }

      marks.add(
        WordHuntRouteDecorationMark(
          center: candidate,
          scale: 0.72 + random.nextDouble() * 0.56,
          rotationTurns: random.nextDouble(),
        ),
      );
    }

    return List<WordHuntRouteDecorationMark>.unmodifiable(marks);
  }

  static bool _isReserved(Offset candidate, List<Offset> reservedPoints) {
    for (final point in reservedPoints) {
      if ((candidate - point).distance < _minimumReservedDistance) {
        return true;
      }
    }
    return false;
  }

  static bool _isTooCloseToExisting(
    Offset candidate,
    List<WordHuntRouteDecorationMark> marks,
  ) {
    for (final mark in marks) {
      if ((candidate - mark.center).distance < 0.065) {
        return true;
      }
    }
    return false;
  }
}
