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

  SessionState({
    this.version = 1,
    required this.sessionId,
    required this.currentRoute,
    required this.lastItemIndex,
    required this.timestamp,
    this.languagePairKey,
    this.committedReviewIds = const [],
    this.recoveryAttempts = 0,
    this.sourceLocale = '',
    this.targetLocale = '',
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
    String? sourceLocale,
    String? targetLocale,
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
      );
}

class SessionRecoveryManager {
  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  final SharedPreferences _prefs;
  final int Function()? clock;
  final int maxRecoveryAttempts;

  SessionRecoveryManager(
    this._prefs, {
    this.clock,
    this.maxRecoveryAttempts = 3,
  });

  Future<void> persistSession(SessionState state) async {
    final rawJson = jsonEncode(state.toMap());
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
      final state = SessionState.fromMap(decoded);

      // Validation
      final resolvedClock = clock?.call() ?? currentTimestampSec ?? currentTimestamp ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

      // 1. Check max age (24 hours = 86400 seconds)
      if (resolvedClock - state.timestamp > 86400) {
        clearSession(); // Fire and forget internally since restoreSession is sync
        return null;
      }

      // 2. Check recovery attempts limit
      if (state.recoveryAttempts >= maxRecoveryAttempts) {
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
}
