import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Basque (Euskara).
///
/// Pre-Indo-European language isolate spoken by 1M+ people in the Basque Country
/// (Spain and France). Features ergative-absolutive alignment (-k marks ergative),
/// polypersonal auxiliary verbs agreeing with subject, direct object, and indirect
/// object simultaneously, 17 agglutinative nominal cases, and SOV syntax.
@immutable
class BasqueDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
  @override
  final String languageName = 'Basque';
  @override
  final String autonym = 'Euskara';
  @override
  final String iso6391 = 'eu';
  @override
  final String iso6392or3 = 'eus';
  @override
  final TypologicalClassification typology = TypologicalClassification.agglutinative;
  @override
  final CanonicalWordOrder primaryWordOrder = CanonicalWordOrder.sov;
  @override
  final GrammaticalAlignment alignment = GrammaticalAlignment.ergativeAbsolutive;
  @override
  final bool hasTones = false;
  @override
  final bool hasGrammaticalGender = false;

  final String writingDirection = 'ltr';
  final String primaryScript = 'Latin (Basque alphabet)';
  final int nominalCaseCount = 17;

  final Map<String, String> ipaPhoneticInventory = const {
    'tz /ts̻/': 'Laminal voiceless alveolar affricate (e.g. zortzi).',
    'ts /ts̺/': 'Apical voiceless alveolar affricate (e.g. etsi).',
    'tx /tʃ/': 'Voiceless postalveolar affricate (e.g. txakur).',
    'x /ʃ/': 'Voiceless postalveolar fricative (e.g. xaboi).',
    'j /x/': 'Voiceless velar fricative in standard Batua (e.g. joan).',
  };

  final Map<UniversalGrammaticalRole, String> universalRoleMapping = const {
    UniversalGrammaticalRole.subjectOrAgent: 'Ergatiboa (-k): Gizona-k ogia jan du (The man ate the bread).',
    UniversalGrammaticalRole.directObjectOrPatient: 'Absolutiboa (zero): Gizona etorri da / Ogia jan du.',
    UniversalGrammaticalRole.indirectObjectOrRecipient: 'Datiboa (-ri): Gizonari liburua eman diot.',
    UniversalGrammaticalRole.genitivePossessor: 'Genitiboa (-ren / -en): Irakaslearen liburua.',
    UniversalGrammaticalRole.instrumentalMeans: 'Instrumentala (-z): Kotxez etorri da.',
    UniversalGrammaticalRole.locativePosition: 'Inesiboa (-n): Hirian bizi da.',
    UniversalGrammaticalRole.ablativeSource: 'Ablatiboa (-tik): Etxetik dator.',
    UniversalGrammaticalRole.allativeDirection: 'Adlatiboa (-ra): Mendira doa.',
    UniversalGrammaticalRole.vocativeAddress: 'Bokatiboa (unmarked / intonation).',
  };

  final Map<String, String> universalLexicon = const {
    'greeting': 'Kaixo / Agur',
    'thanks': 'Eskerrik asko / Mila esker',
    'please': 'Mesedez',
    'book': 'Liburua',
    'school': 'Eskola / Ikastetxea',
    'teacher': 'Irakaslea',
    'knowledge': 'Ezagutza / Zientzia',
    'justice': 'Justizia / Bidezkotasuna',
    'prayer': 'Otoitza / Erregua',
    'halal': 'Halal / Baimendua',
    'friend': 'Laguna',
    'water': 'Ura',
    'bread': 'Ogia',
    'home': 'Etxea',
    'city': 'Hiria',
    'hospital': 'Ospitalea',
    'pharmacy': 'Farmazia',
    'placeOfWorship': 'Meskita / Eliza',
  };

  final List<Map<String, String>> practicalDialoguePhrases = const [
    {
      'basque': 'Kaixo! Nola zaude?',
      'arabic': 'مرحباً! كيف حالك؟',
      'english': 'Hello! How are you?',
    },
    {
      'basque': 'Eskerrik asko zure laguntzagatik!',
      'arabic': 'شكراً جزيلاً على مساعدتك!',
      'english': 'Thank you very much for your help!',
    },
    {
      'basque': 'Mesedez, non dago farmaziarik hurbilena?',
      'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      'english': 'Please, where is the nearest pharmacy?',
    },
    {
      'basque': 'Bai, hizkuntzak ikasten ari naiz.',
      'arabic': 'نعم، أنا أتعلم اللغات حالياً.',
      'english': 'Yes, I am currently learning languages.',
    },
  ];

  const BasqueDeepLocalizationProfile();
}
