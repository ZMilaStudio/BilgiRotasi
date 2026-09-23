import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'word_hunt_gameplay_presentation.dart';
import 'word_hunt_input.dart';
import 'word_hunt_models.dart';
import 'word_hunt_path.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_scoring.dart';
import 'word_hunt_starter_content.dart';

const _harborGridSpacing = 1.5;
const _harborCellVisualScale = 1.12;
const _harborInstructionDefault =
    'İlk harfe dokun, parmağını kelimenin üzerinde sürükle.';

class WordHuntLevelPlayResult {
  const WordHuntLevelPlayResult({
    required this.levelId,
    required this.stars,
    required this.unlockedInfoCardIds,
    this.foundBonusCount,
  });

  final String levelId;
  final int stars;
  final Set<String> unlockedInfoCardIds;
  final int? foundBonusCount;
}

/// Başlangıç Limanı Bölüm 1 için production oynanış ekranı.
///
/// Prototype ekran korunur; bu ekran aynı path/scoring motorlarını production
/// akış sözleşmesindeki timer freeze, güvenli çıkış ve idempotent sonuç
/// davranışlarıyla kullanır.
class WordHuntLevelProductionScreen extends StatefulWidget {
  const WordHuntLevelProductionScreen({
    super.key,
    required this.level,
    required this.infoCards,
    this.backgroundAsset,
    this.presentation,
    this.routeTitle = 'Başlangıç Limanı',
    this.deferCompletionDialog = false,
    this.now,
  });

  final WordHuntLevelDefinition level;
  final List<WordHuntInfoCard> infoCards;
  final String? backgroundAsset;
  final WordHuntGameplayPresentation? presentation;
  final String routeTitle;
  final bool deferCompletionDialog;
  final DateTime Function()? now;

  @override
  State<WordHuntLevelProductionScreen> createState() =>
      _WordHuntLevelProductionScreenState();
}

