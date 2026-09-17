import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'word_hunt_deferred_completion_level_screen.dart';
import 'word_hunt_gokyuzu_gameplay_backgrounds.dart';
import 'word_hunt_gokyuzu_master_art_screen.dart';
import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_progress_codec.dart';
import 'word_hunt_reference_route_screen.dart';
import 'word_hunt_route_catalog.dart';
import 'word_hunt_route_completion_dialogs.dart';
import 'word_hunt_route_rewards.dart';
import 'word_hunt_route_selector.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_screens.dart';
import 'word_hunt_starter_content.dart';
import 'word_hunt_themed_production_route_screen.dart';

/// Ana Bilgi Rotası uygulamasından Kelime Avı production akışına girilen ekran.
///
/// Rota seçimi ve route presentation kararı [WordHuntRouteCatalog] verisiyle
/// çözülür. Bu ekran rota adına göre renderer seçmez.
///
/// Mevcut production sözleşmesi:
/// - Başlangıç Limanı her zaman açıktır ve mevcut reference renderer'ı kullanır.
/// - Gökyüzü Adaları 18 Başlangıç Limanı yıldızında açılır ve mevcut MASTER ART
///   renderer/gameplay arka planlarını kullanır.
/// - Orman Yolu, Başlangıç Limanı 10. bölüm tamamlandığında açılır ve generic
///   themed reusable renderer ile production Orman skinini kullanır.
///
/// Doğrudan belirli bir rota gösterilecek QA/test senaryolarında
/// [routeSelectionEnabled] false verilebilir. Catalog'da bilinen bir rota ise
/// mevcut production presentation'ı korunur; bilinmeyen QA rotası güvenli legacy
/// reference renderer'a düşer.
class WordHuntProductionEntryScreen extends StatefulWidget {
  const WordHuntProductionEntryScreen({
    super.key,
    this.ownerUid,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.infoCards = WordHuntStarterContent.infoCards,
    this.routeSelectionEnabled = true,
  });

  final String? ownerUid;
  final WordHuntRouteDefinition route;
  final List<WordHuntInfoCard> infoCards;
  final bool routeSelectionEnabled;

  @override
  State<WordHuntProductionEntryScreen> createState() =>
      _WordHuntProductionEntryScreenState();
}

