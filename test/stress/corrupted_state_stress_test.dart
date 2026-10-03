import 'dart:convert';

import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:deutsch_bilarabi/services/learner_persistence.dart';
import 'package:deutsch_bilarabi/services/preferences_service.dart';
import 'package:deutsch_bilarabi/services/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stress_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<({PreferencesService prefs, LearnerPersistence persistence, LearnerRepository repository})>
      harness(Map<String, Object> initial) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await PreferencesService.instance();
    final persistence = LearnerPersistence(
      prefs,
      LearnerRepository.key,
      LearnerRepository.legacyFavoriteKey,
    );
    return (
      prefs: prefs,
      persistence: persistence,
      repository: LearnerRepository(prefs, persistence: persistence),
    );
  }

  test('corrupted primary state fails closed and rewrites itself as valid state', () async {
    final h = await harness(<String, Object>{
      LearnerRepository.key: '{"xp": 999999, "attempts": [BROKEN',
    });

    final recovered = h.repository.load();
    expect(recovered.xp, 0);
    expect(recovered.attempts, isEmpty);
    expect(recovered.reviewCards, isEmpty);

    await h.repository.record(
      item: const StressLearningContent(id: 'stress-corrupt-recovery'),
      answer: '',
      correct: false,
      seconds: -999,
      hinted: false,
      at: DateTime.utc(2026, 1, 1),
    );

    final raw = h.prefs.getString(LearnerRepository.key);
    expect(raw, isNotNull);
    expect(() => jsonDecode(raw!), returnsNormally);

    final durable = h.repository.reload();
    expect(durable.attempts, hasLength(1));
    expect(durable.attempts.single.seconds, 0);
    expect(durable.review, contains('stress-corrupt-recovery'));
    expect(durable.reviewCards, contains('stress-corrupt-recovery'));
  });

  test('partially corrupt records are isolated while valid progress survives', () async {
    final validAt = DateTime.utc(2026, 1, 2);
    final payload = jsonEncode(<String, Object?>{
      'xp': LearnerPersistence.maxXp * 100,
      'streak': -500,
      'learned': <Object?>[' kept ', '', 9, List<String>.filled(161, 'x').join()],
      'attempts': <Object?>[
        'not-an-attempt',
        <String, Object?>{
          'id': 'good-attempt',
          'itemId': 'concept-1',
          'skill': 'recall',
          'answer': 'ok',
          'correct': true,
          'hinted': false,
          'seconds': 9,
          'at': validAt.toIso8601String(),
        },
        <String, Object?>{
          'id': <String, Object?>{'malformed': true},
          'itemId': 'bad',
        },
      ],
      'reviewCards': <String, Object?>{
        'garbage': 'not-a-card',
        'concept-1': <String, Object?>{
          'itemId': 'concept-1',
          'dueAt': validAt.toIso8601String(),
          'difficulty': 1.4,
        },
      },
      'updatedAt': '2999-01-01T00:00:00.000Z',
    });
    final h = await harness(<String, Object>{LearnerRepository.key: payload});

    final state = h.repository.load();

    expect(state.xp, LearnerPersistence.maxXp);
    expect(state.streak, 0);
    expect(state.learned, <String>{'kept'});
    expect(state.attempts, hasLength(1));
    expect(state.attempts.single.id, 'good-attempt');
    expect(state.reviewCards, hasLength(1));
    expect(state.reviewCards, contains('concept-1'));
    expect(
      state.updatedAt.isBefore(DateTime.now().add(const Duration(days: 1, minutes: 1))),
      isTrue,
    );
  });

  test('oversized persistence payload is rejected deterministically before storage write', () async {
    final h = await harness(const <String, Object>{});
    final suffix = List<String>.filled(150, 'x').join();
    final huge = List<String>.generate(
      10000,
      (index) => "${index.toString().padLeft(5, '0')}_$suffix",
      growable: false,
    ).toSet();

    final oversized = LearnerState(
      learned: huge,
      review: huge,
      favoriteVerbs: huge,
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    await expectLater(
      h.persistence.save(oversized),
      throwsA(
        isA<LearnerPersistenceFailure>().having(
          (failure) => failure.code,
          'code',
          LearnerPersistenceFailureCode.payloadTooLarge,
        ),
      ),
    );
    expect(h.prefs.getString(LearnerRepository.key), isNull);
  });
}
