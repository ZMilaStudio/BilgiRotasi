import 'dart:async';

import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_screens.dart';

/// Route final henüz tamamlanmamışken generic level-result dialog'unu kullanıcıya
/// göstermeden mevcut production gameplay sonucunu parent orchestration'a taşır.
///
/// Mevcut gameplay ekranına scoring/content branch'i eklemez. Yalnız onun
/// non-dismissible completion dialog'unu aynı event-loop içinde onaylayıp görünür
/// completion yüzeyini parent'a bırakır; exit confirmation gibi dismissible
/// dialog'lara dokunmaz.
class WordHuntDeferredCompletionLevelScreen extends StatefulWidget {
  const WordHuntDeferredCompletionLevelScreen({
    super.key,
    required this.level,
    required this.infoCards,
    required this.routeTitle,
    this.backgroundAsset,
  });

  final WordHuntLevelDefinition level;
  final List<WordHuntInfoCard> infoCards;
  final String routeTitle;
  final String? backgroundAsset;

  @override
  State<WordHuntDeferredCompletionLevelScreen> createState() =>
      _WordHuntDeferredCompletionLevelScreenState();
}

class _WordHuntDeferredCompletionLevelScreenState
    extends State<WordHuntDeferredCompletionLevelScreen> {
  bool _resultForwarded = false;

  void _forwardResult(WordHuntLevelPlayResult? result) {
    if (_resultForwarded) return;
    _resultForwarded = true;
    scheduleMicrotask(() {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: const Key('word_hunt_deferred_completion_navigator'),
      observers: <NavigatorObserver>[_DeferredCompletionDialogObserver()],
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => _DeferredCompletionShell(
          level: widget.level,
          infoCards: widget.infoCards,
          routeTitle: widget.routeTitle,
          backgroundAsset: widget.backgroundAsset,
          onResult: _forwardResult,
        ),
      ),
    );
  }
}

class _DeferredCompletionShell extends StatefulWidget {
  const _DeferredCompletionShell({
    required this.level,
    required this.infoCards,
    required this.routeTitle,
    required this.backgroundAsset,
    required this.onResult,
  });

  final WordHuntLevelDefinition level;
  final List<WordHuntInfoCard> infoCards;
  final String routeTitle;
  final String? backgroundAsset;
  final ValueChanged<WordHuntLevelPlayResult?> onResult;

  @override
  State<_DeferredCompletionShell> createState() =>
      _DeferredCompletionShellState();
}

class _DeferredCompletionShellState extends State<_DeferredCompletionShell> {
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchGameplay());
  }

  Future<void> _launchGameplay() async {
    if (!mounted || _launched) return;
    _launched = true;
    final result = await Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder: (_) => WordHuntLevelProductionScreen(
          level: widget.level,
          infoCards: widget.infoCards,
          backgroundAsset: widget.backgroundAsset,
          routeTitle: widget.routeTitle,
        ),
      ),
    );
    if (mounted) widget.onResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF061425),
      child: SizedBox.expand(),
    );
  }
}

class _DeferredCompletionDialogObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is! DialogRoute<bool> || route.barrierDismissible) return;

    scheduleMicrotask(() {
      if (route.isActive) route.navigator?.pop(true);
    });
  }
}
