import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/speech/continuous_read_aloud_engine.dart';

void main() {
  group('ContinuousReadAloudEngine Tests', () {
    late ContinuousReadAloudEngine engine;

    setUp(() {
      engine = ContinuousReadAloudEngine();
    });

    test('Loads paragraph and advances token tracking without interrupting', () {
      engine.loadParagraph('Das ist ein schönes Haus');

      expect(engine.tokens.length, equals(5));
      expect(engine.tokens.first.status, equals(ReadAloudTokenStatus.current));

      engine.onSpokenWordObserved('Das', isAccurate: true);
      expect(engine.tokens[0].status, equals(ReadAloudTokenStatus.correct));
      expect(engine.tokens[1].status, equals(ReadAloudTokenStatus.current));

      engine.onSpokenWordObserved('ist', isAccurate: false); // Mispronounced
      expect(engine.tokens[1].status, equals(ReadAloudTokenStatus.mispronounced));

      final report = engine.finalizeReport();
      expect(report.correctWordsCount, equals(1));
      expect(report.mispronouncedCount, equals(1));
      expect(report.skippedCount, equals(3));
    });
  });
}
