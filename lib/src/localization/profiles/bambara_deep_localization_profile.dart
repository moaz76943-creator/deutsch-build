import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Bambara (Bamanankan / Manding).
///
/// Mande language spoken by 15M+ people across Mali, Senegal, Guinea, Burkina Faso,
/// and Côte d'Ivoire. Characterized by S-Aux-O-V-X sentence architecture, 2 lexical
/// tones, extensive nominal compounding, and deep Timbuktu Islamic scholarship roots.
@immutable
class BambaraDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final Map<String, String> predicateMarkerBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const BambaraDeepLocalizationProfile({
    this.languageName = 'Bambara',
    this.autonym = 'Bamanankan',
    this.iso6391 = 'bm',
    this.iso6392or3 = 'bam',
    this.typology = TypologicalClassification.isolatingAnalytic,
    this.primaryWordOrder = CanonicalWordOrder.sov, // S-Aux-O-V-X structure
    this.alignment = GrammaticalAlignment.analyticalPrepositional,
    this.hasTones = true,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (official Malian alphabet with ɛ, ɔ, ɲ, ŋ) / N\'Ko',
    this.specialCharacters = const ['ɛ', 'ɔ', 'ɲ', 'ŋ'],
    this.predicateMarkerBridge = const {
      'S-Aux-O-V-X Structure': 'Bambara places auxiliary aspect markers between Subject and Object while verb remains final (A b\'a kalan = er liest es). Bridges directly to German Satzklammer and modal verb brackets (er muss es lesen).',
      'Abstract Derivation (-ya)': 'Suffix -ya turns adjectives and nouns into abstract concepts (kɛnɛya = Gesundheit, tilennenya = Gerechtigkeit). Directly parallels German -heit / -keit (Krankheit, Gerechtigkeit).',
    },
    this.culturalIslamicLexicon = const {
      'i ni ce / salaam alaykum': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'i ni ce kosɛbɛ': 'Danke / Vielen Dank',
      'hakɛ to / sabali': 'Bitte / Entschuldigung',
      'gafe / kitabu': 'Buch (Arabic: كتاب)',
      'kalanso / madarasa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'karamɔgɔ': 'Lehrer / Meister (Arabic: كرم - Karam)',
      'dɔnniya': 'Wissen / Wissenschaft',
      'tilennenya': 'Gerechtigkeit / Aufrichtigkeit',
      'seli / dɛli': 'Gebet / Salāt (Arabic: صلاة)',
      'halali': 'Erlaubt / Halal (Arabic: حلال)',
      'terikɛ / teri': 'Freund',
      'ji': 'Wasser',
      'buru': 'Brot / Nahrung',
      'so': 'Haus / Heim',
      'dugu': 'Stadt',
      'dɔgɔtɔrɔso': 'Krankenhaus',
      'furabaso': 'Apotheke',
      'misiri': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct match to Bambara "S / s" or palatal sequences.',
      'tsch /tʃ/': 'Direct 1:1 match to Bambara "C / c" (/tʃ/) (cɛ, cogo, Deutschland).',
      'z /ts/': 'Bambara "z" is /z/; German "z" is practiced as compound "t+s" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Mapped via velar fricative release in regional northern Manding loanwords.',
    },
    this.coreA1Vocabulary = const {
      'I ni ce / Salaam alaykum': 'Hallo / Guten Tag',
      'I ni sɔgɔma': 'Guten Morgen',
      'I ni tile': 'Guten Tag',
      'I ni wula': 'Guten Abend',
      'I ni ce kosɛbɛ': 'Vielen Dank',
      'Sabali': 'Bitte',
      'Ɔwɔ': 'Ja',
      'Ayi': 'Nein',
      'Ne tɔgɔ ...': 'Mein Name ist ...',
      'I bɔra min?': 'Woher kommen Sie?',
      'Ne bɔra ...': 'Ich komme aus ...',
      'Ji': 'Wasser',
      'Buru': 'Brot',
      'Dɔgɔtɔrɔso': 'Krankenhaus',
      'Furabaso': 'Apotheke',
      'Gare': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'bambara': 'I ni ce! Yala i bɛ Alimankan fɔ wa?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'bambara': 'Ɔwɔ, ne bɛ Alimankan kalan sisan.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'bambara': 'Sabali, furabaso surunyuman bɛ min?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'bambara': 'I ni ce kosɛbɛ i ka dɛmɛ na!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
