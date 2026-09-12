import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'word_hunt_gokyuzu_gameplay_backgrounds.dart';
import 'word_hunt_gokyuzu_master_art_screen.dart';
import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_progress_codec.dart';
import 'word_hunt_reference_route_screen.dart';
import 'word_hunt_route_catalog.dart';
import 'word_hunt_route_selector.dart';
import 'word_hunt_route_visual_theme.dart';
import 'word_hunt_screens.dart';
import 'word_hunt_starter_content.dart';

/// Ana Bilgi Rotası uygulamasından Kelime Avı production akışına girilen ekran.
///
/// Rota seçimi ve route presentation kararı [WordHuntRouteCatalog] verisiyle
/// çözülür. Bu ekran rota adına göre renderer seçmez.
///
/// Mevcut production sözleşmesi değişmez:
/// - Başlangıç Limanı her zaman açıktır ve mevcut reference renderer'ı kullanır.
/// - Gökyüzü Adaları 18 Başlangıç Limanı yıldızında açılır ve mevcut MASTER ART
///   renderer/gameplay arka planlarını kullanır.
/// - Generic themed renderer production tarafından desteklenir; fakat Orman Yolu
///   owner unlock + production skin kararı verilmeden katalogda yoktur.
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
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

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
    try {
      final raw = await _preferences.getString(_storageKey);
      if (raw != null && raw.trim().isNotEmpty) {
        loaded = WordHuntProgressCodec.decode(
          raw,
          expectedOwnerScope: _ownerScope,
        );
      }
    } catch (_) {
      // Bozuk/eski yerel veri Kelime Avı'nın açılmasını engellemez.
      loaded = const WordHuntProgressSnapshot();
    }

    if (!mounted) return;
    setState(() {
      _progress = loaded;
      _loading = false;
    });
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
      final rule = entry.unlockRule;
      final prerequisite = rule.prerequisiteRoute;
      final message = prerequisite == null
          ? '${entry.route.title} henüz açık değil.'
          : '${entry.route.title} için ${rule.requiredStars} '
                '${prerequisite.title} yıldızı gerekli.';
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

    final level = route.levels[levelIndex - 1];
    final result = await Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder: (_) => WordHuntLevelProductionScreen(
          level: level,
          infoCards: _activeInfoCards,
          backgroundAsset: _gameplayBackgroundForLevel(level.index),
          routeTitle: route.title,
        ),
      ),
    );

    if (result == null || !mounted) return;

    final next = _progress.recordLevelResult(
      levelId: result.levelId,
      stars: result.stars,
      unlockedInfoCards: result.unlockedInfoCardIds,
    );
    setState(() => _progress = next);
    await _saveProgress(next);
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kelime Avı'),
        content: const Text(
          'Hedef kelimeleri yatay, dikey veya çapraz olarak bul. '
          'Bölümü tamamladıkça yeni duraklar açılır; bonus kelimeler de '
          'bilgi kartlarını keşfetmene yardımcı olur.',
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
    final complete = WordHuntRouteProgressEngine.isRouteComplete(
      route,
      _progress,
    );
    final message = complete
        ? '${route.title} tamamlandı.'
        : 'Sıradaki durak: Bölüm '
              '${WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, _progress)}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        final visualTheme = _activeCatalogEntry?.visualTheme;
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
        return WordHuntThemedRouteMapScreen(
          key: const Key('word_hunt_production_entry_themed_route'),
          route: route,
          visualTheme: visualTheme,
          progress: _progress,
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
