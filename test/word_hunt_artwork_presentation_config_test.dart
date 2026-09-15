import 'package:bilgi_rotasi/word_hunt/word_hunt_artwork_presentation.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_reusable_route_map_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_map_decoration.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_themed_production_route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const proofMapTheme = WordHuntRouteMapTheme(
    id: 'generic-artwork-presentation-proof',
    backgroundColor: Color(0xFF07150D),
    surfaceColor: Color(0xFF143420),
    pathColor: Color(0xFFEBD49B),
    lockedPathColor: Color(0xFF657066),
    nodeColor: Color(0xFF81542F),
    lockedNodeColor: Color(0xFF4A5050),
    accentColor: Color(0xFFFFD96B),
    textColor: Color(0xFFFFF7E2),
  );
  const decorationSpec = WordHuntRouteDecorationSpec(
    kind: WordHuntRouteDecorationKind.forest,
    seed: 1,
    count: 0,
  );
  const decorationPalette = WordHuntRouteDecorationPalette(
    primary: Color(0xFF4F8A45),
    secondary: Color(0xFF6A4328),
    accent: Color(0xFFFFE08A),
  );

  test('Orman 1 presentation values are explicit config', () {
    const theme = WordHuntRouteVisualThemes.ormanYolu;

    expect(theme.referenceCanvasSize, const Size(411, 731));
    expect(theme.extendTallAmbientFromArtworkEdges, isTrue);
    expect(
      theme.artworkOverlayMode,
      WordHuntArtworkOverlayMode.embeddedRouteLiveNodes,
    );

    for (final proofTheme in WordHuntRouteVisualThemeProofs.all) {
      expect(proofTheme.referenceCanvasSize, isNull);
      expect(proofTheme.extendTallAmbientFromArtworkEdges, isFalse);
      expect(
        proofTheme.artworkOverlayMode,
        WordHuntArtworkOverlayMode.reusable,
      );
    }
  });

  testWidgets('embedded-route overlay selection does not depend on theme id', (
    tester,
  ) async {
    const theme = WordHuntRouteVisualTheme(
      id: 'not-orman-route-id',
      mapTheme: proofMapTheme,
      decorationSpec: decorationSpec,
      decorationPalette: decorationPalette,
      backgroundAsset: 'assets/word_hunt/baslangic_limani_bg.jpg',
      artworkOverlayMode: WordHuntArtworkOverlayMode.embeddedRouteLiveNodes,
    );

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntThemedRouteMapScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: theme,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('word_hunt_route_stop_asset_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_reusable_node_1_current')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reference canvas and tall ambient are config driven', (
    tester,
  ) async {
    const theme = WordHuntRouteVisualTheme(
      id: 'not-orman-reference-id',
      mapTheme: proofMapTheme,
      decorationSpec: decorationSpec,
      decorationPalette: decorationPalette,
      backgroundAsset: 'assets/word_hunt/baslangic_limani_bg.jpg',
      referenceCanvasSize: Size(411, 731),
      extendTallAmbientFromArtworkEdges: true,
    );

    tester.view.physicalSize = const Size(411, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntThemedProductionRouteScreen(
          route: WordHuntOrmanContent.ormanYolu,
          visualTheme: theme,
          progress: const WordHuntProgressSnapshot(),
          onBack: () {},
          onInfo: () {},
          onCompass: () {},
          onBook: () {},
          onLevelTap: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('word_hunt_orman_reference_canvas')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_orman_ambient_top_band')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('word_hunt_orman_ambient_bottom_band')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
