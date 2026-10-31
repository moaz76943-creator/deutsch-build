import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Zulu (isiZulu).
///
/// Southern Bantu (Nguni) language spoken by 28M+ people in South Africa and Southern Africa.
/// Features 15 noun classes (genders) marked by prefixal concord, famous Khoisan-derived
/// click consonants (c, q, x), agglutinative prefixing/suffixing morphology, and comprehensive
/// omnidirectional cross-lingual transfer across African and European languages.
@immutable
class ZuluDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final int nounClassCount; // 15 noun classes!
  final List<String> clickConsonants; // c, q, x
  final Map<String, String> nounClassConcordBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const ZuluDeepLocalizationProfile({
    this.languageName = 'Zulu',
    this.autonym = 'isiZulu',
    this.iso6391 = 'zu',
    this.iso6392or3 = 'zul',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true,
    this.hasGrammaticalGender = true, // 15 noun classes/genders!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Zulu alphabet)',
    this.nounClassCount = 15,
    this.clickConsonants = const ['c (Dental click /ǀ/)', 'q (Postalveolar click /ǃ/)', 'x (Alveolar-lateral click /ǁ/)'],
    this.nounClassConcordBridge = const {
      '15-Noun-Class Concord': 'isiZulu classifies all nouns into 15 prefixal classes (umu-/aba- people, ili-/ama- natural pairs, isi-/izi- languages/objects). Because Zulu speakers operate 15 grammatical genders natively, German\'s 3-gender system (der, die, das) is easily mastered without conceptual resistance.',
      'Locative Prefixation (e-...-ini)': 'Zulu locative circumposition e-khaya-ini -> ekhaya (at home). Maps directly to German static prepositions with Dativ (zu Hause, in der Stadt).',
    },
    this.culturalIslamicLexicon = const {
      'sawubona / sanibonani / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ngiyabonga / ngiyabonga kakhulu': 'Danke / Vielen Dank',
      'ngicela / uxolo': 'Bitte / Entschuldigung',
      'incwadi': 'Buch',
      'isikole / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'uthisha / umfundisi': 'Lehrer / Dozent',
      'ulwazi / isayensi': 'Wissen / Wissenschaft',
      'ubulungiswa': 'Gerechtigkeit',
      'umthandazo / salah': 'Gebet / Salāt (Arabic: صلاة)',
      'i-halal': 'Erlaubt / Halal (Arabic: حلال)',
      'umngane': 'Freund',
      'amanzi': 'Wasser',
      'isinkwa': 'Brot / Nahrung',
      'indlu / ikhaya': 'Haus / Heim',
      'idolobha': 'Stadt',
      'isibhedlela': 'Krankenhaus',
      'ikhemisi': 'Apotheke',
      'i-mosque / i-masjid': 'Moschee (Arabic: جامع / مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Zulu "Sh / sh" (ishumi, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Zulu "Tsh / tsh" (tshala, Deutschland).',
      'z /ts/': 'Zulu "z" is voiced /z/; German "z" is practiced as the compound sequence "t+s" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Direct match to Zulu "H / h" or velar fricative releases in northern dialects (Bach, Nacht).',
    },
    this.coreA1Vocabulary = const {
      'Sawubona / Sanibonani': 'Hallo / Guten Tag',
      'Sawubona ekuseni': 'Guten Morgen',
      'Sawubona emini': 'Guten Tag',
      'Sawubona kusihlwa': 'Guten Abend',
      'Ngiyabonga kakhulu': 'Vielen Dank',
      'Ngicela': 'Bitte',
      'Yebo': 'Ja',
      'Cha': 'Nein',
      'Igama lami ngu ...': 'Mein Name ist ...',
      'Uvelaphi?': 'Woher kommen Sie?',
      'Ngivela e ...': 'Ich komme aus ...',
      'Amanzi': 'Wasser',
      'Isinkwa': 'Brot',
      'Isibhedlela': 'Krankenhaus',
      'Ikhemisi': 'Apotheke',
      'Isiteshi sesitimela': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'zulu': 'Sawubona! Ingabe uyasikhuluma isiJalimane?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'zulu': 'Yebo, ngifunda isiJalimane manje.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'zulu': 'Ngicela ungitshele, ikhemisi eliseduze likuphi?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'zulu': 'Ngiyabonga kakhulu ngosizo lwakho!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
