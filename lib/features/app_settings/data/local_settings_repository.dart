import 'dart:convert';

import '../domain/learning_preferences.dart';
import '../domain/settings_repository.dart';
import '../domain/storage_metrics.dart';

final class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(
    this._source, {
    DateTime Function()? nowUtc,
  }) : _nowUtc = nowUtc ?? (() => DateTime.now().toUtc());

  static final int _schemaVersion = 1;

  final SettingsLocalDataSource _source;
  final DateTime Function() _nowUtc;

  @override
  Future<LearningPreferences> loadPreferences() async {
    final record = await _readRecord();
    return record.preferences;
  }

  @override
  Future<void> savePreferences(LearningPreferences preferences) async {
    final current = await _readRecord();
    final encoded = _encode(
      preferences: preferences,
      lastCacheClearAt: current.lastCacheClearAt,
    );
    await _source.write(encoded);
  }

  @override
  Future<StorageMetrics> loadStorageMetrics() async {
    final raw = await _source.read();
    if (raw == null || raw.isEmpty) {
      return StorageMetrics(localDataBytes: 0);
    }
    final record = _decode(raw);
    return StorageMetrics(
      localDataBytes: utf8.encode(raw).length,
      lastCacheClearAt: record.lastCacheClearAt,
    );
  }

  @override
  Future<StorageMetrics> clearCache() async {
    final current = await _readRecord();
    final clearedAt = _nowUtc().toUtc();
    final encoded = _encode(
      preferences: current.preferences,
      lastCacheClearAt: clearedAt,
    );
    await _source.write(encoded);
    _source.evictMemoryCache();
    return StorageMetrics(
      localDataBytes: utf8.encode(encoded).length,
      lastCacheClearAt: clearedAt,
    );
  }

  Future<_SettingsRecord> _readRecord() async {
    final raw = await _source.read();
    if (raw == null || raw.trim().isEmpty) {
      return const _SettingsRecord(
        preferences: LearningPreferences(),
      );
    }
    return _decode(raw);
  }

  _SettingsRecord _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const _SettingsRecord(
          preferences: LearningPreferences(),
        );
      }
      final map = <String, Object?>{
        for (final entry in decoded.entries)
          if (entry.key is String) entry.key as String: entry.value,
      };
      if (map['schema_version'] != _schemaVersion) {
        return const _SettingsRecord(
          preferences: LearningPreferences(),
        );
      }

      final speech = _asDouble(map['speech_rate']);
      final scale = _asDouble(map['text_scale_factor']);
      final translation = map['show_automatic_translation'];
      final lastClear = _asUtcDate(map['last_cache_clear_at']);

      return _SettingsRecord(
        preferences: LearningPreferences.normalized(
          speechRate: speech,
          textScaleFactor: scale,
          showAutomaticTranslation:
              translation is bool ? translation : null,
        ),
        lastCacheClearAt: lastClear,
      );
    } on Object {
      return const _SettingsRecord(
        preferences: LearningPreferences(),
      );
    }
  }

  String _encode({
    required LearningPreferences preferences,
    required DateTime? lastCacheClearAt,
  }) {
    return jsonEncode(<String, Object?>{
      'schema_version': _schemaVersion,
      'speech_rate': preferences.speechRate,
      'text_scale_factor': preferences.textScaleFactor,
      'show_automatic_translation':
          preferences.showAutomaticTranslation,
      'last_cache_clear_at': lastCacheClearAt?.toUtc().toIso8601String(),
    });
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _asUtcDate(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed?.toUtc();
  }
}

final class _SettingsRecord {
  const _SettingsRecord({
    required this.preferences,
    this.lastCacheClearAt,
  });

  final LearningPreferences preferences;
  final DateTime? lastCacheClearAt;
}
