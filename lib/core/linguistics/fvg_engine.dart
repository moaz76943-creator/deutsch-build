class FvgEntry {
  final String nounPhrase;
  final String? preposition;
  final String functionVerb;
  final String simpleVerbEquivalent;
  final String arabicGloss;
  final String cefrLevel;

  const FvgEntry({
    required this.nounPhrase,
    this.preposition,
    required this.functionVerb,
    required this.simpleVerbEquivalent,
    required this.arabicGloss,
    required this.cefrLevel,
  });

  String get fullPhrase => preposition != null
      ? '$preposition $nounPhrase $functionVerb'
      : '$nounPhrase $functionVerb';
}

/// Offline linguistic engine mapping and validating German Noun-Verb Collocations (FVG).
class FunktionsverbgefuegeEngine {
  static const List<FvgEntry> _fvgRegistry = [
    FvgEntry(
      nounPhrase: 'eine Entscheidung',
      functionVerb: 'treffen',
      simpleVerbEquivalent: 'entscheiden',
      arabicGloss: 'يتخذ قراراً',
      cefrLevel: 'B1',
    ),
    FvgEntry(
      nounPhrase: 'Verfügung',
      preposition: 'zur',
      functionVerb: 'stehen',
      simpleVerbEquivalent: 'verfügbar sein',
      arabicGloss: 'يكون متاحاً تحت التصرف',
      cefrLevel: 'B2',
    ),
    FvgEntry(
      nounPhrase: 'Verfügung',
      preposition: 'zur',
      functionVerb: 'stellen',
      simpleVerbEquivalent: 'bereitstellen',
      arabicGloss: 'يضع تحت التصرف / يتيح',
      cefrLevel: 'B2',
    ),
    FvgEntry(
      nounPhrase: 'Abschied',
      functionVerb: 'nehmen',
      simpleVerbEquivalent: 'sich verabschieden',
      arabicGloss: 'يودّع',
      cefrLevel: 'B1',
    ),
    FvgEntry(
      nounPhrase: 'Anspruch',
      preposition: 'in',
      functionVerb: 'nehmen',
      simpleVerbEquivalent: 'beanspruchen / nutzen',
      arabicGloss: 'يستفيد من / يستهلك وقتاً أو جهداً',
      cefrLevel: 'B2',
    ),
    FvgEntry(
      nounPhrase: 'Frage',
      preposition: 'in',
      functionVerb: 'kommen',
      simpleVerbEquivalent: 'möglich sein',
      arabicGloss: 'يكون وارداً في الحسبان',
      cefrLevel: 'B1',
    ),
    FvgEntry(
      nounPhrase: 'Kritik',
      functionVerb: 'üben',
      simpleVerbEquivalent: 'kritisieren',
      arabicGloss: 'يوجه نقداً',
      cefrLevel: 'B2',
    ),
  ];

  /// يبحث عن المتلازمة بناء على الفعل البسيط المكافئ
  FvgEntry? findBySimpleVerb(String simpleVerb) {
    for (final entry in _fvgRegistry) {
      if (entry.simpleVerbEquivalent.toLowerCase().contains(simpleVerb.toLowerCase())) {
        return entry;
      }
    }
    return null;
  }

  /// التحقق من صحة الاقتران بين الاسم وحرف الجر والفعل الوظيفي
  bool validateCollocation(String noun, String verb, {String? prep}) {
    for (final entry in _fvgRegistry) {
      final matchNoun = entry.nounPhrase.toLowerCase().contains(noun.toLowerCase());
      final matchVerb = entry.functionVerb.toLowerCase() == verb.toLowerCase();
      final matchPrep = (prep == null && entry.preposition == null) ||
          (prep != null && entry.preposition != null &&
           entry.preposition!.toLowerCase() == prep.toLowerCase());

      if (matchNoun && matchVerb && matchPrep) return true;
    }
    return false;
  }
}
