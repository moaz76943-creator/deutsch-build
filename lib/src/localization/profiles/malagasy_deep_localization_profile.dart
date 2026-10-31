import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Malagasy (Fiteny malagasy).
///
/// Austronesian language (East Barito branch) spoken by 28M+ people in Madagascar.
/// Characterized by default Verb-Object-Subject (VOS) constituent order (one of the rarest
/// in the world), symmetric voice morphology, historical Arabic Sorabe script roots,
/// African Bantu lexical synthesis, and omnidirectional cross-linguistic alignment.
@immutable
class MalagasyDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final Map<String, String> vosWordOrderBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const MalagasyDeepLocalizationProfile({
    this.languageName = 'Malagasy',
    this.autonym = 'Fiteny malagasy',
    this.iso6391 = 'mg',
    this.iso6392or3 = 'mlg',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.topicProminent, // Default VOS structure!
    this.alignment = GrammaticalAlignment.austronesianSymmetricVoice,
    this.hasTones = false,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (official 21 letters) / historic Sorabe (Arabic script)',
    this.vosWordOrderBridge = const {
      'Default VOS Architecture': 'Malagasy places the verb first and the subject at the very end (Manasa lamba ny reny = Washes clothes the mother = Die Mutter wäscht Kleidung). Contrastive training systematically handles constituent inversion to SVO, SOV, and V2.',
      'Symmetric Voice Affixation': 'Active prefix (m-), passive suffix (-ina), and circumstantial circumfix (i-...-ana) transform focus roles into Indo-European active, passive, and prepositional clauses.',
    },
    this.culturalIslamicLexicon = const {
      'manao ahoana / salama': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'misaotra / misaotra betsaka': 'Danke / Vielen Dank',
      'azafady': 'Bitte / Entschuldigung',
      'boky': 'Buch (English loan: book)',
      'sekoly / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'mpampianatra': 'Lehrer / Dozent',
      'fahalalana / siansa': 'Wissen / Wissenschaft',
      'fahamarinana': 'Gerechtigkeit',
      'vavaka / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'namana': 'Freund',
      'rano': 'Wasser',
      'mofo': 'Brot / Nahrung',
      'trano': 'Haus / Heim',
      'tanàna': 'Stadt',
      'hopitaly': 'Krankenhaus',
      'fivarotam-panafody': 'Apotheke',
      'mousqué / masjid': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Malagasy "S / s" in palatalized positions or postalveolar /ʃ/.',
      'tsch /tʃ/': 'Direct 1:1 match to Malagasy "Tr / tr" (/ʈʂ/ or /tʃ/) (trano, Deutschland).',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as compound "t+s" (tsunami -> Zeit).',
      'Penultimate Word Stress': 'Malagasy words are typically stressed on the penultimate syllable, providing a natural bridge to standard German penultimate lexical stress.',
    },
    this.coreA1Vocabulary = const {
      'Manao ahoana / Salama': 'Hallo / Guten Tag',
      'Manao ahoana maraina': 'Guten Morgen',
      'Manao ahoana tolakandro': 'Guten Tag',
      'Manao ahoana hariva': 'Guten Abend',
      'Misaotra betsaka': 'Vielen Dank',
      'Azafady': 'Bitte',
      'Eny': 'Ja',
      'Tsia': 'Nein',
      'Ny anarako dia ...': 'Mein Name ist ...',
      'Avy aiza ianao?': 'Woher kommen Sie?',
      'Avy any ... aho': 'Ich komme aus ...',
      'Rano': 'Wasser',
      'Mofo': 'Brot',
      'Hopitaly': 'Krankenhaus',
      'Fivarotam-panafody': 'Apotheke',
      'Gara': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'malagasy': 'Manao ahoana! Mahay miteny alemà ve ianao?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'malagasy': 'Eny, mianatra teny alemà aho izao.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'malagasy': 'Azafady, aiza no misy ny fivarotam-panafody akaiky indrindra?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'malagasy': 'Misaotra betsaka tamin\'ny fanampianao!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
