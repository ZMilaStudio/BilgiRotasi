import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_edge_ambient.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gunes_imparatorlugu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_gunes_imparatorlugu_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kayip_sehir_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kayip_sehir_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_visual_theme.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_themed_production_route_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_yeralti_kralligi_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_yeralti_kralligi_visual_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_flutter_feature/word_hunt_star_visuals.dart';

void main() {
  final routeThemes = <({
    WordHuntRouteDefinition route,
    WordHuntRouteVisualTheme theme,
  })>[
    (
      route: WordHuntKayipSehirContent.kayipSehir,
      theme: WordHuntKayipSehirVisualTheme.production,
    ),
    (
      route: WordHuntYeraltiKralligiContent.yeraltiKralligi,
      theme: WordHuntYeraltiKralligiVisualTheme.production,
    ),
    (
      route: WordHuntGunesImparatorluguContent.gunesImparatorlugu,
      theme: WordHuntGunesImparatorluguVisualTheme.production,
    ),
  ];

  testWidgets(
    'all trilogy L10 special nodes stay overflow-free locked/current/completed',
    (tester) async {
      tester.view.physicalSize = const Size(411, 731);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final routeTheme in routeThemes) {
        final route = routeTheme.route;
        for (final scenario in <({
          int completed,
          String visualState,
          int levelTenStars,
        })>[
          (completed: 4, visualState: 'locked', levelTenStars: 0),
          (completed: 9, visualState: 'current', levelTenStars: 0),
          (completed: 10, visualState: 'completed', levelTenStars: 1),
          (completed: 10, visualState: 'completed', levelTenStars: 2),
          (completed: 10, visualState: 'completed', levelTenStars: 3),
        ]) {
          final progress = _progressThrough(
            route,
            scenario.completed,
            levelTenStars: scenario.levelTenStars,
          );
          expect(
            progress.starsFor(route.levels[9].id),
            scenario.levelTenStars,
            reason: '${route.id} / ${scenario.visualState} / source progress',
          );
          await _pumpRoute(
            tester,
            route: route,
            theme: routeTheme.theme,
            progress: progress,
          );

          expect(
            find.byKey(
              Key('word_hunt_reusable_node_10_${scenario.visualState}'),
            ),
            findsOneWidget,
            reason: '${route.id} / ${scenario.visualState}',
          );
          expect(
            find.byKey(const Key('word_hunt_seal_silhouette_10_final')),
            findsOneWidget,
            reason: '${route.id} / ${scenario.visualState}',
          );

          expect(
            find.byKey(const Key('word_hunt_seal_star_row_10')),
            findsOneWidget,
            reason: '${route.id} / ${scenario.visualState}',
          );
          expect(
            find.byKey(const Key('word_hunt_seal_physical_lock_10')),
            scenario.visualState == 'locked' ? findsOneWidget : findsNothing,
            reason: '${route.id} / ${scenario.visualState}',
          );

          var filledCount = 0;
          for (var i = 0; i < 3; i++) {
            expect(
              find.byKey(Key('word_hunt_seal_star_socket_10_$i')),
              findsOneWidget,
              reason: '${route.id} / ${scenario.visualState} / socket $i',
            );
            final star = tester.widget<Icon>(
              find.byKey(Key('word_hunt_seal_star_10_$i')),
            );
            final filled = i < scenario.levelTenStars;
            if (star.icon == Icons.star_rounded) filledCount++;
            expect(
              star.icon,
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              reason: '${route.id} / ${scenario.visualState} / icon $i',
            );
            expect(
              star.color,
              filled ? WordHuntStarVisuals.filled : WordHuntStarVisuals.empty,
              reason: '${route.id} / ${scenario.visualState} / color $i',
            );
            expect(star.size, 10, reason: '${route.id} / star $i');
          }
          expect(
            filledCount,
            scenario.levelTenStars,
            reason: '${route.id} / ${scenario.visualState} / filled count',
          );

          expect(
            tester.takeException(),
            isNull,
            reason: '${route.id} / ${scenario.visualState}',
          );
        }
      }
    },
  );

  testWidgets(
    '720x1280 compact chrome keeps top controls clear of title and star count',
    (tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final route = WordHuntKayipSehirContent.kayipSehir;
      await _pumpRoute(
        tester,
        route: route,
        theme: WordHuntKayipSehirVisualTheme.production,
        progress: _progressThrough(route, 9),
      );

      final back = find.byKey(const Key('word_hunt_themed_chrome_back'));
      final info = find.byKey(const Key('word_hunt_themed_chrome_info'));
      final backVisual = find.byKey(
        const Key('word_hunt_reference_back_visual_control'),
      );
      final infoVisual = find.byKey(
        const Key('word_hunt_reference_info_visual_control'),
      );
      final title = find.byKey(const Key('word_hunt_reusable_route_title'));
      final stars = find.byKey(const Key('word_hunt_reusable_route_stars'));

      final backVisualRect = tester.getRect(backVisual);
      final infoVisualRect = tester.getRect(infoVisual);
      final titleRect = tester.getRect(title);
      final starsRect = tester.getRect(stars);

      expect(backVisualRect.overlaps(titleRect), isFalse);
      expect(infoVisualRect.overlaps(starsRect), isFalse);
      expect(tester.getSize(back).shortestSide, greaterThanOrEqualTo(48));
      expect(tester.getSize(info).shortestSide, greaterThanOrEqualTo(48));
      expect(tester.getSize(backVisual).shortestSide, 40);
      expect(tester.getSize(infoVisual).shortestSide, 40);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '1080x2400 edge ambient uses a real overlap feather without mirror/flip',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final route = WordHuntGunesImparatorluguContent.gunesImparatorlugu;
      final theme = WordHuntGunesImparatorluguVisualTheme.production;
      await _pumpRoute(
        tester,
        route: route,
        theme: theme,
        progress: _progressThrough(route, 9),
      );

      expect(
        theme.tallAmbientMode,
        WordHuntTallAmbientMode.edgeDerivedLowFrequency,
      );
      final ambientWidgets = tester
          .widgetList<WordHuntEdgeDerivedAmbient>(
            find.byType(WordHuntEdgeDerivedAmbient),
          )
          .toList(growable: false);
      expect(ambientWidgets, hasLength(2));
      for (final ambient in ambientWidgets) {
        expect(ambient.featherFraction, greaterThan(0.30));
        expect(ambient.featherFraction, lessThanOrEqualTo(1));
      }

      final source = File(
        'lib/word_hunt/word_hunt_edge_ambient.dart',
      ).readAsStringSync();
      expect(source, isNot(contains('Matrix4.diagonal3Values')));
      expect(source, isNot(contains('Transform.flip')));
      expect(source, isNot(contains('scaleY: -1')));
      expect(tester.takeException(), isNull);
    },
  );
}

WordHuntProgressSnapshot _progressThrough(
  WordHuntRouteDefinition route,
  int completedCount, {
  int levelTenStars = 3,
}) {
  return WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      for (final level in route.levels.take(completedCount))
        level.id: level.index == 10 ? levelTenStars : 3,
    },
  );
}

Future<void> _pumpRoute(
  WidgetTester tester, {
  required WordHuntRouteDefinition route,
  required WordHuntRouteVisualTheme theme,
  required WordHuntProgressSnapshot progress,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WordHuntThemedProductionRouteScreen(
        route: route,
        visualTheme: theme,
        progress: progress,
        onBack: () {},
        onInfo: () {},
        onLevelTap: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}
