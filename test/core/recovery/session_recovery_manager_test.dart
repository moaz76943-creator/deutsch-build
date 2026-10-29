import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';

void main() {
  group('SessionRecoveryManager Tests', () {
    late SessionRecoveryManager recoveryManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      recoveryManager = SessionRecoveryManager(prefs);
    });

    test('Persists and restores valid session accurately', () async {
      final session = SessionState(
        sessionId: 'sess_123',
        currentRoute: '/quiz/trainer',
        lastItemIndex: 5,
        timestamp: 1728468000,
        languagePairKey: 'de_ar_1.0',
        committedReviewIds: ['rev_1'],
      );

      await recoveryManager.persistSession(session);
      final restored = await recoveryManager.restoreSession(
        expectedLanguagePairKey: 'de_ar_1.0',
        currentTimestamp: 1728468005,
        isRouteValid: (_) => true,
      );

      expect(restored, isNotNull);
      expect(restored?.sessionId, 'sess_123');
      expect(restored?.currentRoute, '/quiz/trainer');
      expect(restored?.lastItemIndex, 5);
      expect(restored?.languagePairKey, 'de_ar_1.0');
      expect(restored?.isReviewCommitted('rev_1'), isTrue);
      expect(restored?.isReviewCommitted('rev_2'), isFalse);
    });

    test('Handles corrupted data gracefully without crashing', () async {
      SharedPreferences.setMockInitialValues({
        'deutsch_active_session_recovery_v1': '{bad_json',
      });
      final prefs = await SharedPreferences.getInstance();
      final manager = SessionRecoveryManager(prefs);

      expect(await manager.restoreSession(
        expectedLanguagePairKey: 'de_ar_1.0',
        currentTimestamp: 1728468005,
        isRouteValid: (_) => true,
      ), isNull);
    });

    test('Clears active session on demand', () async {
      final session = SessionState(
        sessionId: 'sess_456',
        currentRoute: '/home',
        lastItemIndex: 0,
        timestamp: 1728468100,
        languagePairKey: 'de_ar_1.0',
      );
      await recoveryManager.persistSession(session);
      await recoveryManager.clearSession();
      expect(await recoveryManager.restoreSession(
        expectedLanguagePairKey: 'de_ar_1.0',
        currentTimestamp: 1728468105,
        isRouteValid: (_) => true,
      ), isNull);
    });

    test('Restores legacy un-enveloped session', () async {
      SharedPreferences.setMockInitialValues({
        'deutsch_active_session_recovery_v1': '{"session_id": "legacy_123", "current_route": "/home", "last_item_index": 2, "timestamp": 1728468000}'
      });
      final prefs = await SharedPreferences.getInstance();
      final manager = SessionRecoveryManager(prefs);
      final restored = await manager.restoreSession(
        expectedLanguagePairKey: 'unknown',
        currentTimestamp: 1728468005,
        isRouteValid: (_) => true,
      );
      expect(restored, isNotNull);
      expect(restored?.sessionId, 'legacy_123');
      expect(restored?.languagePairKey, 'unknown');
      expect(restored?.committedReviewIds, isEmpty);
    });
  });
}