class _WordHuntLevelProductionScreenState
    extends State<WordHuntLevelProductionScreen> {
  final Set<String> _foundTargets = <String>{};
  final Set<String> _foundBonus = <String>{};
  final Map<String, List<WordHuntCell>> _foundPaths =
      <String, List<WordHuntCell>>{};
  final Set<String> _unlockedInfoCards = <String>{};

  List<WordHuntCell> _selectedPath = const <WordHuntCell>[];
  WordHuntCell? _dragStart;
  int? _activePointer;
  Timer? _timer;
  Timer? _errorFeedbackTimer;
  late final DateTime _startedAt;
  int _elapsedSeconds = 0;
  int? _completionElapsedSeconds;
  int? _completionMistakes;
  int _mistakes = 0;
  bool _selectionInvalid = false;
  bool _completionDialogOpen = false;
  bool _resultDelivered = false;
  bool _exitDialogOpen = false;
  bool _allowPop = false;
  Set<WordHuntCell> _errorCells = const <WordHuntCell>{};
  String _status = _harborInstructionDefault;

  bool get _allTargetsFound =>
      _foundTargets.length >= widget.level.targetWords.length;

  bool get _allBonusFound =>
      _foundBonus.length >= widget.level.bonusWords.length;

  bool get _allWordsFound => _allTargetsFound && _allBonusFound;

  bool get _hasMeaningfulAttempt =>
      _foundTargets.isNotEmpty || _foundBonus.isNotEmpty || _mistakes > 0;

  int get _displayedElapsedSeconds =>
      _completionElapsedSeconds ?? _elapsedSeconds;

  int get _scoredMistakes => _completionMistakes ?? _mistakes;

  WordHuntGameplayPresentation get _effectivePresentation {
    final configured = widget.presentation;
    if (configured != null) return configured;
    return WordHuntGameplayPresentation(
      profileId: 'legacy-harbor-compatibility',
      scene: WordHuntGameplaySceneDefinition(
        id: 'legacy-harbor-scene',
        assetPath:
            widget.backgroundAsset ??
            WordHuntRoutePresentationProfiles.harborBackground,
        alignment: Alignment.topCenter,
      ),
      skin: WordHuntRoutePresentationProfiles.harborSkin,
    );
  }

  String get _displayedInstructionStatus {
    final status = _status;
    final successFeedback =
        status.endsWith(' bulundu!') ||
        status.startsWith('Bilgi kartı açıldı:') ||
        status.startsWith('Bonus kelime:') ||
        status.endsWith(' zaten bulundu.');
    return successFeedback ? _harborInstructionDefault : status;
  }

  DateTime _now() => widget.now?.call() ?? DateTime.now();

  int _wallClockElapsedSeconds() =>
      math.max(0, _now().difference(_startedAt).inSeconds);

  @override
  void initState() {
    super.initState();
    _startedAt = _now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _completionElapsedSeconds != null) return;
      final elapsed = _wallClockElapsedSeconds();
      if (elapsed == _elapsedSeconds) return;
      setState(() => _elapsedSeconds = elapsed);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _errorFeedbackTimer?.cancel();
    super.dispose();
  }

  void _startErrorFeedback(Iterable<WordHuntCell> cells) {
    _errorFeedbackTimer?.cancel();
    _errorCells = cells.where((cell) => !_isFound(cell)).toSet();
    if (_errorCells.isEmpty) return;
    _errorFeedbackTimer = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() => _errorCells = const <WordHuntCell>{});
    });
  }

  WordHuntCell? _cellForPosition(Offset position, Size size) {
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx >= size.width ||
        position.dy >= size.height) {
      return null;
    }
    final row = (position.dy / (size.height / widget.level.rowCount)).floor();
    final column =
        (position.dx / (size.width / widget.level.columnCount)).floor();
    return WordHuntCell(row, column);
  }

  List<WordHuntCell>? _straightPathBetween(
    WordHuntCell start,
    WordHuntCell end,
  ) {
    final rowDelta = end.row - start.row;
    final columnDelta = end.column - start.column;
    if (rowDelta == 0 && columnDelta == 0) return <WordHuntCell>[start];

    final straight =
        rowDelta == 0 ||
        columnDelta == 0 ||
        rowDelta.abs() == columnDelta.abs();
    if (!straight) return null;

    final steps = math.max(rowDelta.abs(), columnDelta.abs());
    final rowStep = rowDelta.sign;
    final columnStep = columnDelta.sign;
    return List<WordHuntCell>.generate(
      steps + 1,
      (index) => WordHuntCell(
        start.row + rowStep * index,
        start.column + columnStep * index,
      ),
      growable: false,
    );
  }

  void _pointerDown(int pointer, Offset position, Size size) {
    if (_resultDelivered || _completionDialogOpen || _activePointer != null) {
      return;
    }
    final cell = _cellForPosition(position, size);
    if (cell == null) return;
    setState(() {
      _activePointer = pointer;
      _errorFeedbackTimer?.cancel();
      _errorCells = const <WordHuntCell>{};
      _dragStart = cell;
      _selectedPath = <WordHuntCell>[cell];
      _selectionInvalid = false;
    });
  }

  void _pointerMove(int pointer, Offset position, Size size) {
    final start = _dragStart;
    if (_resultDelivered ||
        _completionDialogOpen ||
        start == null ||
        pointer != _activePointer) {
      return;
    }
    final end = _cellForPosition(position, size);
    if (end == null) return;
    final path = _straightPathBetween(start, end);
    if (path == null) {
      setState(() {
        _selectionInvalid = true;
        _selectedPath = <WordHuntCell>[start, end];
      });
      return;
    }

    final read = WordHuntPathEngine.readWord(
      grid: widget.level.grid,
      path: path,
    );
    if (!read.isValid) {
      setState(() => _selectionInvalid = true);
      return;
    }
    setState(() {
      _selectionInvalid = false;
      _selectedPath = path;
    });
  }

  void _pointerCancel(int pointer) {
    if (!mounted || pointer != _activePointer) return;
    setState(() {
      _activePointer = null;
      _selectedPath = const <WordHuntCell>[];
      _dragStart = null;
      _selectionInvalid = false;
    });
  }

  void _pointerUp(int pointer) {
    if (pointer != _activePointer) return;
    _activePointer = null;
    if (_dragStart == null || _resultDelivered || _completionDialogOpen) return;
    if (_selectionInvalid) {
      setState(() {
        _startErrorFeedback(_selectedPath);
        _selectedPath = const <WordHuntCell>[];
        _dragStart = null;
        _selectionInvalid = false;
        _status = 'Bu yol düz bir çizgi oluşturmuyor.';
      });
      return;
    }
    if (_selectedPath.isEmpty) {
      _dragStart = null;
      return;
    }

    final resolution = WordHuntInputResolver.resolve(
      level: widget.level,
      path: _selectedPath,
      foundTargetWords: _foundTargets,
      foundBonusWords: _foundBonus,
    );
    if (resolution.isIgnored) {
      setState(() {
        _selectedPath = const <WordHuntCell>[];
        _dragStart = null;
        _selectionInvalid = false;
      });
      return;
    }
    final selectedPath = resolution.path;
    final result = resolution.result!;

    setState(() {
      _selectedPath = const <WordHuntCell>[];
      _dragStart = null;

      switch (result.kind) {
        case WordHuntSelectionKind.target:
          final word = result.canonicalWord!;
          _foundTargets.add(word);
          _foundPaths[word] = selectedPath;
          final cardTitle = _unlockInfoCardFor(word);
          _status =
              cardTitle == null
                  ? '$word bulundu!'
                  : 'Bilgi kartı açıldı: $cardTitle';
          if (_allTargetsFound && _completionElapsedSeconds == null) {
            final elapsed = _wallClockElapsedSeconds();
            _elapsedSeconds = elapsed;
            _completionElapsedSeconds = elapsed;
            _completionMistakes = _mistakes;
            _timer?.cancel();
          }
        case WordHuntSelectionKind.bonus:
          final word = result.canonicalWord!;
          _foundBonus.add(word);
          _foundPaths[word] = selectedPath;
          final cardTitle = _unlockInfoCardFor(word);
          _status =
              cardTitle == null
                  ? 'Bonus kelime: $word ✨'
                  : 'Bilgi kartı açıldı: $cardTitle';
        case WordHuntSelectionKind.alreadyFound:
          _status = '${result.canonicalWord} zaten bulundu.';
        case WordHuntSelectionKind.notAWord:
          _startErrorFeedback(selectedPath);
          if (_completionElapsedSeconds == null) {
            _mistakes++;
            _status = 'Bu seçim listede yok. Başka bir yol dene.';
          } else {
            _status = 'Ana hedefler tamam. İstersen bonus kelimeyi ara.';
          }
        case WordHuntSelectionKind.invalidPath:
          _status = result.error ?? 'Bu yol geçerli değil.';
      }
    });
    _scheduleAutoCompletionIfAllWordsFound();
  }

  void _scheduleAutoCompletionIfAllWordsFound() {
    if (!_allWordsFound || _completionDialogOpen || _resultDelivered) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_allWordsFound ||
          _completionDialogOpen ||
          _resultDelivered) {
        return;
      }
      unawaited(_finishLevel());
    });
  }

  String? _unlockInfoCardFor(String word) {
    final normalized = WordHuntPathEngine.normalizeWord(word);
    for (final card in widget.infoCards) {
      if (!widget.level.infoCardIds.contains(card.id)) continue;
      if (WordHuntPathEngine.normalizeWord(card.word) == normalized) {
        _unlockedInfoCards.add(card.id);
        return card.title;
      }
    }
    return null;
  }

  Future<void> _finishLevel() async {
    if (!_allTargetsFound || _completionDialogOpen || _resultDelivered) return;
    _completionDialogOpen = true;
    final elapsed = _displayedElapsedSeconds;
    final score = WordHuntScoringEngine.calculate(
      level: widget.level,
      foundTargetCount: _foundTargets.length,
      mistakes: _scoredMistakes,
      elapsedSeconds: elapsed,
    );
    final result = WordHuntLevelPlayResult(
      levelId: widget.level.id,
      stars: score.stars,
      unlockedInfoCardIds: Set<String>.unmodifiable(_unlockedInfoCards),
      foundBonusCount: _foundBonus.length,
    );

    if (!mounted) return;
    if (widget.deferCompletionDialog) {
      _resultDelivered = true;
      Navigator.of(context).pop(result);
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xD9000812),
      builder:
          (dialogContext) => _HarborCompletionDialog(
            skin: _effectivePresentation.skin,
            routeTitle: widget.routeTitle,
            stars: score.stars,
            elapsedSeconds: elapsed,
            mistakes: _scoredMistakes,
            bonusWords: _foundBonus.toList(growable: false),
            onReturn: () => Navigator.of(dialogContext).pop(true),
          ),
    );

    if (!mounted) return;
    if (leave == true && !_resultDelivered) {
      _resultDelivered = true;
      Navigator.of(context).pop(result);
      return;
    }
    _completionDialogOpen = false;
  }

  Future<void> _requestExit() async {
    if (_allowPop || _exitDialogOpen || _resultDelivered) return;
    if (!_hasMeaningfulAttempt) {
      _popWithoutResult();
      return;
    }

    _exitDialogOpen = true;
    final leave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            key: const Key('word_hunt_production_exit_dialog'),
            title: const Text('Bölümden çıkılsın mı?'),
            content: const Text('Bu denemedeki ilerleme kaybolacak.'),
            actions: [
              TextButton(
                key: const Key('word_hunt_production_exit_continue'),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Devam Et'),
              ),
              FilledButton(
                key: const Key('word_hunt_production_exit_confirm'),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Çık'),
              ),
            ],
          ),
    );
    _exitDialogOpen = false;
    if (leave == true && mounted) _popWithoutResult();
  }

  void _popWithoutResult() {
    if (!mounted || _allowPop) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  bool _isFound(WordHuntCell cell) =>
      _foundPaths.values.any((path) => path.contains(cell));

  @override
  Widget build(BuildContext context) {
    final presentation = _effectivePresentation;
    final skin = presentation.skin;
    return PopScope<Object?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        key: const Key('word_hunt_production_screen'),
        backgroundColor: skin.scaffoldColor,
        body: Stack(
          fit: StackFit.expand,
          children: [
            KeyedSubtree(
              key: const Key('word_hunt_production_gameplay_background'),
              child: WordHuntGameplaySceneBackground(scene: presentation.scene),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, viewport) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HarborGameplayHeader(
                          skin: skin,
                          levelTitle: widget.level.displayNameOrFallback,
                          routeTitle: widget.routeTitle,
                          onBack: _requestExit,
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(
                              child: _HarborMetricPlate(
                                skin: skin,
                                icon: Icons.search_rounded,
                                iconAsset:
                                    skin.metricPanelAsset == null
                                        ? null
                                        : 'assets/word_hunt/v5_reference_assets/icon_search.png',
                                label:
                                    '${_foundTargets.length}/${widget.level.targetWords.length}',
                                key: const Key('word_hunt_production_progress'),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _HarborMetricPlate(
                                skin: skin,
                                icon: Icons.close_rounded,
                                iconAsset:
                                    skin.metricPanelAsset == null
                                        ? null
                                        : 'assets/word_hunt/v5_reference_assets/icon_mistake.png',
                                label: '$_scoredMistakes hata',
                                key: const Key('word_hunt_production_mistakes'),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _HarborMetricPlate(
                                skin: skin,
                                icon: Icons.timer_outlined,
                                iconAsset:
                                    skin.metricPanelAsset == null
                                        ? null
                                        : 'assets/word_hunt/v5_reference_assets/icon_timer.png',
                                label: '${_displayedElapsedSeconds}s',
                                textKey: const Key(
                                  'word_hunt_production_elapsed_text',
                                ),
                                key: const Key('word_hunt_production_elapsed'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Column(
                          key: const Key('word_hunt_production_word_plates'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              key: const Key(
                                'word_hunt_production_target_plates',
                              ),
                              alignment: WrapAlignment.center,
                              spacing: 5,
                              runSpacing: 5,
                              children: [
                                for (final word in widget.level.targetWords)
                                  KeyedSubtree(
                                    key: Key(
                                      'word_hunt_production_target_${word}_${_foundTargets.contains(word) ? 'found' : 'pending'}',
                                    ),
                                    child: _HarborWordPlate(
                                      skin: skin,
                                      word: word,
                                      found: _foundTargets.contains(word),
                                    ),
                                  ),
                              ],
                            ),
                            if (widget.level.bonusWords.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Wrap(
                                key: const Key(
                                  'word_hunt_production_bonus_plates',
                                ),
                                alignment: WrapAlignment.center,
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  for (final word in widget.level.bonusWords)
                                    KeyedSubtree(
                                      key: Key(
                                        'word_hunt_production_bonus_${word}_${_foundBonus.contains(word) ? 'found' : 'pending'}',
                                      ),
                                      child: _HarborWordPlate(
                                        skin: skin,
                                        word: word,
                                        found: _foundBonus.contains(word),
                                        bonus: true,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 7),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final dimension = math.min(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              );
                              final gridSize = Size.square(dimension);
                              final cellExtent =
                                  (dimension -
                                      (widget.level.columnCount - 1) *
                                          _harborGridSpacing) /
                                  widget.level.columnCount;
                              return Center(
                                child: SizedBox.square(
                                  dimension: dimension,
                                  child: Listener(
                                    key: const Key('word_hunt_production_grid'),
                                    behavior: HitTestBehavior.opaque,
                                    onPointerDown:
                                        (event) => _pointerDown(
                                          event.pointer,
                                          event.localPosition,
                                          gridSize,
                                        ),
                                    onPointerMove:
                                        (event) => _pointerMove(
                                          event.pointer,
                                          event.localPosition,
                                          gridSize,
                                        ),
                                    onPointerUp:
                                        (event) => _pointerUp(event.pointer),
                                    onPointerCancel:
                                        (event) =>
                                            _pointerCancel(event.pointer),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        IgnorePointer(
                                          child: CustomPaint(
                                            key: const Key(
                                              'word_hunt_production_found_path_connector',
                                            ),
                                            painter:
                                                _HarborFoundPathConnectorPainter(
                                                  skin: skin,
                                                  paths: _foundPaths.values
                                                      .map(
                                                        (path) => List<
                                                          WordHuntCell
                                                        >.unmodifiable(path),
                                                      )
                                                      .toList(growable: false),
                                                  cellExtent: cellExtent,
                                                  spacing: _harborGridSpacing,
                                                ),
                                          ),
                                        ),
                                        GridView.builder(
                                          padding: EdgeInsets.zero,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    widget.level.columnCount,
                                                crossAxisSpacing:
                                                    _harborGridSpacing,
                                                mainAxisSpacing:
                                                    _harborGridSpacing,
                                              ),
                                          itemCount:
                                              widget.level.rowCount *
                                              widget.level.columnCount,
                                          itemBuilder: (context, index) {
                                            final row =
                                                index ~/
                                                widget.level.columnCount;
                                            final column =
                                                index %
                                                widget.level.columnCount;
                                            final cell = WordHuntCell(
                                              row,
                                              column,
                                            );
                                            final rune = widget
                                                .level
                                                .grid[row]
                                                .runes
                                                .elementAt(column);
                                            return _HarborGridCell(
                                              skin: skin,
                                              key: Key(
                                                'word_hunt_production_cell_${row}_$column',
                                              ),
                                              row: row,
                                              column: column,
                                              letter: String.fromCharCode(rune),
                                              extent: cellExtent,
                                              selected: _selectedPath.contains(
                                                cell,
                                              ),
                                              found: _isFound(cell),
                                              error: _errorCells.contains(cell),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 7),
                        _HarborInstructionPlate(
                          skin: skin,
                          status: _displayedInstructionStatus,
                        ),
                        if (_allTargetsFound) ...[
                          const SizedBox(height: 7),
                          FilledButton.icon(
                            key: const Key('word_hunt_production_finish'),
                            onPressed:
                                _completionDialogOpen || _resultDelivered
                                    ? null
                                    : _finishLevel,
                            style: FilledButton.styleFrom(
                              backgroundColor: skin.finishButtonColor,
                              foregroundColor: skin.primaryTextColor,
                              side: BorderSide(color: skin.accentColor),
                              textStyle: const TextStyle(
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            icon: const Icon(Icons.flag_rounded),
                            label: const Text('Bölümü Tamamla'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// İzole rota ekranı. Mevcut Bilgi Rotası ana navigasyonuna bağlı değildir.
class WordHuntRoutePrototypeScreen extends StatefulWidget {
  const WordHuntRoutePrototypeScreen({
    super.key,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.infoCards = WordHuntStarterContent.infoCards,
    this.initialProgress = const WordHuntProgressSnapshot(),
  });

  final WordHuntRouteDefinition route;
  final List<WordHuntInfoCard> infoCards;
  final WordHuntProgressSnapshot initialProgress;

  @override
  State<WordHuntRoutePrototypeScreen> createState() =>
      _WordHuntRoutePrototypeScreenState();
}

class _WordHuntRoutePrototypeScreenState
    extends State<WordHuntRoutePrototypeScreen> {
  late WordHuntProgressSnapshot _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
  }

  Future<void> _openLevel(int index) async {
    if (!WordHuntRouteProgressEngine.isLevelUnlocked(
      widget.route,
      _progress,
      index,
    )) {
      return;
    }

    final level = widget.route.levels[index - 1];
    final result = await Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder:
            (_) => WordHuntLevelPrototypeScreen(
              level: level,
              infoCards: widget.infoCards,
            ),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      _progress = _progress.recordLevelResult(
        levelId: result.levelId,
        stars: result.stars,
        unlockedInfoCards: result.unlockedInfoCardIds,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeStars = WordHuntRouteProgressEngine.totalStars(
      widget.route,
      _progress,
    );
    final routeComplete = WordHuntRouteProgressEngine.isRouteComplete(
      widget.route,
      _progress,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF06142E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06142E),
        foregroundColor: Colors.white,
        title: const Text('Kelime Avı'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _RouteHeader(
              title: widget.route.title,
              stars: routeStars,
              maximumStars: widget.route.maximumStars,
              unlockStarsRequired: widget.route.unlockStarsRequired,
              complete: routeComplete,
            ),
            const SizedBox(height: 22),
            for (
              var index = 1;
              index <= widget.route.levels.length;
              index++
            ) ...[
              _RouteLevelNode(
                key: Key('word_hunt_level_$index'),
                level: widget.route.levels[index - 1],
                stars: _progress.starsFor(widget.route.levels[index - 1].id),
                unlocked: WordHuntRouteProgressEngine.isLevelUnlocked(
                  widget.route,
                  _progress,
                  index,
                ),
                onTap: () => _openLevel(index),
              ),
              if (index != widget.route.levels.length)
                Center(
                  child: Container(
                    width: 3,
                    height: 22,
                    color: const Color(0x5560A5FA),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({
    required this.title,
    required this.stars,
    required this.maximumStars,
    required this.unlockStarsRequired,
    required this.complete,
  });

  final String title;
  final int stars;
  final int maximumStars;
  final int unlockStarsRequired;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF25104B), Color(0xFF111F4D)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8B5CF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧭 1. ROTA',
            style: TextStyle(
              color: Color(0xFFFFD166),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelimeleri bul, yıldızları topla ve limanın son kapısını aç.',
            style: TextStyle(color: Color(0xFFD6D9E8), height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD166)),
              const SizedBox(width: 6),
              Text(
                '$stars / $maximumStars',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                complete ? 'ROTA TAMAMLANDI' : 'Kapı: $unlockStarsRequired ⭐',
                style: TextStyle(
                  color:
                      complete
                          ? const Color(0xFF5EEAD4)
                          : const Color(0xFFA7B0C9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteLevelNode extends StatelessWidget {
  const _RouteLevelNode({
    super.key,
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.onTap,
  });

  final WordHuntLevelDefinition level;
  final int stars;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = switch (level.type) {
      WordHuntLevelType.normal => const Color(0xFF14B8A6),
      WordHuntLevelType.challenge => const Color(0xFFF59E0B),
      WordHuntLevelType.bonus => const Color(0xFF8B5CF6),
      WordHuntLevelType.routeFinal => const Color(0xFFFFD166),
    };
    final typeLabel = switch (level.type) {
      WordHuntLevelType.normal => 'Normal',
      WordHuntLevelType.challenge => 'Meydan Okuma',
      WordHuntLevelType.bonus => 'Bonus Durak',
      WordHuntLevelType.routeFinal => 'Rota Finali',
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: unlocked ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFF102443) : const Color(0xFF0B1730),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  unlocked
                      ? accent.withValues(alpha: 0.75)
                      : const Color(0xFF26354D),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      unlocked
                          ? accent.withValues(alpha: 0.18)
                          : const Color(0xFF172238),
                  border: Border.all(
                    color: unlocked ? accent : const Color(0xFF445066),
                  ),
                ),
                child:
                    unlocked
                        ? Text(
                          '${level.index}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                        : const Icon(
                          Icons.lock_rounded,
                          color: Color(0xFF77829A),
                        ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bölüm ${level.index}',
                      style: TextStyle(
                        color:
                            unlocked ? Colors.white : const Color(0xFF77829A),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: unlocked ? accent : const Color(0xFF66738A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (stars > 0)
                Row(
                  children: List<Widget>.generate(
                    3,
                    (starIndex) => Icon(
                      Icons.star_rounded,
                      size: 20,
                      color:
                          starIndex < stars
                              ? const Color(0xFFFFD166)
                              : const Color(0xFF3B465C),
                    ),
                  ),
                )
              else if (unlocked)
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Parmağı grid üzerinde sürükleyerek kelime seçilebilen izole oyun ekranı.
class WordHuntLevelPrototypeScreen extends StatefulWidget {
  const WordHuntLevelPrototypeScreen({
    super.key,
    required this.level,
    required this.infoCards,
  });

  final WordHuntLevelDefinition level;
  final List<WordHuntInfoCard> infoCards;

  @override
  State<WordHuntLevelPrototypeScreen> createState() =>
      _WordHuntLevelPrototypeScreenState();
}

class _WordHuntLevelPrototypeScreenState
    extends State<WordHuntLevelPrototypeScreen> {
  final Set<String> _foundTargets = <String>{};
  final Set<String> _foundBonus = <String>{};
  final Map<String, List<WordHuntCell>> _foundPaths =
      <String, List<WordHuntCell>>{};
  final Set<String> _unlockedInfoCards = <String>{};

  List<WordHuntCell> _selectedPath = const <WordHuntCell>[];
  WordHuntCell? _dragStart;
  Timer? _timer;
  late DateTime _startedAt;
  int _elapsedSeconds = 0;
  int? _completionElapsedSeconds;
  int? _completionMistakes;
  int _mistakes = 0;
  String _status = 'Bir kelimenin ilk harfinden başlayıp parmağını sürükle.';

  @override
  void initState() {
    super.initState();
    _resetAttempt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _allTargetsFound =>
      _foundTargets.length >= widget.level.targetWords.length;

  int get _displayedElapsedSeconds =>
      _completionElapsedSeconds ?? _elapsedSeconds;

  int get _scoredMistakes => _completionMistakes ?? _mistakes;

  void _resetAttempt() {
    _timer?.cancel();
    _foundTargets.clear();
    _foundBonus.clear();
    _foundPaths.clear();
    _unlockedInfoCards.clear();
    _selectedPath = const <WordHuntCell>[];
    _dragStart = null;
    _elapsedSeconds = 0;
    _completionElapsedSeconds = null;
    _completionMistakes = null;
    _mistakes = 0;
    _status = 'Bir kelimenin ilk harfinden başlayıp parmağını sürükle.';
    _startedAt = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _completionElapsedSeconds != null) return;
      final elapsed = DateTime.now().difference(_startedAt).inSeconds;
      if (elapsed == _elapsedSeconds) return;
      setState(() => _elapsedSeconds = elapsed);
    });
  }

  WordHuntCell? _cellForPosition(Offset position, Size size) {
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx >= size.width ||
        position.dy >= size.height) {
      return null;
    }
    final row = (position.dy / (size.height / widget.level.rowCount)).floor();
    final column =
        (position.dx / (size.width / widget.level.columnCount)).floor();
    return WordHuntCell(row, column);
  }

  List<WordHuntCell>? _straightPathBetween(
    WordHuntCell start,
    WordHuntCell end,
  ) {
    final rowDelta = end.row - start.row;
    final columnDelta = end.column - start.column;
    if (rowDelta == 0 && columnDelta == 0) return <WordHuntCell>[start];

    final straight =
        rowDelta == 0 ||
        columnDelta == 0 ||
        rowDelta.abs() == columnDelta.abs();
    if (!straight) return null;

    final steps = math.max(rowDelta.abs(), columnDelta.abs());
    final rowStep = rowDelta.sign;
    final columnStep = columnDelta.sign;
    return List<WordHuntCell>.generate(
      steps + 1,
      (index) => WordHuntCell(
        start.row + rowStep * index,
        start.column + columnStep * index,
      ),
      growable: false,
    );
  }

  void _pointerDown(Offset position, Size size) {
    final cell = _cellForPosition(position, size);
    if (cell == null) return;
    setState(() {
      _dragStart = cell;
      _selectedPath = <WordHuntCell>[cell];
    });
  }

  void _pointerMove(Offset position, Size size) {
    if (_dragStart == null) return;
    final end = _cellForPosition(position, size);
    if (end == null) return;
    final path = _straightPathBetween(_dragStart!, end);
    if (path == null) return;

    final read = WordHuntPathEngine.readWord(
      grid: widget.level.grid,
      path: path,
    );
    if (!read.isValid) return;
    setState(() => _selectedPath = path);
  }

  void _pointerUp() {
    if (_selectedPath.isEmpty) return;

    final selectedPath = List<WordHuntCell>.unmodifiable(_selectedPath);
    final result = WordHuntPathEngine.evaluate(
      level: widget.level,
      path: selectedPath,
      foundTargetWords: _foundTargets,
      foundBonusWords: _foundBonus,
    );

    setState(() {
      _selectedPath = const <WordHuntCell>[];
      _dragStart = null;

      switch (result.kind) {
        case WordHuntSelectionKind.target:
          final word = result.canonicalWord!;
          _foundTargets.add(word);
          _foundPaths[word] = selectedPath;
          final cardTitle = _unlockInfoCardFor(word);
          _status =
              cardTitle == null
                  ? 'Harika! $word bulundu.'
                  : 'Bilgi kartı açıldı: $cardTitle';
          if (_allTargetsFound && _completionElapsedSeconds == null) {
            final elapsed = DateTime.now().difference(_startedAt).inSeconds;
            _elapsedSeconds = elapsed;
            _completionElapsedSeconds = elapsed;
            _completionMistakes = _mistakes;
            _timer?.cancel();
          }
        case WordHuntSelectionKind.bonus:
          final word = result.canonicalWord!;
          _foundBonus.add(word);
          _foundPaths[word] = selectedPath;
          final cardTitle = _unlockInfoCardFor(word);
          _status =
              cardTitle == null
                  ? 'Bonus kelime: $word ✨'
                  : 'Bilgi kartı açıldı: $cardTitle';
        case WordHuntSelectionKind.alreadyFound:
          _status = '${result.canonicalWord} zaten bulundu.';
        case WordHuntSelectionKind.notAWord:
          if (_completionElapsedSeconds == null) {
            _mistakes++;
            _status = 'Bu seçim listede yok. Başka bir yol dene.';
          } else {
            _status = 'Ana hedefler tamam. İstersen bonus kelimeyi ara.';
          }
        case WordHuntSelectionKind.invalidPath:
          _status = result.error ?? 'Bu yol geçerli değil.';
      }
    });
  }

  String? _unlockInfoCardFor(String word) {
    final normalized = WordHuntPathEngine.normalizeWord(word);
    for (final card in widget.infoCards) {
      if (!widget.level.infoCardIds.contains(card.id)) continue;
      if (WordHuntPathEngine.normalizeWord(card.word) == normalized) {
        _unlockedInfoCards.add(card.id);
        return card.title;
      }
    }
    return null;
  }

  Future<void> _finishLevel() async {
    if (!_allTargetsFound) return;
    _timer?.cancel();
    final elapsed = _displayedElapsedSeconds;
    final score = WordHuntScoringEngine.calculate(
      level: widget.level,
      foundTargetCount: _foundTargets.length,
      mistakes: _scoredMistakes,
      elapsedSeconds: elapsed,
    );

    if (!mounted) return;
    final leave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF102443),
            title: const Text(
              'Bölüm Tamamlandı',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    3,
                    (index) => Icon(
                      Icons.star_rounded,
                      size: 42,
                      color:
                          index < score.stars
                              ? const Color(0xFFFFD166)
                              : const Color(0xFF3B465C),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${elapsed}s • $_scoredMistakes hata • ${_foundBonus.length} bonus',
                  style: const TextStyle(color: Color(0xFFD6D9E8)),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Rotaya Dön'),
              ),
            ],
          ),
    );

    if (leave == true && mounted) {
      Navigator.of(context).pop(
        WordHuntLevelPlayResult(
          levelId: widget.level.id,
          stars: score.stars,
          unlockedInfoCardIds: Set<String>.unmodifiable(_unlockedInfoCards),
          foundBonusCount: _foundBonus.length,
        ),
      );
    }
  }

  bool _isFound(WordHuntCell cell) =>
      _foundPaths.values.any((path) => path.contains(cell));

  @override
  Widget build(BuildContext context) {
    final challengeSeconds = widget.level.timeLimitSeconds;

    return Scaffold(
      backgroundColor: const Color(0xFF06142E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06142E),
        foregroundColor: Colors.white,
        title: Text('Bölüm ${widget.level.index}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.search_rounded,
                      label:
                          '${_foundTargets.length}/${widget.level.targetWords.length}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.close_rounded,
                      label: '$_scoredMistakes hata',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.timer_outlined,
                      label: '${_displayedElapsedSeconds}s',
                      warning:
                          challengeSeconds != null &&
                          _displayedElapsedSeconds > challengeSeconds,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final word in widget.level.targetWords)
                    _WordChip(word: word, found: _foundTargets.contains(word)),
                  for (final word in widget.level.bonusWords)
                    _WordChip(
                      word: word,
                      found: _foundBonus.contains(word),
                      bonus: true,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              AspectRatio(
                aspectRatio: widget.level.columnCount / widget.level.rowCount,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gridSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return Listener(
                      key: const Key('word_hunt_grid'),
                      behavior: HitTestBehavior.opaque,
                      onPointerDown:
                          (event) =>
                              _pointerDown(event.localPosition, gridSize),
                      onPointerMove:
                          (event) =>
                              _pointerMove(event.localPosition, gridSize),
                      onPointerUp: (_) => _pointerUp(),
                      onPointerCancel: (_) {
                        setState(() {
                          _selectedPath = const <WordHuntCell>[];
                          _dragStart = null;
                        });
                      },
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widget.level.columnCount,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 7,
                        ),
                        itemCount:
                            widget.level.rowCount * widget.level.columnCount,
                        itemBuilder: (context, index) {
                          final row = index ~/ widget.level.columnCount;
                          final column = index % widget.level.columnCount;
                          final cell = WordHuntCell(row, column);
                          final rune = widget.level.grid[row].runes.elementAt(
                            column,
                          );
                          final selected = _selectedPath.contains(cell);
                          final found = _isFound(cell);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  selected
                                      ? const Color(0xFF8B5CF6)
                                      : found
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFF142A4C),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    selected
                                        ? const Color(0xFFD8B4FE)
                                        : found
                                        ? const Color(0xFF5EEAD4)
                                        : const Color(0xFF34527A),
                              ),
                            ),
                            child: Text(
                              String.fromCharCode(rune),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D203D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD6D9E8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_allTargetsFound)
                FilledButton.icon(
                  key: const Key('word_hunt_finish_button'),
                  onPressed: _finishLevel,
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text('Bölümü Tamamla'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HarborCompletionDialog extends StatelessWidget {
  const _HarborCompletionDialog({
    required this.skin,
    required this.routeTitle,
    required this.stars,
    required this.elapsedSeconds,
    required this.mistakes,
    required this.bonusWords,
    required this.onReturn,
  });

  final WordHuntGameplaySkin skin;
  final String routeTitle;
  final int stars;
  final int elapsedSeconds;
  final int mistakes;
  final List<String> bonusWords;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('word_hunt_production_result_dialog'),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          key: const Key('word_hunt_production_result_panel'),
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                skin.completionSurfaceTop,
                skin.completionSurfaceBottom,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: skin.accentColor, width: 1.4),
            boxShadow: <BoxShadow>[
              const BoxShadow(
                color: Color(0xCC000000),
                blurRadius: 24,
                offset: Offset(0, 11),
              ),
              BoxShadow(color: skin.connectorGlowColor, blurRadius: 14),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 46,
                height: 3,
                decoration: BoxDecoration(
                  color: skin.accentColor,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: skin.connectorGlowColor, blurRadius: 8),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Icon(skin.completionIcon, color: skin.accentColor, size: 28),
              const SizedBox(height: 6),
              Text(
                'Bölüm Tamamlandı',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: skin.primaryTextColor,
                  fontFamily: 'serif',
                  fontSize: 22,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .2,
                  shadows: const <Shadow>[
                    Shadow(color: Color(0xE0000000), blurRadius: 7),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                routeTitle,
                style: TextStyle(
                  color: skin.accentColor,
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      index < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      key: Key('word_hunt_production_result_star_${index + 1}'),
                      size: 34,
                      color:
                          index < stars
                              ? skin.accentColor
                              : skin.secondaryTextColor.withValues(alpha: .45),
                      shadows:
                          index < stars
                              ? <Shadow>[
                                Shadow(
                                  color: skin.connectorGlowColor,
                                  blurRadius: 10,
                                ),
                              ]
                              : const <Shadow>[],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: skin.surfaceBorderColor),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _HarborResultMetric(
                      skin: skin,
                      icon: Icons.timer_outlined,
                      value: '$elapsedSeconds saniye',
                      valueKey: const Key(
                        'word_hunt_production_result_elapsed',
                      ),
                      label: 'Süre',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _HarborResultMetric(
                      skin: skin,
                      icon: Icons.close_rounded,
                      value: '$mistakes hata',
                      valueKey: const Key(
                        'word_hunt_production_result_mistakes',
                      ),
                      label: 'Hata',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _HarborResultMetric(
                      skin: skin,
                      icon: Icons.auto_awesome_rounded,
                      value: '${bonusWords.length}',
                      label: 'Bonus',
                    ),
                  ),
                ],
              ),
              if (bonusWords.isNotEmpty) ...<Widget>[
                const SizedBox(height: 9),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: skin.bonusSurfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: skin.surfaceBorderColor),
                  ),
                  child: Text(
                    '✦ Bonus: ${bonusWords.join(' • ')}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: skin.accentColor,
                      fontFamily: 'serif',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  key: const Key('word_hunt_production_return_route'),
                  onPressed: onReturn,
                  style: FilledButton.styleFrom(
                    backgroundColor: skin.finishButtonColor,
                    foregroundColor: skin.primaryTextColor,
                    side: BorderSide(color: skin.accentColor, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  icon: const Icon(Icons.route_rounded, size: 18),
                  label: const Text('Rotaya Dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HarborResultMetric extends StatelessWidget {
  const _HarborResultMetric({
    required this.skin,
    required this.icon,
    required this.value,
    required this.label,
    this.valueKey,
  });

  final WordHuntGameplaySkin skin;
  final IconData icon;
  final String value;
  final String label;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      decoration: BoxDecoration(
        color: skin.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: skin.surfaceBorderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: skin.accentColor, size: 16),
          const SizedBox(height: 3),
          Text(
            value,
            key: valueKey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: skin.primaryTextColor,
              fontFamily: 'serif',
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: skin.secondaryTextColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HarborGameplayHeader extends StatelessWidget {
  const _HarborGameplayHeader({
    required this.skin,
    required this.levelTitle,
    required this.routeTitle,
    required this.onBack,
  });

  final WordHuntGameplaySkin skin;
  final String levelTitle;
  final String routeTitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final backAsset = skin.backIconAsset;
    return SizedBox(
      height: 62,
      child: Row(
        children: [
          IconButton(
            key: const Key('word_hunt_production_back'),
            onPressed: onBack,
            style: IconButton.styleFrom(
              minimumSize: const Size(42, 42),
              padding: EdgeInsets.zero,
              foregroundColor: skin.primaryTextColor,
            ),
            icon:
                backAsset == null
                    ? const Icon(Icons.arrow_back_rounded)
                    : Image.asset(
                      backAsset,
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  levelTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: skin.primaryTextColor,
                    fontFamily: 'serif',
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .2,
                    shadows: const [
                      Shadow(color: Color(0xE0000000), blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  routeTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: skin.secondaryTextColor,
                    fontFamily: 'serif',
                    fontSize: 13.5,
                    letterSpacing: .25,
                    shadows: const [
                      Shadow(color: Color(0xCC000000), blurRadius: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HarborMetricPlate extends StatelessWidget {
  const _HarborMetricPlate({
    super.key,
    required this.skin,
    required this.icon,
    required this.label,
    this.iconAsset,
    this.textKey,
  });

  final WordHuntGameplaySkin skin;
  final IconData icon;
  final String? iconAsset;
  final String label;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final panelAsset = skin.metricPanelAsset;
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: panelAsset == null ? skin.surfaceColor : null,
        image:
            panelAsset == null
                ? null
                : DecorationImage(
                  image: AssetImage(panelAsset),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
        borderRadius: BorderRadius.circular(12),
        border:
            panelAsset == null
                ? Border.all(color: skin.surfaceBorderColor)
                : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconAsset == null)
            Icon(icon, size: 18, color: skin.accentColor)
          else
            Image.asset(
              iconAsset!,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              key: textKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: skin.primaryTextColor,
                fontFamily: 'serif',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                shadows: const <Shadow>[
                  Shadow(color: Color(0xCC000000), blurRadius: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HarborWordPlate extends StatelessWidget {
  const _HarborWordPlate({
    required this.skin,
    required this.word,
    required this.found,
    this.bonus = false,
  });

  final WordHuntGameplaySkin skin;
  final String word;
  final bool found;
  final bool bonus;

  @override
  Widget build(BuildContext context) {
    final asset = bonus ? skin.bonusPlateAsset : skin.targetPlateAsset;
    final surface = bonus ? skin.bonusSurfaceColor : skin.targetSurfaceColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      constraints: const BoxConstraints(minHeight: 34),
      padding: EdgeInsets.fromLTRB(bonus && asset != null ? 30 : 12, 6, 12, 6),
      decoration: BoxDecoration(
        color:
            asset == null ? (found ? skin.foundSurfaceColor : surface) : null,
        image:
            asset == null
                ? null
                : DecorationImage(
                  image: AssetImage(asset),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  colorFilter:
                      found
                          ? ColorFilter.mode(
                            skin.foundSurfaceColor,
                            BlendMode.color,
                          )
                          : null,
                ),
        borderRadius: BorderRadius.circular(16),
        border:
            asset == null
                ? Border.all(
                  color: found ? skin.accentColor : skin.surfaceBorderColor,
                )
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bonus)
            SizedBox(
              key: Key('word_hunt_production_bonus_icon_$word'),
              width: asset == null ? 12 : 0,
              height: asset == null ? 12 : 0,
              child:
                  asset == null
                      ? Icon(
                        Icons.auto_awesome_rounded,
                        size: 12,
                        color: skin.accentColor,
                      )
                      : null,
            ),
          if (bonus && asset == null) const SizedBox(width: 4),
          Text(
            word,
            style: TextStyle(
              color: found ? skin.accentColor : skin.primaryTextColor,
              fontFamily: 'serif',
              fontSize: 12.5,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
              shadows: const <Shadow>[
                Shadow(color: Color(0xD0000000), blurRadius: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HarborFoundPathConnectorPainter extends CustomPainter {
  const _HarborFoundPathConnectorPainter({
    required this.skin,
    required this.paths,
    required this.cellExtent,
    required this.spacing,
  });

  final WordHuntGameplaySkin skin;
  final List<List<WordHuntCell>> paths;
  final double cellExtent;
  final double spacing;

  Offset _centerFor(WordHuntCell cell) {
    final stride = cellExtent + spacing;
    return Offset(
      cell.column * stride + cellExtent / 2,
      cell.row * stride + cellExtent / 2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;
    final glowPaint =
        Paint()
          ..color = skin.connectorGlowColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(10, cellExtent * .70)
          ..strokeCap = StrokeCap.butt;
    final bridgePaint =
        Paint()
          ..color = skin.connectorColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(8, cellExtent * .58)
          ..strokeCap = StrokeCap.butt;

    for (final path in paths) {
      if (path.length < 2) continue;
      for (var index = 0; index < path.length - 1; index++) {
        final startCenter = _centerFor(path[index]);
        final endCenter = _centerFor(path[index + 1]);
        final delta = endCenter - startCenter;
        final distance = delta.distance;
        if (distance <= 0) continue;
        final direction = delta / distance;
        final overlap = cellExtent * .40;
        canvas.drawLine(
          startCenter + direction * overlap,
          endCenter - direction * overlap,
          glowPaint,
        );
        canvas.drawLine(
          startCenter + direction * overlap,
          endCenter - direction * overlap,
          bridgePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HarborFoundPathConnectorPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.cellExtent != cellExtent ||
        oldDelegate.spacing != spacing ||
        oldDelegate.skin.id != skin.id;
  }
}

class _HarborGridCell extends StatelessWidget {
  const _HarborGridCell({
    super.key,
    required this.skin,
    required this.row,
    required this.column,
    required this.letter,
    required this.extent,
    required this.selected,
    required this.found,
    required this.error,
  });

  final WordHuntGameplaySkin skin;
  final int row;
  final int column;
  final String letter;
  final double extent;
  final bool selected;
  final bool found;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final active = selected || found;
    final asset = active ? skin.gridSelectedAsset : skin.gridIdleAsset;
    final fill =
        error
            ? skin.gridErrorColor
            : found
            ? skin.gridFoundColor
            : selected
            ? skin.gridSelectedColor
            : skin.gridIdleColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: asset == null ? fill : null,
        borderRadius: BorderRadius.circular(math.max(6, extent * .14)),
        border:
            asset == null
                ? Border.all(
                  color: active ? skin.accentColor : skin.surfaceBorderColor,
                )
                : null,
        boxShadow:
            active
                ? <BoxShadow>[
                  BoxShadow(
                    color: skin.connectorGlowColor,
                    blurRadius: 3,
                    spreadRadius: .2,
                  ),
                ]
                : const <BoxShadow>[],
      ),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (asset != null)
            ClipRect(
              child: Transform.scale(
                scale: _harborCellVisualScale,
                child: Image.asset(
                  asset,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          if (error)
            DecoratedBox(
              decoration: BoxDecoration(
                color: skin.gridErrorColor.withValues(alpha: .70),
                borderRadius: BorderRadius.circular(math.max(6, extent * .14)),
                border: Border.all(color: skin.accentColor, width: 1.2),
              ),
            ),
          Center(
            child: Text(
              letter,
              style: TextStyle(
                color: skin.gridTextColor,
                fontFamily: 'serif',
                fontSize: (extent * .46).clamp(17, 24),
                fontWeight: FontWeight.w900,
                height: 1,
                shadows: const <Shadow>[
                  Shadow(color: Color(0xE0000000), blurRadius: 3),
                ],
              ),
            ),
          ),
          if (error)
            IgnorePointer(
              child: SizedBox.expand(
                key: Key('word_hunt_production_error_cell_${row}_$column'),
              ),
            ),
        ],
      ),
    );
  }
}

class _HarborInstructionPlate extends StatelessWidget {
  const _HarborInstructionPlate({required this.skin, required this.status});

  final WordHuntGameplaySkin skin;
  final String status;

  @override
  Widget build(BuildContext context) {
    final asset = skin.instructionPanelAsset;
    return Container(
      key: const Key('word_hunt_production_instruction_plate'),
      height: 50,
      decoration: BoxDecoration(
        color: asset == null ? skin.instructionSurfaceColor : null,
        image:
            asset == null
                ? null
                : DecorationImage(
                  image: AssetImage(asset),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
        borderRadius: BorderRadius.circular(14),
        border:
            asset == null ? Border.all(color: skin.surfaceBorderColor) : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: asset == null ? 14 : 48,
        vertical: 7,
      ),
      child: Center(
        child: Text(
          status,
          key: const Key('word_hunt_production_status'),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: skin.primaryTextColor,
            fontFamily: 'serif',
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w800,
            shadows: const <Shadow>[
              Shadow(color: Color(0xD0000000), blurRadius: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    this.warning = false,
  });

  final IconData icon;
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? const Color(0xFFF97316) : const Color(0xFF22D3EE);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF102443),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.found,
    this.bonus = false,
  });

  final String word;
  final bool found;
  final bool bonus;

  @override
  Widget build(BuildContext context) {
    final accent = bonus ? const Color(0xFFFFD166) : const Color(0xFF5EEAD4);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: found ? accent.withValues(alpha: 0.2) : const Color(0xFF102443),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: found ? accent : const Color(0xFF354966)),
      ),
      child: Text(
        '${bonus ? '✦ ' : ''}$word',
        style: TextStyle(
          color: found ? accent : const Color(0xFFD6D9E8),
          fontWeight: FontWeight.w800,
          decoration: found ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
