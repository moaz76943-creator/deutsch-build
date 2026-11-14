import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/german_arabic_proverbs_bank.dart';

void main() {
  group('GermanArabicProverbsBank Unit Tests (L019)', () {
    test('Contains verified high-frequency wisdom proverbs with Arabic matches', () {
      expect(GermanArabicProverbsBank.proverbs.length, greaterThanOrEqualTo(5));

      final practice = GermanArabicProverbsBank.proverbs.firstWhere((p) => p.germanProverb.contains('Meister'));
      expect(practice.arabicEquivalent, contains('الإتقان'));

      final patience = GermanArabicProverbsBank.proverbs.firstWhere((p) => p.germanProverb.contains('Geduld'));
      expect(patience.arabicEquivalent, contains('الصبر مفتاح الفرج'));
    });
  });
}
