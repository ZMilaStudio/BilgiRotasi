import 'package:flutter/material.dart';
import 'package:word_hunt_content/word_hunt_starter_content.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_entry_screen.dart';
import 'package:word_hunt_flutter_feature/word_hunt_feature_host.dart';

import 'word_hunt_standalone_progress_store.dart';

void main() => runApp(const KelimeAviStandaloneApp());

class KelimeAviStandaloneApp extends StatelessWidget {
  const KelimeAviStandaloneApp({super.key, this.progressStore});

  final WordHuntProgressStore? progressStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Avı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF123B54)),
      ),
      home: KelimeAviStandaloneHomeScreen(
        progressStore: progressStore ?? WordHuntStandaloneProgressStore(),
      ),
    );
  }
}

class KelimeAviStandaloneHomeScreen extends StatelessWidget {
  const KelimeAviStandaloneHomeScreen({super.key, required this.progressStore});

  final WordHuntProgressStore progressStore;

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
                        progressStore: progressStore,
                        progressStorageIdentity:
                            const WordHuntStandaloneProgressStorageIdentity(),
                      ),
                    ),
                  );
                },
                child: const Text('Oyna'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
