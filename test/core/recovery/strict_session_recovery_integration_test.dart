import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';

void main() {
  late SharedPreferences preferences;
  late SessionRecoveryManager manager;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
    manager = SessionRecoveryManager(preferences, clock: () => 2000000);
  });

  SessionState checkpoint({
    String source = 'de',
    String target = 'ar',
    String route = '/lesson',
  }) => SessionState(
        sessionId: 'stable-1',
        currentRoute: route,
        lastItemIndex: 4,
        timestamp: 1999000,
        sourceLocale: source,
        targetLocale: target,
        semanticVersion: '2',
        committedReviewIds: const <String>['tx-1'],
      );

  Future<SessionState?> activate({
    String source = 'de',
    String target = 'ar',
  }) => manager.restoreForPair(
        expectedSourceLocale: source,
        expectedTargetLocale: target,
        expectedSemanticVersion: '2',
        isValidRoute: (route) => route == '/lesson',
      );

  test('strict restore commits its attempt before navigation', () async {
    await manager.persistSession(checkpoint());
    final restored = await activate();
    expect(restored?.committedReviewIds, <String>['tx-1']);
    final raw = jsonDecode(preferences.getString(
        'deutsch_active_session_recovery_v1')!) as Map<String, dynamic>;
    expect(raw['recovery_attempts'], 1);
    // A second restore in the same runtime must not trigger a second handoff.
    expect(await activate(), isNull);
    // Each new process has its own manager, but the persisted ledger is finite.
    final rebooted = SessionRecoveryManager(preferences, clock: () => 2000000);
    expect(await rebooted.restoreForPair(
      expectedSourceLocale: 'de',
      expectedTargetLocale: 'ar',
      expectedSemanticVersion: '2',
      isValidRoute: (route) => route == '/lesson',
    ), isNotNull);
  });

  test('attempt ceiling survives manager recreation', () async {
    await manager.persistSession(checkpoint());
    for (var attempt = 0; attempt < 3; attempt++) {
      final reopened = SessionRecoveryManager(preferences, clock: () => 2000000);
      expect(await reopened.restoreForPair(
        expectedSourceLocale: 'de',
        expectedTargetLocale: 'ar',
        expectedSemanticVersion: '2',
        isValidRoute: (route) => route == '/lesson',
      ), isNotNull);
    }
    final exceeded = SessionRecoveryManager(preferences, clock: () => 2000000);
    expect(await exceeded.restoreForPair(
      expectedSourceLocale: 'de',
      expectedTargetLocale: 'ar',
      expectedSemanticVersion: '2',
      isValidRoute: (route) => route == '/lesson',
    ), isNull);
  });

  test('stable handoff resets attempts only for the matching session', () async {
    await manager.persistSession(checkpoint());
    expect(await activate(), isNotNull);
    expect(await manager.markRestoreStable('stable-1'), isTrue);
    final raw = jsonDecode(preferences.getString(
        'deutsch_active_session_recovery_v1')!) as Map<String, dynamic>;
    expect(raw['recovery_attempts'], 0);
    expect(await activate(), isNull);
  });

  test('racing restore calls admit only one navigation', () async {
    await manager.persistSession(checkpoint());
    final answers = await Future.wait(<Future<SessionState?>>[
      activate(),
      activate(),
    ]);
    expect(answers.where((session) => session != null).length, 1);
    final raw = jsonDecode(preferences.getString(
        'deutsch_active_session_recovery_v1')!) as Map<String, dynamic>;
    expect(raw['recovery_attempts'], 1);
  });

  test('incomplete or different directed pair fails closed', () async {
    await manager.persistSession(checkpoint(source: '', target: 'ar'));
    expect(await activate(), isNull);
    await manager.persistSession(checkpoint(source: 'ar', target: 'de'));
    expect(await activate(), isNull);
    await manager.persistSession(checkpoint(source: 'de', target: 'fr'));
    expect(await activate(), isNull);
  });

  test('legacy snapshot can be inspected but never activated', () async {
    final old = checkpoint().toMap();
    await preferences.setString(
        'deutsch_active_session_recovery_v1', jsonEncode(old));
    expect(manager.restoreSession(), isNotNull);
    expect(await activate(), isNull);
  });

  test('stale, future, missing route and mismatched version are rejected',
      () async {
    await manager.persistSession(checkpoint(route: '/unknown'));
    expect(await activate(), isNull);
    await manager.persistSession(SessionState(
      sessionId: 'old',
      currentRoute: '/lesson',
      lastItemIndex: 0,
      timestamp: 1,
      sourceLocale: 'de',
      targetLocale: 'ar',
    ));
    expect(await activate(), isNull);
    await manager.persistSession(SessionState(
      sessionId: 'future',
      currentRoute: '/lesson',
      lastItemIndex: 0,
      timestamp: 2005000,
      sourceLocale: 'de',
      targetLocale: 'ar',
    ));
    expect(await activate(), isNull);
    await manager.persistSession(checkpoint());
    expect(await manager.restoreForPair(
      expectedSourceLocale: 'de',
      expectedTargetLocale: 'ar',
      expectedSemanticVersion: '3',
      isValidRoute: (_) => true,
    ), isNull);
  });

  test('stable acknowledgement verifies directed identity even with reused id',
      () async {
    await manager.persistSession(checkpoint());
    expect(await activate(), isNotNull);
    await manager.persistSession(checkpoint(target: 'fr'));
    expect(await manager.markRestoreStable('stable-1'), isFalse);
    expect(manager.restoreSession()?.targetLocale, 'fr');
  });

  test('stable acknowledgment cannot overwrite a newer session', () async {
    await manager.persistSession(checkpoint());
    expect(await activate(), isNotNull);
    final updated = SessionState(
      sessionId: 'newer-session',
      currentRoute: '/lesson',
      lastItemIndex: 0,
      timestamp: 1999000,
      sourceLocale: 'de',
      targetLocale: 'fr',
    );
    await manager.persistSession(updated);
    expect(await manager.markRestoreStable('stable-1'), isFalse);
    expect(manager.restoreSession()?.sessionId, 'newer-session');
  });

  test('corruption and duplicate review transactions do not restore', () async {
    await preferences.setString(
        'deutsch_active_session_recovery_v1', '{broken');
    expect(await activate(), isNull);
    expect(() => manager.persistSession(SessionState(
          sessionId: 'duplicate',
          currentRoute: '/lesson',
          lastItemIndex: 0,
          timestamp: 1999000,
          committedReviewIds: const <String>['tx', 'tx'],
        )), throwsArgumentError);
  });

  test('stale payload cannot corrupt the checkpoint ledger', () async {
    final duplicate = checkpoint().toMap();
    duplicate['committed_review_ids'] = <String>['repeat', 'repeat'];
    await preferences.setString('deutsch_active_session_recovery_v1',
        jsonEncode(<String, dynamic>{
          'version': SessionRecoveryManager.checkpointVersion,
          'state': duplicate,
          'recovery_attempts': 0,
        }));
    expect(await activate(), isNull);
  });

  test('checkpoint is bounded and immutable', () {
    final ids = <String>['tx-1'];
    final state = SessionState(
      sessionId: 'a',
      currentRoute: '/lesson',
      lastItemIndex: 0,
      timestamp: 1999000,
      committedReviewIds: ids,
    );
    ids.add('tx-2');
    expect(state.committedReviewIds, <String>['tx-1']);
    expect(() => state.committedReviewIds.add('tx-3'), throwsUnsupportedError);
  });
}
