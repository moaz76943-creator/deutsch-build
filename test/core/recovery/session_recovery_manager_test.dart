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

    test('Persists and restores valid session accurately (Legacy behavior)', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final session = SessionState(
        sessionId: 'sess_123',
        currentRoute: '/quiz/trainer',
        lastItemIndex: 5,
        timestamp: nowSec,
      );

      await recoveryManager.persistSession(session);
      final restored = recoveryManager.restoreSession();

      expect(restored, isNotNull);
      expect(restored?.sessionId, 'sess_123');
      expect(restored?.currentRoute, '/quiz/trainer');
      expect(restored?.lastItemIndex, 5);
      expect(restored?.version, 1);
      expect(restored?.recoveryAttempts, 1);
    });

    test('Handles corrupted data gracefully without crashing', () async {
      SharedPreferences.setMockInitialValues({
        'deutsch_active_session_recovery_v1': '{bad_json',
      });
      final prefs = await SharedPreferences.getInstance();
      final manager = SessionRecoveryManager(prefs);

      expect(manager.restoreSession(), isNull);
      expect(prefs.getString('deutsch_active_session_recovery_v1'), isNull);
    });

    test('Clears active session on demand', () async {
      final session = SessionState(
        sessionId: 'sess_456',
        currentRoute: '/home',
        lastItemIndex: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      await recoveryManager.persistSession(session);
      await recoveryManager.clearSession();
      expect(recoveryManager.restoreSession(), isNull);
    });
  });
}
