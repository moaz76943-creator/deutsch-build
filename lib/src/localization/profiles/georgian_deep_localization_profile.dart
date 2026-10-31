import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Georgian (ქართული ენა / Kartuli ena).
///
/// South Caucasian (Kartvelian) language spoken by 4M+ people. Features unique
/// Mkhedruli script (33 letters, unicameral), complex polypersonal verb morphology,
/// split ergativity (screeve series), 7 grammatical cases, massive consonant
/// cluster capability (rendering German consonant clusters effortless), and exact
/// 1:1 match of letter 'ც' to German 'Z/z' (/ts/).
@immutable
class GeorgianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool hasSplitErgativity;
  final bool hasPolypersonalVerbs;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const GeorgianDeepLocalizationProfile({
    this.languageName = 'Georgian',
    this.autonym = 'ქართული ენა',
    this.iso6391 = 'ka',
    this.iso6392 = 'kat',
    this.languageFamily = 'Kartvelian',
    this.branch = 'Karto-Zan',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Mkhedruli (ქართული დამწერლობა)',
    this.hasSplitErgativity = true,
    this.hasPolypersonalVerbs = true,
    this.wordOrder = 'SOV / SVO flexible',
    this.caseSystemAlignment = const {
      '1. სახელობითი (Nominativ - unmarked/-i)': 'Subject in present series. Directly maps to German Nominativ (der Mann / das Buch).',
      '2. მოთხრობითი (Ergativ - -ma)': 'Agent in past transitive screeve series (კაცმა წაიკითხა). Maps to German past subject.',
      '3. მიცემითი (Dativ - -s)': 'Indirect/direct object (კაცს). Maps to German Dativ and Akkusativ.',
      '4. ნათესაობითი (Genitiv - -is)': 'Possession and relations (კაცის). Directly maps to German Genitiv (des Mannes).',
      '5. მოქმედებითი (Instrumentalis - -it)': 'Instrument or accompaniment (კალმით). Maps to German Dativ with preposition "mit".',
      '6. ვითარებითი (Adverbialis - -ad/-d)': 'Role or transformation. Maps to German preposition "als" or "zu" (als Lehrer).',
      '7. წოდებითი (Vokativ - -o)': 'Direct address (მეგობარო!). Maps to German direct address.',
    },
    this.culturalIslamicLexicon = const {
      'გამარჯობა / სალამ': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'მადლობა / დიდი მადლობა': 'Danke / Vielen Dank',
      'გეთაყვა / გთხოვთ': 'Bitte',
      'წიგნი / ქითაბი': 'Buch (Arabic: كتاب)',
      'სკოლა / მედრესე': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'მასწავლებელი': 'Lehrer / Dozent',
      'ცოდნა / მეცნიერება': 'Wissen / Wissenschaft',
      'სამართლიანობა': 'Gerechtigkeit',
      'ლოცვა / ნამაზი': 'Gebet / Salāt (Persian: نماز)',
      'ჰალალი': 'Erlaubt / Halal (Arabic: حلال)',
      'მეგობარი': 'Freund',
      'წყალი': 'Wasser',
      'პური': 'Brot / Nahrung',
      'სახლი': 'Haus / Heim',
      'ქალაქი': 'Stadt',
      'საავადმყოფო': 'Krankenhaus',
      'აფთიაქი': 'Apotheke',
      'მეჩეთი': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Georgian letter "ც" is strictly /ts/ (e.g. ცენტრი, ცოლი), matching German "z" (Zeit, Zug, Zimmer) with zero distortion!',
      'sch /ʃ/': 'Direct 1:1 match to Georgian "შ" (e.g. შაბათი, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Georgian "ჩ" (e.g. ჩაი, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct 1:1 match to Georgian "ხ" (e.g. ხორცი, Bach, Nacht).',
      'Consonant Cluster Advantage': 'Georgian natively permits massive consonant clusters (e.g. გვფრცქვნი, მწვრთნელი); German clusters (Herbst, Angst, pflücken) present zero articulatory difficulty!',
      'Article System Drill': 'Because Georgian lacks grammatical articles, learners receive dedicated cognitive anchoring for der, die, das.',
    },
    this.coreA1Vocabulary = const {
      'გამარჯობა': 'Hallo / Guten Tag',
      'დილა მშვიდობისა': 'Guten Morgen',
      'დღე მშვიდობისა': 'Guten Tag',
      'საღამო მშვიდობისა': 'Guten Abend',
      'დიდი მადლობა': 'Vielen Dank',
      'გთხოვთ': 'Bitte',
      'დიახ / კი': 'Ja',
      'არა': 'Nein',
      'მე მქვია ...': 'Mein Name ist ...',
      'საიდან ხართ?': 'Woher kommen Sie?',
      'მე ვარ ...-დან': 'Ich komme aus ...',
      'წყალი': 'Wasser',
      'პური': 'Brot',
      'საავადმყოფო': 'Krankenhaus',
      'აფთიაქი': 'Apotheke',
      'რკინიგზის სადგური': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'georgian': 'გამარჯობა! ლაპარაკობთ გერმანულად?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'georgian': 'დიახ, მე ახლა ვსწავლობ გერმანულ ენას.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'georgian': 'გთხოვთ მითხრათ, სად არის უახლოესი აფთიაქი?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'georgian': 'დიდი მადლობა თქვენი დახმარებისთვის!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Georgian case into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
