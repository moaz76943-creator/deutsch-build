/// Capabilities a directed-pair grammar profile can declare.
/// Inflection enums live on [LanguageGrammarRuleProvider] so the two
/// libraries do not define the same type twice.
enum GrammarFeature {
  gender,
  caseSystem,
  grammaticalCase,
  nounClasses,
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
