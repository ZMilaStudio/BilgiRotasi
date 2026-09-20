part of 'main.dart';

enum AccountMode { undecided, guest, google }

class AccountCloudConflict {
  const AccountCloudConflict({
    required this.localSnapshot,
    required this.remoteSnapshot,
    required this.localRevision,
    required this.remoteRevision,
    required this.localValueCount,
    required this.remoteValueCount,
    required this.localCapturedAt,
    this.remoteUpdatedAt,
  });

  final String localSnapshot;
  final String remoteSnapshot;
  final int localRevision;
  final int remoteRevision;
  final int localValueCount;
  final int remoteValueCount;
  final DateTime localCapturedAt;
  final DateTime? remoteUpdatedAt;
}

class CloudSnapshotRecord {
  const CloudSnapshotRecord({
    required this.snapshot,
    required this.revision,
    this.updatedAt,
    this.deviceInstallationId,
  });

  final String snapshot;
  final int revision;
  final DateTime? updatedAt;
  final String? deviceInstallationId;
}

class AccountCloudConflictException implements Exception {
  const AccountCloudConflictException();
}

class AccountAccessPolicy {
  AccountAccessPolicy._();

  static bool dailyVisible(AccountMode mode) {
    return mode == AccountMode.google;
  }
}

class AccountDeletionFinalizationResult {
  const AccountDeletionFinalizationResult({required this.failureCount});

  final int failureCount;
  bool get isPartial => failureCount > 0;
}

class AccountDeletionSessionFinalizer {
  AccountDeletionSessionFinalizer._();

  static Future<AccountDeletionFinalizationResult> run({
    required List<Future<void> Function()> localCleanupTasks,
    required Future<void> Function() firebaseSignOut,
    required Future<void> Function() googleSignOut,
  }) async {
    var failures = 0;
    for (final task in localCleanupTasks) {
      try {
        await task();
      } catch (_) {
        failures++;
      }
    }
    for (final signOut in <Future<void> Function()>[
      firebaseSignOut,
      googleSignOut,
    ]) {
      try {
        await signOut();
      } catch (_) {
        failures++;
      }
    }
    return AccountDeletionFinalizationResult(failureCount: failures);
  }
}

class AccountSessionState {
  const AccountSessionState({
    required this.mode,
    required this.firebaseReady,
    this.user,
    this.busy = false,
    this.message,
    this.lastSyncedAt,
    this.conflict,
  });

  final AccountMode mode;
  final bool firebaseReady;
  final User? user;
  final bool busy;
  final String? message;
  final DateTime? lastSyncedAt;
  final AccountCloudConflict? conflict;

  bool get signedIn => mode == AccountMode.google && user != null;

  String get sessionKey {
    return '${mode.name}:${user?.uid ?? 'guest'}';
  }
}

enum GoogleAccountSignInStage {
  googleAuthenticate,
  firebaseCredential,
  cloudSync,
}

class GoogleAccountSignInOutcome<T> {
  const GoogleAccountSignInOutcome({
    required this.mode,
    required this.cloudSynced,
    this.user,
    this.message,
    this.failedStage,
  });

  final AccountMode mode;
  final T? user;
  final bool cloudSynced;
  final String? message;
  final GoogleAccountSignInStage? failedStage;
}

class GoogleAccountSignInMessages {
  GoogleAccountSignInMessages._();

  static const String cloudSyncFailed =
      'Google girişi başarılı. Bulut kaydı şu an eşitlenemedi; '
      'telefondaki kayıt korunuyor.';

  static String forAuthenticationError(Object error) {
    if (error is GoogleSignInException) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          return 'Google girişi iptal edildi.';
        case GoogleSignInExceptionCode.clientConfigurationError:
          return 'Google giriş yapılandırması doğrulanamadı.';
        case GoogleSignInExceptionCode.uiUnavailable:
          return 'Google hesap seçme ekranı açılamadı.';
        case GoogleSignInExceptionCode.interrupted:
          return 'Google giriş işlemi kesildi.';
        case GoogleSignInExceptionCode.unknownError:
          return 'Google hesabı doğrulanamadı.';
        case GoogleSignInExceptionCode.providerConfigurationError:
          return 'Google giriş hizmeti kullanılamıyor.';
        case GoogleSignInExceptionCode.userMismatch:
          return 'Seçilen Google hesabı doğrulanamadı.';
      }
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
          return 'Google oturumu doğrulanamadı. Tekrar deneyebilirsin.';
        case 'account-exists-with-different-credential':
          return 'Bu e-posta başka bir giriş yöntemiyle kayıtlı.';
        case 'network-request-failed':
          return 'İnternet bağlantısı kurulamadı.';
        case 'user-disabled':
          return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
        case 'operation-not-allowed':
          return 'Google ile giriş şu anda kullanılamıyor.';
      }
    }

    return 'Google hesabı doğrulanamadı.';
  }
}

class GoogleAccountSignInFlow {
  GoogleAccountSignInFlow._();

  static Future<GoogleAccountSignInOutcome<T>> run<T>({
    required AccountMode previousMode,
    required Future<T> Function() authenticate,
    required void Function(T user) onAuthenticated,
    required Future<void> Function(T user) synchronizeCloud,
  }) async {
    late final T user;
    try {
      user = await authenticate();
    } catch (error) {
      return GoogleAccountSignInOutcome<T>(
        mode: previousMode,
        cloudSynced: false,
        message: GoogleAccountSignInMessages.forAuthenticationError(error),
        failedStage:
            error is FirebaseAuthException
                ? GoogleAccountSignInStage.firebaseCredential
                : GoogleAccountSignInStage.googleAuthenticate,
      );
    }

    onAuthenticated(user);

    try {
      await synchronizeCloud(user);
      return GoogleAccountSignInOutcome<T>(
        mode: AccountMode.google,
        user: user,
        cloudSynced: true,
      );
    } catch (_) {
      return GoogleAccountSignInOutcome<T>(
        mode: AccountMode.google,
        user: user,
        cloudSynced: false,
        message: GoogleAccountSignInMessages.cloudSyncFailed,
        failedStage: GoogleAccountSignInStage.cloudSync,
      );
    }
  }
}

