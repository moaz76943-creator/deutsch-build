/// Model simulating B2 Writing exam (Formal Complaint & Dialectical Argumentation Essay).
class SimulatedB2WritingExamModel {
  static const String b2FormalComplaintPrompt =
      'Sie haben einen Sprachkurs gebucht, doch der zugesagte muttersprachliche Konversationsunterricht '
      'fällt wiederholt ohne Ersatz aus.\n'
      'Schreiben Sie eine förmliche Beschwerde-E-Mail an die Institutsleitung (ca. 120-150 Wörter):\n'
      '1. Beziehen Sie sich präzise auf Ihre Buchungsnummer und den Vertrag.\n'
      '2. Schildern Sie sachlich und höflich den Grund Ihrer Beanstandung.\n'
      '3. Formulieren Sie eine konstruktive Lösungserwartung (z.B. Nachholtermine oder Teilrückerstattung).\n'
      '4. Setzen Sie eine angemessene Frist zur schriftlichen Stellungnahme.';

  /// Evaluates B2 formal complaint against CEFR B2 criteria.
  Map<String, dynamic> evaluateB2FormalEmail(String text) {
    final lower = text.toLowerCase();
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    final hasFormalSalutation = lower.contains('sehr geehrte damen und herren') || lower.contains('sehr geehrte institutsleitung');
    final hasReference = lower.contains('buchungsnummer') || lower.contains('vertrag') || lower.contains('bezugnehmend');
    final hasComplaint = lower.contains('beschwerde') || lower.contains('ausfall') || lower.contains('beanstandung');
    final hasSolution = lower.contains('nachholtermin') || lower.contains('rückerstattung') || lower.contains('lösung');
    final hasDeadline = lower.contains('frist') || lower.contains('bis zum') || lower.contains('stellungnahme');
    final hasFormalClosing = lower.contains('mit freundlichen grüßen');

    int fulfilledCriteria = 0;
    if (hasFormalSalutation) fulfilledCriteria++;
    if (hasReference) fulfilledCriteria++;
    if (hasComplaint) fulfilledCriteria++;
    if (hasSolution) fulfilledCriteria++;
    if (hasDeadline) fulfilledCriteria++;
    if (hasFormalClosing) fulfilledCriteria++;

    final isLengthValid = words >= 100;

    return {
      'wordCount': words,
      'isLengthValid': isLengthValid,
      'criteriaFulfilledCount': fulfilledCriteria, // Max 6
      'isPassed': fulfilledCriteria >= 5 && isLengthValid,
    };
  }
}
