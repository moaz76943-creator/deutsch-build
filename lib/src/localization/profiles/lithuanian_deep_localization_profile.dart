import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Lithuanian (Lietuvių kalba).
///
/// Most morphologically conservative living Indo-European language in Europe.
/// Characterized by 7 grammatical cases, mobile pitch accent, exact 1:1 match of
/// letter 'C/c' to German 'Z/z' (/ts/) and 'Š/š' to German 'SCH' (/ʃ/), dual number
/// preservation, and historic Lipka Tatar Islamic heritage in Vilnius and Kaunas.
@immutable
class LithuanianDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final Map<String, String> sevenCaseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const LithuanianDeepLocalizationProfile({
    this.languageName = 'Lithuanian',
    this.autonym = 'Lietuvių kalba',
    this.iso6391 = 'lt',
    this.iso6392or3 = 'lit',
    this.typology = TypologicalClassification.fusionalInflected,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true, // Tonal pitch accent (tvirtapradė / tvirtagalė)
    this.hasGrammaticalGender = true, // Vyriškoji & Moteriškoji giminė
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Lithuanian alphabet with nosinė hooks)',
    this.specialCharacters = const ['ą', 'č', 'ę', 'ė', 'į', 'š', 'ų', 'ū', 'ž'],
    this.sevenCaseSystemAlignment = const {
      '1. Vardininkas (Nominativ - Kas?)': 'Direct subject. Directly maps to German Nominativ (Wer? Was? - vyras = der Mann).',
      '2. Kilmininkas (Genitiv - Ko?)': 'Possession and partitive negation. Directly maps to German Genitiv (Wessen? - vyro = des Mannes).',
      '3. Naudininkas (Dativ - Kam?)': 'Indirect object / recipient. Directly maps to German Dativ (Wem? - vyrui = dem Mann).',
      '4. Galininkas (Akkusativ - Ką?)': 'Direct object. Directly maps to German Akkusativ (Wen? Was? - vyrą = den Mann).',
      '5. Įnagininkas (Instrumentalis - Kuo?)': 'Means or accompaniment. Directly maps to German Dativ with preposition "mit".',
      '6. Vietininkas (Lokativ - Kur?)': 'Location inside or at. Directly maps to German Dativ with static preposition "in".',
      '7. Šauksmininkas (Vokativ)': 'Direct respectful address (Vyrai!). Maps to German direct address.',
    },
    this.culturalIslamicLexicon = const {
      'labas / laba diena / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ačiū / labai ačiū': 'Danke / Vielen Dank',
      'prašau': 'Bitte',
      'knyga': 'Buch',
      'mokykla / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'mokytojas / dėstytojas': 'Lehrer / Dozent',
      'žinios / mokslas': 'Wissen / Wissenschaft',
      'teisingumas': 'Gerechtigkeit',
      'malda / namazas': 'Gebet / Salāt (Persian: نماز)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'draugas / bičiulis': 'Freund',
      'vanduo': 'Wasser',
      'duona': 'Brot / Nahrung',
      'namas': 'Haus / Heim',
      'miestas': 'Stadt',
      'ligoninė': 'Krankenhaus',
      'vaistinė': 'Apotheke',
      'mečetė': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Lithuanian "C / c" is strictly /ts/ (e.g. cukrus, citrina), matching German "z" (Zeit, Zug, Zimmer) with zero distortion!',
      'sch /ʃ/': '100% Native Identity! Lithuanian "Š / š" is strictly /ʃ/ (e.g. šalis, šuo), matching German "sch" (Schule, schön) perfectly!',
      'tsch /tʃ/': '100% Native Identity! Lithuanian "Č / č" is strictly /tʃ/ (e.g. čia, česnakas), matching German "tsch" (Deutschland) flawlessly!',
      'ch /x/ (ach-Laut)': 'Direct 1:1 match to Lithuanian "Ch / ch" (chemija, Bach, Nacht).',
      '7-Case Mastery Advantage': 'Lithuanian learners operate an archaic 7-case Indo-European inflectional framework natively, making German\'s 4 cases feel streamlined and intuitive.',
    },
    this.coreA1Vocabulary = const {
      'Laba diena / Labas': 'Hallo / Guten Tag',
      'Labas rytas': 'Guten Morgen',
      'Laba diena': 'Guten Tag',
      'Labas vakaras': 'Guten Abend',
      'Labai ačiū': 'Vielen Dank',
      'Prašau': 'Bitte',
      'Taip': 'Ja',
      'Ne': 'Nein',
      'Mano vardas yra ...': 'Mein Name ist ...',
      'Iš kur jūs esate?': 'Woher kommen Sie?',
      'Aš esu iš ...': 'Ich komme aus ...',
      'Vanduo': 'Wasser',
      'Duona': 'Brot',
      'Ligoninė': 'Krankenhaus',
      'Vaistinė': 'Apotheke',
      'Geležinkelio stotis': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'lithuanian': 'Laba diena! Ar jūs kalbate vokiškai?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'lithuanian': 'Taip, aš dabar mokausi vokiečių kalbos.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'lithuanian': 'Atsiprašau, kur yra artimiausia vaistinė?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'lithuanian': 'Labai ačiū už jūsų pagalbą!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
