import 'dart:io';

import 'package:bilgi_rotasi/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kelime Avı top-level product entry', () {
    test('product chooser iki eşit ana oyun alanını tanımlar', () {
      final screen = ProductModeEntryScreen(
        questionBank: QuestionBank(const <int, List<QuizQuestion>>{}),
        ownerUid: 'test-user',
      );

      expect(screen.ownerUid, 'test-user');

      final source = File('lib/product_mode_entry.dart').readAsStringSync();
      expect(source, contains("'BİLGİ YARIŞMASI'"));
      expect(source, contains("'KELİME AVI'"));
      expect(source, contains("'assets/branding/splash_logo.png'"));
      expect(source, contains("'Bilgi Rotası & Kelime Avı'"));
    });

    test('PlayCenter nested Kelime Avı entry artık yoktur', () {
      final source = File('lib/main_navigation.dart').readAsStringSync();
      final start = source.indexOf('class PlayCenterScreen');
      final end = source.indexOf('class DailyCenterScreen', start);
      expect(start, greaterThanOrEqualTo(0));
      expect(end, greaterThan(start));

      final playCenter = source.substring(start, end);
      expect(playCenter, isNot(contains("'word_hunt'")));
      expect(playCenter, isNot(contains('Kelime Avı')));
      expect(playCenter, contains('Standart Tahta Oyunu'));
      expect(playCenter, contains('Serbest Rota'));
      expect(playCenter, contains('Soru Maratonu'));
      expect(playCenter, contains('Meydan Okuma'));
      expect(playCenter, contains('PlayCenterEntryCatalog.liveDuelTitle'));
      expect(playCenter, contains('Diğer Oyun Modları'));
    });
  });
}
