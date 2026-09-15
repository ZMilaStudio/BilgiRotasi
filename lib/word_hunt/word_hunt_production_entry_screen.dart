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
      // Bozuk/eski yerel veri veya kullanılamayan storage katmanı Kelime Avı'nın
      // açılmasını engellemez; varsayılan boş progression ile devam edilir.
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${route.title} tamamlandı.')),
    );
  }

  void _showBook() {
    final route = _activeRoute;
    if (route.theme == 'orman' && route.levels.isNotEmpty) {
      _showOrmanTopicBook();
      return;
    }

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

  void _showOrmanTopicBook() {
    final route = _activeRoute;
    final levelIndex = WordHuntRouteProgressEngine.nextPlayableLevelIndex(
      route,
      _progress,
    ).clamp(1, route.levels.length).toInt();
    final level = route.levels[levelIndex - 1];
    final guide = _ormanTopicGuides[levelIndex - 1];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10251A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          key: const Key('word_hunt_current_topic_sheet'),
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Bölüm $levelIndex • ${guide.title}',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFFFE288),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                guide.fact,
                style: Theme.of(sheetContext).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFFFF5DE),
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 14),
              Text(
                'Bu bölümde: ${level.targetWords.join(', ')}',
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFCAD6C8),
                      height: 1.35,
                    ),
              ),
            ],
          ),
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

class _TopicGuide {
  const _TopicGuide(this.title, this.fact);
  final String title;
  final String fact;
}

const List<_TopicGuide> _ormanTopicGuides = <_TopicGuide>[
  _TopicGuide(
    'Ormanın Temeli',
    'Ağaçların kökleri toprağa tutunmayı sağlar; gövde ve dallar ise su ile besinlerin yapraklara taşınmasına yardımcı olur.',
  ),
  _TopicGuide(
    'Kökler ve Ağaç Türleri',
    'Çam ve meşe gibi farklı ağaç türleri aynı ormanda yaşayabilir. Kökler suyu ve mineralleri topraktan alır.',
  ),
  _TopicGuide(
    'Kuşlar ve Yuvalar',
    'Kuşlar yuvalarını korunmak ve yavrularını büyütmek için kullanır. Ağaçların dalları birçok canlıya güvenli yaşam alanı sağlar.',
  ),
  _TopicGuide(
    'Toprak, Mantar ve Dere',
    'Mantarlar ormandaki ölü organik maddelerin parçalanmasına yardım eder. Dereler de çevredeki canlılara su taşır.',
  ),
  _TopicGuide(
    'Patika ve Orman Bitkileri',
    'Orman tabanındaki çiçekler ve otlar ışık, su ve toprağın uygun olduğu alanlarda gelişir; patikalar bu yaşam alanlarının arasından geçer.',
  ),
  _TopicGuide(
    'Orman Hayvanları',
    'Sincap ve geyik gibi hayvanlar yiyecek, su ve barınak için ormanın farklı katmanlarından yararlanır.',
  ),
  _TopicGuide(
    'Ağaçların Yaşam Döngüsü',
    'Yapraklar güneş ışığını kullanarak ağacın besin üretmesine yardım eder; dallar ve gövde bu sistemi bir arada tutar.',
  ),
  _TopicGuide(
    'Çam ve Orman Dokusu',
    'Çamlar iğne yaprakları sayesinde su kaybını azaltabilir. Bu özellik birçok çam türünün serin ve zorlu koşullara uyum sağlamasına yardım eder.',
  ),
  _TopicGuide(
    'Kuşların Ormandaki Rolü',
    'Bazı kuşlar tohumların yayılmasına yardımcı olur. Böylece yeni bitkilerin farklı alanlarda filizlenmesine katkı sağlayabilirler.',
  ),
  _TopicGuide(
    'Orman Ekosistemi',
    'Toprak, bitkiler, mantarlar, su ve hayvanlar birbirine bağlı bir ekosistem oluşturur. Bir parçadaki değişim diğer canlıları da etkileyebilir.',
  ),
];
