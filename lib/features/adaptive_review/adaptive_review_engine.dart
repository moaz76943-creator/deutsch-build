import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:deutsch_bilarabi/services/play_integrity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adaptive Review Engine for Low-Stress Cognitive Load Sessions.
///
/// Personalizes spaced review based on error patterns (gender, plurals, pronunciation).
/// Advanced modes (detailed analytics, hard packs) are gated by Play Integrity.
/// Sensitive metrics stored encrypted via FlutterSecureStorage.
/// Offline-first; verify integrity token on backend for high-value actions.
class AdaptiveReviewEngine {
  static final AdaptiveReviewEngine instance = AdaptiveReviewEngine._();
  AdaptiveReviewEngine._();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _errorPatternsKey = 'adaptive_error_patterns_v1';
  static const _sessionMetricsKey = 'adaptive_session_metrics_v1';

  /// Check if advanced adaptive features are available.
  /// Requests fresh integrity token; do not cache long-term.
  Future<bool> isAdvancedModeAvailable() async {
    final token = await PlayIntegrityService.requestIntegrityToken();
    if (token == null || token.isEmpty) {
      debugPrint('[AdaptiveReview] Integrity token unavailable – advanced mode gated.');
      return false;
    }
    // In production: send token + requestHash to backend for verification.
    // Client-side only is insufficient against determined attackers.
    debugPrint('[AdaptiveReview] Integrity token obtained (len=${token.length}). Gate advanced features.');
    return true; // Placeholder; replace with backend result.
  }

  /// Record an error pattern for personalization (e.g. 'gender_der', 'plural_s').
  Future<void> recordErrorPattern(String pattern, {int weight = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_errorPatternsKey) ?? '{}';
    final Map<String, dynamic> patterns = jsonDecode(raw);
    patterns[pattern] = (patterns[pattern] as int? ?? 0) + weight;
    await prefs.setString(_errorPatternsKey, jsonEncode(patterns));

    // Also store a secure summary for sensitive analytics.
    await _secureStorage.write(
      key: 'last_error_pattern',
      value: pattern,
    );
  }

  /// Get prioritized review items based on error patterns (simple heuristic).
  /// Returns list of pattern keys sorted by frequency.
  Future<List<String>> getPriorityPatterns({int limit = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_errorPatternsKey) ?? '{}';
    final Map<String, dynamic> patterns = jsonDecode(raw);
    final sorted = patterns.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// Start a low-stress session: fewer items, focus on weak areas, calm pacing.
  Future<Map<String, dynamic>> prepareLowStressSession() async {
    final advanced = await isAdvancedModeAvailable();
    final priorities = await getPriorityPatterns();
    return {
      'mode': advanced ? 'advanced_adaptive' : 'basic_low_stress',
      'priorities': priorities,
      'maxItems': advanced ? 12 : 6,
      'pacingMs': 1800, // Slower for reduced cognitive load
      'message': 'جلسة مراجعة هادئة مخصصة لنقاط ضعفك',
    };
  }

  /// Persist session metrics encrypted.
  Future<void> saveSessionMetrics(Map<String, dynamic> metrics) async {
    final encoded = jsonEncode(metrics);
    await _secureStorage.write(key: _sessionMetricsKey, value: encoded);
  }
}
