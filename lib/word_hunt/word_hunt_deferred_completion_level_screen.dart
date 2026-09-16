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
  late final NavigatorObserver _completionObserver =
      _DeferredCompletionDialogObserver();
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
      observers: <NavigatorObserver>[_completionObserver],
      onGenerateRoute: (_) => _ForwardingMaterialPageRoute<WordHuntLevelPlayResult>(
        onPopped: _forwardResult,
        builder: (_) => WordHuntLevelProductionScreen(
          level: widget.level,
          infoCards: widget.infoCards,
          backgroundAsset: widget.backgroundAsset,
          routeTitle: widget.routeTitle,
        ),
      ),
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

class _ForwardingMaterialPageRoute<T> extends MaterialPageRoute<T> {
  _ForwardingMaterialPageRoute({
    required super.builder,
    required this.onPopped,
  });

  final ValueChanged<T?> onPopped;

  @override
  bool didPop(T? result) {
    final didPop = super.didPop(result);
    if (didPop) onPopped(result);
    return didPop;
  }
}
