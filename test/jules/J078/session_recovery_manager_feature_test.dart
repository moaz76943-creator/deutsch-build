import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';

void main() {
  group('J078 - Last-Known-Good Learning Session Recovery', () {
    late SessionRecoveryManager recoveryManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      recoveryManager = SessionRecoveryManager(prefs);
    });

    test('Valid restart with correct pair identity and active session', () async {
      final session = SessionState(
        sessionId: 'sess_valid',
        currentRoute: '/quiz',
        lastItemIndex: 10,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        languagePairKey: 'ar_de_1.0',
        committedReviewIds: [],
      );

      await recoveryManager.persistSession(session);

      final restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'ar_de_1.0',
        isValidRoute: (route) => route.startsWith('/'),
      );

      expect(restored, isNotNull);
      expect(restored?.sessionId, 'sess_valid');
      expect(restored?.languagePairKey, 'ar_de_1.0');
    });

    test('Interrupted review correctly tracks committed SRS submissions to prevent duplicates', () async {
      final session = SessionState(
        sessionId: 'sess_interrupted',
        currentRoute: '/quiz',
        lastItemIndex: 5,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        languagePairKey: 'ar_de_1.0',
        committedReviewIds: ['rev_1', 'rev_2'],
      );

      await recoveryManager.persistSession(session);

      final restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'ar_de_1.0',
        isValidRoute: (_) => true,
      );

      expect(restored, isNotNull);
      expect(recoveryManager.isReviewCommitted(restored!, 'rev_1'), isTrue);
      expect(recoveryManager.isReviewCommitted(restored, 'rev_2'), isTrue);
      expect(recoveryManager.isReviewCommitted(restored, 'rev_3'), isFalse);
    });

    test('Wrong language pair identity is safely rejected', () async {
      final session = SessionState(
        sessionId: 'sess_wrong_pair',
        currentRoute: '/quiz',
        lastItemIndex: 5,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        languagePairKey: 'ar_de_1.0',
      );

      await recoveryManager.persistSession(session);

      final restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'en_de_1.0',
        isValidRoute: (_) => true,
      );

      expect(restored, isNull);
    });

    test('Malformed checkpoint safely rejected', () async {
       SharedPreferences.setMockInitialValues({
        'deutsch_active_session_recovery_v1': '{"version": 2, "state": {"session_id": "", "current_route": "/quiz", "timestamp": 4000}}'
      });
      final prefs = await SharedPreferences.getInstance();
      recoveryManager = SessionRecoveryManager(prefs);

      final restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'ar_de_1.0',
        isValidRoute: (_) => true,
      );

      expect(restored, isNull);
    });

    test('Missing screen/invalid destination is rejected', () async {
      final session = SessionState(
        sessionId: 'sess_missing_screen',
        currentRoute: '/non_existent',
        lastItemIndex: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        languagePairKey: 'ar_de_1.0',
      );

      await recoveryManager.persistSession(session);

      final restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'ar_de_1.0',
        isValidRoute: (route) => route == '/quiz', // Only /quiz is valid
      );

      expect(restored, isNull);
    });

    test('Stale session is rejected', () async {
      final session = SessionState(
        sessionId: 'sess_stale',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 86401,
        languagePairKey: 'ar_de_1.0',
      );

      await recoveryManager.persistSession(session);

      final restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'ar_de_1.0',
        isValidRoute: (_) => true,
      );

      expect(restored, isNull);
    });

    test('Corrupted checkpoints cannot create recovery loops (exceeds max attempts)', () async {
      final session = SessionState(
        sessionId: 'sess_loop',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        languagePairKey: 'ar_de_1.0',
      );

      await recoveryManager.persistSession(session);

      // Attempt 1
      var restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'ar_de_1.0',
        isValidRoute: (_) => true,
      );
      expect(restored, isNotNull);

      // Attempt 2
      restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'ar_de_1.0',
        isValidRoute: (_) => true,
      );
      expect(restored, isNotNull);

      // Attempt 3
      restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'ar_de_1.0',
        isValidRoute: (_) => true,
      );
      expect(restored, isNotNull);

      // Attempt 4 (should be rejected)
      restored = recoveryManager.restoreSession(
        expectedLanguagePairKey: 'ar_de_1.0',
        isValidRoute: (_) => true,
      );
      expect(restored, isNull);
    });
  });
}