class AccountSnapshotCodec {
  AccountSnapshotCodec._();

  static String encode(Map<String, Object?> values) {
    final encoded = <String, dynamic>{};

    for (final entry in values.entries) {
      final value = entry.value;

      if (value is String) {
        encoded[entry.key] = <String, dynamic>{
          'type': 'string',
          'value': value,
        };
      } else if (value is int) {
        encoded[entry.key] = <String, dynamic>{'type': 'int', 'value': value};
      } else if (value is double) {
        encoded[entry.key] = <String, dynamic>{
          'type': 'double',
          'value': value,
        };
      } else if (value is bool) {
        encoded[entry.key] = <String, dynamic>{'type': 'bool', 'value': value};
      } else if (value is List<String>) {
        encoded[entry.key] = <String, dynamic>{
          'type': 'stringList',
          'value': value,
        };
      }
    }

    return jsonEncode(<String, dynamic>{'schema': 2, 'values': encoded});
  }

  static Map<String, Object?> decode(String raw) {
    if (utf8.encode(raw).length > 700000) {
      throw const FormatException('Bulut kayıt boyutu güvenli sınırı aşıyor.');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Bulut kayıt biçimi geçersiz.');
    }

    final root = Map<String, dynamic>.from(decoded);
    final schema = (root['schema'] as num?)?.toInt() ?? 1;
    if (schema < 1 || schema > 2) {
      throw const FormatException('Bulut kayıt şeması desteklenmiyor.');
    }
    final rawValues = root['values'];
    if (rawValues is! Map) {
      throw const FormatException('Bulut kayıt değerleri bulunamadı.');
    }

    if (rawValues.length > 500) {
      throw const FormatException('Bulut kayıt alanı güvenli sınırı aşıyor.');
    }

    final result = <String, Object?>{};

    for (final entry in rawValues.entries) {
      final key = entry.key.toString();
      final item = entry.value;

      if (item is! Map) continue;

      final typed = Map<String, dynamic>.from(item);
      final type = typed['type']?.toString();
      final value = typed['value'];

      switch (type) {
        case 'string':
          if (value is String) result[key] = value;
        case 'int':
          if (value is num) result[key] = value.toInt();
        case 'double':
          if (value is num) result[key] = value.toDouble();
        case 'bool':
          if (value is bool) result[key] = value;
        case 'stringList':
          if (value is List) {
            result[key] = value
                .map((item) => item.toString())
                .toList(growable: false);
          }
      }
    }

    return result;
  }
}

class AccountLocalSnapshot {
  AccountLocalSnapshot._();

  static const String controlPrefix = 'bilgi_rotasi_account_';
  static const String _restoreJournalKey =
      'bilgi_rotasi_account_restore_journal_v1';

  // Oyun servisleri SharedPreferencesAsync kullanıyor.
  // Bulut yedeği de aynı Android DataStore alanını okumalıdır.
  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static bool shouldSyncKey(String key) {
    if (!key.startsWith('bilgi_rotasi_')) return false;
    if (key.startsWith(controlPrefix)) return false;

    final lower = key.toLowerCase();

    if (GameSaveService.isScopedStorageKey(key)) {
      return GameSaveService.belongsToActiveScope(key);
    }

    if (key == GameSaveService._legacySaveKey ||
        key == GameSaveService._legacyBackupKey) {
      return false;
    }

    if (lower.contains('player_username')) return false;

    if (lower.contains('error_log') ||
        lower.contains('system_health') ||
        lower.contains('question_feedback')) {
      return false;
    }

    return true;
  }

  static int valueCount(String raw) {
    return AccountSnapshotCodec.decode(raw).length;
  }

  static Future<String> capture() async {
    final allValues = await _preferences.getAll();
    final values = <String, Object?>{};

    for (final entry in allValues.entries) {
      if (!shouldSyncKey(entry.key)) continue;
      values[entry.key] = entry.value;
    }

    final encoded = AccountSnapshotCodec.encode(values);

    if (utf8.encode(encoded).length > 700000) {
      throw StateError('Bulut kaydı güvenli boyut sınırını aştı.');
    }

    return encoded;
  }

  static Future<void> restore(String raw) async {
    final values = AccountSnapshotCodec.decode(raw);
    final backup = await capture();
    await _preferences.setString(
      _restoreJournalKey,
      jsonEncode(<String, String>{'backup': backup, 'target': raw}),
    );

    try {
      await _applyDecoded(values);
      await _preferences.remove(_restoreJournalKey);
    } catch (_) {
      await _applyDecoded(AccountSnapshotCodec.decode(backup));
      await _preferences.remove(_restoreJournalKey);
      rethrow;
    }
  }

  static Future<void> recoverInterruptedRestore() async {
    final journal = await _preferences.getString(_restoreJournalKey);
    if (journal == null || journal.isEmpty) return;

    try {
      final decoded = jsonDecode(journal);
      if (decoded is! Map || decoded['backup'] is! String) {
        throw const FormatException('Geri yükleme günlüğü bozuk.');
      }
      final backup = decoded['backup'] as String;
      await _applyDecoded(AccountSnapshotCodec.decode(backup));
    } finally {
      await _preferences.remove(_restoreJournalKey);
    }
  }

