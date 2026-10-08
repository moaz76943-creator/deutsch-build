import 'dart:convert';
import 'dart:io';

import 'package:deutsch_bilarabi/core/models/language_catalog_models.dart';
import 'package:deutsch_bilarabi/core/packs/pack_models.dart';
import 'package:deutsch_bilarabi/core/progress/offline_pair_progress_engine.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/storage/local_db/pair_progress_database.dart';
import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';
import 'package:deutsch_bilarabi/features/gamification/sqlite_gamification_repository.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:deutsch_bilarabi/services/review_transaction_reconciler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('duplicate gamification event mutates XP streak and revision once',
      () async {
    final fixture = await _GamificationFixture.create();
    addTearDown(fixture.dispose);

    final at = DateTime.utc(2026, 10, 7, 8);
    final event = GamificationReviewEvent(
      reviewId: 'rv1:meaning:1791360000000000:AAAAAAAAAAAAAAAA',
      facetType: ReviewFacetType.meaningRecall,
      correct: true,
      hinted: false,
      requestedXp: 10,
      occurredAtUtc: at,
      timezoneOffsetMinutes: 0,
    );

    await fixture.repository.recordReview(event);
    expect(await fixture.repository.loadRevision(), 1);

    await fixture.repository.recordReview(event);
    expect(await fixture.repository.loadRevision(), 1);

    final snapshot = await fixture.repository.loadSnapshot();
    expect(snapshot.profile.totalXp, 10);
    expect(snapshot.profile.currentStreak, 1);
    expect(snapshot.profile.longestStreak, 1);
  });

  test('duplicate event ID with changed payload fails closed', () async {
    final fixture = await _GamificationFixture.create();
    addTearDown(fixture.dispose);

    final at = DateTime.utc(2026, 10, 7, 9);
    const id = 'rv1:meaning:1791363600000000:BBBBBBBBBBBBBBBB';
    await fixture.repository.recordReview(
      GamificationReviewEvent(
        reviewId: id,
        facetType: ReviewFacetType.meaningRecall,
        correct: true,
        hinted: false,
        requestedXp: 10,
        occurredAtUtc: at,
        timezoneOffsetMinutes: 0,
      ),
    );

    await expectLater(
      fixture.repository.recordReview(
        GamificationReviewEvent(
          reviewId: id,
          facetType: ReviewFacetType.meaningRecall,
          correct: true,
          hinted: false,
          requestedXp: 11,
          occurredAtUtc: at,
          timezoneOffsetMinutes: 0,
        ),
      ),
      throwsA(
        isA<GamificationReviewEventException>().having(
          (error) => error.code,
          'code',
          'gamification_event_payload_mismatch',
        ),
      ),
    );

    final snapshot = await fixture.repository.loadSnapshot();
    expect(snapshot.profile.totalXp, 10);
    expect(snapshot.profile.currentStreak, 1);
    expect(await fixture.repository.loadRevision(), 1);
  });

  test('legacy XP streak seed is one-way after revision advances', () async {
    final fixture = await _GamificationFixture.create();
    addTearDown(fixture.dispose);

    final first = await fixture.repository.migrateLegacyProfileIfPristine(
      totalXp: 120,
      currentStreak: 4,
      lastReviewAtUtc: DateTime.utc(2026, 10, 6, 8),
      timezoneOffsetMinutes: 0,
    );
    expect(first, isTrue);
    expect(await fixture.repository.loadRevision(), 1);

    final second = await fixture.repository.migrateLegacyProfileIfPristine(
      totalXp: 999,
      currentStreak: 99,
      lastReviewAtUtc: DateTime.utc(2026, 10, 7, 8),
      timezoneOffsetMinutes: 0,
    );
    expect(second, isFalse);

    final snapshot = await fixture.repository.loadSnapshot();
    expect(snapshot.profile.totalXp, 120);
    expect(snapshot.profile.currentStreak, 4);
    expect(snapshot.profile.longestStreak, 4);
    expect(await fixture.repository.loadRevision(), 1);
  });

  test('attempt sink cannot mutate legacy XP or streak', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      LearnerRepository.key: jsonEncode(<String, Object?>{
        'xp': 75,
        'streak': 3,
        'attempts': <Object?>[],
        'assessmentHistory': <Object?>[],
        'placementHistory': <Object?>[],
        'favoriteVerbs': <String>[],
        'learned': <String>[],
        'review': <String>[],
        'reviewCards': <String, Object?>{},
        'updatedAt': '2026-10-07T08:00:00.000Z',
      }),
    });
    final prefs = await PreferencesService.instance();
    final persistence = LearnerPersistence(
      prefs,
      LearnerRepository.key,
      LearnerRepository.legacyFavoriteKey,
    );

    const id = 'rv1:history:1791367200000000:CCCCCCCCCCCCCCCC';
    await persistence.applyReviewAttemptOnce(
      reviewEventId: id,
      attempt: Attempt(
        id: id,
        itemId: 'history_only',
        skill: 'production',
        answer: 'Hallo',
        correct: true,
        hinted: false,
        seconds: 2,
        at: DateTime.utc(2026, 10, 7, 10),
      ),
    );

    final state = persistence.load();
    expect(state.xp, 0);
    expect(state.streak, 0);
    expect(state.attempts.where((attempt) => attempt.id == id).length, 1);

    final raw = jsonDecode(prefs.getString(LearnerRepository.key)!)
        as Map<String, dynamic>;
    expect(raw['xp'], 75);
    expect(raw['streak'], 3);
  });

  test('recovery after gamification write before ACK does not re-award',
      () async {
    final fixture = await _ConversationFixture.create();
    addTearDown(fixture.dispose);

    final at = DateTime.utc(2026, 10, 7, 10, 30);
    const eventId =
        'rv1:conversation:1791369000000000:EEEEEEEEEEEEEEEE';
    final envelope = ReviewTransactionEnvelope(
      reviewEventId: eventId,
      sourceLanguageId: fixture.pair.source.id,
      targetLanguageId: fixture.pair.target.id,
      conceptId: 'conversation_crash',
      facetType: ReviewFacetType.production,
      skill: 'production',
      answer: 'Guten Morgen.',
      correct: true,
      hinted: false,
      seconds: 5,
      occurredAt: at,
      timezoneOffsetMinutes: 0,
      requestedXp: 10,
    );

    await fixture.engine.persistReviewDeliveryEnvelope(
      pair: fixture.pair,
      envelope: envelope,
    );
    await fixture.gamification.recordReview(
      GamificationReviewEvent(
        reviewId: eventId,
        facetType: ReviewFacetType.production,
        correct: true,
        hinted: false,
        requestedXp: 10,
        occurredAtUtc: at,
        timezoneOffsetMinutes: 0,
      ),
    );
    expect(await fixture.gamification.loadRevision(), 1);

    final before = await fixture.engine.loadReviewTransaction(eventId);
    expect(before?.attemptApplied, isFalse);
    expect(before?.gamificationApplied, isFalse);

    final reconciler = ReviewTransactionReconciler(
      pairProgressEngine: fixture.engine,
      learnerPersistence: fixture.repository.persistence,
      gamificationRepository: fixture.gamification,
    );
    final report = await reconciler.reconcilePendingReviewTransactions(
      limit: 128,
    );
    expect(report.inspected, 1);
    expect(report.completed, 1);

    final gamification = await fixture.gamification.loadSnapshot();
    expect(gamification.profile.totalXp, 10);
    expect(gamification.profile.currentStreak, 1);
    expect(await fixture.gamification.loadRevision(), 1);

    final after = await fixture.engine.loadReviewTransaction(eventId);
    expect(after?.isComplete, isTrue);
    expect(
      fixture.repository
          .load()
          .attempts
          .where((attempt) => attempt.id == eventId)
          .length,
      1,
    );
  });

  test('conversation replay uses one attempt one reward and no SRS mutation',
      () async {
    final fixture = await _ConversationFixture.create();
    addTearDown(fixture.dispose);

    final at = DateTime.utc(2026, 10, 7, 11);
    const eventId =
        'rv1:conversation:1791370800000000:DDDDDDDDDDDDDDDD';

    for (var index = 0; index < 2; index += 1) {
      await fixture.repository.recordConversationAttempt(
        itemId: 'conversation_turn_1',
        skill: 'production',
        answer: 'Ich möchte einen Kaffee.',
        correct: true,
        seconds: 8,
        hinted: false,
        at: at,
        reviewEventId: eventId,
      );
    }

    final learner = await fixture.repository.reloadPersisted();
    expect(
      learner.attempts.where((attempt) => attempt.id == eventId).length,
      1,
    );
    expect(learner.xp, 0);
    expect(learner.streak, 0);

    final gamification = await fixture.gamification.loadSnapshot();
    expect(gamification.profile.totalXp, 10);
    expect(gamification.profile.currentStreak, 1);
    expect(await fixture.gamification.loadRevision(), 1);

    final pair = await fixture.engine.loadPair(fixture.pair);
    expect(pair.achievementPoints, 0);
    expect(pair.cards, isEmpty);

    final journal = await fixture.engine.loadReviewTransaction(eventId);
    expect(journal, isNotNull);
    expect(journal!.isComplete, isTrue);
  });
}

