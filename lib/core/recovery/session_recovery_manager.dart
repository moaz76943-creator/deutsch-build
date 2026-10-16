import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState {
  final String sessionId;
  final String currentRoute;
  final int lastItemIndex;
  final int timestamp;
  final String? languagePairKey;
  final List<String> committedReviewIds;

  SessionState({
    required this.sessionId,
    required this.currentRoute,
    required this.lastItemIndex,
    required this.timestamp,
    this.languagePairKey,
    this.committedReviewIds = const [],
  });

  Map<String, dynamic> toMap() => {
    'session_id': sessionId,
    'current_route': currentRoute,
    'last_item_index': lastItemIndex,
    'timestamp': timestamp,
    if (languagePairKey != null) 'language_pair_key': languagePairKey,
    'committed_review_ids': committedReviewIds,
  };

  factory SessionState.fromMap(Map<String, dynamic> map) => SessionState(
    sessionId: map['session_id'] as String,
    currentRoute: map['current_route'] as String,
    lastItemIndex: map['last_item_index'] as int,
    timestamp: map['timestamp'] as int,
    languagePairKey: map['language_pair_key'] as String?,
    committedReviewIds: (map['committed_review_ids'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}

class CheckpointEnvelope {
  static const int currentVersion = 2;

  final int version;
  final SessionState state;
  final int recoveryAttempts;

  CheckpointEnvelope({
    this.version = currentVersion,
    required this.state,
    this.recoveryAttempts = 0,
  });

  Map<String, dynamic> toMap() => {
    'version': version,
    'state': state.toMap(),
    'recoveryAttempts': recoveryAttempts,
  };

  factory CheckpointEnvelope.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('version')) {
      return CheckpointEnvelope(
        version: 1,
        state: SessionState.fromMap(map),
        recoveryAttempts: 0,
      );
    }
    return CheckpointEnvelope(
      version: map['version'] as int,
      state: SessionState.fromMap(map['state'] as Map<String, dynamic>),
      recoveryAttempts: map['recoveryAttempts'] as int? ?? 0,
    );
  }
}

class SessionRecoveryManager {
  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  static const int _maxRecoveryAttempts = 3;
  static const Duration _maxCheckpointAge = Duration(hours: 24);

  final SharedPreferences _prefs;

  SessionRecoveryManager(this._prefs);

  Future<void> persistSession(SessionState state) async {
    final envelope = CheckpointEnvelope(state: state, recoveryAttempts: 0);
    final rawJson = jsonEncode(envelope.toMap());
    await _prefs.setString(_storageKey, rawJson);
  }

  SessionState? restoreSession({
    String? expectedLanguagePair,
    List<String>? validRoutes,
    bool Function(String route)? isDestinationValid,
  }) {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return null;

    CheckpointEnvelope envelope;
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      envelope = CheckpointEnvelope.fromMap(decoded);
    } catch (_) {
      clearSession();
      return null;
    }

    final state = envelope.state;

    // Check age
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - state.timestamp > _maxCheckpointAge.inMilliseconds) {
      clearSession();
      return null;
    }

    // Check language pair
    if (expectedLanguagePair != null &&
        state.languagePairKey != null &&
        state.languagePairKey != expectedLanguagePair) {
      clearSession();
      return null;
    }

    // Check invalid destinations / missing screens
    bool isValidRoute = true;
    if (validRoutes != null && !validRoutes.contains(state.currentRoute)) {
      isValidRoute = false;
    }
    if (isDestinationValid != null && !isDestinationValid(state.currentRoute)) {
      isValidRoute = false;
    }

    if (!isValidRoute) {
      clearSession();
      return null;
    }

    // Check attempts
    if (envelope.recoveryAttempts >= _maxRecoveryAttempts) {
      clearSession();
      return null;
    }

    // Increment attempts and save
    final updatedEnvelope = CheckpointEnvelope(
      version: envelope.version,
      state: state,
      recoveryAttempts: envelope.recoveryAttempts + 1,
    );
    _prefs.setString(_storageKey, jsonEncode(updatedEnvelope.toMap()));

    return state;
  }

  Future<void> clearSession() async {
    await _prefs.remove(_storageKey);
  }
}
