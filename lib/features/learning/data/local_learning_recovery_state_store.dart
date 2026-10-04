import 'dart:convert';

import '../../../services/preferences_service.dart';
import '../domain/local_learning_recovery_resume.dart';

abstract interface class LocalLearningRecoveryStateStore {
  Future<LocalLearningRecoveryResumeCursor?> loadCursor(String pairKey);
  Future<void> saveCursor(LocalLearningRecoveryResumeCursor cursor);
  Future<void> clearCursor(String pairKey);
  Future<DateTime?> loadLastPromptAt(String pairKey);
  Future<void> markPrompted(String pairKey, DateTime at);
}

/// Stores orchestration-only recovery metadata.
///
/// This store never persists mastery, SRS due dates, scores, XP, streaks, or
/// learner progress. Canonical progress remains owned by LearnerRepository and
/// its pair-scoped progress authority.
final class PreferencesLocalLearningRecoveryStateStore
    implements LocalLearningRecoveryStateStore {
  const PreferencesLocalLearningRecoveryStateStore(this._preferences);

  static const String _cursorPrefix = 'local_learning_recovery_cursor_v1:';
  static const String _promptPrefix = 'local_learning_recovery_prompt_v1:';

  final PreferencesService _preferences;

  @override
  Future<LocalLearningRecoveryResumeCursor?> loadCursor(String pairKey) async {
    final storageKey = _key(_cursorPrefix, pairKey);
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final cursor =
          LocalLearningRecoveryResumeCursor.fromJson(jsonDecode(raw));
      if (cursor == null || cursor.pairKey != pairKey.trim()) {
        await _preferences.remove(storageKey);
        return null;
      }
      return cursor;
    } on FormatException {
      await _preferences.remove(storageKey);
      return null;
    }
  }

  @override
  Future<void> saveCursor(LocalLearningRecoveryResumeCursor cursor) async {
    final written = await _preferences.setString(
      _key(_cursorPrefix, cursor.pairKey),
      jsonEncode(cursor.toJson()),
    );
    if (!written) {
      throw StateError('local_learning_recovery_cursor_write_failed');
    }
  }

  @override
  Future<void> clearCursor(String pairKey) async {
    await _preferences.remove(_key(_cursorPrefix, pairKey));
  }

  @override
  Future<DateTime?> loadLastPromptAt(String pairKey) async {
    final raw = _preferences.getString(_key(_promptPrefix, pairKey));
    return DateTime.tryParse(raw ?? '')?.toUtc();
  }

  @override
  Future<void> markPrompted(String pairKey, DateTime at) async {
    final written = await _preferences.setString(
      _key(_promptPrefix, pairKey),
      at.toUtc().toIso8601String(),
    );
    if (!written) {
      throw StateError('local_learning_recovery_prompt_write_failed');
    }
  }

  static String _key(String prefix, String pairKey) {
    final normalized = pairKey.trim();
    if (normalized.isEmpty || normalized.length > 80) {
      throw ArgumentError.value(pairKey, 'pairKey', 'invalid pair key');
    }
    final encoded =
        base64Url.encode(utf8.encode(normalized)).replaceAll('=', '');
    return '$prefix$encoded';
  }
}
