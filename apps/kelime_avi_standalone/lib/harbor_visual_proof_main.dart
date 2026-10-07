import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:word_hunt_flutter_feature/word_hunt_progress.dart';
import 'package:word_hunt_flutter_feature/word_hunt_reference_route_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_starter_content.dart';

/// Debug-only Android screenshot entrypoint. It never writes device progress,
/// and is not referenced from the production application entrypoint.
void main() => runApp(buildHarborVisualProofApp());

@visibleForTesting
Widget buildHarborVisualProofApp({Key? key}) => _HarborVisualProofApp(key: key);

class _HarborVisualProofApp extends StatefulWidget {
  const _HarborVisualProofApp({super.key});

  @override
  State<_HarborVisualProofApp> createState() => _HarborVisualProofAppState();
}

class _HarborVisualProofAppState extends State<_HarborVisualProofApp> {
  int selected = 2;
  _HarborProofScenario scenario = _HarborProofScenario.mixed;
  String? _lastGeometrySignature;

  WordHuntProgressSnapshot get progress => switch (scenario) {
    _HarborProofScenario.mixed => WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (var level = 1; level <= 10; level++) 'baslangic-$level': 3,
        'baslangic-11': 1,
        'baslangic-12': 2,
        'baslangic-13': 3,
        'baslangic-14': 1,
      },
    ),
    _HarborProofScenario.l20Playable => WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (var level = 1; level <= 10; level++) 'baslangic-$level': 3,
        for (var level = 11; level <= 19; level++)
          'baslangic-$level': (level - 11) % 3 + 1,
      },
    ),
    _HarborProofScenario.segment3 => WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (var level = 1; level <= 28; level++)
          'baslangic-$level': level % 3 + 1,
      },
    ),
    _HarborProofScenario.segment4Mixed => WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (var level = 1; level <= 30; level++) 'baslangic-$level': 1,
        for (var level = 31; level <= 33; level++)
          'baslangic-$level': level - 30,
      },
    ),
    _HarborProofScenario.l40Playable => WordHuntProgressSnapshot(
      bestStarsByLevelId: <String, int>{
        for (var level = 1; level <= 30; level++) 'baslangic-$level': 1,
        for (var level = 31; level <= 39; level++)
          'baslangic-$level': (level - 31) % 3 + 1,
      },
    ),
  };

  void _toggleScenario() {
    setState(() {
      scenario = switch (scenario) {
        _HarborProofScenario.mixed => _HarborProofScenario.l20Playable,
        _HarborProofScenario.l20Playable => _HarborProofScenario.segment3,
        _HarborProofScenario.segment3 => _HarborProofScenario.segment4Mixed,
        _HarborProofScenario.segment4Mixed => _HarborProofScenario.l40Playable,
        _HarborProofScenario.l40Playable => _HarborProofScenario.mixed,
      };
      selected = switch (scenario) {
        _HarborProofScenario.segment3 => 3,
        _HarborProofScenario.segment4Mixed ||
        _HarborProofScenario.l40Playable => 4,
        _ => 2,
      };
      _lastGeometrySignature = null;
    });
  }

  void _scheduleGeometryEvidence() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final view = View.of(context);
      final logicalSize = MediaQuery.sizeOf(context);
      final signature =
          '${scenario.name}:${logicalSize.width}x${logicalSize.height}';
      if (_lastGeometrySignature == signature) return;

      final evidence = <String, Map<String, double>>{};
      void visit(Element element) {
        final key = element.widget.key;
        final value = key is ValueKey<String> ? key.value : null;
        if (value != null &&
            (value == 'word_hunt_harbor_scene_2' ||
                value == 'word_hunt_harbor_scene_3' ||
                value == 'word_hunt_harbor_scene_4' ||
                value.startsWith('word_hunt_harbor_stars_') ||
                value.startsWith('word_hunt_harbor_level_') ||
                value.startsWith('word_hunt_harbor_medallion_') ||
                value.startsWith('word_hunt_harbor_star_backplate_') ||
                value.startsWith('word_hunt_harbor_challenge_'))) {
          final renderObject = element.renderObject;
          if (renderObject is RenderBox && renderObject.hasSize) {
            final origin = renderObject.localToGlobal(Offset.zero);
            evidence[value] = <String, double>{
              'left': origin.dx,
              'top': origin.dy,
              'width': renderObject.size.width,
              'height': renderObject.size.height,
              'right': origin.dx + renderObject.size.width,
              'bottom': origin.dy + renderObject.size.height,
            };
          }
        }
        element.visitChildren(visit);
      }

      WidgetsBinding.instance.rootElement?.visitChildren(visit);
      if (!evidence.containsKey('word_hunt_harbor_scene_$selected') ||
          !evidence.containsKey('word_hunt_harbor_level_${selected * 10}')) {
        // Registered scenes load asynchronously without rebuilding this parent.
        Future<void>.delayed(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          _scheduleGeometryEvidence();
          WidgetsBinding.instance.scheduleFrame();
        });
        return;
      }
      _lastGeometrySignature = signature;
      debugPrint(
        '[HARBOR_PROOF_FRAME] ${jsonEncode(<String, Object>{'scenario': scenario.name, 'logicalWidth': logicalSize.width, 'logicalHeight': logicalSize.height, 'devicePixelRatio': view.devicePixelRatio})}',
      );
      for (final entry in evidence.entries) {
        debugPrint(
          '[HARBOR_PROOF_GEOMETRY] ${jsonEncode(<String, Object>{'scenario': scenario.name, 'logicalWidth': logicalSize.width, 'logicalHeight': logicalSize.height, 'key': entry.key, 'rect': entry.value})}',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleGeometryEvidence();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WordHuntReferenceRouteScreen(
        route: WordHuntStarterContent.baslangicLimani,
        progress: progress,
        segmentIndex: selected,
        onBack: () {},
        onInfo: _toggleScenario,
        onLevelTap: (_) {},
        onSegmentSelect: (index) => setState(() => selected = index),
      ),
    );
  }
}

enum _HarborProofScenario {
  mixed,
  l20Playable,
  segment3,
  segment4Mixed,
  l40Playable,
}
