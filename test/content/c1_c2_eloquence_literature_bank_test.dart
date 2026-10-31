import 'package:test/test.dart';
import '../../lib/src/content/c1_c2_eloquence_literature_bank.dart';

void main() {
  group('C1C2EloquenceLiteratureBank Unit Tests (L015)', () {
    test('Contains advanced C1/C2 rhetorical, literary, and argumentation vocabulary', () {
      expect(C1C2EloquenceLiteratureBank.eloquenceEntries.length, greaterThanOrEqualTo(5));

      final eloquence = C1C2EloquenceLiteratureBank.eloquenceEntries.firstWhere((e) => e.germanWord == 'die Beredsamkeit');
      expect(eloquence.arabicMeaning, contains('الفصاحة والبلاغة'));
      expect(eloquence.cefrLevel, equals('C1'));

      final nuance = C1C2EloquenceLiteratureBank.eloquenceEntries.firstWhere((e) => e.germanWord == 'die Nuance');
      expect(nuance.cefrLevel, equals('C2'));
      expect(nuance.arabicMeaning, contains('الفرق الدقيق'));
    });
  });
}
