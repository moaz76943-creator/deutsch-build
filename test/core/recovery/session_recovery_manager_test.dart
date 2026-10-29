import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';

void main() {
  late SharedPreferences prefs;
  late SessionRecoveryManager manager;
  const key = 'deutsch_active_session_recovery_v1';

  SessionState valid({
    String source = 'de',
    String target = 'ar',
    String route = '/quiz',
    int timestamp = 9900,
  }) => SessionState(
    sessionId: 'session-1',
    currentRoute: route,
    lastItemIndex: 5,
    timestamp: timestamp,
    sourceLocale: source,
    targetLocale: target,
    semanticVersion: '1.0',
    committedReviewIds: ['review-a', 'review-b'],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({'learner.progress': 42});
    prefs = await SharedPreferences.getInstance();
    manager = SessionRecoveryManager(
      prefs, clock: () => 10000, maxRecoveryAttempts: 2, maxCheckpointAgeMs: 2000,
    );
  });

  test('roundtrip retains pair, route, and committed SRS review IDs', () async {
    await manager.persistSession(valid());
    final restored = manager.restoreSession(
      expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
      isValidRoute: (route) => route == '/quiz',
    );
    expect(restored?.sessionId, 'session-1');
    expect(restored?.committedReviewIds, ['review-a', 'review-b']);
  });

  test('missing expected pair or route never restores a checkpoint', () async {
    await manager.persistSession(valid());
    expect(manager.restoreSession(), isNull);
    expect(manager.restoreSession(
      expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
    ), isNull);
  });

  test('rejects wrong directed pair and disallowed route', () async {
    await manager.persistSession(valid());
    expect(manager.restoreSession(
      expectedSourceLocale: 'ar', expectedTargetLocale: 'de',
      isValidRoute: (_) => true,
    ), isNull);
    expect(manager.restoreSession(
      expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
      isValidRoute: (_) => false,
    ), isNull);
  });

  test('incomplete pair and unversioned legacy checkpoints fail closed', () async {
    await expectLater(manager.persistSession(valid(target: '')),
        throwsA(isA<ArgumentError>()));
    await prefs.setString(key, jsonEncode({
      'session_id': 'legacy', 'current_route': '/quiz',
      'last_item_index': 0, 'timestamp': 9900,
    }));
    expect(manager.restoreSession(
      expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
      isValidRoute: (_) => true,
    ), isNull);
  });

  test('attempt counter is awaited before recovery; third attempt fails', () async {
    await manager.persistSession(valid());
    for (var attempt = 1; attempt <= 2; attempt++) {
      final state = await manager.restoreAndMarkAttempt(
        expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
        isValidRoute: (_) => true,
      );
      expect(state, isNotNull);
      final saved = jsonDecode(prefs.getString(key)!) as Map<String, dynamic>;
      expect(saved['recovery_attempts'], attempt);
    }
    expect(await manager.restoreAndMarkAttempt(
      expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
      isValidRoute: (_) => true,
    ), isNull);
    expect(prefs.getInt('learner.progress'), 42);
  });

  test('rejects stale, future, corrupted, and oversized checkpoints', () async {
    for (final timestamp in [1, 10001]) {
      await manager.persistSession(valid(timestamp: timestamp));
      expect(manager.restoreSession(
        expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
        isValidRoute: (_) => true,
      ), isNull, reason: 'timestamp $timestamp must be rejected');
    }
    await prefs.setString(key, '{invalid');
    expect(manager.restoreSession(
      expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
      isValidRoute: (_) => true,
    ), isNull);
    await prefs.setString(key, List.filled(100000, 'x').join());
    expect(manager.restoreSession(
      expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
      isValidRoute: (_) => true,
    ), isNull);
  });

  test('clear only removes the recovery key, never learner progress', () async {
    await manager.persistSession(valid());
    await manager.clearSession();
    expect(prefs.getString(key), isNull);
    expect(prefs.getInt('learner.progress'), 42);
  });
  test('concurrent recovery callbacks reserve one durable attempt only', () async {
    await manager.persistSession(valid());
    final first = manager.restoreAndMarkAttempt(
      expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
      isValidRoute: (_) => true,
    );
    final duplicate = manager.restoreAndMarkAttempt(
      expectedSourceLocale: 'de', expectedTargetLocale: 'ar',
      isValidRoute: (_) => true,
    );
    final results = await Future.wait([first, duplicate]);
    expect(results.whereType<SessionState>().length, 1);
    final checkpoint = jsonDecode(prefs.getString(key)!) as Map<String, dynamic>;
    expect(checkpoint['recovery_attempts'], 1);
  });

}
