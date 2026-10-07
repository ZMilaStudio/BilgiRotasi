import 'package:flutter/material.dart';
import 'package:word_hunt_domain/word_hunt_journey_catalog_contract.dart';
import 'package:word_hunt_domain/word_hunt_journey_gameplay_completion.dart';
import 'word_hunt_journey_gameplay_visual.dart';
import 'word_hunt_models.dart';
import 'word_hunt_screens.dart';
import 'word_hunt_starter_content.dart';

class JourneyGameplayCompletionBridge {
  static JourneyGameplayCompletion normalize(
    JourneyLevelRecord record,
    WordHuntLevelDefinition level,
    WordHuntLevelPlayResult result,
  ) {
    if (!record.published ||
        record.stableId != journeyStableId(record.ordinal) ||
        level.index != record.ordinal ||
        (record.gameplayContentId != null &&
            record.gameplayContentId != level.id) ||
        result.levelId != level.id ||
        result.foundBonusCount == null ||
        result.foundBonusCount! < 0 ||
        result.foundBonusCount! > level.bonusWords.length) {
      throw StateError('Gameplay outcome does not match the opened payload.');
    }
    return JourneyGameplayCompletion(
      stableLevelId: record.stableId,
      earnedStars: result.stars,
      bonusFoundCount: result.foundBonusCount!,
      completed: true,
      challenge: level.type == WordHuntLevelType.challenge,
    );
  }
}

/// Detached production gameplay: no legacy feature-entry/orchestrator/storage.
/// The inner gameplay route returns its frozen score to this outer host. The
/// host stays open with that outcome until Journey persistence succeeds.
class WordHuntJourneyGameplayHost extends StatefulWidget {
  const WordHuntJourneyGameplayHost({
    super.key,
    required this.record,
    required this.level,
    required this.onCompletion,
    this.now,
  });
  final JourneyLevelRecord record;
  final WordHuntLevelDefinition level;
  final Future<bool> Function(JourneyGameplayCompletion) onCompletion;
  final DateTime Function()? now;
  @override
  State<WordHuntJourneyGameplayHost> createState() => _HostState();
}

class _HostState extends State<WordHuntJourneyGameplayHost> {
  final navigator = GlobalKey<NavigatorState>();
  JourneyGameplayCompletion? outcome;
  bool busy = false, allowExit = false;
  String? error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => launch());
  }

  Future<void> launch() async {
    if (!mounted) return;
    final result = await navigator.currentState!.push<WordHuntLevelPlayResult>(
      MaterialPageRoute(
        builder:
            (_) => WordHuntLevelProductionScreen(
              level: widget.level,
              infoCards: WordHuntStarterContent.infoCards,
              presentation: JourneyGameplayVisual.forOrdinal(
                widget.level.index,
              ),
              routeTitle: 'Kelime Avı',
              deferCompletionDialog: true,
              now: widget.now,
            ),
      ),
    );
    if (!mounted) return;
    if (result == null) {
      leave();
      return;
    }
    try {
      outcome = JourneyGameplayCompletionBridge.normalize(
        widget.record,
        widget.level,
        result,
      );
    } catch (_) {
      setState(
        () =>
            error =
                'Bölüm sonucu doğrulanamadı. Haritaya dönmeden tekrar dene.',
      );
      return;
    }
    await persist();
  }

  void leave() {
    setState(() => allowExit = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void replayInvalidOutcome() {
    setState(() => error = null);
    WidgetsBinding.instance.addPostFrameCallback((_) => launch());
  }

  Future<void> persist() async {
    if (busy || outcome == null) return;
    setState(() {
      busy = true;
      error = null;
    });
    var saved = false;
    try {
      saved = await widget.onCompletion(outcome!);
    } catch (_) {
      /* Retain outcome for retry. */
    }
    if (!mounted) return;
    if (saved) {
      leave();
      return;
    }
    setState(() {
      busy = false;
      error = 'Kayıt yapılamadı. Sonucun korundu; tekrar dene.';
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: allowExit,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && outcome == null && error == null)
        navigator.currentState?.maybePop();
    },
    child:
        outcome != null || error != null
            ? Scaffold(
              appBar: AppBar(
                title: const Text('Bölüm tamamlandı'),
                automaticallyImplyLeading: false,
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (outcome != null) ...[
                      Text(
                        '${outcome!.earnedStars} yıldız • ${outcome!.bonusFoundCount} bonus',
                      ),
                      if (busy) const CircularProgressIndicator(),
                    ],
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Semantics(liveRegion: true, child: Text(error!)),
                      ),
                    if (!busy && outcome != null)
                      FilledButton(
                        key: const Key('journey_completion_retry'),
                        onPressed: persist,
                        child: const Text('TEKRAR DENE'),
                      ),
                    if (outcome == null && error != null)
                      FilledButton(
                        onPressed: replayInvalidOutcome,
                        child: const Text('YENİDEN OYNA'),
                      ),
                  ],
                ),
              ),
            )
            : Navigator(
              key: navigator,
              onGenerateRoute:
                  (_) => MaterialPageRoute<void>(
                    builder:
                        (_) => const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        ),
                  ),
            ),
  );
}