  static Future<void> _applyDecoded(Map<String, Object?> values) async {
    final currentKeys = (await _preferences.getKeys())
        .where(shouldSyncKey)
        .toList(growable: false);

    for (final key in currentKeys) {
      await _preferences.remove(key);
    }

    for (final entry in values.entries) {
      if (!shouldSyncKey(entry.key)) continue;

      final value = entry.value;

      if (value is String) {
        await _preferences.setString(entry.key, value);
      } else if (value is int) {
        await _preferences.setInt(entry.key, value);
      } else if (value is double) {
        await _preferences.setDouble(entry.key, value);
      } else if (value is bool) {
        await _preferences.setBool(entry.key, value);
      } else if (value is List<String>) {
        await _preferences.setStringList(entry.key, value);
      }
    }
  }

  static Future<void> clearGameData() async {
    final currentKeys = (await _preferences.getKeys())
        .where(shouldSyncKey)
        .toList(growable: false);

    for (final key in currentKeys) {
      await _preferences.remove(key);
    }
  }
}

class AccountCloudService with WidgetsBindingObserver {
  AccountCloudService._();

  static final AccountCloudService _instance = AccountCloudService._();

  static const String _guestSelectedKey =
      'bilgi_rotasi_account_guest_selected_v1';
  static const String _guestSnapshotKey =
      'bilgi_rotasi_account_guest_snapshot_v1';
  static const String _installationIdKey =
      'bilgi_rotasi_account_installation_id_v1';
  static const String _googleServerClientId =
      '184174765052-cq19m113aum2jofrfj3np8adbulgmeon'
      '.apps.googleusercontent.com';

  static final ValueNotifier<AccountSessionState> state =
      ValueNotifier<AccountSessionState>(
        const AccountSessionState(
          mode: AccountMode.undecided,
          firebaseReady: false,
        ),
      );

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  GoogleSignIn? _googleSignIn;
  Timer? _syncTimer;
  bool _initialized = false;
  bool _syncing = false;
  bool _deleting = false;

  static bool get dailyVisible {
    return AccountAccessPolicy.dailyVisible(state.value.mode);
  }

  static Future<void> initialize() {
    return _instance._initialize();
  }

  static Future<void> continueAsGuest() {
    return _instance._continueAsGuest();
  }

  static Future<void> signInWithGoogle() {
    return _instance._signInWithGoogle();
  }

  static Future<void> signOut() {
    return _instance._signOut();
  }

  static Future<void> syncNow() {
    return _instance._syncNow(manual: true);
  }

  static Future<void> deleteAccountAndCloudData() {
    return _instance._deleteAccountAndCloudData();
  }

  static Future<void> resolveConflict({required bool useCloud}) {
    return _instance._resolveConflict(useCloud: useCloud);
  }

  static void refreshPresentation() {
    final current = state.value;

    state.value = AccountSessionState(
      mode: current.mode,
      firebaseReady: current.firebaseReady,
      user: current.user,
      busy: current.busy,
      message: current.message,
      lastSyncedAt: current.lastSyncedAt,
      conflict: current.conflict,
    );
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    _initialized = true;

    final preferences = await SharedPreferences.getInstance();
    final guestSelected = preferences.getBool(_guestSelectedKey) == true;

    try {
      await AccountLocalSnapshot.recoverInterruptedRestore();

      if (!FirebaseRuntimePolicy.remoteFirebaseEnabled) {
        state.value = AccountSessionState(
          mode: AccountMode.guest,
          firebaseReady: false,
          message: 'Test derlemesinde production Firebase bağlantısı kapalı.',
        );
        return;
      }

      await Firebase.initializeApp();
      await FirebaseRuntimePolicy.activateAppCheck();

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _googleSignIn = GoogleSignIn.instance;

      await _googleSignIn!.initialize(serverClientId: _googleServerClientId);

      WidgetsBinding.instance.addObserver(this);

      final currentUser = _auth!.currentUser;

      if (currentUser == null) {
        state.value = AccountSessionState(
          mode: guestSelected ? AccountMode.guest : AccountMode.undecided,
          firebaseReady: true,
        );
      } else {
        state.value = AccountSessionState(
          mode: AccountMode.google,
          firebaseReady: true,
          user: currentUser,
          message:
              'Telefondaki kayıtla açıldı. '
              'Bulut eşitlemesi arka planda denenecek.',
        );

        unawaited(_activateExistingUser(currentUser));
      }

      _syncTimer?.cancel();

      _syncTimer = Timer.periodic(const Duration(seconds: 45), (_) {
        if (state.value.signedIn) {
          unawaited(_syncNow(manual: false));
        }
      });
    } catch (error) {
      state.value = AccountSessionState(
        mode: guestSelected ? AccountMode.guest : AccountMode.undecided,
        firebaseReady: false,
        message:
            'Google girişi şu an hazırlanamadı. '
            'Misafir olarak çevrimdışı oynayabilirsin.',
      );
    }
  }

