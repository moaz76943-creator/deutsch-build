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

      final manager = SessionRecoveryManager(prefs);
      final restored = manager.restoreSession(currentTimestampSec: 1000000 + 1000);

      expect(restored, isNotNull);
      expect(restored?.sessionId, 'legacy_123');
      expect(restored?.languagePairKey, isNull);
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
      final manager = SessionRecoveryManager(prefs);

      await manager.persistSession(session);
      final restored = manager.restoreSession(currentTimestampSec: 1000000 + 1000);

      expect(restored?.committedReviewIds, containsAll(['rev_1', 'rev_2']));
    });

    test('Rejects checkpoint with wrong language pair', () async {
      final session = SessionState(
        sessionId: 'sess_pair',
        currentRoute: '/quiz/trainer',
        lastItemIndex: 0,
        timestamp: 1000000,
        languagePairKey: 'de_ar_1.0',
      );
      final manager = SessionRecoveryManager(prefs);

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        expectedLanguagePairKey: 'en_ar_1.0',
        currentTimestampSec: 1000000 + 1000,
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
      final manager = SessionRecoveryManager(prefs);

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        isValidRoute: (route) => route == '/valid_route',
        currentTimestampSec: 1000000 + 1000,
      );

      expect(restored, isNull);
    });

    test('Rejects stale session beyond max age', () async {
      const maxAgeSec = 24 * 60 * 60;
      final session = SessionState(
        sessionId: 'sess_stale',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: 1000000,
      );
      final manager = SessionRecoveryManager(prefs);

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        currentTimestampSec: 1000000 + maxAgeSec + 1000, // 1000 seconds past max age
      );

      expect(restored, isNull);
    });

    test('Enforces max recovery attempts limit', () async {
      final session = SessionState(
        sessionId: 'sess_loop',
        currentRoute: '/quiz',
        lastItemIndex: 0,
        timestamp: 1000000,
      );
      final manager = SessionRecoveryManager(prefs);

      await manager.persistSession(session);

      // Attempt 1
      var restored = manager.restoreSession(currentTimestampSec: 1000000 + 1000);
      expect(restored, isNotNull);

      // Attempt 2
      restored = manager.restoreSession(currentTimestampSec: 1000000 + 1000);
      expect(restored, isNotNull);

      // Attempt 3
      restored = manager.restoreSession(currentTimestampSec: 1000000 + 1000);
      expect(restored, isNotNull);

      // Attempt 4 (Should fail because limit is >= 3 in our logic)
      restored = manager.restoreSession(currentTimestampSec: 1000000 + 1000);
      expect(restored, isNull);
    });
  });
}
