import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_kristal_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_selector.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final starter = WordHuntStarterContent.baslangicLimani;
  final sky = WordHuntGokyuzuContent.gokyuzuAdalari;
  final forest = WordHuntOrmanContent.ormanYolu;
  final ancient = WordHuntOrman2Content.orman2;
  final crystal = WordHuntKristalContent.kristalVadisi;

  Map<String, int> completedRouteStars(WordHuntRouteDefinition route) {
    final stars = <String, int>{for (final level in route.levels) level.id: 1};
    var remaining = route.unlockStarsRequired - route.levels.length;
    for (final level in route.levels) {
      if (remaining <= 0) break;
      final add = remaining > 2 ? 2 : remaining;
      stars[level.id] = 1 + add;
      remaining -= add;
    }
    return stars;
  }

  Map<String, int> allLevelsAtTotal(
    WordHuntRouteDefinition route,
    int targetStars,
  ) {
    assert(targetStars >= route.levels.length);
    assert(targetStars <= route.maximumStars);
    final stars = <String, int>{for (final level in route.levels) level.id: 1};
    var remaining = targetStars - route.levels.length;
    for (final level in route.levels) {
      if (remaining <= 0) break;
      final add = remaining > 2 ? 2 : remaining;
      stars[level.id] = 1 + add;
      remaining -= add;
    }
    return stars;
  }

  WordHuntProgressSnapshot progressWith({
    Map<String, int> stars = const <String, int>{},
    Set<String> rewards = const <String>{},
  }) {
    return WordHuntProgressSnapshot(
      bestStarsByLevelId: stars,
      unlockedRouteRewardIds: rewards,
    );
  }

  Map<String, int> mergeStars(Iterable<Map<String, int>> parts) {
    return <String, int>{for (final part in parts) ...part};
  }

  Future<void> pumpSelector(
    WidgetTester tester,
    WordHuntProgressSnapshot progress, {
    Size size = const Size(411, 731),
    double textScale = 1,
    ValueChanged<WordHuntRouteCatalogEntry>? onRouteTap,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: WordHuntRouteSelector(
            progress: progress,
            onRouteTap: onRouteTap ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder card(String key) => find.byKey(Key('word_hunt_route_card_$key'));

  Finder progressText(String key) =>
      find.byKey(Key('word_hunt_route_progress_$key'));

  group('guided recommended route states', () {
    testWidgets('STATE A fresh user recommends starter as Sıradaki', (
      tester,
    ) async {
      await pumpSelector(tester, const WordHuntProgressSnapshot());

      expect(find.text('Sıradaki'), findsOneWidget);
      expect(
        find.descendant(of: card('starter'), matching: find.text('Sıradaki')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card('gokyuzu'), matching: find.text('Kilitli')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card('orman'), matching: find.text('Kilitli')),
        findsOneWidget,
      );
      await tester.ensureVisible(card('orman2'));
      expect(
        find.descendant(of: card('orman2'), matching: find.text('Kilitli')),
        findsOneWidget,
      );
    });

    testWidgets(
      'STATE B starter final complete at 17 stars stays incomplete and recommends Devam Et',
      (tester) async {
        final progress = progressWith(stars: allLevelsAtTotal(starter, 17));
        expect(
          WordHuntRouteProgressEngine.isRouteComplete(starter, progress),
          isFalse,
        );

        await pumpSelector(tester, progress);

        expect(
          find.descendant(of: card('starter'), matching: find.text('Devam Et')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: card('gokyuzu'), matching: find.text('Kilitli')),
          findsOneWidget,
        );
      },
    );

    testWidgets('STATE C starter complete recommends sky as Sıradaki', (
      tester,
    ) async {
      final progress = progressWith(stars: completedRouteStars(starter));
      await pumpSelector(tester, progress);

      expect(
        find.descendant(of: card('starter'), matching: find.text('Tamamlandı')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card('gokyuzu'), matching: find.text('Sıradaki')),
        findsOneWidget,
      );
    });

    testWidgets('STATE D sky complete recommends forest as Sıradaki', (
      tester,
    ) async {
      final progress = progressWith(
        stars: mergeStars(<Map<String, int>>[
          completedRouteStars(starter),
          completedRouteStars(sky),
        ]),
      );
      await pumpSelector(tester, progress);

      expect(
        find.descendant(of: card('orman'), matching: find.text('Sıradaki')),
        findsOneWidget,
      );
    });

    testWidgets('STATE E forest complete recommends ancient as Sıradaki', (
      tester,
    ) async {
      final progress = progressWith(
        stars: mergeStars(<Map<String, int>>[
          completedRouteStars(starter),
          completedRouteStars(sky),
          completedRouteStars(forest),
        ]),
      );
      await pumpSelector(tester, progress);

      await tester.ensureVisible(card('orman2'));
      expect(
        find.descendant(of: card('orman2'), matching: find.text('Sıradaki')),
        findsOneWidget,
      );
    });

    testWidgets('STATE F Kadim complete recommends Kristal as Sıradaki', (
      tester,
    ) async {
      final progress = progressWith(
        stars: mergeStars(<Map<String, int>>[
          completedRouteStars(starter),
          completedRouteStars(sky),
          completedRouteStars(forest),
          completedRouteStars(ancient),
        ]),
      );
      await pumpSelector(tester, progress);

      await tester.ensureVisible(card('kristal'));
      expect(
        find.descendant(of: card('kristal'), matching: find.text('Sıradaki')),
        findsOneWidget,
      );
      expect(find.text('Tüm mevcut rotaları tamamladın.'), findsNothing);
    });

    testWidgets('STATE G Kristal partial uses Devam Et', (tester) async {
      final progress = progressWith(
        stars: mergeStars(<Map<String, int>>[
          completedRouteStars(starter),
          completedRouteStars(sky),
          completedRouteStars(forest),
          completedRouteStars(ancient),
          <String, int>{crystal.levels.first.id: 2},
        ]),
      );
      await pumpSelector(tester, progress);
      await tester.ensureVisible(card('kristal'));
      expect(
        find.descendant(of: card('kristal'), matching: find.text('Devam Et')),
        findsOneWidget,
      );
    });

    testWidgets('STATE H all five legacy routes complete recommends Kayıp', (
      tester,
    ) async {
      final progress = progressWith(
        stars: mergeStars(<Map<String, int>>[
          completedRouteStars(starter),
          completedRouteStars(sky),
          completedRouteStars(forest),
          completedRouteStars(ancient),
          completedRouteStars(crystal),
        ]),
      );
      await pumpSelector(tester, progress);
      await tester.ensureVisible(card('kayip-sehir'));
      expect(
        find.descendant(
          of: card('kayip-sehir'),
          matching: find.text('Sıradaki'),
        ),
        findsOneWidget,
      );
      expect(find.text('Devam Et'), findsNothing);
      expect(find.text('Tamamlandı'), findsNWidgets(5));
      expect(find.text('Tüm mevcut rotaları tamamladın.'), findsNothing);
    });

    testWidgets('partial next route uses Devam Et instead of Sıradaki', (
      tester,
    ) async {
      final progress = progressWith(
        stars: mergeStars(<Map<String, int>>[
          completedRouteStars(starter),
          <String, int>{sky.levels[0].id: 3, sky.levels[1].id: 3},
        ]),
      );
      await pumpSelector(tester, progress);

      expect(
        find.descendant(of: card('gokyuzu'), matching: find.text('Devam Et')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card('starter'), matching: find.text('Tamamlandı')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card('orman'), matching: find.text('Kilitli')),
        findsOneWidget,
      );
    });
  });

  group('locked unmet requirement presentation', () {
    testWidgets(
      'starter final complete at 17 shows 17 / 18 stars on sky lock',
      (tester) async {
        final progress = progressWith(stars: allLevelsAtTotal(starter, 17));
        await pumpSelector(tester, progress);

        expect(
          find.text('Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.'),
          findsOneWidget,
        );
        expect(
          tester.widget<Text>(progressText('gokyuzu')).data,
          '17 / 18 yıldız',
        );
        expect(
          find.descendant(
            of: card('gokyuzu'),
            matching: find.text('10 / 10 bölüm'),
          ),
          findsNothing,
        );
      },
    );

    testWidgets('sky final complete at 17 shows 17 / 18 stars on forest lock', (
      tester,
    ) async {
      final progress = progressWith(
        stars: mergeStars(<Map<String, int>>[
          completedRouteStars(starter),
          allLevelsAtTotal(sky, 17),
        ]),
      );
      await pumpSelector(tester, progress);

      expect(tester.widget<Text>(progressText('orman')).data, '17 / 18 yıldız');
      expect(
        find.descendant(
          of: card('orman'),
          matching: find.text('10 / 10 bölüm'),
        ),
        findsNothing,
      );
    });

    testWidgets('final incomplete keeps completed-level requirement progress', (
      tester,
    ) async {
      final progress = progressWith(
        stars: <String, int>{
          for (final level in starter.levels.take(8)) level.id: 1,
        },
      );
      await pumpSelector(tester, progress);

      expect(tester.widget<Text>(progressText('gokyuzu')).data, '8 / 10 bölüm');
      expect(
        find.descendant(
          of: card('gokyuzu'),
          matching: find.textContaining('/ 18 yıldız'),
        ),
        findsNothing,
      );
    });

    testWidgets('zero-star threshold forest to ancient stays level focused', (
      tester,
    ) async {
      final progress = progressWith(
        stars: mergeStars(<Map<String, int>>[
          completedRouteStars(starter),
          completedRouteStars(sky),
          <String, int>{for (final level in forest.levels.take(9)) level.id: 1},
        ]),
      );
      await pumpSelector(tester, progress);

      await tester.ensureVisible(card('orman2'));
      expect(tester.widget<Text>(progressText('orman2')).data, '9 / 10 bölüm');
      expect(
        find.descendant(
          of: card('orman2'),
          matching: find.textContaining('/ 18 yıldız'),
        ),
        findsNothing,
      );
    });
  });

  testWidgets('ordinal is visible in unlocked locked and completed cards', (
    tester,
  ) async {
    final progress = progressWith(
      stars: completedRouteStars(starter),
      rewards: <String>{starter.routeRewardId},
    );
    await pumpSelector(tester, progress);

    expect(find.text('İlk rota'), findsOneWidget);
    expect(find.text('İkinci rota'), findsOneWidget);
    expect(find.text('Üçüncü rota'), findsOneWidget);
    await tester.ensureVisible(card('orman2'));
    expect(find.text('Dördüncü rota'), findsOneWidget);
    await tester.ensureVisible(card('kristal'));
    expect(find.text('Beşinci rota'), findsOneWidget);
  });

  testWidgets(
    'locked tap gives exact reason but never calls route navigation',
    (tester) async {
      WordHuntRouteCatalogEntry? tapped;
      await pumpSelector(
        tester,
        const WordHuntProgressSnapshot(),
        onRouteTap: (entry) => tapped = entry,
      );

      await tester.tap(card('gokyuzu'));
      await tester.pump();

      expect(tapped, isNull);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text(
            'Başlangıç Limanı’nı tamamla ve en az 18 yıldız kazan.',
          ),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('complete and reward remain separate selector states', (
    tester,
  ) async {
    final completedWithoutReward = progressWith(
      stars: completedRouteStars(starter),
    );
    await pumpSelector(tester, completedWithoutReward);

    expect(
      find.descendant(of: card('starter'), matching: find.text('Tamamlandı')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: card('starter'),
        matching: find.text('Rozet kazanıldı'),
      ),
      findsNothing,
    );

    final withReward = progressWith(
      stars: completedRouteStars(starter),
      rewards: <String>{starter.routeRewardId},
    );
    await pumpSelector(tester, withReward);

    expect(
      find.descendant(of: card('starter'), matching: find.text('Tamamlandı')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: card('starter'),
        matching: find.text('Rozet kazanıldı'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'inconsistent locked earned reward never unlocks or recommends route',
    (tester) async {
      WordHuntRouteCatalogEntry? tapped;
      final progress = progressWith(rewards: <String>{sky.routeRewardId});
      await pumpSelector(
        tester,
        progress,
        onRouteTap: (entry) => tapped = entry,
      );

      expect(WordHuntRouteCatalog.gokyuzu.isUnlocked(progress), isFalse);
      expect(
        find.descendant(of: card('starter'), matching: find.text('Sıradaki')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card('gokyuzu'), matching: find.text('Kilitli')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card('gokyuzu'),
          matching: find.text('Rozet kazanıldı'),
        ),
        findsOneWidget,
      );

      await tester.tap(card('gokyuzu'));
      await tester.pump();
      expect(tapped, isNull);
    },
  );

  group('responsive selector layout', () {
    final sizes = <Size>[
      const Size(320, 640),
      const Size(360, 800),
      const Size(411, 731),
    ];

    for (final size in sizes) {
      testWidgets(
        '${size.width.toInt()} px renders guided worst-case without overflow',
        (tester) async {
          final progress = progressWith(
            stars: mergeStars(<Map<String, int>>[
              completedRouteStars(starter),
              <String, int>{sky.levels[0].id: 3, sky.levels[1].id: 3},
            ]),
            rewards: <String>{starter.routeRewardId},
          );

          await pumpSelector(tester, progress, size: size);

          expect(tester.takeException(), isNull);
          expect(card('starter'), findsOneWidget);
          expect(find.text('Devam Et'), findsOneWidget);
          expect(
            find.text('Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.'),
            findsOneWidget,
          );
          await tester.ensureVisible(card('orman2'));
          await tester.pumpAndSettle();
          expect(card('orman2'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('480 px keeps selector scrollable and reachable', (
      tester,
    ) async {
      await pumpSelector(
        tester,
        const WordHuntProgressSnapshot(),
        size: const Size(480, 800),
      );

      expect(tester.takeException(), isNull);
      await tester.ensureVisible(card('orman2'));
      await tester.pumpAndSettle();
      expect(card('orman2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320 px at 1.5 text scale grows vertically without overflow', (
      tester,
    ) async {
      final progress = progressWith(
        stars: completedRouteStars(starter),
        rewards: <String>{starter.routeRewardId},
      );
      await pumpSelector(
        tester,
        progress,
        size: const Size(320, 640),
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Tamamlandı'), findsOneWidget);
      expect(find.text('Rozet kazanıldı'), findsOneWidget);
      expect(
        find.text('Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.'),
        findsOneWidget,
      );
      await tester.ensureVisible(card('orman2'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('card semantics announce state reason and reward once', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    final progress = progressWith(
      stars: completedRouteStars(starter),
      rewards: <String>{starter.routeRewardId},
    );
    await pumpSelector(tester, progress);

    final starterNode = tester.getSemantics(
      find.byKey(const Key('word_hunt_route_semantics_starter')),
    );
    expect(starterNode.label, contains('Başlangıç Limanı'));
    expect(starterNode.label, contains('Tamamlandı'));
    expect(starterNode.label, contains('Rozet kazanıldı'));
    expect(starterNode.label, contains('Kelime Yolcusu'));
    expect(starterNode.label, contains('18 / 30 yıldız'));

    final forestNode = tester.getSemantics(
      find.byKey(const Key('word_hunt_route_semantics_orman')),
    );
    expect(forestNode.label, contains('Orman Yolu'));
    expect(forestNode.label, contains('Kilitli'));
    expect(
      forestNode.label,
      contains('Gökyüzü Adaları’nı tamamla ve en az 18 yıldız kazan.'),
    );
    expect(forestNode.label, contains('0 / 10 bölüm'));

    expect(find.bySemanticsLabel(RegExp(r'^Rozet kazanıldı')), findsNothing);

    semantics.dispose();
  });

  testWidgets(
    'locked Kadim keeps forest identity and a separate lock treatment',
    (tester) async {
      await pumpSelector(tester, const WordHuntProgressSnapshot());

      await tester.ensureVisible(card('orman2'));
      expect(
        find.descendant(
          of: card('orman2'),
          matching: find.byIcon(Icons.forest_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card('orman2'),
          matching: find.byIcon(Icons.lock_outline_rounded),
        ),
        findsWidgets,
      );
    },
  );
}