class _WordHuntProductionEntryScreenState
    extends State<WordHuntProductionEntryScreen> {
  SharedPreferencesAsync? _preferencesInstance;

  SharedPreferencesAsync get _preferences =>
      _preferencesInstance ??= SharedPreferencesAsync();

  WordHuntProgressSnapshot _progress = const WordHuntProgressSnapshot();
  WordHuntRouteDefinition? _selectedRoute;
  List<WordHuntInfoCard>? _selectedInfoCards;
  bool _loading = true;

  bool get _catalogMode =>
      widget.routeSelectionEnabled &&
      widget.route.id == WordHuntStarterContent.baslangicLimani.id;

  WordHuntRouteDefinition get _activeRoute => _selectedRoute ?? widget.route;

  List<WordHuntInfoCard> get _activeInfoCards =>
      _selectedInfoCards ?? widget.infoCards;

  WordHuntRouteCatalogEntry? get _activeCatalogEntry =>
      WordHuntRouteCatalog.entryForRouteId(_activeRoute.id);

  WordHuntRoutePresentationKind get _activePresentationKind =>
      _activeCatalogEntry?.presentationKind ??
      WordHuntRoutePresentationKind.referenceRoute;

  String get _ownerScope => WordHuntProgressCodec.scopeForUid(widget.ownerUid);

  String get _storageKey =>
      WordHuntProgressCodec.storageKeyForUid(widget.ownerUid);

  String get _kristalRevealSeenKey =>
      'bilgi_rotasi_word_hunt_seen_kristal_vadisi_reveal_v1_$_ownerScope';

  @override
  void initState() {
    super.initState();
    if (!_catalogMode) {
      _selectedRoute = widget.route;
      _selectedInfoCards = widget.infoCards;
    }
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    var loaded = const WordHuntProgressSnapshot();
    var shouldPersistBackfill = false;
    var shouldRevealHistoricalKristal = false;
    try {
      final raw = await _preferences.getString(_storageKey);
      final hadPersistedProgress = raw != null && raw.trim().isNotEmpty;
      if (hadPersistedProgress) {
        loaded = WordHuntProgressCodec.decode(
          raw,
          expectedOwnerScope: _ownerScope,
        );
      }

      if (_catalogMode && hadPersistedProgress) {
        final kristal = WordHuntRouteCatalog.kristal;
        final kristalHasProgress = kristal.route.levels.any(
          (level) => loaded.starsFor(level.id) > 0,
        );
        final revealSeen =
            await _preferences.getBool(_kristalRevealSeenKey) ?? false;
        shouldRevealHistoricalKristal =
            kristal.isUnlocked(loaded) && !kristalHasProgress && !revealSeen;
        if (shouldRevealHistoricalKristal) {
          await _preferences.setBool(_kristalRevealSeenKey, true);
        }
      }
      final backfilled = WordHuntRouteRewardEngine.backfillCompletedRoutes(
        loaded,
      );
      shouldPersistBackfill = !identical(backfilled, loaded);
      loaded = backfilled;
    } catch (_) {
      // Bozuk veya desteklenmeyen yerel veri / storage katmanı Kelime Avı'nın
      // açılmasını engellemez; varsayılan boş progression ile devam edilir.
      loaded = const WordHuntProgressSnapshot();
      shouldPersistBackfill = false;
      shouldRevealHistoricalKristal = false;
    }

    if (!mounted) return;
    setState(() {
      _progress = loaded;
      _loading = false;
    });
    if (shouldPersistBackfill) {
      await _saveProgress(loaded);
    }
    if (shouldRevealHistoricalKristal && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni rota açıldı: Kristal Vadisi')),
        );
      });
    }
  }

  Future<void> _markKristalRevealSeenForNextRoute(
    WordHuntRouteDefinition completedRoute,
  ) async {
    final next = WordHuntRouteRewardEngine.nextCatalogEntry(completedRoute);
    if (next?.cardKey != WordHuntRouteCatalog.kristal.cardKey) return;
    try {
      await _preferences.setBool(_kristalRevealSeenKey, true);
    } catch (_) {
      // Bu marker progression değildir; yazılamaması completion'ı engellemez.
    }
  }

  Future<void> _saveProgress(WordHuntProgressSnapshot progress) async {
    try {
      await _preferences.setString(
        _storageKey,
        WordHuntProgressCodec.encode(progress, ownerScope: _ownerScope),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelime Avı ilerlemesi bu cihazda kaydedilemedi.'),
        ),
      );
    }
  }

  void _openCatalogRoute(WordHuntRouteCatalogEntry entry) {
    if (!entry.isUnlocked(_progress)) {
      final message = _lockedRouteMessage(entry);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    setState(() {
      _selectedRoute = entry.route;
      _selectedInfoCards = entry.infoCards;
    });
  }

  String _lockedRouteMessage(WordHuntRouteCatalogEntry entry) {
    final rule = entry.unlockRule;
    final prerequisite = rule.prerequisiteRoute;
    if (prerequisite == null) {
      return '${entry.route.title} henüz açık değil.';
    }

    switch (rule.kind) {
      case WordHuntRouteUnlockKind.always:
        return '${entry.route.title} henüz açık değil.';
      case WordHuntRouteUnlockKind.routeStars:
        return '${entry.route.title} için ${rule.requiredStars} '
            '${prerequisite.title} yıldızı gerekli.';
      case WordHuntRouteUnlockKind.routeComplete:
        return '${entry.route.title} için ${prerequisite.title} '
            '${prerequisite.levels.length}. bölümü tamamlaman gerekli.';
    }
  }

  void _leaveRoute() {
    if (_catalogMode) {
      setState(() {
        _selectedRoute = null;
        _selectedInfoCards = null;
      });
      return;
    }
    Navigator.of(context).maybePop();
  }

  String? _gameplayBackgroundForLevel(int levelIndex) {
    switch (_activePresentationKind) {
      case WordHuntRoutePresentationKind.referenceRoute:
      case WordHuntRoutePresentationKind.themedReusable:
        return null;
      case WordHuntRoutePresentationKind.gokyuzuMasterArt:
        return WordHuntGokyuzuGameplayBackgrounds.forLevel(levelIndex);
    }
  }

  Future<void> _openLevel(int levelIndex) async {
    final route = _activeRoute;
    if (!WordHuntRouteProgressEngine.isLevelUnlocked(
      route,
      _progress,
      levelIndex,
    )) {
      return;
    }

    final beforeProgress = _progress;
    final beforeRouteComplete = WordHuntRouteProgressEngine.isRouteComplete(
      route,
      beforeProgress,
    );
    final level = route.levels[levelIndex - 1];
    final deferFinalCompletion =
        level.type == WordHuntLevelType.routeFinal && !beforeRouteComplete;
    final result = await Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder: (_) {
          final backgroundAsset = _gameplayBackgroundForLevel(level.index);
          if (deferFinalCompletion) {
            return WordHuntDeferredCompletionLevelScreen(
              level: level,
              infoCards: _activeInfoCards,
              backgroundAsset: backgroundAsset,
              routeTitle: route.title,
            );
          }
          return WordHuntLevelProductionScreen(
            level: level,
            infoCards: _activeInfoCards,
            backgroundAsset: backgroundAsset,
            routeTitle: route.title,
          );
        },
      ),
    );

    if (result == null || !mounted) return;

    final transition = WordHuntRouteRewardEngine.recordLevelResult(
      route: route,
      progress: beforeProgress,
      levelId: result.levelId,
      stars: result.stars,
      unlockedInfoCards: result.unlockedInfoCardIds,
    );
    final next = transition.progress;
    setState(() => _progress = next);
    await _saveProgress(next);
    if (!mounted) return;

    if (transition.routeCompletedNow) {
      await _markKristalRevealSeenForNextRoute(route);
      await _showRouteCompletionCeremony(route, next);
      return;
    }

    if (level.type == WordHuntLevelType.routeFinal &&
        !beforeRouteComplete &&
        !transition.afterRouteComplete) {
      await _showFinalIncomplete(route, next);
    }
  }

  Future<void> _showRouteCompletionCeremony(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) async {
    final reward = WordHuntRouteRewardCatalog.forRoute(route);
    if (reward == null || !mounted) return;

    final catalogEntry = WordHuntRouteCatalog.entryForRouteId(route.id);
    final nextCandidate = WordHuntRouteRewardEngine.nextCatalogEntry(route);
    final nextEntry =
        nextCandidate != null && nextCandidate.isUnlocked(progress)
        ? nextCandidate
        : null;
    final routeColors =
        catalogEntry?.colors ??
        const <Color>[Color(0xFF17324B), Color(0xFF081623)];

    final action = await showDialog<WordHuntRouteCompletionAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WordHuntRouteCompletionDialog(
        route: route,
        reward: reward,
        totalStars: WordHuntRouteProgressEngine.totalStars(route, progress),
        routeColors: routeColors,
        nextRouteTitle: nextEntry?.route.title,
      ),
    );

    if (!mounted) return;
    if (action == WordHuntRouteCompletionAction.showRouteSelector &&
        _catalogMode) {
      setState(() {
        _selectedRoute = null;
        _selectedInfoCards = null;
      });
    }
  }

  Future<void> _showFinalIncomplete(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WordHuntFinalIncompleteDialog(
        route: route,
        totalStars: WordHuntRouteProgressEngine.totalStars(route, progress),
      ),
    );
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('word_hunt_route_help_dialog'),
        title: const Text('Harita Rehberi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _GuideLine('Bölümleri sırayla tamamla.'),
            _GuideLine('Her bölümden en fazla 3 yıldız kazanılabilir.'),
            _GuideLine('İlerledikçe yeni duraklar açılır.'),
            _GuideLine('Taçlı bölüm tema finalidir.'),
            _GuideLine('Pusula sonraki durağı gösterir.'),
            _GuideLine('Kitap bölümün konusu hakkında bilgi verir.'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showCompassHint() {
    final route = _activeRoute;
    if (!WordHuntRouteProgressEngine.isRouteComplete(route, _progress)) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${route.title} tamamlandı.')));
  }

  void _showBook() {
    final unlocked = _activeInfoCards
        .where((card) => _progress.unlockedInfoCardIds.contains(card.id))
        .toList(growable: false);

    if (unlocked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Henüz bilgi kartı açılmadı.')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ListView.separated(
          key: const Key('word_hunt_unlocked_info_cards'),
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          itemCount: unlocked.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (_, index) {
            final card = unlocked[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(card.title),
              subtitle: Text('${card.shortFact}\n${card.category}'),
              isThreeLine: true,
              leading: CircleAvatar(child: Text(card.word.characters.first)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        key: Key('word_hunt_production_entry_loading'),
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_catalogMode && _selectedRoute == null) {
      return WordHuntRouteSelector(
        progress: _progress,
        onRouteTap: _openCatalogRoute,
      );
    }

    final route = _activeRoute;
    switch (_activePresentationKind) {
      case WordHuntRoutePresentationKind.gokyuzuMasterArt:
        return WordHuntGokyuzuMasterArtScreen(
          key: const Key('word_hunt_production_entry_gokyuzu_route'),
          route: route,
          progress: _progress,
          onBack: _leaveRoute,
          onInfo: _showInfo,
          onCompass: _showCompassHint,
          onBook: _showBook,
          onLevelTap: _openLevel,
        );
      case WordHuntRoutePresentationKind.themedReusable:
        final WordHuntRouteVisualTheme? visualTheme =
            _activeCatalogEntry?.visualTheme;
        if (visualTheme == null) {
          return WordHuntReferenceRouteScreen(
            key: const Key('word_hunt_production_entry_theme_fallback'),
            route: route,
            progress: _progress,
            onBack: _leaveRoute,
            onInfo: _showInfo,
            onCompass: _showCompassHint,
            onBook: _showBook,
            onLevelTap: _openLevel,
          );
        }
        return WordHuntThemedProductionRouteScreen(
          key: const Key('word_hunt_production_entry_themed_route'),
          route: route,
          visualTheme: visualTheme,
          progress: _progress,
          onBack: _leaveRoute,
          onInfo: _showInfo,
          onCompass: _showCompassHint,
          onBook: _showBook,
          onLevelTap: _openLevel,
        );
      case WordHuntRoutePresentationKind.referenceRoute:
        return WordHuntReferenceRouteScreen(
          key: const Key('word_hunt_production_entry_route'),
          route: route,
          progress: _progress,
          onBack: _leaveRoute,
          onInfo: _showInfo,
          onCompass: _showCompassHint,
          onBook: _showBook,
          onLevelTap: _openLevel,
        );
    }
  }
}

class _GuideLine extends StatelessWidget {
  const _GuideLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 8),
            child: Text('•'),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
