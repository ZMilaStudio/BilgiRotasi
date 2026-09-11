import 'package:bilgi_rotasi/word_hunt/word_hunt_progress.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_map_v2_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const proofProgress = WordHuntProgressSnapshot(
    bestStarsByLevelId: <String, int>{
      'baslangic-1': 3,
      'baslangic-2': 3,
      'baslangic-3': 3,
      'baslangic-4': 3,
      'baslangic-5': 3,
      'baslangic-6': 3,
      'baslangic-7': 3,
    },
  );

  testWidgets('reference layout keeps the full route inside the initial phone view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntRouteMapV2Screen(progress: proofProgress),
      ),
    );
    await tester.pumpAndSettle();

    final level10 = find.byKey(const Key('word_hunt_v2_level_10'));
    final book = find.byKey(const Key('word_hunt_v2_book'));
    expect(tester.getBottomRight(level10).dy, lessThan(800));
    expect(tester.getBottomRight(book).dy, lessThan(800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('special stop labels follow the approved right-side composition', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntRouteMapV2Screen(progress: proofProgress),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getCenter(find.text('MEYDAN OKUMA')).dx,
        greaterThan(tester.getCenter(find.text('5')).dx));
    expect(tester.getCenter(find.text('BONUS DURAK')).dx,
        greaterThan(tester.getCenter(find.text('8')).dx));
    expect(tester.getCenter(find.text('ROTA FİNALİ')).dx,
        greaterThan(tester.getCenter(find.text('10')).dx));

    expect(find.text('Fener'), findsNothing);
    expect(find.text('Liman'), findsNothing);
    expect(find.text('Hazine'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('route geometry follows the latest user harbor reference', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: WordHuntRouteMapV2Screen(progress: proofProgress),
      ),
    );
    await tester.pumpAndSettle();

    Offset center(int level) =>
        tester.getCenter(find.byKey(Key('word_hunt_v2_level_$level')));

    expect(center(4).dx, greaterThan(center(3).dx));
    expect(center(5).dy, lessThan(center(4).dy));
    expect(center(5).dx, lessThan(center(4).dx));
    expect(center(6).dx, lessThan(center(5).dx));
    expect(center(6).dy, greaterThan(center(5).dy));
    expect(center(7).dx, greaterThan(center(6).dx));
    expect(center(7).dx - center(9).dx, greaterThan(40));
    expect(center(8).dx, greaterThan(center(7).dx));
    expect(center(9).dx, lessThan(center(8).dx));
    expect(center(10).dx, greaterThan(center(9).dx));
    expect(center(10).dy, greaterThan(center(9).dy));
    expect(tester.takeException(), isNull);
  });
}
