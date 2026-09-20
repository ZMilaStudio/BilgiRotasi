import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'word_hunt_models.dart';
import 'word_hunt_progress.dart';
import 'word_hunt_route_catalog.dart';
import 'word_hunt_themed_production_route_screen.dart';

const String wordHuntTrilogyProofHead = String.fromEnvironment(
  'TRILOGY_PROOF_HEAD',
  defaultValue: 'unknown',
);

const List<String> wordHuntTrilogyProofRouteIds = <String>[
  'kayip-sehir',
  'yeralti-kralligi',
  'gunes-imparatorlugu',
];

enum WordHuntTrilogyProofState { l5Current, l10Current, completed }

extension WordHuntTrilogyProofStateX on WordHuntTrilogyProofState {
  String get slug => switch (this) {
    WordHuntTrilogyProofState.l5Current => 'l5-current',
    WordHuntTrilogyProofState.l10Current => 'l10-current',
    WordHuntTrilogyProofState.completed => 'completed',
  };

  String get label => switch (this) {
    WordHuntTrilogyProofState.l5Current => 'L5 CURRENT',
    WordHuntTrilogyProofState.l10Current => 'L10 CURRENT',
    WordHuntTrilogyProofState.completed => 'COMPLETED',
  };

  int get completedLevelCount => switch (this) {
    WordHuntTrilogyProofState.l5Current => 4,
    WordHuntTrilogyProofState.l10Current => 9,
    WordHuntTrilogyProofState.completed => 10,
  };
}

WordHuntRouteCatalogEntry wordHuntTrilogyProofEntry(String routeId) {
  if (!wordHuntTrilogyProofRouteIds.contains(routeId)) {
    throw ArgumentError.value(routeId, 'routeId', 'Unsupported trilogy route');
  }
  final entry = WordHuntRouteCatalog.entryForRouteId(routeId);
  if (entry == null ||
      entry.presentationKind != WordHuntRoutePresentationKind.themedReusable ||
      entry.visualTheme == null) {
    throw StateError(
      'Production trilogy catalog entry is not proof-ready: ' + routeId,
    );
  }
  return entry;
}

WordHuntProgressSnapshot wordHuntTrilogyProofProgress(
  WordHuntRouteDefinition route,
  WordHuntTrilogyProofState state,
) {
  final completedCount = state.completedLevelCount;
  return WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (final level in route.levels.take(completedCount)) level.id: 3,
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    debugPrint(
      '[WORD_HUNT_TRILOGY_PROOF_FLUTTER_ERROR] ' +
          details.exceptionAsString(),
    );
    FlutterError.presentError(details);
  };
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[WORD_HUNT_TRILOGY_PROOF_PLATFORM_ERROR] ' + error.toString());
    debugPrintStack(stackTrace: stack);
    return false;
  };
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const WordHuntTrilogyVisualProofApp());
}

class WordHuntTrilogyVisualProofApp extends StatelessWidget {
  const WordHuntTrilogyVisualProofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Avı Trilogy Runtime Proof',
      theme: ThemeData.dark(useMaterial3: true),
      home: const _ProofMenu(),
    );
  }
}

class _ProofMenu extends StatefulWidget {
  const _ProofMenu();

  @override
  State<_ProofMenu> createState() => _ProofMenuState();
}

class _ProofMenuState extends State<_ProofMenu> {
  bool _readyLogged = false;

