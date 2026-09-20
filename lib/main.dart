import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart' hide Source;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'sound_data.dart';
import 'word_hunt/word_hunt_production_entry_screen.dart';

part 'daily_challenge.dart';
part 'analytics_telemetry.dart';
part 'push_notifications.dart';
part 'ad_monetization.dart';
part 'question_feedback.dart';
part 'xp_progression.dart';
part 'career_collection_update.dart';
part 'gameplay_boost.dart';
part 'quick_modes.dart';
part 'advanced_modes.dart';
part 'retention_system.dart';
part 'visual_collection.dart';
part 'board_theme_art.dart';
part 'accessibility_settings.dart';
part 'social_features.dart';
part 'system_health.dart';
part 'difficulty_balance.dart';
part 'question_quality.dart';
part 'main_navigation.dart';
part 'product_mode_entry.dart';
part 'game_ui_polish.dart';
part 'pawn_step_sounds.dart';
part 'premium_pawn_picker.dart';
part 'pawn_visual_effects.dart';
part 'premium_dice.dart';
part 'short_challenge_mode.dart';
part 'board_target_presentation.dart';
part 'about_privacy.dart';
part 'app_build_info.dart';
part 'account_cloud.dart';
part 'firebase_security.dart';
part 'player_username.dart';
part 'player_safety.dart';
part 'live_duel_league.dart';
part 'live_duel_leaderboard.dart';
part 'live_duel_server_gateway.dart';
part 'live_duel_matchmaking.dart';
part 'live_duel_screen.dart';
part 'live_duel_questions.dart';
part 'live_duel_progress.dart';
part 'live_duel_play_screen.dart';
part 'live_duel_result.dart';
part 'live_duel_connection.dart';

class SoundFx {
  SoundFx._();

  static bool enabled = true;
  static bool _initialized = false;
  static String? lastError;

  static final Map<String, String> _soundPaths = <String, String>{};

  static final AudioPlayer _dicePlayer = AudioPlayer(
    playerId: 'bilgi_rotasi_dice',
  );
  static final AudioPlayer _stepPlayer = AudioPlayer(
    playerId: 'bilgi_rotasi_step',
  );
  static final AudioPlayer _effectPlayer = AudioPlayer(
    playerId: 'bilgi_rotasi_effect',
  );
  static final AudioPlayer _musicPlayer = AudioPlayer(
    playerId: 'bilgi_rotasi_music',
  );

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await AudioPlayer.global.ensureInitialized();
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          route: AudioContextConfigRoute.system,
          focus: AudioContextConfigFocus.mixWithOthers,
          respectSilence: false,
        ).build(),
      );

      final directory = Directory(
        '${Directory.systemTemp.path}/bilgi_rotasi_embedded_sounds_user_dice_95077',
      );
      await directory.create(recursive: true);

      for (final entry in embeddedSoundBase64.entries) {
        final bytes = base64Decode(entry.value);
        final file = File('${directory.path}/${entry.key}');

        final needsWrite =
            !await file.exists() || await file.length() != bytes.length;

        if (needsWrite) {
          await file.writeAsBytes(bytes, flush: true);
        }

        _soundPaths[entry.key] = file.path;
      }

      for (final entry in PawnStepSoundFactory.buildAll().entries) {
        final file = File('${directory.path}/${entry.key}');
        final bytes = entry.value;
        final needsWrite =
            !await file.exists() || await file.length() != bytes.length;

        if (needsWrite) {
          await file.writeAsBytes(bytes, flush: true);
        }
        _soundPaths[entry.key] = file.path;
      }

      await Future.wait([
        _dicePlayer.setReleaseMode(ReleaseMode.stop),
        _stepPlayer.setReleaseMode(ReleaseMode.stop),
        _effectPlayer.setReleaseMode(ReleaseMode.stop),
        _musicPlayer.setReleaseMode(ReleaseMode.stop),
      ]);

      _initialized = true;
      lastError = null;
    } catch (error) {
      lastError = error.toString();
      rethrow;
    }
  }

  static void setEnabled(bool value) {
    enabled = value;

    if (!value) {
      unawaited(_dicePlayer.stop());
      unawaited(_stepPlayer.stop());
      unawaited(_effectPlayer.stop());
      unawaited(_musicPlayer.stop());
    }
  }

  static Future<bool> _play(
    AudioPlayer player,
    String fileName, {
    double volume = 1,
    double playbackRateMultiplier = 1,
  }) async {
    if (!enabled) return false;

    try {
      await initialize();

      final path = _soundPaths[fileName];
      if (path == null || path.isEmpty) {
        throw StateError('Gömülü ses hazırlanamadı: $fileName');
      }

      final file = File(path);
      if (!await file.exists()) {
        throw StateError('Geçici ses dosyası bulunamadı: $fileName');
      }

      await player.setPlaybackRate(
        playbackRateMultiplier.clamp(0.5, 2.0).toDouble(),
      );

      await player.play(
        DeviceFileSource(path),
        volume:
            (volume * AppPreferencesService.soundMultiplier)
                .clamp(0.0, 1.0)
                .toDouble(),
      );

      lastError = null;
      return true;
    } catch (error) {
      lastError = error.toString();
      return false;
    }
  }

  static Future<bool> dice() {
    return _play(_dicePlayer, 'dice_roll.mp3', volume: 1.0);
  }

  static Future<bool> step() {
    return pawnStep(0);
  }

  static Future<bool> pawnStep(int pawnType, {int stepIndex = 0}) {
    return _play(
      _stepPlayer,
      PawnStepSoundFactory.fileNameForPawn(pawnType),
      volume: PawnStepSoundFactory.volumeForPawn(pawnType),
      playbackRateMultiplier: PawnStepSoundFactory.rateForStep(
        pawnType,
        stepIndex,
      ),
    );
  }

  static Future<bool> landing() {
    return _play(_effectPlayer, 'landing.mp3', volume: 1);
  }

  static Future<bool> correct() {
    return _play(_effectPlayer, 'correct.mp3', volume: 1);
  }

  static Future<bool> wrong() {
    return _play(_effectPlayer, 'wrong.mp3', volume: 1);
  }

  static Future<bool> badge() {
    return _play(_effectPlayer, 'badge.mp3', volume: 1);
  }

  static Future<bool> win() {
    return _play(_musicPlayer, 'win.mp3', volume: 1);
  }

  static Future<bool> test() {
    return correct();
  }
}

class SavedGame {
  const SavedGame({
    required this.players,
    required this.currentPlayerIndex,
    required this.savedAt,
    required this.usedQuestionIds,
  });

  final List<PlayerData> players;
  final int currentPlayerIndex;
  final DateTime savedAt;
  final Set<String> usedQuestionIds;

  PlayerData get currentPlayer {
    final safeIndex = currentPlayerIndex.clamp(0, players.length - 1).toInt();
    return players[safeIndex];
  }

  int get totalBadges {
    return players.fold<int>(
      0,
      (total, player) => total + player.badges.length,
    );
  }
}

class GameSaveService {
  GameSaveService._();

  static const String _legacySaveKey = 'bilgi_rotasi_saved_game_v1';
  static const String _legacyBackupKey = 'bilgi_rotasi_saved_game_backup_v1';
  static const String _scopedSavePrefix = 'bilgi_rotasi_saved_game_v2_';
  static const String _scopedBackupPrefix =
      'bilgi_rotasi_saved_game_backup_v2_';

  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static String storageScopeForUid(String? uid) {
    final normalized = uid?.trim() ?? '';
    return normalized.isEmpty ? 'guest' : 'user_$normalized';
  }

  static String saveKeyForUid(String? uid) {
    return '$_scopedSavePrefix${storageScopeForUid(uid)}';
  }

  static String backupKeyForUid(String? uid) {
    return '$_scopedBackupPrefix${storageScopeForUid(uid)}';
  }

  static String get _currentUid {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get _currentScope => storageScopeForUid(_currentUid);

  static String get _saveKey => saveKeyForUid(_currentUid);

  static String get _backupKey => backupKeyForUid(_currentUid);

  static bool isScopedStorageKey(String key) {
    return key.startsWith(_scopedSavePrefix) ||
        key.startsWith(_scopedBackupPrefix);
  }

  static bool belongsToScope(String key, String scope) {
    return key == '$_scopedSavePrefix$scope' ||
        key == '$_scopedBackupPrefix$scope';
  }

  static bool belongsToActiveScope(String key) {
    return belongsToScope(key, _currentScope);
  }

  static String? _ownerScopeFromRaw(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final owner = decoded['ownerScope']?.toString().trim();
      return owner == null || owner.isEmpty ? null : owner;
    } catch (_) {
      return null;
    }
  }

  static String _attachOwnerScope(String raw, String scope) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Kayıtlı oyun biçimi geçersiz.');
    }

    final payload = Map<String, dynamic>.from(decoded);
    payload['schema'] = 4;
    payload['ownerScope'] = scope;
    return jsonEncode(payload);
  }

  static Future<void> _claimRawForCurrentUser(String raw) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final claimed = _attachOwnerScope(raw, storageScopeForUid(user.uid));

    await _preferences.setString(_saveKey, claimed);
    await _preferences.setString(_backupKey, claimed);
  }

  static Future<void> sanitizeGuestScope() async {
    final guestSaveKey = saveKeyForUid(null);
    final guestBackupKey = backupKeyForUid(null);
    final raw = await _preferences.getString(guestSaveKey);

    if (raw == null || raw.trim().isEmpty) {
      await _preferences.remove(guestBackupKey);
      return;
    }

    final owner = _ownerScopeFromRaw(raw);

    if (owner != null && owner != 'guest') {
      await _preferences.remove(guestSaveKey);
      await _preferences.remove(guestBackupKey);
    }
  }

  static Future<void> _migrateLegacyForSignedInUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final current = await _preferences.getString(_saveKey);
    if (current != null && current.trim().isNotEmpty) return;

    final legacy = await _preferences.getString(_legacySaveKey);

    if (legacy != null && legacy.trim().isNotEmpty) {
      await _claimRawForCurrentUser(legacy);
      await _preferences.remove(_legacySaveKey);
      await _preferences.remove(_legacyBackupKey);
      return;
    }

    final guestSaveKey = saveKeyForUid(null);
    final guestBackupKey = backupKeyForUid(null);
    final guestRaw = await _preferences.getString(guestSaveKey);

    if (guestRaw == null || guestRaw.trim().isEmpty) return;

    final guestOwner = _ownerScopeFromRaw(guestRaw);

    // 1.65.0 öncesi yanlışlıkla misafir kasasına yazılan
    // sahipsiz kayıt, mevcut Google hesabına güvenle taşınır.
    if (guestOwner == null) {
      await _claimRawForCurrentUser(guestRaw);
      await _preferences.remove(guestSaveKey);
      await _preferences.remove(guestBackupKey);
    }
  }

  static Future<void> save({
    required List<PlayerData> players,
    required int currentPlayerIndex,
    required Set<String> usedQuestionIds,
  }) async {
    if (players.isEmpty) return;

    final payload = <String, dynamic>{
      'schema': 4,
      'ownerScope': _currentScope,
      'savedAt': DateTime.now().toIso8601String(),
      'currentPlayerIndex': currentPlayerIndex,
      'players': players.map(_playerToJson).toList(),
      'usedQuestionIds': usedQuestionIds.toList()..sort(),
    };

    try {
      await GameRecoveryService.saveWithBackup(jsonEncode(payload));
    } catch (_) {
      // Kayıt sorunu oyunun çalışmasını durdurmamalı.
    }
  }

  static Future<SavedGame?> load() async {
    try {
      await _migrateLegacyForSignedInUser();

      final raw = await _preferences.getString(_saveKey);
      if (raw == null || raw.trim().isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        await clear();
        return null;
      }

      final ownerScope = decoded['ownerScope']?.toString().trim();

      if (ownerScope == null || ownerScope.isEmpty) {
        if (_currentUid.isEmpty) {
          // Sahibi belli olmayan eski kayıt misafir ekranında
          // gösterilmez. Google hesabına girildiğinde kurtarılır.
          return null;
        }

        final claimed = _attachOwnerScope(raw, _currentScope);
        await _preferences.setString(_saveKey, claimed);
        await _preferences.setString(_backupKey, claimed);
        decoded['schema'] = 4;
        decoded['ownerScope'] = _currentScope;
      } else if (ownerScope != _currentScope) {
        return null;
      }

      final rawPlayers = decoded['players'];
      if (rawPlayers is! List || rawPlayers.isEmpty) {
        await clear();
        return null;
      }

      final players = <PlayerData>[];
      for (final item in rawPlayers) {
        if (item is Map<String, dynamic>) {
          players.add(_playerFromJson(item));
        } else if (item is Map) {
          players.add(_playerFromJson(Map<String, dynamic>.from(item)));
        }
      }

      if (players.isEmpty) {
        await clear();
        return null;
      }

      final rawIndex = (decoded['currentPlayerIndex'] as num?)?.toInt() ?? 0;
      final currentPlayerIndex = rawIndex.clamp(0, players.length - 1).toInt();
      final savedAt =
          DateTime.tryParse(decoded['savedAt']?.toString() ?? '') ??
          DateTime.now();

      final rawUsedQuestionIds = decoded['usedQuestionIds'];
      final usedQuestionIds = <String>{};

      if (rawUsedQuestionIds is List) {
        usedQuestionIds.addAll(
          rawUsedQuestionIds
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty),
        );
      }

      return SavedGame(
        players: players,
        currentPlayerIndex: currentPlayerIndex,
        savedAt: savedAt,
        usedQuestionIds: usedQuestionIds,
      );
    } catch (error, stack) {
      await AppErrorLogService.record(
        source: 'Kayıt yükleme',
        error: error,
        stack: stack,
      );

      final recovered = await GameRecoveryService.recover();

      if (recovered != null) {
        return recovered;
      }

      await clear();
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      await _preferences.remove(_saveKey);
      await _preferences.remove(_backupKey);
    } catch (_) {
      // Kayıt silme sorunu arayüzü kilitlememeli.
    }
  }

  static Map<String, dynamic> _playerToJson(PlayerData player) {
    return <String, dynamic>{
      'name': player.name,
      'color': player.color.value,
      'pawnType': player.pawnType,
      'position': player.position,
      'movePulse': player.movePulse,
      'correctAnswers': player.correctAnswers,
      'wrongAnswers': player.wrongAnswers,
      'correctStreak': player.correctStreak,
      'wrongStreak': player.wrongStreak,
      'difficultyMode': player.difficultyMode.name,
      'doubleChance': player.doubleChance,
      'jokers': player.jokers.toJson(),
      'badges': player.badges.toList()..sort(),
    };
  }

  static PlayerData _playerFromJson(Map<String, dynamic> json) {
    final player = PlayerData(
      name:
          json['name']?.toString().trim().isNotEmpty == true
              ? json['name'].toString()
              : 'Oyuncu',
      color: Color((json['color'] as num?)?.toInt() ?? 0xFF2563EB),
      pawnType: (json['pawnType'] as num?)?.toInt() ?? 0,
      difficultyMode: difficultyModeFromName(json['difficultyMode']),
      jokers: JokerWallet.fromJson(json['jokers']),
    );

    player.position = (json['position'] as num?)?.toInt() ?? 0;
    player.movePulse = (json['movePulse'] as num?)?.toInt() ?? 0;
    player.correctAnswers = (json['correctAnswers'] as num?)?.toInt() ?? 0;
    player.wrongAnswers = (json['wrongAnswers'] as num?)?.toInt() ?? 0;
    player.correctStreak = (json['correctStreak'] as num?)?.toInt() ?? 0;
    player.wrongStreak = (json['wrongStreak'] as num?)?.toInt() ?? 0;
    player.doubleChance = json['doubleChance'] == true;

    final rawBadges = json['badges'];
    if (rawBadges is List) {
      player.badges.addAll(
        rawBadges
            .whereType<num>()
            .map((value) => value.toInt())
            .where((value) => value >= 0 && value < GameCategory.values.length),
      );
    }

    return player;
  }
}

class CareerStats {
  CareerStats({
    this.totalQuestions = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.gamesStarted = 0,
    this.soloWins = 0,
    this.multiplayerWins = 0,
    this.marathonRuns = 0,
    this.perfectMarathons = 0,
    this.bestStreak = 0,
    this.totalBadges = 0,
    List<int>? categoryAnswered,
    List<int>? categoryCorrect,
  }) : categoryAnswered =
           categoryAnswered ?? List<int>.filled(GameCategory.values.length, 0),
       categoryCorrect =
           categoryCorrect ?? List<int>.filled(GameCategory.values.length, 0);

  int totalQuestions;
  int totalCorrect;
  int totalWrong;
  int gamesStarted;
  int soloWins;
  int multiplayerWins;
  int marathonRuns;
  int perfectMarathons;
  int bestStreak;
  int totalBadges;
  final List<int> categoryAnswered;
  final List<int> categoryCorrect;

  int get completedGames => soloWins + multiplayerWins + marathonRuns;

  int get accuracy {
    if (totalQuestions == 0) return 0;
    return (totalCorrect / totalQuestions * 100).round();
  }

  int categoryAccuracy(int index) {
    if (index < 0 ||
        index >= categoryAnswered.length ||
        categoryAnswered[index] == 0) {
      return 0;
    }

    return (categoryCorrect[index] / categoryAnswered[index] * 100).round();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'gamesStarted': gamesStarted,
      'soloWins': soloWins,
      'multiplayerWins': multiplayerWins,
      'marathonRuns': marathonRuns,
      'perfectMarathons': perfectMarathons,
      'bestStreak': bestStreak,
      'totalBadges': totalBadges,
      'categoryAnswered': categoryAnswered,
      'categoryCorrect': categoryCorrect,
    };
  }

  factory CareerStats.fromJson(Map<String, dynamic> json) {
    List<int> readList(String key) {
      final raw = json[key];

      if (raw is! List) {
        return List<int>.filled(GameCategory.values.length, 0);
      }

      final values =
          raw
              .map((value) => (value as num?)?.toInt() ?? 0)
              .take(GameCategory.values.length)
              .toList();

      while (values.length < GameCategory.values.length) {
        values.add(0);
      }

      return values;
    }

    return CareerStats(
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['totalCorrect'] as num?)?.toInt() ?? 0,
      totalWrong: (json['totalWrong'] as num?)?.toInt() ?? 0,
      gamesStarted: (json['gamesStarted'] as num?)?.toInt() ?? 0,
      soloWins: (json['soloWins'] as num?)?.toInt() ?? 0,
      multiplayerWins: (json['multiplayerWins'] as num?)?.toInt() ?? 0,
      marathonRuns: (json['marathonRuns'] as num?)?.toInt() ?? 0,
      perfectMarathons: (json['perfectMarathons'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      totalBadges: (json['totalBadges'] as num?)?.toInt() ?? 0,
      categoryAnswered: readList('categoryAnswered'),
      categoryCorrect: readList('categoryCorrect'),
    );
  }
}

class CareerStatsService {
  CareerStatsService._();

