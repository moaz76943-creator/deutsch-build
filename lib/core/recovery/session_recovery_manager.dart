import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Checkpoint metadata only; SRS progress is owned by its transactional store.
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
        ?.map((item) => item as String).toList(growable: false) ?? const [],
  );
}

class CheckpointEnvelope {
  final int version;
  final SessionState state;
  final int recoveryAttempts;

  const CheckpointEnvelope({
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
    return CheckpointEnvelope(
      version: map['version'] as int,
      state: SessionState.fromMap(map['state'] as Map<String, dynamic>),
      recoveryAttempts: map['recovery_attempts'] as int? ?? 0,
    );
  }
}

class SessionRecoveryManager {
  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  static const int checkpointVersion = 2;
  static const int maxReviewIds = 256;
  static const int maxCheckpointBytes = 64 * 1024;
  // Process-local reservation gate. SharedPreferences is not transactional;
  // duplicate simultaneous callbacks must not both consume the same attempt.
  static bool _recoveryReservationInFlight = false;
  final SharedPreferences _prefs;
  final int Function() _clock;
  final int maxRecoveryAttempts;
  final int maxCheckpointAgeMs;

  SessionRecoveryManager(
    this._prefs, {
    int Function()? clock,
    this.maxRecoveryAttempts = 3,
    this.maxCheckpointAgeMs = 24 * 60 * 60 * 1000,
  }) : _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  bool _valid(SessionState state) {
    if (state.sessionId.trim().isEmpty || state.sessionId.length > 128 ||
        !state.currentRoute.startsWith('/') ||
        state.currentRoute.contains('..') || state.currentRoute.length > 256 ||
        state.lastItemIndex < 0 || state.timestamp <= 0 ||
        state.sourceLocale.isEmpty || state.targetLocale.isEmpty ||
        state.sourceLocale.length > 40 || state.targetLocale.length > 40 ||
        state.semanticVersion.length > 80 ||
        state.committedReviewIds.length > maxReviewIds) {
      return false;
    }
    final seen = <String>{};
    for (final id in state.committedReviewIds) {
      if (id.isEmpty || id.length > 128 || !seen.add(id)) return false;
    }
    return true;
  }

  Future<void> persistSession(SessionState state, {int attempts = 0}) async {
    if (!_valid(state) || attempts < 0 || attempts > maxRecoveryAttempts) {
      throw ArgumentError('Invalid checkpoint metadata');
    }
    final raw = jsonEncode(CheckpointEnvelope(
      version: checkpointVersion,
      state: state,
      recoveryAttempts: attempts,
    ).toMap());
    if (utf8.encode(raw).length > maxCheckpointBytes) {
      throw ArgumentError('Checkpoint exceeds bounded metadata storage');
    }
    if (!await _prefs.setString(_storageKey, raw)) {
      throw StateError('Checkpoint write not confirmed');
    }
  }

  CheckpointEnvelope? _validatedCheckpoint({
    required String? expectedSourceLocale,
    required String? expectedTargetLocale,
    required bool Function(String)? isValidRoute,
  }) {
    // Never auto-restore an unknown pair or an unchecked route.
    if (expectedSourceLocale == null || expectedSourceLocale.isEmpty ||
        expectedTargetLocale == null || expectedTargetLocale.isEmpty ||
        isValidRoute == null || maxRecoveryAttempts <= 0 ||
        maxCheckpointAgeMs <= 0) {
      return null;
    }
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty || utf8.encode(raw).length > maxCheckpointBytes) {
      return null;
    }
    try {
      final env = CheckpointEnvelope.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      final state = env.state;
      final age = _clock() - state.timestamp;
      if (env.version != checkpointVersion ||
          env.recoveryAttempts < 0 ||
          env.recoveryAttempts >= maxRecoveryAttempts ||
          !_valid(state) ||
          state.sourceLocale != expectedSourceLocale ||
          state.targetLocale != expectedTargetLocale ||
          age < 0 || age > maxCheckpointAgeMs ||
          !isValidRoute(state.currentRoute)) {
        return null;
      }
      return env;
    } catch (_) {
      // Keep the checkpoint for diagnosis; never mutate learner progress.
      return null;
    }
  }

  /// Compatibility reader. Read-only, fail-closed: never consumes an attempt
  /// or restores a session without independently supplied pair/route identity.
  SessionState? restoreSession({
    String? expectedSourceLocale,
    String? expectedTargetLocale,
    bool Function(String)? isValidRoute,
  }) => _validatedCheckpoint(
    expectedSourceLocale: expectedSourceLocale,
    expectedTargetLocale: expectedTargetLocale,
    isValidRoute: isValidRoute,
  )?.state;

  /// Reserve an attempt *durably before* presenting the restored session.
  /// Call this for actual recovery rather than the read-only compatibility API.
  Future<SessionState?> restoreAndMarkAttempt({
    required String expectedSourceLocale,
    required String expectedTargetLocale,
    required bool Function(String) isValidRoute,
  }) async {
    // Reserve synchronously before the first await so two UI callbacks
    // cannot independently read the same recovery counter.
    if (_recoveryReservationInFlight) return null;
    _recoveryReservationInFlight = true;
    try {
      final envelope = _validatedCheckpoint(
        expectedSourceLocale: expectedSourceLocale,
        expectedTargetLocale: expectedTargetLocale,
        isValidRoute: isValidRoute,
      );
      if (envelope == null) return null;
      try {
        await persistSession(
          envelope.state,
          attempts: envelope.recoveryAttempts + 1,
        );
      } catch (_) {
        // Never expose a checkpoint when its reservation was not persisted.
        return null;
      }
      return envelope.state;
    } finally {
      _recoveryReservationInFlight = false;
    }
  }

  Future<void> clearSession() async {
    await _prefs.remove(_storageKey);
  }
}
