import 'dart:math' as math;

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
///
/// Sahne tabanı da yalnız dekor türünden üretilir; route-id veya level
/// koordinatına göre branch içermez. Yol ve node katmanları bu painter'ın
/// üstünde kaldığı için etkileşim geometrisine dokunmaz.
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
    if (size.isEmpty || opacity <= 0) return;

    _paintSceneBase(canvas, size);

    final marks = WordHuntRouteDecorationLayout.generate(
      spec: spec,
      reservedPoints: reservedPoints,
    );

    for (var index = 0; index < marks.length; index++) {
      final mark = marks[index];
      final center = Offset(
        mark.center.dx * size.width,
        mark.center.dy * size.height,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(_motifRotation(mark.rotationTurns));

      switch (spec.kind) {
        case WordHuntRouteDecorationKind.forest:
          _paintForest(canvas, mark.scale, index);
        case WordHuntRouteDecorationKind.sky:
          _paintSky(canvas, mark.scale, index);
        case WordHuntRouteDecorationKind.harbor:
          _paintHarbor(canvas, mark.scale, index);
      }

      canvas.restore();
    }
  }

  double _motifRotation(double turns) {
    final centeredTurns = turns - 0.5;
    switch (spec.kind) {
      case WordHuntRouteDecorationKind.forest:
        return centeredTurns * math.pi * 0.16;
      case WordHuntRouteDecorationKind.sky:
        return centeredTurns * math.pi * 0.04;
      case WordHuntRouteDecorationKind.harbor:
        return centeredTurns * math.pi * 0.10;
    }
  }

  void _paintSceneBase(Canvas canvas, Size size) {
    switch (spec.kind) {
      case WordHuntRouteDecorationKind.forest:
        _paintForestBase(canvas, size);
      case WordHuntRouteDecorationKind.sky:
        _paintSkyBase(canvas, size);
      case WordHuntRouteDecorationKind.harbor:
        _paintHarborBase(canvas, size);
    }
  }

  void _paintForestBase(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final longestSide = math.max(size.width, size.height);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          palette.accent.withValues(alpha: opacity * 0.18),
          palette.primary.withValues(alpha: opacity * 0.04),
          Colors.transparent,
        ],
        stops: const <double>[0, 0.42, 1],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.46, size.height * 0.06),
          radius: longestSide * 0.52,
        ),
      );
    canvas.drawRect(rect, glowPaint);

    final rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          palette.accent.withValues(alpha: opacity * 0.13),
          Colors.transparent,
        ],
      ).createShader(rect);
    final leftRay = Path()
      ..moveTo(size.width * 0.10, 0)
      ..lineTo(size.width * 0.27, 0)
      ..lineTo(size.width * 0.52, size.height * 0.58)
      ..lineTo(size.width * 0.36, size.height * 0.58)
      ..close();
    final rightRay = Path()
      ..moveTo(size.width * 0.50, 0)
      ..lineTo(size.width * 0.61, 0)
      ..lineTo(size.width * 0.78, size.height * 0.48)
      ..lineTo(size.width * 0.65, size.height * 0.48)
      ..close();
    canvas.drawPath(leftRay, rayPaint);
    canvas.drawPath(rightRay, rayPaint);

    final hazePaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.055);
    for (final entry in const <(double, double, double)>[
      (0.34, 0.64, 0.10),
      (0.63, 0.76, 0.13),
      (0.88, 0.88, 0.16),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * entry.$1),
          width: size.width * entry.$2,
          height: size.height * entry.$3,
        ),
        hazePaint,
      );
    }

    final edgePaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.085);
    const edgeCanopy = <Offset>[
      Offset(-0.03, 0.18),
      Offset(1.03, 0.24),
      Offset(-0.02, 0.52),
      Offset(1.02, 0.58),
      Offset(-0.01, 0.84),
      Offset(1.02, 0.88),
    ];
    for (var index = 0; index < edgeCanopy.length; index++) {
      final point = edgeCanopy[index];
      final radius = size.width * (index.isEven ? 0.18 : 0.15);
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        radius,
        edgePaint,
      );
    }
  }

  void _paintSkyBase(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          palette.accent.withValues(alpha: opacity * 0.16),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.76, size.height * 0.12),
          radius: math.max(size.width, size.height) * 0.42,
        ),
      );
    canvas.drawRect(rect, glowPaint);

    final random = math.Random(spec.seed ^ 0x5A17);
    final starPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.34);
    for (var index = 0; index < 24; index++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * 0.78,
      );
      final radius = 0.8 + random.nextDouble() * 1.5;
      canvas.drawCircle(center, radius, starPaint);
    }

    final cloudBandPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.055);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.38, size.height * 0.54),
        width: size.width * 0.82,
        height: size.height * 0.13,
      ),
      cloudBandPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.68, size.height * 0.82),
        width: size.width * 0.74,
        height: size.height * 0.14,
      ),
      cloudBandPaint,
    );
  }

  void _paintHarborBase(Canvas canvas, Size size) {
    final waterPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var band = 0; band < 7; band++) {
      final y = size.height * (0.22 + band * 0.115);
      final wave = Path()..moveTo(-20, y);
      for (var step = 0; step < 5; step++) {
        final startX = size.width * step / 4;
        final endX = size.width * (step + 1) / 4;
        final controlY = y + (step.isEven ? -7 : 7);
        wave.quadraticBezierTo(
          (startX + endX) / 2,
          controlY,
          endX,
          y,
        );
      }
      canvas.drawPath(wave, waterPaint);
    }

    final horizonPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          palette.accent.withValues(alpha: opacity * 0.10),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.04, size.width, size.height * 0.26),
      horizonPaint,
    );
  }

  void _paintForest(Canvas canvas, double scale, int variantIndex) {
    switch (variantIndex % 4) {
      case 0:
        _paintForestTree(canvas, scale);
      case 1:
        _paintForestRockAndFern(canvas, scale);
      case 2:
        _paintForestMushrooms(canvas, scale);
      case 3:
        _paintForestShrub(canvas, scale);
    }
  }

  void _paintForestTree(Canvas canvas, double scale) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: opacity * 0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 17 * scale),
        width: 29 * scale,
        height: 8 * scale,
      ),
      shadowPaint,
    );

    final trunkPaint = Paint()
      ..color = palette.secondary.withValues(alpha: opacity * 0.92);
    final trunk = Path()
      ..moveTo(-3.4 * scale, 16 * scale)
      ..lineTo(-2.2 * scale, -3 * scale)
      ..lineTo(3.1 * scale, -3 * scale)
      ..lineTo(4.2 * scale, 16 * scale)
      ..close();
    canvas.drawPath(trunk, trunkPaint);

    final crownRect = Rect.fromCircle(
      center: Offset(0, -8 * scale),
      radius: 18 * scale,
    );
    final leafPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        colors: <Color>[
          palette.accent.withValues(alpha: opacity * 0.34),
          palette.primary.withValues(alpha: opacity * 0.94),
          palette.primary.withValues(alpha: opacity * 0.66),
        ],
        stops: const <double>[0, 0.42, 1],
      ).createShader(crownRect);
    canvas.drawCircle(Offset(0, -10 * scale), 15 * scale, leafPaint);
    canvas.drawCircle(Offset(-10 * scale, -2 * scale), 10 * scale, leafPaint);
    canvas.drawCircle(Offset(10 * scale, -1 * scale), 11 * scale, leafPaint);
    canvas.drawCircle(Offset(1 * scale, 2 * scale), 12 * scale, leafPaint);
  }

  void _paintForestRockAndFern(Canvas canvas, double scale) {
    final rockPaint = Paint()
      ..color = palette.secondary.withValues(alpha: opacity * 0.56);
    final rockHighlightPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-5 * scale, 6 * scale),
        width: 18 * scale,
        height: 12 * scale,
      ),
      rockPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(7 * scale, 8 * scale),
        width: 14 * scale,
        height: 9 * scale,
      ),
      rockPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-7 * scale, 3 * scale),
        width: 8 * scale,
        height: 3.5 * scale,
      ),
      rockHighlightPaint,
    );

    final fernPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7 * scale
      ..strokeCap = StrokeCap.round;
    for (final direction in const <double>[-1, 0, 1]) {
      final stem = Path()
        ..moveTo(direction * 3 * scale, 5 * scale)
        ..quadraticBezierTo(
          direction * 8 * scale,
          -3 * scale,
          direction * 12 * scale,
          -11 * scale,
        );
      canvas.drawPath(stem, fernPaint);
    }
  }

  void _paintForestMushrooms(Canvas canvas, double scale) {
    final stemPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.54);
    final capPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.88);
    final spotPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.76);

    for (final mushroom in const <(double, double, double)>[
      (-8, 4, 1),
      (1, 0, 1.18),
      (9, 6, 0.76),
    ]) {
      final x = mushroom.$1 * scale;
      final y = mushroom.$2 * scale;
      final localScale = mushroom.$3 * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y + 6 * localScale),
            width: 3.4 * localScale,
            height: 9 * localScale,
          ),
          Radius.circular(1.4 * localScale),
        ),
        stemPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 13 * localScale,
          height: 7 * localScale,
        ),
        capPaint,
      );
      canvas.drawCircle(
        Offset(x - 2 * localScale, y - 0.7 * localScale),
        1.15 * localScale,
        spotPaint,
      );
    }
  }

  void _paintForestShrub(Canvas canvas, double scale) {
    final leafPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.82);
    final accentPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.48);
    const leaves = <Offset>[
      Offset(-11, 1),
      Offset(-5, -6),
      Offset(2, -8),
      Offset(9, -3),
      Offset(10, 5),
      Offset(1, 7),
      Offset(-7, 8),
    ];
    for (var index = 0; index < leaves.length; index++) {
      final leaf = leaves[index];
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(leaf.dx * scale, leaf.dy * scale),
          width: (index.isEven ? 10 : 8) * scale,
          height: (index.isEven ? 6 : 9) * scale,
        ),
        leafPaint,
      );
    }
    canvas.drawCircle(Offset(1 * scale, -2 * scale), 2.1 * scale, accentPaint);
  }

  void _paintSky(Canvas canvas, double scale, int variantIndex) {
    final cloudPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.70);
    final starPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity);

    if (variantIndex % 3 == 1) {
      final starPath = Path();
      for (var point = 0; point < 10; point++) {
        final radius = point.isEven ? 6.5 * scale : 2.8 * scale;
        final angle = -math.pi / 2 + point * math.pi / 5;
        final target = Offset(math.cos(angle) * radius, math.sin(angle) * radius);
        if (point == 0) {
          starPath.moveTo(target.dx, target.dy);
        } else {
          starPath.lineTo(target.dx, target.dy);
        }
      }
      starPath.close();
      canvas.drawPath(starPath, starPaint);
      return;
    }

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

  void _paintHarbor(Canvas canvas, double scale, int variantIndex) {
    final waterPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;
    final buoyPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.92);

    final wave = Path()
      ..moveTo(-16 * scale, 2 * scale)
      ..quadraticBezierTo(-8 * scale, -5 * scale, 0, 2 * scale)
      ..quadraticBezierTo(8 * scale, 9 * scale, 16 * scale, 2 * scale);
    canvas.drawPath(wave, waterPaint);

    if (variantIndex.isEven) {
      canvas.drawCircle(Offset(0, -8 * scale), 4.2 * scale, buoyPaint);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(0, -3 * scale),
          width: 2.2 * scale,
          height: 8 * scale,
        ),
        buoyPaint,
      );
    } else {
      final rockPaint = Paint()
        ..color = palette.secondary.withValues(alpha: opacity * 0.68);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(5 * scale, 7 * scale),
          width: 18 * scale,
          height: 9 * scale,
        ),
        rockPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WordHuntRouteDecorationPainter oldDelegate) {
    return oldDelegate.spec != spec ||
        oldDelegate.reservedPoints != reservedPoints ||
        oldDelegate.palette != palette ||
        oldDelegate.opacity != opacity;
  }
}
