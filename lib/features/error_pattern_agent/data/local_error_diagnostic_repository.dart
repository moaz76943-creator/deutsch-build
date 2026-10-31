import 'dart:convert';

import '../../../services/preferences_service.dart';
import '../domain/error_diagnostic_repository.dart';
import '../domain/error_pattern_models.dart';

final class LocalErrorDiagnosticRepository
    implements ErrorDiagnosticRepository {
  LocalErrorDiagnosticRepository(this._preferences);

  static final String storageKey = 'error_pattern_diagnostic_entries_v1';
  static final int maxEntries = 500;

  final PreferencesService _preferences;
  Future<void> _writeQueue = Future<void>.value();

  @override
  Future<List<ErrorLogEntry>> loadEntries() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <ErrorLogEntry>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <ErrorLogEntry>[];
      final entries = <ErrorLogEntry>[];
      for (final value in decoded) {
        if (value is! Map) continue;
        final parsed = ErrorLogEntry.fromJson(<String, Object?>{
          for (final item in value.entries)
            if (item.key is String) item.key as String: item.value,
        });
        if (parsed != null) entries.add(parsed);
      }
      entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return List<ErrorLogEntry>.unmodifiable(
        entries.length <= maxEntries
            ? entries
            : entries.sublist(entries.length - maxEntries),
      );
    } on Object {
      return const <ErrorLogEntry>[];
    }
  }

  @override
  Future<void> appendEntry(ErrorLogEntry entry) => _enqueue(() async {
        final entries = <ErrorLogEntry>[...await loadEntries(), entry];
        final bounded = entries.length <= maxEntries
            ? entries
            : entries.sublist(entries.length - maxEntries);
        final payload = jsonEncode(
          bounded.map((item) => item.toJson()).toList(growable: false),
        );
        final saved = await _preferences.setString(storageKey, payload);
        if (!saved) {
          throw StateError('error diagnostic persistence failed');
        }
      });

  @override
  Future<void> clearEntries() => _enqueue(() async {
        final removed = await _preferences.remove(storageKey);
        if (!removed && _preferences.getString(storageKey) != null) {
          throw StateError('error diagnostic clear failed');
        }
      });

  Future<void> _enqueue(Future<void> Function() action) {
    final next = _writeQueue.then((_) => action());
    _writeQueue = next.catchError((_) {});
    return next;
  }
}
