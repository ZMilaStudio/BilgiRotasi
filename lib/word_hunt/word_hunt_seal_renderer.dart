import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';

enum WordHuntSealMaterialFamily {
  ancientStone,
  engineeredStoneCopper,
  ceremonialSolarStone,
}

enum WordHuntSealFrameArchitecture {
  weatheredSegments,
  engineeredSegments,
  ceremonialRays,
}

enum WordHuntSealCenterTreatment {
  recessedStone,
  turquoiseInset,
  navySolarInset,
}

enum WordHuntSealChallengeGeometry {
  radialFragments,
  concentricLock,
  splitAlignment,
}

enum WordHuntSealFinalGeometry {
  multiRingDescent,
  celestialMechanism,
  solarThrone,
}

enum WordHuntSealNodeState { locked, current, completed }

@immutable
class WordHuntSealVisualSpec {
  const WordHuntSealVisualSpec({
    required this.id,
    required this.materialFamily,
    required this.frameArchitecture,
    required this.centerTreatment,
    required this.challengeGeometry,
    required this.finalGeometry,
    required this.surfaceColor,
    required this.rimColor,
    required this.accentColor,
    required this.centerColor,
    required this.lockedColor,
    required this.textColor,
    required this.shadowColor,
    this.normalFootprint = 52,
    this.challengeFootprint = 60,
    this.finalFootprint = 70,
  }) : assert(normalFootprint > 0),
       assert(challengeFootprint > normalFootprint),
       assert(finalFootprint > challengeFootprint);

  final String id;
  final WordHuntSealMaterialFamily materialFamily;
  final WordHuntSealFrameArchitecture frameArchitecture;
  final WordHuntSealCenterTreatment centerTreatment;
  final WordHuntSealChallengeGeometry challengeGeometry;
  final WordHuntSealFinalGeometry finalGeometry;
  final Color surfaceColor;
  final Color rimColor;
  final Color accentColor;
  final Color centerColor;
  final Color lockedColor;
  final Color textColor;
  final Color shadowColor;
  final double normalFootprint;
  final double challengeFootprint;
  final double finalFootprint;

  double footprintFor(WordHuntLevelType type) => switch (type) {
    WordHuntLevelType.challenge => challengeFootprint,
    WordHuntLevelType.routeFinal => finalFootprint,
    WordHuntLevelType.normal || WordHuntLevelType.bonus => normalFootprint,
  };

  static const WordHuntSealVisualSpec ancient = WordHuntSealVisualSpec(
    id: 'ancient-seal',
    materialFamily: WordHuntSealMaterialFamily.ancientStone,
    frameArchitecture: WordHuntSealFrameArchitecture.weatheredSegments,
    centerTreatment: WordHuntSealCenterTreatment.recessedStone,
    challengeGeometry: WordHuntSealChallengeGeometry.radialFragments,
    finalGeometry: WordHuntSealFinalGeometry.multiRingDescent,
    surfaceColor: Color(0xFF75513A),
    rimColor: Color(0xFFC8A46D),
    accentColor: Color(0xFF56BDB2),
    centerColor: Color(0xFF302927),
    lockedColor: Color(0xFF55504B),
    textColor: Color(0xFFF8E9C8),
    shadowColor: Color(0xD9140F0C),
  );

  static const WordHuntSealVisualSpec mechanical = WordHuntSealVisualSpec(
    id: 'mechanical-seal',
    materialFamily: WordHuntSealMaterialFamily.engineeredStoneCopper,
    frameArchitecture: WordHuntSealFrameArchitecture.engineeredSegments,
    centerTreatment: WordHuntSealCenterTreatment.turquoiseInset,
    challengeGeometry: WordHuntSealChallengeGeometry.concentricLock,
    finalGeometry: WordHuntSealFinalGeometry.celestialMechanism,
    surfaceColor: Color(0xFF453E38),
    rimColor: Color(0xFFA76A3C),
    accentColor: Color(0xFF55C7C2),
    centerColor: Color(0xFF163C42),
    lockedColor: Color(0xFF4D4B48),
    textColor: Color(0xFFF4E6CE),
    shadowColor: Color(0xDD100D0B),
  );