  Future<void> _continueAsGuest() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_guestSelectedKey, true);
    await GameSaveService.sanitizeGuestScope();

    final snapshot = await AccountLocalSnapshot.capture();
    await preferences.setString(_guestSnapshotKey, snapshot);

    state.value = AccountSessionState(
      mode: AccountMode.guest,
      firebaseReady: state.value.firebaseReady,
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_auth == null || _firestore == null || _googleSignIn == null) {
      state.value = AccountSessionState(
        mode: state.value.mode,
        firebaseReady: false,
        message:
            'Google girişi hazır değil. '
            'İnternet bağlantını kontrol et.',
      );
      return;
    }

    final previousState = state.value;
    final previousMode = previousState.mode;
    final preferences = await SharedPreferences.getInstance();
    await GameSaveService.sanitizeGuestScope();
    final guestSnapshot = await AccountLocalSnapshot.capture();

    await preferences.setString(_guestSnapshotKey, guestSnapshot);
    await preferences.setBool(_guestSelectedKey, true);

    state.value = AccountSessionState(
      mode: previousMode,
      firebaseReady: true,
      busy: true,
    );

    final outcome = await GoogleAccountSignInFlow.run<User>(
      previousMode: previousMode,
      authenticate: _authenticateGoogleUser,
      onAuthenticated: (user) {
        state.value = AccountSessionState(
          mode: AccountMode.google,
          firebaseReady: true,
          user: user,
          busy: true,
          message: 'Google hesabı bağlandı. Bulut kaydı hazırlanıyor.',
        );
      },
      synchronizeCloud: (user) {
        return _synchronizeAfterGoogleSignIn(user, guestSnapshot);
      },
    );

    if (outcome.user == null) {
      state.value = AccountSessionState(
        mode: previousMode,
        firebaseReady: true,
        user: previousState.user,
        message: outcome.message,
        lastSyncedAt: previousState.lastSyncedAt,
        conflict: previousState.conflict,
      );
      return;
    }

    if (!outcome.cloudSynced) {
      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: outcome.user,
        message: outcome.message,
        lastSyncedAt: state.value.lastSyncedAt,
        conflict: state.value.conflict,
      );
    }
  }

  Future<User> _authenticateGoogleUser() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn!.authenticate();

    if (googleUser == null) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );
    }

    final idToken = googleUser.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description: 'Google ID token was unavailable.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final result = await _auth!.signInWithCredential(credential);
    final user = result.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Firebase credential did not return a user.',
      );
    }
    return user;
  }

  Future<void> _synchronizeAfterGoogleSignIn(
    User user,
    String guestSnapshot,
  ) async {
    final remoteRecord = await _loadRemoteRecord(user.uid);
    final remote = remoteRecord?.snapshot;
    final localCount = AccountLocalSnapshot.valueCount(guestSnapshot);
    final remoteCount =
        remote == null ? 0 : AccountLocalSnapshot.valueCount(remote);

    if (remote == null || (remoteCount == 0 && localCount > 0)) {
      await _writeRemoteSnapshot(user, guestSnapshot);
    } else if (localCount > 0 && remote != guestSnapshot) {
      await _saveUserLocalSnapshot(
        user.uid,
        guestSnapshot,
        dirty: true,
        revision: 0,
      );
      await _publishConflict(
        user: user,
        localSnapshot: guestSnapshot,
        localRevision: 0,
        remote: remoteRecord!,
      );
      return;
    } else {
      await AccountLocalSnapshot.restore(remote);
      await _saveUserLocalSnapshot(
        user.uid,
        remote,
        dirty: false,
        revision: remoteRecord!.revision,
      );
    }

    await _refreshGameServices();

    state.value = AccountSessionState(
      mode: AccountMode.google,
      firebaseReady: true,
      user: user,
      message:
          'Bulut kaydı doğrulandı • '
          '${max(localCount, remoteCount)} kayıt',
      lastSyncedAt: DateTime.now(),
    );
  }

  Future<void> _activateExistingUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    final localSnapshot = preferences.getString(_userSnapshotKey(user.uid));
    final dirty = preferences.getBool(_userDirtyKey(user.uid)) == true;
    final localRevision = preferences.getInt(_userRevisionKey(user.uid)) ?? 0;
    final deviceSnapshot = await AccountLocalSnapshot.capture();
    final deviceCount = AccountLocalSnapshot.valueCount(deviceSnapshot);

    try {
      final remoteRecord = await _loadRemoteRecord(user.uid);
      if (dirty &&
          localSnapshot != null &&
          localSnapshot.isNotEmpty &&
          remoteRecord != null &&
          remoteRecord.revision != localRevision &&
          remoteRecord.snapshot != localSnapshot) {
        await _publishConflict(
          user: user,
          localSnapshot: localSnapshot,
          localRevision: localRevision,
          remote: remoteRecord,
        );
        return;
      }

      if (dirty &&
          localSnapshot != null &&
          localSnapshot.isNotEmpty &&
          AccountLocalSnapshot.valueCount(localSnapshot) > 0) {
        await AccountLocalSnapshot.restore(localSnapshot);
        await _writeRemoteSnapshot(
          user,
          localSnapshot,
          expectedRevision: remoteRecord?.revision ?? 0,
        );
      } else {
        final remote = remoteRecord?.snapshot;
        final remoteCount =
            remote == null ? 0 : AccountLocalSnapshot.valueCount(remote);

        if (remote != null && remoteCount > 0) {
          await AccountLocalSnapshot.restore(remote);
          await _saveUserLocalSnapshot(
            user.uid,
            remote,
            dirty: false,
            revision: remoteRecord!.revision,
          );
        } else {
          final snapshot =
              deviceCount > 0
                  ? deviceSnapshot
                  : localSnapshot != null && localSnapshot.isNotEmpty
                  ? localSnapshot
                  : deviceSnapshot;

          await _writeRemoteSnapshot(user, snapshot);
        }
      }

      await _refreshGameServices();

      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        lastSyncedAt: DateTime.now(),
      );
    } catch (_) {
      await _refreshGameServices();

      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        message:
            'Bulut kaydı şu an alınamadı. '
            'Telefondaki kayıt korunuyor.',
      );
    }
  }

  Future<CloudSnapshotRecord?> _loadRemoteRecord(String uid) async {
    final document = await _firestore!
        .collection('users')
        .doc(uid)
        .get(GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 6));

    if (!document.exists) return null;

    final data = document.data();
    final raw = data?['snapshotJson'];

    if (raw is! String || raw.isEmpty) return null;

    AccountSnapshotCodec.decode(raw);
    final rawUpdatedAt = data?['updatedAt'];
    return CloudSnapshotRecord(
      snapshot: raw,
      revision: max(0, (data?['revision'] as num?)?.toInt() ?? 0),
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
      deviceInstallationId: data?['deviceInstallationId']?.toString(),
    );
  }

  Future<int> _writeRemoteSnapshot(
    User user,
    String snapshot, {
    int? expectedRevision,
  }) async {
    if (utf8.encode(snapshot).length > 700000) {
      throw StateError('Bulut kaydı güvenli boyut sınırını aştı.');
    }

    final valueCount = AccountLocalSnapshot.valueCount(snapshot);
    final reference = _firestore!.collection('users').doc(user.uid);
    final installationId = await _installationId();

    final revision = await _firestore!.runTransaction<int>((transaction) async {
      final current = await transaction.get(reference);
      final currentRevision = max(
        0,
        (current.data()?['revision'] as num?)?.toInt() ?? 0,
      );
      if (expectedRevision != null && currentRevision != expectedRevision) {
        throw const AccountCloudConflictException();
      }
      final nextRevision = currentRevision + 1;
      transaction.set(reference, <String, dynamic>{
        'schema': 2,
        'snapshotJson': snapshot,
        'snapshotValueCount': valueCount,
        'revision': nextRevision,
        'deviceInstallationId': installationId,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'appVersion': AppBuildInfo.version,
        'clientUpdatedAt': DateTime.now().toUtc().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return nextRevision;
    });

    final verified = await reference.get(GetOptions(source: Source.server));
    final verifiedSnapshot = verified.data()?['snapshotJson'];

    if (verifiedSnapshot != snapshot) {
      throw StateError('Bulut kaydı sunucuda doğrulanamadı.');
    }

    await _saveUserLocalSnapshot(
      user.uid,
      snapshot,
      dirty: false,
      revision: revision,
    );
    return revision;
  }

  Future<void> _saveUserLocalSnapshot(
    String uid,
    String snapshot, {
    required bool dirty,
    int? revision,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_userSnapshotKey(uid), snapshot);
    await preferences.setBool(_userDirtyKey(uid), dirty);
    if (revision != null) {
      await preferences.setInt(_userRevisionKey(uid), revision);
    }
  }

  Future<void> _syncNow({required bool manual}) async {
    final user = _auth?.currentUser;

    if (user == null || _firestore == null || _syncing || _deleting) {
      return;
    }

    _syncing = true;

    if (manual) {
      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        busy: true,
        lastSyncedAt: state.value.lastSyncedAt,
      );
    }

    try {
      final snapshot = await AccountLocalSnapshot.capture();
      final valueCount = AccountLocalSnapshot.valueCount(snapshot);
      final preferences = await SharedPreferences.getInstance();
      final expectedRevision =
          preferences.getInt(_userRevisionKey(user.uid)) ?? 0;

      await _saveUserLocalSnapshot(user.uid, snapshot, dirty: true);

      await _writeRemoteSnapshot(
        user,
        snapshot,
        expectedRevision: expectedRevision,
      );

      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        message: 'Buluta $valueCount kayıt yüklendi ve doğrulandı.',
        lastSyncedAt: DateTime.now(),
      );
    } on AccountCloudConflictException {
      final remote = await _loadRemoteRecord(user.uid);
      final local = await AccountLocalSnapshot.capture();
      if (remote != null) {
        await _publishConflict(
          user: user,
          localSnapshot: local,
          localRevision:
              (await SharedPreferences.getInstance()).getInt(
                _userRevisionKey(user.uid),
              ) ??
              0,
          remote: remote,
        );
      }
    } catch (_) {
      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        message:
            'Bulut eşitlemesi tamamlanamadı. '
            'Telefondaki kayıt korunuyor.',
        lastSyncedAt: state.value.lastSyncedAt,
      );
    } finally {
      _syncing = false;
    }
  }

  Future<void> _publishConflict({
    required User user,
    required String localSnapshot,
    required int localRevision,
    required CloudSnapshotRecord remote,
  }) async {
    state.value = AccountSessionState(
      mode: AccountMode.google,
      firebaseReady: true,
      user: user,
      message: 'İki cihazda farklı kayıt bulundu. Seçim yapmalısın.',
      lastSyncedAt: state.value.lastSyncedAt,
      conflict: AccountCloudConflict(
        localSnapshot: localSnapshot,
        remoteSnapshot: remote.snapshot,
        localRevision: localRevision,
        remoteRevision: remote.revision,
        localValueCount: AccountLocalSnapshot.valueCount(localSnapshot),
        remoteValueCount: AccountLocalSnapshot.valueCount(remote.snapshot),
        localCapturedAt: DateTime.now(),
        remoteUpdatedAt: remote.updatedAt,
      ),
    );
  }

  Future<void> _resolveConflict({required bool useCloud}) async {
    final user = _auth?.currentUser;
    final conflict = state.value.conflict;
    if (user == null || conflict == null) return;

    state.value = AccountSessionState(
      mode: AccountMode.google,
      firebaseReady: true,
      user: user,
      busy: true,
      conflict: conflict,
    );

    try {
      if (useCloud) {
        await AccountLocalSnapshot.restore(conflict.remoteSnapshot);
        await _saveUserLocalSnapshot(
          user.uid,
          conflict.remoteSnapshot,
          dirty: false,
          revision: conflict.remoteRevision,
        );
      } else {
        await AccountLocalSnapshot.restore(conflict.localSnapshot);
        await _writeRemoteSnapshot(
          user,
          conflict.localSnapshot,
          expectedRevision: conflict.remoteRevision,
        );
      }
      await _refreshGameServices();
      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        message:
            useCloud ? 'Bulut kaydı seçildi.' : 'Bu telefonun kaydı seçildi.',
        lastSyncedAt: DateTime.now(),
      );
    } catch (_) {
      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: user,
        conflict: conflict,
        message:
            'Kayıt seçimi tamamlanamadı. Veriler korunuyor; tekrar deneyebilirsin.',
      );
    }
  }

  Future<void> _deleteAccountAndCloudData() async {
    final user = _auth?.currentUser;

    if (user == null ||
        _firestore == null ||
        _googleSignIn == null ||
        _deleting) {
      return;
    }

    _deleting = true;

    state.value = AccountSessionState(
      mode: AccountMode.google,
      firebaseReady: true,
      user: user,
      busy: true,
      lastSyncedAt: state.value.lastSyncedAt,
    );

    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn!.authenticate();

      if (googleUser == null) {
        throw StateError('Hesap silme doğrulaması iptal edildi.');
      }

      final idToken = googleUser.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google doğrulama anahtarı alınamadı.');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      await user.reauthenticateWithCredential(credential);
      final deletion = await SecureCallableService.call(
        'requestAccountDeletion',
      );
      if (deletion['status'] != 'complete') {
        throw StateError('Sunucu hesap silme işlemini tamamlamadı.');
      }

      final finalization = await AccountDeletionSessionFinalizer.run(
        localCleanupTasks: <Future<void> Function()>[
          () async {
            final preferences = await SharedPreferences.getInstance();
            await preferences.remove(_userSnapshotKey(user.uid));
            await preferences.remove(_userDirtyKey(user.uid));
            await preferences.remove(_guestSnapshotKey);
            await preferences.setBool(_guestSelectedKey, true);
          },
          AccountLocalSnapshot.clearGameData,
          QuestionFeedbackService.clearLocalDataForAccountDeletion,
          () async => PlayerUsernameService.resetSession(),
          _refreshGameServices,
        ],
        firebaseSignOut: () async => _auth?.signOut(),
        googleSignOut: () async => _googleSignIn?.signOut(),
      );

      state.value = AccountSessionState(
        mode: AccountMode.guest,
        firebaseReady: true,
        message:
            finalization.isPartial
                ? 'Hesap ve bulut verileri silindi. Bazı yerel veriler '
                    'temizlenemedi; bunları Android uygulama ayarlarından '
                    'temizleyebilirsin. Misafir modunda devam ediliyor.'
                : 'Hesap ve bulut verileri kalıcı olarak silindi.',
      );
    } catch (error) {
      state.value = AccountSessionState(
        mode: AccountMode.google,
        firebaseReady: true,
        user: _auth?.currentUser ?? user,
        message: _deletionFriendlyError(error),
        lastSyncedAt: state.value.lastSyncedAt,
      );
    } finally {
      _deleting = false;
    }
  }

  Future<void> _signOut() async {
    final user = _auth?.currentUser;

    if (user == null) {
      await _continueAsGuest();
      return;
    }

    state.value = AccountSessionState(
      mode: AccountMode.google,
      firebaseReady: true,
      user: user,
      busy: true,
      lastSyncedAt: state.value.lastSyncedAt,
    );

    try {
      await _syncNow(manual: false);
    } catch (_) {
      // Çıkış, eşitleme hatası yüzünden kilitlenmemeli.
    }

    final accountSnapshot = await AccountLocalSnapshot.capture();

    await _saveUserLocalSnapshot(user.uid, accountSnapshot, dirty: false);

    await _auth?.signOut();
    await _googleSignIn?.signOut();
    PlayerUsernameService.resetSession();

    final preferences = await SharedPreferences.getInstance();
    final guestSnapshot = preferences.getString(_guestSnapshotKey);

    if (guestSnapshot != null && guestSnapshot.isNotEmpty) {
      await AccountLocalSnapshot.restore(guestSnapshot);
    } else {
      await AccountLocalSnapshot.clearGameData();
    }

    await GameSaveService.sanitizeGuestScope();
    await preferences.setBool(_guestSelectedKey, true);
    await _refreshGameServices();

    state.value = const AccountSessionState(
      mode: AccountMode.guest,
      firebaseReady: true,
    );
  }

  Future<void> _refreshGameServices() async {
    try {
      await XpProgressService.initialize();
    } catch (_) {}

    try {
      await GameplayBoostSettingsService.initialize();
    } catch (_) {}

    try {
      await RetentionProgressService.initialize();
    } catch (_) {}

    try {
      await VisualCollectionService.initialize();
    } catch (_) {}

    try {
      await AppPreferencesService.initialize();
    } catch (_) {}
  }

  String _deletionFriendlyError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('iptal') ||
        text.contains('canceled') ||
        text.contains('cancelled')) {
      return 'Hesap silme doğrulaması iptal edildi.';
    }

    if (text.contains('network') ||
        text.contains('socket') ||
        text.contains('timeout')) {
      return 'Hesap silinemedi. İnternet bağlantını kontrol et.';
    }

    if (text.contains('requires-recent-login')) {
      return 'Güvenlik için Google hesabını yeniden doğrulayıp '
          'tekrar dene.';
    }

    return 'Hesap silme tamamlanamadı. '
        'BilgiRotasi10@gmail.com adresinden destek alabilirsin.';
  }

  String _userSnapshotKey(String uid) {
    return 'bilgi_rotasi_account_user_snapshot_$uid';
  }

  String _userDirtyKey(String uid) {
    return 'bilgi_rotasi_account_user_dirty_$uid';
  }

  String _userRevisionKey(String uid) {
    return 'bilgi_rotasi_account_user_revision_$uid';
  }

  Future<String> _installationId() async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(_installationIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final value =
        'device-${DateTime.now().microsecondsSinceEpoch}-'
        '${random.nextInt(1 << 32)}';
    await preferences.setString(_installationIdKey, value);
    return value;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      unawaited(_syncNow(manual: false));
    }
  }
}

