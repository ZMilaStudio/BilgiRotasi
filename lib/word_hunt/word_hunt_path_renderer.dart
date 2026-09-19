import 'dart:math' as math;

import 'package:flutter/material.dart';

enum WordHuntPathVisualFamily {
  ancientWaymarks,
  engineeredSegmented,
  ceremonialAlignment,
}

enum WordHuntPathJointStyle { wornStud, copperPlate, alignmentMarker }

enum WordHuntPathMaterial {
  weatheredStone,
  carvedStoneCopper,
  ceremonialStoneGold,
}

enum WordHuntPathApproach { normal, challenge, finalNode }

@immutable
class WordHuntPathVisualSpec {
  const WordHuntPathVisualSpec({
    required this.id,
    required this.family,
    required this.jointStyle,
    required this.material,
    required this.activeColor,
    required this.lockedColor,
    required this.underlayColor,
    required this.thickness,
    required this.segmentLength,
    required this.gap,
    this.jointRadius = 2.2,
    this.challengeApproachScale = 1,
    this.finalApproachScale = 1,
  }) : assert(thickness > 0),
       assert(segmentLength > 0),
       assert(gap >= 0),
       assert(jointRadius > 0),
       assert(challengeApproachScale > 0),
       assert(finalApproachScale > 0);

  final String id;
  final WordHuntPathVisualFamily family;
  final WordHuntPathJointStyle jointStyle;
  final WordHuntPathMaterial material;
  final Color activeColor;
  final Color lockedColor;
  final Color underlayColor;
  final double thickness;
  final double segmentLength;
  final double gap;
  final double jointRadius;
  final double challengeApproachScale;
  final double finalApproachScale;

  double scaleForApproach(WordHuntPathApproach approach) => switch (approach) {
    WordHuntPathApproach.normal => 1,
    WordHuntPathApproach.challenge => challengeApproachScale,
    WordHuntPathApproach.finalNode => finalApproachScale,
  };

  static const WordHuntPathVisualSpec ancientWaymarks =
      WordHuntPathVisualSpec(
        id: 'ancient-waymarks',
        family: WordHuntPathVisualFamily.ancientWaymarks,
        jointStyle: WordHuntPathJointStyle.wornStud,
        material: WordHuntPathMaterial.weatheredStone,
        activeColor: Color(0xFFC8A46D),
        lockedColor: Color(0xFF746755),
        underlayColor: Color(0xAA241A13),
        thickness: 3.2,
        segmentLength: 10,
        gap: 8,
        jointRadius: 2.4,
      );

  static const WordHuntPathVisualSpec engineeredSegmented =
      WordHuntPathVisualSpec(
        id: 'engineered-segmented',
        family: WordHuntPathVisualFamily.engineeredSegmented,
        jointStyle: WordHuntPathJointStyle.copperPlate,
        material: WordHuntPathMaterial.carvedStoneCopper,
        activeColor: Color(0xFFA76A3C),
        lockedColor: Color(0xFF665A50),
        underlayColor: Color(0xB0141110),
        thickness: 3.0,
        segmentLength: 15,
        gap: 6,
        jointRadius: 2.6,
        challengeApproachScale: 1.04,
        finalApproachScale: 1.06,
      );

  static const WordHuntPathVisualSpec ceremonialAlignment =
      WordHuntPathVisualSpec(
        id: 'ceremonial-alignment',
        family: WordHuntPathVisualFamily.ceremonialAlignment,
        jointStyle: WordHuntPathJointStyle.alignmentMarker,
        material: WordHuntPathMaterial.ceremonialStoneGold,
        activeColor: Color(0xFFE2BB69),
        lockedColor: Color(0xFF796F59),
        underlayColor: Color(0xAA14172A),
        thickness: 2.8,
        segmentLength: 18,
        gap: 7,
        jointRadius: 2.2,
        challengeApproachScale: 1.03,
        finalApproachScale: 1.05,
      );
}

/// A single logical edge prepared by the route-map geometry authority.
///
/// This type deliberately has no level numbers or topology table. Callers build
/// segments from their own canonical graph and pass only drawable geometry.
@immutable
class WordHuntPathSegment {
  const WordHuntPathSegment({
    required this.start,
    required this.end,
    required this.active,
    this.approach = WordHuntPathApproach.normal,
  });

