import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_gokyuzu_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman2_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_orman_content.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_production_entry_screen.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_starter_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final entrySource = File(
    'lib/word_hunt/word_hunt_production_entry_screen.dart',
  ).readAsStringSync();

  Future<void> pumpEntry(
    WidgetTester tester, {
    required WordHuntRouteDefinition route,
    required List<WordHuntInfoCard> infoCards,
    required String ownerUid,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntProductionEntryScreen(
          ownerUid: ownerUid,
          route: route,
          infoCards: infoCards,
          routeSelectionEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> completeLevel(
    WidgetTester tester, {
    required Key levelKey,
    required String levelId,
    Set<String> unlockedInfoCardIds = const <String>{},
  }) async {
    await tester.tap(find.byKey(levelKey));
    await tester.pumpAndSettle();
    expect(find.byType(WordHuntLevelProductionScreen), findsOneWidget);

    Navigator.of(
      tester.element(find.byType(WordHuntLevelProductionScreen)),
    ).pop(
      WordHuntLevelPlayResult(
        levelId: levelId,
        stars: 1,
        unlockedInfoCardIds: unlockedInfoCardIds,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('fresh Orman Yolu book reports no unlocked info cards', (
    tester,
  ) async {
    await pumpEntry(
      tester,
      route: WordHuntOrmanContent.ormanYolu,
      infoCards: WordHuntOrmanContent.infoCards,
      ownerUid: 'book-fresh-orman',
    );

    await tester.tap(find.byKey(const Key('word_hunt_themed_chrome_book')));
    await tester.pump();

    expect(find.text('Henüz bilgi kartı açılmadı.'), findsOneWidget);
    expect(find.byKey(const Key('word_hunt_unlocked_info_cards')), findsNothing);
  });

  testWidgets('Orman Yolu book shows unlocked Orman card and isolates Kadim card', (
    tester,
  ) async {
    const fact =
        'Ağaçların kökleri su ve mineralleri alırken gövdeleri yaprakları ışığa doğru taşır.';
    await pumpEntry(
      tester,
      route: WordHuntOrmanContent.ormanYolu,
      infoCards: WordHuntOrmanContent.infoCards,
      ownerUid: 'book-orman-isolation',
    );

    await completeLevel(
      tester,
      levelKey: const Key('word_hunt_reusable_level_1'),
      levelId: 'orman-yolu-01',
      unlockedInfoCardIds: const <String>{
        'orman-info-agac',
        'kadim-info-egrelti',
      },
    );

    await tester.tap(find.byKey(const Key('word_hunt_themed_chrome_book')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word_hunt_unlocked_info_cards')), findsOneWidget);
    expect(find.text('Ağaç'), findsOneWidget);
    expect(find.text('$fact\nDoğa'), findsOneWidget);
    expect(find.text('Eğrelti'), findsNothing);
    expect(
      find.textContaining(
        'Eğreltiler çiçek ve tohum oluşturmak yerine sporlarla çoğalan',
      ),
      findsNothing,
    );
  });

  testWidgets('Kadim Orman book shows unlocked Kadim card and isolates Orman card', (
    tester,
  ) async {
    const fact =
        'Eğreltiler çiçek ve tohum oluşturmak yerine sporlarla çoğalan damarlı bitkilerdir.';
    await pumpEntry(
      tester,
      route: WordHuntOrman2Content.orman2,
      infoCards: WordHuntOrman2Content.infoCards,
      ownerUid: 'book-kadim-isolation',
    );

    await completeLevel(
      tester,
      levelKey: const Key('word_hunt_reusable_level_1'),
      levelId: 'orman-2-01',
      unlockedInfoCardIds: const <String>{
        'kadim-info-egrelti',
        'orman-info-agac',
      },
    );

    await tester.tap(find.byKey(const Key('word_hunt_themed_chrome_book')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word_hunt_unlocked_info_cards')), findsOneWidget);
    expect(find.text('Eğrelti'), findsOneWidget);
    expect(find.text('$fact\nDoğa'), findsOneWidget);
    expect(find.text('Ağaç'), findsNothing);
    expect(
      find.textContaining(
        'Ağaçların kökleri su ve mineralleri alırken',
      ),
      findsNothing,
    );
  });

  testWidgets('Başlangıç Limanı keeps the generic unlocked-card book flow', (
    tester,
  ) async {
    const fact = 'Deniz suyu, çözünmüş tuzlar nedeniyle genellikle tuzludur.';
    await pumpEntry(
      tester,
      route: WordHuntStarterContent.baslangicLimani,
      infoCards: WordHuntStarterContent.infoCards,
      ownerUid: 'book-starter-regression',
    );

    await completeLevel(
      tester,
      levelKey: const Key('word_hunt_pixel_proof_level_1'),
      levelId: 'baslangic-1',
    );
    await completeLevel(
      tester,
      levelKey: const Key('word_hunt_pixel_proof_level_2'),
      levelId: 'baslangic-2',
      unlockedInfoCardIds: const <String>{'info-deniz'},
    );

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_book')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word_hunt_unlocked_info_cards')), findsOneWidget);
    expect(find.text('Deniz'), findsOneWidget);
    expect(find.text('$fact\nDoğa'), findsOneWidget);
  });

  testWidgets('Gökyüzü keeps the generic unlocked-card book flow', (
    tester,
  ) async {
    const fact =
        'Rüzgâr, havanın basınç farkları nedeniyle hareket etmesiyle oluşur.';
    await pumpEntry(
      tester,
      route: WordHuntGokyuzuContent.gokyuzuAdalari,
      infoCards: WordHuntGokyuzuContent.infoCards,
      ownerUid: 'book-gokyuzu-regression',
    );

    await completeLevel(
      tester,
      levelKey: const Key('word_hunt_gokyuzu_master_art_level_1'),
      levelId: 'gokyuzu-1',
      unlockedInfoCardIds: const <String>{'gok-info-ruzgar'},
    );

    await tester.tap(
      find.byKey(const Key('word_hunt_gokyuzu_master_art_book')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word_hunt_unlocked_info_cards')), findsOneWidget);
    expect(find.text('Rüzgâr'), findsOneWidget);
    expect(find.text('$fact\nDoğa'), findsOneWidget);
  });

  test('production book has no forest-theme or legacy topic dependency', () {
    expect(entrySource, isNot(contains("route.theme == 'orman'")));
    expect(entrySource, isNot(contains('_showOrmanTopicBook')));
    expect(entrySource, isNot(contains('_TopicGuide')));
    expect(entrySource, isNot(contains('_ormanTopicGuides')));
    expect(
      entrySource,
      contains(
        '_activeInfoCards\n        .where((card) => '
        '_progress.unlockedInfoCardIds.contains(card.id))',
      ),
    );
  });
}
