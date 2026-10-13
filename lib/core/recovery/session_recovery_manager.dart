import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Navigation metadata only. SRS transactions are never replayed by recovery.
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
  SessionRecoveryManager(
    this._preferences, {
    int Function()? clock,
    this.maxRecoveryAttempts = 3,
    this.maxCheckpointAgeMs = 24 * 60 * 60 * 1000,
  })  : assert(maxRecoveryAttempts > 0),
        assert(maxCheckpointAgeMs > 0),
        _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  static const int checkpointVersion = 2;
  static const int maxCommittedReviewIds = 256;
  static const int maxCheckpointBytes = 128 * 1024;

  // All managers within this isolate serialize checkpoint read-modify-write.
  // A single resolved tail is retained, rather than an unbounded history.
  static Future<void> _storageTail = Future<void>.value();
  static Future<T> _exclusively<T>(Future<T> Function() operation) async {
    final previous = _storageTail;
    final completion = Completer<void>();
    _storageTail = completion.future;
    await previous;
    try {
      return await operation();
    } finally {
      completion.complete();
    }
  }

  final SharedPreferences _preferences;
  final int Function() _clock;
  final int maxRecoveryAttempts;
  final int maxCheckpointAgeMs;
  SessionState? _activatedState;

  Future<void> persistSession(SessionState state, {int attempts = 0}) =>
      _exclusively(() => _persistUnlocked(state, attempts: attempts));

  Future<void> _persistUnlocked(SessionState state, {int attempts = 0}) async {
    if (!_hasValidCoreFields(state) ||
        state.committedReviewIds.length > maxCommittedReviewIds ||
        attempts < 0) {
      throw ArgumentError('Invalid session checkpoint');
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
    if (utf8.encode(raw).length > maxCheckpointBytes) {
      throw ArgumentError('Session checkpoint exceeds byte limit');
    }
    if (!await _preferences.setString(_storageKey, raw)) {
      throw StateError('Checkpoint persistence was not acknowledged');
    }
  }

  CheckpointEnvelope? _readEnvelope() {
    final raw = _preferences.getString(_storageKey);
    if (raw == null ||
        raw.isEmpty ||
        raw.length > maxCheckpointBytes ||
        utf8.encode(raw).length > maxCheckpointBytes) {
      return null;
    }
    try {
      final parsed = jsonDecode(raw);
      if (parsed is! Map) return null;
      final envelope =
          CheckpointEnvelope.fromMap(Map<String, dynamic>.from(parsed));
      final ids = envelope.state.committedReviewIds;
      if ((envelope.version != 1 && envelope.version != checkpointVersion) ||
          envelope.recoveryAttempts < 0 ||
          !_hasValidCoreFields(envelope.state) ||
          ids.length > maxCommittedReviewIds ||
          ids.any((id) => id.isEmpty || id.length > 128) ||
          ids.toSet().length != ids.length) {
        return null;
      }
      return envelope;
    } catch (_) {
      return null;
    }
  }

  bool _hasValidCoreFields(SessionState state) =>
      state.sessionId.isNotEmpty &&
      state.sessionId.length <= 128 &&
      state.currentRoute.startsWith('/') &&
      state.currentRoute.length <= 256 &&
      state.lastItemIndex >= 0 &&
      state.timestamp > 0;

  /// Compatibility-only inspection. Does not navigate or advance SRS.
  SessionState? restoreSession() => _readEnvelope()?.state;

  /// Activation is strictly pair-scoped and one-shot per manager lifetime.
  /// Durable recovery-attempt accounting completes before the caller receives
  /// any restorable state; simultaneous callers cannot double-navigate.
  Future<SessionState?> restoreForPair({
    required String expectedSourceLocale,
    required String expectedTargetLocale,
    required bool Function(String) isValidRoute,
    String? expectedSemanticVersion,
  }) => _exclusively(() async {
        if (_activatedState != null ||
            expectedSourceLocale.isEmpty ||
            expectedTargetLocale.isEmpty) {
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
          await _persistUnlocked(
            state,
            attempts: envelope.recoveryAttempts + 1,
          );
          _activatedState = state;
          return state;
        } catch (_) {
          // Failed persistence must never lead to navigation.
          return null;
        }
      });

  /// Only the exact, previously activated directed session can acknowledge
  /// a stable restore; a newer checkpoint is never overwritten.
  Future<bool> markRestoreStable(String sessionId) => _exclusively(() async {
        final activated = _activatedState;
        final current = _readEnvelope();
        if (activated == null ||
            current == null ||
            current.version != checkpointVersion ||
            activated.sessionId != sessionId ||
            current.state.sessionId != activated.sessionId ||
            current.state.sourceLocale != activated.sourceLocale ||
            current.state.targetLocale != activated.targetLocale ||
            current.state.semanticVersion != activated.semanticVersion ||
            current.state.timestamp != activated.timestamp) {
          return false;
        }
        try {
          await _persistUnlocked(current.state);
          return true;
        } catch (_) {
          return false;
        }
      });

  Future<void> clearSession() => _exclusively(() async {
        await _preferences.remove(_storageKey);
        _activatedState = null;
      });
}
