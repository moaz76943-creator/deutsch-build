import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/burmese_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('BurmeseDeepLocalizationProfile Tests', () {
    const profile = BurmeseDeepLocalizationProfile();

    test('Linguistic properties correctly model Sino-Tibetan Burmese standard', () {
      expect(profile.languageName, equals('Burmese'));
      expect(profile.iso6391, equals('my'));
      expect(profile.iso6392or3, equals('mya'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.hasTones, isTrue);
      expect(profile.toneCount, equals(4));
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Wibat postpositional case alignment bridges to German declensions', () {
      expect(profile.wibatCaseAlignment.length, greaterThanOrEqualTo(5));
      expect(profile.getGermanCaseBridge('Subject'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Object'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Dative'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Genitive'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Instrumental'), contains('mit'));
    });

    test('Phonetic bridge identifies native match and SOV subordinate mirror', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ရှ')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('SOV Verb-Final')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('မင်္ဂလာပါ / စလာမ်'));
      expect(profile.culturalIslamicLexicon.keys, contains('ဟလာလ်'));
      expect(profile.culturalIslamicLexicon.keys, contains('ဗလီ / မတ်စ်ဂျစ်ဒ်'));
      expect(profile.coreA1Vocabulary['ကျေးဇူးအများကြီးတင်ပါတယ်'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
