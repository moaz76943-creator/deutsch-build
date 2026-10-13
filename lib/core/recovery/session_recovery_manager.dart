import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState {
  final String sessionId;
  final String currentRoute;
  final int lastItemIndex;
  final int timestamp;
  final String sourceLocale;
  final String targetLocale;
  final String semanticVersion;
  final List<String> committedReviewIds;

  SessionState({
    required this.sessionId,
    required this.currentRoute,
    required this.lastItemIndex,
    required this.timestamp,
    this.sourceLocale = '',
    this.targetLocale = '',
    this.semanticVersion = '',
    this.committedReviewIds = const [],
  });

  Map<String, dynamic> toMap() => {
    'session_id': sessionId,
    'current_route': currentRoute,
    'last_item_index': lastItemIndex,
    'timestamp': timestamp,
    'source_locale': sourceLocale,
    'target_locale': targetLocale,
    'semantic_version': semanticVersion,
    'committed_review_ids': committedReviewIds,
  };

  factory SessionState.fromMap(Map<String, dynamic> map) => SessionState(
    sessionId: map['session_id'] as String,
    currentRoute: map['current_route'] as String,
    lastItemIndex: map['last_item_index'] as int,
    timestamp: map['timestamp'] as int,
    sourceLocale: map['source_locale'] as String? ?? '',
    targetLocale: map['target_locale'] as String? ?? '',
    semanticVersion: map['semantic_version'] as String? ?? '',
    committedReviewIds: (map['committed_review_ids'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}

class CheckpointEnvelope {
  final int version;
  final SessionState state;
  final int recoveryAttempts;

  CheckpointEnvelope({
    required this.version,
    required this.state,
    this.recoveryAttempts = 0,
  });

  Map<String, dynamic> toMap() => {
    'version': version,
    'state': state.toMap(),
    'recovery_attempts': recoveryAttempts,
  };

  factory CheckpointEnvelope.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('version')) {
      return CheckpointEnvelope(
        version: map['version'] as int,
        state: SessionState.fromMap(map['state'] as Map<String, dynamic>),
        recoveryAttempts: map['recovery_attempts'] as int? ?? 0,
      );
    } else {
      // Legacy fallback
      return CheckpointEnvelope(
        version: 1,
        state: SessionState.fromMap(map),
        recoveryAttempts: 0,
      );
    }
  }
}

class SessionRecoveryManager {
  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  final SharedPreferences _prefs;
  final int Function() _clock;
  final int maxRecoveryAttempts;
  final int maxCheckpointAgeMs;

  SessionRecoveryManager(
    this._prefs, {
    int Function()? clock,
    this.maxRecoveryAttempts = 3,
    this.maxCheckpointAgeMs = 24 * 60 * 60 * 1000, // 24 hours
  }) : _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  Future<void> persistSession(SessionState state, {int attempts = 0}) async {
    final envelope = CheckpointEnvelope(
      version: 2,
      state: state,
      recoveryAttempts: attempts,
    );
    final rawJson = jsonEncode(envelope.toMap());
    await _prefs.setString(_storageKey, rawJson);
  }

  SessionState? restoreSession({
    String? expectedSourceLocale,
    String? expectedTargetLocale,
    bool Function(String route)? isValidRoute,
  }) {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return null;

    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final envelope = CheckpointEnvelope.fromMap(decoded);

      if (envelope.recoveryAttempts >= maxRecoveryAttempts) {
        _prefs.remove(_storageKey);
        return null;
      }

      final state = envelope.state;

      // Validate core required fields
      if (state.sessionId.isEmpty || state.currentRoute.isEmpty) {
        _prefs.remove(_storageKey);
        return null;
      }

      // Validate language pair identity if requested
      if (expectedSourceLocale != null && expectedTargetLocale != null) {
        if (state.sourceLocale.isNotEmpty &&
            state.targetLocale.isNotEmpty &&
            (state.sourceLocale != expectedSourceLocale ||
                state.targetLocale != expectedTargetLocale)) {
          _prefs.remove(_storageKey);
          return null;
        }
      }

      // Validate checkpoint age
      final currentTimestamp = _clock();
      if (currentTimestamp - state.timestamp > maxCheckpointAgeMs) {
        _prefs.remove(_storageKey);
        return null;
      }

      // Validate route
      if (isValidRoute != null && !isValidRoute(state.currentRoute)) {
        _prefs.remove(_storageKey);
        return null;
      }

      // Increment attempt counter and persist immediately before returning
      persistSession(state, attempts: envelope.recoveryAttempts + 1);

      return state;
    } catch (_) {
      _prefs.remove(_storageKey);
      return null;
    }
  }

  Future<void> clearSession() async {
    await _prefs.remove(_storageKey);
  }
}
