import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Dutch (Nederlands).
///
/// West Germanic language spoken by 25M+ people; German's closest major sister tongue.
/// Shares the foundational West Germanic syntactic architecture: Verb-Second (V2) word
/// order in main clauses, Verb-Final (SOV) in subordinate clauses, separable prefix verbs
/// (meenemen = mitnehmen), sentence brackets (Satzklammer), and native velar fricative 'G/CH' (/x/).
@immutable
class DutchDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool hasV2WordOrder; // V2 in main clauses, V-final in subordinate!
  final bool hasSeparableVerbs; // meenemen -> neem mee matching mitnehmen -> nehme mit!
  final bool hasSatzklammer; // Sentence bracket identical to German!
  final String wordOrder;
  final Map<String, String> syntacticTwinBridges;
  final Map<String, String> falseFriendMitigation;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const DutchDeepLocalizationProfile({
    this.languageName = 'Dutch',
    this.autonym = 'Nederlands',
    this.iso6391 = 'nl',
    this.iso6392 = 'nld',
    this.languageFamily = 'Indo-European',
    this.branch = 'Germanic (West Germanic / Low Franconian)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Dutch alphabet)',
    this.hasV2WordOrder = true,
    this.hasSeparableVerbs = true,
    this.hasSatzklammer = true,
    this.wordOrder = 'V2 (main) / SOV (subordinate)',
    this.syntacticTwinBridges = const {
      'V2 Rule (Inversie)': 'Exact syntactic match! Adverbial initial position causes subject-verb inversion in both languages (Vandaag leer ik = Heute lerne ich).',
      'Subordinate Verb-Final': 'Exact syntactic match! Subordinate conjunctions trigger verb-final order (omdat ik Duits leer = weil ich Deutsch lerne).',
      'Scheidbare Werkwoorden (Separable Verbs)': 'Exact syntactic match! meenemen: ik neem het mee = mitnehmen: ich nehme es mit.',
      'Satzklammer (Sentence Bracket)': 'Exact syntactic match! Auxiliaries bracket infinitives at the end (ik moet een boek lezen = ich muss ein Buch lesen).',
      'Gender System Mapping': 'Dutch "de"-words map to German "der" & "die"; Dutch "het"-words map directly to German "das".',
    },
    this.falseFriendMitigation = const {
      'bellen': 'Dutch: anrufen / klingeln (German: bellen = bellend bellen wie ein Hund).',
      'klaarkomen': 'Dutch: fertig werden / bereit sein (caution in colloquial German!).',
      'monster': 'Dutch: Probe / Muster (German: Monster = Ungeheuer).',
      'slim': 'Dutch: klug / schlau (German: schlimm = böse / übel).',
      'eng': 'Dutch: gruselig / unheimlich (German: eng = schmal / nicht weit).',
      'durven': 'Dutch: wagen / sich trauen (German: dürfen = Erlaubnis haben).',
    },
    this.culturalIslamicLexicon = const {
      'hallo / goedendag / salam': 'Hallo / Guten Tag / Friede (Arabic: سلام)',
      'dank u wel / bedankt': 'Danke / Vielen Dank',
      'alstublieft / alsjeblieft': 'Bitte / Bitte sehr',
      'boek': 'Buch',
      'school / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'leraar / docent': 'Lehrer / Dozent',
      'kennis / wetenschap': 'Wissen / Wissenschaft',
      'gerechtigheid': 'Gerechtigkeit',
      'gebed / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'vriend': 'Freund',
      'water': 'Wasser',
      'brood': 'Brot / Nahrung',
      'huis': 'Haus / Heim',
      'stad': 'Stadt',
      'ziekenhuis': 'Krankenhaus',
      'apotheek': 'Apotheke',
      'moskee': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'ch /x/ (ach-Laut)': '100% Native Identity! Dutch "Ch / ch" and "G / g" (e.g. nacht, goed) are pronounced as velar/uvular fricatives /x/ or /ɣ/, matching German "ch" in Nacht, Bach, Buch effortlessly!',
      'sch /ʃ/': 'Dutch "Sch / sch" is /sx/ (school); contrastive training isolates postalveolar /ʃ/ without velar friction (Schule, schön).',
      'z /ts/': 'Dutch "z" is voiced /z/; German "z" is an affricate /ts/, practiced as the compound sequence "t+s" (tsunami -> Zeit).',
      'Sister Language Acceleration': 'Dutch speakers achieve the highest initial acquisition speed in German due to near-identical core vocabulary and shared West Germanic syntax.',
    },
    this.coreA1Vocabulary = const {
      'Hallo / Goedendag': 'Hallo / Guten Tag',
      'Goedemorgen': 'Guten Morgen',
      'Goedemiddag': 'Guten Tag',
      'Goedenavond': 'Guten Abend',
      'Dank u wel / Heel erg bedankt': 'Vielen Dank',
      'Alstublieft': 'Bitte',
      'Ja': 'Ja',
      'Nee': 'Nein',
      'Mijn naam is ...': 'Mein Name ist ...',
      'Waar komt u vandaan?': 'Woher kommen Sie?',
      'Ik kom uit ...': 'Ich komme aus ...',
      'Water': 'Wasser',
      'Brood': 'Brot',
      'Ziekenhuis': 'Krankenhaus',
      'Apotheek': 'Apotheke',
      'Treinstation': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'dutch': 'Goedendag! Spreekt u Duits?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'dutch': 'Ja, ik leer op dit moment de Duitse taal.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'dutch': 'Alstublieft, waar is de dichtstbijzijnde apotheek?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'dutch': 'Hartelijk dank voor uw hulp!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Validates availability of a syntactic twin bridge rule.
  bool hasSyntacticTwinRule(String ruleKey) {
    return syntacticTwinBridges.keys.any((k) => k.toLowerCase().contains(ruleKey.toLowerCase()));
  }
}
