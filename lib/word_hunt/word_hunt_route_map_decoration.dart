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

@immutable
class WordHuntRouteDecorationPalette {
  const WordHuntRouteDecorationPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
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

/// Proof/skin katmanında kullanılan ortak motif painter'ı.
///
/// Konumları kendisi seçmez; `WordHuntRouteDecorationLayout` tarafından üretilen
/// normalize işaretleri boyar. Böylece motif türü değişse bile node/path
/// geometrisi veya rota başına elle koordinat yazma ihtiyacı oluşmaz.
class WordHuntRouteDecorationPainter extends CustomPainter {
  const WordHuntRouteDecorationPainter({
    required this.spec,
    required this.reservedPoints,
    required this.palette,
    this.opacity = 0.42,
  });

  final WordHuntRouteDecorationSpec spec;
  final List<Offset> reservedPoints;
  final WordHuntRouteDecorationPalette palette;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final marks = WordHuntRouteDecorationLayout.generate(
      spec: spec,
      reservedPoints: reservedPoints,
    );

    for (final mark in marks) {
      final center = Offset(
        mark.center.dx * size.width,
        mark.center.dy * size.height,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(mark.rotationTurns * math.pi * 2);

      switch (spec.kind) {
        case WordHuntRouteDecorationKind.forest:
          _paintForest(canvas, mark.scale);
        case WordHuntRouteDecorationKind.sky:
          _paintSky(canvas, mark.scale);
        case WordHuntRouteDecorationKind.harbor:
          _paintHarbor(canvas, mark.scale);
      }

      canvas.restore();
    }
  }

  void _paintForest(Canvas canvas, double scale) {
    final trunkPaint = Paint()
      ..color = palette.secondary.withValues(alpha: opacity * 0.82);
    final leafPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity);
    final highlightPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.52);

    final trunk = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, 9 * scale),
        width: 5.5 * scale,
        height: 22 * scale,
      ),
      Radius.circular(2.5 * scale),
    );
    canvas.drawRRect(trunk, trunkPaint);
    canvas.drawCircle(Offset(0, -6 * scale), 13 * scale, leafPaint);
    canvas.drawCircle(Offset(-8 * scale, 1 * scale), 9 * scale, leafPaint);
    canvas.drawCircle(Offset(8 * scale, 1 * scale), 9 * scale, leafPaint);
    canvas.drawCircle(
      Offset(-4 * scale, -10 * scale),
      3.3 * scale,
      highlightPaint,
    );
  }

  void _paintSky(Canvas canvas, double scale) {
    final cloudPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.72);
    final starPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 28 * scale,
        height: 12 * scale,
      ),
      cloudPaint,
    );
    canvas.drawCircle(Offset(-7 * scale, -4 * scale), 7 * scale, cloudPaint);
    canvas.drawCircle(Offset(4 * scale, -6 * scale), 9 * scale, cloudPaint);
    canvas.drawCircle(Offset(13 * scale, -13 * scale), 2.3 * scale, starPaint);
  }

  void _paintHarbor(Canvas canvas, double scale) {
    final waterPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;
    final buoyPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.92);

    final wave = Path()
      ..moveTo(-16 * scale, 2 * scale)
      ..quadraticBezierTo(
        -8 * scale,
        -5 * scale,
        0,
        2 * scale,
      )
      ..quadraticBezierTo(
        8 * scale,
        9 * scale,
        16 * scale,
        2 * scale,
      );
    canvas.drawPath(wave, waterPaint);
    canvas.drawCircle(Offset(0, -8 * scale), 4.2 * scale, buoyPaint);
  }

  @override
  bool shouldRepaint(covariant WordHuntRouteDecorationPainter oldDelegate) {
    return oldDelegate.spec != spec ||
        oldDelegate.reservedPoints != reservedPoints ||
        oldDelegate.palette != palette ||
        oldDelegate.opacity != opacity;
  }
}
