import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:word_hunt_content/word_hunt_journey_catalog.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_domain/word_hunt_journey_progress.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_codec.dart';
import 'package:word_hunt_flutter_feature/word_hunt_infinite_journey_map_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_map_state_adapter.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_prototype_shell.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_theme.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_theme_demo.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_background.dart';
import 'package:word_hunt_flutter_feature/word_hunt_gameplay_readability_contract.dart';
import 'journey_owner_test_store.dart';

void main() {
  if (!kDebugMode) throw UnsupportedError('Journey owner entry is debug-only');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(JourneyOwnerTestApp(repository: JourneyOwnerTestRepository()));
}

PublishedJourneyCatalog ownerGameplayCatalog() => PublishedJourneyCatalog(
  levelCount: 15000,
  publishedLevelCount: WordHuntStarterContent.baslangicLimani.levels.length,
  metadata: {
    for (final level in WordHuntStarterContent.baslangicLimani.levels)
      level.index: JourneyLevelMetadata(
        gameplayContentId: level.id,
        challenge: level.index == 20 || level.index == 40,
        milestone: level.index == 10,
      ),
  },
);

WordHuntJourneySaveV1 ownerPreset(int frontier) {
  if (![1, 10, 20, 31, 40, 41].contains(frontier)) {
    throw ArgumentError('Unknown preset');
  }
  return WordHuntJourneySaveV1(
    bestStarsByStableId: {
      for (var n = 1; n < frontier; n++) journeyStableId(n): (n - 1) % 3 + 1,
    },
    lastViewedLevelId: journeyStableId(frontier == 41 ? 40 : frontier),
  );
}

JourneyThemeDefinition ownerLowContrastTheme() => JourneyThemeDefinition(
  id: 'owner-low-contrast-test',
  scenery: JourneyScenery.night,
  top: const Color(0xFFE8E8E8),
  bottom: const Color(0xFFDDDDDD),
  accent: const Color(0xFFEEEEEE),
  readability: JourneyThemeReadability(
    contract: const WordHuntGameplayReadabilityContract(
      textMode: WordHuntTextMode.light,
      scrimColor: Colors.black,
      scrimOpacity: .05,
    ),
    samples: const [Color(0xFFE8E8E8), Color(0xFFDDDDDD), Color(0xFFEEEEEE)],
  ),
);

class JourneyOwnerTestApp extends StatelessWidget {
  const JourneyOwnerTestApp({super.key, required this.repository});
  final JourneySaveRepository repository;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Journey Runtime Test',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF123B54)),
    ),
    home: kDebugMode
        ? _OwnerHome(repository: repository)
        : const SizedBox.shrink(),
  );
}

class _OwnerHome extends StatefulWidget {
  const _OwnerHome({required this.repository});
  final JourneySaveRepository repository;
  @override
  State<_OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<_OwnerHome> {
  int revision = 0;
  Future<void> tools() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('TEST ARAÇLARI'),
                subtitle: Text('Yalnız Journey test kaydı • gerçek oyun L1–40'),
              ),
              for (final frontier in [1, 10, 20, 31, 40, 41])
                ListTile(
                  key: Key('journey_preset_$frontier'),
                  title: Text(
                    frontier == 1
                        ? 'FRESH'
                        : frontier == 41
                        ? 'CONTENT END TEST'
                        : 'L$frontier TEST',
                  ),
                  onTap: () async {
                    final confirmed = await confirm(
                      context,
                      'Journey test kaydı bu preset ile değiştirilsin mi?',
                    );
                    if (!confirmed || !mounted) return;
                    try {
                      await widget.repository.save(ownerPreset(frontier));
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Test kaydı yazılamadı. Tekrar dene.',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    if (!mounted || !context.mounted) return;
                    Navigator.pop(context);
                    setState(() => revision++);
                  },
                ),
              ListTile(
                key: const Key('journey_reset'),
                title: const Text('TEST VERİSİNİ SIFIRLA'),
                onTap: () async {
                  if (!await confirm(
                    context,
                    'Yalnız Journey test verisi sıfırlansın mı?',
                  )) {
                    return;
                  }
                  try {
                    await widget.repository.clear();
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test kaydı silinemedi. Tekrar dene.'),
                        ),
                      );
                    }
                    return;
                  }
                  if (!mounted || !context.mounted) return;
                  Navigator.pop(context);
                  setState(() => revision++);
                },
              ),
              ListTile(
                key: const Key('journey_preview'),
                title: const Text('HARİTA GÖRSEL ÖNİZLEME • 15.000'),
                subtitle: const Text('Kayıt yazmaz • oyun açmaz'),
                onTap: () async {
                  WordHuntJourneySaveV1? save;
                  try {
                    save = await widget.repository.load();
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Test kaydı okunamadı.')),
                      );
                    }
                    return;
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  await Navigator.of(this.context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => JourneyOwnerVisualPreview(save: save),
                    ),
                  );
                },
              ),
              ListTile(
                key: const Key('journey_readability'),
                title: const Text('READABILITY TEST DEMOSU'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(this.context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          title: const Text(
                            'TEST • düzeltilmiş düşük kontrast',
                          ),
                        ),
                        body: JourneyThemeReadabilityDemo(
                          theme: ownerLowContrastTheme(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> confirm(BuildContext context, String text) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('VAZGEÇ'),
            ),
            FilledButton(
              key: const Key('journey_test_confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ONAYLA'),
            ),
          ],
        ),
      ) ??
      false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: WordHuntJourneyPrototypeShell(
      key: ValueKey(revision),
      catalog: ownerGameplayCatalog(),
      repository: widget.repository,
    ),
    bottomNavigationBar: SafeArea(
      child: TextButton(
        key: const Key('journey_test_tools'),
        onPressed: tools,
        child: const Text('Journey Runtime Test • TEST ARAÇLARI'),
      ),
    ),
  );
}

