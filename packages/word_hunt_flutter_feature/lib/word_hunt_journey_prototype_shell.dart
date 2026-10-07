import 'package:flutter/material.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_domain/word_hunt_journey_progress.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_codec.dart';
import 'word_hunt_infinite_journey_map_screen.dart';
import 'word_hunt_journey_map_state_adapter.dart';
import 'word_hunt_journey_theme.dart';
import 'word_hunt_journey_theme_demo.dart';
import 'package:word_hunt_content/word_hunt_journey_gameplay_resolver.dart';
import 'word_hunt_journey_gameplay_host.dart';

/// Independent widget entry. Does not connect to production navigation/storage.
class WordHuntJourneyPrototypeShell extends StatefulWidget {
  const WordHuntJourneyPrototypeShell({
    super.key,
    required this.catalog,
    required this.repository,
    this.themeSchedule,
    this.syntheticProof = false,
    this.gameplayNow,
  });
  final PublishedJourneyCatalog catalog;
  final JourneySaveRepository repository;
  final JourneyThemeSchedule? themeSchedule;

  /// Explicit old Slice 3/4 test harness only. Default Journey flow is real.
  final bool syntheticProof;
  final DateTime Function()? gameplayNow;
  @override
  State<WordHuntJourneyPrototypeShell> createState() => _ShellState();
}

