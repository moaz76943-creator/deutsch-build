import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_adjective_declension_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave4_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4890 Adjective Declension Engine Tests', () {
    test('LING-013: Weak declension inflects correctly after definite articles', () {
      // der gute Mann (Nom Mas)
      final res1 = GermanAdjectiveDeclensionEngine.inflect(
        adjective: 'gut',
        type: DeclensionType.weak,
        gramCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.maskulin,
      );
      expect(res1.fullInflectedForm, equals('gute'));

      // den guten Mann (Akk Mas)
      final res2 = GermanAdjectiveDeclensionEngine.inflect(
        adjective: 'gut',
        type: DeclensionType.weak,
        gramCase: GrammaticalCase.akkusativ,
        gender: GrammaticalGender.maskulin,
      );
      expect(res2.fullInflectedForm, equals('guten'));

      // dem guten Mann (Dat Mas)
      final res3 = GermanAdjectiveDeclensionEngine.inflect(
        adjective: 'gut',
        type: DeclensionType.weak,
        gramCase: GrammaticalCase.dativ,
        gender: GrammaticalGender.maskulin,
      );
      expect(res3.fullInflectedForm, equals('guten'));
    });

    test('LING-013: Mixed declension inflects correctly after indefinite articles', () {
      // ein schönes Buch (Nom/Akk Neu)
      final res = GermanAdjectiveDeclensionEngine.inflect(
        adjective: 'schoen',
        type: DeclensionType.mixed,
        gramCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.neutral,
      );
      expect(res.fullInflectedForm, equals('schoenes'));
      expect(res.suffix, equals('es'));
    });

    test('LING-013: Strong declension applies signal endings without articles', () {
      // frische Milch (Nom Fem) -> -e
      final res1 = GermanAdjectiveDeclensionEngine.inflect(
        adjective: 'frisch',
        type: DeclensionType.strong,
        gramCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.feminin,
      );
      expect(res1.fullInflectedForm, equals('frische'));

      // kaltem Wasser (Dat Neu) -> -em
      final res2 = GermanAdjectiveDeclensionEngine.inflect(
        adjective: 'kalt',
        type: DeclensionType.strong,
        gramCase: GrammaticalCase.dativ,
        gender: GrammaticalGender.neutral,
      );
      expect(res2.fullInflectedForm, equals('kaltem'));
    });

    test('UI Bridge generates accurate Task 4890 diagnostics report', () {
      final bridge = Vol115Wave4UIBridge();
      final report = bridge.getTask4890Diagnostics();

      expect(report['task_id'], equals(4890));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