/// Read-only inspector; the map has no launch callback or repository reference.
class JourneyOwnerVisualPreview extends StatefulWidget {
  const JourneyOwnerVisualPreview({super.key, this.save});
  final WordHuntJourneySaveV1? save;
  @override
  State<JourneyOwnerVisualPreview> createState() => _PreviewState();
}

class _PreviewState extends State<JourneyOwnerVisualPreview> {
  final controller = WordHuntJourneyMapController();
  int ordinal = 50;
  String? telemetry;
  void measure() {
    var chunks = 0, nodes = 0, decor = 0;
    void visit(Element element) {
      final key = element.widget.key;
      if (key is ValueKey<String> && key.value.startsWith('journey_chunk_')) {
        chunks++;
      }
      if (key is ValueKey<String> &&
          key.value.startsWith('word_hunt_journey_level_')) {
        nodes++;
      }
      if (element.widget case JourneyChunkBackground(:final rows)) {
        decor += rows * 2;
      }
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
    setState(
      () => telemetry = 'Monteli chunk: $chunks • node: $nodes • decor: $decor',
    );
  }

  late final adapter = JourneyMapStateAdapter(
    WordHuntJourneyProgress(
      catalog: PublishedJourneyCatalog(
        levelCount: 15000,
        metadata: {
          20: const JourneyLevelMetadata(challenge: true),
          40: const JourneyLevelMetadata(challenge: true),
          100: const JourneyLevelMetadata(milestone: true),
        },
      ),
      save: widget.save,
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('TEST • GÖRSEL ÖNİZLEME')),
    body: Column(
      children: [
        const Text('Kayıt değişmez • oyun açılmaz'),
        TextButton(
          key: const Key('journey_measure'),
          onPressed: measure,
          child: const Text('MONTE SAYILARINI ÖLÇ'),
        ),
        if (telemetry != null) Text(telemetry!),
        DropdownButton<int>(
          key: const Key('journey_preview_ordinal'),
          value: ordinal,
          items: [
            20,
            21,
            50,
            100,
            101,
            150,
            250,
            350,
            500,
            5000,
            15000,
          ].map((n) => DropdownMenuItem(value: n, child: Text('L$n'))).toList(),
          onChanged: (n) {
            if (n != null) {
              setState(() => ordinal = n);
              controller.jumpToLevel(n);
            }
          },
        ),
        Expanded(
          child: WordHuntInfiniteJourneyMapScreen(
            publishedLevelCount: 15000,
            initialOrdinal: ordinal,
            currentOrdinal: adapter.currentOrdinal ?? 40,
            controller: controller,
            stateForOrdinal: adapter.presentationForOrdinal,
            showContinueControl: false,
            themeSchedule: JourneyThemeSchedule.synthetic,
          ),
        ),
      ],
    ),
  );
}
