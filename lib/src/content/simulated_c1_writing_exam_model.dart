/// Model simulating C1 Academic Writing exam (Grafikbeschreibung & Stellungnahme).
class SimulatedC1WritingExamModel {
  static const String c1WritingPrompt =
      'Thema: "Digitalisierung der universitären Lehre: Chancen und Grenzen virtueller Seminare"\n'
      'Verfassen Sie einen wissenschaftlich fundierten Text (ca. 200-250 Wörter):\n'
      '1. Fassen Sie die Kernaspekte der Debatte präzise und objektiv zusammen.\n'
      '2. Beschreiben Sie die didaktischen Vorteile digitaler Zugänglichkeit.\n'
      '3. Setzen Sie sich kritisch mit den Herausforderungen für den akademischen Diskurs auseinander.\n'
      '4. Begründen Sie Ihre eigene fundierte Schlussfolgerung mit schlüssigen Argumenten.';

  /// Evaluates C1 academic essay against CEFR C1 criteria (cohesion, academic register, argument depth).
  Map<String, dynamic> evaluateC1AcademicEssay(String text) {
    final lower = text.toLowerCase();
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    // Academic connectors
    final hasAcademicConnectors = lower.contains('diesbezüglich') ||
        lower.contains('folglich') ||
        lower.contains('infolgedessen') ||
        lower.contains('hingegen') ||
        lower.contains('hervorzuheben ist');

    final hasObjectiveSynthesis = lower.contains('einerseits') && lower.contains('andererseits') ||
        lower.contains('zusammenfassend lässt sich festhalten');

    final hasArgumentDepth = lower.contains('studie') ||
        lower.contains('untersuchung') ||
        lower.contains('evidenz') ||
        lower.contains('erkenntnis');

    final isLengthSufficient = words >= 180;

    int score = 0;
    if (hasAcademicConnectors) score += 2;
    if (hasObjectiveSynthesis) score += 2;
    if (hasArgumentDepth) score += 2;

    return {
      'wordCount': words,
      'isLengthSufficient': isLengthSufficient,
      'academicScoreOutOf6': score,
      'hasAdvancedConnectors': hasAcademicConnectors,
      'isPassed': score >= 4 && isLengthSufficient,
    };
  }
}
