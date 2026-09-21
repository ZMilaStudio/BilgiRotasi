import 'package:bilgi_rotasi/word_hunt/word_hunt_gameplay_flow.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpFlow(
    WidgetTester tester, {
    WordHuntProgressSnapshot initialProgress = const WordHuntProgressSnapshot(),
    WordHuntGameplayLevelBuilder? levelBuilder,
  }) async {
    await tester.binding.setSurfaceSize(const Size(540, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: WordHuntGameplayFlow(
          initialProgress: initialProgress,
          levelBuilder: levelBuilder,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('empty route Node 1 ile production gameplay açar', (
    tester,
  ) async {
    await pumpFlow(tester);
    expect(
      find.byKey(const Key('word_hunt_master_art_level_2_locked')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
    await tester.tap(
      find.byKey(const Key('word_hunt_pixel_proof_level_1')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.byType(WordHuntLevelProductionScreen), findsOneWidget);
    expect(find.text('Bölüm 1'), findsOneWidget);
  });

  testWidgets('gerçek result progress kaydeder ve Node 2 açılır', (
    tester,
  ) async {
    await pumpFlow(
      tester,
      levelBuilder:
          (context, level, infoCards) => Scaffold(
            body: FilledButton(
              key: const Key('fake_result'),
              onPressed:
                  () => Navigator.of(context).pop(
                    WordHuntLevelPlayResult(
                      levelId: level.id,
                      stars: 3,
                      unlockedInfoCardIds: const <String>{},
                    ),
                  ),
              child: const Text('Sonuç'),
            ),
          ),
    );

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('fake_result')));
    await tester.pumpAndSettle();

    expect(find.text('3 / 60'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_master_art_level_2_locked')),
      findsNothing,
    );
  });

  testWidgets('bir yıldız sonucu da Node 2 kilidini açar', (tester) async {
    await pumpFlow(
      tester,
      levelBuilder:
          (context, level, infoCards) => Scaffold(
            body: FilledButton(
              key: const Key('fake_one_star_result'),
              onPressed:
                  () => Navigator.of(context).pop(
                    WordHuntLevelPlayResult(
                      levelId: level.id,
                      stars: 1,
                      unlockedInfoCardIds: const <String>{},
                    ),
                  ),
              child: const Text('Bir yıldız'),
            ),
          ),
    );

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('fake_one_star_result')));
    await tester.pumpAndSettle();

    expect(find.text('1 / 60'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_master_art_level_2_locked')),
      findsNothing,
    );
  });

  testWidgets('replay düşük besti düşürmez, yüksek sonuç besti yükseltir', (
    tester,
  ) async {
    var nextStars = 1;
    await pumpFlow(
      tester,
      initialProgress: const WordHuntProgressSnapshot(
        bestStarsByLevelId: <String, int>{'baslangic-1': 2},
      ),
      levelBuilder:
          (context, level, infoCards) => Scaffold(
            body: FilledButton(
              key: const Key('fake_result'),
              onPressed:
                  () => Navigator.of(context).pop(
                    WordHuntLevelPlayResult(
                      levelId: level.id,
                      stars: nextStars,
                      unlockedInfoCardIds: const <String>{},
                    ),
                  ),
              child: const Text('Sonuç'),
            ),
          ),
    );

    Future<void> play() async {
      await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('fake_result')));
      await tester.pumpAndSettle();
    }

    await play();
    expect(find.text('2 / 60'), findsOneWidget);
    nextStars = 3;
    await play();
    expect(find.text('3 / 60'), findsOneWidget);
  });

  testWidgets('null dönüş route progressini değiştirmez', (tester) async {
    await pumpFlow(
      tester,
      levelBuilder:
          (context, level, infoCards) => Scaffold(
            body: FilledButton(
              key: const Key('fake_exit'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Çık'),
            ),
          ),
    );

    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('fake_exit')));
    await tester.pumpAndSettle();

    expect(find.text('0 / 60'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_master_art_level_2_locked')),
      findsOneWidget,
    );
  });

  testWidgets('production yarım attemptten çıkış progress kaydetmez', (
    tester,
  ) async {
    await pumpFlow(tester);
    await tester.tap(find.byKey(const Key('word_hunt_pixel_proof_level_1')));
    await tester.pumpAndSettle();

    final start = tester.getCenter(
      find.byKey(const Key('word_hunt_production_cell_0_0')),
    );
    final end = tester.getCenter(
      find.byKey(const Key('word_hunt_production_cell_0_3')),
    );
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(end);
    await gesture.up();
    await tester.pump();

    await tester.tap(find.byKey(const Key('word_hunt_production_back')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('word_hunt_production_exit_continue')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WordHuntLevelProductionScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('word_hunt_production_back')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('word_hunt_production_exit_confirm')),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 / 60'), findsOneWidget);
    expect(
      find.byKey(const Key('word_hunt_master_art_level_2_locked')),
      findsOneWidget,
    );
  });
}
