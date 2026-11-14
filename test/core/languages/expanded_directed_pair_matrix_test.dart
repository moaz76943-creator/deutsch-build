import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_profile.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/expanded_directed_pair_matrix.dart';

void main() {
  group('ExpandedDirectedPairMatrix Tests', () {
    const matrix = ExpandedDirectedPairMatrix();
    late DeclarativeLanguageEngine engine;

    setUp(() {
      engine = DeclarativeLanguageEngine()..initialize();
    });

    test('Confirms directional asymmetry: D(A -> B) != D(B -> A)', () {
      final ar = engine.getProfile('ar')!;
      final de = engine.getProfile('de')!;

      final arToDe = matrix.computeDirectionalFriction(ar, de);
      final deToAr = matrix.computeDirectionalFriction(de, ar);

      expect(arToDe, greaterThan(0.5));
      expect(deToAr, greaterThan(0.5));
      // Asymmetric distance must not be strictly identical
      expect(arToDe, isNot(equals(deToAr)));
    });
  });
}
