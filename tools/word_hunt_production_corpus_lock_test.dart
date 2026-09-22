import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'word_hunt_corpus_support.dart';

void main() {
  final lockFile = File('tools/word_hunt_production_corpus.lock.json');

  test('checked production corpus lock exactly matches Dart authority', () {
    final generated = buildProductionCorpusLock();
    final checked = jsonDecode(lockFile.readAsStringSync());

    expect(canonicalCorpusJson(checked), canonicalCorpusJson(generated));
    expect(
      checked['sourceDigest'],
      productionCorpusSourceDigest(Map<String, Object?>.from(checked as Map)),
    );
  });

  test('production corpus generation is deterministic', () {
    final first = prettyCorpusJson(buildProductionCorpusLock());
    final second = prettyCorpusJson(buildProductionCorpusLock());
    expect(second, first);
  });

  test('current production corpus is 8 routes and 100 available levels', () {
    final lock = buildProductionCorpusLock();
    final routes = (lock['routes']! as List).cast<Map<String, Object?>>();

    expect(routes, hasLength(8));
    expect(
      routes.fold<int>(
        0,
        (total, route) => total + (route['availableLevelCount']! as int),
      ),
      100,
    );

    final starter = routes.firstWhere(
      (route) => route['routeId'] == 'baslangic-limani',
    );
    expect(starter['availableLevelCount'], 30);
    expect(starter['plannedLevelCount'], 100);
    expect(starter['reservedWordCount'], 196);

    final levels = (starter['levels']! as List).cast<Map<String, Object?>>();
    expect(
      levels.map((level) => level['localIndex']),
      containsAll(<int>[11, 20, 21, 30]),
    );

    final words = (starter['reservedWords']! as List).cast<String>();
    expect(words, containsAll(<String>['BARDAK', 'MANDAL', 'ŞEMSİYE']));
  });

  test('Turkish normalization parity remains explicit', () {
    expect(normalizeCorpusWord('i'), 'İ');
    expect(normalizeCorpusWord('ı'), 'I');
    expect(normalizeCorpusWord('İ'), 'İ');
    expect(normalizeCorpusWord('I'), 'I');
    expect(normalizeCorpusWord('  incir  '), 'İNCİR');
  });
}