  static const String _key = 'bilgi_rotasi_career_stats_v1';
  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static Future<CareerStats> load() async {
    try {
      final raw = await _preferences.getString(_key);

      if (raw == null || raw.trim().isEmpty) {
        return CareerStats();
      }

      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        return CareerStats.fromJson(decoded);
      }

      if (decoded is Map) {
        return CareerStats.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Bozuk istatistik kaydı oyunu etkilememeli.
    }

    return CareerStats();
  }

  static Future<void> _save(CareerStats stats) async {
    try {
      await _preferences.setString(_key, jsonEncode(stats.toJson()));
    } catch (_) {
      // İstatistik kaydı oyunu durdurmamalı.
    }
  }

  static Future<void> recordGameStarted() async {
    final stats = await load();
    stats.gamesStarted++;
    await _save(stats);
  }

  static Future<XpGainResult> recordAnswer({
    required int categoryIndex,
    required bool correct,
    String difficulty = 'Orta',
    bool badgeEarned = false,
    int xpMultiplier = 1,
  }) async {
    final stats = await load();

    stats.totalQuestions++;

    if (correct) {
      stats.totalCorrect++;
    } else {
      stats.totalWrong++;
    }

    if (categoryIndex >= 0 && categoryIndex < GameCategory.values.length) {
      stats.categoryAnswered[categoryIndex]++;

      if (correct) {
        stats.categoryCorrect[categoryIndex]++;
      }
    }

    if (badgeEarned) {
      stats.totalBadges++;
    }

    await _save(stats);
    await PassportProgressService.recordAnswer(categoryIndex: categoryIndex);

    final answerGain = await XpProgressService.recordAnswer(
      correct: correct,
      difficulty: difficulty,
      badgeEarned: badgeEarned,
      xpMultiplier: xpMultiplier,
    );

    final retentionGain = await RetentionProgressService.recordAnswer(
      categoryIndex: categoryIndex,
      correct: correct,
      difficulty: difficulty,
      currentStreak: answerGain.currentStreak,
    );

    if (retentionGain == null) return answerGain;

    return XpGainResult.combine(
      <XpGainResult>[answerGain, retentionGain],
      reason:
          '${answerGain.reason} + '
          '${retentionGain.reason}',
    );
  }

  static Future<XpGainResult> recordGameCompleted({required bool solo}) async {
    final stats = await load();

    if (solo) {
      stats.soloWins++;
    } else {
      stats.multiplayerWins++;
    }

    await _save(stats);
    return XpProgressService.recordGameCompleted(solo: solo);
  }

  static Future<XpGainResult> recordMarathon({
    required int questionCount,
    required int correct,
    required int bestStreak,
  }) async {
    final stats = await load();

    stats.marathonRuns++;

    if (correct == questionCount && questionCount > 0) {
      stats.perfectMarathons++;
    }

    stats.bestStreak = max(stats.bestStreak, bestStreak);

    await _save(stats);

    final marathonGain = await XpProgressService.recordMarathon(
      questionCount: questionCount,
      perfect: correct == questionCount && questionCount > 0,
    );

    final retentionGain = await RetentionProgressService.recordMarathon();

    if (retentionGain == null) return marathonGain;

    return XpGainResult.combine(
      <XpGainResult>[marathonGain, retentionGain],
      reason:
          '${marathonGain.reason} + '
          '${retentionGain.reason}',
    );
  }

  static Future<void> clear() async {
    try {
      await _preferences.remove(_key);
    } catch (_) {
      // Sıfırlama sorunu ekranı kilitlememeli.
    }
  }
}