class AccountConflictSummary {
  const AccountConflictSummary({
    required this.valueCount,
    required this.totalXp,
    required this.level,
    required this.saveCount,
  });

  final int valueCount;
  final int totalXp;
  final int level;
  final int saveCount;

  factory AccountConflictSummary.fromSnapshot(String snapshot) {
    final values = AccountSnapshotCodec.decode(snapshot);
    var totalXp = 0;
    final rawXp = values['bilgi_rotasi_xp_progress_v1'];
    if (rawXp is String) {
      try {
        final decoded = jsonDecode(rawXp);
        if (decoded is Map) {
          totalXp = max(0, (decoded['totalXp'] as num?)?.toInt() ?? 0);
        }
      } catch (_) {}
    }
    return AccountConflictSummary(
      valueCount: values.length,
      totalXp: totalXp,
      level: XpProgressService.snapshot(totalXp).level,
      saveCount:
          values.keys
              .where(
                (key) =>
                    key.contains('saved_game') || key.contains('game_save'),
              )
              .length,
    );
  }
}

class AccountCloudConflictScreen extends StatelessWidget {
  const AccountCloudConflictScreen({required this.conflict, super.key});

  final AccountCloudConflict conflict;

  @override
  Widget build(BuildContext context) {
    final local = AccountConflictSummary.fromSnapshot(conflict.localSnapshot);
    final remote = AccountConflictSummary.fromSnapshot(conflict.remoteSnapshot);
    return Scaffold(
      appBar: AppBar(title: const Text('Bulut kaydı çakışması')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const Text(
            'İki cihazda farklı ilerleme bulundu. Eski kayıt otomatik olarak '
            'yenisinin üzerine yazılmadı. Devam etmek istediğin kaydı seç.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          _summaryCard(
            title: 'Bu telefonun kaydı',
            summary: local,
            revision: conflict.localRevision,
            updatedAt: conflict.localCapturedAt,
          ),
          const SizedBox(height: 12),
          _summaryCard(
            title: 'Bulut kaydı',
            summary: remote,
            revision: conflict.remoteRevision,
            updatedAt: conflict.remoteUpdatedAt,
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed:
                () => AccountCloudService.resolveConflict(useCloud: false),
            child: const Text('Bu telefonun kaydını kullan'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed:
                () => AccountCloudService.resolveConflict(useCloud: true),
            child: const Text('Bulut kaydını kullan'),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required AccountConflictSummary summary,
    required int revision,
    DateTime? updatedAt,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.totalXp} XP • Seviye ${summary.level}\n'
              '${summary.saveCount} kayıt • ${summary.valueCount} veri alanı\n'
              'Revision $revision'
              '${updatedAt == null ? '' : '\nSon oynama/eşitleme: ${updatedAt.toLocal()}'}',
            ),
          ],
        ),
      ),
    );
  }
}