  static const WordHuntSealVisualSpec solar = WordHuntSealVisualSpec(
    id: 'solar-seal',
    materialFamily: WordHuntSealMaterialFamily.ceremonialSolarStone,
    frameArchitecture: WordHuntSealFrameArchitecture.ceremonialRays,
    centerTreatment: WordHuntSealCenterTreatment.navySolarInset,
    challengeGeometry: WordHuntSealChallengeGeometry.splitAlignment,
    finalGeometry: WordHuntSealFinalGeometry.solarThrone,
    surfaceColor: Color(0xFFB18A46),
    rimColor: Color(0xFFF0C870),
    accentColor: Color(0xFF69D8D0),
    centerColor: Color(0xFF182B52),
    lockedColor: Color(0xFF71684F),
    textColor: Color(0xFFFFF0C4),
    shadowColor: Color(0xDD111427),
  );
}

/// Shared premium seal renderer.
///
/// Silhouette authority is the level type. State only changes material response;
/// it never replaces challenge/final geometry with a normal node.
class WordHuntSealNode extends StatelessWidget {
  const WordHuntSealNode({
    super.key,
    required this.levelIndex,
    required this.levelType,
    required this.state,
    required this.spec,
  });

  final int levelIndex;
  final WordHuntLevelType levelType;
  final WordHuntSealNodeState state;
  final WordHuntSealVisualSpec spec;

  String get _silhouetteName => switch (levelType) {
    WordHuntLevelType.challenge => 'challenge',
    WordHuntLevelType.routeFinal => 'final',
    WordHuntLevelType.normal || WordHuntLevelType.bonus => 'normal',
  };

