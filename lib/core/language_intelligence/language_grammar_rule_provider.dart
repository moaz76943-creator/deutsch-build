enum GrammaticalGender {
  masculine,
  feminine,
  neuter,
  common,
  none,
}

enum GrammaticalCategory {
  noun,
  verb,
  adjective,
  adverb,
  preposition,
  particle,
  unknown,
}

enum GrammaticalCase {
  nominative,
  accusative,
  dative,
  genitive,
  instrumental,
  prepositional,
  locative,
  vocative,
  ablative,
  ergative,
  absolutive,
  none,
}

enum GrammaticalNumber {
  singular,
  dual,
  plural,
  none,
}

enum GrammaticalPerson {
  first,
  second,
  third,
  none,
}

enum GrammaticalTense {
  past,
  present,
  future,
  none,
}

enum GrammaticalAspect {
  perfective,
  imperfective,
  continuous,
  none,
}

enum GrammaticalMood {
  indicative,
  subjunctive,
  imperative,
  conditional,
  optative,
  jussive,
  none,
}

enum GrammarFeature {
  gender,
  nounClasses,
  grammaticalCase,
  number,
  agreement,
  tense,
  aspect,
  mood,
  person,
  rootPattern,
  inflectional,
  agglutinative,
  analytic,
}

class GrammarProfile {
  final Set<GrammarFeature> supportedFeatures;
  final Set<GrammaticalCase> supportedCases;
  final Set<GrammaticalGender> supportedGenders;
  final Set<GrammaticalNumber> supportedNumbers;

  const GrammarProfile({
    this.supportedFeatures = const {},
    this.supportedCases = const {},
    this.supportedGenders = const {},
    this.supportedNumbers = const {},
  });

  bool supportsFeature(GrammarFeature feature) => supportedFeatures.contains(feature);
  bool supportsCase(GrammaticalCase gCase) => supportedCases.contains(gCase);
  bool supportsGender(GrammaticalGender gender) => supportedGenders.contains(gender);
  bool supportsNumber(GrammaticalNumber number) => supportedNumbers.contains(number);
}

abstract class LanguageGrammarRuleProvider {
  String get languageCode;

  /// الملف التعريفي للقواعد النحوية المدعومة في هذه اللغة
  GrammarProfile get profile => const GrammarProfile();

  /// استنتاج الجنس النحوي للكلمة
  GrammaticalGender determineGender(String word, {String? article});

  /// استنتاج الفئة النحوية
  GrammaticalCategory determineCategory(String word, {String? article});

  /// التحقق مما إذا كانت الأداة مطابقة للكلمة
  bool isValidArticle(String word, String article);

  // الخصائص النحوية الموسعة (بالقيمة الافتراضية للغات التي لا تدعمها)
  GrammaticalCase determineCase(String word, {String? context}) => GrammaticalCase.none;
  GrammaticalNumber determineNumber(String word, {String? context}) => GrammaticalNumber.none;
  GrammaticalPerson determinePerson(String word, {String? context}) => GrammaticalPerson.none;
  GrammaticalTense determineTense(String word, {String? context}) => GrammaticalTense.none;
  GrammaticalAspect determineAspect(String word, {String? context}) => GrammaticalAspect.none;
  GrammaticalMood determineMood(String word, {String? context}) => GrammaticalMood.none;

  /// التحقق من دعم خاصية معينة
  bool supportsFeature(GrammarFeature feature) => profile.supportsFeature(feature);
}
