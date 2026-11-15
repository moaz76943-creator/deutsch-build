import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState {
  final int version;
  final String sessionId;
  final String currentRoute;
  final int lastItemIndex;
  final int timestamp;
  final String? languagePairKey;
  final List<String> committedReviewIds;
  final int recoveryAttempts;
  final String sourceLocale;
  final String targetLocale;
  final String? semanticVersion;

  SessionState({
    this.version = 1,
    required this.sessionId,
    required this.currentRoute,
    required this.lastItemIndex,
    required this.timestamp,
    this.languagePairKey,
    List<String> committedReviewIds = const [],
    this.recoveryAttempts = 0,
    this.sourceLocale = '',
    this.targetLocale = '',
    this.semanticVersion,
  }) : committedReviewIds = List.unmodifiable(committedReviewIds) {
    if (committedReviewIds.toSet().length != committedReviewIds.length) {
      throw ArgumentError('committedReviewIds must not contain duplicates');
    }
  }

  SessionState copyWith({
    int? version,
    String? sessionId,
    String? currentRoute,
    int? lastItemIndex,
    int? timestamp,
    String? languagePairKey,
    List<String>? committedReviewIds,
    int? recoveryAttempts,
    String? sourceLocale,
    String? targetLocale,
    String? semanticVersion,
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
      sourceLocale: sourceLocale ?? this.sourceLocale,
      targetLocale: targetLocale ?? this.targetLocale,
      semanticVersion: semanticVersion ?? this.semanticVersion,
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
        'source_locale': sourceLocale,
        'target_locale': targetLocale,
        if (semanticVersion != null) 'semantic_version': semanticVersion,
      };

  factory SessionState.fromMap(Map<String, dynamic> map) {
    String sourceLoc = map['source_locale'] as String? ?? '';
    String targetLoc = map['target_locale'] as String? ?? '';
    final String? pairKey = map['language_pair_key'] as String?;

    if (pairKey != null && (sourceLoc.isEmpty || targetLoc.isEmpty)) {
        final parts = pairKey.split('_');
        if (parts.isNotEmpty) {
            sourceLoc = parts[0];
            if (parts.length > 1) {
                targetLoc = parts[1];
            }
        }
    }

    return SessionState(
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
        sourceLocale: sourceLoc,
        targetLocale: targetLoc,
        semanticVersion: map['semantic_version'] as String?,
      );
  }
}

class SessionRecoveryManager {
  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  static const int checkpointVersion = 2;

  final SharedPreferences _prefs;
  final int Function()? clock;
  final int maxRecoveryAttempts;

  SessionState? _activeRestoredSession;
  bool _isRestoring = false;

  SessionRecoveryManager(
    this._prefs, {
    this.clock,
    this.maxRecoveryAttempts = 3,
  });

  Future<void> persistSession(SessionState state) async {
    final rawJson = jsonEncode({
      'version': checkpointVersion,
      'state': state.toMap(),
      'recovery_attempts': state.recoveryAttempts,
    });
    await _prefs.setString(_storageKey, rawJson);
  }

  SessionState? restoreSession({
    String? expectedLanguagePairKey,
    bool Function(String route)? isValidRoute,
    bool Function(String pairKey)? isPackAvailable,
    int? currentTimestampSec,
    String? expectedSourceLocale,
    String? expectedTargetLocale,
    int? currentTimestamp,
    bool Function(String route)? isRouteValid,
  }) {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final int v = decoded['version'] as int? ?? 1;

      SessionState state;
      int recoveryAttempts = 0;
      if (v == checkpointVersion && decoded.containsKey('state')) {
        final stateMap = decoded['state'] as Map<String, dynamic>;
        recoveryAttempts = decoded['recovery_attempts'] as int? ?? 0;
        stateMap['recovery_attempts'] = recoveryAttempts;
        state = SessionState.fromMap(stateMap);
      } else {
        state = SessionState.fromMap(decoded);
        recoveryAttempts = state.recoveryAttempts;
      }

      // Validation
      final resolvedClock = clock?.call() ?? currentTimestampSec ?? currentTimestamp ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

      // 1. Check max age (24 hours = 86400 seconds)
      if (resolvedClock - state.timestamp > 86400) {
        clearSession(); // Fire and forget internally since restoreSession is sync
        return null;
      }

      // 2. Check recovery attempts limit
      if (recoveryAttempts >= maxRecoveryAttempts) {
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

      // 3.1 Check expectedSourceLocale and expectedTargetLocale
      if (expectedSourceLocale != null && expectedTargetLocale != null) {
          if (state.sourceLocale != expectedSourceLocale || state.targetLocale != expectedTargetLocale) {
              clearSession();
              return null;
          }
      }

      // 4. Check route valid
      if (isValidRoute != null && !isValidRoute(state.currentRoute)) {
        clearSession();
        return null;
      }

      if (isRouteValid != null && !isRouteValid(state.currentRoute)) {
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
          state.copyWith(recoveryAttempts: recoveryAttempts + 1);

      if (v == checkpointVersion) {
        persistSession(updatedState); // Async call, fire and forget
      } else {
        _prefs.setString(_storageKey, jsonEncode(updatedState.toMap()));
      }

      return updatedState;
    } catch (_) {
      clearSession();
      return null;
    }
  }

  Future<SessionState?> restoreForPair({
    required String expectedSourceLocale,
    required String expectedTargetLocale,
    required String expectedSemanticVersion,
    required bool Function(String route) isValidRoute,
  }) async {
    if (_isRestoring) return null;
    if (_activeRestoredSession != null) return null;
    _isRestoring = true;
    try {
      final rawJson = _prefs.getString(_storageKey);
      if (rawJson == null || rawJson.isEmpty) return null;

      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final int v = decoded['version'] as int? ?? 1;

      if (v != checkpointVersion) {
         return null; // Reject legacy snapshots for activation
      }

      final stateMap = decoded['state'] as Map<String, dynamic>?;
      if (stateMap == null) return null;

      final recoveryAttempts = decoded['recovery_attempts'] as int? ?? 0;
      stateMap['recovery_attempts'] = recoveryAttempts;

      final state = SessionState.fromMap(stateMap);

      final resolvedClock = clock?.call() ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

      if (state.timestamp > resolvedClock) {
         await clearSession();
         return null;
      }

      if (resolvedClock - state.timestamp > 86400) {
         await clearSession();
         return null;
      }

      if (recoveryAttempts >= maxRecoveryAttempts) {
         await clearSession();
         return null;
      }

      if (state.sourceLocale != expectedSourceLocale || state.targetLocale != expectedTargetLocale) {
         await clearSession();
         return null;
      }

      if (state.semanticVersion != expectedSemanticVersion) {
         await clearSession();
         return null;
      }

      if (!isValidRoute(state.currentRoute)) {
         await clearSession();
         return null;
      }

      final updatedState = state.copyWith(recoveryAttempts: recoveryAttempts + 1);
      await persistSession(updatedState);

      _activeRestoredSession = updatedState;
      return updatedState;
    } catch (_) {
      await clearSession();
      return null;
    } finally {
      _isRestoring = false;
    }
  }

  Future<bool> markRestoreStable(String sessionId) async {
    if (_activeRestoredSession == null) return false;
    if (_activeRestoredSession!.sessionId != sessionId) return false;

    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return false;

    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final int v = decoded['version'] as int? ?? 1;

      Map<String, dynamic> stateMap;
      if (v == checkpointVersion && decoded.containsKey('state')) {
        stateMap = decoded['state'] as Map<String, dynamic>;
      } else {
        return false;
      }

      final state = SessionState.fromMap(stateMap);

      if (state.sessionId != sessionId) return false;
      if (state.sourceLocale != _activeRestoredSession!.sourceLocale || state.targetLocale != _activeRestoredSession!.targetLocale) {
        return false;
      }

      final updatedState = state.copyWith(recoveryAttempts: 0);
      await persistSession(updatedState);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearSession() async {
    _activeRestoredSession = null;
    await _prefs.remove(_storageKey);
  }

  bool isReviewCommitted(SessionState state, String reviewId) {
    return state.committedReviewIds.contains(reviewId);
  }
}
