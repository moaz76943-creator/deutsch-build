import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/arabic_german_cognate_bank.dart';

void main() {
  group('ArabicGermanCognateBank Unit Tests (L016)', () {
    test('Contains verified historic Arabic loanwords in German with cultural routes', () {
      expect(ArabicGermanCognateBank.cognates.length, greaterThanOrEqualTo(5));

      final sugar = ArabicGermanCognateBank.cognates.firstWhere((c) => c.germanWord == 'Zucker');
      expect(sugar.arabicOrigin, contains('سُكَّر'));
      expect(sugar.etymologicalRoute, contains('التجارة المتوسطية'));

      final coffee = ArabicGermanCognateBank.cognates.firstWhere((c) => c.germanWord == 'Kaffee');
      expect(coffee.arabicOrigin, contains('قَهْوَة'));
    });
  });
}
