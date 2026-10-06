import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_entry_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_host.dart';
import 'package:word_hunt_domain/word_hunt_experience_mode.dart';
import 'package:word_hunt_domain/word_hunt_journey_save_codec.dart';
import 'package:word_hunt_content/word_hunt_production_journey_catalog.dart';
import 'package:word_hunt_flutter_feature/word_hunt_journey_prototype_shell.dart';
import 'word_hunt_production_journey_store.dart';

import 'word_hunt_standalone_progress_store.dart';
import 'word_hunt_device_test_panel.dart';

void main() => runApp(const KelimeAviStandaloneApp());

class KelimeAviStandaloneApp extends StatelessWidget {
  const KelimeAviStandaloneApp({
    super.key,
    this.progressStore,
    this.experienceMode,
    this.journeyRepository,
  });

  final WordHuntProgressStore? progressStore;
  final WordHuntExperienceMode? experienceMode;
  final JourneySaveRepository? journeyRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Avı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF123B54)),
      ),
      home:
          (experienceMode ?? configuredWordHuntExperience) ==
              WordHuntExperienceMode.journey
          ? WordHuntJourneyPrototypeShell(
              catalog: ProductionJourneyCatalogFactory.create(),
              repository:
                  journeyRepository ?? WordHuntProductionJourneyRepository(),
            )
          : KelimeAviStandaloneHomeScreen(
              progressStore: progressStore ?? WordHuntStandaloneProgressStore(),
            ),
    );
  }
}

class KelimeAviStandaloneHomeScreen extends StatefulWidget {
  const KelimeAviStandaloneHomeScreen({super.key, required this.progressStore});

  final WordHuntProgressStore progressStore;

  @override
  State<KelimeAviStandaloneHomeScreen> createState() =>
      _KelimeAviStandaloneHomeScreenState();
}

class _KelimeAviStandaloneHomeScreenState
    extends State<KelimeAviStandaloneHomeScreen> {
  int _versionTaps = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Kelime Avı',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              const Text('Keşfet, bul ve rotanı tamamla.'),
              const SizedBox(height: 28),
              FilledButton(
                key: const Key('kelime_avi_standalone_play_button'),
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => WordHuntFeatureEntryScreen(
                        route: WordHuntStarterContent.baslangicLimani,
                        infoCards: WordHuntStarterContent.infoCards,
                        progressStore: widget.progressStore,
                        progressStorageIdentity:
                            const WordHuntStandaloneProgressStorageIdentity(),
                      ),
                    ),
                  );
                },
                child: const Text('Oyna'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                key: const Key('kelime_avi_version'),
                onTap: kDebugMode
                    ? () {
                        if (++_versionTaps < 5) return;
                        _versionTaps = 0;
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => WordHuntDeviceTestPanel(
                              store: widget.progressStore,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'Kelime Avı · 1.0.0',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
