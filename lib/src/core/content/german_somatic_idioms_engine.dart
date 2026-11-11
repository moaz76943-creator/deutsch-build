/// Anatomical domain referenced in the idiom.
enum SomaticBodyPart { hand, head, eye, heart, ear }

/// Analysis descriptor of an identified somatic German idiom.
class SomaticIdiomEntry {
  final String germanIdiom;
  final SomaticBodyPart bodyPart;
  final String literalGermanMeaning;
  final String figurativeGermanMeaning;
  final String arabicEquivalence;
  final String contextExampleSentence;

  const SomaticIdiomEntry({
    required this.germanIdiom,
    required this.bodyPart,
    required this.literalGermanMeaning,
    required this.figurativeGermanMeaning,
    required this.arabicEquivalence,
    required this.contextExampleSentence,
  });

  Map<String, dynamic> toJson() => {
        'idiom': germanIdiom,
        'body_part': bodyPart.name,
        'literal': literalGermanMeaning,
        'figurative': figurativeGermanMeaning,
        'arabic': arabicEquivalence,
        'example': contextExampleSentence,
      };
}

/// Offline rule engine analyzing German somatic idioms (somatische Phraseologismen / Redewendungen mit Körperteilen).
/// Distinguishes literal physical readings from figurative idiomatic expressions in authentic texts.
class GermanSomaticIdiomsEngine {
  static const List<SomaticIdiomEntry> _idiomRegistry = [
    // Hand
    SomaticIdiomEntry(
      germanIdiom: 'zwei linke haende haben',
      bodyPart: SomaticBodyPart.hand,
      literalGermanMeaning: 'körperlich zwei linke Hände besitzen',
      figurativeGermanMeaning: 'sehr ungeschickt bei handwerklichen Arbeiten sein',
      arabicEquivalence: 'أخرق اليدين / قليل الحيلة في الأعمال اليدوية',
      contextExampleSentence: 'Er kann das Regal nicht aufbauen, er hat zwei linke Hände.',
    ),
    SomaticIdiomEntry(
      germanIdiom: 'unter die arme greifen',
      bodyPart: SomaticBodyPart.hand,
      literalGermanMeaning: 'jemanden physisch unter den Armen stützen',
      figurativeGermanMeaning: 'jemandem in einer Notlage finanziell oder tatkräftig helfen',
      arabicEquivalence: 'يمد له يد العون / يسانده في أزمته',
      contextExampleSentence: 'Die Eltern greifen dem Studenten finanziell unter die Arme.',
    ),
    // Kopf
    SomaticIdiomEntry(
      germanIdiom: 'einen kuehlen kopf bewahren',
      bodyPart: SomaticBodyPart.head,
      literalGermanMeaning: 'einen kalten Schädel behalten',
      figurativeGermanMeaning: 'in einer schwierigen, stressigen Situation ruhig und gelassen bleiben',
      arabicEquivalence: 'يحافظ على هدوئه ورباطة جأشه في الأزمات',
      contextExampleSentence: 'In der Prüfung muss man vor allem einen kühlen Kopf bewahren.',
    ),
    SomaticIdiomEntry(
      germanIdiom: 'sich den kopf zerbrechen',
      bodyPart: SomaticBodyPart.head,
      literalGermanMeaning: 'den eigenen Schädel zerschlagen',
      figurativeGermanMeaning: 'sehr intensiv und angestrengt über ein Problem nachdenken',
      arabicEquivalence: 'يُعمل فكره بعمق / يُجهد عقله في التفكير',
      contextExampleSentence: 'Ich zerbreche mir seit Tagen den Kopf über diese schwere Frage.',
    ),
    // Auge
    SomaticIdiomEntry(
      germanIdiom: 'ein auge zudruecken',
      bodyPart: SomaticBodyPart.eye,
      literalGermanMeaning: 'ein physisches Auge schließen',
      figurativeGermanMeaning: 'einen kleinen Fehler nachsichtig übersehen und nicht bestrafen',
      arabicEquivalence: 'يغض الطرف / يتسامح ويتساهل مع هفوة بسيطة',
      contextExampleSentence: 'Der Prüfer drückte bei der kleinen Unachtsamkeit ein Auge zu.',
    ),
    // Herz
    SomaticIdiomEntry(
      germanIdiom: 'ein herz aus gold haben',
      bodyPart: SomaticBodyPart.heart,
      literalGermanMeaning: 'ein Herz aus Edelmetall besitzen',
      figurativeGermanMeaning: 'außerordentlich gütig, hilfsbereit und edelmütig sein',
      arabicEquivalence: 'طيب القلب للغاية / كريم ونبيل السريرة',
      contextExampleSentence: 'Unsere Großmutter hat wirklich ein Herz aus Gold.',
    ),
    SomaticIdiomEntry(
      germanIdiom: 'schweren herzens',
      bodyPart: SomaticBodyPart.heart,
      literalGermanMeaning: 'mit einem physisch schweren Herzen',
      figurativeGermanMeaning: 'sehr ungern und mit innerem Bedauern eine Entscheidung treffen',
      arabicEquivalence: 'بقلب مثقل بالأسى / ببالغ الأسف والأسى',
      contextExampleSentence: 'Schweren Herzens musste er sein altes Auto verkaufen.',
    ),
    // Ohr
    SomaticIdiomEntry(
      germanIdiom: 'ein offenes ohr haben',
      bodyPart: SomaticBodyPart.ear,
      literalGermanMeaning: 'physisch unverstopfte Ohren haben',
      figurativeGermanMeaning: 'jemandem verständnisvoll und hilfsbereit zuhören',
      arabicEquivalence: 'يصغي باهتمام وتفهم / رحب الصدر في الاستماع',
      contextExampleSentence: 'Mein Lehrer hat immer ein offenes Ohr für unsere Sorgen.',
    ),
  ];

  /// Scan input text and detect recognized somatic idioms.
  static List<SomaticIdiomEntry> detectIdioms(String text) {
    if (text.isEmpty) return const [];
    final clean = text.trim().toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue');

    final matches = <SomaticIdiomEntry>[];
    for (final entry in _idiomRegistry) {
      if (clean.contains(entry.germanIdiom)) {
        matches.add(entry);
      }
    }
    return matches;
  }

  /// Retrieve idiom details by anatomical category.
  static List<SomaticIdiomEntry> getIdiomsByBodyPart(SomaticBodyPart part) {
    return _idiomRegistry.where((e) => e.bodyPart == part).toList();
  }
}
