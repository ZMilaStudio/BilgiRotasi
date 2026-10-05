import 'dart:convert';
import 'word_hunt_journey_save_v1.dart';

class WordHuntJourneySaveCodec {
  const WordHuntJourneySaveCodec();
  String encode(WordHuntJourneySaveV1 save) {
    Map<String, int> sorted(Map<String, int> values) => {
      for (final key in values.keys.toList()..sort()) key: values[key]!,
    };
    return jsonEncode({
      'schemaVersion': WordHuntJourneySaveV1.schemaVersion,
      'bestStarsByLevelId': sorted(save.bestStarsByStableId),
      'bestBonusByLevelId': sorted(save.bestBonusByStableId),
      'lastViewedLevelId': save.lastViewedLevelId,
    });
  }

  /// Null means corrupt/unsupported, never a partially salvaged save.
  WordHuntJourneySaveV1? decode(String input) {
    try {
      final raw = jsonDecode(input);
      if (_hasDuplicateKeys(input)) return null;
      if (raw is! Map<String, dynamic> ||
          raw['schemaVersion'] is! int ||
          raw['schemaVersion'] != 1)
        return null;
      Map<String, int> counts(Object? value) {
        if (value is! Map<String, dynamic>)
          throw const FormatException('Counts');
        return value.map((key, value) {
          if (value is! int)
            throw const FormatException('Integer count required');
          return MapEntry(key, value);
        });
      }

      final last = raw['lastViewedLevelId'];
      if (last != null && last is! String) return null;
      return WordHuntJourneySaveV1(
        bestStarsByStableId: counts(raw['bestStarsByLevelId']),
        bestBonusByStableId: counts(raw['bestBonusByLevelId']),
        lastViewedLevelId: last as String?,
      );
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  // jsonDecode otherwise silently keeps the last duplicate property. Inspect
  // object keys only after syntax validation; escaped aliases are the same key.
  bool _hasDuplicateKeys(String input) {
    final containers = <Set<String>?>[];
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '{') {
        containers.add(<String>{});
      } else if (char == '[') {
        containers.add(null);
      } else if (char == '}' || char == ']') {
        containers.removeLast();
      } else if (char == '"') {
        final start = i;
        i++;
        while (input[i] != '"') {
          if (input[i] == r'\') i++;
          i++;
        }
        var next = i + 1;
        while (next < input.length && input[next].trim().isEmpty) {
          next++;
        }
        if (next < input.length && input[next] == ':') {
          final key = jsonDecode(input.substring(start, i + 1)) as String;
          if (!containers.last!.add(key)) return true;
        }
      }
    }
    return false;
  }
}

abstract interface class JourneySaveRepository {
  Future<WordHuntJourneySaveV1?> load();
  Future<void> save(WordHuntJourneySaveV1 snapshot);
  Future<void> clear();
}

/// Isolated greenfield storage: no filesystem, preferences or schema 3 keys.
class InMemoryJourneySaveRepository implements JourneySaveRepository {
  InMemoryJourneySaveRepository({String? initialJson}) : _json = initialJson;
  String? _json;
  final _codec = const WordHuntJourneySaveCodec();
  @override
  Future<WordHuntJourneySaveV1?> load() async =>
      _json == null ? null : _codec.decode(_json!);
  @override
  Future<void> save(WordHuntJourneySaveV1 snapshot) async {
    _json = _codec.encode(snapshot);
  }

  @override
  Future<void> clear() async {
    _json = null;
  }
}
