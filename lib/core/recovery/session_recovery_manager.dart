import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState {
  final String sessionId;
  final String currentRoute;
  final int lastItemIndex;
  final int timestamp;
  final String languagePairKey;
  final List<String> committedReviewIds;

  SessionState({
    required this.sessionId,
    required this.currentRoute,
    required this.lastItemIndex,
    required this.timestamp,
    this.languagePairKey = 'unknown',
    this.committedReviewIds = const [],
  });

  bool isReviewCommitted(String reviewId) {
    return committedReviewIds.contains(reviewId);
  }

  Map<String, dynamic> toMap() => {
    'session_id': sessionId,
    'current_route': currentRoute,
    'last_item_index': lastItemIndex,
    'timestamp': timestamp,
    'language_pair_key': languagePairKey,
    'committed_review_ids': committedReviewIds,
  };

  factory SessionState.fromMap(Map<String, dynamic> map) => SessionState(
    sessionId: map['session_id'] as String? ?? '',
    currentRoute: map['current_route'] as String? ?? '',
    lastItemIndex: map['last_item_index'] as int? ?? 0,
    timestamp: map['timestamp'] as int? ?? 0,
    languagePairKey: map['language_pair_key'] as String? ?? 'unknown',
    committedReviewIds: (map['committed_review_ids'] as List<dynamic>?)
            ?.map((e) => e.toString())
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
    required this.recoveryAttempts,
  });

  Map<String, dynamic> toMap() => {
    'version': version,
    'state': state.toMap(),
    'recovery_attempts': recoveryAttempts,
  };

  factory CheckpointEnvelope.fromMap(Map<String, dynamic> map) {
    return CheckpointEnvelope(
      version: map['version'] as int? ?? 1,
      state: SessionState.fromMap(map['state'] as Map<String, dynamic>),
      recoveryAttempts: map['recovery_attempts'] as int? ?? 0,
    );
  }
}

class SessionRecoveryManager {
  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  static const int _maxRecoveryAttempts = 3;
  static const int _maxStaleSeconds = 86400; // 24 hours
  final SharedPreferences _prefs;

  SessionRecoveryManager(this._prefs);

  Future<void> persistSession(SessionState state) async {
    final envelope = CheckpointEnvelope(
      version: 2,
      state: state,
      recoveryAttempts: 0,
    );
    final rawJson = jsonEncode(envelope.toMap());
    await _prefs.setString(_storageKey, rawJson);
  }

  Future<SessionState?> restoreSession({
    required String expectedLanguagePairKey,
    required int currentTimestamp,
    required bool Function(String) isRouteValid,
  }) async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return null;

    CheckpointEnvelope envelope;
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;

      if (decoded.containsKey('version') && decoded.containsKey('state')) {
        envelope = CheckpointEnvelope.fromMap(decoded);
      } else {
        final state = SessionState.fromMap(decoded);
        envelope = CheckpointEnvelope(version: 1, state: state, recoveryAttempts: 0);
      }
    } catch (_) {
      return null;
    }

    if (envelope.state.sessionId.isEmpty || envelope.state.currentRoute.isEmpty) {
      return null;
    }

    if (envelope.recoveryAttempts >= _maxRecoveryAttempts) {
      return null;
    }

    if (envelope.state.languagePairKey != 'unknown' && envelope.state.languagePairKey != expectedLanguagePairKey) {
        return null;
    }

    if (currentTimestamp - envelope.state.timestamp > _maxStaleSeconds) {
      return null;
    }

    if (!isRouteValid(envelope.state.currentRoute)) {
      return null;
    }

    final newEnvelope = CheckpointEnvelope(
      version: envelope.version,
      state: envelope.state,
      recoveryAttempts: envelope.recoveryAttempts + 1,
    );
    await _prefs.setString(_storageKey, jsonEncode(newEnvelope.toMap()));

    return envelope.state;
  }

  Future<void> clearSession() async {
    await _prefs.remove(_storageKey);
  }
}
