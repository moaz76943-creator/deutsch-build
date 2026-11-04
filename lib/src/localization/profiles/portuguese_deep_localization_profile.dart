import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Portuguese (Português).
///
/// Global Romance language spoken by 260M+ people (Portugal, Brazil, Angola, etc.).
/// Characterized by coda sibilant palatalization (/ʃ/ in European Portuguese matching
/// German 'sch' and 'sp/st' onsets), nasal vowels (ã, õ), preposed definite articles (o/a),
/// contracted prepositions (do/no/ao matching German im/am/zum), and personal infinitive.
@immutable
class PortugueseDeepLocalizationProfile {
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
  final bool hasSibilantPalatalization; // coda s/z = /ʃ/ matching German sch!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const PortugueseDeepLocalizationProfile({
    this.languageName = 'Portuguese',
    this.autonym = 'Português',
    this.iso6391 = 'pt',
    this.iso6392 = 'por',
    this.languageFamily = 'Indo-European',
    this.branch = 'Romance (Ibero-Romance)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Portuguese alphabet)',
    this.specialCharacters = const ['á', 'â', 'ã', 'à', 'ç', 'é', 'ê', 'í', 'ó', 'ô', 'õ', 'ú'],
    this.hasTwoGenders = true,
    this.hasSibilantPalatalization = true, // 's' in festa, inglês is /ʃ/!
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Gênero masculino (o)': 'German Maskulinum (der) - e.g., o homem (der Mann), o livro (das Buch/masc in PT).',
      'Gênero feminino (a)': 'German Femininum (die) - e.g., a mulher (die Frau), a escola (die Schule).',
      'Artigos contraídos (do / no / ao)': 'Direct parallel to German article contractions: do = des (de+o), no = im (em+o), ao = dem (a+o).',
    },
    this.caseSystemAlignment = const {
      'Nominativ (Sujeito)': 'Direct subject without preposition. Matches German Nominativ (o homem lê).',
      'Akkusativ (Objeto direto)': 'Direct object without preposition (eu vejo o homem). Matches German Akkusativ (ich sehe den Mann).',
      'Dativ (Objeto indireto - a / para)': 'Marked with preposition "a" or "para" (eu dou o livro ao homem). Matches German Dativ (ich gebe dem Mann das Buch).',
      'Genitiv (Posse - de / do)': 'Marked with preposition "de" or contracted "do" (o livro do professor). Matches German Genitiv (das Buch des Lehrers).',
      'Instrumentalis (Com)': 'Preposition "com" (com o amigo). Matches German Dativ with preposition "mit".',
      'Lokativ (Em / No / Na)': 'Preposition "em" (na cidade). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'olá / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'obrigado / muito obrigado': 'Danke / Vielen Dank',
      'por favor': 'Bitte',
      'livro': 'Buch',
      'escola / madraça': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'professor / mestre': 'Lehrer / Meister',
      'ciência / conhecimento': 'Wissen / Wissenschaft',
      'justiça': 'Gerechtigkeit',
      'oração / salāt': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'amigo': 'Freund',
      'água': 'Wasser',
      'pão': 'Brot / Nahrung',
      'casa': 'Haus / Heim',
      'cidade / almedina': 'Stadt (Arabic: مدينة)',
      'hospital': 'Krankenhaus',
      'farmácia': 'Apotheke',
      'mesquita': 'Moschee (Arabic: مسجد)',
      'oxalá': 'Hoffentlich / So Gott will (Arabic: لو شاء الله)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': '100% Native Identity! In European Portuguese, coda "s" and "z" (festa, inglês, rapaz) are strictly /ʃ/, matching German "sch" (Schule, schön) and "sp/st" onsets (Sport, Stein) natively!',
      'tsch /tʃ/': 'Direct match to Brazilian Portuguese "t" before "i" (tio, noite match Deutschland!).',
      'ch /x/ (ach-Laut)': 'Mapped via guttural velar/uvular friction in Brazilian initial "r" (carro, rua -> Bach, Nacht).',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as the compound sequence "t+s" (tsunami -> Zeit).',
      'Personal Infinitive Bridge': 'Portuguese "infinitivo pessoal" (para fazermos, ao chegares) provides a unique intuitive springboard for German infinitive clauses with "um zu" and "ohne zu".',
    },
    this.coreA1Vocabulary = const {
      'Olá / Bom dia': 'Hallo / Guten Tag',
      'Bom dia': 'Guten Morgen',
      'Boa tarde': 'Guten Tag',
      'Boa noite': 'Guten Abend',
      'Muito obrigado': 'Vielen Dank',
      'Por favor': 'Bitte',
      'Sim': 'Ja',
      'Não': 'Nein',
      'Chamo-me / Meu nome é ...': 'Mein Name ist ...',
      'De onde você é?': 'Woher kommen Sie?',
      'Eu sou de ...': 'Ich komme aus ...',
      'Água': 'Wasser',
      'Pão': 'Brot',
      'Hospital': 'Krankenhaus',
      'Farmácia': 'Apotheke',
      'Estação de trem / comboio': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'portuguese': 'Olá! Você fala alemão?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'portuguese': 'Sim, estou aprendendo a língua alemã agora.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'portuguese': 'Por favor, onde fica a farmácia mais próxima?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'portuguese': 'Muito obrigado pela sua ajuda!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Portuguese prepositional relation into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
