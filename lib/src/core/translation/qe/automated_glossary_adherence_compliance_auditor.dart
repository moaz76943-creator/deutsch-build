/// Task 1794: Automated glossary adherence and mandatory terminology auditor
class GlossaryAdherenceAuditor {
  bool verifyGlossaryMatch(String text, List<String> mandatoryTerms) => mandatoryTerms.every((t) => text.contains(t));
}
