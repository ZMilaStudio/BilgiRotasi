import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_route_catalog.dart';
import 'word_hunt_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const _Wave5GameplayProofApp());
}

class _Wave5GameplayProofApp extends StatelessWidget {
  const _Wave5GameplayProofApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _Wave5GameplayProofCarousel(),
    );
  }
}

class _Wave5GameplayProofCarousel extends StatefulWidget {
  const _Wave5GameplayProofCarousel();

  @override
  State<_Wave5GameplayProofCarousel> createState() =>
      _Wave5GameplayProofCarouselState();
}

class _Wave5GameplayProofCarouselState
    extends State<_Wave5GameplayProofCarousel> {
  static const Duration _routeDuration = Duration(seconds: 5);

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _announceAfterFrame();
    _timer = Timer.periodic(_routeDuration, (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % WordHuntRouteCatalog.entries.length;
      });
      _announceAfterFrame();
    });
  }

  void _announceAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final entry = WordHuntRouteCatalog.entries[_index];
      final presentation = entry.presentationProfile.gameplayForLevel(
        levelIndex: 1,
      );
      debugPrint(
        '[WAVE5_GAMEPLAY_PROOF_READY] '
        'route=${entry.route.id} '
        'profile=${presentation.profileId} '
        'scene=${presentation.scene.id}',
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = WordHuntRouteCatalog.entries[_index];
    final level = entry.route.levels.first;
    final presentation = entry.presentationProfile.gameplayForLevel(
      levelIndex: level.index,
    );
    return WordHuntLevelProductionScreen(
      key: ValueKey<String>('wave5-proof-${entry.route.id}'),
      level: level,
      infoCards: entry.infoCards,
      routeTitle: entry.route.title,
      presentation: presentation,
    );
  }
}