class _ShellState extends State<WordHuntJourneyPrototypeShell> {
  WordHuntJourneyProgress? _progress;
  final _map = WordHuntJourneyMapController();
  final _gameplay = JourneyGameplayResolver();
  bool _onMap = false, _busy = false, _loading = true, _opening = false;
  int _anchor = 1, _totalStars = 0;
  String? _feedback;
  JourneyMapStateAdapter get adapter => JourneyMapStateAdapter(_progress!);
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final save = await widget.repository.load();
      if (!mounted) return;
      setState(() {
        _progress = WordHuntJourneyProgress(
          catalog: widget.catalog,
          save: save,
        );
        _totalStars = _progress!.snapshot.totalStars;
        _loading = false;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _feedback = 'Kayıt yüklenemedi. Tekrar dene.';
        });
    }
  }

  Future<bool> _persist(void Function() mutation) async {
    if (_busy) return false;
    final before = _progress!.snapshot;
    setState(() {
      _busy = true;
      _feedback = null;
    });
    try {
      mutation();
      await widget.repository.save(_progress!.snapshot);
      if (!mounted) return false;
      setState(() {
        _busy = false;
        _totalStars = _progress!.snapshot.totalStars;
      });
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _progress = WordHuntJourneyProgress(
          catalog: widget.catalog,
          save: before,
        );
        _busy = false;
        _feedback = 'Kayıt yapılamadı. Tekrar dene.';
      });
      return false;
    }
  }

  void _continue() {
    final next = adapter.currentOrdinal;
    if (next == null) {
      _endFeedback();
      return;
    }
    _openMap(next);
  }

  void _endFeedback() => setState(() {
    _feedback =
        widget.catalog.publishedLevelCount == 0
            ? 'Yeni bölümler yakında.'
            : 'Şimdilik tüm bölümleri tamamladın. Yeni bölümler yakında.';
  });
  void _openMap(int ordinal) {
    setState(() {
      _onMap = true;
      _anchor = ordinal;
      _feedback = null;
    });
    _map.jumpToLevel(ordinal);
  }

  void _resumeMap() {
    final ordinal = adapter.initialOrdinal(preferLastViewed: true);
    if (ordinal == null) {
      _endFeedback();
      return;
    }
    _openMap(ordinal);
  }

  Future<void> _goTo() async {
    final ordinal = await showDialog<int>(
      context: context,
      builder:
          (_) => _GoToLevelDialog(
            publishedCount: widget.catalog.publishedLevelCount,
            eligible: adapter.canJumpToOrdinal,
          ),
    );
    if (!mounted || ordinal == null || !adapter.canJumpToOrdinal(ordinal))
      return;
    // Jump itself does not write. Last-viewed persistence is a separate policy.
    if (!await _persist(
      () => _progress!.recordLastViewed(journeyStableId(ordinal)),
    ))
      return;
    if (!mounted) return;
    _anchor = ordinal;
    adapter.jumpToOrdinal(_map, ordinal);
  }

  Future<void> _openLevel(int ordinal) async {
    if (_opening || _busy || !adapter.canJumpToOrdinal(ordinal)) return;
    final record = widget.catalog.recordForOrdinal(ordinal)!;
    final payload = _gameplay.resolve(record);
    if (!widget.syntheticProof && payload == null) {
      setState(() => _feedback = 'Bu bölümün oyun içeriği henüz hazır değil.');
      return;
    }
    _opening = true;
    try {
      if (!await _persist(
        () => _progress!.recordLastViewed(journeyStableId(ordinal)),
      ))
        return;
      if (!mounted) return;
      _anchor = ordinal;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder:
              (_) =>
                  !widget.syntheticProof
                      ? WordHuntJourneyGameplayHost(
                        record: record,
                        level: payload!,
                        now: widget.gameplayNow,
                        onCompletion:
                            (result) => _persist(() {
                              if (!result.completed ||
                                  result.stableLevelId != record.stableId) {
                                throw StateError('Unexpected Journey outcome.');
                              }
                              _progress!.recordCompletion(
                                result.stableLevelId,
                                stars: result.earnedStars,
                                bonusFound: result.bonusFoundCount,
                              );
                            }),
                      )
                      : WordHuntJourneySyntheticLevelScreen(
                        ordinal: ordinal,
                        theme: (widget.themeSchedule ??
                                JourneyThemeSchedule.synthetic)
                            .themeForOrdinal(ordinal),
                        onComplete:
                            (stars, bonus) => _persist(
                              () => _progress!.recordCompletion(
                                journeyStableId(ordinal),
                                stars: stars,
                                bonusFound: bonus,
                              ),
                            ),
                      ),
        ),
      );
      if (!mounted) return;
      setState(() {});
      _map.jumpToLevel(_anchor);
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_progress == null)
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_feedback ?? ''),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                    });
                    _load();
                  },
                  child: const Text('TEKRAR DENE'),
                ),
              ],
            ),
          ),
        ),
      );
    return PopScope(
      canPop: !_onMap,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy)
          setState(() {
            _onMap = false;
            _feedback = null;
          });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelime Avı'),
          automaticallyImplyLeading: false,
          leading:
              _onMap
                  ? IconButton(
                    key: const Key('journey_back'),
                    tooltip: 'Geri',
                    onPressed:
                        _busy
                            ? null
                            : () => setState(() {
                              _onMap = false;
                              _feedback = null;
                            }),
                    icon: const Icon(Icons.arrow_back),
                  )
                  : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_feedback != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(_feedback!, key: const Key('journey_feedback')),
                  ),
                ),
              if (_onMap)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          key: const Key('journey_map_continue'),
                          onPressed: _busy ? null : _continue,
                          child: const Text('DEVAM ET'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('journey_go_to'),
                          onPressed: _busy ? null : _goTo,
                          child: const Text('BÖLÜME GİT'),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: AbsorbPointer(
                  absorbing: _busy,
                  child:
                      _onMap
                          ? WordHuntInfiniteJourneyMapScreen(
                            publishedLevelCount: adapter.publishedLevelCount,
                            initialOrdinal: _anchor,
                            currentOrdinal: adapter.currentOrdinal ?? _anchor,
                            controller: _map,
                            stateForOrdinal: adapter.presentationForOrdinal,
                            onLevelTap: _openLevel,
                            showContinueControl: false,
                            themeSchedule:
                                widget.themeSchedule ??
                                JourneyThemeSchedule.synthetic,
                          )
                          : Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    adapter.currentOrdinal == null
                                        ? 'Yeni bölümler yakında'
                                        : 'Bölüm ${adapter.currentOrdinal}',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Toplam yıldız: $_totalStars'),
                                  Text(
                                    'Yayınlanan son bölüm: ${adapter.publishedLevelCount}',
                                  ),
                                  const SizedBox(height: 24),
                                  FilledButton(
                                    key: const Key('journey_home_continue'),
                                    onPressed: _continue,
                                    child: const Text('DEVAM ET'),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    key: const Key('journey_home_map'),
                                    onPressed: _resumeMap,
                                    child: const Text('HARİTAYI AÇ'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                ),
              ),
              if (_busy) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoToLevelDialog extends StatefulWidget {
  const _GoToLevelDialog({
    required this.publishedCount,
    required this.eligible,
  });
  final int publishedCount;
  final bool Function(int) eligible;
  @override
  State<_GoToLevelDialog> createState() => _GoToState();
}

class _GoToState extends State<_GoToLevelDialog> {
  final input = TextEditingController();
  String? error;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void submit() {
    final ordinal = int.tryParse(input.text.trim());
    final message =
        ordinal == null || ordinal < 1
            ? 'Geçerli bir bölüm numarası gir.'
            : ordinal > widget.publishedCount
            ? 'Bu bölüm henüz yayınlanmadı.'
            : !widget.eligible(ordinal)
            ? 'Bu bölüm henüz açılmadı.'
            : null;
    if (message != null) {
      setState(() {
        error = message;
      });
      return;
    }
    Navigator.pop(context, ordinal);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Bölüme Git'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: const Key('journey_ordinal_input'),
          controller: input,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Bölüm numarası'),
          onSubmitted: (_) => submit(),
        ),
        if (error != null) Semantics(liveRegion: true, child: Text(error!)),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('İPTAL'),
      ),
      FilledButton(
        key: const Key('journey_jump_submit'),
        onPressed: submit,
        child: const Text('GİT'),
      ),
    ],
  );
}

