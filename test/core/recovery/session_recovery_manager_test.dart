import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';
import 'dart:convert';

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
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await recoveryManager.persistSession(session);
      final restored = recoveryManager.restoreSession();

      expect(restored, isNotNull);
      expect(restored?.sessionId, 'sess_123');
      expect(restored?.currentRoute, '/quiz/trainer');
      expect(restored?.lastItemIndex, 5);
    });

    test('Handles corrupted data gracefully without crashing', () async {
      SharedPreferences.setMockInitialValues({
        'deutsch_active_session_recovery_v1': '{bad_json',
      });
      final prefs = await SharedPreferences.getInstance();
      final manager = SessionRecoveryManager(prefs);

      expect(manager.restoreSession(), isNull);
    });

    test('Clears active session on demand', () async {
      final session = SessionState(
        sessionId: 'sess_456',
        currentRoute: '/home',
        lastItemIndex: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await recoveryManager.persistSession(session);
      await recoveryManager.clearSession();
      expect(recoveryManager.restoreSession(), isNull);
    });

    test('Migrates version 1 data correctly', () async {
      final oldData = {
        'session_id': 'sess_v1',
        'current_route': '/home',
        'last_item_index': 2,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      SharedPreferences.setMockInitialValues({
        'deutsch_active_session_recovery_v1': jsonEncode(oldData),
      });
      final prefs = await SharedPreferences.getInstance();
      final manager = SessionRecoveryManager(prefs);

      final restored = manager.restoreSession();
      expect(restored, isNotNull);
      expect(restored?.sessionId, 'sess_v1');
    });

    test('Rejects stale sessions', () async {
      final staleTimestamp = DateTime.now().subtract(const Duration(hours: 25)).millisecondsSinceEpoch;
      final session = SessionState(
        sessionId: 'sess_stale',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: staleTimestamp,
      );
      await recoveryManager.persistSession(session);

      expect(recoveryManager.restoreSession(), isNull);
    });

    test('Rejects missing screen', () async {
      final session = SessionState(
        sessionId: 'sess_missing',
        currentRoute: '/invalid_screen',
        lastItemIndex: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await recoveryManager.persistSession(session);

      expect(recoveryManager.restoreSession(validRoutes: ['/quiz']), isNull);
    });

    test('Rejects wrong language pair', () async {
      final session = SessionState(
        sessionId: 'sess_pair',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        languagePairKey: 'de-ar',
      );
      await recoveryManager.persistSession(session);

      expect(recoveryManager.restoreSession(expectedLanguagePair: 'en-ar'), isNull);
    });

    test('Prevents infinite recovery loops', () async {
      final session = SessionState(
        sessionId: 'sess_loop',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await recoveryManager.persistSession(session);

      expect(recoveryManager.restoreSession(), isNotNull); // Attempt 1
      expect(recoveryManager.restoreSession(), isNotNull); // Attempt 2
      expect(recoveryManager.restoreSession(), isNotNull); // Attempt 3
      expect(recoveryManager.restoreSession(), isNull); // Blocked
    });
  });
}
