import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Modern Greek (Ελληνικά).
///
/// Independent Hellenic branch spoken by 13.5M+ people with over 450,000 in Germany.
/// Features Greek alphabet (24 letters), 3 grammatical genders with preposed definite
/// articles (ο, η, το) mirroring German der, die, das directly, a 4-case system,
/// exact 1:1 match of letter 'Χ/χ' to both German ach-Laut and ich-Laut, and rich
/// scientific/philosophical Greco-German cognates.
@immutable
class GreekDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool hasThreeGenders; // Exact match to German der, die, das!
  final bool hasExactPreposedArticleMirror; // o, h, to = der, die, das!
  final String wordOrder;
  final Map<String, String> articleEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> grecoGermanCognateBridges;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const GreekDeepLocalizationProfile({
    this.languageName = 'Greek',
    this.autonym = 'Ελληνικά',
    this.iso6391 = 'el',
    this.iso6392 = 'ell',
    this.languageFamily = 'Indo-European',
    this.branch = 'Hellenic',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Greek alphabet',
    this.hasThreeGenders = true,
    this.hasExactPreposedArticleMirror = true,
    this.wordOrder = 'SVO',
    this.articleEquivalenceMap = const {
      'Ο / ο (Αρσενικό)': 'Direct 1:1 mirror to German "der" (Maskulinum - e.g., ο άνδρας = der Mann).',
      'Η / η (Θηλυκό)': 'Direct 1:1 mirror to German "die" (Femininum - e.g., η γυναίκα = die Frau).',
      'Το / το (Ουδέτερο)': 'Direct 1:1 mirror to German "das" (Neutrum - e.g., το παιδί = das Kind).',
    },
    this.caseSystemAlignment = const {
      '1. Ονομαστική (Nominativ)': 'Direct subject. Matches German Nominativ (Wer? Was? - ο άνδρας).',
      '2. Γενική (Genitiv)': 'Possession and relations. Matches German Genitiv (Wessen? - του άνδρα).',
      '3. Αιτιατική (Akkusativ)': 'Direct object. Matches German Akkusativ (Wen? Was? - τον άνδρα).',
      '4. Κλητική (Vokativ)': 'Direct respectful address. Matches German direct address.',
      'Dative Bridge (σε + Αιτιατική)': 'Greek expresses Dativ through "σε" + Akkusativ (στον άνδρα). Maps to German Dativ (dem Mann).',
    },
    this.grecoGermanCognateBridges = const {
      'φιλοσοφία (philosophia)': 'German "Philosophie".',
      'μαθηματικά (mathematika)': 'German "Mathematik".',
      'δημοκρατία (demokratia)': 'German "Demokratie".',
      'μουσική (mousiki)': 'German "Musik".',
      'θέατρο (theatro)': 'German "Theater".',
      'σύστημα (systema)': 'German "System".',
    },
    this.culturalIslamicLexicon = const {
      'γεια σας / σελάμ': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ευχαριστώ / ευχαριστώ πολύ': 'Danke / Vielen Dank',
      'παρακαλώ': 'Bitte',
      'βιβλίο': 'Buch',
      'σχολείο / μεντρεσές': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'δάσκαλος / καθηγητής': 'Lehrer / Professor',
      'γνώση / επιστήμη': 'Wissen / Wissenschaft',
      'δικαιοσύνη': 'Gerechtigkeit',
      'προσευχή / ναμάζι': 'Gebet / Salāt (Persian: نماز)',
      'χαλάλ': 'Erlaubt / Halal (Arabic: حلال)',
      'φίλος': 'Freund',
      'νερό': 'Wasser',
      'ψωμί': 'Brot / Nahrung',
      'σπίτι': 'Haus / Heim',
      'πόλη': 'Stadt',
      'νοσοκομείο': 'Krankenhaus',
      'φαρμακείο': 'Apotheke',
      'τζαμί': 'Moschee (Arabic: جامع)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Greek digraph "ΤΣ / τσ" is strictly /ts/ (e.g. τσίρκο, τσέπη), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'ch /x/ (ach-Laut)': '100% Native Identity! Greek "Χ / χ" before back vowels (a, o, u) is a voiceless velar fricative /x/ (e.g. χρόνος, χαρά), matching German "ch" in Nacht, Bach, Buch!',
      'ch /ç/ (ich-Laut)': '100% Native Identity! Greek "Χ / χ" before front vowels (e, i) is a voiceless palatal fricative /ç/ (e.g. όχι, χέρι), matching German "ch" in ich, nicht, möchte!',
      'Article Mirror Advantage': 'Greek speakers intuitively master German articles because Greek already uses preposed definite articles (ο, η, το) with the exact same three genders.',
    },
    this.coreA1Vocabulary = const {
      'Γεια σας': 'Hallo / Guten Tag',
      'Καλημέρα': 'Guten Morgen',
      'Καλό μεσημέρι': 'Guten Tag',
      'Καλησπέρα': 'Guten Abend',
      'Ευχαριστώ πολύ': 'Vielen Dank',
      'Παρακαλώ': 'Bitte',
      'Ναι': 'Ja',
      'Όχι': 'Nein',
      'Με λένε ...': 'Mein Name ist ...',
      'Από πού είστε;': 'Woher kommen Sie?',
      'Είμαι από ...': 'Ich komme aus ...',
      'Νερό': 'Wasser',
      'Ψωμί': 'Brot',
      'Νοσοκομείο': 'Krankenhaus',
      'Φαρμακείο': 'Apotheke',
      'Σιδηροδρομικός σταθμός': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'greek': 'Γεια σας! Μιλάτε γερμανικά;',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'greek': 'Ναι, μαθαίνω τη γερμανική γλώσσα τώρα.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'greek': 'Παρακαλώ, πού βρίσκεται το πλησιέστερο φαρμακείο;',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'greek': 'Σας ευχαριστώ πολύ για τη βοήθειά σας!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Greek case to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
