import 'dart:io';
import 'package:test/test.dart';
import '../../../lib/polyglot_core.dart';

void main() {
  group('Task #4989: Zero-Config Bootstrap & Reactive Study Session Controller Tests', () {
    late PolyglotAppBootstrap app;
    late PolyglotStudySessionController session;

    setUp(() {
      final extraPack = File('assets/packs/de_medicine_business_expansion.json').readAsStringSync();
      app = PolyglotAppBootstrap.initialize(extraJsonPacks: [extraPack]);
      session = app.createSessionController();
    });

    tearDown(() async {
      await session.dispose();
      await app.dispose();
    });

    test('Initializes complete unified registry with 350+ units in 1 call', () {
      expect(app.registry.allUnits.length, greaterThanOrEqualTo(350));
      expect(
        app.registry.queryUnits(searchQuery: 'auffälligen Befund'),
        isNotEmpty,
      );
    });

    test('Runs full interactive session lifecycle and updates accuracy & SRS', () async {
      final emissions = <PolyglotSessionState>[];
      final sub = session.stateStream.listen(emissions.add);

      session.startSession(languageCode: 'de', limit: 2);
      expect(session.state.isCompleted, isFalse);
      expect(session.state.currentExercise, isNotNull);

      final ex1 = session.state.currentExercise!;
      final res1 = session.submitAnswer(ex1.correctOptionIndex);
      expect(res1?.isCorrect, isTrue);
      expect(session.state.accuracyRate, equals(1.0));

      session.advanceToNext();
      expect(session.state.currentIndex, equals(1));

      final ex2 = session.state.currentExercise!;
      session.submitAnswer(ex2.correctOptionIndex);
      session.advanceToNext();
      expect(session.state.isCompleted, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emissions.length, equals(5));
      await sub.cancel();
    });
  });
}
