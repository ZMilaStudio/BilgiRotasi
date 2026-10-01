import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_progress.dart';
import 'package:word_hunt_domain/word_hunt_progress_codec.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_host.dart';
import 'package:word_hunt_flutter_feature/word_hunt_route_catalog.dart';

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
    bool resetPilotAccess = false,
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
    final seeded = WordHuntRouteCatalog.grantEligiblePilotAccess(
      WordHuntProgressSnapshot(
        bestStarsByLevelId: stars,
        bestBonusFoundCountByLevelId: {
          for (final entry in old.bestBonusFoundCountByLevelId.entries)
            if (!harborIds.contains(entry.key)) entry.key: entry.value,
        },
        unlockedInfoCardIds: old.unlockedInfoCardIds,
        unlockedRouteRewardIds: old.unlockedRouteRewardIds,
        grandfatheredUnlockedRouteIds: {
          for (final id in old.grandfatheredUnlockedRouteIds)
            if (!resetPilotAccess ||
                id != WordHuntRouteCatalog.gokyuzu.route.id)
              id,
        },
        lastActiveRouteId: old.lastActiveRouteId,
      ),
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
    if (!const [59, 60, 90].contains(stars)) throw ArgumentError.value(stars);
    return preparePilotBoundary(completed: 30, stars: stars);
  }

  /// Explicit destructive QA reset of this pilot entitlement only, so a locked
  /// boundary can be retested after an unlocked preset. Normal prep preserves it.
  Future<WordHuntProgressSnapshot> preparePilotBoundary({
    required int completed,
    required int stars,
  }) {
    if (!const [
      (30, 59),
      (30, 60),
      (20, 60),
      (30, 90),
    ].contains((completed, stars))) {
      throw ArgumentError('Unsupported pilot boundary preset');
    }
    return prepare(
      completed: completed,
      totalStars: stars,
      resetPilotAccess: true,
    );
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
              'Pilot sınır presetleri önceki Gökyüzü pilot erişimini de sıfırlar. '
              'Diğer rota ilerlemesi ve uygulama verileri korunur. Devam edilsin mi?',
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
          for (final preset in const [(30, 59), (30, 60), (20, 60), (30, 90)])
            OutlinedButton(
              onPressed:
                  busy
                      ? null
                      : () => apply(
                        '${preset.$1} tamam / ${preset.$2} yıldız',
                        () => seeder.preparePilotBoundary(
                          completed: preset.$1,
                          stars: preset.$2,
                        ),
                      ),
              child: Text('${preset.$1} tamam / ${preset.$2} yıldız'),
            ),
        ],
      ),
    );
  }
}
