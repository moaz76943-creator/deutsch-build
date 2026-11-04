import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Spanish (Español / Castellano).
///
/// Global Romance language spoken by 500M+ people. Characterized by 2 grammatical
/// genders (masculino/femenino), preposed definite articles (el/la/los/las),
/// rich subjunctive mood bridging directly to German Konjunktiv II, shared
/// Andalusian-Arabic historical vocabulary, and exact match of Spanish 'J/j' to German ach-Laut.
@immutable
class SpanishDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasTwoGenders; // Masculino & Femenino
  final bool hasSubjunctiveMood; // Subjuntivo maps to Konjunktiv!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const SpanishDeepLocalizationProfile({
    this.languageName = 'Spanish',
    this.autonym = 'Español',
    this.iso6391 = 'es',
    this.iso6392 = 'spa',
    this.languageFamily = 'Indo-European',
    this.branch = 'Romance (Ibero-Romance)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Spanish alphabet)',
    this.specialCharacters = const ['á', 'é', 'í', 'ó', 'ú', 'ü', 'ñ', '¿', '¡'],
    this.hasTwoGenders = true,
    this.hasSubjunctiveMood = true,
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Género masculino (el)': 'German Maskulinum (der) - e.g., el hombre (der Mann), el libro (das Buch/masc in ES).',
      'Género femenino (la)': 'German Femininum (die) - e.g., la mujer (die Frau), la escuela (die Schule).',
      'Concepto neutro (lo)': 'German Neutrum (das) - e.g., lo bueno (das Gute), lo importante (das Wichtige).',
    },
    this.caseSystemAlignment = const {
      'Nominativ (Sujeto)': 'Direct subject without preposition. Matches German Nominativ (el hombre lee).',
      'Akkusativ (Objeto directo)': 'Direct object; takes "a personal" for animate entities (veo a Carlos). Matches German Akkusativ (ich sehe den Mann).',
      'Dativ (Objeto indirecto - a / para)': 'Recipient marked with preposition "a" (le doy el libro a María). Matches German Dativ (ich gebe der Frau das Buch).',
      'Genitiv (Posesión - de)': 'Marked with preposition "de" (el libro del hombre). Matches German Genitiv (das Buch des Mannes).',
      'Instrumentalis (Con)': 'Preposition "con" (con el amigo). Matches German Dativ with preposition "mit".',
      'Lokativ (En)': 'Preposition "en" (en la ciudad). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'hola / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'gracias / muchas gracias': 'Danke / Vielen Dank',
      'por favor': 'Bitte',
      'libro': 'Buch',
      'escuela / madraza': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'profesor / maestro': 'Lehrer / Dozent',
      'ciencia / saber': 'Wissen / Wissenschaft',
      'justicia': 'Gerechtigkeit',
      'oración / salāt': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'amigo': 'Freund',
      'agua': 'Wasser',
      'pan': 'Brot / Nahrung',
      'casa': 'Haus / Heim',
      'ciudad / medina': 'Stadt (Arabic: مدينة)',
      'hospital': 'Krankenhaus',
      'farmacia / botica': 'Apotheke',
      'mezquita': 'Moschee (Arabic: مسجد)',
      'ojalá': 'Hoffentlich / So Gott will (Arabic: لو شاء الله)',
    },
    this.germanPhoneticBridges = const {
      'ch /x/ (ach-Laut)': '100% Native Identity! Spanish "J / j" and "G" before e/i (e.g. jardín, gente) match German "ch" in Nacht, Bach, Buch with absolute perfection!',
      'z /ts/': 'Spanish "Z / z" is /θ/ or /s/; German "z" is an affricate /ts/, practiced as the compound sequence "t+s" (tsunami -> Zeit).',
      'sch /ʃ/': 'Practiced with postalveolar retraction contrasting with Spanish dental /s/ (Schule vs escuela).',
      'Prothetic E Prevention': 'Spanish speakers naturally tend to prepend prothetic /e/ before s-clusters (e.g., *esport, *estudent); dedicated drills ensure clean German onsets (Sport, Sprache, Straße).',
      'Subjunctive to Konjunktiv Bridge': 'Spanish "modo subjuntivo" (quisiera, tuviera) maps directly to German Konjunktiv II (ich möchte, ich hätte), accelerating advanced syntax mastery.',
    },
    this.coreA1Vocabulary = const {
      'Hola / Buenos días': 'Hallo / Guten Tag',
      'Buenos días': 'Guten Morgen',
      'Buenas tardes': 'Guten Tag',
      'Buenas noches': 'Guten Abend',
      'Muchas gracias': 'Vielen Dank',
      'Por favor': 'Bitte',
      'Sí': 'Ja',
      'No': 'Nein',
      'Me llamo ...': 'Mein Name ist ...',
      '¿De dónde es usted?': 'Woher kommen Sie?',
      'Soy de ...': 'Ich komme aus ...',
      'Agua': 'Wasser',
      'Pan': 'Brot',
      'Hospital': 'Krankenhaus',
      'Farmacia': 'Apotheke',
      'Estación de tren': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'spanish': '¡Hola! ¿Habla usted alemán?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'spanish': 'Sí, estoy aprendiendo el idioma alemán ahora.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'spanish': 'Por favor, ¿dónde está la farmacia más cercana?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'spanish': '¡Muchas gracias por su ayuda!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Spanish prepositional relation into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
