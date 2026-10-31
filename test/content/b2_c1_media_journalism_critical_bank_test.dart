import 'package:test/test.dart';
import '../../lib/src/content/b2_c1_media_journalism_critical_bank.dart';

void main() {
  group('B2C1MediaJournalismCriticalBank Unit Tests (L014)', () {
    test('Contains journalism and critical analysis terms with ethical foundation', () {
      expect(B2C1MediaJournalismCriticalBank.mediaEntries.length, greaterThanOrEqualTo(5));

      final credibility = B2C1MediaJournalismCriticalBank.mediaEntries.firstWhere((e) => e.germanWord == 'die Glaubwürdigkeit');
      expect(credibility.arabicMeaning, contains('المصداقية'));
      expect(credibility.cefrLevel, equals('B2'));

      final facts = B2C1MediaJournalismCriticalBank.mediaEntries.firstWhere((e) => e.germanWord == 'die Faktenprüfung');
      expect(facts.arabicMeaning, contains('تدقيق الحقائق'));
      expect(facts.cefrLevel, equals('C1'));
    });
  });
}