/// Progression proof only: not production gameplay or an artwork preview.
class WordHuntJourneySyntheticLevelScreen extends StatefulWidget {
  const WordHuntJourneySyntheticLevelScreen({
    super.key,
    required this.ordinal,
    required this.onComplete,
    this.theme,
  });
  final int ordinal;
  final JourneyThemeDefinition? theme;
  final Future<bool> Function(int stars, int bonus) onComplete;
  @override
  State<WordHuntJourneySyntheticLevelScreen> createState() => _SyntheticState();
}

class _SyntheticState extends State<WordHuntJourneySyntheticLevelScreen> {
  int stars = 1;
  bool busy = false;
  String? error;
  final bonus = TextEditingController(text: '0');
  @override
  void dispose() {
    bonus.dispose();
    super.dispose();
  }

  Future<void> finish() async {
    if (busy) return;
    final value = int.tryParse(bonus.text.trim());
    if (value == null || value < 0) {
      setState(() {
        error = 'Geçerli bir bonus sayısı gir.';
      });
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    final saved = await widget.onComplete(stars, value);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() {
        busy = false;
        error = 'Kayıt yapılamadı. Tekrar dene.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(
        title: Text('Bölüm ${widget.ordinal}'),
        actions: [
          if (widget.theme != null)
            IconButton(
              tooltip: 'Sentetik okunabilirlik demosu',
              icon: const Icon(Icons.palette_outlined),
              onPressed:
                  () => showDialog<void>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text(widget.theme!.id),
                          content: SizedBox(
                            width: 300,
                            height: 240,
                            child: JourneyThemeReadabilityDemo(
                              theme: widget.theme!,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('KAPAT'),
                            ),
                          ],
                        ),
                  ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bölümü tamamla', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 16),
                for (var n = 1; n <= 3; n++)
                  Semantics(
                    selected: stars == n,
                    child: OutlinedButton(
                      key: Key('journey_stars_$n'),
                      onPressed:
                          busy
                              ? null
                              : () => setState(() {
                                stars = n;
                              }),
                      child: Text('$n yıldızla bitir'),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('journey_bonus_input'),
                  controller: bonus,
                  enabled: !busy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bonus sayısı'),
                ),
                if (error != null)
                  Semantics(liveRegion: true, child: Text(error!)),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('journey_finish'),
                  onPressed: busy ? null : finish,
                  child: const Text('BİTİR'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
