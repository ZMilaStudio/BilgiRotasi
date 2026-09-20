import 'dart:convert';

import 'word_hunt_progress.dart';

class WordHuntProgressDecodeResult {
  const WordHuntProgressDecodeResult({
    required this.snapshot,
    required this.sourceSchemaVersion,
  });

  final WordHuntProgressSnapshot snapshot;
  final int sourceSchemaVersion;

  bool get requiresMigrationWriteback =>
      sourceSchemaVersion < WordHuntProgressCodec.schemaVersion;
}

class WordHuntProgressCodec {
  WordHuntProgressCodec._();

  static const int schemaVersion = 3;
  static const String _storagePrefix = 'bilgi_rotasi_word_hunt_progress_v1_';

  static String scopeForUid(String? uid) {
    final normalized = uid?.trim() ?? '';
    return normalized.isEmpty ? 'guest' : 'user_$normalized';
  }

  static String storageKeyForUid(String? uid) {
    return '$_storagePrefix${scopeForUid(uid)}';
  }

  static String encode(
    WordHuntProgressSnapshot snapshot, {
    required String ownerScope,
  }) {
    final normalizedOwner = ownerScope.trim();
    if (normalizedOwner.isEmpty) {
      throw const FormatException('ownerScope boş olamaz');
    }

    final sortedStars =
        snapshot.bestStarsByLevelId.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in sortedStars) {
      if (entry.key.trim().isEmpty || entry.value < 0 || entry.value > 3) {
        throw FormatException('yıldız değeri geçersiz: ${entry.key}');
      }
    }

