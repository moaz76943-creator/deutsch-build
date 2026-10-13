import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Serializable navigation-only checkpoint; this is not the SRS transaction
/// authority and never replays a review as a side effect of restoration.
class SessionState {
  SessionState({
    required this.sessionId,
    required this.currentRoute,
    required this.lastItemIndex,
    required this.timestamp,
    this.sourceLocale = '',
    this.targetLocale = '',
    this.semanticVersion = '',
    List<String> committedReviewIds = const <String>[],
  }) : committedReviewIds = List<String>.unmodifiable(committedReviewIds);

  final String sessionId;
  final String currentRoute;
  final int lastItemIndex;
  final int timestamp;
  final String sourceLocale;
  final String targetLocale;
  final String semanticVersion;
  final List<String> committedReviewIds;

  Map<String, dynamic> toMap() => <String, dynamic>{
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
        committedReviewIds:
            (map['committed_review_ids'] as List<dynamic>? ?? const <dynamic>[])
                .cast<String>(),
      );
}

class CheckpointEnvelope {
  const CheckpointEnvelope({
    required this.version,
    required this.state,
    required this.recoveryAttempts,
  });

  final int version;
  final SessionState state;
  final int recoveryAttempts;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'version': version,
        'state': state.toMap(),
        'recovery_attempts': recoveryAttempts,
      };

  factory CheckpointEnvelope.fromMap(Map<String, dynamic> value) {
    if (!value.containsKey('version')) {
      return CheckpointEnvelope(
        version: 1,
        state: SessionState.fromMap(value),
        recoveryAttempts: 0,
      );
    }
    return CheckpointEnvelope(
      version: value['version'] as int,
      state: SessionState.fromMap(
        Map<String, dynamic>.from(value['state'] as Map),
      ),
      recoveryAttempts: value['recovery_attempts'] as int? ?? 0,
    );
  }
}

class SessionRecoveryManager {
  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  static const int checkpointVersion = 2;
  static const int maxCommittedReviewIds = 256;
  static const int maxCheckpointBytes = 128 * 1024;

  SessionRecoveryManager(
    this._preferences, {
    int Function()? clock,
    this.maxRecoveryAttempts = 3,
    this.maxCheckpointAgeMs = 24 * 60 * 60 * 1000,
  })  : assert(maxRecoveryAttempts > 0),
        assert(maxCheckpointAgeMs > 0),
        _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  final SharedPreferences _preferences;
  final int Function() _clock;
  final int maxRecoveryAttempts;
  final int maxCheckpointAgeMs;

  Future<void> persistSession(SessionState state, {int attempts = 0}) async {
    if (!_hasValidCoreFields(state) ||
        state.committedReviewIds.length > maxCommittedReviewIds ||
        attempts < 0) {
      throw ArgumentError('Invalid or oversized session checkpoint');
    }
    final seen = <String>{};
    for (final id in state.committedReviewIds) {
      if (id.isEmpty || id.length > 128 || !seen.add(id)) {
        throw ArgumentError('Invalid or duplicate committed review ID');
      }
    }
    final raw = jsonEncode(CheckpointEnvelope(
      version: checkpointVersion,
      state: state,
      recoveryAttempts: attempts,
    ).toMap());
    if (raw.length > maxCheckpointBytes) {
      throw ArgumentError('Session checkpoint exceeds size limit');
    }
    if (!await _preferences.setString(_storageKey, raw)) {
      throw StateError('Checkpoint persistence was not acknowledged');
    }
  }

  CheckpointEnvelope? _readEnvelope() {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty || raw.length > maxCheckpointBytes) {
      return null;
    }
    try {
      final parsed = jsonDecode(raw);
      if (parsed is! Map) return null;
      final envelope =
          CheckpointEnvelope.fromMap(Map<String, dynamic>.from(parsed));
      if ((envelope.version != 1 && envelope.version != checkpointVersion) ||
          envelope.recoveryAttempts < 0 ||
          !_hasValidCoreFields(envelope.state) ||
          envelope.state.committedReviewIds.length > maxCommittedReviewIds ||\n          envelope.state.committedReviewIds.any((id) =>\n              id.isEmpty || id.length > 128) ||\n          envelope.state.committedReviewIds.toSet().length !=\n              envelope.state.committedReviewIds.length) {
        return null;
      }
      return envelope;
    } catch (_) {
      return null;
    }
  }

  bool _hasValidCoreFields(SessionState state) {
    return state.sessionId.isNotEmpty &&
        state.sessionId.length <= 128 &&
        state.currentRoute.startsWith('/') &&
        state.currentRoute.length <= 256 &&
        state.lastItemIndex >= 0 &&
        state.timestamp > 0;
  }

  /// Compatibility read only. Startup probes may inspect legacy metadata, but
  /// must NEVER navigate to it or replay SRS using this untrusted read.
  SessionState? restoreSession() => _readEnvelope()?.state;

  /// The sole activation API. Requires a complete directed language identity
  /// and a caller-owned route validator. The recovery attempt is durably
  /// recorded BEFORE returning any session for navigation.
  Future<SessionState?> restoreForPair({
    required String expectedSourceLocale,
    required String expectedTargetLocale,
    required bool Function(String) isValidRoute,
    String? expectedSemanticVersion,
  }) async {
    if (expectedSourceLocale.isEmpty || expectedTargetLocale.isEmpty) {
      return null;
    }
    final envelope = _readEnvelope();
    if (envelope == null ||
        envelope.version != checkpointVersion ||
        envelope.recoveryAttempts >= maxRecoveryAttempts) {
      return null;
    }
    final state = envelope.state;
    if (state.sourceLocale.isEmpty ||
        state.targetLocale.isEmpty ||
        state.sourceLocale != expectedSourceLocale ||
        state.targetLocale != expectedTargetLocale ||
        (expectedSemanticVersion != null &&
            (state.semanticVersion.isEmpty ||
                state.semanticVersion != expectedSemanticVersion)) ||
        !isValidRoute(state.currentRoute)) {
      return null;
    }
    final age = _clock() - state.timestamp;
    if (age < 0 || age > maxCheckpointAgeMs) return null;

    try {
      await persistSession(state, attempts: envelope.recoveryAttempts + 1);
      return state;
    } catch (_) {
      // No checkpoint durability => no navigation/resume side effect.
      return null;
    }
  }

  /// A successful UI handoff may reset the attempt ledger, but only if the
  /// same session is still current; stale completions cannot rewrite newer
  /// language-pair checkpoints.
  Future<bool> markRestoreStable(String sessionId) async {
    final current = _readEnvelope();
    if (current == null ||
        current.version != checkpointVersion ||
        current.state.sessionId != sessionId) return false;
    try {
      await persistSession(current.state);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearSession() async {
    await _preferences.remove(_storageKey);
  }
}
