import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:deutsch_bilarabi/services/play_integrity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adaptive Review Engine for Low-Stress Cognitive Load Sessions.
///
/// Personalizes spaced review based on error patterns (gender, plurals, pronunciation).
/// Implements a simplified FSRS-inspired scheduler for better long-term retention.
/// Advanced modes (detailed analytics, hard packs) are gated by Play Integrity (offline-safe).
/// Sensitive metrics and card schedules stored encrypted via FlutterSecureStorage.
/// Offline-first; no network required. Client-side gating is best-effort only.
class AdaptiveReviewEngine {
  static final AdaptiveReviewEngine instance = AdaptiveReviewEngine._();
  AdaptiveReviewEngine._();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _errorPatternsKey = 'adaptive_error_patterns_v1';
  static const _sessionMetricsKey = 'adaptive_session_metrics_v1';
  static const _cardSchedulesKey = 'adaptive_card_schedules_v1';

  Map<String, dynamic> _safeJsonDecode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {};
    } catch (e) {
      debugPrint('[AdaptiveReview] Malformed JSON recovered: $e');
      return {};
    }
  }

  /// Check if advanced adaptive features are available.
  /// Offline-safe: returns false when no integrity token (expected in release).
  Future<bool> isAdvancedModeAvailable() async {
    final token = await PlayIntegrityService.requestIntegrityToken();
    if (token == null || token.isEmpty) {
      debugPrint('[AdaptiveReview] Integrity token unavailable – advanced mode gated (offline design).');
      return PlayIntegrityService.isLikelyGenuineDevice(); // Weak local fallback.
    }
    // Production: send token to backend for verification before enabling advanced.
    debugPrint('[AdaptiveReview] Integrity token obtained (len=${token.length}).');
    return true;
  }

  /// Record an error pattern for personalization (e.g. 'gender_der', 'plural_s').
  Future<void> recordErrorPattern(String pattern, {int weight = 1}) async {
    if (pattern.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_errorPatternsKey);
    final Map<String, dynamic> patterns = _safeJsonDecode(raw);
    patterns[pattern] = (patterns[pattern] as int? ?? 0) + weight;
    await prefs.setString(_errorPatternsKey, jsonEncode(patterns));

    await _secureStorage.write(
      key: 'last_error_pattern',
      value: pattern,
    );
  }

  /// Get prioritized review items based on error patterns.
  Future<List<String>> getPriorityPatterns({int limit = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_errorPatternsKey);
    final Map<String, dynamic> patterns = _safeJsonDecode(raw);
    final sorted = patterns.entries.toList()
      ..sort((a, b) => ((b.value as num?) ?? 0).compareTo((a.value as num?) ?? 0));
    return sorted.take(limit).map((e) => e.key.toString()).toList();
  }

  /// Simplified FSRS-like schedule for a card.
  /// Stores next review date and stability in encrypted storage.
  Future<void> scheduleCard(String cardId, {required bool recalled, double difficulty = 0.5}) async {
    if (cardId.trim().isEmpty) return;
    final raw = await _secureStorage.read(key: _cardSchedulesKey);
    final Map<String, dynamic> schedules = _safeJsonDecode(raw);

    final now = DateTime.now().millisecondsSinceEpoch;
    final current = schedules[cardId] as Map<String, dynamic>? ?? {
      'stability': 1.0,
      'difficulty': difficulty,
      'lastReview': now,
      'intervalDays': 1,
    };

    double stability = (current['stability'] as num?)?.toDouble() ?? 1.0;
    if (recalled) {
      stability *= 1.5 + (1 - difficulty); // Increase stability on success
    } else {
      stability = max(0.5, stability * 0.5); // Reset on failure
    }

    final intervalDays = max(1, (stability * 2).round());
    schedules[cardId] = {
      'stability': stability,
      'difficulty': difficulty,
      'lastReview': now,
      'nextReview': now + (intervalDays * 86400000),
      'intervalDays': intervalDays,
    };

    await _secureStorage.write(key: _cardSchedulesKey, value: jsonEncode(schedules));
  }

  /// Get cards due for review (basic).
  Future<List<String>> getDueCards({int limit = 10}) async {
    final raw = await _secureStorage.read(key: _cardSchedulesKey);
    final Map<String, dynamic> schedules = _safeJsonDecode(raw);
    final now = DateTime.now().millisecondsSinceEpoch;

    final due = <String>[];
    schedules.forEach((id, data) {
      if (data is! Map) return;
      final next = (data['nextReview'] as num?)?.toInt() ?? 0;
      if (next <= now) due.add(id.toString());
    });
    due.sort();
    return due.take(limit).toList();
  }

  /// Start a low-stress session: fewer items, focus on weak areas, calm pacing.
  Future<Map<String, dynamic>> prepareLowStressSession() async {
    final advanced = await isAdvancedModeAvailable();
    final priorities = await getPriorityPatterns();
    final due = await getDueCards(limit: advanced ? 12 : 6);

    return {
      'mode': advanced ? 'advanced_adaptive' : 'basic_low_stress',
      'priorities': priorities,
      'dueCards': due,
      'maxItems': advanced ? 12 : 6,
      'pacingMs': 1800,
      'message': 'جلسة مراجعة هادئة مخصصة لنقاط ضعفك',
    };
  }

  /// Persist session metrics encrypted.
  Future<void> saveSessionMetrics(Map<String, dynamic> metrics) async {
    final encoded = jsonEncode(metrics);
    await _secureStorage.write(key: _sessionMetricsKey, value: encoded);
  }
}