class CareerAchievement {
  const CareerAchievement({
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final String emoji;
  final String title;
  final String description;
  final bool Function(CareerStats stats) isUnlocked;
}

final List<CareerAchievement> careerAchievements = [
  CareerAchievement(
    emoji: '👣',
    title: 'İlk Adım',
    description: 'İlk sorunu cevapla.',
    isUnlocked: (stats) => stats.totalQuestions >= 1,
  ),
  CareerAchievement(
    emoji: '🎯',
    title: 'Bilgi Avcısı',
    description: '25 doğru cevaba ulaş.',
    isUnlocked: (stats) => stats.totalCorrect >= 25,
  ),
  CareerAchievement(
    emoji: '🧠',
    title: 'Bilgi Ustası',
    description: '100 doğru cevaba ulaş.',
    isUnlocked: (stats) => stats.totalCorrect >= 100,
  ),
  CareerAchievement(
    emoji: '🏅',
    title: 'Rozet Koleksiyoncusu',
    description: 'Toplam 6 rozet kazan.',
    isUnlocked: (stats) => stats.totalBadges >= 6,
  ),
  CareerAchievement(
    emoji: '🧭',
    title: 'Serbest Kaşif',
    description: 'Serbest Rota modunu tamamla.',
    isUnlocked: (stats) => stats.soloWins >= 1,
  ),
  CareerAchievement(
    emoji: '👑',
    title: 'Bilgi Şampiyonu',
    description: 'Çok oyunculu bir oyun kazan.',
    isUnlocked: (stats) => stats.multiplayerWins >= 1,
  ),
  CareerAchievement(
    emoji: '⚡',
    title: 'Maratoncu',
    description: 'Bir Soru Maratonu tamamla.',
    isUnlocked: (stats) => stats.marathonRuns >= 1,
  ),
  CareerAchievement(
    emoji: '💯',
    title: 'Kusursuz Tur',
    description: 'Bir maratonda bütün soruları bil.',
    isUnlocked: (stats) => stats.perfectMarathons >= 1,
  ),
  CareerAchievement(
    emoji: '🔥',
    title: 'Seri Ustası',
    description: '10 doğru cevaplık seri yap.',
    isUnlocked: (stats) => stats.bestStreak >= 10,
  ),
  CareerAchievement(
    emoji: '🌟',
    title: 'Yüz Soru',
    description: 'Toplam 100 soru cevapla.',
    isUnlocked: (stats) => stats.totalQuestions >= 100,
  ),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await AppErrorLogService.initialize();

  try {
    await SoundFx.initialize();
  } catch (_) {
    // Ses başlatılamasa bile oyun açılmaya devam eder.
  }

  try {
    await XpProgressService.initialize();
  } catch (_) {
    // XP sistemi açılamasa bile oyun açılmaya devam eder.
  }

  try {
    await GameplayBoostSettingsService.initialize();
  } catch (_) {
    // Oynanış ayarları açılamasa bile oyun devam eder.
  }

  try {
    await RetentionProgressService.initialize();
  } catch (_) {
    // Günlük ve haftalık sistem açılamasa bile oyun devam eder.
  }

  try {
    await VisualCollectionService.initialize();
  } catch (_) {
    // Koleksiyon sistemi açılamasa bile oyun devam eder.
  }

  try {
    await AppPreferencesService.initialize();
  } catch (_) {
    // Erişilebilirlik ayarları açılamasa bile oyun devam eder.
  }

  try {
    await AnalyticsConsentService.initialize();
  } catch (_) {
    // Tercih okunamazsa Analytics varsayılan olarak kapalı kalır.
  }

  runApp(const BilgiRotasiApp());

  unawaited(AnalyticsTelemetry.appProcessStarted());
  unawaited(PushNotificationService.initialize());
  unawaited(_initializeAccountCloudInBackground());
  unawaited(AdPrivacyService.instance.initialize());
}

Future<void> _initializeAccountCloudInBackground() async {
  try {
    await AccountCloudService.initialize().timeout(const Duration(seconds: 8));
  } catch (_) {
    // İnternet olmasa bile yerel oyun açılmaya devam eder.
  }
}

class BilgiRotasiApp extends StatefulWidget {
  const BilgiRotasiApp({super.key});

  @override
  State<BilgiRotasiApp> createState() => _BilgiRotasiAppState();
}

class _BilgiRotasiAppState extends State<BilgiRotasiApp> {
  late final Future<QuestionBank> _questionBankFuture;

  @override
  void initState() {
    super.initState();
    _questionBankFuture = QuestionBank.load();
    unawaited(AnalyticsTelemetry.screenViewed('app_root'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(AnalyticsConsentService.showInitialPromptIfNeeded());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AnalyticsConsentService.navigatorKey,
      navigatorObservers: <NavigatorObserver>[
        AnalyticsTelemetry.navigatorObserver,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Bilgi Rotası & Kelime Avı',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155E75),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      builder: (context, child) {
        return AccessibilityAppFrame(child: child ?? const SizedBox.shrink());
      },
      home: FutureBuilder<QuestionBank>(
        future: _questionBankFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingScreen();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorScreen(
              message: snapshot.error?.toString() ?? 'Sorular yüklenemedi.',
            );
          }

          return AccountGate(questionBank: snapshot.data!);
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text('Sorular hazırlanıyor…'),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 72),
                const SizedBox(height: 18),
                const Text(
                  'Uygulama başlatılamadı',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                const Text(
                  'pubspec.yaml içinde assets/questions.json satırının bulunduğunu kontrol et.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CareerStatsScreen extends StatefulWidget {
  const CareerStatsScreen({super.key});

  @override
  State<CareerStatsScreen> createState() => _CareerStatsScreenState();
}

class _CareerStatsScreenState extends State<CareerStatsScreen> {
  late Future<CareerStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _statsFuture = CareerStatsService.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler & Başarımlar')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE6F7F5)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<CareerStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = snapshot.data ?? CareerStats();

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                children: [
                  _buildHero(stats),
                  const SizedBox(height: 10),
                  FutureBuilder<XpProgress>(
                    future: XpProgressService.load(),
                    builder: (context, xpSnapshot) {
                      final xp = xpSnapshot.data;
                      if (xp == null) {
                        return const SizedBox.shrink();
                      }

                      return SocialShareButton(
                        title: 'Bilgi Rotası Kariyerim',
                        text: SocialShareService.careerText(stats, xp),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const XpCareerCard(),
                  const SizedBox(height: 16),
                  _buildSummary(stats),
                  const SizedBox(height: 16),
                  if (AccountCloudService.dailyVisible) ...[
                    const DailyChallengeStatsCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildCategoryStats(stats),
                  const SizedBox(height: 16),
                  _buildAchievements(stats),
                  const SizedBox(height: 18),
                  TextButton.icon(
                    onPressed: _resetStats,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB91C1C),
                    ),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text(
                      'İstatistikleri Sıfırla',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHero(CareerStats stats) {
    final unlocked =
        careerAchievements.where((item) => item.isUnlocked(stats)).length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A245D), Color(0xFF155E75)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('📊', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text(
            'Bilgi kariyerin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${stats.totalQuestions} soru • '
            '${stats.accuracy}% başarı • '
            '$unlocked/${careerAchievements.length} başarım',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD8F1EE),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(CareerStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _summaryCard(
          emoji: '✅',
          value: '${stats.totalCorrect}',
          label: 'Doğru cevap',
        ),
        _summaryCard(
          emoji: '🎯',
          value: '%${stats.accuracy}',
          label: 'Genel başarı',
        ),
        _summaryCard(
          emoji: '🏆',
          value: '${stats.completedGames}',
          label: 'Tamamlanan tur',
        ),
        _summaryCard(
          emoji: '🔥',
          value: '${stats.bestStreak}',
          label: 'En iyi seri',
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String emoji,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 27)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(CareerStats stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori başarıların',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < GameCategory.values.length; index++)
            _categoryRow(
              category: GameCategory.values[index],
              answered: stats.categoryAnswered[index],
              correct: stats.categoryCorrect[index],
              accuracy: stats.categoryAccuracy(index),
            ),
        ],
      ),
    );
  }

  Widget _categoryRow({
    required GameCategory category,
    required int answered,
    required int correct,
    required int accuracy,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                answered == 0 ? 'Henüz yok' : '$correct/$answered • %$accuracy',
                style: TextStyle(
                  color: category.darkColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: answered == 0 ? 0 : accuracy / 100,
              minHeight: 8,
              backgroundColor: category.color.withOpacity(0.13),
              color: category.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(CareerStats stats) {
    final unlocked =
        careerAchievements.where((item) => item.isUnlocked(stats)).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF271631),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x55FFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Başarımlar • $unlocked/'
            '${careerAchievements.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
          for (final achievement in careerAchievements)
            _achievementRow(achievement, achievement.isUnlocked(stats)),
        ],
      ),
    );
  }

  Widget _achievementRow(CareerAchievement achievement, bool unlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0x22FFE082) : const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: unlocked ? const Color(0x88FFE082) : const Color(0x22FFFFFF),
        ),
      ),
      child: Row(
        children: [
          Text(
            unlocked ? achievement.emoji : '🔒',
            style: const TextStyle(fontSize: 27),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color:
                        unlocked
                            ? const Color(0xFFFFE082)
                            : const Color(0xFFB9AEC2),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: Color(0xFFD0C6D7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: unlocked ? const Color(0xFF4ADE80) : const Color(0xFF766A80),
          ),
        ],
      ),
    );
  }

  Future<void> _resetStats() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('İstatistikler sıfırlansın mı?'),
              content: const Text(
                'XP, seviye, bütün toplamlar, kategori '
                'başarıları ve açılan başarımlar silinecek. '
                'Kayıtlı oyunun etkilenmeyecek.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Sıfırla'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    await CareerStatsService.clear();
    await DailyChallengeService.clear();
    await XpProgressService.clear();
    await RetentionProgressService.clear();

    if (!mounted) return;

    setState(_reload);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<SavedGame?> _savedGameFuture;
  bool _actionBusy = false;

  @override
  void initState() {
    super.initState();
    _reloadSavedGame();

    // Bozuk eğitim katmanı ilk açılışta otomatik gösterilmez.
    // Eğitim, Ayarlar ekranındaki güvenli pencereden açılabilir.
  }

  void _reloadSavedGame() {
    _savedGameFuture = GameSaveService.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AdBannerSlot(placement: AdPlacement.homeMenu),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF170C21), Color(0xFF352044), Color(0xFF0D5260)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroHeader(),
                const SizedBox(height: 10),
                const AccountSummaryCard(),
                const SizedBox(height: 12),
                FutureBuilder<SavedGame?>(
                  future: _savedGameFuture,
                  builder: (context, snapshot) {
                    final savedGame = snapshot.data;

                    if (snapshot.connectionState == ConnectionState.waiting ||
                        savedGame == null) {
                      return const SizedBox.shrink();
                    }

                    return _buildSavedGameCard(savedGame);
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'BÖLÜMLER',
                  style: TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 13,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                MainNavigationGrid(questionBank: widget.questionBank),
                const SizedBox(height: 16),
                const Text(
                  AppBuildInfo.compactLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x1AFFFFFF),
            border: Border.all(color: const Color(0xFFFFD978), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x6632E0D0),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Image.asset(
            'assets/branding/splash_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'BİLGİ ROTASI',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            height: 1,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Color(0x88000000),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Zarı at, bilginle yolu aç.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD7F6F2),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureStrip() {
    const features = [
      ('🧭', 'Serbest Rota', 'Tek kişilik tahta'),
      ('🧠', 'Soru Maratonu', 'Hızlı bilgi turu'),
      ('💾', 'Kaydet ve dön', 'Kaldığın yerden'),
    ];

    return Row(
      children: [
        for (var index = 0; index < features.length; index++) ...[
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _actionBusy ? null : () => _onModeCardTap(index),
                borderRadius: BorderRadius.circular(18),
                splashColor: const Color(0x33FFE082),
                highlightColor: const Color(0x1FFFFFFF),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x16FFFFFF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0x55FFFFFF)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        features[index].$1,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        features[index].$2,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        features[index].$3,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFCBC1D6),
                          fontSize: 9,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (index < features.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Future<void> _onModeCardTap(int index) async {
    GameHaptics.selectionClick();

    switch (index) {
      case 0:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => SoloRouteSetupScreen(questionBank: widget.questionBank),
          ),
        );
        if (mounted) {
          setState(_reloadSavedGame);
        }
        return;

      case 1:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => MarathonSetupScreen(questionBank: widget.questionBank),
          ),
        );
        return;

      case 2:
        await _openSavedGameShortcut();
        return;
    }
  }

  Future<void> _openSavedGameShortcut() async {
    if (_actionBusy) return;

    setState(() => _actionBusy = true);

    final savedGame = await GameSaveService.load();

    if (!mounted) return;

    if (savedGame != null) {
      setState(() => _actionBusy = false);
      await _continueGame(savedGame);
      return;
    }

    setState(() => _actionBusy = false);

    final startNewGame =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Text('💾', style: TextStyle(fontSize: 44)),
              title: const Text('Kayıtlı oyun yok'),
              content: const Text(
                'Tahta oyunundan çıkarken “Kaydet ve Çık” '
                'seçeneğini kullandığında buradan tek dokunuşla '
                'oyuna dönebilirsin.',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Kapat'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Yeni Oyun Kur'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (startNewGame && mounted) {
      await _openNewGame();
    }
  }

  Widget _buildCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x12FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Altı bilgi rozeti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(GameCategory.values.length, (index) {
              final category = GameCategory.values[index];

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: category.color.withOpacity(0.72)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.emoji),
                    const SizedBox(width: 6),
                    Text(
                      category.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedGameCard(SavedGame savedGame) {
    final currentPlayer = savedGame.currentPlayer;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A2C71), Color(0xFF283E68)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0x99FFE082)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PawnToken(
                type: currentPlayer.pawnType,
                color: currentPlayer.color,
                active: true,
                width: 62,
                height: 76,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEVAM EDEN OYUN',
                      style: TextStyle(
                        color: Color(0xFFFFE082),
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      savedGame.players.length == 1
                          ? 'Serbest Rota • ${currentPlayer.name}'
                          : 'Sıra ${currentPlayer.name} oyuncusunda',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${savedGame.players.length} oyuncu • '
                      '${savedGame.totalBadges} rozet • '
                      '${savedGame.usedQuestionIds.length} soru\n'
                      '${_formatDate(savedGame.savedAt)}',
                      style: const TextStyle(
                        color: Color(0xFFD8CCEA),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          FilledButton.icon(
            onPressed: _actionBusy ? null : () => _continueGame(savedGame),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'Oyuna Devam Et',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          TextButton.icon(
            onPressed: _actionBusy ? null : _deleteSavedGame,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFCDD2),
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Kayıtlı Oyunu Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _continueGame(SavedGame savedGame) async {
    if (_actionBusy) return;

    setState(() => _actionBusy = true);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => GameScreen(
              questionBank: widget.questionBank,
              players: savedGame.players,
              initialPlayerIndex: savedGame.currentPlayerIndex,
              initialUsedQuestionIds: savedGame.usedQuestionIds,
              initialStatus:
                  'Kayıtlı oyun açıldı. Sıra '
                  '${savedGame.currentPlayer.name} oyuncusunda.',
            ),
      ),
    );

    if (!mounted) return;

    setState(() {
      _actionBusy = false;
      _reloadSavedGame();
    });
  }

  Future<void> _openNewGame() async {
    if (_actionBusy) return;

    setState(() => _actionBusy = true);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerSetupScreen(questionBank: widget.questionBank),
      ),
    );

    if (!mounted) return;

    setState(() {
      _actionBusy = false;
      _reloadSavedGame();
    });
  }

  Future<void> _deleteSavedGame() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Kayıtlı oyun silinsin mi?'),
              content: const Text(
                'Oyuncuların konumları, rozetleri ve '
                'istatistikleri silinecek.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Kaydı Sil'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    setState(() => _actionBusy = true);
    await GameSaveService.clear();

    if (!mounted) return;

    setState(() {
      _actionBusy = false;
      _reloadSavedGame();
    });
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day.$month.${local.year} $hour:$minute';
  }

  void _showRules(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nasıl oynanır?'),
          content: const SingleChildScrollView(
            child: Text(
              '• Bütün oyuncular oyuna ortadaki '
              'altıgenden başlar.\n\n'
              '• Zar atıldıktan sonra gidilecek yol seçilir. '
              'Kavşaklarda dış halkada sağa, sola veya '
              'merkeze doğru ilerlenebilir.\n\n'
              '• Gelinen rengin kategorisinden dört şıklı '
              'soru açılır.\n\n'
              '• Doğru cevap veren oyuncu yeniden oynar. '
              'Yanlış cevapta sıra diğer oyuncuya geçer.\n\n'
              '• Beyaz çerçeveli rozet alanlarında doğru cevap '
              'veren oyuncu o kategorinin rozetini kazanır.\n\n'
              '• Parlayan özel kutular; İleri 2, Geri 2, '
              'Kategori Seç veya Çifte Şans etkisi verir.\n\n'
              '• Altı rozeti tamamlayan oyuncu final '
              'sorusunu doğru cevaplayınca oyunu kazanır.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anladım'),
            ),
          ],
        );
      },
    );
  }
}

class CategoryPill extends StatelessWidget {
  const CategoryPill({required this.category, super.key});

  final GameCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: category.color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji),
          const SizedBox(width: 7),
          Text(
            category.label,
            style: TextStyle(
              color: category.darkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MarathonScoreService {
  MarathonScoreService._();

  static const String _key = 'bilgi_rotasi_marathon_scores_v1';
  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static String _scoreKey(int? categoryIndex, int questionCount) {
    final category =
        categoryIndex == null ? 'mixed' : 'category_$categoryIndex';
    return '${category}_$questionCount';
  }

  static Future<Map<String, int>> _loadScores() async {
    try {
      final raw = await _preferences.getString(_key);
      if (raw == null || raw.isEmpty) {
        return <String, int>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, int>{};
      }

      return decoded.map<String, int>(
        (key, value) => MapEntry(key.toString(), (value as num?)?.toInt() ?? 0),
      );
    } catch (_) {
      return <String, int>{};
    }
  }

  static Future<int> bestScore({
    required int? categoryIndex,
    required int questionCount,
  }) async {
    final scores = await _loadScores();
    return scores[_scoreKey(categoryIndex, questionCount)] ?? 0;
  }

  static Future<void> saveBest({
    required int? categoryIndex,
    required int questionCount,
    required int score,
  }) async {
    try {
      final scores = await _loadScores();
      final key = _scoreKey(categoryIndex, questionCount);
      final oldScore = scores[key] ?? 0;

      if (score <= oldScore) return;

      scores[key] = score;
      await _preferences.setString(_key, jsonEncode(scores));
    } catch (_) {
      // Rekor kaydı oyunu durdurmamalı.
    }
  }
}

class SoloRouteSetupScreen extends StatefulWidget {
  const SoloRouteSetupScreen({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  State<SoloRouteSetupScreen> createState() => _SoloRouteSetupScreenState();
}

class _SoloRouteSetupScreenState extends State<SoloRouteSetupScreen> {
  static const _colors = [
    Color(0xFFE11D48),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFF97316),
    Color(0xFF9333EA),
    Color(0xFF0891B2),
  ];

  final TextEditingController _nameController = TextEditingController(
    text: AppPreferencesService.current.defaultPlayerName,
  );

  int _pawnType = VisualCollectionService.current.favoritePawn;
  int _colorIndex = AppPreferencesService.current.defaultColorIndex;
  bool _starting = false;
  DifficultyMode _difficultyMode = DifficultyMode.relaxed;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerColor = _colors[_colorIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Serbest Rota')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE7F7F5)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 26),
            children: [
              Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A2448), Color(0xFF155E75)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Column(
                  children: [
                    Text('🧭', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 8),
                    Text(
                      'Tek başına altı rozeti topla',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Yanlış cevapta oyun bitmez. Aynı oyuncu '
                      'rotasına devam eder; doğru ve yanlışların '
                      'şampiyon ekranında gösterilir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFD7EDEB), height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                maxLength: 18,
                decoration: const InputDecoration(
                  labelText: 'Oyuncu adı',
                  prefixIcon: Icon(Icons.person_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Oyuncu rengin',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_colors.length, (index) {
                  final selected = index == _colorIndex;
                  final color = _colors[index];

                  return InkWell(
                    onTap: () {
                      GameHaptics.selectionClick();
                      setState(() => _colorIndex = index);
                    },
                    customBorder: const CircleBorder(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 170),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.black : Colors.white,
                          width: selected ? 3 : 2,
                        ),
                        boxShadow:
                            selected
                                ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.48),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                                : null,
                      ),
                      child:
                          selected
                              ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                              )
                              : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Text(
                'Piyonunu seç',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: PawnCatalog.all.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: 0.76,
                ),
                itemBuilder: (context, index) {
                  final pawn = PawnCatalog.all[index];
                  final selected = index == _pawnType;

                  return InkWell(
                    onTap: () {
                      GameHaptics.selectionClick();
                      setState(() => _pawnType = index);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            selected
                                ? playerColor.withOpacity(0.13)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              selected ? playerColor : const Color(0xFFD7DEE8),
                          width: selected ? 2.4 : 1.1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PawnToken(
                            type: index,
                            color: playerColor,
                            active: selected,
                            width: 58,
                            height: 72,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            pawn.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              DifficultyModeCard(
                value: _difficultyMode,
                onChanged: (mode) {
                  setState(() => _difficultyMode = mode);
                },
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _starting ? null : _startSoloRoute,
                icon: const Icon(Icons.explore_rounded),
                label: Text(
                  _starting ? 'Hazırlanıyor…' : 'Serbest Rotaya Başla',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startSoloRoute() async {
    if (_starting) return;

    setState(() => _starting = true);

    final name = _nameController.text.trim();
    final player = PlayerData(
      name: name.isEmpty ? 'Oyuncu' : name,
      color: _colors[_colorIndex],
      pawnType: _pawnType,
      difficultyMode: _difficultyMode,
    );

    await GameSaveService.clear();
    await CareerStatsService.recordGameStarted();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => GameScreen(
              questionBank: widget.questionBank,
              players: [player],
              initialStatus: 'Serbest Rota başladı. Altı rozeti topla! 🧭',
            ),
      ),
    );
  }
}

class MarathonSetupScreen extends StatefulWidget {
  const MarathonSetupScreen({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  State<MarathonSetupScreen> createState() => _MarathonSetupScreenState();
}

class _MarathonSetupScreenState extends State<MarathonSetupScreen> {
  int? _categoryIndex;
  int _questionCount = 10;
  DifficultyMode _difficultyMode = DifficultyMode.relaxed;

  int get _poolSize {
    if (_categoryIndex == null) {
      return widget.questionBank.totalCount;
    }

    return widget.questionBank.questionsByCategory[_categoryIndex]?.length ?? 0;
  }

  List<int> get _availableCounts {
    final counts = <int>[
      for (final count in const [10, 20, 50])
        if (count <= _poolSize) count,
    ];

    if (counts.isEmpty && _poolSize > 0) {
      counts.add(_poolSize);
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final availableCounts = _availableCounts;

    if (!availableCounts.contains(_questionCount) &&
        availableCounts.isNotEmpty) {
      _questionCount = availableCounts.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Soru Maratonu')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C1D95), Color(0xFF155E75)],
                ),
                borderRadius: BorderRadius.circular(27),
              ),
              child: const Column(
                children: [
                  Text('🧠⚡', style: TextStyle(fontSize: 46)),
                  SizedBox(height: 8),
                  Text(
                    'Tahtasız hızlı bilgi turu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Soruları art arda çöz, doğru serini büyüt '
                    've kendi rekorunu geç.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFE7E1F0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _categoryTile(
              categoryIndex: null,
              emoji: '🎲',
              title: 'Karışık',
              subtitle: 'Altı kategoriden rastgele',
              color: const Color(0xFF475569),
            ),
            const SizedBox(height: 8),
            for (
              var index = 0;
              index < GameCategory.values.length;
              index++
            ) ...[
              _categoryTile(
                categoryIndex: index,
                emoji: GameCategory.values[index].emoji,
                title: GameCategory.values[index].label,
                subtitle:
                    '${widget.questionBank.questionsByCategory[index]?.length ?? 0} soru',
                color: GameCategory.values[index].color,
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            const Text(
              'Tur uzunluğu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            SegmentedButton<int>(
              segments: [
                for (final count in availableCounts)
                  ButtonSegment<int>(value: count, label: Text('$count soru')),
              ],
              selected: {_questionCount},
              onSelectionChanged: (selection) {
                setState(() => _questionCount = selection.first);
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<int>(
              future: MarathonScoreService.bestScore(
                categoryIndex: _categoryIndex,
                questionCount: _questionCount,
              ),
              builder: (context, snapshot) {
                final best = snapshot.data ?? 0;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7D6),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: const Color(0xFFEAB308)),
                  ),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 27)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          best == 0
                              ? 'Bu ayarda henüz rekor yok.'
                              : 'En yüksek skor: $best / $_questionCount',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            DifficultyModeCard(
              value: _difficultyMode,
              onChanged: (mode) {
                setState(() => _difficultyMode = mode);
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: availableCounts.isEmpty ? null : _startMarathon,
              icon: const Icon(Icons.bolt_rounded),
              label: const Text(
                'Maratonu Başlat',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile({
    required int? categoryIndex,
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final selected = categoryIndex == _categoryIndex;

    return InkWell(
      onTap: () {
        GameHaptics.selectionClick();

        setState(() {
          _categoryIndex = categoryIndex;
          final counts = _availableCounts;

          if (!counts.contains(_questionCount) && counts.isNotEmpty) {
            _questionCount = counts.first;
          }
        });
      },
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.14) : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? color : const Color(0xFFD7DEE8),
            width: selected ? 2.2 : 1.1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 27)),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }

  void _startMarathon() {
    final pool =
        _categoryIndex == null
            ? widget.questionBank.questionsByCategory.values
                .expand((questions) => questions)
                .toList()
            : List<QuizQuestion>.from(
              widget.questionBank.questionsByCategory[_categoryIndex] ??
                  const <QuizQuestion>[],
            );

    final questions = DifficultyBalance.pickMarathonQuestions(
      questionBank: widget.questionBank,
      pool: pool,
      count: min(_questionCount, pool.length),
      random: Random(),
      mode: _difficultyMode,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => MarathonScreen(
              questionBank: widget.questionBank,
              questions: questions,
              categoryIndex: _categoryIndex,
            ),
      ),
    );
  }
}

class MarathonScreen extends StatefulWidget {
  const MarathonScreen({
    required this.questionBank,
    required this.questions,
    required this.categoryIndex,
    super.key,
  });

  final QuestionBank questionBank;
  final List<QuizQuestion> questions;
  final int? categoryIndex;

  @override
  State<MarathonScreen> createState() => _MarathonScreenState();
}

class _MarathonScreenState extends State<MarathonScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  final JokerWallet _jokers = JokerWallet.starter();
  final Set<String> _usedQuestionIds = <String>{};

  int _questionIndex = 0;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _maxStreak = 0;
  bool _busy = false;
  bool _exitDialogOpen = false;
  late final GameTelemetrySession _telemetry;

  QuizQuestion get _question => widget.questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _telemetry = GameTelemetrySession.start(
      gameMode: 'marathon',
      category:
          widget.categoryIndex == null
              ? 'mixed'
              : GameCategory.values[widget.categoryIndex!].label,
    );
  }

  @override
  void dispose() {
    _telemetry.abandon();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = GameCategory.values[_question.categoryIndex];
    final progress =
        widget.questions.isEmpty
            ? 0.0
            : _questionIndex / widget.questions.length;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_confirmExit());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Soru Maratonu'),
          leading: IconButton(
            onPressed: _confirmExit,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1029), Color(0xFF123B4A)],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 26),
              children: [
                Row(
                  children: [
                    Expanded(child: _scoreCard('✅', '$_correct', 'Doğru')),
                    const SizedBox(width: 8),
                    Expanded(child: _scoreCard('🔥', '$_streak', 'Seri')),
                    const SizedBox(width: 8),
                    Expanded(child: _scoreCard('❌', '$_wrong', 'Yanlış')),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0x33FFFFFF),
                    color: const Color(0xFFFFE082),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Soru ${_questionIndex + 1} / '
                  '${widget.questions.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD8CCEA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 54),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category.label,
                        style: TextStyle(
                          color: category.darkColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        widget.categoryIndex == null
                            ? 'Karışık maraton'
                            : 'Kategori maratonu',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _busy ? null : _openQuestion,
                        style: FilledButton.styleFrom(
                          backgroundColor: category.color,
                        ),
                        icon: const Icon(Icons.quiz_rounded),
                        label: Text(
                          _busy ? 'Bekle…' : 'Soruyu Aç',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Her doğru cevap serini bir artırır. '
                  'Yanlış cevap seriyi sıfırlar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFCBC1D6), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFCBC1D6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuestion() async {
    if (_busy || widget.questions.isEmpty) return;

    setState(() => _busy = true);

    final plan = await GameplayBoostDialogs.chooseQuestionPlan(
      context,
      baseCategoryIndex: _question.categoryIndex,
      normalDifficulty: _question.difficulty,
      wallet: null,
      allowCategoryChange: false,
    );

    if (!mounted) return;

    var questionForPlay = _question;

    if (plan.risky) {
      questionForPlay =
          GameplayBoostQuestionPicker.riskQuestion(
            questionBank: widget.questionBank,
            current: _question,
            preferredDifficulty: plan.preferredDifficulty,
            usedQuestionIds: _usedQuestionIds,
          ) ??
          _question;
    }

    _usedQuestionIds.add(questionForPlay.id);

    final correct =
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder:
                (_) => QuestionScreen(
                  question: questionForPlay,
                  jokers: _jokers,
                  riskMode: plan.risky,
                  xpMultiplier: plan.xpMultiplier,
                  onChangeQuestion: (current) async {
                    return GameplayBoostQuestionPicker.replacement(
                      questionBank: widget.questionBank,
                      current: current,
                      usedQuestionIds: _usedQuestionIds,
                    );
                  },
                ),
          ),
        ) ??
        false;

    if (!mounted) return;

    if (correct) {
      _correct++;
      _streak++;
      _maxStreak = max(_maxStreak, _streak);
      unawaited(SoundFx.correct());
    } else {
      _wrong++;
      _streak = 0;
      unawaited(SoundFx.wrong());
    }

    final answerGain = await CareerStatsService.recordAnswer(
      categoryIndex: questionForPlay.categoryIndex,
      difficulty: questionForPlay.difficulty,
      correct: correct,
      xpMultiplier: plan.xpMultiplier,
    );

    if (mounted) {
      await XpCelebration.show(context, answerGain);
    }

    final finished = _questionIndex + 1 >= widget.questions.length;

    if (finished) {
      _stopwatch.stop();
      _telemetry.complete(
        _correct > _wrong ? 'completed_positive' : 'completed',
      );

      final previousBest = await MarathonScoreService.bestScore(
        categoryIndex: widget.categoryIndex,
        questionCount: widget.questions.length,
      );

      await MarathonScoreService.saveBest(
        categoryIndex: widget.categoryIndex,
        questionCount: widget.questions.length,
        score: _correct,
      );
      final marathonGain = await CareerStatsService.recordMarathon(
        questionCount: widget.questions.length,
        correct: _correct,
        bestStreak: _maxStreak,
      );

      if (!mounted) return;

      await XpCelebration.show(context, marathonGain);

      if (!mounted) return;

      if (_correct > previousBest) {
        unawaited(SoundFx.win());
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => MarathonResultScreen(
                questionBank: widget.questionBank,
                categoryIndex: widget.categoryIndex,
                questionCount: widget.questions.length,
                correct: _correct,
                wrong: _wrong,
                maxStreak: _maxStreak,
                elapsed: _stopwatch.elapsed,
                previousBest: previousBest,
              ),
        ),
      );
      return;
    }

    setState(() {
      _questionIndex++;
      _busy = false;
    });
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;

    _exitDialogOpen = true;

    final exit =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Maratondan çıkılsın mı?'),
              content: const Text(
                'Bu maratonun mevcut ilerlemesi '
                'kaydedilmeyecek.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Devam Et'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Maratondan Çık'),
                ),
              ],
            );
          },
        ) ??
        false;

    _exitDialogOpen = false;

    if (exit && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class MarathonResultScreen extends StatelessWidget {
  const MarathonResultScreen({
    required this.questionBank,
    required this.categoryIndex,
    required this.questionCount,
    required this.correct,
    required this.wrong,
    required this.maxStreak,
    required this.elapsed,
    required this.previousBest,
    super.key,
  });

  final QuestionBank questionBank;
  final int? categoryIndex;
  final int questionCount;
  final int correct;
  final int wrong;
  final int maxStreak;
  final Duration elapsed;
  final int previousBest;

  @override
  Widget build(BuildContext context) {
    final percentage =
        questionCount == 0 ? 0 : (correct / questionCount * 100).round();
    final isNewRecord = correct > previousBest;
    final modeLabel =
        categoryIndex == null
            ? 'Karışık'
            : GameCategory.values[categoryIndex!].label;

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        bottomNavigationBar: const AdBannerSlot(
          placement: AdPlacement.marathonResult,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.2,
              colors: [Color(0xFF5B2C70), Color(0xFF21132D), Color(0xFF0B3440)],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
              children: [
                Text(
                  isNewRecord ? '🏆 YENİ REKOR!' : '🧠 MARATON BİTTİ',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                FamilyRecordCapture.single(
                  name: AppPreferencesService.current.defaultPlayerName,
                  mode: 'Soru Maratonu',
                  score: correct,
                  total: questionCount,
                  won: correct >= max(1, questionCount ~/ 2),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xE61D1027),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFFFD978),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 58)),
                      const SizedBox(height: 8),
                      Text(
                        '$correct / $questionCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '$modeLabel • Başarı %$percentage',
                        style: const TextStyle(
                          color: Color(0xFFD8CCEA),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _resultStat(
                              '🔥',
                              '$maxStreak',
                              'En iyi seri',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _resultStat(
                              '⏱️',
                              _durationText(elapsed),
                              'Süre',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _resultStat('❌', '$wrong', 'Yanlış')),
                        ],
                      ),
                      if (!isNewRecord && previousBest > 0) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Kişisel rekorun: '
                          '$previousBest / $questionCount',
                          style: const TextStyle(
                            color: Color(0xFFFFE082),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                SocialShareButton(
                  dark: true,
                  title: 'Bilgi Rotası Maraton Sonucu',
                  text: SocialShareService.resultText(
                    title: '⚡ Soru Maratonu',
                    score: '$correct / $questionCount',
                    detail:
                        '$modeLabel • Başarı %$percentage • '
                        'En iyi seri $maxStreak',
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                MarathonSetupScreen(questionBank: questionBank),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE082),
                    foregroundColor: const Color(0xFF3A2448),
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(
                    'Yeni Maraton',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x99FFE082)),
                    minimumSize: const Size.fromHeight(54),
                  ),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Ana Menü',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultStat(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFCBC1D6), fontSize: 9),
          ),
        ],
      ),
    );
  }

  String _durationText(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int _playerCount = 2;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(
      text:
          index == 0
              ? AppPreferencesService.current.defaultPlayerName
              : 'Oyuncu ${index + 1}',
    ),
  );

  final List<int> _selectedPawnTypes = List<int>.generate(
    6,
    (index) =>
        index == 0 ? VisualCollectionService.current.favoritePawn : index,
  );

  final List<DifficultyMode> _selectedDifficultyModes =
      List<DifficultyMode>.filled(6, DifficultyMode.relaxed);

  static const List<Color> _playerColors = [
    Color(0xFFE11D48),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFF9333EA),
    Color(0xFFF97316),
    Color(0xFF0891B2),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyuncuları Hazırla')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Oyuncu sayısı: $_playerCount',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Slider(
                            min: 2,
                            max: 6,
                            divisions: 4,
                            value: _playerCount.toDouble(),
                            label: '$_playerCount',
                            onChanged: (value) {
                              setState(() => _playerCount = value.round());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(_playerCount, (index) {
                    final pawn = PawnCatalog.at(_selectedPawnTypes[index]);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _showPawnPicker(index),
                              child: Container(
                                width: 84,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _playerColors[index].withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _playerColors[index].withOpacity(
                                      0.35,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PawnToken(
                                      type: _selectedPawnTypes[index],
                                      color: _playerColors[index],
                                      active: true,
                                      width: 54,
                                      height: 66,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pawn.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        height: 1.05,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Değiştir',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _controllers[index],
                                    maxLength: 16,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      labelText: '${index + 1}. oyuncu',
                                      helperText:
                                          'Yanındaki piyona dokunarak seç',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DifficultyModeDropdown(
                                    value: _selectedDifficultyModes[index],
                                    label: 'Oyuncunun soru seviyesi',
                                    onChanged: (mode) {
                                      setState(() {
                                        _selectedDifficultyModes[index] = mode;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: FilledButton.icon(
                onPressed: _startGame,
                icon: const Icon(Icons.casino_rounded),
                label: const Text(
                  'Tahtaya Geç',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPawnPicker(int playerIndex) async {
    final selected = await PremiumPawnPicker.show(
      context,
      playerNumber: playerIndex + 1,
      initialPawnType: _selectedPawnTypes[playerIndex],
      playerColor: _playerColors[playerIndex],
    );

    if (selected == null || !mounted) return;

    setState(() {
      _selectedPawnTypes[playerIndex] = selected;
    });
  }

  Future<void> _startGame() async {
    final players = <PlayerData>[];

    for (var index = 0; index < _playerCount; index++) {
      final name = _controllers[index].text.trim();

      players.add(
        PlayerData(
          name: name.isEmpty ? 'Oyuncu ${index + 1}' : name,
          color: _playerColors[index],
          pawnType: _selectedPawnTypes[index],
          difficultyMode: _selectedDifficultyModes[index],
        ),
      );
    }

    await GameSaveService.clear();
    await CareerStatsService.recordGameStarted();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) =>
                GameScreen(questionBank: widget.questionBank, players: players),
      ),
    );
  }
}

class WinnerScreen extends StatefulWidget {
  const WinnerScreen({
    required this.questionBank,
    required this.winner,
    required this.players,
    required this.gameId,
    super.key,
  });

  final QuestionBank questionBank;
  final PlayerData winner;
  final List<PlayerData> players;
  final String gameId;

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    if (AppPreferencesService.current.animationMode == 'minimal') {
      _confettiController.value = 0.35;
    } else {
      _confettiController.repeat();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  List<PlayerData> get _ranking {
    final result = List<PlayerData>.from(widget.players);

    result.sort((a, b) {
      final badgeCompare = b.badges.length.compareTo(a.badges.length);
      if (badgeCompare != 0) return badgeCompare;

      final correctCompare = b.correctAnswers.compareTo(a.correctAnswers);
      if (correctCompare != 0) return correctCompare;

      return a.wrongAnswers.compareTo(b.wrongAnswers);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        bottomNavigationBar: const AdBannerSlot(
          placement: AdPlacement.boardResult,
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.45),
                    radius: 1.25,
                    colors: [
                      Color(0xFF6B3A82),
                      Color(0xFF281538),
                      Color(0xFF071D29),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: WinnerConfettiPainter(
                        progress: _confettiController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '🏆 ŞAMPİYON 🏆',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFFE082),
                        fontSize: 25,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWinnerCard(),
                    const SizedBox(height: 16),
                    _buildRankingCard(),
                    const SizedBox(height: 16),
                    SupportRewardCard(gameId: widget.gameId, dark: true),
                    FamilyRecordCapture.board(
                      players: widget.players,
                      winner: widget.winner,
                    ),
                    const SizedBox(height: 10),
                    SocialShareButton(
                      dark: true,
                      title: 'Bilgi Rotası Şampiyonu',
                      text: <String>[
                        '🧭 BİLGİ ROTASI',
                        '🏆 ${widget.winner.name} şampiyon!',
                        '${widget.winner.correctAnswers} doğru • '
                            '${widget.winner.badges.length}/6 rozet',
                        '',
                        'Aynı telefonda bilgi düellosu!',
                      ].join('\n'),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (_) => PlayerSetupScreen(
                                  questionBank: widget.questionBank,
                                ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE082),
                        foregroundColor: const Color(0xFF3A2448),
                      ),
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text(
                        'Yeni Oyun',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0x99FFE082)),
                        minimumSize: const Size.fromHeight(54),
                      ),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text(
                        'Ana Menü',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerCard() {
    final player = widget.winner;
    final totalAnswers = player.correctAnswers + player.wrongAnswers;
    final successRate =
        totalAnswers == 0
            ? 0
            : (player.correctAnswers / totalAnswers * 100).round();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xE61D1027),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFFD978), width: 2.2),
        boxShadow: const [
          BoxShadow(color: Color(0x7732E0D0), blurRadius: 30, spreadRadius: 2),
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 152,
                height: 152,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      player.color.withOpacity(0.72),
                      const Color(0x001D1027),
                    ],
                  ),
                ),
              ),
              PawnToken(
                type: player.pawnType,
                color: player.color,
                active: true,
                width: 105,
                height: 128,
              ),
              const Positioned(
                top: 2,
                child: Text('👑', style: TextStyle(fontSize: 43)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            player.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 31,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bilgi Rotası şampiyonu!',
            style: TextStyle(
              color: Color(0xFFFFE082),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _statBox('6/6', 'Rozet', '🏅')),
              const SizedBox(width: 8),
              Expanded(
                child: _statBox('${player.correctAnswers}', 'Doğru', '✅'),
              ),
              const SizedBox(width: 8),
              Expanded(child: _statBox('%$successRate', 'Başarı', '🎯')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 21)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCBC1D6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard() {
    final ranking = _ranking;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xD9191422),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Oyun sıralaması',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          for (var index = 0; index < ranking.length; index++)
            _rankingRow(ranking[index], index),
        ],
      ),
    );
  }

  Widget _rankingRow(PlayerData player, int index) {
    final medals = ['🥇', '🥈', '🥉'];
    final medal = index < medals.length ? medals[index] : '${index + 1}.';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color:
            identical(player, widget.winner)
                ? const Color(0x22FFE082)
                : const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              identical(player, widget.winner)
                  ? const Color(0x88FFE082)
                  : const Color(0x22FFFFFF),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(medal, style: const TextStyle(fontSize: 21)),
          ),
          PawnToken(
            type: player.pawnType,
            color: player.color,
            active: identical(player, widget.winner),
            width: 31,
            height: 39,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '${player.badges.length}/6 • '
            '${player.correctAnswers}D',
            style: const TextStyle(
              color: Color(0xFFD8CCEA),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class WinnerConfettiPainter extends CustomPainter {
  const WinnerConfettiPainter({required this.progress});

  final double progress;

  static const _colors = [
    Color(0xFFFFD54F),
    Color(0xFF26C6DA),
    Color(0xFFEC407A),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < 46; index++) {
      final seed = index * 71;
      final xBase = ((seed * 37) % 1000) / 1000 * size.width;
      final speed = 0.55 + (seed % 8) * 0.08;
      final fall = (progress * speed + (index % 11) / 11) % 1;
      final sway = sin(progress * pi * 4 + index) * 18;
      final y = fall * (size.height + 80) - 40;
      final x = xBase + sway;
      final rotation = progress * pi * 6 + index * 0.8;
      final color = _colors[index % _colors.length];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 8 + (index % 3) * 2,
            height: 15 + (index % 4) * 2,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = color.withOpacity(0.88),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant WinnerConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.questionBank,
    required this.players,
    this.initialPlayerIndex = 0,
    this.initialUsedQuestionIds = const <String>{},
    this.initialStatus,
    super.key,
  });

  final QuestionBank questionBank;
  final List<PlayerData> players;
  final int initialPlayerIndex;
  final Set<String> initialUsedQuestionIds;
  final String? initialStatus;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  late final String _gameId;
  int _currentPlayerIndex = 0;
  int? _lastDice;
  bool _diceRolling = false;
  bool _bonusRollPending = false;
  bool _isBusy = false;
  String _status = 'Zarı at ve rotaya çık.';
  PlayerData? _winner;
  List<MoveOption> _moveOptions = const <MoveOption>[];
  Completer<MoveOption>? _moveCompleter;
  MoveOption? _activeMove;
  double _routeOpacity = 0;
  int? _landingNodeId;
  int _landingPulse = 0;
  bool _soundEnabled = AppPreferencesService.current.soundEnabled;
  bool _allowRoutePop = false;
  bool _exitDialogOpen = false;
  final Set<String> _usedQuestionIds = <String>{};
  late final GameTelemetrySession _telemetry;

  PlayerData get _currentPlayer => widget.players[_currentPlayerIndex];

  String _chooseQuestionDifficulty({bool finalQuestion = false}) {
    return _currentPlayer.difficultyMode.chooseDifficulty(
      _random,
      correctStreak: _currentPlayer.correctStreak,
      wrongStreak: _currentPlayer.wrongStreak,
      finalQuestion: finalQuestion,
      forceRelaxed: AppPreferencesService.current.childMode,
    );
  }

  String get _difficultyStatusText {
    final mode =
        AppPreferencesService.current.childMode
            ? DifficultyMode.relaxed
            : _currentPlayer.difficultyMode;

    return '${mode.emoji} ${mode.label} • '
        '${_currentPlayer.adaptiveDifficultyLabel}';
  }

  @override
  void initState() {
    super.initState();
    _telemetry = GameTelemetrySession.start(gameMode: 'board_game');
    _gameId = 'board_${DateTime.now().microsecondsSinceEpoch}';

    if (widget.players.isNotEmpty) {
      _currentPlayerIndex =
          widget.initialPlayerIndex.clamp(0, widget.players.length - 1).toInt();
    }

    _status = widget.initialStatus ?? 'Zarı at ve rotaya çık.';
    _usedQuestionIds.addAll(widget.initialUsedQuestionIds);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_saveGame());
    });
  }

  @override
  void dispose() {
    _telemetry.abandon();
    super.dispose();
  }

  Future<void> _saveGame() {
    return GameSaveService.save(
      players: widget.players,
      currentPlayerIndex: _currentPlayerIndex,
      usedQuestionIds: _usedQuestionIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final compactLayout = GameUiMetrics.isCompact(
      MediaQuery.sizeOf(context).width,
    );

    return PopScope<Object?>(
      canPop: _allowRoutePop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_handleSystemBack());
        }
      },
      child: Scaffold(
        backgroundColor: BoardThemeArt.screenBackground(
          VisualCollectionService.theme.id,
        ),
        appBar: AppBar(
          backgroundColor: BoardThemeArt.appBarColor(
            VisualCollectionService.theme.id,
          ),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Text('Bilgi Rotası'),
          actions: [
            IconButton(
              tooltip: _soundEnabled ? 'Sesleri kapat' : 'Sesleri aç',
              onPressed: () async {
                final willEnable = !_soundEnabled;

                setState(() {
                  _soundEnabled = willEnable;
                });

                await AppPreferencesService.setSoundEnabled(willEnable);

                if (willEnable) {
                  await SoundFx.test();
                }
              },
              icon: Icon(
                _soundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
              ),
            ),
            IconButton(
              tooltip: 'Oyunu bitir',
              onPressed: _confirmExit,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        bottomNavigationBar:
            compactLayout
                ? GameMobileActionBar(
                  player: _currentPlayer,
                  busy: _isBusy,
                  hasWinner: _winner != null,
                  onPressed: _onMainAction,
                )
                : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              if (isWide) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildBoardCard()),
                      const SizedBox(width: 18),
                      SizedBox(
                        width: 350,
                        child: _buildControlPanel(showMainAction: true),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 112),
                clipBehavior: Clip.none,
                children: [
                  _buildBoardCard(),
                  const SizedBox(height: 10),
                  _buildControlPanel(showMainAction: false),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBoardCard() {
    final themeId = VisualCollectionService.theme.id;

    return Card(
      color: BoardThemeArt.boardCardColor(themeId),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: BoardThemeArt.borderColor(themeId).withOpacity(0.72),
          width: 1.6,
        ),
      ),
      clipBehavior: Clip.none,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final boardSize = GameUiMetrics.boardSize(constraints.maxWidth);

                return Center(
                  child: SizedBox.square(
                    dimension: boardSize,
                    child: GameBoard(
                      players: widget.players,
                      currentPlayerIndex: _currentPlayerIndex,
                      moveOptions: _moveOptions,
                      onMoveSelected: _selectMoveFromBoard,
                      activeMove: _activeMove,
                      routeOpacity: _routeOpacity,
                      landingNodeId: _landingNodeId,
                      landingPulse: _landingPulse,
                    ),
                  ),
                );
              },
            ),
            const AccessibilityCategoryLegend(),
            GameStatusBanner(
              status: _status,
              busy: _isBusy,
              waitingForRoute: _moveOptions.isNotEmpty,
              playerColor: _currentPlayer.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel({required bool showMainAction}) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GameTurnHeader(
                  player: _currentPlayer,
                  lastDice: _lastDice,
                  diceRolling: _diceRolling,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Toplanan rozetler',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                GameBadgeStrip(player: _currentPlayer),
                if (showMainAction) ...[
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed:
                        _isBusy || _winner != null ? null : _onMainAction,
                    icon: Icon(
                      GameUiMetrics.actionIcon(
                        busy: _isBusy,
                        hasAllBadges: _currentPlayer.hasAllBadges,
                      ),
                    ),
                    label: Text(
                      GameUiMetrics.actionLabel(
                        busy: _isBusy,
                        hasAllBadges: _currentPlayer.hasAllBadges,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else
                  const SizedBox(height: 12),
                if (_currentPlayer.doubleChance)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withOpacity(0.48),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🍀', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 7),
                        Text(
                          'Çifte Şans hazır',
                          style: TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                JokerWalletMiniBar(wallet: _currentPlayer.jokers),
                const SizedBox(height: 9),
                GameProgressSummary(
                  player: _currentPlayer,
                  difficultyText: _difficultyStatusText,
                  usedQuestionCount: _usedQuestionIds.length,
                  totalQuestionCount: widget.questionBank.totalCount,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Oyuncular',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                ...List.generate(widget.players.length, (index) {
                  final player = widget.players[index];
                  final active = index == _currentPlayerIndex;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          active
                              ? player.color.withOpacity(0.12)
                              : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            active
                                ? player.color.withOpacity(0.55)
                                : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        PawnToken(
                          type: player.pawnType,
                          color: player.color,
                          active: active,
                          width: 32,
                          height: 40,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            player.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  active ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text('${player.badges.length}/6'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onMainAction() async {
    if (_currentPlayer.hasAllBadges) {
      await _askFinalQuestion();
    } else {
      await _rollDiceAndAsk();
    }
  }

  Future<void> _rollDiceAndAsk() async {
    if (_isBusy || _winner != null) return;

    setState(() {
      _isBusy = true;
      _lastDice = null;
      _diceRolling = true;
      _status = '${_currentPlayer.name} zarı atıyor…';
    });

    unawaited(SoundFx.dice());
    GameHaptics.mediumImpact();

    for (var i = 0; i < 12; i++) {
      await Future<void>.delayed(Duration(milliseconds: 65 + i * 8));

      if (!mounted) return;

      setState(() {
        _lastDice = _random.nextInt(6) + 1;
      });

      if (i.isEven) {
        GameHaptics.selectionClick();
      }
    }

    final diceResult = _random.nextInt(6) + 1;

    setState(() {
      _lastDice = diceResult;
      _diceRolling = false;
      _status = '${_currentPlayer.name} $diceResult attı!';
    });

    GameHaptics.heavyImpact();

    await Future<void>.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _status = '${_currentPlayer.name} $diceResult attı. Yolunu seç.';
    });

    final options = BoardMap.options(_currentPlayer.position, diceResult);

    if (!mounted) return;

    final MoveOption? selected;

    if (options.length == 1) {
      selected = options.first;
    } else {
      selected = await _waitForBoardMove(options);
    }

    if (!mounted) return;

    if (selected == null) {
      setState(() {
        _isBusy = false;
        _status = 'Yol seçimi iptal edildi.';
      });
      return;
    }

    setState(() {
      _activeMove = selected;
      _routeOpacity = 1;
      _landingNodeId = null;
      _status = '${_currentPlayer.name} rotada ilerliyor…';
    });

    await _animatePawnPath(selected.path);

    if (!mounted) return;

    var target = BoardMap.node(_currentPlayer.position);
    await _showLanding(target);

    if (!mounted) return;

    int? selectedCategory;
    final specialEffect = target.specialEffect;

    if (specialEffect != null) {
      selectedCategory = await _resolveSpecialEffect(specialEffect);

      if (!mounted) return;

      target = BoardMap.node(_currentPlayer.position);
      await _saveGame();

      if (_bonusRollPending) {
        setState(() {
          _bonusRollPending = false;
          _isBusy = false;
          _lastDice = null;
          _diceRolling = false;
          _status = '${_currentPlayer.name}, tekrar zar atma hakkı sende! 🎲';
        });
        return;
      }
    }

    final baseCategoryIndex =
        selectedCategory ??
        (target.categoryIndex < 0
            ? _random.nextInt(GameCategory.values.length)
            : target.categoryIndex);

    final plan = await GameplayBoostDialogs.chooseQuestionPlan(
      context,
      baseCategoryIndex: baseCategoryIndex,
      normalDifficulty: _chooseQuestionDifficulty(),
      wallet: _currentPlayer.jokers,
    );

    if (!mounted) return;

    final categoryIndex = plan.categoryIndex;

    final draw = widget.questionBank.nextQuestion(
      categoryIndex: categoryIndex,
      random: _random,
      usedQuestionIds: _usedQuestionIds,
      preferredDifficulty: plan.preferredDifficulty,
    );
    final question = draw.question;

    if (draw.poolReset && mounted) {
      setState(() {
        _status =
            '${GameCategory.values[categoryIndex].label} '
            'soru havuzu tamamlandı; yeni tur başladı.';
      });
    }

    await _saveGame();

    if (!mounted) return;

    final correct =
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder:
                (_) => QuestionScreen(
                  question: question,
                  isBadgeQuestion: target.isBadge,
                  jokers: _currentPlayer.jokers,
                  riskMode: plan.risky,
                  xpMultiplier: plan.xpMultiplier,
                  onChangeQuestion: (current) async {
                    final replacement = GameplayBoostQuestionPicker.replacement(
                      questionBank: widget.questionBank,
                      current: current,
                      usedQuestionIds: _usedQuestionIds,
                    );

                    if (replacement != null) {
                      await _saveGame();
                    }

                    return replacement;
                  },
                ),
          ),
        ) ??
        false;

    if (!mounted) return;

    await _handleAnswer(
      correct: correct,
      categoryIndex: categoryIndex,
      difficulty: question.difficulty,
      xpMultiplier: plan.xpMultiplier,
      wasBadgeCell: target.isBadge,
    );
  }

  Future<void> _animatePawnPath(List<int> path) async {
    final pawnType = _currentPlayer.pawnType;
    var stepIndex = 0;

    for (final id in path.skip(1)) {
      setState(() {
        _currentPlayer.position = id;
        _currentPlayer.movePulse++;
      });

      unawaited(SoundFx.pawnStep(pawnType, stepIndex: stepIndex));
      stepIndex++;
      GameHaptics.selectionClick();

      await Future<void>.delayed(const Duration(milliseconds: 390));

      if (!mounted) return;
    }
  }

  Future<void> _showLanding(BoardNode target) async {
    setState(() {
      _landingNodeId = _currentPlayer.position;
      _landingPulse++;
      _routeOpacity = 0;
      _status =
          '${_currentPlayer.name}, ${BoardMap.label(target.id)} alanına geldi.';
    });

    unawaited(SoundFx.landing());
    GameHaptics.heavyImpact();

    await Future<void>.delayed(const Duration(milliseconds: 520));

    if (!mounted) return;

    setState(() {
      _activeMove = null;
      _landingNodeId = null;
    });
  }

  Future<int?> _resolveSpecialEffect(SpecialCellEffect effect) async {
    if (effect == SpecialCellEffect.randomJoker) {
      final accepted = await AdMonetizationDialogs.askForJokerReward(context);
      if (!accepted || !mounted) return null;

      final earned = await AdMonetizationService.instance.showRewarded();
      if (!mounted) return null;

      if (!earned) {
        setState(() {
          _status = 'Reklam tamamlanmadı; oyun joker verilmeden devam ediyor.';
        });
        return null;
      }

      final kind = JokerKind.values[_random.nextInt(JokerKind.values.length)];
      _currentPlayer.jokers.grant(kind);

      setState(() {
        _status =
            '${_currentPlayer.name}, ${kind.emoji} ${kind.title} jokeri kazandı!';
      });

      unawaited(SoundFx.badge());
      GameHaptics.heavyImpact();
      await _showJokerRewardDialog(kind);
      return null;
    }

    await _showSpecialEffectDialog(effect);

    if (!mounted) return null;

    unawaited(SoundFx.badge());
    GameHaptics.heavyImpact();

    switch (effect) {
      case SpecialCellEffect.rollAgain:
        setState(() {
          _bonusRollPending = true;
          _status = '${_currentPlayer.name} tekrar zar atma hakkı kazandı! 🎲';
        });
        return null;

      case SpecialCellEffect.randomJoker:
        return null;

      case SpecialCellEffect.chooseCategory:
        return _chooseQuestionCategory();

      case SpecialCellEffect.doubleChance:
        setState(() {
          _currentPlayer.doubleChance = true;
          _status = '${_currentPlayer.name} Çifte Şans hakkı kazandı! 🍀';
        });
        return null;
    }
  }

  Future<void> _showJokerRewardDialog(JokerKind kind) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Text(kind.emoji, style: const TextStyle(fontSize: 52)),
          title: const Text('Joker Kazandın!'),
          content: Text(
            '${kind.title} jokerine +1 eklendi.\n\n'
            'Yeni toplam: ${_currentPlayer.jokers.count(kind)}',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Harika'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSpecialEffectDialog(SpecialCellEffect effect) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Text(effect.emoji, style: const TextStyle(fontSize: 48)),
          title: Text('Özel Kutu: ${effect.title}'),
          content: Text(
            effect == SpecialCellEffect.doubleChance &&
                    _currentPlayer.doubleChance
                ? 'Çifte Şans hakkın zaten hazır. '
                    'Mevcut hakkın korunacak.'
                : effect.description,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Uygula'),
            ),
          ],
        );
      },
    );
  }

  Future<int> _chooseQuestionCategory() async {
    final selected = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Soru kategorisini seç'),
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(GameCategory.values.length, (index) {
                final category = GameCategory.values[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: ListTile(
                    tileColor: category.color.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: category.color.withOpacity(0.45)),
                    ),
                    leading: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                    title: Text(
                      category.label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onTap: () => Navigator.pop(dialogContext, index),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );

    final categoryIndex =
        selected ?? _random.nextInt(GameCategory.values.length);

    if (mounted) {
      setState(() {
        _status =
            '${GameCategory.values[categoryIndex].label} kategorisi seçildi.';
      });
    }

    return categoryIndex;
  }

  Future<MoveOption?> _waitForBoardMove(List<MoveOption> options) async {
    final completer = Completer<MoveOption>();

    setState(() {
      _moveOptions = List<MoveOption>.unmodifiable(options);
      _moveCompleter = completer;
      _status = '${_currentPlayer.name}, parlayan hedeflerden birine dokun.';
    });

    GameHaptics.mediumImpact();

    final selected = await completer.future;

    if (!mounted) return null;

    setState(() {
      _moveOptions = const <MoveOption>[];
      _moveCompleter = null;
      _status = '${BoardMap.routeTitle(selected)} seçildi.';
    });

    return selected;
  }

  void _selectMoveFromBoard(MoveOption option) {
    final completer = _moveCompleter;

    if (completer == null || completer.isCompleted) return;

    GameHaptics.heavyImpact();
    completer.complete(option);
  }

  Future<void> _askFinalQuestion() async {
    if (_isBusy || _winner != null) return;

    setState(() {
      _isBusy = true;
      _status = '${_currentPlayer.name} final sorusunda!';
    });

    final categoryIndex = _random.nextInt(GameCategory.values.length);
    final draw = widget.questionBank.nextQuestion(
      categoryIndex: categoryIndex,
      random: _random,
      usedQuestionIds: _usedQuestionIds,
      preferredDifficulty: _chooseQuestionDifficulty(finalQuestion: true),
    );
    final question = draw.question;

    await _saveGame();

    if (!mounted) return;

    final correct =
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder:
                (_) =>
                    QuestionScreen(question: question, isFinalQuestion: true),
          ),
        ) ??
        false;

    if (!mounted) return;

    _currentPlayer.registerAdaptiveAnswer(correct);

    if (correct) {
      _currentPlayer.correctAnswers++;

      setState(() {
        _winner = _currentPlayer;
        _status = '${_currentPlayer.name} Bilgi Rotası şampiyonu!';
        _isBusy = false;
      });

      final answerGain = await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        difficulty: question.difficulty,
        correct: true,
      );

      if (mounted) {
        await XpCelebration.show(context, answerGain);
      }

      final completionGain = await CareerStatsService.recordGameCompleted(
        solo: widget.players.length == 1,
      );

      if (mounted) {
        await XpCelebration.show(context, completionGain);
      }
      await GameSaveService.clear();
      unawaited(SoundFx.win());
      GameHaptics.heavyImpact();
      await _showWinnerDialog(_currentPlayer);
    } else {
      _currentPlayer.wrongAnswers++;
      final answerGain = await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        difficulty: question.difficulty,
        correct: false,
      );

      if (mounted) {
        await XpCelebration.show(context, answerGain);
      }

      _advanceTurn();

      setState(() {
        _status =
            'Final kaçtı. Sıra '
            '${_currentPlayer.name} oyuncusunda.';
        _isBusy = false;
      });

      unawaited(SoundFx.wrong());
      await _saveGame();
    }
  }

  Future<void> _handleAnswer({
    required bool correct,
    required int categoryIndex,
    required String difficulty,
    required int xpMultiplier,
    required bool wasBadgeCell,
  }) async {
    final answeredPlayer = _currentPlayer;
    answeredPlayer.registerAdaptiveAnswer(correct);

    if (correct) {
      answeredPlayer.correctAnswers++;
      var badgeMessage = '';
      var badgeEarned = false;

      if (wasBadgeCell && !answeredPlayer.badges.contains(categoryIndex)) {
        answeredPlayer.badges.add(categoryIndex);
        badgeEarned = true;
        badgeMessage =
            ' ${GameCategory.values[categoryIndex].label} '
            'rozeti kazanıldı!';
      }

      setState(() {
        _status =
            answeredPlayer.hasAllBadges
                ? 'Altı rozet tamam! Final sorusu hazır. 🏆'
                : 'Doğru cevap!$badgeMessage '
                    'Aynı oyuncu devam ediyor.';
        _isBusy = false;
      });

      unawaited(badgeEarned ? SoundFx.badge() : SoundFx.correct());
      GameHaptics.selectionClick();

      final xpGain = await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        difficulty: difficulty,
        correct: true,
        badgeEarned: badgeEarned,
        xpMultiplier: xpMultiplier,
      );

      if (mounted) {
        await XpCelebration.show(context, xpGain);
      }
    } else {
      answeredPlayer.wrongAnswers++;

      if (answeredPlayer.doubleChance) {
        answeredPlayer.doubleChance = false;

        setState(() {
          _lastDice = null;
          _status =
              'Yanlış cevap ama Çifte Şans kullanıldı! '
              '${answeredPlayer.name} tekrar oynuyor. 🍀';
          _isBusy = false;
        });
      } else {
        _advanceTurn();

        setState(() {
          _status =
              'Yanlış cevap. Sıra '
              '${_currentPlayer.name} oyuncusunda.';
          _isBusy = false;
        });
      }

      unawaited(SoundFx.wrong());

      final xpGain = await CareerStatsService.recordAnswer(
        categoryIndex: categoryIndex,
        difficulty: difficulty,
        correct: false,
        xpMultiplier: xpMultiplier,
      );

      if (mounted) {
        await XpCelebration.show(context, xpGain);
      }
    }

    await _saveGame();
  }

  void _advanceTurn() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % widget.players.length;
    _lastDice = null;
  }

  Future<void> _showWinnerDialog(PlayerData player) async {
    _telemetry.complete('completed');
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => WinnerScreen(
              questionBank: widget.questionBank,
              winner: player,
              players: widget.players,
              gameId: _gameId,
            ),
      ),
    );
  }

  Future<void> _handleSystemBack() async {
    if (_allowRoutePop || _exitDialogOpen || !mounted) return;
    await _confirmExit();
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;

    _exitDialogOpen = true;
    String? action;

    try {
      action = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Oyundan çıkılsın mı?'),
            content: const Text(
              'İlerlemeni kaydedip daha sonra devam '
              'edebilir veya bu oyunu tamamen silebilirsin.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                child: const Text('Devam Et'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'delete'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                ),
                child: const Text('Oyunu Sil'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, 'save'),
                child: const Text('Kaydet ve Çık'),
              ),
            ],
          );
        },
      );
    } finally {
      _exitDialogOpen = false;
    }

    if (!mounted || action == null || action == 'cancel') {
      return;
    }

    final completer = _moveCompleter;
    if (completer != null &&
        !completer.isCompleted &&
        _moveOptions.isNotEmpty) {
      completer.complete(_moveOptions.first);
    }

    if (action == 'delete') {
      await GameSaveService.clear();
    } else {
      await _saveGame();
    }

    if (!mounted) return;

    setState(() {
      _allowRoutePop = true;
    });

    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

enum SpecialCellEffect { rollAgain, randomJoker, chooseCategory, doubleChance }

extension SpecialCellEffectX on SpecialCellEffect {
  String get title {
    switch (this) {
      case SpecialCellEffect.rollAgain:
        return 'Tekrar Zar At';
      case SpecialCellEffect.randomJoker:
        return 'Joker Kazan';
      case SpecialCellEffect.chooseCategory:
        return 'Kategori Seç';
      case SpecialCellEffect.doubleChance:
        return 'Çifte Şans';
    }
  }

  String get emoji {
    switch (this) {
      case SpecialCellEffect.rollAgain:
        return '🎲';
      case SpecialCellEffect.randomJoker:
        return '🎁';
      case SpecialCellEffect.chooseCategory:
        return '🎯';
      case SpecialCellEffect.doubleChance:
        return '🍀';
    }
  }

  String get description {
    switch (this) {
      case SpecialCellEffect.rollAgain:
        return 'Bu kutuda soru açılmaz. Aynı oyuncu zarı yeniden atar.';
      case SpecialCellEffect.randomJoker:
        return 'Dört aktif jokerden biri rastgele seçilir ve +1 eklenir.';
      case SpecialCellEffect.chooseCategory:
        return 'Bu turda sorulacak kategoriyi sen seçersin.';
      case SpecialCellEffect.doubleChance:
        return 'Bir sonraki yanlış cevabında sıra sende kalır. '
            'Hak kullanılana kadar korunur.';
    }
  }

  Color get color {
    switch (this) {
      case SpecialCellEffect.rollAgain:
        return const Color(0xFF06B6D4);
      case SpecialCellEffect.randomJoker:
        return const Color(0xFFF59E0B);
      case SpecialCellEffect.chooseCategory:
        return const Color(0xFF8B5CF6);
      case SpecialCellEffect.doubleChance:
        return const Color(0xFF22C55E);
    }
  }
}

enum BoardNodeKind { center, spoke, outer }

class BoardNode {
  const BoardNode({
    required this.id,
    required this.kind,
    required this.categoryIndex,
    this.arm,
    this.step,
    this.ring,
    this.isBadge = false,
    this.specialEffect,
  });

  final int id;
  final BoardNodeKind kind;
  final int categoryIndex;
  final int? arm;
  final int? step;
  final int? ring;
  final bool isBadge;
  final SpecialCellEffect? specialEffect;
}

class MoveOption {
  const MoveOption(this.path);

  final List<int> path;
  int get destination => path.last;
}

class BoardMap {
  static const centerId = 0;
  static const outerCount = 36;
  static const spokeCount = 6;
  static const spokeLength = 5;
  static const outerStart = 1;
  static const spokeStart = 37;

  static const directions = [
    'Kuzey',
    'Kuzeydoğu',
    'Güneydoğu',
    'Güney',
    'Güneybatı',
    'Kuzeybatı',
  ];

  static const Map<int, SpecialCellEffect> specialCells = {
    4: SpecialCellEffect.rollAgain,
    22: SpecialCellEffect.rollAgain,
    9: SpecialCellEffect.randomJoker,
    27: SpecialCellEffect.randomJoker,
    14: SpecialCellEffect.chooseCategory,
    32: SpecialCellEffect.chooseCategory,
    18: SpecialCellEffect.doubleChance,
    36: SpecialCellEffect.doubleChance,
  };

  static const spokeMix = <List<int>>[
    [3, 1, 5, 2, 4],
    [4, 2, 0, 5, 3],
    [5, 3, 1, 0, 4],
    [0, 4, 2, 1, 5],
    [1, 5, 3, 2, 0],
    [2, 0, 4, 3, 1],
  ];

  static const outerMix = <List<int>>[
    [2, 5, 1, 4, 3],
    [3, 0, 4, 2, 5],
    [4, 1, 5, 3, 0],
    [5, 2, 0, 4, 1],
    [0, 3, 1, 5, 2],
    [1, 4, 2, 0, 3],
  ];

  static int outerId(int ring) {
    final value = (ring % outerCount + outerCount) % outerCount;
    return outerStart + value;
  }

  static int spokeId(int arm, int step) {
    return spokeStart + arm * spokeLength + step;
  }

  static BoardNode node(int id) {
    if (id == centerId) {
      return const BoardNode(
        id: centerId,
        kind: BoardNodeKind.center,
        categoryIndex: -1,
      );
    }

    if (id >= outerStart && id < outerStart + outerCount) {
      final ring = id - outerStart;
      final badge = ring % 6 == 0;

      return BoardNode(
        id: id,
        kind: BoardNodeKind.outer,
        categoryIndex: badge ? ring ~/ 6 : outerMix[ring ~/ 6][(ring % 6) - 1],
        ring: ring,
        isBadge: badge,
        specialEffect: specialCells[id],
      );
    }

    final offset = id - spokeStart;
    if (offset >= 0 && offset < spokeCount * spokeLength) {
      final arm = offset ~/ spokeLength;
      final step = offset % spokeLength;

      return BoardNode(
        id: id,
        kind: BoardNodeKind.spoke,
        categoryIndex: spokeMix[arm][step],
        arm: arm,
        step: step,
      );
    }

    throw RangeError('Geçersiz tahta alanı: $id');
  }

  static List<int> neighbors(int id) {
    final n = node(id);

    switch (n.kind) {
      case BoardNodeKind.center:
        return List.generate(spokeCount, (arm) => spokeId(arm, 0));

      case BoardNodeKind.spoke:
        final result = <int>[];
        result.add(n.step == 0 ? centerId : spokeId(n.arm!, n.step! - 1));
        result.add(
          n.step == spokeLength - 1
              ? outerId(n.arm! * 6)
              : spokeId(n.arm!, n.step! + 1),
        );
        return result;

      case BoardNodeKind.outer:
        final result = <int>[outerId(n.ring! - 1), outerId(n.ring! + 1)];

        if (n.ring! % 6 == 0) {
          result.add(spokeId(n.ring! ~/ 6, spokeLength - 1));
        }

        return result;
    }
  }

  static List<MoveOption> options(int start, int steps) {
    final found = <List<int>>[];

    void walk(int current, int left, List<int> path) {
      if (left == 0) {
        found.add(path);
        return;
      }

      for (final next in neighbors(current)) {
        if (path.contains(next)) continue;
        walk(next, left - 1, [...path, next]);
      }
    }

    walk(start, steps, [start]);

    final unique = <int, MoveOption>{};
    for (final path in found) {
      unique.putIfAbsent(path.last, () => MoveOption(path));
    }

    return unique.values.toList();
  }

  static List<int> continuePath({
    required int previous,
    required int current,
    required int steps,
  }) {
    final result = <int>[current];
    var last = previous;
    var cursor = current;

    for (var index = 0; index < steps; index++) {
      final next = _nextInDirection(previous: last, current: cursor);

      result.add(next);
      last = cursor;
      cursor = next;
    }

    return result;
  }

  static List<int> reversePath(MoveOption option, int steps) {
    final reversed = option.path.reversed.toList();
    final result = <int>[reversed.first];

    for (
      var index = 1;
      index < reversed.length && result.length < steps + 1;
      index++
    ) {
      result.add(reversed[index]);
    }

    if (result.length < steps + 1) {
      final previous =
          result.length >= 2 ? result[result.length - 2] : option.destination;
      final remaining = steps - (result.length - 1);
      final extension = continuePath(
        previous: previous,
        current: result.last,
        steps: remaining,
      );

      result.addAll(extension.skip(1));
    }

    return result;
  }

  static int _nextInDirection({required int previous, required int current}) {
    final previousNode = node(previous);
    final currentNode = node(current);

    if (currentNode.kind == BoardNodeKind.outer &&
        previousNode.kind == BoardNodeKind.outer) {
      final clockwise =
          (currentNode.ring! - previousNode.ring! + outerCount) % outerCount ==
          1;

      return outerId(currentNode.ring! + (clockwise ? 1 : -1));
    }

    if (currentNode.kind == BoardNodeKind.spoke &&
        previousNode.kind == BoardNodeKind.spoke &&
        currentNode.arm == previousNode.arm) {
      final movingOutward = currentNode.step! > previousNode.step!;

      if (movingOutward) {
        return currentNode.step == spokeLength - 1
            ? outerId(currentNode.arm! * 6)
            : spokeId(currentNode.arm!, currentNode.step! + 1);
      }

      return currentNode.step == 0
          ? centerId
          : spokeId(currentNode.arm!, currentNode.step! - 1);
    }

    if (currentNode.kind == BoardNodeKind.spoke &&
        previousNode.kind == BoardNodeKind.center) {
      return currentNode.step == spokeLength - 1
          ? outerId(currentNode.arm! * 6)
          : spokeId(currentNode.arm!, currentNode.step! + 1);
    }

    if (currentNode.kind == BoardNodeKind.spoke &&
        previousNode.kind == BoardNodeKind.outer) {
      return currentNode.step == 0
          ? centerId
          : spokeId(currentNode.arm!, currentNode.step! - 1);
    }

    if (currentNode.kind == BoardNodeKind.center &&
        previousNode.kind == BoardNodeKind.spoke) {
      return spokeId((previousNode.arm! + 3) % spokeCount, 0);
    }

    if (currentNode.kind == BoardNodeKind.outer &&
        previousNode.kind == BoardNodeKind.spoke) {
      return outerId(currentNode.ring! + 1);
    }

    final candidates =
        neighbors(current).where((candidate) => candidate != previous).toList();

    return candidates.isEmpty ? previous : candidates.first;
  }

  static String routeTitle(MoveOption option) {
    final start = node(option.path.first);
    final first = node(option.path[1]);

    if (start.kind == BoardNodeKind.center) {
      return '${directions[first.arm!]} yolunu seç';
    }

    if (start.kind == BoardNodeKind.outer &&
        first.kind == BoardNodeKind.outer) {
      final clockwise =
          (first.ring! - start.ring! + outerCount) % outerCount == 1;
      return clockwise ? 'Saat yönünde ilerle' : 'Saat yönünün tersine ilerle';
    }

    if (first.kind == BoardNodeKind.center) {
      return 'Merkeze gir';
    }

    if (start.kind == BoardNodeKind.outer &&
        first.kind == BoardNodeKind.spoke) {
      return 'Merkeze doğru ilerle';
    }

    if (start.kind == BoardNodeKind.spoke &&
        first.kind == BoardNodeKind.spoke) {
      return first.step! < start.step!
          ? 'Merkeze doğru ilerle'
          : 'Dış halkaya doğru ilerle';
    }

    return 'Dış halkaya çık';
  }

  static String label(int id) {
    final n = node(id);

    if (n.kind == BoardNodeKind.center) {
      return 'Merkez altıgen';
    }

    final category = GameCategory.values[n.categoryIndex];

    if (n.specialEffect != null) {
      return '${n.specialEffect!.title} özel alanı';
    }

    if (n.isBadge) {
      return '${category.label} rozet alanı';
    }

    if (n.kind == BoardNodeKind.spoke) {
      return '${directions[n.arm!]} bağlantısı • ${category.label}';
    }

    return 'Dış halka • ${category.label}';
  }

  static double base(Size size) {
    return min(size.width, size.height);
  }

  static Offset center(Size size) {
    return Offset(size.width / 2, size.height / 2);
  }

  static double armAngle(int arm) {
    return -pi / 2 + arm * (2 * pi / spokeCount);
  }

  static Offset position(Size size, int id) {
    final n = node(id);
    final c = center(size);
    final b = base(size);

    if (n.kind == BoardNodeKind.center) return c;

    if (n.kind == BoardNodeKind.outer) {
      final angle = -pi / 2 + n.ring! * (2 * pi / outerCount);
      return c + Offset(cos(angle), sin(angle)) * b * 0.42;
    }

    final angle = armAngle(n.arm!);
    final radius = b * (0.155 + n.step! * 0.049);
    return c + Offset(cos(angle), sin(angle)) * radius;
  }
}

class PawnDefinition {
  const PawnDefinition({
    required this.name,
    required this.assetPath,
    required this.fallbackSymbol,
  });

  final String name;
  final String assetPath;
  final String fallbackSymbol;
}

class PawnCatalog {
  static const List<PawnDefinition> all = [
    PawnDefinition(
      name: 'Renkli Halka',
      assetPath: 'assets/pawns/01_renkli_halka.png',
      fallbackSymbol: '◉',
    ),
    PawnDefinition(
      name: 'Bilgi Taşı',
      assetPath: 'assets/pawns/02_bilgi_tasi.png',
      fallbackSymbol: '💎',
    ),
    PawnDefinition(
      name: 'Beyin Maskotu',
      assetPath: 'assets/pawns/03_beyin_maskotu.png',
      fallbackSymbol: '🧠',
    ),
    PawnDefinition(
      name: 'Klasik Piyon',
      assetPath: 'assets/pawns/04_klasik_piyon.png',
      fallbackSymbol: '♟',
    ),
    PawnDefinition(
      name: 'Bilge At',
      assetPath: 'assets/pawns/05_bilge_at.png',
      fallbackSymbol: '♞',
    ),
    PawnDefinition(
      name: 'Kristal Zar',
      assetPath: 'assets/pawns/06_kristal_zar.png',
      fallbackSymbol: '🎲',
    ),
    PawnDefinition(
      name: 'Pusula Yıldızı',
      assetPath: 'assets/pawns/07_pusula_yildizi.png',
      fallbackSymbol: '🧭',
    ),
    PawnDefinition(
      name: 'Açık Kitap',
      assetPath: 'assets/pawns/08_acik_kitap.png',
      fallbackSymbol: '📖',
    ),
    PawnDefinition(
      name: 'Ampul Fikri',
      assetPath: 'assets/pawns/09_ampul_fikri.png',
      fallbackSymbol: '💡',
    ),
    PawnDefinition(
      name: 'Kum Saati',
      assetPath: 'assets/pawns/10_kum_saati.png',
      fallbackSymbol: '⏳',
    ),
    PawnDefinition(
      name: 'Soru İşareti',
      assetPath: 'assets/pawns/11_soru_isareti.png',
      fallbackSymbol: '?',
    ),
    PawnDefinition(
      name: 'Kupa Rozet',
      assetPath: 'assets/pawns/12_kupa_rozet.png',
      fallbackSymbol: '🏆',
    ),
    PawnDefinition(
      name: 'Minik Galaksi Bilgesi',
      assetPath: 'assets/pawns/13_minik_galaksi_bilgesi.png',
      fallbackSymbol: '🌌',
    ),
    PawnDefinition(
      name: 'Fidan Muhafızı',
      assetPath: 'assets/pawns/14_fidan_muhafizi.png',
      fallbackSymbol: '🌱',
    ),
    PawnDefinition(
      name: 'Özgür Ev Cini',
      assetPath: 'assets/pawns/15_ozgur_ev_cini.png',
      fallbackSymbol: '🧦',
    ),
    PawnDefinition(
      name: 'Mağara Sinsiği',
      assetPath: 'assets/pawns/16_magara_sinsigi.png',
      fallbackSymbol: '💍',
    ),
    PawnDefinition(
      name: 'Kara Kedi',
      assetPath: 'assets/pawns/17_kara_kedi.png',
      fallbackSymbol: '🐈‍⬛',
    ),
  ];

  static PawnDefinition at(int index) {
    final normalized = (index % all.length + all.length) % all.length;
    return all[normalized];
  }
}

class PawnToken extends StatelessWidget {
  const PawnToken({
    required this.type,
    required this.color,
    required this.active,
    required this.width,
    required this.height,
    super.key,
  });

  final int type;
  final Color color;
  final bool active;
  final double width;
  final double height;

  Widget _buildPremiumSpecialPawn(PawnDefinition pawn) {
    return SizedBox(
      width: width,
      height: height,
      child: RepaintBoundary(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (active)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.62),
                        blurRadius: width * 0.46,
                        spreadRadius: width * 0.04,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, -height * 0.01),
                child: Transform.scale(
                  scale: active ? 1.16 : 1.08,
                  alignment: Alignment.center,
                  child: Image.asset(
                    pawn.assetPath,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          pawn.fallbackSymbol,
                          style: TextStyle(
                            fontSize: width * 0.70,
                            height: 1,
                            shadows: const [
                              Shadow(color: Colors.white, blurRadius: 5),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (active)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: max(9.0, width * 0.20),
                  height: max(9.0, width * 0.20),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.95),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (type == 0) {
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: RainbowRingPawnPainter(playerColor: color, active: active),
        ),
      );
    }

    final pawn = PawnCatalog.at(type);

    if (type >= 12) {
      return _buildPremiumSpecialPawn(pawn);
    }

    return SizedBox(
      width: width,
      height: height,
      child: RepaintBoundary(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: height * 0.08,
              child: Container(
                width: width * 0.92,
                height: width * 0.92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xEE26364A),
                      Color(0xDD160C20),
                      Color(0x99100818),
                    ],
                    stops: [0, 0.68, 1],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFD76A),
                    width: active ? 2.3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(active ? 0.72 : 0.42),
                      blurRadius: active ? width * 0.54 : width * 0.34,
                      spreadRadius: active ? width * 0.10 : width * 0.04,
                    ),
                    const BoxShadow(
                      color: Color(0xAA000000),
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, -height * 0.08),
                child: Transform.scale(
                  scale: active ? 1.34 : 1.24,
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    pawn.assetPath,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          pawn.fallbackSymbol,
                          style: TextStyle(
                            fontSize: width * 0.70,
                            height: 1,
                            shadows: const [
                              Shadow(color: Colors.white, blurRadius: 5),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: width * 0.78,
                height: max(4.0, height * 0.085),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(color, Colors.white, 0.55)!,
                      color,
                      Color.lerp(color, Colors.black, 0.35)!,
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFE082),
                    width: active ? 2.1 : 1.4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xCC000000),
                      offset: Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            if (active)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: max(9.0, width * 0.20),
                  height: max(9.0, width * 0.20),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.95),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RainbowRingPawnPainter extends CustomPainter {
  const RainbowRingPawnPainter({
    required this.playerColor,
    required this.active,
  });

  final Color playerColor;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final center = Offset(size.width / 2, size.height * 0.39);
    final radius = size.width * 0.31;
    final ringWidth = size.width * 0.18;

    if (active) {
      canvas.drawCircle(
        center,
        radius * 1.42,
        Paint()
          ..color = playerColor.withOpacity(0.48)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    final baseShadow = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.91),
      width: size.width * 0.88,
      height: size.height * 0.16,
    );
    canvas.drawOval(
      baseShadow.translate(0, 3),
      Paint()
        ..color = const Color(0xAA000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final baseRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.87),
      width: size.width * 0.86,
      height: size.height * 0.19,
    );
    canvas.drawOval(
      baseRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF0A6), Color(0xFFFFC83D), Color(0xFF9A5A08)],
        ).createShader(baseRect),
    );
    canvas.drawOval(
      baseRect.deflate(size.width * 0.03),
      Paint()..color = const Color(0xFF401F58),
    );

    canvas.drawCircle(
      center.translate(0, size.height * 0.018),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth + size.width * 0.035
        ..color = const Color(0xFF5A2B15),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFFF3D8D),
            Color(0xFFFF8A27),
            Color(0xFFFFEA43),
            Color(0xFF32D36B),
            Color(0xFF16BCE8),
            Color(0xFF5F46F2),
            Color(0xFFFF3D8D),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawCircle(
      center,
      radius + ringWidth / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = active ? 2.4 : 1.5
        ..color = const Color(0xFFFFF1A8),
    );
    canvas.drawCircle(
      center,
      radius - ringWidth / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xAAFFFFFF),
    );

    final highlightRect = Rect.fromCircle(
      center: center.translate(-size.width * 0.02, -size.height * 0.015),
      radius: radius,
    );
    canvas.drawArc(
      highlightRect,
      -2.75,
      1.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.035
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xCCFFFFFF),
    );

    canvas.drawCircle(
      Offset(size.width * 0.67, size.height * 0.18),
      size.width * 0.055,
      Paint()..color = const Color(0xE6FFFFFF),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.98),
          width: size.width * 0.72,
          height: max(4.0, size.height * 0.075),
        ),
        const Radius.circular(999),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(playerColor, Colors.white, 0.55)!,
            playerColor,
            Color.lerp(playerColor, Colors.black, 0.35)!,
          ],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(covariant RainbowRingPawnPainter oldDelegate) {
    return oldDelegate.playerColor != playerColor ||
        oldDelegate.active != active;
  }
}

class RouteHighlightPainter extends CustomPainter {
  const RouteHighlightPainter({required this.options});

  final List<MoveOption> options;

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final glowPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = BoardMap.base(size) * 0.030
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0x667DE3FF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final routePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = BoardMap.base(size) * 0.012
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFE082), Color(0xFF67E8F9), Color(0xFFFFFFFF)],
          ).createShader(Offset.zero & size);

    for (final option in options) {
      if (option.path.length < 2) continue;

      final route = Path();
      final first = BoardMap.position(size, option.path.first);
      route.moveTo(first.dx, first.dy);

      for (final nodeId in option.path.skip(1)) {
        final point = BoardMap.position(size, nodeId);
        route.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(route, glowPaint);
      canvas.drawPath(route, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RouteHighlightPainter oldDelegate) {
    return oldDelegate.options != options;
  }
}

class RouteTargetPulse extends StatefulWidget {
  const RouteTargetPulse({
    required this.color,
    required this.emoji,
    required this.onTap,
    required this.size,
    super.key,
  });

  final Color color;
  final String emoji;
  final VoidCallback onTap;
  final double size;

  @override
  State<RouteTargetPulse> createState() => _RouteTargetPulseState();
}

class _RouteTargetPulseState extends State<RouteTargetPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 0.88,
      end: 1.13,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white,
                Color.lerp(widget.color, Colors.white, 0.20)!,
                widget.color,
              ],
              stops: const [0, 0.50, 1],
            ),
            border: Border.all(color: const Color(0xFFFFE082), width: 3),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.80),
                blurRadius: 14,
                spreadRadius: 4,
              ),
              const BoxShadow(
                color: Color(0xAAFFFFFF),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            widget.emoji,
            style: TextStyle(fontSize: widget.size * 0.42, height: 1),
          ),
        ),
      ),
    );
  }
}

class JumpingPawn extends StatefulWidget {
  const JumpingPawn({
    required this.type,
    required this.color,
    required this.active,
    required this.width,
    required this.height,
    required this.movePulse,
    super.key,
  });

  final int type;
  final Color color;
  final bool active;
  final double width;
  final double height;
  final int movePulse;

  @override
  State<JumpingPawn> createState() => _JumpingPawnState();
}

class _JumpingPawnState extends State<JumpingPawn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 390),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant JumpingPawn oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.movePulse != widget.movePulse) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final arc = sin(pi * t);
          final landingT = t < 0.76 ? 0.0 : (t - 0.76) / 0.24;
          final landingBounce = sin(pi * landingT.clamp(0.0, 1.0));

          final lift = arc * widget.height * 0.40;
          final scaleX = 1 - arc * 0.045 + landingBounce * 0.13;
          final scaleY = 1 + arc * 0.055 - landingBounce * 0.11;
          final shadowScale = 1 - arc * 0.42;
          final shadowOpacity = 0.46 - arc * 0.23;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: PawnStepTrailPainter(
                      progress: t,
                      pawnType: widget.type,
                      playerColor: widget.color,
                      pulse: widget.movePulse,
                      minimal: PawnVisualEffects.minimalAnimations,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: widget.height * 0.015,
                child: Opacity(
                  opacity: shadowOpacity,
                  child: Transform.scale(
                    scaleX: shadowScale,
                    scaleY: 0.72,
                    child: Container(
                      width: widget.width * 0.78,
                      height: widget.height * 0.16,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x99000000),
                            blurRadius: 7,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -lift),
                child: Transform.scale(
                  scaleX: scaleX,
                  scaleY: scaleY,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            ],
          );
        },
        child: PawnToken(
          type: widget.type,
          color: widget.color,
          active: widget.active,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}

