import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';

void main() {
  group('J078 Session Recovery Manager Extended Tests', () {
    late SessionRecoveryManager manager;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      manager = SessionRecoveryManager(prefs);
    });

    test('Successfully recovers a valid V2 checkpoint', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final session = SessionState(
        version: 2,
        sessionId: 'sess_v2_123',
        currentRoute: '/trainer',
        lastItemIndex: 10,
        timestamp: nowSec,
        languagePairKey: 'de_ar',
        committedReviewIds: ['r1', 'r2'],
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        expectedLanguagePairKey: 'de_ar',
        isRouteValid: (route) => route == '/trainer',
        isPackAvailable: (pair) => true,
        currentTimestamp: nowSec + 10,
      );

      expect(restored, isNotNull);
      expect(restored?.version, 2);
      expect(restored?.languagePairKey, 'de_ar');
      expect(restored?.committedReviewIds, ['r1', 'r2']);
      expect(restored?.recoveryAttempts, 1);
    });

    test('Fails and clears when expected language pair identity is wrong', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final session = SessionState(
        version: 2,
        sessionId: 'sess_v2_124',
        currentRoute: '/trainer',
        lastItemIndex: 1,
        timestamp: nowSec,
        languagePairKey: 'en_ar',
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        expectedLanguagePairKey: 'de_ar',
        currentTimestamp: nowSec + 10,
      );

      expect(restored, isNull);
      expect(prefs.getString('deutsch_active_session_recovery_v1'), isNull);
    });

    test('Fails and clears when checkpoint is stale (too old)', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final staleTimestamp = nowSec - 90000; // > 24 hours (86400s)
      final session = SessionState(
        sessionId: 'sess_stale',
        currentRoute: '/trainer',
        lastItemIndex: 1,
        timestamp: staleTimestamp,
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        currentTimestamp: nowSec,
      );

      expect(restored, isNull);
      expect(prefs.getString('deutsch_active_session_recovery_v1'), isNull);
    });

    test('Fails and clears when route is invalid (missing screen)', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final session = SessionState(
        sessionId: 'sess_invalid_route',
        currentRoute: '/missing_screen',
        lastItemIndex: 1,
        timestamp: nowSec,
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        isRouteValid: (route) => false,
        currentTimestamp: nowSec,
      );

      expect(restored, isNull);
      expect(prefs.getString('deutsch_active_session_recovery_v1'), isNull);
    });

    test('Fails and clears when language pack is unavailable', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final session = SessionState(
        sessionId: 'sess_missing_pack',
        currentRoute: '/trainer',
        lastItemIndex: 1,
        timestamp: nowSec,
        languagePairKey: 'fr_ar',
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        isPackAvailable: (pair) => false,
        currentTimestamp: nowSec,
      );

      expect(restored, isNull);
      expect(prefs.getString('deutsch_active_session_recovery_v1'), isNull);
    });

    test('Fails and clears when recovery attempts exceed limit', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final session = SessionState(
        sessionId: 'sess_too_many_attempts',
        currentRoute: '/trainer',
        lastItemIndex: 1,
        timestamp: nowSec,
        recoveryAttempts: 3,
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        currentTimestamp: nowSec,
      );

      expect(restored, isNull);
      expect(prefs.getString('deutsch_active_session_recovery_v1'), isNull);
    });

    test('Increments recovery attempts correctly upon valid restoration', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final session = SessionState(
        sessionId: 'sess_attempts',
        currentRoute: '/trainer',
        lastItemIndex: 1,
        timestamp: nowSec,
        recoveryAttempts: 1,
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        currentTimestamp: nowSec,
      );

      expect(restored?.recoveryAttempts, 2);

      // Since persistence happens async, wait a tiny bit to check storage
      await Future.delayed(Duration.zero);
      final raw = prefs.getString('deutsch_active_session_recovery_v1');
      expect(raw, contains('"recovery_attempts":2'));
    });

    test('Interrupted review recovers with committed reviews to avoid duplication', () async {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final session = SessionState(
        sessionId: 'sess_interrupted',
        currentRoute: '/trainer',
        lastItemIndex: 5,
        timestamp: nowSec,
        committedReviewIds: ['rev_1', 'rev_2'],
      );

      await manager.persistSession(session);

      final restored = manager.restoreSession(
        currentTimestamp: nowSec,
      );

      expect(restored, isNotNull);
      expect(restored?.lastItemIndex, 5); // Maintains position
      expect(restored?.committedReviewIds.contains('rev_1'), isTrue); // Prevents replay
    });
  });
}
