import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/localization/profiles/persian_deep_localization_profile.dart';

void main() {
  group('PersianDeepLocalizationProfile Unit Tests (Task 403)', () {
    test('Contains verified Indo-European cognates (Mādar/Mutter, Barādar/Bruder, Nām/Name)', () {
      expect(PersianDeepLocalizationProfile.ancestralCognates.length, greaterThanOrEqualTo(5));

      final mother = PersianDeepLocalizationProfile.ancestralCognates.first;
      expect(mother.persianWord, contains('مادر'));
      expect(mother.germanWord, equals('Mutter'));

      final isVerb = PersianDeepLocalizationProfile.ancestralCognates.last;
      expect(isVerb.persianWord, contains('است'));
      expect(isVerb.germanWord, equals('Ist'));
    });

    test('Identifies Persian specific letters (گ، چ، پ، ژ) correctly', () {
      expect(PersianDeepLocalizationProfile.containsPersianSpecificLetters('پژوهش'), isTrue);
      expect(PersianDeepLocalizationProfile.containsPersianSpecificLetters('كتاب'), isFalse);
    });
  });
}
