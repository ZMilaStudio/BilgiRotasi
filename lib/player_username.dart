part of 'main.dart';

class PlayerUsernamePolicy {
  PlayerUsernamePolicy._();

  static const int minLength = 3;
  static const int maxLength = 16;
  static const Duration changeCooldown = Duration(days: 30);
  static const Duration firstCorrectionWindow = Duration(hours: 24);
  static const int currentPolicyVersion = 2;

  static final RegExp _allowedPattern = RegExp(r'^[a-z0-9][a-z0-9_]{2,15}$');
  static final RegExp _emailPattern = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    caseSensitive: false,
  );
  static final RegExp _urlPattern = RegExp(
    r'(https?://|www\.|[a-z0-9-]+\.(com|net|org|io|gg|tr)\b)',
    caseSensitive: false,
  );
  static final RegExp _phonePattern = RegExp(r'(?:\d[\s_.-]*){7,}');

  static const Set<String> _reserved = <String>{
    'admin',
    'administrator',
    'moderator',
    'mod',
    'sistem',
    'system',
    'destek',
    'support',
    'bilgirotasi',
    'bilgi_rotasi',
    'google',
    'firebase',
    'zmilastudio',
    'zmila_studio',
    'bilgirotasiadmin',
    'bilgirotasidestek',
    'null',
    'undefined',
  };

  static const Set<String> _exactBlockedTerms = <String>{
    'aq',
    'pic',
    'nazi',
    'sex',
  };

  static const Set<String> _blockedTerms = <String>{
    'amk',
    'orospu',
    'siktir',
    'sikik',
    'yarrak',
    'ibne',
    'gerizekali',
    'salak',
    'aptal',
    'fuck',
    'bitch',
    'nigger',
    'porn',
  };

  static String normalize(String raw) {
    return raw
        .trim()
        .replaceAll('İ', 'i')
        .toLowerCase()
        .replaceAll('\u0307', '')
        .replaceAll('ı', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  static String suggestionFromDisplayName(String displayName) {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '';
    final first = parts.first;
    final suggestion = normalize(first).replaceAll(RegExp(r'[^a-z0-9_]'), '');
    if (suggestion.length < minLength) return '';
    return suggestion.substring(0, min(suggestion.length, maxLength));
  }

  static String _moderationKey(String value) {
    return normalize(value)
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('5', 's')
        .replaceAll('7', 't')
        .replaceAll(RegExp(r'[_\W]+'), '');
  }

  static String? validate(String raw) {
    final username = normalize(raw);

    if (_emailPattern.hasMatch(raw.trim()) ||
        _urlPattern.hasMatch(raw.trim()) ||
        _phonePattern.hasMatch(raw.trim()) ||
        raw.contains('@')) {
      return 'Kullanıcı adı kişisel iletişim bilgisi içeremez.';
    }

    if (username.length < minLength || username.length > maxLength) {
      return 'Kullanıcı adı 3–16 karakter olmalı.';
    }

    if (!_allowedPattern.hasMatch(username)) {
      return 'Yalnızca küçük harf, rakam ve alt çizgi kullanabilirsin. '
          'İlk karakter harf veya rakam olmalı.';
    }

    final moderationKey = _moderationKey(username);
    final impersonates = _reserved.any(
      (term) => moderationKey.contains(_moderationKey(term)),
    );
    final inappropriate = _blockedTerms.any(
      (term) => moderationKey.contains(_moderationKey(term)),
    );

    if (impersonates ||
        _exactBlockedTerms.contains(moderationKey) ||
        inappropriate) {
      return 'Bu kullanıcı adı kullanılamaz.';
    }

    return null;
  }

  static Duration remainingCooldown({
    required DateTime? changedAt,
    DateTime? now,
  }) {
    if (changedAt == null) return Duration.zero;

    final current = (now ?? DateTime.now()).toUtc();
    final availableAt = changedAt.toUtc().add(changeCooldown);

    if (!availableAt.isAfter(current)) return Duration.zero;
    return availableAt.difference(current);
  }

  static String cooldownLabel(Duration remaining) {
    if (remaining <= Duration.zero) return 'Şimdi değiştirebilirsin';

    final days = remaining.inHours ~/ 24;
    final hours = remaining.inHours.remainder(24);
    if (days == 0) return '$hours saat sonra değiştirebilirsin';
    return '$days gün $hours saat sonra değiştirebilirsin';
  }
}

class PlayerUsernameProfile {
  const PlayerUsernameProfile({
    required this.uid,
    required this.username,
    this.changedAt,
    this.firstSetAt,
    this.correctionUsed = true,
    this.policyVersion = 1,
  });

  final String uid;
  final String username;
  final DateTime? changedAt;
  final DateTime? firstSetAt;
  final bool correctionUsed;
  final int policyVersion;

  bool get hasMigrationCorrection =>
      !correctionUsed &&
      username.isNotEmpty &&
      policyVersion < PlayerUsernamePolicy.currentPolicyVersion;

  bool get hasNewAccountCorrection {
    if (correctionUsed || firstSetAt == null) return false;
    return DateTime.now().toUtc().isBefore(
      firstSetAt!.toUtc().add(PlayerUsernamePolicy.firstCorrectionWindow),
    );
  }

  bool get hasFreeCorrection =>
      hasMigrationCorrection || hasNewAccountCorrection;

  bool get canChange =>
      hasFreeCorrection ||
      PlayerUsernamePolicy.remainingCooldown(changedAt: changedAt) <=
          Duration.zero;

  DateTime? get nextChangeAt =>
      changedAt?.toUtc().add(PlayerUsernamePolicy.changeCooldown);

  String get cooldownLabel => PlayerUsernamePolicy.cooldownLabel(
    PlayerUsernamePolicy.remainingCooldown(changedAt: changedAt),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'username': username,
    'changedAt': changedAt?.toIso8601String(),
    'firstSetAt': firstSetAt?.toIso8601String(),
    'correctionUsed': correctionUsed,
    'policyVersion': policyVersion,
  };

  factory PlayerUsernameProfile.fromJson(Map<String, dynamic> json) {
    return PlayerUsernameProfile(
      uid: json['uid']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      changedAt: DateTime.tryParse(json['changedAt']?.toString() ?? ''),
      firstSetAt: DateTime.tryParse(json['firstSetAt']?.toString() ?? ''),
      correctionUsed:
          json.containsKey('correctionUsed')
              ? json['correctionUsed'] == true
              : false,
      policyVersion: (json['policyVersion'] as num?)?.toInt() ?? 1,
    );
  }
}

class PlayerUsernameException implements Exception {
  const PlayerUsernameException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PlayerUsernameService {
  PlayerUsernameService._();

  static const String _localPrefix = 'bilgi_rotasi_player_username_v1_';

  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static final ValueNotifier<PlayerUsernameProfile?> state =
      ValueNotifier<PlayerUsernameProfile?>(null);

  static String? get currentUsername => state.value?.username;

  static CollectionReference<Map<String, dynamic>> get _claims =>
      FirebaseFirestore.instance.collection('usernames');

  static DocumentReference<Map<String, dynamic>> _userReference(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static String _localKey(String uid) => '$_localPrefix$uid';

  static Future<PlayerUsernameProfile?> _readLocal(String uid) async {
    final raw = await _preferences.getString(_localKey(uid));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final profile = PlayerUsernameProfile.fromJson(
        Map<String, dynamic>.from(decoded),
      );

      if (profile.uid != uid ||
          PlayerUsernamePolicy.validate(profile.username) != null) {
        return null;
      }

      return profile;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeLocal(PlayerUsernameProfile profile) async {
    await _preferences.setString(
      _localKey(profile.uid),
      jsonEncode(profile.toJson()),
    );
  }

  static Future<bool> _remoteUsernameMatches(User user, String username) async {
    final snapshot = await _userReference(user.uid)
        .get(GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 6));

    final remoteUsername = PlayerUsernamePolicy.normalize(
      snapshot.data()?['username']?.toString() ?? '',
    );

    return snapshot.exists && remoteUsername == username;
  }

  static Future<PlayerUsernameProfile?> load() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      state.value = null;
      return null;
    }

    final local = await _readLocal(user.uid);

    if (local != null) {
      state.value = local;
      unawaited(_refreshRemote(user, local));
      return local;
    }

    return _refreshRemote(user, null);
  }

  static Future<PlayerUsernameProfile?> _refreshRemote(
    User user,
    PlayerUsernameProfile? fallback,
  ) async {
    try {
      final snapshot = await _userReference(user.uid)
          .get(GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 6));

      final data = snapshot.data();
      final username = PlayerUsernamePolicy.normalize(
        data?['username']?.toString() ?? '',
      );
      final changedAt = data?['usernameChangedAt'];
      final firstSetAt = data?['usernameFirstSetAt'];

      if (PlayerUsernamePolicy.validate(username) != null) {
        return fallback;
      }

      final profile = PlayerUsernameProfile(
        uid: user.uid,
        username: username,
        changedAt:
            changedAt is Timestamp ? changedAt.toDate() : fallback?.changedAt,
        firstSetAt:
            firstSetAt is Timestamp
                ? firstSetAt.toDate()
                : fallback?.firstSetAt,
        correctionUsed: data?['usernameCorrectionUsed'] == true,
        policyVersion:
            (data?['usernamePolicyVersion'] as num?)?.toInt() ??
            fallback?.policyVersion ??
            1,
      );

      await _writeLocal(profile);
      state.value = profile;
      return profile;
    } catch (_) {
      return fallback;
    }
  }

  static Future<String> requireUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const PlayerUsernameException(
        'Kullanıcı adı için Google hesabıyla giriş yapmalısın.',
      );
    }

    final current = state.value;
    if (current != null &&
        current.uid == user.uid &&
        PlayerUsernamePolicy.validate(current.username) == null) {
      try {
        if (await _remoteUsernameMatches(user, current.username)) {
          return current.username;
        }

        final repaired = await claim(current.username);
        return repaired.username;
      } on PlayerUsernameException {
        rethrow;
      } catch (_) {
        throw const PlayerUsernameException(
          'Kullanıcı adı sunucuda doğrulanamadı. '
          'İnternet bağlantını kontrol edip tekrar dene.',
        );
      }
    }

    final loaded = await load();
    if (loaded == null) {
      throw const PlayerUsernameException(
        'Önce kullanıcı adını belirlemelisin.',
      );
    }

    return loaded.username;
  }

  static Future<PlayerUsernameProfile> claim(String raw) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const PlayerUsernameException(
        'Kullanıcı adı için Google hesabıyla giriş yapmalısın.',
      );
    }

    final username = PlayerUsernamePolicy.normalize(raw);
    final validationError = PlayerUsernamePolicy.validate(username);

    if (validationError != null) {
      throw PlayerUsernameException(validationError);
    }

    final current = await load();

    if (current?.username == username) {
      try {
        if (await _remoteUsernameMatches(user, username)) {
          return current!;
        }
      } catch (_) {
        // Aynı adın sunucu kaydı eksikse işlem aşağıdaki
        // transaction ile yeniden kurulacaktır.
      }
    }

    if (current != null && current.username != username && !current.canChange) {
      throw PlayerUsernameException(
        'Kullanıcı adını ${current.cooldownLabel.toLowerCase()}.',
      );
    }

    if (current != null && current.username != username) {
      await _ensureNoActiveDuel(user.uid);
    }

    late final Map<String, dynamic> result;
    try {
      result = await PlayerUsernameServerGateway.claim(username);
    } on FirebaseFunctionsException catch (error) {
      throw PlayerUsernameException(
        error.message ?? 'Kullanıcı adı sunucuda doğrulanamadı.',
      );
    }
    final changedAt = DateTime.fromMillisecondsSinceEpoch(
      (result['changedAtMillis'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      isUtc: true,
    );
    final firstSetAt = DateTime.fromMillisecondsSinceEpoch(
      (result['firstSetAtMillis'] as num?)?.toInt() ??
          current?.firstSetAt?.millisecondsSinceEpoch ??
          changedAt.millisecondsSinceEpoch,
      isUtc: true,
    );

    final profile = PlayerUsernameProfile(
      uid: user.uid,
      username: username,
      changedAt: changedAt,
      firstSetAt: firstSetAt,
      correctionUsed: result['correctionUsed'] == true,
      policyVersion:
          (result['policyVersion'] as num?)?.toInt() ??
          PlayerUsernamePolicy.currentPolicyVersion,
    );

    await _writeLocal(profile);
    state.value = profile;
    AccountCloudService.refreshPresentation();

    return profile;
  }

  static Future<void> deleteAccountIdentity(String uid) async {
    final userReference = _userReference(uid);
    final local = await _readLocal(uid);

    await FirebaseFirestore.instance.runTransaction<void>((transaction) async {
      final userSnapshot = await transaction.get(userReference);
      final username = PlayerUsernamePolicy.normalize(
        userSnapshot.data()?['username']?.toString() ?? local?.username ?? '',
      );

      DocumentReference<Map<String, dynamic>>? claimReference;
      DocumentSnapshot<Map<String, dynamic>>? claimSnapshot;

      if (username.isNotEmpty) {
        claimReference = _claims.doc(username);
        claimSnapshot = await transaction.get(claimReference);
      }

      if (claimReference != null &&
          claimSnapshot?.data()?['uid']?.toString() == uid) {
        transaction.delete(claimReference);
      }

      if (userSnapshot.exists) {
        transaction.delete(userReference);
      }
    });

    await _preferences.remove(_localKey(uid));

    if (state.value?.uid == uid) {
      state.value = null;
    }
  }

  static void resetSession() {
    state.value = null;
  }

  static Future<void> _ensureNoActiveDuel(String uid) async {
    final queue = await FirebaseFirestore.instance
        .collection('live_duel_queue')
        .doc(uid)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 6));
    if (queue.exists) {
      throw const PlayerUsernameException(
        'Eşleştirme kuyruğundayken kullanıcı adı değiştirilemez.',
      );
    }

    final matches = await FirebaseFirestore.instance
        .collection('live_duel_matches')
        .where('playerUids', arrayContains: uid)
        .limit(10)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 6));
    final active = matches.docs.any((document) {
      final data = document.data();
      return data['resultProcessed'] != true && data['status'] != 'completed';
    });
    if (active) {
      throw const PlayerUsernameException(
        'Devam eden düello tamamlanmadan kullanıcı adı değiştirilemez.',
      );
    }
  }
}

