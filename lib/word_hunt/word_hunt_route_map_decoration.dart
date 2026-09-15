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

/// Ortak sahne painter'ı. Rota kimliği veya rota başına koordinat taşımaz.
/// Tema türü, palette ve seed yalnız görsel skin'i değiştirir; node/path
/// geometrisi üst katmanda aynen kalır.
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
          _paintForestMotif(canvas, mark.scale, index);
        case WordHuntRouteDecorationKind.sky:
          _paintSkyMotif(canvas, mark.scale, index);
        case WordHuntRouteDecorationKind.harbor:
          _paintHarborMotif(canvas, mark.scale, index);
      }

      canvas.restore();
    }
  }

  double _motifRotation(double turns) {
    final centeredTurns = turns - 0.5;
    switch (spec.kind) {
      case WordHuntRouteDecorationKind.forest:
        return centeredTurns * math.pi * 0.10;
      case WordHuntRouteDecorationKind.sky:
        return centeredTurns * math.pi * 0.04;
      case WordHuntRouteDecorationKind.harbor:
        return centeredTurns * math.pi * 0.08;
    }
  }

  void _paintSceneBase(Canvas canvas, Size size) {
    switch (spec.kind) {
      case WordHuntRouteDecorationKind.forest:
        _paintForestScene(canvas, size);
      case WordHuntRouteDecorationKind.sky:
        _paintSkyScene(canvas, size);
      case WordHuntRouteDecorationKind.harbor:
        _paintHarborScene(canvas, size);
    }
  }

  void _paintForestScene(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xFFBFD6C2).withValues(alpha: opacity * 0.72),
          const Color(0xFF6F9B72).withValues(alpha: opacity * 0.42),
          palette.primary.withValues(alpha: opacity * 0.12),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.22, 0.52, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    _paintSunbeams(canvas, size);
    _paintDistantForest(canvas, size);
    _paintCliffsAndWaterfalls(canvas, size);
    _paintForestGround(canvas, size);
    _paintScenicTrail(canvas, size);
    _paintBridge(canvas, size);
    _paintNodePedestals(canvas, size);
    _paintEdgeTrees(canvas, size);
    _paintFireflies(canvas, size);
  }

  void _paintSunbeams(Canvas canvas, Size size) {
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xFFFFF3BC).withValues(alpha: opacity * 0.30),
          const Color(0xFFFFF3BC).withValues(alpha: opacity * 0.05),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    final beam1 = Path()
      ..moveTo(size.width * 0.12, 0)
      ..lineTo(size.width * 0.27, 0)
      ..lineTo(size.width * 0.56, size.height * 0.54)
      ..lineTo(size.width * 0.38, size.height * 0.54)
      ..close();
    final beam2 = Path()
      ..moveTo(size.width * 0.43, 0)
      ..lineTo(size.width * 0.52, 0)
      ..lineTo(size.width * 0.70, size.height * 0.42)
      ..lineTo(size.width * 0.58, size.height * 0.42)
      ..close();
    canvas.drawPath(beam1, beamPaint);
    canvas.drawPath(beam2, beamPaint);
  }

  void _paintDistantForest(Canvas canvas, Size size) {
    final hazePaint = Paint()
      ..color = const Color(0xFF335B45).withValues(alpha: opacity * 0.42);
    final ridgePaint = Paint()
      ..color = const Color(0xFF1B3D2A).withValues(alpha: opacity * 0.60);

    final hazeRidge = Path()
      ..moveTo(0, size.height * 0.25)
      ..lineTo(size.width * 0.12, size.height * 0.19)
      ..lineTo(size.width * 0.26, size.height * 0.23)
      ..lineTo(size.width * 0.40, size.height * 0.15)
      ..lineTo(size.width * 0.58, size.height * 0.22)
      ..lineTo(size.width * 0.74, size.height * 0.14)
      ..lineTo(size.width, size.height * 0.22)
      ..lineTo(size.width, size.height * 0.39)
      ..lineTo(0, size.height * 0.39)
      ..close();
    canvas.drawPath(hazeRidge, hazePaint);

    final ridge = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.18, size.height * 0.27)
      ..lineTo(size.width * 0.34, size.height * 0.32)
      ..lineTo(size.width * 0.52, size.height * 0.23)
      ..lineTo(size.width * 0.68, size.height * 0.31)
      ..lineTo(size.width * 0.84, size.height * 0.22)
      ..lineTo(size.width, size.height * 0.30)
      ..lineTo(size.width, size.height * 0.46)
      ..lineTo(0, size.height * 0.46)
      ..close();
    canvas.drawPath(ridge, ridgePaint);

    final pinePaint = Paint()
      ..color = const Color(0xFF153522).withValues(alpha: opacity * 0.56);
    for (var i = 0; i < 22; i++) {
      final x = size.width * (i / 21);
      final height = size.height * (0.055 + (i % 5) * 0.008);
      final baseY = size.height * (0.33 + (i % 3) * 0.018);
      _paintPine(canvas, Offset(x, baseY), height, pinePaint);
    }
  }

  void _paintPine(Canvas canvas, Offset base, double height, Paint paint) {
    final width = height * 0.44;
    final path = Path()
      ..moveTo(base.dx, base.dy - height)
      ..lineTo(base.dx - width * 0.52, base.dy - height * 0.52)
      ..lineTo(base.dx - width * 0.20, base.dy - height * 0.52)
      ..lineTo(base.dx - width * 0.70, base.dy - height * 0.22)
      ..lineTo(base.dx - width * 0.18, base.dy - height * 0.22)
      ..lineTo(base.dx - width, base.dy)
      ..lineTo(base.dx + width, base.dy)
      ..lineTo(base.dx + width * 0.18, base.dy - height * 0.22)
      ..lineTo(base.dx + width * 0.70, base.dy - height * 0.22)
      ..lineTo(base.dx + width * 0.20, base.dy - height * 0.52)
      ..lineTo(base.dx + width * 0.52, base.dy - height * 0.52)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintCliffsAndWaterfalls(Canvas canvas, Size size) {
    final rockPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          const Color(0xFF77806D).withValues(alpha: opacity * 0.66),
          const Color(0xFF38473B).withValues(alpha: opacity * 0.82),
          const Color(0xFF1F2F26).withValues(alpha: opacity * 0.90),
        ],
      ).createShader(Offset.zero & size);
    final mossPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.64);

    final leftCliff = Path()
      ..moveTo(0, size.height * 0.38)
      ..lineTo(size.width * 0.18, size.height * 0.34)
      ..lineTo(size.width * 0.28, size.height * 0.43)
      ..lineTo(size.width * 0.25, size.height * 0.58)
      ..lineTo(size.width * 0.15, size.height * 0.70)
      ..lineTo(0, size.height * 0.73)
      ..close();
    canvas.drawPath(leftCliff, rockPaint);

    final rightCliff = Path()
      ..moveTo(size.width, size.height * 0.30)
      ..lineTo(size.width * 0.82, size.height * 0.34)
      ..lineTo(size.width * 0.74, size.height * 0.47)
      ..lineTo(size.width * 0.78, size.height * 0.60)
      ..lineTo(size.width * 0.90, size.height * 0.69)
      ..lineTo(size.width, size.height * 0.66)
      ..close();
    canvas.drawPath(rightCliff, rockPaint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.16, size.height * 0.40),
        width: size.width * 0.23,
        height: size.height * 0.055,
      ),
      mossPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.84, size.height * 0.36),
        width: size.width * 0.25,
        height: size.height * 0.055,
      ),
      mossPaint,
    );

    _paintWaterfall(
      canvas,
      size,
      x: 0.16,
      top: 0.40,
      bottom: 0.58,
      width: 0.11,
    );
    _paintWaterfall(
      canvas,
      size,
      x: 0.85,
      top: 0.37,
      bottom: 0.53,
      width: 0.09,
    );
    _paintWaterfall(
      canvas,
      size,
      x: 0.21,
      top: 0.61,
      bottom: 0.76,
      width: 0.08,
    );
  }

  void _paintWaterfall(
    Canvas canvas,
    Size size, {
    required double x,
    required double top,
    required double bottom,
    required double width,
  }) {
    final left = size.width * (x - width / 2);
    final topY = size.height * top;
    final bottomY = size.height * bottom;
    final waterRect = Rect.fromLTWH(
      left,
      topY,
      size.width * width,
      bottomY - topY,
    );
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xFFDBF7FF).withValues(alpha: opacity * 0.72),
          const Color(0xFF6ED4E8).withValues(alpha: opacity * 0.78),
          const Color(0xFF2A91B1).withValues(alpha: opacity * 0.66),
        ],
      ).createShader(waterRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(waterRect, Radius.circular(size.width * 0.035)),
      waterPaint,
    );

    final streakPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.44)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i <= 3; i++) {
      final sx = left + size.width * width * (i / 4);
      canvas.drawLine(
        Offset(sx, topY + 4),
        Offset(sx - 2, bottomY - 6),
        streakPaint,
      );
    }

    final poolPaint = Paint()
      ..color = const Color(0xFF4CB8D1).withValues(alpha: opacity * 0.52);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * x, bottomY),
        width: size.width * width * 1.9,
        height: size.height * 0.026,
      ),
      poolPaint,
    );
  }

  void _paintForestGround(Canvas canvas, Size size) {
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          const Color(0xFF315E36).withValues(alpha: opacity * 0.28),
          const Color(0xFF183921).withValues(alpha: opacity * 0.66),
          const Color(0xFF0B2114).withValues(alpha: opacity * 0.90),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.38, size.width, size.height * 0.62),
      groundPaint,
    );

    final grassPaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.48)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final random = math.Random(spec.seed ^ 0xA11CE);
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.42 + random.nextDouble() * 0.58);
      final h = 3 + random.nextDouble() * 7;
      canvas.drawLine(Offset(x, y), Offset(x - 2, y - h), grassPaint);
      canvas.drawLine(Offset(x + 1, y), Offset(x + 3, y - h * 0.8), grassPaint);
    }
  }

  void _paintScenicTrail(Canvas canvas, Size size) {
    if (reservedPoints.length < 2) return;
    final points = reservedPoints
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList(growable: false);
    final trail = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final delta = end - start;
      final length = delta.distance;
      if (length == 0) continue;
      final midpoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );
      final normal = Offset(-delta.dy / length, delta.dx / length);
      final direction = i.isEven ? 1.0 : -1.0;
      final control = midpoint + normal * (length * 0.08 * direction);
      trail.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    }

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: opacity * 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final earthPaint = Paint()
      ..color = const Color(0xFFB38750).withValues(alpha: opacity * 0.52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final warmPaint = Paint()
      ..color = const Color(0xFFE2BD77).withValues(alpha: opacity * 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(trail, shadowPaint);
    canvas.drawPath(trail, earthPaint);
    canvas.drawPath(trail, warmPaint);
  }

  void _paintBridge(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.48, size.height * 0.56);
    final width = size.width * 0.25;
    final height = size.height * 0.035;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: opacity * 0.34);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, height * 0.80),
        width: width * 1.08,
        height: height * 0.72,
      ),
      shadowPaint,
    );

    final plankPaint = Paint()
      ..color = palette.secondary.withValues(alpha: opacity * 0.92);
    final plankLightPaint = Paint()
      ..color = const Color(0xFFC38A4B).withValues(alpha: opacity * 0.74);
    for (var i = 0; i < 9; i++) {
      final x = center.dx - width / 2 + i * width / 8;
      final y = center.dy + math.sin(i / 8 * math.pi) * 4;
      final plank = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y),
          width: width / 8 + 4,
          height: height,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(plank, i.isEven ? plankPaint : plankLightPaint);
    }

    final ropePaint = Paint()
      ..color = const Color(0xFF6E4C2F).withValues(alpha: opacity * 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final railY = center.dy - height * 0.95;
    canvas.drawLine(
      Offset(center.dx - width / 2, railY),
      Offset(center.dx + width / 2, railY),
      ropePaint,
    );
    for (final dx in <double>[-0.5, -0.25, 0.0, 0.25, 0.5]) {
      final x = center.dx + width * dx;
      canvas.drawLine(
        Offset(x, center.dy - 3),
        Offset(x, railY),
        ropePaint,
      );
    }
  }

  void _paintNodePedestals(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: opacity * 0.42);
    final barkPaint = Paint()
      ..color = palette.secondary.withValues(alpha: opacity * 0.88);
    final woodPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.32, -0.35),
        colors: <Color>[
          const Color(0xFFD8A45F).withValues(alpha: opacity * 0.82),
          const Color(0xFFA86C38).withValues(alpha: opacity * 0.90),
          const Color(0xFF694124).withValues(alpha: opacity * 0.94),
        ],
      ).createShader(Offset.zero & size);
    final ringPaint = Paint()
      ..color = const Color(0xFFF2C983).withValues(alpha: opacity * 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (final point in reservedPoints) {
      final center = Offset(point.dx * size.width, point.dy * size.height);
      final stumpCenter = center + const Offset(0, 7);
      canvas.drawOval(
        Rect.fromCenter(
          center: stumpCenter + const Offset(0, 8),
          width: 72,
          height: 24,
        ),
        shadowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: stumpCenter + const Offset(0, 5),
            width: 66,
            height: 38,
          ),
          const Radius.circular(15),
        ),
        barkPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 68, height: 54),
        woodPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 55, height: 42),
        ringPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: center, width: 42, height: 31),
        -0.7,
        3.4,
        false,
        ringPaint,
      );
    }
  }

  void _paintEdgeTrees(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          const Color(0xFF7D5635).withValues(alpha: opacity * 0.90),
          const Color(0xFF3E291C).withValues(alpha: opacity * 0.96),
          const Color(0xFF241A12).withValues(alpha: opacity * 0.98),
        ],
      ).createShader(Offset.zero & size);
    final highlightPaint = Paint()
      ..color = const Color(0xFFC08B52).withValues(alpha: opacity * 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final leftTrunk = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.07, size.height)
      ..cubicTo(
        size.width * 0.10,
        size.height * 0.76,
        size.width * 0.02,
        size.height * 0.46,
        size.width * 0.10,
        0,
      )
      ..lineTo(0, 0)
      ..close();
    final rightTrunk = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width * 0.93, size.height)
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.74,
        size.width * 0.98,
        size.height * 0.40,
        size.width * 0.91,
        0,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(leftTrunk, trunkPaint);
    canvas.drawPath(rightTrunk, trunkPaint);

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.055, size.height)
        ..cubicTo(
          size.width * 0.08,
          size.height * 0.73,
          size.width * 0.025,
          size.height * 0.42,
          size.width * 0.075,
          0,
        ),
      highlightPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.955, size.height)
        ..cubicTo(
          size.width * 0.92,
          size.height * 0.72,
          size.width * 0.975,
          size.height * 0.43,
          size.width * 0.94,
          0,
        ),
      highlightPaint,
    );

    final leafDark = Paint()
      ..color = const Color(0xFF123B22).withValues(alpha: opacity * 0.96);
    final leafMid = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.84);
    final leafLight = Paint()
      ..color = const Color(0xFF78A94F).withValues(alpha: opacity * 0.58);
    final random = math.Random(spec.seed ^ 0xC0FFEE);
    for (var i = 0; i < 34; i++) {
      final side = i.isEven ? 0.0 : 1.0;
      final x = side == 0
          ? size.width * (0.01 + random.nextDouble() * 0.12)
          : size.width * (0.87 + random.nextDouble() * 0.12);
      final y = random.nextDouble() * size.height;
      final r = 8 + random.nextDouble() * 15;
      final paint = i % 3 == 0
          ? leafLight
          : i % 3 == 1
          ? leafMid
          : leafDark;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: r * 1.35,
          height: r,
        ),
        paint,
      );
    }
  }

  void _paintFireflies(Canvas canvas, Size size) {
    final random = math.Random(spec.seed ^ 0xF17EF1E5);
    for (var i = 0; i < 24; i++) {
      final center = Offset(
        size.width * (0.10 + random.nextDouble() * 0.80),
        size.height * (0.18 + random.nextDouble() * 0.74),
      );
      final radius = 1.4 + random.nextDouble() * 1.5;
      final glowRect = Rect.fromCircle(center: center, radius: radius * 5);
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            const Color(0xFFFFEB73).withValues(alpha: opacity * 0.82),
            const Color(0xFFFFD43B).withValues(alpha: opacity * 0.24),
            Colors.transparent,
          ],
        ).createShader(glowRect);
      canvas.drawCircle(center, radius * 5, glowPaint);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFFFFF6B0).withValues(alpha: opacity * 0.96),
      );
    }
  }

  void _paintSkyScene(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          palette.secondary.withValues(alpha: opacity * 0.42),
          palette.primary.withValues(alpha: opacity * 0.18),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    final random = math.Random(spec.seed ^ 0x5A17);
    for (var i = 0; i < 32; i++) {
      final c = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * 0.78,
      );
      final r = 0.8 + random.nextDouble() * 1.7;
      canvas.drawCircle(
        c,
        r,
        Paint()..color = palette.accent.withValues(alpha: opacity * 0.46),
      );
    }

    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.08);
    for (final cloud in const <(double, double, double)>[
      (0.26, 0.32, 0.26),
      (0.72, 0.52, 0.22),
      (0.38, 0.78, 0.30),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * cloud.$1, size.height * cloud.$2),
          width: size.width * cloud.$3,
          height: size.height * 0.045,
        ),
        cloudPaint,
      );
    }
  }

  void _paintHarborScene(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final horizonPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          palette.accent.withValues(alpha: opacity * 0.12),
          palette.primary.withValues(alpha: opacity * 0.08),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, horizonPaint);

    final wavePaint = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.17)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var band = 0; band < 8; band++) {
      final y = size.height * (0.18 + band * 0.105);
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
      canvas.drawPath(wave, wavePaint);
    }
  }

  void _paintForestMotif(Canvas canvas, double scale, int variantIndex) {
    switch (variantIndex % 6) {
      case 0:
        _paintForestTree(canvas, scale);
      case 1:
        _paintRockAndFern(canvas, scale);
      case 2:
        _paintMushrooms(canvas, scale);
      case 3:
        _paintFlowers(canvas, scale);
      case 4:
        _paintShrub(canvas, scale);
      case 5:
        _paintTinyPine(canvas, scale);
    }
  }

  void _paintForestTree(Canvas canvas, double scale) {
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: opacity * 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 17 * scale),
        width: 34 * scale,
        height: 9 * scale,
      ),
      shadow,
    );
    final trunk = Paint()
      ..color = palette.secondary.withValues(alpha: opacity * 0.92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, 6 * scale),
          width: 7 * scale,
          height: 26 * scale,
        ),
        Radius.circular(3 * scale),
      ),
      trunk,
    );

    final crownRect = Rect.fromCircle(
      center: Offset(0, -9 * scale),
      radius: 20 * scale,
    );
    final crown = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.42),
        colors: <Color>[
          const Color(0xFF9BC35D).withValues(alpha: opacity * 0.72),
          palette.primary.withValues(alpha: opacity * 0.96),
          const Color(0xFF163E22).withValues(alpha: opacity * 0.96),
        ],
      ).createShader(crownRect);
    for (final c in <Offset>[
      Offset(0, -12 * scale),
      Offset(-10 * scale, -4 * scale),
      Offset(10 * scale, -3 * scale),
      Offset(0, 3 * scale),
    ]) {
      canvas.drawCircle(c, 12 * scale, crown);
    }
  }

  void _paintRockAndFern(Canvas canvas, double scale) {
    final rock = Paint()
      ..color = const Color(0xFF6B7467).withValues(alpha: opacity * 0.78);
    final rockLight = Paint()
      ..color = const Color(0xFFAAB49E).withValues(alpha: opacity * 0.34);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-5 * scale, 5 * scale),
        width: 25 * scale,
        height: 17 * scale,
      ),
      rock,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(-5 * scale, 4 * scale),
        width: 19 * scale,
        height: 12 * scale,
      ),
      math.pi * 1.05,
      math.pi * 0.75,
      false,
      rockLight..style = PaintingStyle.stroke..strokeWidth = 1.3 * scale,
    );
    final fern = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * scale
      ..strokeCap = StrokeCap.round;
    for (var i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(4 * scale, 9 * scale),
        Offset((8 + i * 3) * scale, (-8 + i.abs()) * scale),
        fern,
      );
    }
  }

  void _paintMushrooms(Canvas canvas, double scale) {
    final stem = Paint()
      ..color = const Color(0xFFFFE9C2).withValues(alpha: opacity * 0.84);
    final cap = Paint()
      ..color = const Color(0xFFD84C37).withValues(alpha: opacity * 0.92);
    final spot = Paint()
      ..color = const Color(0xFFFFF4D6).withValues(alpha: opacity * 0.90);
    for (final x in <double>[-7, 6]) {
      final h = x < 0 ? 15.0 : 11.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (x - 2) * scale,
            -1 * scale,
            4 * scale,
            h * scale,
          ),
          Radius.circular(2 * scale),
        ),
        stem,
      );
      final capRect = Rect.fromCenter(
        center: Offset(x * scale, -1 * scale),
        width: (x < 0 ? 18 : 14) * scale,
        height: (x < 0 ? 10 : 8) * scale,
      );
      canvas.drawOval(capRect, cap);
      canvas.drawCircle(
        Offset((x - 2) * scale, -2 * scale),
        1.2 * scale,
        spot,
      );
      canvas.drawCircle(
        Offset((x + 3) * scale, 0),
        1.0 * scale,
        spot,
      );
    }
  }

  void _paintFlowers(Canvas canvas, double scale) {
    final stem = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.88)
      ..strokeWidth = 1.3 * scale
      ..strokeCap = StrokeCap.round;
    final petal = Paint()
      ..color = const Color(0xFFDFA8FF).withValues(alpha: opacity * 0.86);
    final center = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.92);
    for (var i = -2; i <= 2; i++) {
      final x = i * 5.0 * scale;
      final top = (-7 - (i.abs() % 2) * 4) * scale;
      canvas.drawLine(Offset(x, 10 * scale), Offset(x, top), stem);
      for (var p = 0; p < 5; p++) {
        final angle = p * math.pi * 2 / 5;
        canvas.drawCircle(
          Offset(
            x + math.cos(angle) * 3 * scale,
            top + math.sin(angle) * 3 * scale,
          ),
          2.2 * scale,
          petal,
        );
      }
      canvas.drawCircle(Offset(x, top), 1.8 * scale, center);
    }
  }

  void _paintShrub(Canvas canvas, double scale) {
    final dark = Paint()
      ..color = const Color(0xFF174626).withValues(alpha: opacity * 0.92);
    final light = Paint()
      ..color = palette.primary.withValues(alpha: opacity * 0.86);
    for (var i = 0; i < 7; i++) {
      final angle = i * math.pi * 2 / 7;
      final c = Offset(
        math.cos(angle) * 8 * scale,
        math.sin(angle) * 5 * scale,
      );
      canvas.drawCircle(c, 7 * scale, i.isEven ? light : dark);
    }
  }

  void _paintTinyPine(Canvas canvas, double scale) {
    final paint = Paint()
      ..color = const Color(0xFF1B5A31).withValues(alpha: opacity * 0.94);
    _paintPine(canvas, Offset(0, 15 * scale), 32 * scale, paint);
  }

  void _paintSkyMotif(Canvas canvas, double scale, int variantIndex) {
    if (variantIndex.isEven) {
      final cloud = Paint()
        ..color = palette.primary.withValues(alpha: opacity * 0.48);
      canvas.drawCircle(Offset(-7 * scale, 0), 7 * scale, cloud);
      canvas.drawCircle(Offset(0, -3 * scale), 9 * scale, cloud);
      canvas.drawCircle(Offset(8 * scale, 1 * scale), 6 * scale, cloud);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, 3 * scale),
            width: 28 * scale,
            height: 10 * scale,
          ),
          Radius.circular(5 * scale),
        ),
        cloud,
      );
    } else {
      final star = Paint()
        ..color = palette.accent.withValues(alpha: opacity * 0.76);
      _paintStar(canvas, Offset.zero, 11 * scale, 5 * scale, star);
    }
  }

  void _paintHarborMotif(Canvas canvas, double scale, int variantIndex) {
    if (variantIndex.isEven) {
      final post = Paint()
        ..color = palette.secondary.withValues(alpha: opacity * 0.82);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 6 * scale,
            height: 25 * scale,
          ),
          Radius.circular(2 * scale),
        ),
        post,
      );
      final lamp = Paint()
        ..color = palette.accent.withValues(alpha: opacity * 0.80);
      canvas.drawCircle(Offset(0, -13 * scale), 5 * scale, lamp);
    } else {
      final water = Paint()
        ..color = palette.primary.withValues(alpha: opacity * 0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale
        ..strokeCap = StrokeCap.round;
      for (var i = -1; i <= 1; i++) {
        final y = i * 5.0 * scale;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(0, y),
            width: 24 * scale,
            height: 8 * scale,
          ),
          0,
          math.pi,
          false,
          water,
        );
      }
    }
  }

  void _paintStar(
    Canvas canvas,
    Offset center,
    double outer,
    double inner,
    Paint paint,
  ) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WordHuntRouteDecorationPainter oldDelegate) {
    return oldDelegate.spec != spec ||
        oldDelegate.reservedPoints != reservedPoints ||
        oldDelegate.palette != palette ||
        oldDelegate.opacity != opacity;
  }
}
