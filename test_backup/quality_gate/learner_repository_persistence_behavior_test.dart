import 'package:deutsch_bilarabi/core/models/language_catalog_models.dart';
import 'package:deutsch_bilarabi/core/packs/pack_models.dart';
import 'package:deutsch_bilarabi/core/progress/offline_pair_progress_engine.dart';
import 'package:deutsch_bilarabi/core/storage/local_db/pair_progress_database.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('repository saves normalized state and caches the persisted value', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await PreferencesService.instance();
    final persistence = _RecordingPersistence(prefs);
    final repository = LearnerRepository(
      prefs,
      persistence: persistence,
    );
    final input = LearnerState(
      xp: 5,
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    await repository.save(input);

    expect(persistence.events, <String>['normalize', 'save']);
    expect(persistence.saved, isNotNull);
    expect(repository.load().xp, 42);
    expect(identical(repository.load(), persistence.saved), isTrue);
  });

  test('repository mutations use the same normalize-save path', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await PreferencesService.instance();
    final persistence = _RecordingPersistence(prefs);
    final repository = LearnerRepository(
      prefs,
      persistence: persistence,
    );

    await repository.toggleFavoriteVerb('gehen');

    expect(persistence.events, <String>['normalize', 'save']);
    expect(persistence.saved?.favoriteVerbs, contains('gehen'));
    expect(repository.load().favoriteVerbs, contains('gehen'));
  });

  test('pair authority strips legacy pair progress before persistence', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await PreferencesService.instance();
    final persistence = _RecordingPersistence(prefs);
    final repository = LearnerRepository(
      prefs,
      persistence: persistence,
    );

    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final pairStore = await PairProgressDatabase.attach(database);
    addTearDown(pairStore.close);

    const request = PackPairRequest(
      sourceLanguageTag: 'ar',
      targetLanguageTag: 'de',
    );
    const route = PackRouteDecision(
      request: request,
      availability: PackAvailabilityStatus.available,
      status: PackAcquisitionStatus.localReady,
      localPack: null,
      providerCandidates: <String>[],
    );
    const pair = ResolvedLanguagePair(
      source: LanguageMetadata(id: 'ar', name: 'Arabic', isRtl: true),
      target: LanguageMetadata(id: 'de', name: 'German', isRtl: false),
      pairKey: 'ar->de',
      generation: 1,
      route: route,
    );

    await repository.bindPairProgressAuthority(
      engine: OfflinePairProgressEngine(pairStore),
      pair: pair,
    );

    final legacyCard = ReviewCard(
      itemId: 'legacy-concept',
      dueAt: DateTime.utc(2026, 1, 2),
    );
    await repository.save(
      LearnerState(
        learned: <String>{'legacy-concept'},
        review: <String>{'legacy-concept'},
        reviewCards: <String, ReviewCard>{
          legacyCard.storageKey: legacyCard,
        },
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    expect(persistence.events, <String>['normalize', 'save']);
    expect(persistence.saved?.learned, isEmpty);
    expect(persistence.saved?.review, isEmpty);
    expect(persistence.saved?.reviewCards, isEmpty);
  });
}

final class _RecordingPersistence extends LearnerPersistence {
  _RecordingPersistence(PreferencesService prefs)
      : super(
          prefs,
          LearnerRepository.key,
          LearnerRepository.legacyFavoriteKey,
        );

  final List<String> events = <String>[];
  LearnerState? saved;

  @override
  LearnerState normalize(LearnerState state) {
    events.add('normalize');
    return state.copyWith(xp: 42);
  }

  @override
  Future<void> save(LearnerState state) async {
    events.add('save');
    saved = state;
  }

  @override
  LearnerState load() =>
      saved ?? LearnerState(updatedAt: DateTime.utc(2026, 1, 1));
}
