import 'dart:async';

import 'package:flutter/material.dart';

import 'word_hunt_gameplay_presentation.dart';
import 'word_hunt_models.dart';
import 'word_hunt_screens.dart';

/// Route final henüz tamamlanmamışken generic level-result dialog'unu kullanıcıya
/// göstermeden mevcut production gameplay sonucunu parent orchestration'a taşır.
///
/// Mevcut gameplay ekranının scoring/content davranışını değiştirmez. Yalnız
/// presentation-level defer opt-in'ini açar ve sonucu parent completion yüzeyine
/// iletir; exit confirmation normal production davranışını korur.
class WordHuntDeferredCompletionLevelScreen extends StatefulWidget {
  const WordHuntDeferredCompletionLevelScreen({
    super.key,
    required this.level,
    required this.infoCards,
    required this.routeTitle,
    this.presentation,
  });

  final WordHuntLevelDefinition level;
  final List<WordHuntInfoCard> infoCards;
  final String routeTitle;
  final WordHuntGameplayPresentation? presentation;

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
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => _DeferredCompletionShell(
          level: widget.level,
          infoCards: widget.infoCards,
          routeTitle: widget.routeTitle,
          presentation: widget.presentation,
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
    required this.presentation,
    required this.onResult,
  });

  final WordHuntLevelDefinition level;
  final List<WordHuntInfoCard> infoCards;
  final String routeTitle;
  final WordHuntGameplayPresentation? presentation;
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
          presentation: widget.presentation,
          routeTitle: widget.routeTitle,
          deferCompletionDialog: true,
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
