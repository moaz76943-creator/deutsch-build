/// Model simulating B1 Writing exam (Teil 1: Social Media Forum Post Expressing Opinion).
class SimulatedB1WritingExamModel {
  static const String b1OpinionPrompt =
      'Sie haben im Online-Forum einen Diskussionsbeitrag zum Thema "Plastikfreies Leben im Alltag" gelesen.\n'
      'Schreiben Sie einen Forumsbeitrag (ca. 80-100 Wörter):\n'
      '1. Äußern Sie Ihre persönliche Meinung zu diesem Umweltthema.\n'
      '2. Nennen Sie Gründe, warum Plastikmüll vermieden werden sollte.\n'
      '3. Geben Sie praktische Beispiele für umweltfreundliche Alternativen (z.B. Stoffbeutel, Glasflaschen).\n'
      '4. Beschreiben Sie die Situation in Ihrem Heimatland.';

  /// Evaluates B1 opinion post against CEFR B1 qualitative criteria.
  Map<String, dynamic> evaluateB1OpinionPost(String essayText) {
    final lower = essayText.toLowerCase();
    final words = essayText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    final hasOpinion = lower.contains('meiner meinung nach') || lower.contains('ich bin der ansicht') || lower.contains('ich denke');
    final hasReasons = lower.contains('weil') || lower.contains('daher') || lower.contains('deshalb') || lower.contains('grund');
    final hasAlternatives = lower.contains('alternative') || lower.contains('glas') || lower.contains('stoff') || lower.contains('beutel');
    final hasHomeCountry = lower.contains('in meinem heimatland') || lower.contains('zu hause');

    int fulfilledPoints = 0;
    if (hasOpinion) fulfilledPoints++;
    if (hasReasons) fulfilledPoints++;
    if (hasAlternatives) fulfilledPoints++;
    if (hasHomeCountry) fulfilledPoints++;

    final isLengthSufficient = words >= 70;

    return {
      'wordCount': words,
      'isLengthSufficient': isLengthSufficient,
      'fulfilledPointsCount': fulfilledPoints, // Max 4
      'hasConnectors': lower.contains('außerdem') || lower.contains('darüber hinaus') || lower.contains('obwohl'),
      'isPassed': fulfilledPoints >= 3 && isLengthSufficient,
    };
  }
}
