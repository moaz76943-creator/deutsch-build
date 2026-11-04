import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Icelandic (Íslenska).
///
/// Most morphologically conservative living Germanic language. Characterized by
/// complete preservation of the 4-case system (Nefnifall, Þolfall, Þágufall, Eignarfall)
/// directly matching German Nominativ, Akkusativ, Dativ, Genitiv, 3 genders (Karlkyn,
/// Kvenkyn, Horkyn) matching der/die/das, archaic letters (Þ/þ, Ð/ð), and native umlauts.
@immutable
class IcelandicDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final bool hasThreeGenders; // Karlkyn, Kvenkyn, Horkyn!
  final bool hasFourCases; // Direct 1:1 match to German 4 cases!
  final Map<String, String> fourCaseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const IcelandicDeepLocalizationProfile({
    this.languageName = 'Icelandic',
    this.autonym = 'Íslenska',
    this.iso6391 = 'is',
    this.iso6392or3 = 'isl',
    this.typology = TypologicalClassification.fusionalInflected,
    this.primaryWordOrder = CanonicalWordOrder.v2VerbSecond,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false,
    this.hasGrammaticalGender = true, // Exact match to German der, die, das!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Icelandic alphabet with Þ, Ð, Æ, Ö)',
    this.specialCharacters = const ['á', 'é', 'í', 'ó', 'ú', 'ý', 'ð', 'þ', 'æ', 'ö'],
    this.hasThreeGenders = true,
    this.hasFourCases = true,
    this.fourCaseSystemAlignment = const {
      '1. Nefnifall (Nominativ - Hver? Hvað?)': 'Direct subject. Direct 1:1 match to German Nominativ (Wer? Was? - maðurinn = der Mann).',
      '2. Þolfall (Akkusativ - Hvern? Hvað?)': 'Direct object. Direct 1:1 match to German Akkusativ (Wen? Was? - manninn = den Mann).',
      '3. Þágufall (Dativ - Hverjum? Hverju?)': 'Indirect object / prepositional. Direct 1:1 match to German Dativ (Wem? - manninum = dem Mann).',
      '4. Eignarfall (Genitiv - Hvers?)': 'Possession and prepositional. Direct 1:1 match to German Genitiv (Wessen? - mannsins = des Mannes).',
    },
    this.culturalIslamicLexicon = const {
      'halló / góðan daginn / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'takk / kærar þakkir': 'Danke / Vielen Dank',
      'gjörðu svo vel / vinsamlegast': 'Bitte / Gern geschehen',
      'bók': 'Buch',
      'skóli / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'kennari': 'Lehrer / Dozent',
      'þekking / vísindi': 'Wissen / Wissenschaft',
      'réttlæti': 'Gerechtigkeit',
      'bæn / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'vinur': 'Freund',
      'vatn': 'Wasser',
      'brauð': 'Brot / Nahrung',
      'hús / heimili': 'Haus / Heim',
      'borg': 'Stadt',
      'sjúkrahús / spítali': 'Krankenhaus',
      'apótek': 'Apotheke',
      'moska': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'ö /ø/': '100% Native Identity! Icelandic "Ö / ö" (börn, köttur) matches German "ö" (schön, Wörter) with zero acoustic distortion!',
      'ä /ɛ/': '100% Native Identity! Icelandic "Æ / æ" (læra, bær) matches German "ä" (Männer, Äpfel) flawlessly!',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as compound "t+s" (tsunami -> Zeit).',
      'sch /ʃ/': 'Practiced via postalveolar articulation contrasting with Icelandic dental /s/.',
      'Germanic Case Twin Bridge': 'Icelandic and German are the only two Germanic languages preserving the full ancient 4-case declension system; case acquisition is completely transparent and natural!',
    },
    this.coreA1Vocabulary = const {
      'Halló / Góðan daginn': 'Hallo / Guten Tag',
      'Góðan daginn (morgun)': 'Guten Morgen',
      'Góðan dag': 'Guten Tag',
      'Gott kvöld': 'Guten Abend',
      'Kærar þakkir': 'Vielen Dank',
      'Gjörðu svo vel': 'Bitte',
      'Já': 'Ja',
      'Nei': 'Nein',
      'Ég heiti ...': 'Mein Name ist ...',
      'Hvaðan ert þú?': 'Woher kommen Sie?',
      'Ég er frá ...': 'Ich komme aus ...',
      'Vatn': 'Wasser',
      'Brauð': 'Brot',
      'Sjúkrahús': 'Krankenhaus',
      'Apótek': 'Apotheke',
      'Lestarstöð': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'icelandic': 'Góðan daginn! Talar þú þýsku?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'icelandic': 'Já, ég er að læra þýsku núna.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'icelandic': 'Vinsamlegast, hvar er næsta apótek?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'icelandic': 'Kærar þakkir fyrir hjálpina!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
