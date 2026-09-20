import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'word_hunt_completion_orchestration.dart';
import 'word_hunt_completion_presentations.dart';
import 'word_hunt_deferred_completion_level_screen.dart';
import 'word_hunt_gameplay_presentation.dart';
import 'word_hunt_gokyuzu_master_art_screen.dart';
import 'word_hunt_home_projection.dart';
import 'word_hunt_home_screen.dart';
import 'word_hunt_models.dart';
import 'word_hunt_milestone_info_rewards.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_progress_codec.dart';
import 'word_hunt_progress_migration.dart';
import 'word_hunt_reference_route_screen.dart';
import 'word_hunt_route_catalog.dart';
import 'word_hunt_route_completion_dialogs.dart';
import 'word_hunt_route_rewards.dart';
import 'word_hunt_route_selector.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_screens.dart';
import 'word_hunt_segment_projection.dart';
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
enum WordHuntCatalogSurface { home, routes, route }

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
  WordHuntCatalogSurface _catalogSurface = WordHuntCatalogSurface.home;
  int _activeSegmentIndex = 1;
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

  int _deriveActiveSegmentIndex(
    WordHuntRouteDefinition route,
    WordHuntProgressSnapshot progress,
  ) {
    return WordHuntCompletionCoordinator.activeSegmentForProgress(
      route: route,
      progress: progress,
    );
  }

  @override
  void initState() {
    super.initState();
    if (!_catalogMode) {
      _catalogSurface = WordHuntCatalogSurface.route;
      _selectedRoute = widget.route;
      _selectedInfoCards = widget.infoCards;
    }
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    var loaded = const WordHuntProgressSnapshot();
    var shouldPersistProgress = false;
    var shouldRevealHistoricalKristal = false;
    try {
      final raw = await _preferences.getString(_storageKey);
      final hadPersistedProgress = raw != null && raw.trim().isNotEmpty;
      if (hadPersistedProgress) {
        final decoded = WordHuntProgressCodec.decodeWithMetadata(
          raw,
          expectedOwnerScope: _ownerScope,
        );
        loaded = WordHuntLegacyProgressMigration.migrate(decoded);
        shouldPersistProgress = decoded.requiresMigrationWriteback;
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
      shouldPersistProgress =
          shouldPersistProgress || !identical(backfilled, loaded);
      loaded = backfilled;
    } catch (_) {
      // Bozuk veya desteklenmeyen yerel veri / storage katmanı Kelime Avı'nın
      // açılmasını engellemez; varsayılan boş progression ile devam edilir.
      loaded = const WordHuntProgressSnapshot();
      shouldPersistProgress = false;
      shouldRevealHistoricalKristal = false;
    }

    if (!mounted) return;
    setState(() {
      _progress = loaded;
      if (!_catalogMode) {
        _activeSegmentIndex = _deriveActiveSegmentIndex(_activeRoute, loaded);
      }
      _loading = false;
    });
    if (shouldPersistProgress) {
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
      _catalogSurface = WordHuntCatalogSurface.route;
      _selectedRoute = entry.route;
      _selectedInfoCards = entry.infoCards;
      _activeSegmentIndex = _deriveActiveSegmentIndex(entry.route, _progress);
    });
  }

  void _showCatalogHome() {
    if (!_catalogMode) return;
    setState(() {
      _catalogSurface = WordHuntCatalogSurface.home;
      _selectedRoute = null;
      _selectedInfoCards = null;
    });
  }

  void _showCatalogRoutes() {
    if (!_catalogMode) return;
    setState(() {
      _catalogSurface = WordHuntCatalogSurface.routes;
      _selectedRoute = null;
      _selectedInfoCards = null;
    });
  }

  Future<void> _continueFromHome(
    WordHuntContinueDestination destination,
  ) async {
    final entry = WordHuntRouteCatalog.entryForRouteId(destination.route.id);
    if (entry == null || !entry.isUnlocked(_progress)) {
      _showCatalogRoutes();
      return;
    }

    setState(() {
      _catalogSurface = WordHuntCatalogSurface.route;
      _selectedRoute = entry.route;
      _selectedInfoCards = entry.infoCards;
      _activeSegmentIndex = destination.activeSegmentIndex;
    });
    await _openLevel(destination.absoluteLevelIndex);
  }

  String _lockedRouteMessage(WordHuntRouteCatalogEntry entry) {
    final lockedMessage = entry.lockedMessage;
    if (lockedMessage != null && lockedMessage.trim().isNotEmpty) {
      return lockedMessage;
    }

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
        _catalogSurface = WordHuntCatalogSurface.routes;
        _selectedRoute = null;
        _selectedInfoCards = null;
      });
      return;
    }
    Navigator.of(context).maybePop();
  }

  WordHuntGameplayPresentation _gameplayPresentationForLevel(int levelIndex) {
    final profile =
        _activeCatalogEntry?.presentationProfile ??
        WordHuntRoutePresentationProfiles.starter;
    final route = _activeRoute;
    final segmentIndex =
        route.segments.isEmpty
            ? null
            : WordHuntSegmentProjection.forLevel(
              route,
              levelIndex,
            ).segmentIndex;
    return profile.gameplayForLevel(
      levelIndex: levelIndex,
      segmentIndex: segmentIndex,
    );
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

    var beforeProgress = _progress;
    final progressWithLastActive = beforeProgress.markLastActiveRoute(route.id);
    if (!identical(progressWithLastActive, beforeProgress)) {
      beforeProgress = progressWithLastActive;
      setState(() => _progress = progressWithLastActive);
      await _saveProgress(progressWithLastActive);
      if (!mounted) return;
    }

    final beforeRouteComplete = WordHuntRouteProgressEngine.isRouteComplete(
      route,
      beforeProgress,
    );
    final level = route.levels[levelIndex - 1];
    final parentOwnsCompletion = _catalogMode;
    final explicitV2 = WordHuntSegmentProjection.isExplicitV2Route(route);
    final deferCompletion =
        parentOwnsCompletion ||
        (!explicitV2 &&
            level.type == WordHuntLevelType.routeFinal &&
            !beforeRouteComplete);
    final result = await Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder: (_) {
          final gameplayPresentation = _gameplayPresentationForLevel(
            level.index,
          );
          if (deferCompletion) {
            return WordHuntDeferredCompletionLevelScreen(
              level: level,
              infoCards: _activeInfoCards,
              presentation: gameplayPresentation,
              routeTitle: route.title,
            );
          }
          return WordHuntLevelProductionScreen(
            level: level,
            infoCards: _activeInfoCards,
            presentation: gameplayPresentation,
            routeTitle: route.title,
          );
        },
      ),
    );

    if (result == null || !mounted) return;

    if (!parentOwnsCompletion) {
      final milestoneInfoReward = WordHuntMilestoneInfoRewardEngine.project(
        route: route,
        routeInfoCards: _activeInfoCards,
        completedLevelId: result.levelId,
        beforeProgress: beforeProgress,
        gameplayUnlockedInfoCardIds: result.unlockedInfoCardIds,
      );
      final transition = WordHuntRouteRewardEngine.recordLevelResult(
        route: route,
        progress: beforeProgress,
        levelId: result.levelId,
        stars: result.stars,
        unlockedInfoCards: <String>{
          ...result.unlockedInfoCardIds,
          ...milestoneInfoReward.newlyGrantedCardIds,
        },
        foundBonusCount: result.foundBonusCount,
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

      if (!explicitV2 &&
          level.type == WordHuntLevelType.routeFinal &&
          !beforeRouteComplete &&
          !transition.afterRouteComplete) {
        await _showFinalIncomplete(route, next);
      }
      return;
    }

    final processed = await WordHuntCompletionOrchestrator.process(
      route: route,
      beforeProgress: beforeProgress,
      levelId: result.levelId,
      stars: result.stars,
      unlockedInfoCards: result.unlockedInfoCardIds,
      foundBonusCount: result.foundBonusCount,
      routeInfoCards: _activeInfoCards,
      onProgressReady: (next) {
        if (!mounted) return;
        setState(() => _progress = next);
      },
      persistProgress: _saveProgress,
    );
    if (!mounted) return;

    final transition = processed.transition;
    final destination = processed.destination;

    final isLegacyFinalIncomplete =
        !WordHuntSegmentProjection.isExplicitV2Route(route) &&
        level.type == WordHuntLevelType.routeFinal &&
        !beforeRouteComplete &&
        !transition.afterRouteComplete;
    if (isLegacyFinalIncomplete) {
      await _showFinalIncomplete(route, transition.progress);
      return;
    }

    if (transition.routeCompletedNow) {
      await _markKristalRevealSeenForNextRoute(route);
    }
    if (!mounted) return;

    await _showParentCompletion(destination);
  }

  Future<void> _showParentCompletion(
    WordHuntCompletionDestination destination,
  ) async {
    if (!mounted) return;
    final action = await showDialog<WordHuntCompletionUiAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WordHuntCompletionPresentation(destination: destination),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case WordHuntCompletionUiAction.returnToRoute:
        return;
      case WordHuntCompletionUiAction.routes:
        _showCatalogRoutes();
        return;
      case WordHuntCompletionUiAction.home:
        _showCatalogHome();
        return;
      case WordHuntCompletionUiAction.primary:
        break;
    }

    switch (destination.kind) {
      case WordHuntCompletionDestinationKind.nextLevel:
        final nextLevel = destination.canonicalNextPlayableLevel;
        if (nextLevel > 0 && nextLevel <= _activeRoute.levels.length) {
          await _openLevel(nextLevel);
        }
        return;
      case WordHuntCompletionDestinationKind.nextSegment:
        setState(() {
          _activeSegmentIndex = destination.nextPlayableSegment;
        });
        return;
      case WordHuntCompletionDestinationKind.nextRoute:
        final nextEntry = destination.nextRoute;
        if (nextEntry == null || !nextEntry.isUnlocked(_progress)) {
          _showCatalogRoutes();
          return;
        }
        setState(() {
          _catalogSurface = WordHuntCatalogSurface.route;
          _selectedRoute = nextEntry.route;
          _selectedInfoCards = nextEntry.infoCards;
          _activeSegmentIndex = _deriveActiveSegmentIndex(
            nextEntry.route,
            _progress,
          );
        });
        return;
      case WordHuntCompletionDestinationKind.returnToRoute:
        return;
      case WordHuntCompletionDestinationKind.terminalRouteComplete:
        _showCatalogRoutes();
        return;
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
      builder:
          (_) => WordHuntRouteCompletionDialog(
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
        _catalogSurface = WordHuntCatalogSurface.routes;
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
      builder:
          (_) => WordHuntFinalIncompleteDialog(
            route: route,
            totalStars: WordHuntRouteProgressEngine.totalStars(route, progress),
          ),
    );
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        key: Key('word_hunt_production_entry_loading'),
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_catalogMode) {
      switch (_catalogSurface) {
        case WordHuntCatalogSurface.home:
          final projection = WordHuntHomeProjection.fromProgress(_progress);
          return WordHuntHomeScreen(
            projection: projection,
            onContinue: _continueFromHome,
            onRoutes: _showCatalogRoutes,
          );
        case WordHuntCatalogSurface.routes:
          return WordHuntRouteSelector(
            progress: _progress,
            onRouteTap: _openCatalogRoute,
            onBack: _showCatalogHome,
          );
        case WordHuntCatalogSurface.route:
          break;
      }
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
          onLevelTap: _openLevel,
          segmentIndex: _activeSegmentIndex,
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
            segmentIndex: _activeSegmentIndex,
          );
        }
        return WordHuntThemedProductionRouteScreen(
          key: const Key('word_hunt_production_entry_themed_route'),
          route: route,
          visualTheme: visualTheme,
          progress: _progress,
          onBack: _leaveRoute,
          onInfo: _showInfo,
          onLevelTap: _openLevel,
          segmentIndex: _activeSegmentIndex,
        );
      case WordHuntRoutePresentationKind.referenceRoute:
        return WordHuntReferenceRouteScreen(
          key: const Key('word_hunt_production_entry_route'),
          route: route,
          progress: _progress,
          onBack: _leaveRoute,
          onInfo: _showInfo,
          onLevelTap: _openLevel,
          segmentIndex: _activeSegmentIndex,
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
