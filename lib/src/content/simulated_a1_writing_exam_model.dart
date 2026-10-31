/// Model simulating A1 Writing tasks (Form Filling & Short Email Composition).
class SimulatedA1WritingExamModel {
  static const Map<String, String> requiredFormFields = {
    'Familienname': 'اسم العائلة / اللقب',
    'Vorname': 'الاسم الشخصي الأول',
    'Geburtsdatum': 'تاريخ الميلاد (يوم/شهر/سنة)',
    'Wohnort': 'مدينة أو قرية السكن الحالية',
    'Beruf': 'المهنة أو مجال الدراسة',
  };

  static const String emailWritingPrompt =
      'Ihre Deutschlehrerin, Frau Sommer, hat Sie zum gemeinsamen Sprachcafé am Samstag eingeladen.\n'
      'Schreiben Sie eine kurze Nachricht (ca. 25-35 Wörter):\n'
      '1. Bedanken Sie sich für die freundliche Einladung.\n'
      '2. Sagen Sie, dass Sie sehr gerne kommen.\n'
      '3. Fragen Sie, ob Sie etwas Gebäck oder Saft mitbringen sollen.';

  /// Evaluates whether learner email satisfies all three required CEFR communicative points.
  Map<String, dynamic> evaluateEmailResponse(String learnerText) {
    final lower = learnerText.toLowerCase();
    final wordCount = learnerText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    final hasThanks = lower.contains('danke') || lower.contains('vielen dank');
    final hasAcceptance = lower.contains('komme gern') || lower.contains('komme sehr gern') || lower.contains('ich komme');
    final hasOffer = lower.contains('mitbringen') || lower.contains('kuchen') || lower.contains('saft');

    final pointsAchieved = (hasThanks ? 1 : 0) + (hasAcceptance ? 1 : 0) + (hasOffer ? 1 : 0);
    final isWordCountSufficient = wordCount >= 20;

    return {
      'wordCount': wordCount,
      'isLengthAcceptable': isWordCountSufficient,
      'hasThanksGuidance': hasThanks,
      'hasAcceptanceGuidance': hasAcceptance,
      'hasOfferGuidance': hasOffer,
      'totalScoreOutOf3': pointsAchieved,
      'isPassed': pointsAchieved >= 2 && isWordCountSufficient,
    };
  }
}