class AccountGate extends StatelessWidget {
  const AccountGate({required this.questionBank, super.key});

  final QuestionBank questionBank;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountSessionState>(
      valueListenable: AccountCloudService.state,
      builder: (context, session, _) {
        if (session.mode == AccountMode.undecided) {
          return const AccountWelcomeScreen();
        }

        if (session.conflict != null) {
          return AccountCloudConflictScreen(conflict: session.conflict!);
        }

        if (session.signedIn) {
          return PlayerUsernameGate(
            key: ValueKey<String>('username:${session.sessionKey}'),
            questionBank: questionBank,
            ownerUid: session.user?.uid,
          );
        }

        return ProductModeEntryScreen(
          key: ValueKey<String>(session.sessionKey),
          questionBank: questionBank,
        );
      },
    );
  }
}

class AccountWelcomeScreen extends StatelessWidget {
  const AccountWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountSessionState>(
      valueListenable: AccountCloudService.state,
      builder: (context, session, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
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
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/branding/splash_logo.png',
                          width: 116,
                          height: 116,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'BİLGİ ROTASI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'İlerlemeni bu telefonda tutabilir '
                          'veya Google hesabınla buluta '
                          'yedekleyebilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFD7F6F2),
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 26),
                        FilledButton.icon(
                          onPressed:
                              session.busy || !session.firebaseReady
                                  ? null
                                  : AccountCloudService.signInWithGoogle,
                          icon:
                              session.busy
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                  : const Icon(Icons.account_circle_rounded),
                          label: const Text('Google ile giriş yap'),
                        ),
                        const SizedBox(height: 11),
                        OutlinedButton.icon(
                          onPressed:
                              session.busy
                                  ? null
                                  : AccountCloudService.continueAsGuest,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0x88FFFFFF)),
                            minimumSize: const Size.fromHeight(54),
                          ),
                          icon: const Icon(Icons.person_outline_rounded),
                          label: const Text('Misafir olarak devam et'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Misafir kullanımında Günlük Görev '
                          'gösterilmez ve ilerleme yalnızca '
                          'bu telefonda saklanır.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFB9AEC2),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        if (session.message != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            session.message!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFD27A),
                              fontWeight: FontWeight.w700,
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
        );
      },
    );
  }
}