  @override
  Widget build(BuildContext context) {
    if (!_readyLogged) {
      _readyLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint(
          '[WORD_HUNT_TRILOGY_PROOF_MENU_READY] head=' +
              wordHuntTrilogyProofHead,
        );
      });
    }

    final scenarios = <({String routeId, WordHuntTrilogyProofState state})>[
      for (final routeId in wordHuntTrilogyProofRouteIds)
        for (final state in WordHuntTrilogyProofState.values)
          (routeId: routeId, state: state),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF071426),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 70,
              child: Center(
                child: Text(
                  'Trilogy Runtime Proof',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                padding: const EdgeInsets.all(8),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: <Widget>[
                  for (final scenario in scenarios)
                    _ProofScenarioButton(
                      routeId: scenario.routeId,
                      state: scenario.state,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofScenarioButton extends StatelessWidget {
  const _ProofScenarioButton({required this.routeId, required this.state});

  final String routeId;
  final WordHuntTrilogyProofState state;

  @override
  Widget build(BuildContext context) {
    final entry = wordHuntTrilogyProofEntry(routeId);
    final semanticLabel =
        'TRILOGY_PROOF_SELECT|' + routeId + '|' + state.slug;
    return Semantics(
      label: semanticLabel,
      button: true,
      child: FilledButton(
        key: Key('trilogy_proof_select_' + routeId + '_' + state.slug),
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => _ProofScenarioScreen(entry: entry, state: state),
            ),
          );
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          entry.route.title + '\n' + state.label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ProofScenarioScreen extends StatelessWidget {
  const _ProofScenarioScreen({required this.entry, required this.state});

  final WordHuntRouteCatalogEntry entry;
  final WordHuntTrilogyProofState state;

  @override
  Widget build(BuildContext context) {
    final progress = wordHuntTrilogyProofProgress(entry.route, state);
    return _TrilogyRuntimeProbe(
      entry: entry,
      state: state,
      progress: progress,
      child: WordHuntThemedProductionRouteScreen(
        route: entry.route,
        visualTheme: entry.visualTheme!,
        progress: progress,
        onBack: () => Navigator.of(context).maybePop(),
        onInfo: _noop,
        onLevelTap: _noopLevel,
      ),
    );
  }

  static void _noop() {}
  static void _noopLevel(int _) {}
}

class _TrilogyRuntimeProbe extends StatefulWidget {
  const _TrilogyRuntimeProbe({
    required this.entry,
    required this.state,
    required this.progress,
    required this.child,
  });

  final WordHuntRouteCatalogEntry entry;
  final WordHuntTrilogyProofState state;
  final WordHuntProgressSnapshot progress;
  final Widget child;

  @override
  State<_TrilogyRuntimeProbe> createState() => _TrilogyRuntimeProbeState();
}

class _TrilogyRuntimeProbeState extends State<_TrilogyRuntimeProbe> {
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final route = widget.entry.route;
        final theme = widget.entry.visualTheme!;
        final asset = theme.backgroundAsset;
        if (asset == null || asset.isEmpty) {
          throw StateError('Missing environment asset for ' + route.id);
        }

        final completedLevels = route.levels
            .where((level) => widget.progress.starsFor(level.id) > 0)
            .length;
        if (completedLevels != widget.state.completedLevelCount) {
          throw StateError(
            'Unexpected completed level count for ' +
                route.id +
                '/' +
                widget.state.slug +
                ': ' +
                completedLevels.toString(),
          );
        }

        debugPrint(
          '[WORD_HUNT_TRILOGY_PROOF_CONFIG_READY] route=' +
              route.id +
              ' state=' +
              widget.state.slug +
              ' theme=' +
              theme.id +
              ' asset=' +
              asset +
              ' completedLevels=' +
              completedLevels.toString() +
              ' head=' +
              wordHuntTrilogyProofHead,
        );

        final data = await rootBundle.load(asset);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        final codec = await ui.instantiateImageCodec(bytes);
        try {
          final frame = await codec.getNextFrame();
          try {
            if (frame.image.width != 941 || frame.image.height != 1672) {
              throw StateError(
                'Unexpected trilogy artwork dimensions for ' +
                    route.id +
                    ': ' +
                    frame.image.width.toString() +
                    'x' +
                    frame.image.height.toString(),
              );
            }
            debugPrint(
              '[WORD_HUNT_TRILOGY_PROOF_ARTWORK_READY] route=' +
                  route.id +
                  ' state=' +
                  widget.state.slug +
                  ' width=' +
                  frame.image.width.toString() +
                  ' height=' +
                  frame.image.height.toString() +
                  ' bytes=' +
                  bytes.length.toString(),
            );
          } finally {
            frame.image.dispose();
          }
        } finally {
          codec.dispose();
        }

        await Future<void>.delayed(const Duration(milliseconds: 900));
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        debugPrint(
          '[WORD_HUNT_TRILOGY_PROOF_FRAME_READY] route=' +
              route.id +
              ' state=' +
              widget.state.slug +
              ' theme=' +
              theme.id +
              ' head=' +
              wordHuntTrilogyProofHead,
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[WORD_HUNT_TRILOGY_PROOF_ERROR] error=' + error.toString(),
        );
        debugPrintStack(
          label: '[WORD_HUNT_TRILOGY_PROOF_ERROR_STACK]',
          stackTrace: stackTrace,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
