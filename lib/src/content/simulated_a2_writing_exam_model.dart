/// Model simulating A2 Writing exam (Personal SMS & Semi-Formal Email).
class SimulatedA2WritingExamModel {
  static const String a2EmailPrompt =
      'Sie können am Montag nicht zu Ihrem Deutschkurs kommen.\n'
      'Schreiben Sie eine E-Mail an Ihren Kursleiter, Herrn Bergmann (ca. 40-50 Wörter):\n'
      '1. Entschuldigen Sie sich höflich für Ihr Fehlen.\n'
      '2. Erklären Sie den Grund (z.B. dringender Arzttermin).\n'
      '3. Bitten Sie um die Hausaufgaben für die nächste Stunde.';

  /// Evaluates A2 email response against CEFR task fulfillment criteria.
  Map<String, dynamic> evaluateA2Email(String text) {
    final lower = text.toLowerCase();
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    final hasSalutation = lower.contains('sehr geehrter herr') || lower.contains('lieber herr');
    final hasApology = lower.contains('entschuldigen') || lower.contains('leider nicht kommen');
    final hasReason = lower.contains('termin') || lower.contains('arzt') || lower.contains('krank');
    final hasHomeworkRequest = lower.contains('hausaufgabe') || lower.contains('schicken') || lower.contains('übung');
    final hasClosing = lower.contains('viele grüße') || lower.contains('mit freundlichen grüßen');

    final contentScore = (hasApology ? 1 : 0) + (hasReason ? 1 : 0) + (hasHomeworkRequest ? 1 : 0);
    final formalScore = (hasSalutation ? 1 : 0) + (hasClosing ? 1 : 0);
    final isLengthValid = words >= 35;

    return {
      'wordCount': words,
      'isLengthValid': isLengthValid,
      'contentPointsScore': contentScore, // Max 3
      'formalStructureScore': formalScore, // Max 2
      'isPassed': contentScore >= 2 && formalScore >= 1 && isLengthValid,
    };
  }
}
