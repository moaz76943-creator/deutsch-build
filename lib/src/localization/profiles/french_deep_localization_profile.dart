import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for French (Français).
///
/// Gallo-Romance language spoken by 300M+ people; Germany's primary direct geopolitical
/// partner. Characterized by identical standard uvular 'r' (/ʁ/) matching German 'r'
/// 100%, native front-rounded vowels 'u' (/y/) and 'eu' (/ø/) matching German 'ü' and 'ö',
/// 2 grammatical genders with preposed articles (le/la/les), subjonctif mood, and
/// contracted prepositional articles (du/au matching German im/am/zum).
@immutable
class FrenchDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasTwoGenders;
  final bool hasUvularR; // French 'r' = German 'r' (/ʁ/)!
  final bool hasNativeGermanUmlauts; // French 'u' = 'ü', 'eu' = 'ö'!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const FrenchDeepLocalizationProfile({
    this.languageName = 'French',
    this.autonym = 'Français',
    this.iso6391 = 'fr',
    this.iso6392 = 'fra',
    this.languageFamily = 'Indo-European',
    this.branch = 'Romance (Gallo-Romance)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (French alphabet)',
    this.specialCharacters = const ['à', 'â', 'ç', 'é', 'è', 'ê', 'ë', 'î', 'ï', 'ô', 'ù', 'û', 'ü', 'ÿ', 'œ', 'æ'],
    this.hasTwoGenders = true,
    this.hasUvularR = true, // Exact 1:1 match to German uvular r!
    this.hasNativeGermanUmlauts = true, // u = ü, eu = ö!
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Genre masculin (le)': 'German Maskulinum (der) - e.g., l\'homme (der Mann), le livre (das Buch/masc in FR).',
      'Genre féminin (la)': 'German Femininum (die) - e.g., la femme (die Frau), l\'école (die Schule).',
      'Formes contractées (du / au)': 'Direct parallel to German article contractions: du = des (de+le), au = dem (à+le), zum = zu dem.',
    },
    this.caseSystemAlignment = const {
      'Nominativ (Sujet)': 'Direct subject. Matches German Nominativ (l\'homme lit).',
      'Akkusativ (Complément d\'objet direct)': 'Direct object without preposition (je vois l\'homme). Matches German Akkusativ (ich sehe den Mann).',
      'Dativ (Complément d\'objet indirect - à)': 'Marked with preposition "à" (je donne le livre à l\'homme). Matches German Dativ (ich gebe dem Mann).',
      'Genitiv (Complément du nom - de / du)': 'Marked with preposition "de" or contracted "du" (le livre du professeur). Matches German Genitiv (des Lehrers).',
      'Instrumentalis (Avec)': 'Preposition "avec" (avec l\'ami). Matches German Dativ with preposition "mit".',
      'Lokativ (Dans / En / À)': 'Prepositions "dans", "en", "à" (dans la ville). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'bonjour / salam': 'Hallo / Guten Tag / Friede (Arabic: سلام)',
      'merci / merci beaucoup': 'Danke / Vielen Dank',
      's\'il vous plaît': 'Bitte',
      'livre': 'Buch',
      'école / médersa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'professeur / enseignant': 'Lehrer / Dozent',
      'science / savoir': 'Wissen / Wissenschaft',
      'justice': 'Gerechtigkeit',
      'prière / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'ami': 'Freund',
      'eau': 'Wasser',
      'pain': 'Brot / Nahrung',
      'maison': 'Haus / Heim',
      'ville': 'Stadt',
      'hôpital': 'Krankenhaus',
      'pharmacie': 'Apotheke',
      'mosquée': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'r /ʁ/ (Uvular R)': '100% Native Identity! Standard French "r" and standard German "r" are both voiced uvular fricatives /ʁ/ (rouge, Paris match rot, Berlin with zero adjustment)!',
      'ü /y/': '100% Native Identity! French "u" (tu, lune, musique) is phonemically /y/, matching German "ü" (über, fünf, Tür) flawlessly!',
      'ö /ø/': '100% Native Identity! French "eu" in closed syllables (feu, peu) is phonemically /ø/, matching German "ö" (schön, Goethe) perfectly!',
      'sch /ʃ/': 'Direct 1:1 match to French "Ch / ch" (chambre, chocolat match Schule, schön).',
      'h /h/ (Aspirated H)': 'French "h" is silent; dedicated aspiration drills train French speakers to actively articulate German aspirated "h" (haben, heute, hier).',
      'z /ts/': 'French "z" is /z/; German "z" is practiced as the affricate compound "t+s" (tsunami -> Zeit).',
    },
    this.coreA1Vocabulary = const {
      'Bonjour': 'Hallo / Guten Tag',
      'Bonjour (matin)': 'Guten Morgen',
      'Bonjour (après-midi)': 'Guten Tag',
      'Bonsoir': 'Guten Abend',
      'Merci beaucoup': 'Vielen Dank',
      'S\'il vous plaît': 'Bitte',
      'Oui': 'Ja',
      'Non': 'Nein',
      'Je m\'appelle ...': 'Mein Name ist ...',
      'D\'où venez-vous ?': 'Woher kommen Sie?',
      'Je viens de ...': 'Ich komme aus ...',
      'Eau': 'Wasser',
      'Pain': 'Brot',
      'Hôpital': 'Krankenhaus',
      'Pharmacie': 'Apotheke',
      'Gare': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'french': 'Bonjour ! Parlez-vous allemand ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'french': 'Oui, j\'apprends la langue allemande en ce moment.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'french': 'S\'il vous plaît, où se trouve la pharmacie la plus proche ?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'french': 'Merci beaucoup pour votre aide !',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a French prepositional relation into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
