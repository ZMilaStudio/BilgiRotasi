import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_avi_standalone/main.dart';
import 'package:kelime_avi_standalone/word_hunt_standalone_progress_store.dart';

class _MemoryPreferences implements WordHuntStandalonePreferences {
  @override
  Future<bool?> getBool(String key) async => null;

  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<void> setBool(String key, bool value) async {}

  @override
  Future<void> setString(String key, String value) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('standalone bundle contains the nested route and gameplay images', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    for (final path in <String>[
      'assets/word_hunt/baslangic_limani_bg.jpg',
      'assets/word_hunt/baslangic_limani/node_normal.webp',
      'assets/word_hunt/v5_reference_assets/harbor_background_1080x1920.png',
      'assets/word_hunt/v5_reference_assets/status_panel_empty.png',
      'assets/word_hunt/v5_reference_assets/cell_idle.png',
      'assets/word_hunt/v5_reference_assets/instruction_panel_empty.png',
      'assets/word_hunt/gokyuzu_adalari/gameplay_bg_bright.webp',
    ]) {
      expect(manifest.listAssets(), contains(path), reason: path);
      expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0));
    }
  });

  testWidgets('standalone route and first level render at narrow phone size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(708, 1536);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      KelimeAviStandaloneApp(
        progressStore: WordHuntStandaloneProgressStore(
          preferences: _MemoryPreferences(),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('kelime_avi_standalone_play_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_home_screen')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('word_hunt_home_routes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_route_selector')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('word_hunt_route_card_starter')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_production_entry_route')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('word_hunt_production_screen')), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_production_grid')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
