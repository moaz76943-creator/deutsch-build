import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_konjunktiv_two_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave5_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4891 Konjunktiv II Engine Tests', () {
    test('LING-014: Synthetic forms for sein and haben conjugate accurately', () {
      final seinForm = GermanKonjunktivTwoEngine.buildForm(
        verb: 'sein',
        person: GrammaticalPerson.ich,
      );
      expect(seinForm.syntheticForm, equals('wäre'));

      final habenForm = GermanKonjunktivTwoEngine.buildForm(
        verb: 'haben',
        person: GrammaticalPerson.wir,
      );
      expect(habenForm.syntheticForm, equals('hätten'));
    });

    test('LING-014: Modal verb können generates polite request correctly', () {
      final modalForm = GermanKonjunktivTwoEngine.buildForm(
        verb: 'können',
        person: GrammaticalPerson.sieSie,
      );
      expect(modalForm.syntheticForm, equals('könnten'));
      expect(modalForm.politeSample.contains('helfen'), isTrue);
    });

    test('LING-014: Standard verbs construct analytic würde + Infinitiv accurately', () {
      final standardForm = GermanKonjunktivTwoEngine.buildForm(
        verb: 'lernen',
        person: GrammaticalPerson.ich,
        complement: 'gerne Deutsch',
      );
      expect(standardForm.analyticForm, equals('würde gerne Deutsch lernen'));
    });

    test('UI Bridge generates accurate Task 4891 diagnostics report', () {
      final bridge = Vol115Wave5UIBridge();
      final report = bridge.getTask4891Diagnostics();

      expect(report['task_id'], equals(4891));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