    final sortedBonusCounts =
        snapshot.bestBonusFoundCountByLevelId.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in sortedBonusCounts) {
      if (entry.key.trim().isEmpty || entry.value < 0) {
        throw FormatException('bonus sayısı geçersiz: ${entry.key}');
      }
    }

    final sortedCards = snapshot.unlockedInfoCardIds.toList()..sort();
    final sortedRewards = snapshot.unlockedRouteRewardIds.toList()..sort();
    final sortedGrandfatheredRoutes =
        snapshot.grandfatheredUnlockedRouteIds.toList()..sort();

    for (final id in <String>[
      ...sortedCards,
      ...sortedRewards,
      ...sortedGrandfatheredRoutes,
    ]) {
      if (id.trim().isEmpty) {
        throw const FormatException('persisted kimlik boş olamaz');
      }
    }

    final lastActiveRouteId = snapshot.lastActiveRouteId?.trim();
    if (lastActiveRouteId != null && lastActiveRouteId.isEmpty) {
      throw const FormatException('lastActiveRouteId geçersiz');
    }

    return jsonEncode(<String, dynamic>{
      'schema': schemaVersion,
      'ownerScope': normalizedOwner,
      'bestStarsByLevelId': <String, int>{
        for (final entry in sortedStars) entry.key: entry.value,
      },
      'unlockedInfoCardIds': sortedCards,
      'unlockedRouteRewardIds': sortedRewards,
      'bestBonusFoundCountByLevelId': <String, int>{
        for (final entry in sortedBonusCounts) entry.key: entry.value,
      },
      'grandfatheredUnlockedRouteIds': sortedGrandfatheredRoutes,
      'lastActiveRouteId': lastActiveRouteId,
    });
  }

  static WordHuntProgressSnapshot decode(
    String raw, {
    required String expectedOwnerScope,
  }) {
    return decodeWithMetadata(
      raw,
      expectedOwnerScope: expectedOwnerScope,
    ).snapshot;
  }

  static WordHuntProgressDecodeResult decodeWithMetadata(
    String raw, {
    required String expectedOwnerScope,
  }) {
    final normalizedExpectedOwner = expectedOwnerScope.trim();
    if (normalizedExpectedOwner.isEmpty) {
      throw const FormatException('expectedOwnerScope boş olamaz');
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('Kelime Avı ilerlemesi çözülemedi: $error');
    }

    if (decoded is! Map) {
      throw const FormatException('Kelime Avı ilerlemesi obje olmalı');
    }

    final payload = Map<String, dynamic>.from(decoded);
    final schema = payload['schema'];
    if (schema is! int || schema < 1 || schema > schemaVersion) {
      throw FormatException('Desteklenmeyen Kelime Avı şeması: $schema');
    }

    final ownerScope = payload['ownerScope'];
    if (ownerScope is! String || ownerScope.trim().isEmpty) {
      throw const FormatException('ownerScope geçersiz');
    }
    if (ownerScope.trim() != normalizedExpectedOwner) {
      throw const FormatException('Kelime Avı ilerlemesi başka hesaba ait');
    }

    final starsRaw = payload['bestStarsByLevelId'];
    if (starsRaw is! Map) {
      throw const FormatException('bestStarsByLevelId geçersiz');
    }

    final stars = <String, int>{};
    for (final entry in starsRaw.entries) {
      final levelId = entry.key;
      final starValue = entry.value;
      if (levelId is! String || levelId.trim().isEmpty) {
        throw const FormatException('bölüm kimliği geçersiz');
      }
      if (starValue is! int || starValue < 0 || starValue > 3) {
        throw FormatException('yıldız değeri geçersiz: $levelId');
      }
      stars[levelId.trim()] = starValue;
    }

    final cardsRaw = payload['unlockedInfoCardIds'];
    if (cardsRaw is! List) {
      throw const FormatException('unlockedInfoCardIds geçersiz');
    }
    final cards = _decodeIdSet(cardsRaw, 'bilgi kartı kimliği');

    final rewards = <String>{};
    if (schema >= 2) {
      final rewardsRaw = payload['unlockedRouteRewardIds'];
      if (rewardsRaw is! List) {
        throw const FormatException('unlockedRouteRewardIds geçersiz');
      }
      rewards.addAll(_decodeIdSet(rewardsRaw, 'rota ödülü kimliği'));
    }

    final bonusCounts = <String, int>{};
    final grandfatheredRoutes = <String>{};
    String? lastActiveRouteId;

    if (schema >= 3) {
      final bonusRaw = payload['bestBonusFoundCountByLevelId'];
      if (bonusRaw is! Map) {
        throw const FormatException('bestBonusFoundCountByLevelId geçersiz');
      }
      for (final entry in bonusRaw.entries) {
        final levelId = entry.key;
        final count = entry.value;
        if (levelId is! String || levelId.trim().isEmpty) {
          throw const FormatException('bonus bölüm kimliği geçersiz');
        }
        if (count is! int || count < 0) {
          throw FormatException('bonus sayısı geçersiz: $levelId');
        }
        bonusCounts[levelId.trim()] = count;
      }

      final routesRaw = payload['grandfatheredUnlockedRouteIds'];
      if (routesRaw is! List) {
        throw const FormatException('grandfatheredUnlockedRouteIds geçersiz');
      }
      grandfatheredRoutes.addAll(
        _decodeIdSet(routesRaw, 'legacy rota erişim kimliği'),
      );

      final lastActiveRaw = payload['lastActiveRouteId'];
      if (lastActiveRaw != null) {
        if (lastActiveRaw is! String || lastActiveRaw.trim().isEmpty) {
          throw const FormatException('lastActiveRouteId geçersiz');
        }
        lastActiveRouteId = lastActiveRaw.trim();
      }
    }

    return WordHuntProgressDecodeResult(
      snapshot: WordHuntProgressSnapshot(
        bestStarsByLevelId: Map<String, int>.unmodifiable(stars),
        unlockedInfoCardIds: Set<String>.unmodifiable(cards),
        unlockedRouteRewardIds: Set<String>.unmodifiable(rewards),
        bestBonusFoundCountByLevelId: Map<String, int>.unmodifiable(
          bonusCounts,
        ),
        grandfatheredUnlockedRouteIds: Set<String>.unmodifiable(
          grandfatheredRoutes,
        ),
        lastActiveRouteId: lastActiveRouteId,
      ),
      sourceSchemaVersion: schema,
    );
  }

  static Set<String> _decodeIdSet(List<dynamic> raw, String label) {
    final values = <String>{};
    for (final item in raw) {
      if (item is! String || item.trim().isEmpty) {
        throw FormatException('$label geçersiz');
      }
      values.add(item.trim());
    }
    return values;
  }
}
