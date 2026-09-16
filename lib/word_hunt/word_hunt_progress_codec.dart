import 'dart:convert';

import 'word_hunt_progress.dart';

class WordHuntProgressCodec {
  WordHuntProgressCodec._();

  static const int schemaVersion = 2;
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

    final sortedStars = snapshot.bestStarsByLevelId.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final sortedCards = snapshot.unlockedInfoCardIds.toList()..sort();
    final sortedRewards = snapshot.unlockedRouteRewardIds.toList()..sort();

    return jsonEncode(<String, dynamic>{
      'schema': schemaVersion,
      'ownerScope': normalizedOwner,
      'bestStarsByLevelId': <String, int>{
        for (final entry in sortedStars) entry.key: entry.value,
      },
      'unlockedInfoCardIds': sortedCards,
      'unlockedRouteRewardIds': sortedRewards,
    });
  }

  static WordHuntProgressSnapshot decode(
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
    if (schema != 1 && schema != schemaVersion) {
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

    final cards = <String>{};
    for (final item in cardsRaw) {
      if (item is! String || item.trim().isEmpty) {
        throw const FormatException('bilgi kartı kimliği geçersiz');
      }
      cards.add(item.trim());
    }

    final rewards = <String>{};
    if (schema == schemaVersion) {
      final rewardsRaw = payload['unlockedRouteRewardIds'];
      if (rewardsRaw is! List) {
        throw const FormatException('unlockedRouteRewardIds geçersiz');
      }
      for (final item in rewardsRaw) {
        if (item is! String || item.trim().isEmpty) {
          throw const FormatException('rota ödülü kimliği geçersiz');
        }
        rewards.add(item.trim());
      }
    }

    return WordHuntProgressSnapshot(
      bestStarsByLevelId: Map<String, int>.unmodifiable(stars),
      unlockedInfoCardIds: Set<String>.unmodifiable(cards),
      unlockedRouteRewardIds: Set<String>.unmodifiable(rewards),
    );
  }
}
