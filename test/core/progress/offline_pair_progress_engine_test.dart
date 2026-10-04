import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../lib/core/models/language_catalog_models.dart';
import '../../../lib/core/packs/pack_models.dart';
import '../../../lib/core/progress/offline_pair_progress_engine.dart';
import '../../../lib/core/storage/local_db/pair_progress_database.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('pair progress remains isolated for ar->de and de->ar', () async {
    final database =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final store = await PairProgressDatabase.attach(database);
    final engine = OfflinePairProgressEngine(store);

    final arDe = _pair('ar', 'de', generation: 1);
    final deAr = _pair('de', 'ar', generation: 2);

    await engine.recordCard(
      pair: arDe,
      cardId: 'card-1',
      learned: true,
      level: 7,
      achievementDelta: 30,
      correct: true,
      reviewedAt: DateTime.utc(2026, 10, 4, 12),
    );
    await engine.recordCard(
      pair: deAr,
      cardId: 'card-1',
      learned: false,
      level: 2,
      achievementDelta: 5,
      correct: false,
      reviewedAt: DateTime.utc(2026, 10, 4, 13),
    );

    final forward = await engine.loadPair(arDe);
    final reverse = await engine.loadPair(deAr);

    expect(forward.pairKey, 'ar->de');
    expect(forward.level, 7);
    expect(forward.achievementPoints, 30);
    expect(forward.learnedCardCount, 1);
    expect(forward.cards.single.correctCount, 1);
    expect(forward.cards.single.incorrectCount, 0);

    expect(reverse.pairKey, 'de->ar');
    expect(reverse.level, 2);
    expect(reverse.achievementPoints, 5);
    expect(reverse.learnedCardCount, 0);
    expect(reverse.cards.single.correctCount, 0);
    expect(reverse.cards.single.incorrectCount, 1);

    await store.close();
  });

  test('same card id can exist independently in two directed pairs', () async {
    final database =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final store = await PairProgressDatabase.attach(database);
    final engine = OfflinePairProgressEngine(store);
    final arDe = _pair('ar', 'de', generation: 10);
    final deAr = _pair('de', 'ar', generation: 11);

    await engine.recordCard(
      pair: arDe,
      cardId: 'shared-card',
      learned: true,
      level: 4,
      achievementDelta: 10,
      correct: true,
      reviewedAt: DateTime.utc(2026, 10, 4),
    );
    await engine.recordCard(
      pair: deAr,
      cardId: 'shared-card',
      learned: true,
      level: 9,
      achievementDelta: 50,
      correct: true,
      reviewedAt: DateTime.utc(2026, 10, 5),
    );

    expect((await engine.loadCard(arDe, 'shared-card'))!.pairKey, 'ar->de');
    expect((await engine.loadCard(deAr, 'shared-card'))!.pairKey, 'de->ar');
    expect((await engine.loadPair(arDe)).achievementPoints, 10);
    expect((await engine.loadPair(deAr)).achievementPoints, 50);

    await store.close();
  });

  test('engine rejects malformed pair context and invalid updates', () async {
    final database =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final store = await PairProgressDatabase.attach(database);
    final engine = OfflinePairProgressEngine(store);
    final pair = _pair('ar', 'de', generation: 1);

    await expectLater(
      engine.recordCard(
        pair: pair,
        cardId: '',
        learned: true,
        level: 1,
        achievementDelta: 1,
        correct: true,
        reviewedAt: DateTime.utc(2026, 10, 4),
      ),
      throwsArgumentError,
    );
    await expectLater(
      engine.recordCard(
        pair: pair,
        cardId: 'x',
        learned: true,
        level: 101,
        achievementDelta: 1,
        correct: true,
        reviewedAt: DateTime.utc(2026, 10, 4),
      ),
      throwsArgumentError,
    );
    await expectLater(
      engine.recordCard(
        pair: pair,
        cardId: 'x',
        learned: true,
        level: 1,
        achievementDelta: -1,
        correct: true,
        reviewedAt: DateTime.utc(2026, 10, 4),
      ),
      throwsArgumentError,
    );

    await store.close();
  });
}

ResolvedLanguagePair _pair(
  String source,
  String target, {
  required int generation,
}) =>
    ResolvedLanguagePair(
      source: LanguageMetadata(
        id: source,
        name: source.toUpperCase(),
        isRtl: source == 'ar',
      ),
      target: LanguageMetadata(
        id: target,
        name: target.toUpperCase(),
        isRtl: target == 'ar',
      ),
      pairKey: '$source->$target',
      generation: generation,
      route: PackRouteDecision(
        request: PackPairRequest(
          sourceLanguageTag: source,
          targetLanguageTag: target,
        ),
        availability: PackAvailabilityStatus.available,
        status: PackAcquisitionStatus.localReady,
        localPack: null,
        providerCandidates: const <String>[],
      ),
    );
