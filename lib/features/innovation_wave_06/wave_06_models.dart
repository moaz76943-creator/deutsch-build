class SpotlightSentence {
  final String baseSubject;
  final String baseVerb;
  final String baseObject;

  const SpotlightSentence({
    required this.baseSubject,
    required this.baseVerb,
    required this.baseObject,
  });

  String getFocusedSentence(String focusTarget) {
    if (focusTarget == 'object') {
      return '$baseObject $baseVerb $baseSubject (تقديم المفعول للتركيز)';
    } else if (focusTarget == 'verb') {
      return '$baseSubject $baseVerb $baseObject (التركيز على الحدث)';
    }
    return '$baseSubject $baseVerb $baseObject (الترتيب الطبيعي)';
  }
}

class MitigationLevel {
  final int level;
  final String text;
  final String explanation;

  const MitigationLevel({
    required this.level,
    required this.text,
    required this.explanation,
  });
}
