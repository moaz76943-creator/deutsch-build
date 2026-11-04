import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Latvian (Latviešu valoda).
///
/// Baltic language spoken by 2M+ people. Characterized by fixed initial syllable
/// stress (matching Czech and Germanic rhythm), phonemic vowel length with macrons
/// (ā, ē, ī, ū), 6 active grammatical cases, exact 1:1 match of letter 'C/c' to German 'Z/z'
/// (/ts/) and 'Š/š' to German 'SCH' (/ʃ/), and historical Lipka Tatar Islamic heritage.
@immutable
class LatvianDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List<String> specialCharacters;
  final Map<String, String> sixCaseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const LatvianDeepLocalizationProfile({
    this.languageName = 'Latvian',
    this.autonym = 'Latviešu valoda',
    this.iso6391 = 'lv',
    this.iso6392or3 = 'lav',
    this.typology = TypologicalClassification.fusionalInflected,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false, // Fixed initial stress rather than free tone!
    this.hasGrammaticalGender = true, // Vīriešu & Sieviešu dzimte
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Latvian alphabet with macrons and cedillas)',
    this.specialCharacters = const ['ā', 'č', 'ē', 'ģ', 'ī', 'ķ', 'ļ', 'ņ', 'š', 'ū', 'ž'],
    this.sixCaseSystemAlignment = const {
      '1. Nominatīvs (Kas?)': 'Direct subject. Directly maps to German Nominativ (vīrietis = der Mann).',
      '2. Ģenitīvs (Kā?)': 'Possession and partitive negation. Directly maps to German Genitiv (vīrieša = des Mannes).',
      '3. Datīvs (Kam?)': 'Indirect object / recipient. Directly maps to German Dativ (vīrietim = dem Mann).',
      '4. Akuzatīvs (Ko?)': 'Direct object. Directly maps to German Akkusativ (vīrieti = den Mann).',
      '5. Instrumentālis (Ar ko?)': 'Accompaniment with preposition "ar". Maps to German Dativ with preposition "mit".',
      '6. Lokātīvs (Kur?)': 'Location inside or at. Directly maps to German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'sveiki / labdien / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'paldies / liels paldies': 'Danke / Vielen Dank',
      'lūdzu': 'Bitte',
      'grāmata': 'Buch',
      'skola / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'skolotājs / pasniedzējs': 'Lehrer / Dozent',
      'zināšanas / zinātne': 'Wissen / Wissenschaft',
      'taisnīgums': 'Gerechtigkeit',
      'lūgšana / namazs': 'Gebet / Salāt (Persian: نماز)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'draugs': 'Freund',
      'ūdens': 'Wasser',
      'maize': 'Brot / Nahrung',
      'māja': 'Haus / Heim',
      'pilsēta': 'Stadt',
      'slimnīca': 'Krankenhaus',
      'aptieka': 'Apotheke (German loan: Apotheke)',
      'mošeja': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Latvian "C / c" is strictly /ts/ (e.g. cena, cidonija), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': '100% Native Identity! Latvian "Š / š" is strictly /ʃ/ (e.g. šalle, šķēre), matching German "sch" (Schule, schön) perfectly!',
      'tsch /tʃ/': 'Direct 1:1 match to Latvian "Č / č" (čemodāns, Deutschland).',
      'Initial Stress Rhythm': 'Latvian automatically places stress on the first syllable of words, directly aligning with standard German root-initial stress cadence.',
    },
    this.coreA1Vocabulary = const {
      'Sveiki / Labdien': 'Hallo / Guten Tag',
      'Labrīt': 'Guten Morgen',
      'Labdien': 'Guten Tag',
      'Labvakar': 'Guten Abend',
      'Liels paldies': 'Vielen Dank',
      'Lūdzu': 'Bitte',
      'Jā': 'Ja',
      'Nē': 'Nein',
      'Mani sauc ...': 'Mein Name ist ...',
      'No kurienes jūs esat?': 'Woher kommen Sie?',
      'Es esmu no ...': 'Ich komme aus ...',
      'Ūdens': 'Wasser',
      'Maize': 'Brot',
      'Slimnīca': 'Krankenhaus',
      'Aptieka': 'Apotheke',
      'Dzelzceļa stacija': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'latvian': 'Labdien! Vai jūs runājat vāciski?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'latvian': 'Jā, es pašlaik mācos vācu valodu.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'latvian': 'Lūdzu, kur atrodas tuvākā aptieka?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'latvian': 'Liels paldies par jūsu palīdzību!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
