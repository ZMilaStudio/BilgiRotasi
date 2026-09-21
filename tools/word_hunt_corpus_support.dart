import 'dart:convert';
import 'dart:io';

import 'package:bilgi_rotasi/word_hunt/word_hunt_models.dart';
import 'package:bilgi_rotasi/word_hunt/word_hunt_route_catalog.dart';
import 'package:crypto/crypto.dart';

const int wordHuntProductionCorpusSchemaVersion = 1;
const String wordHuntProductionCorpusKind =
    'WORD_HUNT_PRODUCTION_CORPUS_LOCK';
const String wordHuntProductionCorpusGeneratedBy =
    'tools/word_hunt_corpus_support.dart';

String normalizeCorpusWord(String value) {
  return value
      .trim()
      .replaceAll('i', 'İ')
      .replaceAll('ı', 'I')
      .toUpperCase();
}

String _sha256Text(String value) => sha256.convert(utf8.encode(value)).toString();

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final entries = value.entries
        .map(
          (entry) => MapEntry<String, Object?>(
            entry.key.toString(),
            _canonicalize(entry.value),
          ),
        )
        .toList()
      ..sort((left, right) => left.key.compareTo(right.key));
    return <String, Object?>{
      for (final entry in entries) entry.key: entry.value,
    };
  }
  if (value is Iterable) {
    return value.map<Object?>((item) => _canonicalize(item)).toList();
  }
  return value;
}

String canonicalCorpusJson(Object? value) => jsonEncode(_canonicalize(value));

String prettyCorpusJson(Object? value) =>
    const JsonEncoder.withIndent('  ').convert(value) + '\n';

Map<String, Object?> _starRulesProjection(WordHuntStarRules rules) {
  return <String, Object?>{
    'twoStarMaxMistakes': rules.twoStarMaxMistakes,
    'threeStarMaxMistakes': rules.threeStarMaxMistakes,
    'twoStarMaxSeconds': rules.twoStarMaxSeconds,
    'threeStarMaxSeconds': rules.threeStarMaxSeconds,
  };
}

Map<String, Object?> _levelProjection(WordHuntLevelDefinition level) {
  final projection = <String, Object?>{
    'localIndex': level.index,
    'levelId': level.id,
    'type': level.type.name,
    'grid': List<String>.unmodifiable(level.grid),
    'targetWords': level.targetWords
        .map(normalizeCorpusWord)
        .toList(growable: false),
    'bonusWords': level.bonusWords
        .map(normalizeCorpusWord)
        .toList(growable: false),
    'starRules': _starRulesProjection(level.starRules),
    'timeLimitSeconds': level.timeLimitSeconds,
    'gridHash': _sha256Text(level.grid.join('\n')),
  };
  projection['levelFingerprint'] = _sha256Text(canonicalCorpusJson(projection));
  return projection;
}

Map<String, Object?> _routeProjection(WordHuntRouteDefinition route) {
  final originsByWord = <String, Map<String, Object?>>{};

  for (final level in route.levels) {
    for (final entry in <(String, Iterable<String>)>[
      ('TARGET', level.targetWords),
      ('BONUS', level.bonusWords),
    ]) {
      for (final rawWord in entry.$2) {
        final word = normalizeCorpusWord(rawWord);
        final previous = originsByWord[word];
        if (previous != null) {
          throw StateError(
            'Production route duplicate: route=${route.id} word=$word '
            'existing=${previous['levelId']} '
            'new=${level.id}',
          );
        }
        originsByWord[word] = <String, Object?>{
          'word': word,
          'levelId': level.id,
          'localIndex': level.index,
          'role': entry.$1,
        };
      }
    }
  }

  final reservedWords = originsByWord.keys.toList()..sort();
  return <String, Object?>{
    'routeId': route.id,
    'availableLevelCount': route.availableLevelCount,
    'plannedLevelCount': route.plannedRouteLevelCount,
    'reservedWordCount': reservedWords.length,
    'reservedWords': reservedWords,
    'wordOrigins': reservedWords
        .map<Map<String, Object?>>((word) => originsByWord[word]!)
        .toList(growable: false),
    'levels': route.levels
        .map<Map<String, Object?>>(_levelProjection)
        .toList(growable: false),
  };
}

Map<String, Object?> buildProductionCorpusLock() {
  final routes = WordHuntRouteCatalog.entries
      .map((entry) => entry.route)
      .toList(growable: false);
  final result = <String, Object?>{
    'schemaVersion': wordHuntProductionCorpusSchemaVersion,
    'kind': wordHuntProductionCorpusKind,
    'generatedBy': wordHuntProductionCorpusGeneratedBy,
    'routeOrder': routes.map((route) => route.id).toList(growable: false),
    'routes': routes
        .map<Map<String, Object?>>(_routeProjection)
        .toList(growable: false),
  };
  result['sourceDigest'] = _sha256Text(canonicalCorpusJson(result));
  return result;
}

String productionCorpusSourceDigest(Map<String, Object?> lock) {
  final payload = Map<String, Object?>.from(lock)..remove('sourceDigest');
  return _sha256Text(canonicalCorpusJson(payload));
}

Future<void> main(List<String> args) async {
  final generated = buildProductionCorpusLock();

  if (args.length == 2 && args[0] == '--write') {
    await File(args[1]).writeAsString(prettyCorpusJson(generated));
    return;
  }

  if (args.length == 2 && args[0] == '--check') {
    final file = File(args[1]);
    final decoded = jsonDecode(await file.readAsString());
    if (canonicalCorpusJson(decoded) != canonicalCorpusJson(generated)) {
      stderr.writeln(
        'WORD_HUNT_PRODUCTION_CORPUS_LOCK: FAIL — checked lock differs from Dart production authority.',
      );
      exitCode = 2;
      return;
    }
    stdout.writeln(
      'WORD_HUNT_PRODUCTION_CORPUS_LOCK: PASS sourceDigest=${generated['sourceDigest']}',
    );
    return;
  }

  stdout.write(prettyCorpusJson(generated));
}
