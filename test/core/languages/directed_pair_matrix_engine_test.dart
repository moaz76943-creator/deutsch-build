import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_profile.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/directed_pair_matrix_engine.dart';

void main() {
  group('DirectedPairMatrixEngine Tests (A -> B != B -> A)', () {
    late DeclarativeLanguageEngine langEngine;
    late DirectedPairMatrixEngine matrixEngine;

    setUp(() {
      langEngine = DeclarativeLanguageEngine()..initialize();
      matrixEngine = DirectedPairMatrixEngine();
    });

    test('Computes asymmetric friction for ar -> de vs en -> de', () {
      final ar = langEngine.getProfile('ar')!;
      final de = langEngine.getProfile('de')!;
      final en = langEngine.getProfile('en')!;

      final arDe = matrixEngine.getOrCreatePairConfig(ar, de);
      final enDe = matrixEngine.getOrCreatePairConfig(en, de);

      expect(arDe.pairId, equals('ar_de'));
      expect(enDe.pairId, equals('en_de'));

      // ar -> de has RTL-LTR flip and VSO-SVO shift, thus higher cognitive friction than en -> de
      expect(arDe.requiresBidiFlipping, isTrue);
      expect(enDe.requiresBidiFlipping, isFalse);
      expect(arDe.cognitiveFrictionScore, greaterThan(enDe.cognitiveFrictionScore));
      expect(arDe.primaryInterferenceAreas, contains('Bi-directional (RTL/LTR) Script Transition'));
    });

    test('Demonstrates non-symmetry: A -> B != B -> A interference parameters', () {
      final ar = langEngine.getProfile('ar')!;
      final de = langEngine.getProfile('de')!;

      final arDe = matrixEngine.getOrCreatePairConfig(ar, de);
      final deAr = matrixEngine.getOrCreatePairConfig(de, ar);

      expect(arDe.pairId, equals('ar_de'));
      expect(deAr.pairId, equals('de_ar'));
      expect(arDe.primaryInterferenceAreas, contains('Case Morphology Expansion (+1 cases)'));
      // de has 4 cases, ar has 3 cases; de -> ar does not trigger case expansion
      expect(deAr.primaryInterferenceAreas.any((a) => a.contains('Case Morphology Expansion')), isFalse);
    });
  });
}
