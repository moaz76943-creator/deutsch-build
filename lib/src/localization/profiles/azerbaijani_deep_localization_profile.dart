import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Azerbaijani (Azərbaycan dili).
///
/// Turkic language family (Oghuz branch) spoken by 30M+ people.
/// Distinguished by native umlauts (ö, ü) which offer native acoustic transfer
/// to German vowels, open "ə", strict 2-way and 4-way vowel harmony,
/// agglutinative morphology, 6 grammatical cases, and SOV clause architecture.
@immutable
class AzerbaijaniDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool isAgglutinative;
  final bool hasVowelHarmony;
  final bool hasGrammaticalGender;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const AzerbaijaniDeepLocalizationProfile({
    this.languageName = 'Azerbaijani',
    this.autonym = 'Azərbaycan dili',
    this.iso6391 = 'az',
    this.iso6392 = 'aze',
    this.languageFamily = 'Turkic',
    this.branch = 'Oghuz',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (official)',
    this.specialCharacters = const ['ə', 'ı', 'ö', 'ü', 'ç', 'ş', 'ğ'],
    this.isAgglutinative = true,
    this.hasVowelHarmony = true, // Strict front/back and rounding harmony
    this.hasGrammaticalGender = false,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Adlıq hal (Nominativ)': 'Zero suffix (kitab). Direct match to German Nominativ (das Buch).',
      'Yiyəlik hal (Genitiv)': 'Suffix -(n)ın / -(n)in / -(n)un / -(n)ün (kitabın). Direct match to German Genitiv (des Buches).',
      'Təsirlik hal (Akkusativ)': 'Suffix -(n)ı / -(n)i / -(n)u / -(n)ü (kitabı). Mapped to German definite Akkusativ (das Buch / den Mann).',
      'Yönlük hal (Dativ)': 'Suffix -(y)a / -(y)ə (məktəbə). Mapped to German Dativ and directional prepositions (zu, nach).',
      'Yerlik hal (Lokativ)': 'Suffix -da / -də (məktəbdə). Mapped to German Dativ with location prepositions (in, an, bei).',
      'Çıxış hal (Ablativ)': 'Suffix -dan / -dən (məktəbdən). Mapped to German Dativ with source prepositions (aus, von, ab).',
    },
    this.culturalIslamicLexicon = const {
      'salam': 'Friede / Begrüßung (Arabic: سلام)',
      'təşəkkür': 'Dankbarkeit / Danke (Arabic: تشكر)',
      'zəhmət olmasa': 'Bitte / Wenn es keine Mühe macht',
      'kitab': 'Buch (Arabic: كتاب)',
      'məktəb': 'Schule (Arabic: مكتب)',
      'müəllim': 'Lehrer (Arabic: معلم)',
      'elm': 'Wissenschaft / Wissen (Arabic: علم)',
      'ədalət': 'Gerechtigkeit (Arabic: عدالة)',
      'namaz': 'Gebet (Persian/Arabic: نماز / صلاة)',
      'dua': 'Bittgebet (Arabic: دعاء)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'ehsan': 'Güte / Wohltätigkeit (Arabic: إحسان)',
      'bərəkət': 'Segen (Arabic: بركة)',
      'vaxt': 'Zeit (Arabic: وقت)',
      'şəhər': 'Stadt (Persian: شهر)',
      'dost': 'Freund (Persian: دوست)',
    },
    this.germanPhoneticBridges = const {
      'ö /ø/ & ü /y/': 'Direct 1:1 acoustic identity! Azerbaijani "ö" and "ü" (göz, gül) match German "ö" and "ü" (schön, über).',
      'ə /æ/ & ä /ɛ/': 'Azerbaijani "ə" provides an intuitive bridge to German short "ä" (Männer, Hände).',
      'sch /ʃ/': 'Directly corresponds to Azerbaijani "ş" (şəhər, Schule).',
      'ch /ç/': 'Similar to the softened Azerbaijani palatal k/y sound in final positions; refined towards hard palate.',
      'ch /x/': 'Corresponds directly to Azerbaijani "x" (xəbər, Nacht, Buch).',
      'z /ts/': 'Azerbaijani "z" is voiced /z/; German "z" is practiced as affricate /ts/.',
    },
    this.coreA1Vocabulary = const {
      'Salam': 'Hallo / Guten Tag',
      'Sabahınız xeyir': 'Guten Morgen',
      'Hər vaxtınız xeyir': 'Guten Tag',
      'Axşamınız xeyir': 'Guten Abend',
      'Çox sağ olun / Təşəkkür edirəm': 'Vielen Dank',
      'Zəhmət olmasa': 'Bitte',
      'Bəli': 'Ja',
      'Xeyr': 'Nein',
      'Mənim adım': 'Mein Name ist',
      'Haradansınız?': 'Woher kommen Sie?',
      'Mən ...-danam': 'Ich komme aus ...',
      'Su': 'Wasser',
      'Çörək': 'Brot',
      'Aptek': 'Apotheke',
      'Xəstəxana': 'Krankenhaus',
      'Dəmiryol vağzalı': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'azerbaijani': 'Salam! Siz alman dilində danışırsınız?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'azerbaijani': 'Bəli, mən alman dilini öyrənirəm.',
        'german': 'Ja, ich lerne Deutsch.',
        'arabic': 'نعم، أنا أتعلم الألمانية.',
      },
      {
        'azerbaijani': 'Zəhmət olmasa, ən yaxın aptek haradadır?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'azerbaijani': 'Köməyiniz üçün çox təşəkkür edirəm!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Demonstrates the native vowel bridge for German umlauts.
  bool hasNativeGermanUmlauts() {
    return specialCharacters.contains('ö') && specialCharacters.contains('ü');
  }

  /// Maps an Azerbaijani case to its German morphological counterpart.
  String? getGermanCaseEquivalent(String azeriCase) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(azeriCase.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