class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountSessionState>(
      valueListenable: AccountCloudService.state,
      builder: (context, session, _) {
        final signedIn = session.signedIn;
        final user = session.user;
        final username = PlayerUsernameService.currentUsername;
        final title =
            signedIn
                ? username != null
                    ? '@$username'
                    : 'Kullanıcı adı hazırlanıyor'
                : 'Misafir';
        final subtitle =
            signedIn
                ? (user?.email ?? 'Bulut kaydı etkin')
                : 'İlerleme yalnızca bu telefonda';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0x16FFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  signedIn ? const Color(0x665EEAD4) : const Color(0x44FFFFFF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      signedIn
                          ? const Color(0x2232D5C5)
                          : const Color(0x22FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  signedIn
                      ? Icons.cloud_done_rounded
                      : Icons.person_outline_rounded,
                  color: signedIn ? const Color(0xFF67E8D8) : Colors.white,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFCFC6D6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (session.busy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Color(0xFFFFE082),
                  ),
                )
              else
                TextButton(
                  onPressed:
                      signedIn
                          ? AccountCloudService.syncNow
                          : session.firebaseReady
                          ? AccountCloudService.signInWithGoogle
                          : null,
                  child: Text(signedIn ? 'Eşitle' : 'Giriş yap'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountSessionState>(
      valueListenable: AccountCloudService.state,
      builder: (context, session, _) {
        final signedIn = session.signedIn;
        final user = session.user;

        return Scaffold(
          appBar: AppBar(title: const Text('Hesap & Bulut Kaydı')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Icon(
                        signedIn
                            ? Icons.cloud_done_rounded
                            : Icons.person_outline_rounded,
                        size: 54,
                        color: const Color(0xFF155E75),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        signedIn
                            ? PlayerUsernameService.currentUsername != null
                                ? '@${PlayerUsernameService.currentUsername}'
                                : 'Kullanıcı adı belirlenmedi'
                            : 'Misafir kullanıcı',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (signedIn &&
                          user?.displayName?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Google hesabı: ${user!.displayName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (signedIn && user?.email != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          user!.email!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Bu bilgiler yalnızca sana görünür.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        signedIn
                            ? 'XP, başarımlar, kayıtlı oyun, '
                                'temalar ve tercihler buluta '
                                'yedeklenir.'
                            : 'İlerleme yalnızca bu telefonda '
                                'saklanır. Günlük Görev '
                                'gösterilmez.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      if (signedIn) ...[
                        OutlinedButton.icon(
                          onPressed:
                              session.busy
                                  ? null
                                  : () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                const PlayerUsernameSetupScreen(
                                                  allowBack: true,
                                                ),
                                      ),
                                    );
                                  },
                          icon: const Icon(Icons.alternate_email_rounded),
                          label: const Text('Kullanıcı adını değiştir'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed:
                              session.busy
                                  ? null
                                  : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const AccountDataViewScreen(),
                                    ),
                                  ),
                          icon: const Icon(Icons.data_object_rounded),
                          label: const Text('Verilerimi görüntüle'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed:
                              session.busy
                                  ? null
                                  : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const BlockedPlayersScreen(),
                                    ),
                                  ),
                          icon: const Icon(Icons.person_off_outlined),
                          label: const Text('Engellenen oyuncular'),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed:
                              session.busy ? null : AccountCloudService.syncNow,
                          icon: const Icon(Icons.sync_rounded),
                          label: const Text('Şimdi eşitle'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed:
                              session.busy ? null : AccountCloudService.signOut,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Hesaptan çık'),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed:
                              session.busy
                                  ? null
                                  : () => _confirmAccountDeletion(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFB91C1C),
                          ),
                          icon: const Icon(Icons.delete_forever_rounded),
                          label: const Text('Hesabı ve bulut verilerini sil'),
                        ),
                      ] else
                        FilledButton.icon(
                          onPressed:
                              session.busy || !session.firebaseReady
                                  ? null
                                  : AccountCloudService.signInWithGoogle,
                          icon: const Icon(Icons.account_circle_rounded),
                          label: const Text('Google ile giriş yap'),
                        ),
                      if (session.message != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          session.message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Hesaptan çıkıldığında Google hesabına '
                    'ait kayıt bulutta kalır ve telefondaki '
                    'misafir kaydı geri yüklenir. Böylece '
                    'hesapların ilerlemeleri birbirine '
                    'karışmaz.',
                    style: TextStyle(height: 1.45),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmAccountDeletion(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFB91C1C),
                size: 42,
              ),
              title: const Text('Hesap ve bulut verileri silinsin mi?'),
              content: const Text(
                'Google hesabına bağlı Bilgi Rotası hesabın, '
                'bulut kaydın, XP, başarımlar, kayıtlı oyun, '
                'temalar ve tercihler kalıcı olarak silinecek. '
                'Bu işlem geri alınamaz. Güvenlik için Google '
                'hesabını yeniden doğrulaman istenebilir.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Kalıcı Olarak Sil'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    await AccountCloudService.deleteAccountAndCloudData();
  }
}

class GuestDailyLockedScreen extends StatelessWidget {
  const GuestDailyLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük Görev')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔐', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 14),
                const Text(
                  'Günlük Görev için hesap gerekli',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Google hesabınla giriş yaptığında '
                  'Günlük Görev ve bulut kaydı açılır.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: AccountCloudService.signInWithGoogle,
                  icon: const Icon(Icons.account_circle_rounded),
                  label: const Text('Google ile giriş yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
