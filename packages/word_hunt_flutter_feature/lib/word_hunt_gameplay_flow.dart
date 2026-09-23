import 'package:flutter/material.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_reference_route_screen.dart';
import 'word_hunt_screens.dart';
import 'word_hunt_starter_content.dart';

typedef WordHuntGameplayLevelBuilder =
    Widget Function(
      BuildContext context,
      WordHuntLevelDefinition level,
      List<WordHuntInfoCard> infoCards,
    );

/// Production MASTER ART rota ile Bölüm 1 gameplay'ini izole olarak bağlar.
///
/// Bu flow `lib/main.dart` entegrasyonu veya kalıcı depolama yapmaz. Başarılı
/// bir gerçek level sonucu geldiğinde mevcut progress snapshot'ını günceller
/// ve aynı route widget'ını yeni state ile render eder.
class WordHuntGameplayFlow extends StatefulWidget {
  const WordHuntGameplayFlow({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.infoCards = WordHuntStarterContent.infoCards,
    this.initialProgress = const WordHuntProgressSnapshot(),
    this.levelBuilder,
    this.onProgressChanged,
    this.onBack,
    this.onInfo,
  });

  final WordHuntRouteDefinition route;
  final List<WordHuntInfoCard> infoCards;
  final WordHuntProgressSnapshot initialProgress;
  final WordHuntGameplayLevelBuilder? levelBuilder;
  final ValueChanged<WordHuntProgressSnapshot>? onProgressChanged;
  final VoidCallback? onBack;
  final VoidCallback? onInfo;

  @override
  State<WordHuntGameplayFlow> createState() => _WordHuntGameplayFlowState();
}

class _WordHuntGameplayFlowState extends State<WordHuntGameplayFlow> {
  late WordHuntProgressSnapshot _progress;
  bool _openingLevel = false;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
  }

  Future<void> _openLevel(int index) async {
    if (_openingLevel || index != 1) return;
    if (!WordHuntRouteProgressEngine.isLevelUnlocked(
      widget.route,
      _progress,
      index,
    )) {
      return;
    }

    _openingLevel = true;
    final level = widget.route.levels[index - 1];
    try {
      final result = await Navigator.of(context).push<WordHuntLevelPlayResult>(
        MaterialPageRoute<WordHuntLevelPlayResult>(
          builder:
              (context) =>
                  widget.levelBuilder?.call(context, level, widget.infoCards) ??
                  WordHuntLevelProductionScreen(
                    level: level,
                    infoCards: widget.infoCards,
                  ),
        ),
      );
      if (!mounted || result == null || result.levelId != level.id) return;

      final updated = _progress.recordLevelResult(
        levelId: result.levelId,
        stars: result.stars,
        unlockedInfoCards: result.unlockedInfoCardIds,
      );
      setState(() => _progress = updated);
      widget.onProgressChanged?.call(updated);
    } finally {
      _openingLevel = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('word_hunt_gameplay_flow'),
      child: WordHuntReferenceRouteScreen(
        route: widget.route,
        progress: _progress,
        onBack: widget.onBack,
        onInfo: widget.onInfo,
        onLevelTap: _openLevel,
      ),
    );
  }
}
