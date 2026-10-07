import 'dart:io';

import 'package:deutsch_bilarabi/core/models/language_catalog_models.dart';
import 'package:deutsch_bilarabi/core/packs/pack_models.dart';
import 'package:deutsch_bilarabi/core/progress/offline_pair_progress_engine.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:deutsch_bilarabi/core/srs_scheduler.dart';
import 'package:deutsch_bilarabi/core/storage/local_db/pair_progress_database.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';
import 'package:deutsch_bilarabi/features/gamification/sqlite_gamification_repository.dart';
import 'package:deutsch_bilarabi/models/content.dart';
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

  test('same reviewEventId is exactly-once across SRS, XP, and attempts',
      () async {
    final fixture = await _ReviewFixture.create();
    addTearDown(fixture.dispose);

    const item = ContentItem(
      id: 'haus',
      german: 'Haus',
      arabic: 'بيت',
      sentence: 'Das Haus ist groß.',
      sentenceAr: 'البيت كبير.',
      topic: 'home',
      skill: 'recall',
    );
    final at = DateTime.utc(2026, 10, 6, 12);
    const reviewEventId =
        'rv1:meaning:1791288000000000:AAAAAAAAAAAAAAAA';

    await fixture.repository.record(
      item: item,
      answer: 'Haus',
      correct: true,
      seconds: 4,
      hinted: false,
      at: at,
      reviewEventId: reviewEventId,
    );
    await fixture.repository.record(
      item: item,
      answer: 'Haus',
      correct: true,
      seconds: 4,
      hinted: false,
      at: at,
      reviewEventId: reviewEventId,
    );

    final reward = unifiedSrsScheduler.xpRewardForReview(
      correct: true,
      hinted: false,
    );
    final pair = await fixture.engine.loadPair(fixture.pair);
    final card = pair.cards.singleWhere((value) => value.cardId == 'haus');
    expect(pair.achievementPoints, reward);
    expect(card.correctCount, 1);
    expect(card.incorrectCount, 0);
    expect(card.reviewCard?.repetitions, 1);

    final learner = await fixture.repository.reloadPersisted();
    expect(
      learner.attempts.where((attempt) => attempt.id == reviewEventId).length,
      1,
    );
    expect(learner.xp, 0);
    expect(learner.streak, 0);

    final gamification = await fixture.gamification.loadSnapshot();
    expect(gamification.profile.totalXp, reward);
    expect(gamification.profile.currentStreak, 1);

    final journal =
        await fixture.engine.loadReviewTransaction(reviewEventId);
    expect(journal, isNotNull);
    expect(journal!.isComplete, isTrue);
  });

  test('reconciler repairs crash after attempt write before journal ACK',
      () async {
    final fixture = await _ReviewFixture.create();
    addTearDown(fixture.dispose);

    final at = DateTime.utc(2026, 10, 6, 13);
    const reviewEventId =
        'rv1:meaning:1791291600000000:BBBBBBBBBBBBBBBB';
    final reward = unifiedSrsScheduler.xpRewardForReview(
      correct: true,
      hinted: false,
    );
    final envelope = ReviewTransactionEnvelope(
      reviewEventId: reviewEventId,
      sourceLanguageId: fixture.pair.source.id,
      targetLanguageId: fixture.pair.target.id,
      conceptId: 'gehen',
      skill: 'recall',
      answer: 'gehen',
      correct: true,
      hinted: false,
      seconds: 3,
      occurredAt: at,
      timezoneOffsetMinutes: 0,
      requestedXp: reward,
    );
    final scheduled = await unifiedSrsScheduler.schedule(
      ReviewCard(itemId: 'gehen', dueAt: at),
      correct: true,
      hinted: false,
      now: at,
    );

    await fixture.engine.persistReviewEnvelope(
      pair: fixture.pair,
      envelope: envelope,
      reviewCard: scheduled,
      learned: true,
      level: 0,
    );

    await fixture.persistence.applyReviewAttemptOnce(
      reviewEventId: reviewEventId,
      attempt: Attempt(
        id: reviewEventId,
        itemId: 'gehen',
        skill: 'recall',
        answer: 'gehen',
        correct: true,
        hinted: false,
        seconds: 3,
        at: at,
      ),
    );

    final beforeRecovery =
        await fixture.engine.loadReviewTransaction(reviewEventId);
    expect(beforeRecovery?.attemptApplied, isFalse);
    expect(beforeRecovery?.gamificationApplied, isFalse);

    final reconciler = ReviewTransactionReconciler(
      pairProgressEngine: fixture.engine,
      learnerPersistence: fixture.persistence,
      gamificationRepository: fixture.gamification,
    );
    final report = await reconciler.reconcilePendingReviewTransactions(
      limit: 128,
    );
    expect(report.inspected, 1);
    expect(report.attemptsAcknowledged, 1);
    expect(report.gamificationAcknowledged, 1);
    expect(report.completed, 1);

    final learner = fixture.persistence.load();
    expect(
      learner.attempts.where((attempt) => attempt.id == reviewEventId).length,
      1,
    );
    expect(learner.xp, 0);
    expect(learner.streak, 0);

    final pair = await fixture.engine.loadPair(fixture.pair);
    expect(pair.achievementPoints, reward);
    expect(
      pair.cards.singleWhere((card) => card.cardId == 'gehen').correctCount,
      1,
    );

    final gamification = await fixture.gamification.loadSnapshot();
    expect(gamification.profile.totalXp, reward);

    final afterRecovery =
        await fixture.engine.loadReviewTransaction(reviewEventId);
    expect(afterRecovery?.isComplete, isTrue);

    final replay = await reconciler.reconcilePendingReviewTransactions(
      limit: 128,
    );
    expect(replay.inspected, 0);
    expect(fixture.persistence.load().xp, 0);
    expect((await fixture.gamification.loadSnapshot()).profile.totalXp, reward);
  });

  test('payload mismatches fail closed at journal, attempt, and gamification',
      () async {
    final fixture = await _ReviewFixture.create();
    addTearDown(fixture.dispose);

    final at = DateTime.utc(2026, 10, 6, 14);
    const reviewEventId =
        'rv1:meaning:1791295200000000:CCCCCCCCCCCCCCCC';
    final reward = unifiedSrsScheduler.xpRewardForReview(
      correct: true,
      hinted: false,
    );
    final envelope = ReviewTransactionEnvelope(
      reviewEventId: reviewEventId,
      sourceLanguageId: fixture.pair.source.id,
      targetLanguageId: fixture.pair.target.id,
      conceptId: 'lernen',
      skill: 'recall',
      answer: 'lernen',
      correct: true,
      hinted: false,
      seconds: 5,
      occurredAt: at,
      timezoneOffsetMinutes: 0,
      requestedXp: reward,
    );
    final scheduled = await unifiedSrsScheduler.schedule(
      ReviewCard(itemId: 'lernen', dueAt: at),
      correct: true,
      hinted: false,
      now: at,
    );
    await fixture.engine.persistReviewEnvelope(
      pair: fixture.pair,
      envelope: envelope,
      reviewCard: scheduled,
      learned: true,
      level: 0,
    );

    final mismatchedEnvelope = ReviewTransactionEnvelope(
      reviewEventId: reviewEventId,
      sourceLanguageId: fixture.pair.source.id,
      targetLanguageId: fixture.pair.target.id,
      conceptId: 'lernen',
      skill: 'recall',
      answer: 'DIFFERENT',
      correct: true,
      hinted: false,
      seconds: 5,
      occurredAt: at,
      timezoneOffsetMinutes: 0,
      requestedXp: reward,
    );
    await expectLater(
      fixture.engine.persistReviewEnvelope(
        pair: fixture.pair,
        envelope: mismatchedEnvelope,
        reviewCard: scheduled,
        learned: true,
        level: 0,
      ),
      throwsA(
        isA<ReviewTransactionJournalException>().having(
          (error) => error.code,
          'code',
          'review_event_payload_mismatch',
        ),
      ),
    );
    expect(
      (await fixture.engine.loadPair(fixture.pair)).achievementPoints,
      reward,
    );

    final originalAttempt = Attempt(
      id: reviewEventId,
      itemId: 'lernen',
      skill: 'recall',
      answer: 'lernen',
      correct: true,
      hinted: false,
      seconds: 5,
      at: at,
    );
    await fixture.persistence.applyReviewAttemptOnce(
      reviewEventId: reviewEventId,
      attempt: originalAttempt,
    );
    await expectLater(
      fixture.persistence.applyReviewAttemptOnce(
        reviewEventId: reviewEventId,
        attempt: Attempt(
          id: reviewEventId,
          itemId: 'lernen',
          skill: 'recall',
          answer: 'DIFFERENT',
          correct: true,
          hinted: false,
          seconds: 5,
          at: at,
        ),
      ),
      throwsA(
        isA<ReviewAttemptApplyException>().having(
          (error) => error.code,
          'code',
          'review_attempt_payload_mismatch',
        ),
      ),
    );
    expect(fixture.persistence.load().xp, 0);

    final originalGamification = GamificationReviewEvent(
      reviewId: reviewEventId,
      facetType: envelope.facetType,
      correct: true,
      hinted: false,
      requestedXp: reward,
      occurredAtUtc: at,
      timezoneOffsetMinutes: 0,
    );
    await fixture.gamification.recordReview(originalGamification);
    await expectLater(
      fixture.gamification.recordReview(
        GamificationReviewEvent(
          reviewId: reviewEventId,
          facetType: envelope.facetType,
          correct: true,
          hinted: false,
          requestedXp: reward + 1,
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
    expect(
      (await fixture.gamification.loadSnapshot()).profile.totalXp,
      reward,
    );
  });
}

final class _ReviewFixture {
  const _ReviewFixture({
    required this.directory,
    required this.pairStore,
    required this.engine,
    required this.gamification,
    required this.persistence,
    required this.repository,
    required this.pair,
  });

  final Directory directory;
  final PairProgressDatabase pairStore;
  final OfflinePairProgressEngine engine;
  final SqliteGamificationRepository gamification;
  final LearnerPersistence persistence;
  final LearnerRepository repository;
  final ResolvedLanguagePair pair;

  static Future<_ReviewFixture> create() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await PreferencesService.instance();

    sqfliteFfiInit();
    final directory =
        await Directory.systemTemp.createTemp('review_transaction_test_');
    final pairDatabase = await databaseFactoryFfi.openDatabase(
      '${directory.path}/pair.db',
    );
    final pairStore = await PairProgressDatabase.attach(pairDatabase);
    final engine = OfflinePairProgressEngine(pairStore);
    final gamification = await SqliteGamificationRepository.openWithFactory(
      databaseFactoryFfi,
      '${directory.path}/gamification.db',
    );
    final persistence = LearnerPersistence(
      prefs,
      LearnerRepository.key,
      LearnerRepository.legacyFavoriteKey,
    );
    final repository = LearnerRepository(
      prefs,
      persistence: persistence,
      gamificationReviewSink: gamification,
    );
    const pair = _pair;
    await repository.bindPairProgressAuthority(
      engine: engine,
      pair: pair,
    );

    return _ReviewFixture(
      directory: directory,
      pairStore: pairStore,
      engine: engine,
      gamification: gamification,
      persistence: persistence,
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