final class _GamificationFixture {
  const _GamificationFixture({
    required this.directory,
    required this.repository,
  });

  final Directory directory;
  final SqliteGamificationRepository repository;

  static Future<_GamificationFixture> create() async {
    sqfliteFfiInit();
    final directory =
        await Directory.systemTemp.createTemp('gamification_6d_test_');
    final repository = await SqliteGamificationRepository.openWithFactory(
      databaseFactoryFfi,
      '${directory.path}/gamification.db',
    );
    return _GamificationFixture(
      directory: directory,
      repository: repository,
    );
  }

  Future<void> dispose() async {
    await repository.close();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

final class _ConversationFixture {
  const _ConversationFixture({
    required this.directory,
    required this.pairStore,
    required this.engine,
    required this.gamification,
    required this.repository,
    required this.pair,
  });

  final Directory directory;
  final PairProgressDatabase pairStore;
  final OfflinePairProgressEngine engine;
  final SqliteGamificationRepository gamification;
  final LearnerRepository repository;
  final ResolvedLanguagePair pair;

  static Future<_ConversationFixture> create() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await PreferencesService.instance();

    sqfliteFfiInit();
    final directory =
        await Directory.systemTemp.createTemp('conversation_6d_test_');
    final pairDatabase = await databaseFactoryFfi.openDatabase(
      '${directory.path}/pair.db',
    );
    final pairStore = await PairProgressDatabase.attach(pairDatabase);
    final engine = OfflinePairProgressEngine(pairStore);
    final gamification = await SqliteGamificationRepository.openWithFactory(
      databaseFactoryFfi,
      '${directory.path}/gamification.db',
    );
    final repository = LearnerRepository(
      prefs,
      persistence: LearnerPersistence(
        prefs,
        LearnerRepository.key,
        LearnerRepository.legacyFavoriteKey,
      ),
      gamificationReviewSink: gamification,
    );
    const pair = _pair;
    await repository.bindPairProgressAuthority(
      engine: engine,
      pair: pair,
    );

    return _ConversationFixture(
      directory: directory,
      pairStore: pairStore,
      engine: engine,
      gamification: gamification,
      repository: repository,
      pair: pair,
    );
  }

  Future<void> dispose() async {
    await gamification.close();
    await pairStore.close();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

const PackPairRequest _request = PackPairRequest(
  sourceLanguageTag: 'ar',
  targetLanguageTag: 'de',
);
const PackRouteDecision _route = PackRouteDecision(
  request: _request,
  availability: PackAvailabilityStatus.available,
  status: PackAcquisitionStatus.localReady,
  localPack: null,
  providerCandidates: <String>[],
);
const ResolvedLanguagePair _pair = ResolvedLanguagePair(
  source: LanguageMetadata(id: 'ar', name: 'Arabic', isRtl: true),
  target: LanguageMetadata(id: 'de', name: 'German', isRtl: false),
  pairKey: 'ar->de',
  generation: 1,
  route: _route,
);