class PlayerCommunityAgreementService {
  const PlayerCommunityAgreementService._();

  static const String textVersion = '2026-07-30-v1';

  static Future<void> accept() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const PlayerUsernameException('Google hesabı gerekli.');
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('agreements')
        .doc('community')
        .set(<String, dynamic>{
          'uid': user.uid,
          'textVersion': textVersion,
          'acceptedAt': FieldValue.serverTimestamp(),
          'appVersion': AppBuildInfo.version,
        });
  }
}

class PlayerUsernameGate extends StatefulWidget {
  const PlayerUsernameGate({
    required this.questionBank,
    this.ownerUid,
    super.key,
  });

  final QuestionBank questionBank;
  final String? ownerUid;

  @override
  State<PlayerUsernameGate> createState() => _PlayerUsernameGateState();
}

class _PlayerUsernameGateState extends State<PlayerUsernameGate> {
  late Future<PlayerUsernameProfile?> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = PlayerUsernameService.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerUsernameProfile?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return ProductModeEntryScreen(
            questionBank: widget.questionBank,
            ownerUid: widget.ownerUid,
          );
        }

        return PlayerUsernameSetupScreen(
          onSaved: (_) {
            if (!mounted) return;
            setState(_reload);
          },
        );
      },
    );
  }
}

