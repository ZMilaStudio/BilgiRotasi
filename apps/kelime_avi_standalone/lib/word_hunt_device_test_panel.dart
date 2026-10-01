import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_progress.dart';
import 'package:word_hunt_domain/word_hunt_progress_codec.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_host.dart';

import 'word_hunt_standalone_progress_store.dart';

/// Debug state preparation only. No route-access/reward rules live here.
class WordHuntDeviceTestSeeder {
  WordHuntDeviceTestSeeder(this.store);
  final WordHuntProgressStore store;
  static const identity = WordHuntStandaloneProgressStorageIdentity();
  static final route = WordHuntStarterContent.baslangicLimani;

  Future<WordHuntProgressSnapshot> load() async {
    final raw = await store.getString(identity.progressStorageKeyForUid(null));
    return raw == null
        ? const WordHuntProgressSnapshot()
        : WordHuntProgressCodec.decode(
          raw,
          expectedOwnerScope: identity.ownerScopeForUid(null),
        );
  }

  Future<WordHuntProgressSnapshot> prepare({
    int completed = 0,
    int? totalStars,
  }) async {
    if (!kDebugMode) throw StateError('Device Test Panel is debug-only');
    if (completed < 0 ||
        completed > 30 ||
        (totalStars != null &&
            (totalStars < completed || totalStars > completed * 3))) {
      throw ArgumentError('Invalid sequential completion/star seed');
    }
    final old = await load();
    final harborIds = route.levels.map((level) => level.id).toSet();
    final stars = <String, int>{
      for (final entry in old.bestStarsByLevelId.entries)
        if (!harborIds.contains(entry.key)) entry.key: entry.value,
    };
    var remaining = (totalStars ?? completed * 3) - completed;
    for (final level in route.levels.take(completed)) {
      final extra = remaining.clamp(0, 2).toInt();
      stars[level.id] = 1 + extra;
      remaining -= extra;
    }
    final seeded = WordHuntProgressSnapshot(
      bestStarsByLevelId: stars,
      bestBonusFoundCountByLevelId: {
        for (final entry in old.bestBonusFoundCountByLevelId.entries)
          if (!harborIds.contains(entry.key)) entry.key: entry.value,
      },
      unlockedInfoCardIds: old.unlockedInfoCardIds,
      unlockedRouteRewardIds: old.unlockedRouteRewardIds,
      grandfatheredUnlockedRouteIds: old.grandfatheredUnlockedRouteIds,
      lastActiveRouteId: old.lastActiveRouteId,
    );
    await store.setString(
      identity.progressStorageKeyForUid(null),
      WordHuntProgressCodec.encode(
        seeded,
        ownerScope: identity.ownerScopeForUid(null),
      ),
    );
    return seeded;
  }

  Future<WordHuntProgressSnapshot> prepareLevel(int level) {
    if (level < 1 || level > 30) throw RangeError.range(level, 1, 30);
    return prepare(completed: level - 1);
  }

  Future<WordHuntProgressSnapshot> prepareStars(int stars) {
    if (!const [17, 18, 90].contains(stars)) throw ArgumentError.value(stars);
    // Completed levels need >=1 star in schema 3. Therefore 17/18-star
    // presets complete 17/18 levels; 90 completes all 30. No fake 0-star
    // completion and no Sky unlock/reward injection.
    return prepare(completed: stars == 90 ? 30 : stars, totalStars: stars);
  }
}

class WordHuntDeviceTestPanel extends StatefulWidget {
  const WordHuntDeviceTestPanel({super.key, required this.store});
  final WordHuntProgressStore store;
  @override
  State<WordHuntDeviceTestPanel> createState() =>
      _WordHuntDeviceTestPanelState();
}

class _WordHuntDeviceTestPanelState extends State<WordHuntDeviceTestPanel> {
  late final seeder = WordHuntDeviceTestSeeder(widget.store);
  String summary = 'Kayıt okunuyor…';
  int selected = 20;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) _refresh();
  }

  String describe(WordHuntProgressSnapshot progress) {
    final route = WordHuntDeviceTestSeeder.route;
    final completed =
        route.levels.where((level) => progress.starsFor(level.id) > 0).length;
    return 'Başlangıç Limanı: $completed/30 tamamlandı · '
        '${WordHuntRouteProgressEngine.totalStars(route, progress)} yıldız · '
        'sonraki L${WordHuntRouteProgressEngine.nextPlayableLevelIndex(route, progress)}';
  }

  Future<void> _refresh() async {
    try {
      final progress = await seeder.load();
      if (mounted) setState(() => summary = describe(progress));
    } catch (error) {
      if (mounted) setState(() => summary = 'Kayıt okunamadı: $error');
    }
  }

  Future<void> apply(
    String label,
    Future<WordHuntProgressSnapshot> Function() action,
  ) async {
    if (!kDebugMode || busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('TEST MODE — kaydı değiştir'),
            content: Text(
              '$label: mevcut Başlangıç Limanı yıldız/bonus kaydı değiştirilecek. '
              'Diğer rota ve uygulama verileri korunur. Devam edilsin mi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Uygula'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => busy = true);
    try {
      final progress = await action();
      if (!mounted) return;
      setState(() => summary = describe(progress));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label hazırlandı. $summary')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Preset başarısız: $error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Device Test Panel — TEST MODE')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(summary, key: const Key('device_test_state_summary')),
          const Text(
            'Gerçek cihaz kaydı değişir. Gökyüzü açma kuralı değiştirilmez.',
          ),
          for (final preset in const <(String, int)>[
            ('Sıfırdan Başlat', 0),
            ('L11 hazırla', 10),
            ('L21 hazırla', 20),
            ('L30 hazırla', 29),
            ('L1–30 tamamla', 30),
          ])
            OutlinedButton(
              onPressed:
                  busy
                      ? null
                      : () => apply(
                        preset.$1,
                        () => seeder.prepare(completed: preset.$2),
                      ),
              child: Text(preset.$1),
            ),
          DropdownButton<int>(
            value: selected,
            items: [
              for (var level = 1; level <= 30; level++)
                DropdownMenuItem(value: level, child: Text('L$level')),
            ],
            onChanged:
                busy ? null : (value) => setState(() => selected = value!),
          ),
          OutlinedButton(
            onPressed:
                busy
                    ? null
                    : () => apply(
                      'L$selected hazırla',
                      () => seeder.prepareLevel(selected),
                    ),
            child: const Text('Seçili bölümü hazırla (tamamlanmamış)'),
          ),
          for (final stars in const [17, 18, 90])
            OutlinedButton(
              onPressed:
                  busy
                      ? null
                      : () => apply(
                        '$stars yıldız',
                        () => seeder.prepareStars(stars),
                      ),
              child: Text('$stars yıldız'),
            ),
        ],
      ),
    );
  }
}
