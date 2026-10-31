import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Kazakh (Qazaq tili / Қазақ тілі).
///
/// Turkic language family (Kipchak branch) spoken by 18M+ people.
/// Distinguished by native umlauts (ö, ü) which offer native 100% acoustic transfer
/// to German vowels, strict front/back vowel harmony, agglutinative morphology,
/// 7 grammatical cases, and SOV clause architecture.
@immutable
class KazakhDeepLocalizationProfile {
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

  const KazakhDeepLocalizationProfile({
    this.languageName = 'Kazakh',
    this.autonym = 'Qazaq tili',
    this.iso6391 = 'kk',
    this.iso6392 = 'kaz',
    this.languageFamily = 'Turkic',
    this.branch = 'Kipchak (Kipchak-Nogai)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (official transition) / Cyrillic',
    this.specialCharacters = const ['ä', 'ğ', 'q', 'ñ', 'ö', 'ş', 'ü', 'ū', 'y', 'ı'],
    this.isAgglutinative = true,
    this.hasVowelHarmony = true, // Strict front (jıñışke) and back (juan) harmony
    this.hasGrammaticalGender = false,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Ataw septigi (Nominativ)': 'Base form without suffix (kitap). Direct match to German Nominativ (das Buch).',
      'İlik septigi (Genitiv)': 'Suffix -nıñ/-niñ/-dıñ/-diñ/-tıñ/-tiñ (kitaptıñ). Direct match to German Genitiv (des Buches).',
      'Barıs septigi (Dativ / Allativ)': 'Suffix -ğa/-ge/-qa/-ke (mektepke). Mapped to German Dativ and directional prepositions (zu, nach).',
      'Tabıs septigi (Akkusativ)': 'Suffix -nı/-ni/-dı/-di/-tı/-ti (kitaptı). Mapped to German definite Akkusativ (das Buch / den Mann).',
      'Jatıs septigi (Lokativ)': 'Suffix -da/-de/-ta/-te (mektepte). Mapped to German Dativ with static prepositions (in, an, bei).',
      'Şığıs septigi (Ablativ)': 'Suffix -dan/-den/-tan/-ten/-nan/-nen (mektepten). Mapped to German Dativ with source prepositions (aus, von, ab).',
      'Kömektes septigi (Instrumentalis)': 'Suffix -men/-ben/-pen (dostpen). Direct bridge to German Dativ with preposition "mit" (mit dem Freund).',
    },
    this.culturalIslamicLexicon = const {
      'sälem': 'Friede / Begrüßung (Arabic: سلام)',
      'as-salamu aleykum': 'Friede sei mit euch (Arabic: السلام عليكم)',
      'raqmet': 'Danke / Barmherzigkeit (Arabic: رحمة)',
      'ötinem / marxabat': 'Bitte (Arabic: مرحمة)',
      'kitap': 'Buch (Arabic: كتاب)',
      'mektep': 'Schule (Arabic: مكتب)',
      'muğalim': 'Lehrer (Arabic: معلم)',
      'ğılım': 'Wissenschaft (Arabic: علم)',
      'ädildik': 'Gerechtigkeit (Arabic: عدالة)',
      'namaz': 'Gebet / Salāt (Persian/Arabic: نماز / صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'dos': 'Freund (Persian: دوست)',
      'su': 'Wasser',
      'nan': 'Brot',
      'üy': 'Haus',
      'qala': 'Stadt',
      'auruxana': 'Krankenhaus',
      'därixana': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'ö /ø/ & ü /y/': '100% Native Identity! Kazakh "ö" (көз / köz) and "ü" (гүл / gül) perfectly match German "ö" (schön) and "ü" (über).',
      'ä /æ/ & ä /ɛ/': 'Kazakh "ä" (ә / ä) provides an immediate intuitive bridge to German "ä" (Männer, Äpfel).',
      'sch /ʃ/': 'Direct 1:1 match to Kazakh "ş" (ш / ş) (e.g., şay, Schule).',
      'ch /x/ (ach-Laut)': 'Direct match to Kazakh "x" and uvular "q" (xat, Bach, Nacht).',
      'z /ts/': 'Kazakh "z" is voiced /z/; German "z" is an affricate /ts/, practiced as "t+s" compound.',
    },
    this.coreA1Vocabulary = const {
      'Sälem': 'Hallo / Guten Tag',
      'Qayırlı tañ': 'Guten Morgen',
      'Qayırlı kün': 'Guten Tag',
      'Qayırlı keş': 'Guten Abend',
      'Ülken raqmet': 'Vielen Dank',
      'Ötinem': 'Bitte',
      'Iä': 'Ja',
      'Jox': 'Nein',
      'Meniñ atım': 'Mein Name ist',
      'Qaydansız?': 'Woher kommen Sie?',
      'Men ...-danmın': 'Ich komme aus ...',
      'Su': 'Wasser',
      'Nan': 'Brot',
      'Därixana': 'Apotheke',
      'Auruxana': 'Krankenhaus',
      'Temirjol vokzalı': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'kazakh': 'Sälemetsiz be! Siz nemisşe söyleysiz be?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'kazakh': 'Iä, men qazir nemis tilin üyrenip jatırmın.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'kazakh': 'Kemeşilik etpeñiz, eñ jaqın därixana qayda?',
        'german': 'Entschuldigung, wo ist die nächste Apotheke?',
        'arabic': 'عفواً، أين تقع أقرب صيدلية؟',
      },
      {
        'kazakh': 'Kömegiñizge köp raqmet!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Confirms that Kazakh natively possesses German umlauts ö and ü.
  bool hasNativeGermanUmlauts() {
    return specialCharacters.contains('ö') && specialCharacters.contains('ü');
  }

  /// Translates Kazakh case name to German morphological and prepositional counterpart.
  String? getGermanCaseBridge(String septikName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(septikName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
