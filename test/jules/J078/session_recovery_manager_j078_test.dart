import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';
import 'dart:convert';

void main() {
  group('J078 Recovery Tests', () {
    late SessionRecoveryManager recoveryManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      recoveryManager = SessionRecoveryManager(prefs);
    });

    test('Valid restart', () async {
      final session = SessionState(
        sessionId: 'sess_valid',
        currentRoute: '/quiz/trainer',
        lastItemIndex: 5,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        languagePairKey: 'de-ar',
      );
      await recoveryManager.persistSession(session);

      final restored = recoveryManager.restoreSession(expectedLanguagePair: 'de-ar', validRoutes: ['/quiz/trainer']);
      expect(restored, isNotNull);
      expect(restored?.sessionId, 'sess_valid');
      expect(restored?.currentRoute, '/quiz/trainer');
      expect(restored?.lastItemIndex, 5);
      expect(restored?.languagePairKey, 'de-ar');
    });

    test('Interrupted review with committed IDs', () async {
      final session = SessionState(
        sessionId: 'sess_interrupted',
        currentRoute: '/quiz',
        lastItemIndex: 2,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        languagePairKey: 'de-ar',
        committedReviewIds: ['rev_1', 'rev_2'],
      );
      await recoveryManager.persistSession(session);

      final restored = recoveryManager.restoreSession();
      expect(restored, isNotNull);
      expect(restored?.committedReviewIds, containsAll(['rev_1', 'rev_2']));
    });

    test('Wrong pair', () async {
      final session = SessionState(
        sessionId: 'sess_wrong_pair',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        languagePairKey: 'de-ar',
      );
      await recoveryManager.persistSession(session);

      expect(recoveryManager.restoreSession(expectedLanguagePair: 'en-ar'), isNull);
    });

    test('Malformed checkpoint', () async {
      SharedPreferences.setMockInitialValues({
        'deutsch_active_session_recovery_v1': '{malformed',
      });
      final prefs = await SharedPreferences.getInstance();
      final manager = SessionRecoveryManager(prefs);

      expect(manager.restoreSession(), isNull);
    });

    test('Missing screen', () async {
      final session = SessionState(
        sessionId: 'sess_missing_screen',
        currentRoute: '/unknown_screen',
        lastItemIndex: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await recoveryManager.persistSession(session);

      expect(recoveryManager.restoreSession(validRoutes: ['/home']), isNull);
    });

    test('Stale session', () async {
      final staleTimestamp = DateTime.now().subtract(const Duration(hours: 25)).millisecondsSinceEpoch;
      final session = SessionState(
        sessionId: 'sess_stale',
        currentRoute: '/home',
        lastItemIndex: 0,
        timestamp: staleTimestamp,
      );
      await recoveryManager.persistSession(session);

      expect(recoveryManager.restoreSession(), isNull);
    });
  });
}