class LandingBurst extends StatefulWidget {
  const LandingBurst({
    required this.color,
    required this.size,
    required this.pawnType,
    required this.playerColor,
    super.key,
  });

  final Color color;
  final double size;
  final int pawnType;
  final Color playerColor;

  @override
  State<LandingBurst> createState() => _LandingBurstState();
}

class _LandingBurstState extends State<LandingBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: LandingBurstPainter(
                    progress: _controller.value,
                    color: widget.color,
                  ),
                ),
                CustomPaint(
                  painter: PawnLandingSignaturePainter(
                    progress: _controller.value,
                    pawnType: widget.pawnType,
                    playerColor: widget.playerColor,
                    minimal: PawnVisualEffects.minimalAnimations,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LandingBurstPainter extends CustomPainter {
  const LandingBurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fade = (1 - progress).clamp(0.0, 1.0);
    final radius = size.width * (0.15 + progress * 0.34);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, size.width * 0.055 * fade)
        ..color = color.withOpacity(0.78 * fade),
    );

    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, size.width * 0.025 * fade)
        ..color = const Color(0xFFFFE082).withOpacity(0.95 * fade),
    );

    for (var index = 0; index < 10; index++) {
      final angle = index * (2 * pi / 10);
      final startDistance = size.width * 0.16;
      final endDistance = size.width * (0.20 + progress * 0.31);
      final start = center + Offset(cos(angle), sin(angle)) * startDistance;
      final end = center + Offset(cos(angle), sin(angle)) * endDistance;

      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = max(1.0, size.width * 0.032 * fade)
          ..color =
              index.isEven
                  ? color.withOpacity(0.88 * fade)
                  : const Color(0xFFFFF3B0).withOpacity(0.95 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LandingBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.players,
    required this.currentPlayerIndex,
    this.moveOptions = const <MoveOption>[],
    this.onMoveSelected,
    this.activeMove,
    this.routeOpacity = 0,
    this.landingNodeId,
    this.landingPulse = 0,
    super.key,
  });

  final List<PlayerData> players;
  final int currentPlayerIndex;
  final List<MoveOption> moveOptions;
  final ValueChanged<MoveOption>? onMoveSelected;
  final MoveOption? activeMove;
  final double routeOpacity;
  final int? landingNodeId;
  final int landingPulse;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final base = BoardMap.base(size);
          final boardCenter = BoardMap.center(size);
          final landingPoint =
              landingNodeId == null
                  ? null
                  : BoardMap.position(size, landingNodeId!);
          final landingNode =
              landingNodeId == null ? null : BoardMap.node(landingNodeId!);
          final landingColor =
              landingNode == null || landingNode.categoryIndex < 0
                  ? const Color(0xFF67E8F9)
                  : GameCategory.values[landingNode.categoryIndex].color;
          final landingSize = base * 0.17;
          final safeCurrentPlayerIndex =
              players.isEmpty
                  ? 0
                  : currentPlayerIndex.clamp(0, players.length - 1).toInt();
          final landingPawnType =
              players.isEmpty ? 0 : players[safeCurrentPlayerIndex].pawnType;
          final landingPlayerColor =
              players.isEmpty
                  ? const Color(0xFF67E8F9)
                  : players[safeCurrentPlayerIndex].color;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(child: LiveBoardLayer()),
              if (moveOptions.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: RouteHighlightPainter(options: moveOptions),
                    ),
                  ),
                ),
              if (activeMove != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.easeOut,
                      opacity: routeOpacity,
                      child: CustomPaint(
                        painter: RouteHighlightPainter(
                          options: <MoveOption>[activeMove!],
                        ),
                      ),
                    ),
                  ),
                ),
              ...List.generate(players.length, (index) {
                final player = players[index];
                var point = BoardMap.position(size, player.position);
                final active = index == currentPlayerIndex;

                final sameCellIndexes = <int>[
                  for (
                    var otherIndex = 0;
                    otherIndex < players.length;
                    otherIndex++
                  )
                    if (players[otherIndex].position == player.position)
                      otherIndex,
                ];
                final stackSlot = sameCellIndexes.indexOf(index);

                if (player.position == BoardMap.centerId) {
                  final divisor = players.isEmpty ? 1 : players.length;
                  final angle = -pi / 2 + index * (2 * pi / divisor.toDouble());
                  point =
                      boardCenter +
                      Offset(cos(angle), sin(angle)) * base * 0.084;
                } else if (sameCellIndexes.length > 1) {
                  final radialAngle = atan2(
                    point.dy - boardCenter.dy,
                    point.dx - boardCenter.dx,
                  );
                  final tangent = Offset(-sin(radialAngle), cos(radialAngle));
                  final centeredSlot =
                      stackSlot - (sameCellIndexes.length - 1) / 2;
                  point += tangent * centeredSlot * base * 0.052;
                }

                final pawnWidth = active ? base * 0.082 : base * 0.072;
                final pawnHeight = active ? base * 0.112 : base * 0.098;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 430),
                  curve: Curves.easeOutBack,
                  left: point.dx - pawnWidth / 2,
                  top: point.dy - pawnHeight * 0.80,
                  child: JumpingPawn(
                    key: ValueKey<String>('pawn-$index'),
                    type: player.pawnType,
                    color: player.color,
                    active: active,
                    width: pawnWidth,
                    height: pawnHeight,
                    movePulse: player.movePulse,
                  ),
                );
              }),
              if (landingPoint != null)
                Positioned(
                  left: landingPoint.dx - landingSize / 2,
                  top: landingPoint.dy - landingSize / 2,
                  child: LandingBurst(
                    key: ValueKey<int>(landingPulse),
                    color: landingColor,
                    size: landingSize,
                    pawnType: landingPawnType,
                    playerColor: landingPlayerColor,
                  ),
                ),
              ...moveOptions.map((option) {
                final destination = BoardMap.node(option.destination);
                final point = BoardMap.position(size, option.destination);
                final targetColor = BoardTargetPresentation.colorFor(
                  destination,
                );
                final targetEmoji = BoardTargetPresentation.emojiFor(
                  destination,
                );
                final targetSize =
                    destination.isBadge ? base * 0.088 : base * 0.074;

                return Positioned(
                  left: point.dx - targetSize / 2,
                  top: point.dy - targetSize / 2,
                  child: Semantics(
                    button: true,
                    label: BoardTargetPresentation.semanticsLabelFor(option),
                    child: RouteTargetPulse(
                      key: ValueKey<int>(option.destination),
                      color: targetColor,
                      emoji: targetEmoji,
                      size: targetSize,
                      onTap: () => onMoveSelected?.call(option),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  const BoardPainter({this.pulse = 0, this.themeOverride});

  final double pulse;
  final BoardThemeDefinition? themeOverride;

  BoardThemeDefinition get _theme =>
      themeOverride ?? VisualCollectionService.theme;

  Color get _gold => _theme.gold;
  Color get _darkGold => _theme.darkGold;
  Color get _deepPurple => _theme.backgroundColors.last;

  @override
  void paint(Canvas canvas, Size size) {
    final base = BoardMap.base(size);
    final center = BoardMap.center(size);

    final boardRect = Rect.fromCenter(
      center: center,
      width: base * 0.98,
      height: base * 0.98,
    );
    final boardShape = RRect.fromRectAndRadius(
      boardRect,
      Radius.circular(base * 0.042),
    );

    canvas.drawShadow(
      Path()..addRRect(boardShape),
      const Color(0xAA000000),
      15,
      true,
    );

    if (pulse > 0) {
      canvas.drawRRect(
        boardShape.inflate(2 + pulse * 3),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 + pulse * 2
          ..color = _gold.withOpacity(0.10 + pulse * 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }

    canvas.drawRRect(
      boardShape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _theme.backgroundColors,
        ).createShader(boardRect),
    );

    BoardThemeArt.paintSurface(canvas, size, boardRect, base, _theme, pulse);

    canvas.drawRRect(
      boardShape.deflate(base * 0.012),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = _gold,
    );
    canvas.drawRRect(
      boardShape.deflate(base * 0.024),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0x99FBE7A2),
    );

    _drawDecorativeWedges(canvas, center, base);
    _drawFoundations(canvas, center, base);
    _drawSpokeTiles(canvas, size, base);
    _drawOuterTiles(canvas, size, base);
    _drawSpecialCellOverlays(canvas, size, base);
    _drawCenterHex(canvas, center, base);
  }

  void _drawDecorativeWedges(Canvas canvas, Offset center, double base) {
    for (var arm = 0; arm < 6; arm++) {
      final angle = BoardMap.armAngle(arm);
      final left = angle - pi / 6;
      final right = angle + pi / 6;
      final path =
          Path()
            ..moveTo(
              center.dx + cos(left) * base * 0.14,
              center.dy + sin(left) * base * 0.14,
            )
            ..lineTo(
              center.dx + cos(left) * base * 0.375,
              center.dy + sin(left) * base * 0.375,
            )
            ..arcTo(
              Rect.fromCircle(center: center, radius: base * 0.375),
              left,
              pi / 3,
              false,
            )
            ..lineTo(
              center.dx + cos(right) * base * 0.14,
              center.dy + sin(right) * base * 0.14,
            )
            ..close();

      canvas.drawPath(
        path,
        Paint()
          ..color =
              arm.isEven ? const Color(0x18000000) : const Color(0x0EFFFFFF),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = const Color(0x33E8C76A),
      );
    }
  }

  void _drawFoundations(Canvas canvas, Offset center, double base) {
    canvas.drawCircle(
      center.translate(0, base * 0.013),
      base * 0.420,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.086
        ..color = const Color(0x99000000),
    );
    canvas.drawCircle(
      center,
      base * 0.420,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.084
        ..color = _darkGold,
    );
    canvas.drawCircle(
      center,
      base * 0.420,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = base * 0.071
        ..color = _theme.foundation,
    );

    for (var arm = 0; arm < 6; arm++) {
      final direction = Offset(
        cos(BoardMap.armAngle(arm)),
        sin(BoardMap.armAngle(arm)),
      );
      final start = center + direction * base * 0.125;
      final end = center + direction * base * 0.368;

      canvas.drawLine(
        start.translate(0, base * 0.012),
        end.translate(0, base * 0.012),
        Paint()
          ..strokeWidth = base * 0.123
          ..strokeCap = StrokeCap.butt
          ..color = const Color(0x88000000),
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = base * 0.121
          ..strokeCap = StrokeCap.butt
          ..color = _darkGold,
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = base * 0.106
          ..strokeCap = StrokeCap.butt
          ..color = _deepPurple,
      );
    }
  }

  void _drawSpokeTiles(Canvas canvas, Size size, double base) {
    for (var arm = 0; arm < 6; arm++) {
      final angle = BoardMap.armAngle(arm);
      for (var step = 0; step < 5; step++) {
        final id = BoardMap.spokeId(arm, step);
        final node = BoardMap.node(id);
        _drawRaisedTile(
          canvas: canvas,
          center: BoardMap.position(size, id),
          angle: angle,
          width: base * 0.102,
          height: base * 0.045,
          category: GameCategory.values[node.categoryIndex],
          base: base,
          iconSize: base * 0.018,
        );
      }
    }
  }

  void _drawOuterTiles(Canvas canvas, Size size, double base) {
    for (var ring = 0; ring < 36; ring++) {
      final id = BoardMap.outerId(ring);
      final node = BoardMap.node(id);
      final angle = -pi / 2 + ring * (2 * pi / 36);
      final category = GameCategory.values[node.categoryIndex];

      if (node.isBadge) {
        _drawBadgeMedallion(
          canvas,
          BoardMap.position(size, id),
          category,
          base,
        );
      } else {
        _drawRaisedTile(
          canvas: canvas,
          center: BoardMap.position(size, id),
          angle: angle,
          width: base * 0.071,
          height: base * 0.052,
          category: category,
          base: base,
          iconSize: base * 0.015,
        );
      }
    }
  }

  void _drawSpecialCellOverlays(Canvas canvas, Size size, double base) {
    for (final entry in BoardMap.specialCells.entries) {
      final id = entry.key;
      final effect = entry.value;
      final node = BoardMap.node(id);

      if (node.kind != BoardNodeKind.outer || node.ring == null) {
        continue;
      }

      final center = BoardMap.position(size, id);
      final angle = -pi / 2 + node.ring! * (2 * pi / BoardMap.outerCount);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + pi / 2);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: base * 0.071,
        height: base * 0.052,
      );
      final shape = RRect.fromRectAndRadius(
        rect,
        Radius.circular(base * 0.007),
      );

      canvas.drawRRect(
        shape.inflate(base * 0.009),
        Paint()
          ..color = effect.color.withOpacity(0.58)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );

      canvas.drawRRect(
        shape.inflate(base * 0.004),
        Paint()..color = const Color(0xFFFFE082),
      );

      canvas.drawRRect(
        shape,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(effect.color, Colors.white, 0.48)!,
              effect.color,
              Color.lerp(effect.color, Colors.black, 0.42)!,
            ],
          ).createShader(rect),
      );

      canvas.drawRRect(
        shape.deflate(base * 0.002),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = const Color(0xEEFFFFFF),
      );

      _drawText(
        canvas,
        effect.emoji,
        Offset.zero,
        base * 0.019,
        Colors.white,
        bold: true,
      );

      canvas.restore();
    }
  }

  void _drawRaisedTile({
    required Canvas canvas,
    required Offset center,
    required double angle,
    required double width,
    required double height,
    required GameCategory category,
    required double base,
    required double iconSize,
  }) {
    final depth = base * 0.010;

    void drawAt(Offset tileCenter, bool top) {
      canvas.save();
      canvas.translate(tileCenter.dx, tileCenter.dy);
      canvas.rotate(angle + pi / 2);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: width,
        height: height,
      );
      final shape = RRect.fromRectAndRadius(
        rect,
        Radius.circular(base * 0.006),
      );

      if (!top) {
        canvas.drawRRect(
          shape.inflate(base * 0.004),
          Paint()..color = _darkGold,
        );
        canvas.drawRRect(
          shape,
          Paint()..color = Color.lerp(category.color, Colors.black, 0.52)!,
        );
      } else {
        canvas.drawRRect(shape.inflate(base * 0.003), Paint()..color = _gold);
        canvas.drawRRect(
          shape,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(category.color, Colors.white, 0.48)!,
                category.color,
                Color.lerp(category.color, Colors.black, 0.25)!,
              ],
              stops: const [0, 0.58, 1],
            ).createShader(rect),
        );
        canvas.drawLine(
          Offset(rect.left + base * 0.007, rect.top + base * 0.005),
          Offset(rect.right - base * 0.007, rect.top + base * 0.005),
          Paint()
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xAAFFFFFF),
        );
        _drawText(canvas, category.emoji, Offset.zero, iconSize, Colors.white);
      }

      canvas.restore();
    }

    drawAt(center.translate(0, depth), false);
    drawAt(center, true);
  }

  void _drawBadgeMedallion(
    Canvas canvas,
    Offset center,
    GameCategory category,
    double base,
  ) {
    final radius = base * 0.043;
    final depth = base * 0.012;

    canvas.drawCircle(
      center.translate(0, depth + base * 0.004),
      radius * 1.12,
      Paint()
        ..color = const Color(0x77000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      center.translate(0, depth),
      radius * 1.07,
      Paint()..color = _darkGold,
    );
    canvas.drawCircle(center, radius * 1.08, Paint()..color = _gold);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.42),
          colors: [
            Color.lerp(category.color, Colors.white, 0.50)!,
            category.color,
            Color.lerp(category.color, Colors.black, 0.30)!,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xCCFFFFFF),
    );
    _drawText(canvas, category.emoji, center, base * 0.027, Colors.white);
  }

  void _drawCenterHex(Canvas canvas, Offset center, double base) {
    final radius = base * 0.124;
    final depth = base * 0.015;

    Path makeHex(Offset c) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final angle = -pi / 2 + i * (2 * pi / 6);
        final point = c + Offset(cos(angle), sin(angle)) * radius;
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path..close();
    }

    final lower = makeHex(center.translate(0, depth));
    final upper = makeHex(center);

    canvas.drawShadow(lower, const Color(0xAA000000), 9, true);
    canvas.drawPath(lower, Paint()..color = _darkGold);
    canvas.drawPath(
      upper,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.38),
          colors: _theme.centerColors,
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawPath(
      upper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = _gold,
    );

    _drawText(
      canvas,
      BoardThemeArt.centerEmoji(_theme.id),
      center.translate(0, -base * 0.025),
      base * 0.030,
      Colors.white,
    );
    _drawText(
      canvas,
      'BİLGİ\nROTASI',
      center.translate(0, base * 0.030),
      base * 0.020,
      Colors.white,
      bold: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color, {
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          height: 1,
          color: color,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          shadows: const [
            Shadow(
              offset: Offset(0, 1.5),
              blurRadius: 2,
              color: Color(0x88000000),
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate._theme.id != _theme.id;
  }
}

class DiceFace extends StatelessWidget {
  const DiceFace({required this.value, super.key});

  final int? value;

  static const Map<int, String> _faces = {
    1: '⚀',
    2: '⚁',
    3: '⚂',
    4: '⚃',
    5: '⚄',
    6: '⚅',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 130),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween<double>(begin: 0, end: 0.25).animate(animation),
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Text(
          value == null ? '🎲' : _faces[value]!,
          key: ValueKey<int?>(value),
          style: const TextStyle(fontSize: 33, height: 1),
        ),
      ),
    );
  }
}

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({
    required this.question,
    this.isBadgeQuestion = false,
    this.isFinalQuestion = false,
    this.jokers,
    this.onChangeQuestion,
    this.riskMode = false,
    this.xpMultiplier = 1,
    super.key,
  });

  final QuizQuestion question;
  final bool isBadgeQuestion;
  final bool isFinalQuestion;
  final JokerWallet? jokers;
  final Future<QuizQuestion?> Function(QuizQuestion current)? onChangeQuestion;
  final bool riskMode;
  final int xpMultiplier;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  static const List<String> _errorReasons = [
    'Doğru cevap yanlış',
    'Soru veya seçenekler belirsiz',
    'Yazım hatası var',
    'Bilgi eskimiş',
    'Aynı soru tekrar ediyor',
    'Diğer',
  ];

  int? _selectedIndex;
  String? _difficultyVote;
  bool _errorReported = false;
  bool _feedbackLoading = false;
  late QuizQuestion _question;
  final Set<int> _hiddenOptions = <int>{};
  final Set<int> _disabledOptions = <int>{};
  bool _secondChanceArmed = false;
  bool _secondChanceUsed = false;
  bool _jokerBusy = false;

  bool get _answered => _selectedIndex != null;
  bool get _correct => _selectedIndex == _question.answerIndex;

  String get _gameMode {
    if (widget.riskMode) return 'Riskli soru';
    if (widget.isFinalQuestion) return 'Final sorusu';
    if (widget.isBadgeQuestion) return 'Rozet sorusu';
    return 'Normal soru';
  }

  @override
  void initState() {
    super.initState();
    _question = widget.question;
    unawaited(_loadFeedbackState());
    unawaited(QuestionFeedbackService.flushPending());
  }

  Future<void> _loadFeedbackState() async {
    final vote = await QuestionFeedbackService.difficultyVoteFor(_question.id);
    final reported = await QuestionFeedbackService.hasErrorReport(_question.id);

    if (!mounted) return;

    setState(() {
      _difficultyVote = vote;
      _errorReported = reported;
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = GameCategory.values[_question.categoryIndex];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color.alphaBlend(
          category.color.withOpacity(0.10),
          Colors.white,
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.alphaBlend(
            category.color.withOpacity(0.10),
            Colors.white,
          ),
          foregroundColor: category.darkColor,
          surfaceTintColor: Colors.transparent,
          title: Text(
            widget.isFinalQuestion
                ? '🏆 Final Sorusu'
                : widget.isBadgeQuestion
                ? '⭐ ${category.label} Rozet Sorusu'
                : '${category.emoji} ${category.label}',
          ),
        ),
        bottomNavigationBar:
            !_answered
                ? null
                : SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: category.color.withValues(alpha: 0.24),
                        ),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 14,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, _correct),
                      style: FilledButton.styleFrom(
                        backgroundColor: category.darkColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text(
                        'Devam Et',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: category.color.withOpacity(0.28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _question.difficulty,
                              style: TextStyle(
                                color: category.darkColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            category.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _question.text,
                        style: const TextStyle(
                          fontSize: 23,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const LiveStreakPill(),
                if (widget.riskMode) ...[
                  const SizedBox(height: 10),
                  RiskQuestionBanner(multiplier: widget.xpMultiplier),
                ],
                if (!_answered &&
                    !widget.isFinalQuestion &&
                    GameplayBoostSettingsService.current.jokersEnabled &&
                    widget.jokers != null) ...[
                  const SizedBox(height: 10),
                  _buildJokerPanel(category),
                ],
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _question.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildOption(index, category);
                  },
                ),
                if (_answered) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          _correct
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _correct
                          ? 'Doğru! ${_question.explanation}'
                          : 'Yanlış. Doğru cevap: '
                              '${_question.options[_question.answerIndex]}. '
                              '${_question.explanation}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildFeedbackPanel(category),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJokerPanel(GameCategory category) {
    final wallet = widget.jokers!;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: category.color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jokerler • Her biri oyun başına 1 adet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              JokerActionButton(
                emoji: '✂️',
                label: '50:50',
                count: wallet.fiftyFifty,
                onPressed:
                    _jokerBusy || wallet.fiftyFifty <= 0
                        ? null
                        : _useFiftyFifty,
              ),
              const SizedBox(width: 6),
              JokerActionButton(
                emoji: '🔄',
                label: 'Değiştir',
                count: wallet.changeQuestion,
                onPressed:
                    _jokerBusy ||
                            wallet.changeQuestion <= 0 ||
                            widget.onChangeQuestion == null
                        ? null
                        : _changeQuestion,
              ),
              const SizedBox(width: 6),
              JokerActionButton(
                emoji: '🍀',
                label: '2. Şans',
                count: wallet.secondChance,
                active: _secondChanceArmed,
                onPressed:
                    _jokerBusy ||
                            wallet.secondChance <= 0 ||
                            _secondChanceArmed ||
                            _secondChanceUsed
                        ? null
                        : _armSecondChance,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _useFiftyFifty() {
    final wallet = widget.jokers;
    if (wallet == null || !wallet.consume(JokerKind.fiftyFifty)) {
      return;
    }
    unawaited(
      AnalyticsTelemetry.jokerUsed(
        gameMode: _gameMode,
        category: GameCategory.values[_question.categoryIndex].label,
      ),
    );

    final wrongOptions = <int>[
      for (var index = 0; index < _question.options.length; index++)
        if (index != _question.answerIndex) index,
    ]..shuffle(Random());

    setState(() {
      _hiddenOptions.addAll(wrongOptions.take(2));
    });

    GameHaptics.mediumImpact();
    _showMessage('✂️ İki yanlış seçenek elendi.');
  }

  void _armSecondChance() {
    final wallet = widget.jokers;
    if (wallet == null || !wallet.consume(JokerKind.secondChance)) {
      return;
    }
    unawaited(
      AnalyticsTelemetry.jokerUsed(
        gameMode: _gameMode,
        category: GameCategory.values[_question.categoryIndex].label,
      ),
    );

    setState(() {
      _secondChanceArmed = true;
    });

    GameHaptics.mediumImpact();
    _showMessage('🍀 İlk cevabın yanlış olursa bir kez daha deneyebilirsin.');
  }

  Future<void> _changeQuestion() async {
    final wallet = widget.jokers;
    final callback = widget.onChangeQuestion;

    if (wallet == null ||
        callback == null ||
        wallet.changeQuestion <= 0 ||
        _jokerBusy) {
      return;
    }

    setState(() => _jokerBusy = true);

    final replacement = await callback(_question);

    if (!mounted) return;

    if (replacement == null) {
      setState(() => _jokerBusy = false);
      _showMessage('Bu kategoride kullanılabilir başka soru kalmadı.');
      return;
    }

    wallet.consume(JokerKind.changeQuestion);
    unawaited(
      AnalyticsTelemetry.jokerUsed(
        gameMode: _gameMode,
        category: GameCategory.values[_question.categoryIndex].label,
      ),
    );

    setState(() {
      _question = replacement;
      _selectedIndex = null;
      _difficultyVote = null;
      _errorReported = false;
      _hiddenOptions.clear();
      _disabledOptions.clear();
      _secondChanceArmed = false;
      _secondChanceUsed = false;
      _jokerBusy = false;
    });

    await _loadFeedbackState();

    if (!mounted) return;

    GameHaptics.mediumImpact();
    _showMessage('🔄 Soru değiştirildi.');
  }

  void _selectOption(int index) {
    if (_answered ||
        _hiddenOptions.contains(index) ||
        _disabledOptions.contains(index)) {
      return;
    }

    GameHaptics.selectionClick();

    if (_secondChanceArmed &&
        !_secondChanceUsed &&
        index != _question.answerIndex) {
      setState(() {
        _secondChanceArmed = false;
        _secondChanceUsed = true;
        _disabledOptions.add(index);
      });

      GameHaptics.heavyImpact();
      _showMessage('🍀 İlk cevap yanlış. İkinci şansını kullan!');
      return;
    }

    setState(() => _selectedIndex = index);
  }

  Widget _buildFeedbackPanel(GameCategory category) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bu soru nasıldı? • İsteğe bağlı',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _feedbackButton(
                  icon: Icons.thumb_up_alt_rounded,
                  label:
                      _difficultyVote == 'Kolay'
                          ? '✓ Kolaydı\nalındı'
                          : 'Kolaydı',
                  selected: _difficultyVote == 'Kolay',
                  color: const Color(0xFF16A34A),
                  onPressed:
                      _feedbackLoading || _difficultyVote != null
                          ? null
                          : () => _voteDifficulty('Kolay'),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _feedbackButton(
                  icon: Icons.local_fire_department_rounded,
                  label: _difficultyVote == 'Zor' ? '✓ Zordu\nalındı' : 'Zordu',
                  selected: _difficultyVote == 'Zor',
                  color: const Color(0xFFEA580C),
                  onPressed:
                      _feedbackLoading || _difficultyVote != null
                          ? null
                          : () => _voteDifficulty('Zor'),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _feedbackButton(
                  icon: Icons.report_problem_rounded,
                  label: _errorReported ? '✓ Hata\nalındı' : 'Hatalı',
                  selected: _errorReported,
                  color: const Color(0xFFDC2626),
                  onPressed:
                      _feedbackLoading || _errorReported
                          ? null
                          : _showErrorDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feedbackButton({
    required IconData icon,
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: selected ? color.withOpacity(0.12) : null,
        side: BorderSide(
          color: selected ? color : const Color(0xFFCBD5E1),
          width: selected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _voteDifficulty(String vote) async {
    final selectedIndex = _selectedIndex;
    if (selectedIndex == null) return;

    setState(() => _feedbackLoading = true);

    final accepted = await QuestionFeedbackService.submitDifficultyVote(
      question: _question,
      selectedIndex: selectedIndex,
      vote: vote,
      gameMode: _gameMode,
    );

    if (!mounted) return;

    setState(() {
      _feedbackLoading = false;
      if (accepted) _difficultyVote = vote;
    });
  }

  Future<void> _showErrorDialog() async {
    var reason = _errorReasons.first;
    final controller = TextEditingController();

    final submit =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Sorudaki hata nedir?'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: reason,
                          decoration: const InputDecoration(
                            labelText: 'Hata türü',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _errorReasons
                                  .map(
                                    (item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => reason = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller,
                          minLines: 2,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama • İsteğe bağlı',
                            hintText:
                                'Hatanın ne olduğunu kısaca yazabilirsin.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Vazgeç'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Gönder'),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;

    final note = controller.text;
    controller.dispose();

    if (!submit || !mounted) return;

    final selectedIndex = _selectedIndex;
    if (selectedIndex == null) return;

    setState(() => _feedbackLoading = true);

    final accepted = await QuestionFeedbackService.submitErrorReport(
      question: _question,
      selectedIndex: selectedIndex,
      reason: reason,
      note: note,
      gameMode: _gameMode,
    );

    if (!mounted) return;

    setState(() {
      _feedbackLoading = false;
      if (accepted) _errorReported = true;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildOption(int index, GameCategory category) {
    if (_hiddenOptions.contains(index)) {
      return const SizedBox.shrink();
    }

    final isDisabled = _disabledOptions.contains(index);
    final isSelected = _selectedIndex == index;
    final isCorrectOption = _question.answerIndex == index;

    Color background = Colors.white;
    Color border = const Color(0xFFCBD5E1);
    IconData? trailingIcon;

    if (_answered) {
      if (isCorrectOption) {
        background = const Color(0xFFDCFCE7);
        border = const Color(0xFF16A34A);
        trailingIcon = Icons.check_circle_rounded;
      } else if (isSelected) {
        background = const Color(0xFFFEE2E2);
        border = const Color(0xFFDC2626);
        trailingIcon = Icons.cancel_rounded;
      }
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _answered || isDisabled ? null : () => _selectOption(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDisabled ? const Color(0xFFE2E8F0) : border,
              width: isSelected ? 2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: category.darkColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _question.options[index],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingIcon != null) Icon(trailingIcon),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerData {
  PlayerData({
    required this.name,
    required this.color,
    required this.pawnType,
    DifficultyMode? difficultyMode,
    JokerWallet? jokers,
  }) : difficultyMode = difficultyMode ?? DifficultyMode.relaxed,
       jokers = jokers ?? JokerWallet.starter();

  final String name;
  final Color color;
  final int pawnType;
  final DifficultyMode difficultyMode;
  final JokerWallet jokers;
  int position = 0;
  int movePulse = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int correctStreak = 0;
  int wrongStreak = 0;
  bool doubleChance = false;
  final Set<int> badges = <int>{};

  bool get hasAllBadges => badges.length == GameCategory.values.length;
}

class QuestionDraw {
  const QuestionDraw({required this.question, required this.poolReset});

  final QuizQuestion question;
  final bool poolReset;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.categoryIndex,
    required this.text,
    required this.options,
    required this.answerIndex,
    required this.difficulty,
    required this.explanation,
  });

  final String id;
  final int categoryIndex;
  final String text;
  final List<String> options;
  final int answerIndex;
  final String difficulty;
  final String explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      categoryIndex: json['categoryIndex'] as int,
      text: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      answerIndex: json['answerIndex'] as int,
      difficulty: (json['difficulty'] as String?) ?? 'Orta',
      explanation: (json['explanation'] as String?) ?? '',
    );
  }
}

Map<String, dynamic> _prepareQuestionData(String raw) {
  final decoded = jsonDecode(raw) as List<dynamic>;
  final playable = <Map<String, dynamic>>[];
  final reasonCounts = <String, int>{};

  for (final item in decoded) {
    final json = item as Map<String, dynamic>;
    final question = QuizQuestion.fromJson(json);
    final reasons = QuestionQualityGuard.reasons(question);

    if (reasons.isEmpty) {
      playable.add(json);
    } else {
      for (final reason in reasons) {
        reasonCounts.update(reason, (count) => count + 1, ifAbsent: () => 1);
      }
    }
  }

  return <String, dynamic>{
    'questions': playable,
    'scanned': decoded.length,
    'excluded': decoded.length - playable.length,
    'reasons': reasonCounts,
  };
}

class QuestionBank {
  QuestionBank(this.questionsByCategory) {
    for (final question in questionsByCategory.values.expand(
      (questions) => questions,
    )) {
      _familyKeyById[question.id] = questionFamilyKey(question.text);
    }
  }

  final Map<int, List<QuizQuestion>> questionsByCategory;
  final Map<String, String> _familyKeyById = <String, String>{};

  static String questionFamilyKey(String text) {
    final lower = text.toLowerCase();
    final normalized =
        lower
            .replaceAll('ç', 'c')
            .replaceAll('ğ', 'g')
            .replaceAll('ı', 'i')
            .replaceAll('ö', 'o')
            .replaceAll('ş', 's')
            .replaceAll('ü', 'u')
            .replaceAll('â', 'a')
            .replaceAll('î', 'i')
            .replaceAll('û', 'u')
            .replaceAll(RegExp(r'[^a-z0-9°]+'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    var temperatureScaleCount = 0;
    if (normalized.contains('celsius') || lower.contains('°c')) {
      temperatureScaleCount++;
    }
    if (normalized.contains('fahrenheit') || lower.contains('°f')) {
      temperatureScaleCount++;
    }
    if (normalized.contains('kelvin')) {
      temperatureScaleCount++;
    }

    if (temperatureScaleCount >= 2 &&
        const <String>[
          'kac derece',
          'kac derecedir',
          'olceginde',
          'donusumu',
          'donusturuldugunde',
        ].any(normalized.contains)) {
      return 'topic:temperature_conversion';
    }

    final numberCount =
        RegExp(r'(?<![a-z])\d+(?:[.,]\d+)?').allMatches(normalized).length;
    final musicWords =
        normalized.contains('nota') &&
        const <String>[
          'vurus',
          'dortluk',
          'sekizlik',
          'onaltilik',
          'otuzikilik',
          'noktali',
          'olcu',
        ].any(normalized.contains);
    final musicCalculation = const <String>[
      'toplam kac',
      'toplamda kac',
      'kac dortluk',
      'kac vurus',
      'vurus surer',
      'vurus eder',
      'zaman birimi kac',
      'kac tam olcu',
    ].any(normalized.contains);

    if (numberCount >= 2 && musicWords && musicCalculation) {
      return 'topic:music_note_duration';
    }

    final administrativeTemplate =
        (normalized.contains('adli idari bolum') &&
            const <String>[
              'hangi ulkeye baglidir',
              'hangi ulkeye aittir',
              'hangi ulkenin',
            ].any(normalized.contains)) ||
        normalized.contains('hangi ulkenin alt ulusal bolum') ||
        normalized.contains('alt ulusal bolumlerinden biri') ||
        (normalized.contains('idari bolum') &&
            normalized.contains('hangi ulkeye'));

    if (administrativeTemplate) {
      return 'topic:administrative_division_country';
    }

    return normalized.replaceAll(RegExp(r'\d+(?:[.,/]\d+)*'), '#').trim();
  }

  Set<String> _familyKeysForIds(Set<String> questionIds) {
    final keys = <String>{};

    for (final id in questionIds) {
      final key = _familyKeyById[id];
      if (key != null && key.isNotEmpty) {
        keys.add(key);
      }
    }

    return keys;
  }

  List<QuizQuestion> diverseQuestions({
    required List<QuizQuestion> pool,
    required int count,
    required Random random,
  }) {
    if (pool.isEmpty || count <= 0) {
      return const <QuizQuestion>[];
    }

    final shuffled = List<QuizQuestion>.from(pool)..shuffle(random);
    final selected = <QuizQuestion>[];
    final deferred = <QuizQuestion>[];
    final seenFamilies = <String>{};

    for (final question in shuffled) {
      final familyKey =
          _familyKeyById[question.id] ?? questionFamilyKey(question.text);

      if (seenFamilies.add(familyKey)) {
        selected.add(question);
      } else {
        deferred.add(question);
      }

      if (selected.length >= count) {
        return selected;
      }
    }

    for (final question in deferred) {
      selected.add(question);
      if (selected.length >= count) {
        break;
      }
    }

    return selected;
  }

  int get totalCount => questionsByCategory.values.fold<int>(
    0,
    (sum, questions) => sum + questions.length,
  );

  static Future<QuestionBank> load() async {
    final raw = await rootBundle.loadString('assets/questions.json');
    final prepared = await compute<String, Map<String, dynamic>>(
      _prepareQuestionData,
      raw,
    );
    final questions = (prepared['questions'] as List<dynamic>)
        .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    QuestionQualityGuard.lastScannedCount = prepared['scanned'] as int;
    QuestionQualityGuard.lastExcludedCount = prepared['excluded'] as int;
    QuestionQualityGuard.lastReasonCounts = Map<String, int>.unmodifiable(
      Map<String, int>.from(prepared['reasons'] as Map<dynamic, dynamic>),
    );

    debugPrint(
      'Soru kalite taraması: '
      '${QuestionQualityGuard.summary}',
    );

    final grouped = <int, List<QuizQuestion>>{};
    for (final question in questions) {
      grouped.putIfAbsent(question.categoryIndex, () => []).add(question);
    }

    for (var index = 0; index < GameCategory.values.length; index++) {
      if (grouped[index] == null || grouped[index]!.isEmpty) {
        throw StateError(
          '${GameCategory.values[index].label} kategorisinde soru yok.',
        );
      }
    }

    return QuestionBank(grouped);
  }

  QuestionDraw nextQuestion({
    required int categoryIndex,
    required Random random,
    required Set<String> usedQuestionIds,
    String? preferredDifficulty,
  }) {
    final list = questionsByCategory[categoryIndex];

    if (list == null || list.isEmpty) {
      throw StateError('Kategori için soru bulunamadı: $categoryIndex');
    }

    var available =
        list
            .where((question) => !usedQuestionIds.contains(question.id))
            .toList();

    var poolReset = false;

    if (available.isEmpty) {
      final categoryIds = list.map((question) => question.id).toSet();

      usedQuestionIds.removeWhere(categoryIds.contains);
      available = List<QuizQuestion>.from(list);
      poolReset = true;
    }

    final usedFamilyKeys = _familyKeysForIds(usedQuestionIds);
    final familyFresh =
        available
            .where(
              (question) =>
                  !usedFamilyKeys.contains(
                    _familyKeyById[question.id] ??
                        questionFamilyKey(question.text),
                  ),
            )
            .toList();

    if (familyFresh.isNotEmpty) {
      available = familyFresh;
    }

    var candidates = available;

    if (preferredDifficulty != null) {
      final preferred =
          available
              .where((question) => question.difficulty == preferredDifficulty)
              .toList();

      if (preferred.isNotEmpty) {
        candidates = preferred;
      }
    }

    final candidateFamilies = <String, List<QuizQuestion>>{};

    for (final candidate in candidates) {
      final familyKey =
          _familyKeyById[candidate.id] ?? questionFamilyKey(candidate.text);
      candidateFamilies
          .putIfAbsent(familyKey, () => <QuizQuestion>[])
          .add(candidate);
    }

    final families = candidateFamilies.values.toList();
    final selectedFamily = families[random.nextInt(families.length)];
    final question = selectedFamily[random.nextInt(selectedFamily.length)];

    usedQuestionIds.add(question.id);

    return QuestionDraw(question: question, poolReset: poolReset);
  }

  QuizQuestion randomQuestion(int categoryIndex, Random random) {
    final list = questionsByCategory[categoryIndex];
    if (list == null || list.isEmpty) {
      throw StateError('Kategori için soru bulunamadı: $categoryIndex');
    }
    return list[random.nextInt(list.length)];
  }
}

enum GameCategory {
  geography,
  entertainment,
  history,
  artLiterature,
  scienceNature,
  sports,
}

extension GameCategoryX on GameCategory {
  String get label {
    switch (this) {
      case GameCategory.geography:
        return 'Coğrafya';
      case GameCategory.entertainment:
        return 'Eğlence';
      case GameCategory.history:
        return 'Tarih';
      case GameCategory.artLiterature:
        return 'Sanat & Edebiyat';
      case GameCategory.scienceNature:
        return 'Bilim & Doğa';
      case GameCategory.sports:
        return 'Spor';
    }
  }

  String get emoji {
    switch (this) {
      case GameCategory.geography:
        return '🌍';
      case GameCategory.entertainment:
        return '🎬';
      case GameCategory.history:
        return '🏛️';
      case GameCategory.artLiterature:
        return '🎨';
      case GameCategory.scienceNature:
        return '🔬';
      case GameCategory.sports:
        return '⚽';
    }
  }

  Color get color {
    switch (this) {
      case GameCategory.geography:
        return const Color(0xFF2563EB);
      case GameCategory.entertainment:
        return const Color(0xFFDB2777);
      case GameCategory.history:
        return const Color(0xFFEAB308);
      case GameCategory.artLiterature:
        return const Color(0xFF9333EA);
      case GameCategory.scienceNature:
        return const Color(0xFF16A34A);
      case GameCategory.sports:
        return const Color(0xFFF97316);
    }
  }

  Color get darkColor {
    switch (this) {
      case GameCategory.geography:
        return const Color(0xFF1E3A8A);
      case GameCategory.entertainment:
        return const Color(0xFF831843);
      case GameCategory.history:
        return const Color(0xFF854D0E);
      case GameCategory.artLiterature:
        return const Color(0xFF581C87);
      case GameCategory.scienceNature:
        return const Color(0xFF14532D);
      case GameCategory.sports:
        return const Color(0xFF9A3412);
    }
  }
}
