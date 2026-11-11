/// Pragmatic function of the conversational discourse marker.
enum DiscourseMarkerFunction {
  conversationalSummary,  // also (إذن / حسناً - خلاصة الحديث)
  qualifiedHesitation,    // na ja (حسناً - تردد أو تحفظ نسبي)
  metaphoricalApproximation, // sozusagen / quasi (نوعاً ما / مجازياً)
  categoricalEmphasis,    // überhaupt (على الإطلاق / قطعي)
  recapitulationCertainty,// jedenfalls (على أي حال / في النهاية)
  essentialReality,       // im Grunde genommen (في واقع الأمر وجوهر المسألة)
}

/// Syntactic placement of the marker in the conversational turn.
enum MarkerPosition { preFieldZero, middleField, parenthetical }

/// Analysis descriptor of an integrated discourse marker in spoken dialogue.
class DiscourseMarkerExpression {
  final String marker;
  final DiscourseMarkerFunction function;
  final MarkerPosition position;
  final String baseUtterance;
  final String pragmaticUtterance;
  final String arabicEquivalence;

  DiscourseMarkerExpression({
    required this.marker,
    required this.function,
    required this.position,
    required this.baseUtterance,
    required this.pragmaticUtterance,
    required this.arabicEquivalence,
  });

  Map<String, dynamic> toJson() => {
        'marker': marker,
        'function': function.name,
        'position': position.name,
        'base': baseUtterance,
        'pragmatic': pragmaticUtterance,
        'arabic': arabicEquivalence,
      };
}

/// Offline rule engine analyzing German Spoken Discourse Markers (Gesprächs- und Diskursmarker).
/// Enforces native pragmatic nuances and position rules (Position 0 vs. Mittelfeld) in oral communication.
class GermanDiscourseMarkerEngine {
  static const Map<String, DiscourseMarkerFunction> _markerFunctions = {
    'also': DiscourseMarkerFunction.conversationalSummary,
    'na ja': DiscourseMarkerFunction.qualifiedHesitation,
    'sozusagen': DiscourseMarkerFunction.metaphoricalApproximation,
    'quasi': DiscourseMarkerFunction.metaphoricalApproximation,
    'überhaupt': DiscourseMarkerFunction.categoricalEmphasis,
    'ueberhaupt': DiscourseMarkerFunction.categoricalEmphasis,
    'jedenfalls': DiscourseMarkerFunction.recapitulationCertainty,
    'im grunde genommen': DiscourseMarkerFunction.essentialReality,
  };

  /// Apply discourse marker to a conversational turn.
  static DiscourseMarkerExpression applyMarker({
    required String marker,
    required String utterance,
    MarkerPosition position = MarkerPosition.preFieldZero,
  }) {
    final cleanMarker = marker.trim();
    final lowerMarker = cleanMarker.toLowerCase();
    final cleanUtterance = utterance.trim();

    final function = _markerFunctions[lowerMarker] ?? DiscourseMarkerFunction.conversationalSummary;
    String formattedUtterance = '';
    String arabic = '';

    switch (position) {
      case MarkerPosition.preFieldZero:
        // Position 0: Marker, comma, complete main clause (Subject + Verb)
        formattedUtterance = '$cleanMarker, $cleanUtterance';
        break;

      case MarkerPosition.middleField:
        // Mittelfeld: Subject + Verb + Marker + Rest
        final tokens = cleanUtterance.split(' ');
        if (tokens.length >= 2) {
          final subj = tokens[0];
          final verb = tokens[1];
          final rest = tokens.sublist(2).join(' ');
          formattedUtterance = '$subj $verb $cleanMarker $rest'.trim();
        } else {
          formattedUtterance = '$cleanUtterance ($cleanMarker)';
        }
        break;

      case MarkerPosition.parenthetical:
        formattedUtterance = '$cleanUtterance - $cleanMarker -';
        break;
    }

    switch (function) {
      case DiscourseMarkerFunction.conversationalSummary:
        arabic = 'إذن / حسناً: إشارة إلى التلخيص أو استئناف الفكرة الرئيسية';
        break;
      case DiscourseMarkerFunction.qualifiedHesitation:
        arabic = 'حسناً: إظهار التحفظ والتردد والقبول المشروط';
        break;
      case DiscourseMarkerFunction.metaphoricalApproximation:
        arabic = 'نوعاً ما / مجازاً: تقريب المعنى وتلطيف التعبير';
        break;
      case DiscourseMarkerFunction.categoricalEmphasis:
        arabic = 'على الإطلاق: تعميم قاطع وتوكيد معنوي جازم';
        break;
      case DiscourseMarkerFunction.recapitulationCertainty:
        arabic = 'على أية حال: حسم الأمر والعودة إلى النقطة الأهم';
        break;
      case DiscourseMarkerFunction.essentialReality:
        arabic = 'في واقع الأمر وجوهره: توضيح الحقيقة الكامنة خلف الظاهر';
        break;
    }

    return DiscourseMarkerExpression(
      marker: cleanMarker,
      function: function,
      position: position,
      baseUtterance: cleanUtterance,
      pragmaticUtterance: formattedUtterance,
      arabicEquivalence: arabic,
    );
  }
}
