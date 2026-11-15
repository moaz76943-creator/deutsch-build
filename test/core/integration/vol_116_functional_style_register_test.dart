import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_functional_style_register_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave14_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4914 Functional Style Register Tests', () {
    test('LING-037: Everyday verb stem maps to formal functional collocation', () {
      final res = GermanFunctionalStyleRegisterEngine.elevateStyle(
        subject: 'Der Ausschuss',
        everydayVerbStem: 'entscheiden',
        baseSentence: 'Der Ausschuss entscheidet heute.',
      );

      expect(res.matchedPattern, equals('eine entscheidung treffen'));
      expect(res.arabicExplanation, contains('اتخاذ قرار'));
      expect(res.targetRegister, equals(LanguageRegister.elevatedFormalAcademic));
    });

    test('LING-037: Academic verbs like kritisieren map to Kritik üben', () {
      final res = GermanFunctionalStyleRegisterEngine.elevateStyle(
        subject: 'Die Medien',
        everydayVerbStem: 'kritisieren',
        baseSentence: 'Die Medien kritisieren den Plan.',
      );

      expect(res.matchedPattern, equals('kritik ueben'));
      expect(res.arabicExplanation, contains('ممارسة النقد'));
    });

    test('UI Bridge generates accurate Task 4914 diagnostics report', () {
      final bridge = Vol116Wave14UIBridge();
      final report = bridge.getTask4914Diagnostics();

      expect(report['task_id'], equals(4914));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(86));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