  final Offset start;
  final Offset end;
  final bool active;
  final WordHuntPathApproach approach;
}

class WordHuntPathPainter extends CustomPainter {
  const WordHuntPathPainter({
    required this.segments,
    required this.spec,
  });

  final List<WordHuntPathSegment> segments;
  final WordHuntPathVisualSpec spec;

  @override
  void paint(Canvas canvas, Size size) {
    for (final segment in segments) {
      final color = segment.active ? spec.activeColor : spec.lockedColor;
      _paintSegment(canvas, segment, color);
    }
  }

  void _paintSegment(
    Canvas canvas,
    WordHuntPathSegment segment,
    Color color,
  ) {
    final start = segment.start;
    final end = segment.end;
    final delta = end - start;
    final distance = delta.distance;
    if (distance <= 0) return;
    final direction = delta / distance;
    final width = spec.thickness * spec.scaleForApproach(segment.approach);

    switch (spec.family) {
      case WordHuntPathVisualFamily.ancientWaymarks:
        _paintDashed(
          canvas,
          start,
          end,
          color,
          roundCaps: true,
          width: width,
        );
        _paintJoint(canvas, start, color);
        _paintJoint(canvas, end, color);
        break;
      case WordHuntPathVisualFamily.engineeredSegmented:
        _paintDashed(
          canvas,
          start,
          end,
          color,
          roundCaps: false,
          width: width,
        );
        final midpoint = start + direction * (distance / 2);
        _paintJoint(canvas, midpoint, color);
        break;
      case WordHuntPathVisualFamily.ceremonialAlignment:
        _paintDashed(
          canvas,
          start,
          end,
          color,
          roundCaps: true,
          width: width,
        );
        final midpoint = start + direction * (distance / 2);
        _paintJoint(canvas, midpoint, color);
        _paintAlignmentTicks(canvas, start, end, direction, color);
        break;
    }
  }

  void _paintDashed(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color, {
    required bool roundCaps,
    required double width,
  }) {
    final delta = end - start;
    final distance = delta.distance;
    final direction = delta / distance;
    final underlayPaint = Paint()
      ..color = spec.underlayColor
      ..strokeWidth = width + 3.2
      ..strokeCap = roundCaps ? StrokeCap.round : StrokeCap.square;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = roundCaps ? StrokeCap.round : StrokeCap.square;
    var cursor = 0.0;
    while (cursor < distance) {
      final dashEnd = math.min(distance, cursor + spec.segmentLength);
      final dashStartPoint = start + direction * cursor;
      final dashEndPoint = start + direction * dashEnd;
      canvas.drawLine(dashStartPoint, dashEndPoint, underlayPaint);
      canvas.drawLine(dashStartPoint, dashEndPoint, paint);
      cursor = dashEnd + spec.gap;
    }
  }

  void _paintJoint(Canvas canvas, Offset center, Color color) {
    switch (spec.jointStyle) {
      case WordHuntPathJointStyle.wornStud:
        canvas.drawCircle(
          center,
          spec.jointRadius,
          Paint()..color = color.withValues(alpha: 0.86),
        );
        break;
      case WordHuntPathJointStyle.copperPlate:
        final rect = Rect.fromCenter(
          center: center,
          width: spec.jointRadius * 3.2,
          height: spec.jointRadius * 2.2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
          Paint()..color = color.withValues(alpha: 0.88),
        );
        break;
      case WordHuntPathJointStyle.alignmentMarker:
        canvas.drawCircle(
          center,
          spec.jointRadius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = color,
        );
        break;
    }
  }

  void _paintAlignmentTicks(
    Canvas canvas,
    Offset start,
    Offset end,
    Offset direction,
    Color color,
  ) {
    final distance = (end - start).distance;
    final perpendicular = Offset(-direction.dy, direction.dx);
    final spacing = math.max(18.0, spec.segmentLength + spec.gap);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.78)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var cursor = spacing; cursor < distance; cursor += spacing) {
      final center = start + direction * cursor;
      canvas.drawLine(
        center - perpendicular * 4,
        center + perpendicular * 4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WordHuntPathPainter oldDelegate) {
    return oldDelegate.segments != segments || oldDelegate.spec != spec;
  }
}
