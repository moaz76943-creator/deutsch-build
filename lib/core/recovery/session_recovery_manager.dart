import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState {
<<<<<<< HEAD
  final int version;
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
  final String sessionId;
  final String currentRoute;
  final int lastItemIndex;
  final int timestamp;
<<<<<<< HEAD
  final String? languagePairKey;
  final List<String> committedReviewIds;
  final int recoveryAttempts;

  SessionState({
    this.version = 1,
=======

  SessionState({
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    required this.sessionId,
    required this.currentRoute,
    required this.lastItemIndex,
    required this.timestamp,
<<<<<<< HEAD
    this.languagePairKey,
    this.committedReviewIds = const [],
    this.recoveryAttempts = 0,
  });

  SessionState copyWith({
    int? version,
    String? sessionId,
    String? currentRoute,
    int? lastItemIndex,
    int? timestamp,
    String? languagePairKey,
    List<String>? committedReviewIds,
    int? recoveryAttempts,
  }) {
    return SessionState(
      version: version ?? this.version,
      sessionId: sessionId ?? this.sessionId,
      currentRoute: currentRoute ?? this.currentRoute,
      lastItemIndex: lastItemIndex ?? this.lastItemIndex,
      timestamp: timestamp ?? this.timestamp,
      languagePairKey: languagePairKey ?? this.languagePairKey,
      committedReviewIds: committedReviewIds ?? this.committedReviewIds,
      recoveryAttempts: recoveryAttempts ?? this.recoveryAttempts,
    );
  }

  Map<String, dynamic> toMap() => {
        'version': version,
        'session_id': sessionId,
        'current_route': currentRoute,
        'last_item_index': lastItemIndex,
        'timestamp': timestamp,
        'language_pair_key': languagePairKey,
        'committed_review_ids': committedReviewIds,
        'recovery_attempts': recoveryAttempts,
      };

  factory SessionState.fromMap(Map<String, dynamic> map) => SessionState(
        version: map['version'] as int? ?? 1,
        sessionId: map['session_id'] as String,
        currentRoute: map['current_route'] as String,
        lastItemIndex: map['last_item_index'] as int,
        timestamp: map['timestamp'] as int,
        languagePairKey: map['language_pair_key'] as String?,
        committedReviewIds: (map['committed_review_ids'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        recoveryAttempts: map['recovery_attempts'] as int? ?? 0,
      );
=======
  });

  Map<String, dynamic> toMap() => {
    'session_id': sessionId,
    'current_route': currentRoute,
    'last_item_index': lastItemIndex,
    'timestamp': timestamp,
  };

  factory SessionState.fromMap(Map<String, dynamic> map) => SessionState(
    sessionId: map['session_id'] as String,
    currentRoute: map['current_route'] as String,
    lastItemIndex: map['last_item_index'] as int,
    timestamp: map['timestamp'] as int,
  );
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
}

class SessionRecoveryManager {
  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  final SharedPreferences _prefs;

  SessionRecoveryManager(this._prefs);

  Future<void> persistSession(SessionState state) async {
    final rawJson = jsonEncode(state.toMap());
    await _prefs.setString(_storageKey, rawJson);
  }

<<<<<<< HEAD
  SessionState? restoreSession({
    String? expectedLanguagePairKey,
    bool Function(String route)? isValidRoute,
    bool Function(String pairKey)? isPackAvailable,
    int? currentTimestampSec,
  }) {
=======
  SessionState? restoreSession() {
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
<<<<<<< HEAD
      final state = SessionState.fromMap(decoded);

      // Validation
      final nowSec = currentTimestampSec ??
          (DateTime.now().millisecondsSinceEpoch ~/ 1000);

      // 1. Check max age (24 hours = 86400 seconds)
      if (nowSec - state.timestamp > 86400) {
        clearSession(); // Fire and forget internally since restoreSession is sync
        return null;
      }

      // 2. Check recovery attempts limit (max 3)
      if (state.recoveryAttempts >= 3) {
        clearSession();
        return null;
      }

      // 3. Check language pair match
      if (expectedLanguagePairKey != null && state.languagePairKey != null) {
        if (state.languagePairKey != expectedLanguagePairKey) {
          clearSession();
          return null;
        }
      }

      // 4. Check route valid
      if (isValidRoute != null && !isValidRoute(state.currentRoute)) {
        clearSession();
        return null;
      }

      // 5. Check pack available
      if (isPackAvailable != null &&
          state.languagePairKey != null &&
          !isPackAvailable(state.languagePairKey!)) {
        clearSession();
        return null;
      }

      // Increment recovery attempts to prevent crash loops
      final updatedState =
          state.copyWith(recoveryAttempts: state.recoveryAttempts + 1);
      persistSession(updatedState); // Async call, fire and forget

      return updatedState;
    } catch (_) {
      clearSession();
      return null;
    }
  }

  Future<void> clearSession() async {
    await _prefs.remove(_storageKey);
  }
=======
      return SessionState.fromMap(decoded);
return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _prefs.remove(_storageKey);
  }
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
}
