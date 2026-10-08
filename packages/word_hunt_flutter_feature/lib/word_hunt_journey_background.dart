import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'word_hunt_journey_theme.dart';

/// A bounded chunk has at most two decorations per row, plus sparse landmarks.
/// Seeds use ordinal identity, never progression, viewport or wall-clock time.
class JourneyDecor {
  const JourneyDecor(this.ordinal, this.side, this.position, this.radius);
  final int ordinal, side;
  final Offset position;
  final double radius;
  static List<JourneyDecor> forChunk(
    int first,
    int rows,
    double width,
    double pitch,
  ) => [
    for (var i = 0; i < rows; i++)
      for (var side = 0; side < 2; side++)
        _seeded(first + i, side, i, width, pitch),
  ];
  static JourneyDecor _seeded(
    int ordinal,
    int side,
    int row,
    double width,
    double pitch,
  ) {
    final seed = ((ordinal * 1103515245 + side * 12345) & 0x7fffffff);
    return JourneyDecor(
      ordinal,
      side,
      Offset(
        side == 0
            ? width * (.025 + seed % 9 / 100)
            : width * (.88 + seed % 9 / 100),
        (row + .15 + (seed % 60) / 100) * pitch,
      ),
      7 + seed % 12.0,
    );
  }
}

class JourneyChunkBackground extends StatelessWidget {
  const JourneyChunkBackground({
    super.key,
    required this.schedule,
    required this.firstOrdinal,
    required this.rows,
    required this.rowPitch,
  });
  final JourneyThemeSchedule schedule;
  final int firstOrdinal, rows;
  final double rowPitch;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: CustomPaint(
        painter: JourneyBackgroundPainter(
          schedule: schedule,
          firstOrdinal: firstOrdinal,
          rows: rows,
          rowPitch: rowPitch,
        ),
      ),
    ),
  );
}

class JourneyBackgroundPainter extends CustomPainter {
  const JourneyBackgroundPainter({
    required this.schedule,
    required this.firstOrdinal,
    required this.rows,
    required this.rowPitch,
  });
  final JourneyThemeSchedule schedule;
  final int firstOrdinal, rows;
  final double rowPitch;
  static const maxDecorPerRow = 2;
  // Geometry guarantees a minimum 34px outer gap at supported phone widths.
  // Art is clipped inside 28px edge strips; numbers/path/hitboxes stay clear.
  static const edgeArtWidth = 28.0;
  Color _middle(JourneyThemeTransition t) => Color.lerp(t.top, t.bottom, .5)!;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var row = 0; row < rows; row++) {
      final ordinal = firstOrdinal + row;
      final frame = schedule.transitionForOrdinal(ordinal);
      final prior = schedule.transitionForOrdinal(math.max(1, ordinal - 1));
      final rect = Rect.fromLTWH(0, row * rowPitch, size.width, rowPitch);
      // Adjacent row/chunk endpoints share exactly the same color.
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_middle(prior), _middle(frame)],
          ).createShader(rect),
      );
      // Do not repeat bright row-sized disks under nodes: a quiet continuous
      // center is shared by all biomes, with environment motifs at the edges.
      final landmark = schedule.landmarkForOrdinal(ordinal);
      if (landmark != null) {
        final x = ordinal.isEven ? size.width - 14 : 14.0;
        canvas.save();
        canvas.clipRect(
          Rect.fromLTWH(
            ordinal.isEven ? size.width - edgeArtWidth : 0,
            rect.top,
            edgeArtWidth,
            rowPitch,
          ),
        );
        if (frame.to.scenery == JourneyScenery.coast) {
          paintCoastalLandmark(
            canvas,
            Offset(x, rect.center.dy),
            landmark,
            frame.to.accent,
          );
        } else {
          paintLandmark(
            canvas,
            Offset(x, rect.center.dy),
            landmark,
            frame.to.accent,
          );
        }
        canvas.restore();
      }
    }
    for (final decor in JourneyDecor.forChunk(
      firstOrdinal,
      rows,
      size.width,
      rowPitch,
    )) {
      final frame = schedule.transitionForOrdinal(decor.ordinal);
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(
          decor.side == 0 ? 0 : size.width - edgeArtWidth,
          0,
          edgeArtWidth,
          size.height,
        ),
      );
      // Cross-fade small vector motifs only. Never decode two large images.
      paintMotif(
        canvas,
        decor.position,
        decor.radius,
        frame.from.scenery,
        frame.from.accent.withValues(
          alpha: .26 * (1 - frame.mix) * frame.decorDensity,
        ),
      );
      paintMotif(
        canvas,
        decor.position,
        decor.radius,
        frame.to.scenery,
        frame.to.accent.withValues(alpha: .26 * frame.mix * frame.decorDensity),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant JourneyBackgroundPainter old) =>
      old.schedule != schedule ||
      old.firstOrdinal != firstOrdinal ||
      old.rows != rows ||
      old.rowPitch != rowPitch;
}