class PlayerUsernameSetupScreen extends StatefulWidget {
  const PlayerUsernameSetupScreen({
    this.onSaved,
    this.allowBack = false,
    super.key,
  });

  final ValueChanged<PlayerUsernameProfile>? onSaved;
  final bool allowBack;

  @override
  State<PlayerUsernameSetupScreen> createState() =>
      _PlayerUsernameSetupScreenState();
}

class _PlayerUsernameSetupScreenState extends State<PlayerUsernameSetupScreen> {
  late final TextEditingController _controller;
  bool _busy = false;
  String? _error;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();

    final current = PlayerUsernameService.currentUsername;
    final googleName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    final suggestion = PlayerUsernamePolicy.suggestionFromDisplayName(
      googleName,
    );

    _controller = TextEditingController(text: current ?? suggestion);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;

    final validationError = PlayerUsernamePolicy.validate(_controller.text);

    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    final current = PlayerUsernameService.state.value;
    if (current == null && !_accepted) {
      setState(() {
        _error =
            'Çevrimiçi kullanıcı adı için koşulları ve topluluk '
            'kurallarını kabul etmelisin.';
      });
      return;
    }

    final username = PlayerUsernamePolicy.normalize(_controller.text);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text('Yazımını kontrol et'),
                content: Text(
                  'Kullanıcı adın @$username olarak görünecek. '
                  'Yazımını kontrol ettin mi?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Düzenlemeye dön'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(
                      current == null
                          ? 'Evet, kullanıcı adımı oluştur'
                          : 'Evet, kullanıcı adımı değiştir',
                    ),
                  ),
                ],
              ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (current == null) {
        await PlayerCommunityAgreementService.accept();
      }
      final profile = await PlayerUsernameService.claim(_controller.text);

      if (!mounted) return;

      widget.onSaved?.call(profile);

      if (widget.allowBack && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(profile);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _busy = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = PlayerUsernameService.state.value;
    final changing = current != null;
    final remaining = PlayerUsernamePolicy.remainingCooldown(
      changedAt: current?.changedAt,
    );
    final freeCorrection = current?.hasFreeCorrection == true;
    final blocked = changing && !freeCorrection && remaining > Duration.zero;
    final nextChangeAt = current?.nextChangeAt?.toLocal();

    return Scaffold(
      appBar:
          widget.allowBack ? AppBar(title: const Text('Kullanıcı Adı')) : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF170C21),
              Color(0xFF352044),
              Color(0xFF0D5260),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Text(
                          '🪪',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 52),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          changing
                              ? 'Kullanıcı adını değiştir'
                              : 'Oyuncu adını belirle',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bu ad Canlı Düello, lig sıralaması ve '
                          'maç geçmişinde görünecek. Google adın ve '
                          'e-postan diğer oyunculara gösterilmeyecek.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        if (current != null) ...<Widget>[
                          Text(
                            'Mevcut ad: @${current.username}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Son değişiklik: '
                            '${_dateTimeLabel(current.changedAt?.toLocal())}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            freeCorrection
                                ? 'Bir defalık ücretsiz düzeltme hakkın hazır.'
                                : 'Normal değişiklik: 30 günde bir. '
                                    'Sonraki tarih: '
                                    '${_dateTimeLabel(nextChangeAt)}',
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _controller,
                          enabled: !_busy && !blocked,
                          maxLength: 16,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9_]'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Kullanıcı adı',
                            prefixText: '@',
                            hintText: 'leventua',
                            errorText: _error,
                            helperText:
                                freeCorrection
                                    ? 'Ücretsiz düzeltme hakkı • bekleme yok'
                                    : blocked
                                    ? PlayerUsernamePolicy.cooldownLabel(
                                      remaining,
                                    )
                                    : '3–16 karakter • küçük harf, '
                                        'rakam ve _',
                          ),
                          onSubmitted: (_) => _save(),
                        ),
                        if (!changing) ...<Widget>[
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _accepted,
                            onChanged:
                                _busy
                                    ? null
                                    : (value) => setState(
                                      () => _accepted = value == true,
                                    ),
                            title: const Text(
                              'Kullanım Koşulları, Topluluk Kuralları ve '
                              'Gizlilik Politikası’nı okudum.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: <Widget>[
                              _policyLink(
                                'Koşullar',
                                'https://leventua.github.io/BilgiRotasi/'
                                    'terms-of-use.html',
                              ),
                              _policyLink(
                                'Topluluk',
                                'https://leventua.github.io/BilgiRotasi/'
                                    'community-guidelines.html',
                              ),
                              _policyLink(
                                'Gizlilik',
                                'https://leventua.github.io/BilgiRotasi/'
                                    'privacy-policy.html',
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _busy || blocked ? null : _save,
                          icon:
                              _busy
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                  : const Icon(Icons.check_rounded),
                          label: Text(
                            changing
                                ? 'Kullanıcı Adını Değiştir'
                                : 'Kullanıcı Adını Kaydet',
                          ),
                        ),
                        if (!widget.allowBack) ...<Widget>[
                          const SizedBox(height: 12),
                          const Text(
                            'Kullanıcı adını daha sonra 30 günde bir '
                            'değiştirebilirsin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _policyLink(String label, String url) {
    return TextButton(
      onPressed:
          () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Text(label),
    );
  }

  String _dateTimeLabel(DateTime? value) {
    if (value == null) return 'Bilinmiyor';
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}.${two(value.month)}.${value.year} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
