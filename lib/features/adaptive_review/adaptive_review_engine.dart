import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:deutsch_bilarabi/services/play_integrity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adaptive Review Engine – Improved FSRS-inspired scheduler.
///
/// Personalizes spaced review based on error patterns (gender, plurals, pronunciation).
/// Uses refined stability/difficulty/retrievability formulas for better long-term retention.
/// Advanced modes gated by Play Integrity (offline-safe; token requires network which is removed by design).
/// All sensitive card schedules and metrics stored encrypted via FlutterSecureStorage.
/// Offline-first; no network required. Client-side gating is best-effort only.
class AdaptiveReviewEngine {
  static final AdaptiveReviewEngine instance = AdaptiveReviewEngine._();
  AdaptiveReviewEngine._();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _errorPatternsKey = 'adaptive_error_patterns_v1';
  static const _sessionMetricsKey = 'adaptive_session_metrics_v1';
  static const _cardSchedulesKey = 'adaptive_card_schedules_v2'; // version bump for new fields

  // FSRS-inspired defaults (desired retention ~0.9)
  static const double _desiredRetention = 0.9;
  static const double _maxIntervalDays = 365.0;
  static const List<double> _learningStepsMinutes = [1.0, 10.0];
  static const List<double> _relearningStepsMinutes = [10.0];

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
  /// Offline-safe: returns false / falls back when no integrity token (expected).
  Future<bool> isAdvancedModeAvailable() async {
    final token = await PlayIntegrityService.requestIntegrityToken();
    if (token == null || token.isEmpty) {
      debugPrint('[AdaptiveReview] Integrity token unavailable – advanced mode gated (offline design).');
      return PlayIntegrityService.isLikelyGenuineDevice();
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

  /// Calculate current retrievability (probability of recall).
  double _retrievability(double stability, double elapsedDays) {
    if (stability <= 0) return 0.0;
    // Simplified FSRS retrievability formula
    final decay = -0.5; // typical FSRS decay parameter
    final factor = 0.9; // related to desired retention
    return pow(1 + factor * elapsedDays / stability, decay).toDouble().clamp(0.0, 1.0);
  }

  /// Improved FSRS-inspired schedule for a card.
  /// Rating: true = Good/Easy (recalled), false = Again (forgot).
  /// Stores next review, stability, difficulty, lapses in encrypted storage.
  Future<void> scheduleCard(String cardId, {required bool recalled, double difficulty = 0.5}) async {
    if (cardId.trim().isEmpty) return;
    final raw = await _secureStorage.read(key: _cardSchedulesKey);
    final Map<String, dynamic> schedules = _safeJsonDecode(raw);

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final current = schedules[cardId] as Map<String, dynamic>? ?? {
      'stability': 1.0,
      'difficulty': difficulty.clamp(0.0, 1.0),
      'lastReview': nowMs,
      'intervalDays': 0.0,
      'lapses': 0,
      'state': 'learning', // learning | review | relearning
    };

    double stability = (current['stability'] as num?)?.toDouble() ?? 1.0;
    double cardDifficulty = (current['difficulty'] as num?)?.toDouble() ?? difficulty;
    int lapses = (current['lapses'] as int?) ?? 0;
    String state = current['state'] as String? ?? 'learning';
    final lastReviewMs = (current['lastReview'] as num?)?.toInt() ?? nowMs;
    final elapsedDays = (nowMs - lastReviewMs) / 86400000.0;

    // Update difficulty based on performance (simple gradient)
    if (recalled) {
      cardDifficulty = (cardDifficulty - 0.05).clamp(0.1, 1.0);
    } else {
      cardDifficulty = (cardDifficulty + 0.15).clamp(0.1, 1.0);
      lapses++;
    }

    // Stability update (simplified FSRS-style)
    if (recalled) {
      final retriev = _retrievability(stability, elapsedDays);
      final growth = 1.0 + (1.0 - cardDifficulty) * (1.0 - retriev) * 2.0;
      stability = (stability * growth).clamp(0.5, 36500.0);
      state = 'review';
    } else {
      stability = max(0.3, stability * 0.4);
      state = 'relearning';
    }

    // Next interval with light fuzzing for natural spacing
    double intervalDays;
    if (state == 'learning') {
      intervalDays = _learningStepsMinutes.first / 1440.0; // minutes to days
    } else if (state == 'relearning') {
      intervalDays = _relearningStepsMinutes.first / 1440.0;
    } else {
      // Review interval based on stability and desired retention
      intervalDays = stability * log(_desiredRetention) / log(0.9);
      intervalDays = intervalDays.clamp(1.0, _maxIntervalDays);
      // Light fuzz ±5%
      final fuzz = 1.0 + (Random().nextDouble() - 0.5) * 0.1;
      intervalDays *= fuzz;
    }

    schedules[cardId] = {
      'stability': stability,
      'difficulty': cardDifficulty,
      'lastReview': nowMs,
      'nextReview': nowMs + (intervalDays * 86400000).round(),
      'intervalDays': intervalDays,
      'lapses': lapses,
      'state': state,
      'retrievability': _retrievability(stability, 0),
    };

    await _secureStorage.write(key: _cardSchedulesKey, value: jsonEncode(schedules));
  }

  /// Get cards due for review, sorted by overdue amount.
  Future<List<String>> getDueCards({int limit = 10}) async {
    final raw = await _secureStorage.read(key: _cardSchedulesKey);
    final Map<String, dynamic> schedules = _safeJsonDecode(raw);
    final now = DateTime.now().millisecondsSinceEpoch;

    final due = <MapEntry<String, int>>[];
    schedules.forEach((id, data) {
      if (data is! Map) return;
      final next = (data['nextReview'] as num?)?.toInt() ?? 0;
      if (next <= now) {
        due.add(MapEntry(id.toString(), now - next)); // overdue ms
      }
    });
    due.sort((a, b) => b.value.compareTo(a.value)); // most overdue first
    return due.take(limit).map((e) => e.key).toList();
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

  /// Optional: get current retrievability for a card (for UI analytics).
  Future<double?> getCardRetrievability(String cardId) async {
    final raw = await _secureStorage.read(key: _cardSchedulesKey);
    final schedules = _safeJsonDecode(raw);
    final data = schedules[cardId];
    if (data is! Map) return null;
    final stability = (data['stability'] as num?)?.toDouble() ?? 1.0;
    final last = (data['lastReview'] as num?)?.toInt() ?? 0;
    final elapsed = (DateTime.now().millisecondsSinceEpoch - last) / 86400000.0;
    return _retrievability(stability, elapsed);
  }
}
