import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Cebuano / Bisaya (Binisaya / Sinugboanon).
///
/// Austronesian language (Visayan branch) spoken by 22M+ people in Central/Southern
/// Philippines. Characterized by Austronesian symmetrical voice trigger alignment
/// (Actor, Patient, Locative, Benefactive), case-marking particles (ang, sa, ug),
/// verb-initial (VSO/VOS) syntax, and extensive Spanish and Malay loanword layers.
@immutable
class CebuanoDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final Map<String, String> voiceTriggerSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const CebuanoDeepLocalizationProfile({
    this.languageName = 'Cebuano',
    this.autonym = 'Binisaya / Sinugboanon',
    this.iso6391 = 'ceb',
    this.iso6392or3 = 'ceb',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.vso,
    this.alignment = GrammaticalAlignment.austronesianSymmetricVoice,
    this.hasTones = false,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Cebuano alphabet)',
    this.voiceTriggerSystemAlignment = const {
      'Actor Trigger (mo- / nag- / -um-)': 'Verb highlights the agent/actor. Maps to Indo-European active voice subject (Nominativ: Nikaon ang bata = Das Kind aß).',
      'Patient/Goal Trigger (-on / gi-)': 'Verb highlights direct object/patient. Maps to German definite Akkusativ (Gikaon sa bata ang pan = Das Kind aß das Brot).',
      'Locative Trigger (-an / gi-...-an)': 'Verb highlights location or recipient. Maps to German Dativ and local prepositions.',
      'Particle "ang"': 'Focus/Topic marker. Functionally aligns with German definite Nominativ (der/die/das).',
      'Particle "sa"': 'Non-focus actor, Genitive possessor, or definite oblique marker. Maps to German Genitiv & Dativ.',
      'Particle "ug"': 'Indefinite direct object marker. Maps to German indefinite Akkusativ (ein, eine, ein).',
    },
    this.culturalIslamicLexicon = const {
      'kumusta / maayong adlaw / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'salamat / daghang salamat': 'Danke / Vielen Dank (Arabic root: سلامة - Salāmah!)',
      'palihog': 'Bitte',
      'basahon / libro': 'Buch (Spanish loan: libro)',
      'tunghaan / eskwelahan / madrasa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'magtutudlo / maestro': 'Lehrer / Dozent',
      'kahibalo / siyensya': 'Wissen / Wissenschaft',
      'katarungan / hustisya': 'Gerechtigkeit',
      'pag-ampo / salah': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'higala': 'Freund',
      'tubig': 'Wasser',
      'pan': 'Brot / Nahrung (Spanish loan: pan)',
      'balay': 'Haus / Heim',
      'dakbayan / siyudad': 'Stadt',
      'ospital': 'Krankenhaus',
      'botika / parmasya': 'Apotheke',
      'moske / masjid': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct match to Cebuano "Sy / sy" or postalveolar /ʃ/.',
      'tsch /tʃ/': 'Direct 1:1 match to Cebuano "Ts / ts" (/tʃ/) (tsaa, tsokolate, Deutschland).',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as the compound sequence "t+s" (tsunami -> Zeit).',
      'Austronesian Voice Alignment Bridge': 'Cebuano trigger system transforms into German active/passive diathesis and case role assignment.',
    },
    this.coreA1Vocabulary = const {
      'Kumusta': 'Hallo / Guten Tag',
      'Maayong buntag': 'Guten Morgen',
      'Maayong hapon': 'Guten Tag',
      'Maayong gabi-i': 'Guten Abend',
      'Daghang salamat': 'Vielen Dank',
      'Palihog': 'Bitte',
      'Oo': 'Ja',
      'Dili': 'Nein',
      'Ang akong ngalan kay ...': 'Mein Name ist ...',
      'Diin ka gikan?': 'Woher kommen Sie?',
      'Gikan ko sa ...': 'Ich komme aus ...',
      'Tubig': 'Wasser',
      'Pan': 'Brot',
      'Ospital': 'Krankenhaus',
      'Botika': 'Apotheke',
      'Estasyon sa tren': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'cebuano': 'Kumusta! Makasulti ka ba og Inaleman?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'cebuano': 'Oo, nagtuon ko og Inaleman karon.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'cebuano': 'Palihog, asa man dapit ang pinakaduol nga botika?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'cebuano': 'Daghang salamat sa imong tabang!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