/// Replaceable vector foundation, not final painted/raster artwork.
void paintCoastalLandmark(
  Canvas canvas,
  Offset center,
  JourneyLandmarkKind kind,
  Color accent,
) {
  final tall = kind != JourneyLandmarkKind.minor;
  final height = switch (kind) {
    JourneyLandmarkKind.minor => 24.0,
    JourneyLandmarkKind.major => 54.0,
    JourneyLandmarkKind.prestige => 78.0,
  };
  final stone = Paint()..color = const Color(0xFF8A9BA5);
  final tower =
      Path()
        ..moveTo(center.dx - 9, center.dy + 28)
        ..lineTo(center.dx - 5, center.dy + 28 - height)
        ..lineTo(center.dx + 5, center.dy + 28 - height)
        ..lineTo(center.dx + 9, center.dy + 28)
        ..close();
  canvas.drawPath(tower, stone);
  canvas.drawRect(
    Rect.fromCenter(
      center: center + Offset(0, 24 - height),
      width: 16,
      height: 9,
    ),
    Paint()..color = accent,
  );
  if (tall) {
    canvas.drawCircle(
      center + Offset(0, 24 - height),
      13,
      Paint()..color = accent.withValues(alpha: .18),
    );
  }
  canvas.drawOval(
    Rect.fromCenter(
      center: center + const Offset(0, 31),
      width: 27,
      height: 10,
    ),
    Paint()..color = const Color(0xFF263843),
  );
}

void paintMotif(
  Canvas canvas,
  Offset center,
  double r,
  JourneyScenery scenery,
  Color color,
) {
  final paint = Paint()..color = color;
  switch (scenery) {
    case JourneyScenery.coast:
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (var i = 0; i < 3; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: center + Offset(0, i * 5), radius: r),
          0,
          math.pi,
          false,
          paint,
        );
      }
    case JourneyScenery.forest:
      final path =
          Path()
            ..moveTo(center.dx, center.dy - r)
            ..lineTo(center.dx - r, center.dy + r)
            ..lineTo(center.dx + r, center.dy + r)
            ..close();
      canvas.drawPath(path, paint);
      canvas.drawRect(
        Rect.fromCenter(center: center + Offset(0, r), width: 3, height: r),
        paint,
      );
    case JourneyScenery.sky:
      canvas.drawOval(
        Rect.fromCenter(center: center, width: r * 3, height: r),
        paint,
      );
      canvas.drawCircle(center - Offset(r * .3, r * .4), r * .7, paint);
    case JourneyScenery.night:
      final path =
          Path()
            ..moveTo(center.dx, center.dy - r)
            ..lineTo(center.dx + r * .35, center.dy)
            ..lineTo(center.dx, center.dy + r)
            ..lineTo(center.dx - r * .35, center.dy)
            ..close();
      canvas.drawPath(path, paint);
  }
}

void paintLandmark(
  Canvas canvas,
  Offset center,
  JourneyLandmarkKind kind,
  Color color,
) {
  final radius = switch (kind) {
    JourneyLandmarkKind.minor => 16.0,
    JourneyLandmarkKind.major => 22.0,
    JourneyLandmarkKind.prestige => 28.0,
  };
  canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF14202F));
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
  final path =
      Path()
        ..moveTo(center.dx - 7, center.dy + 9)
        ..lineTo(center.dx, center.dy - 11)
        ..lineTo(center.dx + 7, center.dy + 9)
        ..close();
  canvas.drawPath(path, Paint()..color = color);
  if (kind == JourneyLandmarkKind.prestige) {
    canvas.drawCircle(
      center,
      radius + 4,
      Paint()
        ..color = color.withValues(alpha: .5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
