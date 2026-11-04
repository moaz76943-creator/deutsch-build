import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Armenian (Հայերեն / Hayeren).
///
/// Independent Indo-European branch spoken by 7M+ people worldwide. Characterized by
/// the unique 39-letter Armenian alphabet (created by Mesrop Mashtots in 405 AD),
/// an agglutinative 7-case nominal system, exact 1:1 match of Armenian affricates
/// (Ծ/ծ, Ց/ց) to German 'Z/z' (/ts/), and SOV/SVO flexible syntax.
@immutable
class ArmenianDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
  @override
  final String languageName;
  @override
  final String autonym;
  @override
  final String iso6391;
  @override
  final String iso6392or3;
  @override
  final TypologicalClassification typology;
  @override
  final CanonicalWordOrder primaryWordOrder;
  @override
  final GrammaticalAlignment alignment;
  @override
  final bool hasTones;
  @override
  final bool hasGrammaticalGender;

  final String writingDirection;
  final String primaryScript;
  final int alphabetLetterCount;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const ArmenianDeepLocalizationProfile({
    this.languageName = 'Armenian',
    this.autonym = 'Հայերեն',
    this.iso6391 = 'hy',
    this.iso6392or3 = 'hye',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.sov,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Armenian alphabet (Հայոց գրեր)',
    this.alphabetLetterCount = 39,
    this.caseSystemAlignment = const {
      '1. Ուղղական (Nominativ)': 'Direct subject form (մարդը). Maps to German Nominativ (der Mann).',
      '2. Հայցական (Akkusativ)': 'Direct object; identical to Dative for humans, Nominative for inanimates. Maps to German Akkusativ.',
      '3. Սեռական (Genitiv - -ի / -i)': 'Possession (ուսուցչի գիրքը). Directly maps to German Genitiv (des Lehrers Buch).',
      '4. Տրական (Dativ)': 'Recipient and goal. Directly maps to German Dativ (dem Mann).',
      '5. Բացառական (Ablativ - -ից / -its)': 'Source and separation (տանից). Maps to German Dativ with prepositions "aus" and "von".',
      '6. Գործիական (Instrumentalis - -ով / -ov)': 'Means or instrument (մեքենայով). Maps to German Dativ with preposition "mit".',
      '7. Ներգոյական (Lokativ - -ում / -um)': 'Location inside (քաղաքում). Maps to German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'բարև / բարև ձեզ / սալամ': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'շնորհակալություն / շնորհակալ եմ': 'Danke / Vielen Dank',
      'խնդրեմ': 'Bitte',
      'գիրք': 'Buch',
      'դպրոց / մադրասա': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'ուսուցիչ / դասախոս': 'Lehrer / Dozent',
      'գիտելիք / գիտություն': 'Wissen / Wissenschaft',
      'արդարություն': 'Gerechtigkeit',
      'աղոթք / նամազ': 'Gebet / Salāt (Persian: نماز)',
      'հալալ': 'Erlaubt / Halal (Arabic: حلال)',
      'ընկեր / բարեկամ': 'Freund',
      'ջուր': 'Wasser',
      'հաց': 'Brot / Nahrung',
      'տուն': 'Haus / Heim',
      'քաղաք': 'Stadt',
      'հիվանդանոց': 'Krankenhaus',
      'դեղատուն': 'Apotheke',
      'մզկիթ': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Armenian "Ծ / ծ" (/ts/) and aspirated "Ց / ց" (/tsʰ/) natively match German "z" (Zeit, Ziel, Zimmer) with zero distortion!',
      'sch /ʃ/': 'Direct 1:1 match to Armenian "Շ / շ" (շուկա, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Armenian "Ճ / ճ" and "Չ / չ" (Deutschland!).',
      'ch /x/ (ach-Laut)': 'Direct 1:1 match to Armenian "Խ / խ" (հաց, խոսք, Bach, Nacht).',
    },
    this.coreA1Vocabulary = const {
      'Բարև / Բարև ձեզ': 'Hallo / Guten Tag',
      'Բարի լույս': 'Guten Morgen',
      'Բարի օր': 'Guten Tag',
      'Բարի երեկո': 'Guten Abend',
      'Շատ շնորհակալություն': 'Vielen Dank',
      'Խնդրեմ': 'Bitte',
      'Այո': 'Ja',
      'Ոչ': 'Nein',
      'Իմ անունն է ...': 'Mein Name ist ...',
      'Որտեղի՞ց եք դուք': 'Woher kommen Sie?',
      'Ես ...-ից եմ': 'Ich komme aus ...',
      'Ջուր': 'Wasser',
      'Հաց': 'Brot',
      'Հիվանդանոց': 'Krankenhaus',
      'Դեղատուն': 'Apotheke',
      'Երկաթուղային կայարան': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'armenian': 'Բարև ձեզ! Դուք խոսո՞ւմ եք գերմաներեն:',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'armenian': 'Այո, ես հիմա սովորում եմ գերմաներեն:',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'armenian': 'Կներեք, որտե՞ղ է գտնվում ամենամոտ դեղատունը:',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'armenian': 'Շատ շնորհակալություն ձեր օգնության համար!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Armenian case to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
