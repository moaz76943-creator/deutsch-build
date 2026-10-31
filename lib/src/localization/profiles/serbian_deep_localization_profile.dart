import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Serbian (Српски језик / Srpski jezik).
///
/// South Slavic language spoken by 10M+ people across Serbia, Bosnia, Montenegro,
/// and diaspora in Germany, Austria, and Switzerland. Features active dual-script
/// digraphic sovereignty (Cyrillic & Latin), 3 grammatical genders matching German
/// der/die/das, a 7-case declension framework, and exact 1:1 match of letter 'Ц/C'
/// to German 'Z/z' (/ts/).
@immutable
class SerbianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final List<String> supportedScripts; // Active digraphic sovereignty
  final bool hasThreeGenders;
  final bool hasNativeGermanZSound; // Serbian 'Ц/C' = German 'Z/z' (/ts/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const SerbianDeepLocalizationProfile({
    this.languageName = 'Serbian',
    this.autonym = 'Српски језик / Srpski jezik',
    this.iso6391 = 'sr',
    this.iso6392 = 'srp',
    this.languageFamily = 'Indo-European',
    this.branch = 'South Slavic (Western)',
    this.writingDirection = 'ltr',
    this.supportedScripts = const ['Cyrillic (Ћирилица - official)', 'Latin (Latinica - equal)'],
    this.hasThreeGenders = true,
    this.hasNativeGermanZSound = true, // 'Ц/c' is strictly /ts/
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Мушки род / Muški rod (Masculin)': 'German Maskulinum (der) - e.g., човек (der Mann), сто (der Tisch).',
      'Женски род / Ženski rod (Feminin)': 'German Femininum (die) - e.g., жена (die Frau), књига (das Buch/fem in SR, die Schule).',
      'Средњи род / Srednji rod (Neutrum)': 'German Neutrum (das) - e.g., дете (das Kind), село (das Dorf).',
    },
    this.caseSystemAlignment = const {
      '1. Номинатив / Nominativ (Ко? Шта?)': 'Direct subject. Matches German Nominativ (Wer? Was? - der Mann).',
      '2. Генитив / Genitiv (Кога? Чега?)': 'Possession and partitive. Matches German Genitiv (Wessen? - des Mannes).',
      '3. Датив / Dativ (Коме? Чему?)': 'Indirect object / recipient. Matches German Dativ (Wem? - dem Mann).',
      '4. Акузатив / Akuzativ (Кога? Шта?)': 'Direct object. Matches German Akkusativ (Wen? Was? - den Mann).',
      '5. Вокатив / Vokativ (Хеј!)': 'Direct address (Пријатељу!). Matches German direct address.',
      '6. Инструментал / Instrumental (С ким? Чим?)': 'Accompaniment or means. Matches German Dativ with preposition "mit".',
      '7. Локатив / Lokativ (О коме? О чему?)': 'Location and topic. Matches German Dativ with prepositions "in", "an", "o".',
    },
    this.culturalIslamicLexicon = const {
      'добар дан / селам': 'Guten Tag / Begrüßung / Friede (Arabic: سلام)',
      'хвала / хвала лепо': 'Danke / Vielen Dank',
      'молим / изволите': 'Bitte',
      'књига / ћирилична књига': 'Buch',
      'школа': 'Schule',
      'учитељ / професор': 'Lehrer / Professor',
      'знање / наука': 'Wissen / Wissenschaft',
      'правда': 'Gerechtigkeit',
      'молитва / намаз': 'Gebet / Salāt (Persian: نماز)',
      'халал': 'Erlaubt / Halal (Arabic: حلال)',
      'пријатељ / друг': 'Freund',
      'вода': 'Wasser',
      'хлеб': 'Brot / Nahrung',
      'кућа / дом': 'Haus / Heim',
      'град': 'Stadt',
      'болница': 'Krankenhaus',
      'апотека': 'Apotheke',
      'џамија': 'Moschee (Arabic: جامع)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Serbian "Ц / ц" / "C / c" is strictly /ts/ (e.g. цена, центар), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Serbian "Ш / ш" / "Š / š" (школа, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Serbian "Ч / ч" / "Č / č" (чаша, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Serbian "Х / х" / "H / h" (хлеб, храна, Bach, Nacht).',
      'Dual Script Sovereignty': 'Serbian learners effortlessly operate both Cyrillic and Latin alphabets, eliminating any orthographic barrier when transitioning to German.',
    },
    this.coreA1Vocabulary = const {
      'Добар дан / Здраво': 'Hallo / Guten Tag',
      'Добро јутро': 'Guten Morgen',
      'Добар дан': 'Guten Tag',
      'Добро вече': 'Guten Abend',
      'Хвала лепо': 'Vielen Dank',
      'Молим': 'Bitte',
      'Да': 'Ja',
      'Не': 'Nein',
      'Зовем се ...': 'Mein Name ist ...',
      'Одакле сте?': 'Woher kommen Sie?',
      'Ја сам из ...': 'Ich komme aus ...',
      'Вода': 'Wasser',
      'Хлеб': 'Brot',
      'Болница': 'Krankenhaus',
      'Апотека': 'Apotheke',
      'Железничка станица': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'serbian': 'Добар дан! Да ли говорите немачки? / Dobar dan! Da li govorite nemački?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'serbian': 'Да, тренутно учим немачки језик. / Da, trenutno učim nemački jezik.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'serbian': 'Молим вас, где се налази најближа апотека? / Molim vas, gde se nalazi najbliža apoteka?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'serbian': 'Много вам хвала на помоћи! / Mnogo vam hvala na pomoći!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Serbian case into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
