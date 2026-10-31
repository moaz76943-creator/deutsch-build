import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Tagalog / Filipino (Wikang Tagalog / Filipino).
///
/// Austronesian language (Philippine branch) spoken by 85M+ people. Characterized by
/// the symmetric Austronesian voice focus system (Actor, Patient, Locative, Beneficiary),
/// case-marking particles (ang, ng, sa), deep Spanish loanword substrate, shared
/// Malayo-Polynesian core vocabulary (anak, mata, bato), and omnidirectional mapping.
@immutable
class TagalogDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final Map<String, String> voiceFocusSystemAlignment;
  final Map<String, String> omnidirectionalBridges;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const TagalogDeepLocalizationProfile({
    this.languageName = 'Tagalog',
    this.autonym = 'Wikang Tagalog / Filipino',
    this.iso6391 = 'tl',
    this.iso6392or3 = 'fil',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.vso,
    this.alignment = GrammaticalAlignment.austronesianSymmetricVoice,
    this.hasTones = false,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Modern Filipino alphabet)',
    this.voiceFocusSystemAlignment = const {
      'Actor Focus (mag- / -um-)': 'Verb highlights the agent/actor. Maps to Indo-European active voice subject (Nominativ: Kumain ang bata = Das Kind aß).',
      'Patient/Object Focus (-in)': 'Verb highlights the patient/direct object. Maps to German definite Akkusativ (Kinain ng bata ang tinapay = Das Kind aß das Brot).',
      'Locative/Directional Focus (-an)': 'Verb highlights location or recipient. Maps to German Dativ and local prepositions.',
      'Benefactive Focus (i-)': 'Verb highlights beneficiary for whom the action occurs. Maps to German Dativ of benefit.',
      'Particle "ang"': 'Focus/Topic marker. Functionally aligns with German definite Nominativ (der/die/das).',
      'Particle "ng"': 'Agent of non-actor focus verb or Genitive possessor (libro ng guro). Directly matches German Genitiv (des Lehrers).',
      'Particle "sa"': 'Oblique / Dative / Locative marker (sa lungsod). Matches German Dativ with prepositions "in" and "zu".',
    },
    this.omnidirectionalBridges = const {
      'Austronesian Western Matrix (Malay/Indonesian)': 'Direct shared roots (anak = child, mata = eye, bato/batu = stone, langit = sky, salamat = thanks from Arabic salāmah!).',
      'Hispanic Romance Substrate': 'Over 4,000 direct Spanish loanwords (mesa, silya, kutsara, pinto, oras, trabaho) providing instant lexical recognition.',
      'Indo-European Voice Transformation': 'Austronesian symmetric focus transforms into active vs passive constructions in German, English, and Russian.',
    },
    this.culturalIslamicLexicon = const {
      'kamusta / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'salamat / maraming salamat': 'Danke / Vielen Dank (Arabic root: سلامة - Salāmah!)',
      'pakiusap / paki': 'Bitte',
      'aklat / libro': 'Buch (Spanish loan: libro)',
      'paaralan / madrasa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'guro / titser': 'Lehrer / Dozent',
      'karunungan / agham': 'Wissen / Wissenschaft',
      'katarungan': 'Gerechtigkeit',
      'dasal / salah': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'kaibigan': 'Freund',
      'tubig': 'Wasser',
      'tinapay': 'Brot / Nahrung',
      'bahay': 'Haus / Heim',
      'lungsod / siyudad': 'Stadt',
      'ospital': 'Krankenhaus',
      'botika / parmasya': 'Apotheke',
      'moske / masjid': 'Moschee (Arabic: مسجد)',
    },
    this.coreA1Vocabulary = const {
      'Kamusta': 'Hallo / Guten Tag',
      'Magandang umaga': 'Guten Morgen',
      'Magandang hapon': 'Guten Tag',
      'Magandang gabi': 'Guten Abend',
      'Maraming salamat': 'Vielen Dank',
      'Pakiusap': 'Bitte',
      'Oo': 'Ja',
      'Hindi': 'Nein',
      'Ang pangalan ko ay ...': 'Mein Name ist ...',
      'Saan ka nanggaling?': 'Woher kommen Sie?',
      'Nanggaling ako sa ...': 'Ich komme aus ...',
      'Tubig': 'Wasser',
      'Tinapay': 'Brot',
      'Ospital': 'Krankenhaus',
      'Botika': 'Apotheke',
      'Istasyon ng tren': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'tagalog': 'Kamusta! Nagsasalita ka ba ng Aleman?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'tagalog': 'Oo, nag-aaral ako ng wikang Aleman ngayon.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'tagalog': 'Pakiusap, saan naroroon ang pinakamalapit na botika?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'tagalog': 'Maraming salamat sa iyong tulong!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
