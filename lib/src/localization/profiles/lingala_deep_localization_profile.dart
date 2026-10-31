import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Lingala (Lingála).
///
/// Central Bantu language spoken by 25M+ people across DRC, Republic of the Congo,
/// and Central Africa. Lingua franca of music (Rumba/Soukous) and trade. Characterized
/// by 15 paired noun classes (mo-/ba-, mo-/mi-, li-/ma-, e-/bi-), 2 tonal registers,
/// SVO syntax, and omnidirectional cross-linguistic alignment across Central Africa.
@immutable
class LingalaDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List<String> specialVowels;
  final Map<String, String> nounClassPairBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const LingalaDeepLocalizationProfile({
    this.languageName = 'Lingala',
    this.autonym = 'Lingála',
    this.iso6391 = 'ln',
    this.iso6392or3 = 'lin',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true,
    this.hasGrammaticalGender = true, // 15 paired noun classes!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Lingala alphabet with ɛ, ɔ)',
    this.nounClassCount = 15,
    this.specialVowels = const ['ɛ', 'ɔ'],
    this.nounClassPairBridge = const {
      'Paired Noun Classes': 'Lingala pairs singular/plural prefixes (mo-/ba- for people: moto/bato; li-/ma- for objects: lilala/malala). Directly prepares learners for German gender plural patterns (der Mann -> die Männer, die Frau -> die Frauen).',
      'Prepositional Framework': 'Preposition "na" (location, instrument, association) and connective "ya" (Genitive) map to German case and preposition networks.',
    },
    this.culturalIslamicLexicon = const {
      'mbote / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'melesi / matondi / tondi mingi': 'Danke / Vielen Dank (French loan: merci)',
      's\'il vous plaît / bolimbisi': 'Bitte / Entschuldigung',
      'buku': 'Buch',
      'kelasi / eteyelo / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'molakisi': 'Lehrer / Dozent',
      'boyebi / mayele': 'Wissen / Wissenschaft',
      'bosembo': 'Gerechtigkeit',
      'losambo / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'moninga': 'Freund',
      'mai': 'Wasser',
      'lipa': 'Brot / Nahrung (Portuguese loan: pão)',
      'ndako': 'Haus / Heim',
      'engumba': 'Stadt',
      'lopitalo': 'Krankenhaus',
      'famasi': 'Apotheke',
      'ndako ya nzambe / misiti': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Practiced via postalveolar articulation contrasting with Lingala dental /s/.',
      'tsch /tʃ/': 'Matches Lingala compound sequence "ts / tsh".',
      'z /ts/': 'Lingala "z" is voiced /z/; German "z" is an affricate /ts/, practiced as compound "t+s" (Zeit -> Tsait).',
      'Tonal Pitch Modulation': 'Lingala High (é) and Low (e) tones provide native acoustic control for German expressive stress patterns.',
    },
    this.coreA1Vocabulary = const {
      'Mbote': 'Hallo / Guten Tag',
      'Mbote na tɔngɔ́': 'Guten Morgen',
      'Mbote na pokwa': 'Guten Abend',
      'Matondi mingi': 'Vielen Dank',
      'Bolimbisi': 'Bitte',
      'Ɛɛ': 'Ja',
      'Tɛ́': 'Nein',
      'Kombo na ngai ...': 'Mein Name ist ...',
      'Oye wuta wapi?': 'Woher kommen Sie?',
      'Naye wuta ...': 'Ich komme aus ...',
      'Mai': 'Wasser',
      'Lipa': 'Brot',
      'Lopitalo': 'Krankenhaus',
      'Famasi': 'Apotheke',
      'Gare': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'lingala': 'Mbote! Olobaka lialémani?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'lingala': 'Ɛɛ, nazali koyekola lialémani sikoyo.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'lingala': 'Bolimbisi, famasi ya pene ezali wapi?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'lingala': 'Matondi mingi mpo na lisungi na yo!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
