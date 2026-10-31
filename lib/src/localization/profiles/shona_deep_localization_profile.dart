import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Shona (chiShona).
///
/// Southern Bantu language spoken by 15M+ people in Zimbabwe, Mozambique, Botswana,
/// and Zambia. Famed for its phonemically unique whistling sibilants (sv /sᶲ/, zv /zᶿ/),
/// 20+ noun classes with all-pervasive prefixal concord, agglutinative morphology,
/// and omnidirectional cross-linguistic alignment across African and world languages.
@immutable
class ShonaDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final int nounClassCount;
  final List<String> whistlingSibilants;
  final Map<String, String> nounClassConcordBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const ShonaDeepLocalizationProfile({
    this.languageName = 'Shona',
    this.autonym = 'chiShona',
    this.iso6391 = 'sn',
    this.iso6392or3 = 'sna',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true,
    this.hasGrammaticalGender = true, // 20+ noun classes/genders!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Shona alphabet)',
    this.nounClassCount = 21,
    this.whistlingSibilants = const ['sv (/sᶲ/)', 'zv (/zᶿ/)', 'tsv (/tsᶲ/)', 'dzv (/dzᶿ/)'],
    this.nounClassConcordBridge = const {
      '20+ Noun-Class Concord': 'chiShona classifies nouns into over 20 classes (mu-/va- people, mu-/mi- trees, chi-/zvi- languages/tools, ru- long objects, ka-/tu- diminutives). Because Shona speakers manage 20+ noun classes natively, German\'s 3-gender system (der, die, das) is effortlessly internalized.',
      'Possessive Concord (-a)': 'Possessive marker takes noun class prefix (bhuku romudzidzisi = das Buch des Lehrers). Maps directly to German Genitiv.',
    },
    this.culturalIslamicLexicon = const {
      'mhoro / kwaziwai / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'maita basa / ndatenda / mazvita': 'Danke / Vielen Dank',
      'ndapota': 'Bitte',
      'bhuku': 'Buch',
      'chikoro / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'mudzidzisi': 'Lehrer / Dozent',
      'ruzivo / sayenzi': 'Wissen / Wissenschaft',
      'ruramisiro / kururama': 'Gerechtigkeit',
      'munamato / salah': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'shamwari': 'Freund',
      'mvura': 'Wasser',
      'chingwa': 'Brot / Nahrung',
      'imba / mba': 'Haus / Heim',
      'guta': 'Stadt',
      'chipatara': 'Krankenhaus',
      'chemisi': 'Apotheke',
      'masikiti': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Shona "Sh / sh" (shoko, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Shona "Ch / ch" (chikoro, Deutschland).',
      'z /ts/': 'Direct match to Shona "Ts / ts" (tsamba, tsunami -> Zeit).',
      'Whistling Sibilant Mastery': 'Shona native control of rare whistled sibilants (sv, zv, tsv) gives learners world-class oral articulatory agility for all European fricatives and affricates.',
    },
    this.coreA1Vocabulary = const {
      'Mhoro / Kwaziwai': 'Hallo / Guten Tag',
      'Mangwanani': 'Guten Morgen',
      'Masikati': 'Guten Tag',
      'Manheru': 'Guten Abend',
      'Maita basa zvikuru': 'Vielen Dank',
      'Ndapota': 'Bitte',
      'Hongu': 'Ja',
      'Kwete': 'Nein',
      'Zita rangu ndinonzi ...': 'Mein Name ist ...',
      'Munobva kupi?': 'Woher kommen Sie?',
      'Ndinobva ku ...': 'Ich komme aus ...',
      'Mvura': 'Wasser',
      'Chingwa': 'Brot',
      'Chipatara': 'Krankenhaus',
      'Chemisi': 'Apotheke',
      'Chiteshi chechitima': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'shona': 'Mhoro! Munotaura chiGerman here?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'shona': 'Hongu, ndiri kudzidza chiGerman iye zvino.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'shona': 'Ndapota, chemisi iri pedyo iri kupi?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'shona': 'Maita basa zvikuru nerubatsiro rwenyu!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