  @override
  Widget build(BuildContext context) {
    final completed = state == WordHuntSealNodeState.completed;
    final locked = state == WordHuntSealNodeState.locked;
    final footprint = spec.footprintFor(levelType);

    return SizedBox(
      key: Key('word_hunt_seal_node_${levelIndex}_${state.name}'),
      width: 78,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.square(
            dimension: footprint,
            child: CustomPaint(
              key: Key(
                'word_hunt_seal_silhouette_${levelIndex}_$_silhouetteName',
              ),
              painter: _WordHuntSealPainter(
                type: levelType,
                state: state,
                spec: spec,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.08),
            child: Text(
              '$levelIndex',
              key: Key('word_hunt_seal_numeral_$levelIndex'),
              maxLines: 1,
              style: TextStyle(
                color: spec.textColor,
                fontSize: levelType == WordHuntLevelType.routeFinal ? 17 : 16,
                height: 1,
                fontWeight: FontWeight.w900,
                shadows: <Shadow>[
                  Shadow(
                    color: spec.shadowColor,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: Row(
              key: Key('word_hunt_seal_star_row_$levelIndex'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(3, (index) {
                return Container(
                  key: Key(
                    'word_hunt_seal_star_socket_${levelIndex}_$index',
                  ),
                  width: 11,
                  height: 11,
                  margin: const EdgeInsets.symmetric(horizontal: 1.2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? spec.accentColor.withValues(alpha: 0.20)
                        : spec.shadowColor.withValues(alpha: 0.46),
                    border: Border.all(
                      color: completed
                          ? spec.accentColor
                          : spec.rimColor.withValues(alpha: 0.58),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: completed
                      ? Icon(
                          Icons.star_rounded,
                          key: Key(
                            'word_hunt_seal_star_filled_${levelIndex}_$index',
                          ),
                          size: 9,
                          color: spec.accentColor,
                        )
                      : null,
                );
              }),
            ),
          ),
          if (locked)
            Positioned(
              right: 7,
              bottom: 13,
              width: 18,
              height: 14,
              child: CustomPaint(
                key: Key('word_hunt_seal_physical_lock_$levelIndex'),
                painter: _WordHuntPhysicalLockPainter(
                  metal: spec.rimColor.withValues(alpha: 0.66),
                  recess: spec.shadowColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WordHuntSealPainter extends CustomPainter {
  const _WordHuntSealPainter({
    required this.type,
    required this.state,
    required this.spec,
  });

  final WordHuntLevelType type;
  final WordHuntSealNodeState state;
  final WordHuntSealVisualSpec spec;

  bool get _locked => state == WordHuntSealNodeState.locked;
  bool get _current => state == WordHuntSealNodeState.current;
  bool get _completed => state == WordHuntSealNodeState.completed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) * 0.44;
    final surface = _locked
        ? Color.alphaBlend(
            spec.lockedColor.withValues(alpha: 0.72),
            spec.surfaceColor,
          )
        : spec.surfaceColor;
    final rim = _locked
        ? Color.alphaBlend(
            spec.lockedColor.withValues(alpha: 0.64),
            spec.rimColor,
          )
        : spec.rimColor;
    final accent = _locked
        ? spec.accentColor.withValues(alpha: 0.24)
        : _completed
        ? spec.accentColor.withValues(alpha: 0.90)
        : spec.accentColor.withValues(alpha: _current ? 0.76 : 0.54);

    if (_current) {
      canvas.drawCircle(
        center,
        radius + 5,
        Paint()
          ..color = spec.accentColor.withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    canvas.drawCircle(
      center + const Offset(1, 2),
      radius + 1,
      Paint()..color = spec.shadowColor.withValues(alpha: 0.70),
    );
    canvas.drawCircle(center, radius, Paint()..color = surface);

    _paintFrame(canvas, center, radius, rim, accent);
    _paintCenter(canvas, center, radius, accent);

    if (type == WordHuntLevelType.challenge) {
      _paintChallenge(canvas, center, radius, rim, accent);
    } else if (type == WordHuntLevelType.routeFinal) {
      _paintFinal(canvas, center, radius, rim, accent);
    }
  }

  void _paintFrame(
    Canvas canvas,
    Offset center,
    double radius,
    Color rim,
    Color accent,
  ) {
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = rim;
    canvas.drawCircle(center, radius, frame);
    canvas.drawCircle(
      center,
      radius * 0.78,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = accent,
    );

    switch (spec.frameArchitecture) {
      case WordHuntSealFrameArchitecture.weatheredSegments:
        for (var i = 0; i < 7; i++) {
          final start = i * math.pi * 2 / 7 + 0.10;
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius * 0.91),
            start,
            0.42,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..strokeCap = StrokeCap.round
              ..color = rim.withValues(alpha: 0.66),
          );
        }
        break;
      case WordHuntSealFrameArchitecture.engineeredSegments:
        for (var i = 0; i < 10; i++) {
          final a = i * math.pi * 2 / 10;
          final p1 = center + Offset(math.cos(a), math.sin(a)) * radius * 0.82;
          final p2 = center + Offset(math.cos(a), math.sin(a)) * radius * 0.98;
          canvas.drawLine(
            p1,
            p2,
            Paint()
              ..strokeWidth = 1.6
              ..color = i.isEven ? accent : rim,
          );
        }
        break;
      case WordHuntSealFrameArchitecture.ceremonialRays:
        for (var i = 0; i < 12; i++) {
          final a = i * math.pi * 2 / 12;
          final p1 = center + Offset(math.cos(a), math.sin(a)) * radius * 0.80;
          final p2 = center + Offset(math.cos(a), math.sin(a)) * radius * 1.02;
          canvas.drawLine(
            p1,
            p2,
            Paint()
              ..strokeWidth = i.isEven ? 2.1 : 1.1
              ..strokeCap = StrokeCap.round
              ..color = i.isEven ? rim : accent,
          );
        }
        break;
    }
  }

  void _paintCenter(
    Canvas canvas,
    Offset center,
    double radius,
    Color accent,
  ) {
    final centerColor = _locked
        ? Color.alphaBlend(
            spec.lockedColor.withValues(alpha: 0.58),
            spec.centerColor,
          )
        : spec.centerColor;
    canvas.drawCircle(
      center,
      radius * 0.49,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.22, -0.28),
          colors: <Color>[
            Color.alphaBlend(
              spec.textColor.withValues(alpha: _locked ? 0.03 : 0.10),
              centerColor,
            ),
            centerColor,
            Color.alphaBlend(
              spec.shadowColor.withValues(alpha: 0.30),
              centerColor,
            ),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.50)),
    );
    canvas.drawCircle(
      center,
      radius * 0.51,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = accent.withValues(alpha: 0.72),
    );
  }

  void _paintChallenge(
    Canvas canvas,
    Offset center,
    double radius,
    Color rim,
    Color accent,
  ) {
    switch (spec.challengeGeometry) {
      case WordHuntSealChallengeGeometry.radialFragments:
        for (var i = 0; i < 5; i++) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius * 1.06),
            -0.9 + i * 1.17,
            0.50,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.2
              ..strokeCap = StrokeCap.round
              ..color = i.isEven ? accent : rim,
          );
        }
        break;
      case WordHuntSealChallengeGeometry.concentricLock:
        canvas.drawCircle(
          center,
          radius * 0.67,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = rim.withValues(alpha: 0.82),
        );
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 1.02),
          -2.7,
          4.2,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..color = accent,
        );
        break;
      case WordHuntSealChallengeGeometry.splitAlignment:
        final linePaint = Paint()
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = accent;
        canvas.drawLine(
          center + Offset(-radius * 0.94, 0),
          center + Offset(-radius * 0.50, 0),
          linePaint,
        );
        canvas.drawLine(
          center + Offset(radius * 0.50, 0),
          center + Offset(radius * 0.94, 0),
          linePaint,
        );
        canvas.drawLine(
          center + Offset(0, -radius * 0.94),
          center + Offset(0, -radius * 0.54),
          linePaint,
        );
        canvas.drawLine(
          center + Offset(0, radius * 0.54),
          center + Offset(0, radius * 0.94),
          linePaint,
        );
        break;
    }
  }

  void _paintFinal(
    Canvas canvas,
    Offset center,
    double radius,
    Color rim,
    Color accent,
  ) {
    canvas.drawCircle(
      center,
      radius * 1.07,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = rim.withValues(alpha: 0.90),
    );

    switch (spec.finalGeometry) {
      case WordHuntSealFinalGeometry.multiRingDescent:
        canvas.drawCircle(
          center,
          radius * 0.64,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = accent,
        );
        canvas.drawCircle(
          center,
          radius * 0.34,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..color = rim,
        );
        break;
      case WordHuntSealFinalGeometry.celestialMechanism:
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final start =
              center + Offset(math.cos(a), math.sin(a)) * radius * 0.55;
          final end =
              center + Offset(math.cos(a), math.sin(a)) * radius * 0.90;
          canvas.drawLine(
            start,
            end,
            Paint()
              ..strokeWidth = i.isEven ? 1.8 : 1.1
              ..color = i.isEven ? accent : rim,
          );
        }
        break;
      case WordHuntSealFinalGeometry.solarThrone:
        for (var i = 0; i < 16; i++) {
          final a = i * math.pi * 2 / 16;
          final inner = radius * (i.isEven ? 0.90 : 0.96);
          final outer = radius * (i.isEven ? 1.18 : 1.10);
          canvas.drawLine(
            center + Offset(math.cos(a), math.sin(a)) * inner,
            center + Offset(math.cos(a), math.sin(a)) * outer,
            Paint()
              ..strokeWidth = i.isEven ? 2.4 : 1.1
              ..strokeCap = StrokeCap.round
              ..color = i.isEven ? rim : accent,
          );
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _WordHuntSealPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.state != state ||
        oldDelegate.spec != spec;
  }
}

class _WordHuntPhysicalLockPainter extends CustomPainter {
  const _WordHuntPhysicalLockPainter({
    required this.metal,
    required this.recess,
  });

  final Color metal;
  final Color recess;

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, size.height * 0.34, size.width - 2, size.height * 0.62),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, Paint()..color = metal);
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.27,
        0,
        size.width * 0.46,
        size.height * 0.64,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = metal,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.68),
      1.5,
      Paint()..color = recess.withValues(alpha: 0.86),
    );
  }

  @override
  bool shouldRepaint(covariant _WordHuntPhysicalLockPainter oldDelegate) {
    return oldDelegate.metal != metal || oldDelegate.recess != recess;
  }
}
