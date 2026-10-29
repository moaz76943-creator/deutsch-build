import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';

void main() {
  group('J078 Last-Known-Good Learning Session Recovery Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('Restores legacy v1 checkpoint correctly', () async {
      final legacyData = {
        'session_id': 'legacy_123',
        'current_route': '/quiz',
        'last_item_index': 2,
        'timestamp': 1000000,
      };
      await prefs.setString('deutsch_active_session_recovery_v1', jsonEncode(legacyData));

      final manager = SessionRecoveryManager(
        prefs,
        clock: () => 1000000 + 1000, // Valid age
      );
      final restored = manager.restoreSession();

      expect(restored, isNotNull);
      expect(restored?.sessionId, 'legacy_123');
      expect(restored?.sourceLocale, '');
      expect(restored?.committedReviewIds, isEmpty);
    });

    test('Preserves committedReviewIds (Interrupted review)', () async {
      final session = SessionState(
        sessionId: 'sess_new',
        currentRoute: '/quiz/trainer',
        lastItemIndex: 5,
        timestamp: 1000000,
        committedReviewIds: ['rev_1', 'rev_2'],
      );
      final manager = SessionRecoveryManager(
        prefs,
        clock: () => 1000000 + 1000,
      );

      await manager.persistSession(session);
      final restored = manager.restoreSession();

      expect(restored?.committedReviewIds, containsAll(['rev_1', 'rev_2']));
    });

    test('Rejects checkpoint with wrong language pair', () async {
      final session = SessionState(
        sessionId: 'sess_pair',
        currentRoute: '/quiz/trainer',
        lastItemIndex: 0,
        timestamp: 1000000,
        sourceLocale: 'de',
        targetLocale: 'ar',
      );
      final manager = SessionRecoveryManager(
        prefs,
        clock: () => 1000000 + 1000,
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        expectedSourceLocale: 'en',
        expectedTargetLocale: 'ar',
      );

      expect(restored, isNull);
    });

    test('Rejects missing screen or invalid route', () async {
      final session = SessionState(
        sessionId: 'sess_route',
        currentRoute: '/missing_pack_route',
        lastItemIndex: 0,
        timestamp: 1000000,
      );
      final manager = SessionRecoveryManager(
        prefs,
        clock: () => 1000000 + 1000,
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        isValidRoute: (route) => route == '/valid_route',
      );

      expect(restored, isNull);
    });

    test('Rejects stale session beyond max age', () async {
      const maxAgeMs = 24 * 60 * 60 * 1000;
      final session = SessionState(
        sessionId: 'sess_stale',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: 1000000,
      );
      final manager = SessionRecoveryManager(
        prefs,
        clock: () => 1000000 + maxAgeMs + 1000, // 1 second past max age
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession();

      expect(restored, isNull);
    });

    test('Enforces max recovery attempts limit', () async {
      final session = SessionState(
        sessionId: 'sess_loop',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: 1000000,
      );
      final manager = SessionRecoveryManager(
        prefs,
        clock: () => 1000000 + 1000,
        maxRecoveryAttempts: 2,
      );

      await manager.persistSession(session);

      // Attempt 1
      var restored = manager.restoreSession();
      expect(restored, isNotNull);

      // Attempt 2
      restored = manager.restoreSession();
      expect(restored, isNotNull);

      // Attempt 3 (Should fail)
      restored = manager.restoreSession();
      expect(restored, isNull);
    });
  });
}
