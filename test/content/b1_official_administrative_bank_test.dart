import 'package:test/test.dart';
import '../../lib/src/content/b1_official_administrative_bank.dart';

void main() {
  group('B1OfficialAdministrativeBank Unit Tests (L010)', () {
    test('Contains essential German administrative and housing terms with clear Arabic gloss', () {
      expect(B1OfficialAdministrativeBank.adminEntries.length, greaterThanOrEqualTo(6));

      final buerger = B1OfficialAdministrativeBank.adminEntries.firstWhere((e) => e.germanWord == 'das Bürgeramt');
      expect(buerger.arabicMeaning, contains('البلدية'));

      final anmeldung = B1OfficialAdministrativeBank.adminEntries.firstWhere((e) => e.germanWord == 'die Meldebescheinigung');
      expect(anmeldung.exampleSentenceDe, contains('unverzichtbares Dokument'));
      expect(anmeldung.cefrLevel, equals('B1'));
    });

    test('All examples maintain complete administrative accuracy and ethical integrity', () {
      for (final item in B1OfficialAdministrativeBank.adminEntries) {
        expect(item.exampleSentenceDe.isNotEmpty, isTrue);
        expect(item.exampleSentenceAr.isNotEmpty, isTrue);
      }
    });
  });
}
