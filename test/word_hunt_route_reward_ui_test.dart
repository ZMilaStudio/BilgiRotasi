import 'package:bilgi_rotasi/word_hunt/word_hunt_gunes_imparatorlugu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_completion_dialogs.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_rewards.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_selector.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF071426),
          body: Center(child: dialog),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('incomplete final shows exact remaining-star explanation only', (
    tester,
  ) async {
    await pumpDialog(
      tester,
      const WordHuntFinalIncompleteDialog(
        route: WordHuntStarterContent.baslangicLimani,
        totalStars: 17,
      ),
    );

    expect(find.text('Final Tamamlandı'), findsOneWidget);
    expect(
      find.text('Rotayı tamamlamak için 1 yıldız daha kazan.'),
      findsOneWidget,
    );
    expect(find.text('17 / 18 yıldız'), findsOneWidget);
    expect(find.text('Rotaya Dön'), findsOneWidget);
    expect(find.text('Rozet Kazandın'), findsNothing);
    expect(find.text('Rota Tamamlandı!'), findsNothing);
  });

  testWidgets('real route ceremony shows reward next route and both CTAs', (
    tester,
  ) async {
    final reward = WordHuntRouteRewardCatalog.forRoute(
      WordHuntStarterContent.baslangicLimani,
    )!;
    await pumpDialog(
      tester,
      WordHuntRouteCompletionDialog(
        route: WordHuntStarterContent.baslangicLimani,
        reward: reward,
        totalStars: 18,
        routeColors: WordHuntRouteCatalog.starter.colors,
        nextRouteTitle: 'Gökyüzü Adaları',
      ),
    );

    expect(find.text('Rota Tamamlandı!'), findsOneWidget);
    expect(find.text('Başlangıç Limanı'), findsOneWidget);
    expect(find.text('Rozet Kazandın'), findsOneWidget);
    expect(find.text('Kelime Yolcusu'), findsOneWidget);
    expect(find.text('18 / 90 yıldız'), findsOneWidget);
    expect(find.text('Gökyüzü Adaları açıldı.'), findsOneWidget);
    expect(find.text('Yeni Rotayı Gör'), findsOneWidget);
    expect(find.text('Rotaya Dön'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_route_reward_icon')),
      findsOneWidget,
    );
  });

  testWidgets('Kadim ceremony now announces Kristal as next route', (
    tester,
  ) async {
    final reward = WordHuntRouteRewardCatalog.forRoute(
      WordHuntOrman2Content.orman2,
    )!;
    await pumpDialog(
      tester,
      WordHuntRouteCompletionDialog(
        route: WordHuntOrman2Content.orman2,
        reward: reward,
        totalStars: 25,
        routeColors: WordHuntRouteCatalog.orman2Pilot.colors,
        nextRouteTitle: 'Kristal Vadisi',
      ),
    );

    expect(find.text('Rota Tamamlandı!'), findsOneWidget);
    expect(find.text('Kadim Orman'), findsOneWidget);
    expect(find.text('Kadim Orman Kaşifi'), findsOneWidget);
    expect(find.text('Kristal Vadisi açıldı.'), findsOneWidget);
    expect(find.text('Tüm mevcut rotaları tamamladın.'), findsNothing);
    expect(find.text('Yeni Rotayı Gör'), findsOneWidget);
    expect(find.text('Rotaya Dön'), findsOneWidget);
  });

  testWidgets('Kristal ceremony now announces Kayıp instead of terminal', (
    tester,
  ) async {
    final reward = WordHuntRouteRewardCatalog.forRoute(
      WordHuntKristalContent.kristalVadisi,
    )!;
    await pumpDialog(
      tester,
      WordHuntRouteCompletionDialog(
        route: WordHuntKristalContent.kristalVadisi,
        reward: reward,
        totalStars: 21,
        routeColors: WordHuntRouteCatalog.kristal.colors,
        nextRouteTitle: 'Kayıp Şehir',
      ),
    );

    expect(find.text('Rota Tamamlandı!'), findsOneWidget);
    expect(find.text('Kristal Vadisi'), findsOneWidget);
    expect(find.text('Kristal Kaşifi'), findsOneWidget);
    expect(find.text('Kayıp Şehir açıldı.'), findsOneWidget);
    expect(find.text('Tüm mevcut rotaları tamamladın.'), findsNothing);
    expect(find.text('Yeni Rotayı Gör'), findsOneWidget);
    expect(find.text('Rotaya Dön'), findsOneWidget);
  });

  testWidgets('Güneş ceremony owns exact terminal copy and reward', (
    tester,
  ) async {
    final reward = WordHuntRouteRewardCatalog.forRoute(
      WordHuntGunesImparatorluguContent.gunesImparatorlugu,
    )!;
    await pumpDialog(
      tester,
      WordHuntRouteCompletionDialog(
        route: WordHuntGunesImparatorluguContent.gunesImparatorlugu,
        reward: reward,
        totalStars: 1,
        routeColors: WordHuntRouteCatalog.gunesImparatorlugu.colors,
      ),
    );

    expect(find.text('Rota Tamamlandı!'), findsOneWidget);
    expect(find.text('Güneş İmparatorluğu'), findsOneWidget);
    expect(find.text('Güneş Kaşifi'), findsOneWidget);
    expect(find.text('Tüm mevcut rotaları tamamladın.'), findsOneWidget);
    expect(find.text('Yeni Rotayı Gör'), findsNothing);
    expect(find.text('Rotaya Dön'), findsOneWidget);
  });

  testWidgets('Kadim to Kristal ceremony is compact-height scroll safe', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final reward = WordHuntRouteRewardCatalog.forRoute(
      WordHuntOrman2Content.orman2,
    )!;
    await pumpDialog(
      tester,
      WordHuntRouteCompletionDialog(
        route: WordHuntOrman2Content.orman2,
        reward: reward,
        totalStars: 25,
        routeColors: WordHuntRouteCatalog.orman2Pilot.colors,
        nextRouteTitle: 'Kristal Vadisi',
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Kristal Vadisi açıldı.'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_show_new_route')), findsOneWidget);
  });

  testWidgets('Kristal to Kayıp ceremony is compact-height scroll safe', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final reward = WordHuntRouteRewardCatalog.forRoute(
      WordHuntKristalContent.kristalVadisi,
    )!;
    await pumpDialog(
      tester,
      WordHuntRouteCompletionDialog(
        route: WordHuntKristalContent.kristalVadisi,
        reward: reward,
        totalStars: 21,
        routeColors: WordHuntRouteCatalog.kristal.colors,
        nextRouteTitle: 'Kayıp Şehir',
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Kayıp Şehir açıldı.'), findsOneWidget);
    expect(find.text('Tüm mevcut rotaları tamamladın.'), findsNothing);
    expect(find.byKey(const Key('word_hunt_show_new_route')), findsOneWidget);
  });

  testWidgets('ceremony CTA results are exact', (tester) async {
    WordHuntRouteCompletionAction? action;
    final reward = WordHuntRouteRewardCatalog.forRoute(
      WordHuntStarterContent.baslangicLimani,
    )!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              key: const Key('open_ceremony'),
              onPressed: () async {
                action = await showDialog<WordHuntRouteCompletionAction>(
                  context: context,
                  builder: (_) => WordHuntRouteCompletionDialog(
                    route: WordHuntStarterContent.baslangicLimani,
                    reward: reward,
                    totalStars: 18,
                    routeColors: WordHuntRouteCatalog.starter.colors,
                    nextRouteTitle: 'Gökyüzü Adaları',
                  ),
                );
              },
              child: const Text('Aç'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open_ceremony')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('word_hunt_show_new_route')));
    await tester.pumpAndSettle();
    expect(action, WordHuntRouteCompletionAction.showRouteSelector);

    action = null;
    await tester.tap(find.byKey(const Key('open_ceremony')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('word_hunt_route_completion_return')),
    );
    await tester.pumpAndSettle();
    expect(action, WordHuntRouteCompletionAction.returnToRoute);
  });

  testWidgets(
    'earned reward shows Rozet kazanıldı without changing unlocked tap',
    (tester) async {
      WordHuntRouteCatalogEntry? tapped;
      const progress = WordHuntProgressSnapshot(
        unlockedRouteRewardIds: <String>{'badge-kelime-yolcusu'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WordHuntRouteSelector(
            progress: progress,
            onRouteTap: (entry) => tapped = entry,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rozet kazanıldı'), findsOneWidget);
      expect(
        find.byKey(
          const Key('word_hunt_route_reward_earned_badge-kelime-yolcusu'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('word_hunt_route_card_starter')));
      await tester.pump();
      expect(tapped, same(WordHuntRouteCatalog.starter));
    },
  );

  testWidgets('reward not earned shows no indicator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteSelector(
          progress: const WordHuntProgressSnapshot(),
          onRouteTap: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rozet kazanıldı'), findsNothing);
  });

  testWidgets('legacy inconsistent locked reward never bypasses route lock', (
    tester,
  ) async {
    WordHuntRouteCatalogEntry? tapped;
    const progress = WordHuntProgressSnapshot(
      unlockedRouteRewardIds: <String>{'badge-gokyuzu-kasifi'},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntRouteSelector(
          progress: progress,
          onRouteTap: (entry) => tapped = entry,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const Key('word_hunt_route_reward_earned_badge-gokyuzu-kasifi'),
      ),
      findsOneWidget,
    );
    expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isFalse);

    await tester.tap(
      find.byKey(const Key('word_hunt_route_card_gokyuzu')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tapped, isNull);
  });
}
