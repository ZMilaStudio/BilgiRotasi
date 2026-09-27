import 'package:flutter/material.dart';
import 'package:word_hunt_flutter_feature/word_hunt_progress.dart';
import 'package:word_hunt_flutter_feature/word_hunt_reference_route_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_starter_content.dart';

/// Debug-only Android screenshot entrypoint. It never writes device progress,
/// and is not referenced from the production application entrypoint.
void main() => runApp(const _HarborVisualProofApp());

class _HarborVisualProofApp extends StatefulWidget {
  const _HarborVisualProofApp();

  @override
  State<_HarborVisualProofApp> createState() => _HarborVisualProofAppState();
}

class _HarborVisualProofAppState extends State<_HarborVisualProofApp> {
  int selected = 2;
  final progress = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (var level = 1; level <= 28; level++)
        'baslangic-$level': level % 3 + 1,
    },
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WordHuntReferenceRouteScreen(
      route: WordHuntStarterContent.baslangicLimani,
      progress: progress,
      segmentIndex: selected,
      onBack: () {},
      onInfo: () {},
      onLevelTap: (_) {},
      onSegmentSelect: (index) => setState(() => selected = index),
    ),
  );
}