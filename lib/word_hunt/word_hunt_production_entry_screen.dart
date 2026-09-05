import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'word_hunt_gokyuzu_master_art_screen.dart';
import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_progress_codec.dart';
import 'word_hunt_reference_route_screen.dart';
import 'word_hunt_screens.dart';
import 'word_hunt_starter_content.dart';

/// Ana Bilgi Rotası uygulamasından Kelime Avı production akışına girilen ekran.
///
/// - Başlangıç Limanı MASTER ART rota ekranını kullanır.
/// - İlerlemeyi hesap/misafir scope'una göre cihazda saklar.
/// - Açık node'u canonical production gameplay ekranına bağlar.
/// - BoardMap, soru bankası, reklam veya diğer oyun modlarına dokunmaz.
class WordHuntProductionEntryScreen extends StatefulWidget {
  const WordHuntProductionEntryScreen({
    super.key,
    this.ownerUid,
    this.route = WordHuntStarterContent.baslangicLimani,
    this.infoCards = WordHuntStarterContent.infoCards,
  });

  final String? ownerUid;
  final WordHuntRouteDefinition route;
  final List<WordHuntInfoCard> infoCards;

  @override
  State<WordHuntProductionEntryScreen> createState() =>
      _WordHuntProductionEntryScreenState();
}

class _WordHuntProductionEntryScreenState
    extends State<WordHuntProductionEntryScreen> {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  WordHuntProgressSnapshot _progress = const WordHuntProgressSnapshot();
  bool _loading = true;

  String get _ownerScope => WordHuntProgressCodec.scopeForUid(widget.ownerUid);

  String get _storageKey =>
      WordHuntProgressCodec.storageKeyForUid(widget.ownerUid);

  @override
  void initState() {
    super.initState();
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

  Future<void> _openLevel(int levelIndex) async {
    if (!WordHuntRouteProgressEngine.isLevelUnlocked(
      widget.route,
      _progress,
      levelIndex,
    )) {
      return;
    }

    final level = widget.route.levels[levelIndex - 1];
    final result = await Navigator.of(context).push<WordHuntLevelPlayResult>(
      MaterialPageRoute<WordHuntLevelPlayResult>(
        builder: (_) => WordHuntLevelProductionScreen(
          level: level,
          infoCards: widget.infoCards,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showCompassHint() {
    final complete = WordHuntRouteProgressEngine.isRouteComplete(
      widget.route,
      _progress,
    );
    final message = complete
        ? '${widget.route.title} tamamlandı.'
        : 'Sıradaki durak: Bölüm '
              '${WordHuntRouteProgressEngine.nextPlayableLevelIndex(widget.route, _progress)}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showBook() {
    final unlocked = widget.infoCards
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

    if (widget.route.id == WordHuntGokyuzuMasterArtScreen.routeId) {
      return WordHuntGokyuzuMasterArtScreen(
        key: const Key('word_hunt_production_entry_gokyuzu_route'),
        route: widget.route,
        progress: _progress,
        onBack: () => Navigator.of(context).maybePop(),
        onInfo: _showInfo,
        onCompass: _showCompassHint,
        onBook: _showBook,
        onLevelTap: _openLevel,
      );
    }

    return WordHuntReferenceRouteScreen(
      key: const Key('word_hunt_production_entry_route'),
      route: widget.route,
      progress: _progress,
      onBack: () => Navigator.of(context).maybePop(),
      onInfo: _showInfo,
      onCompass: _showCompassHint,
      onBook: _showBook,
      onLevelTap: _openLevel,
    );
  }
}
