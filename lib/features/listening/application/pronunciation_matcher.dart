import '../domain/audio_services.dart';
import '../domain/listening_models.dart';

abstract final class PronunciationMatcher {
  static PronunciationFeedback evaluate({
    required AudioRecordingResult recording,
    required String targetText,
    required List<String> targetPhonemes,
  }) {
    if (!recording.available) {
      return PronunciationFeedback(
        signalAvailable: false,
        accuracy: null,
        textAccuracy: null,
        phonemeMatches: const <PronunciationPhonemeMatch>[],
        messageArabic: _unavailableMessage(recording.reason),
      );
    }

    final recognized = recording.recognizedText?.trim();
    final textAccuracy =
        recognized == null || recognized.isEmpty
            ? null
            : _textSimilarity(targetText, recognized);

    final observed = recording.recognizedPhonemes;
    if (targetPhonemes.isEmpty || observed.isEmpty) {
      return PronunciationFeedback(
        signalAvailable: true,
        accuracy: null,
        textAccuracy: textAccuracy,
        phonemeMatches: const <PronunciationPhonemeMatch>[],
        recognizedText: recognized,
        messageArabic:
            'تم التقاط النطق، لكن محلل الفونيمات لم يوفّر قياسًا صوتيًا موثوقًا. '
            'لن يتم اختلاق درجة فونيمات.',
      );
    }

    final alignment = _align(targetPhonemes, observed);
    final matched = alignment.where((item) => item.matched).length;
    final denominator =
        targetPhonemes.length > observed.length
            ? targetPhonemes.length
            : observed.length;
    final accuracy =
        denominator == 0 ? 0.0 : (matched / denominator).clamp(0.0, 1.0);

    return PronunciationFeedback(
      signalAvailable: true,
      accuracy: accuracy.toDouble(),
      textAccuracy: textAccuracy,
      phonemeMatches: List<PronunciationPhonemeMatch>.unmodifiable(alignment),
      recognizedText: recognized,
      messageArabic: accuracy >= .85
          ? 'مطابقة الفونيمات قوية. حافظ على نفس وضوح المخارج.'
          : accuracy >= .6
              ? 'المطابقة جيدة جزئيًا. راجع الفونيمات غير المتطابقة.'
              : 'تحتاج بعض الأصوات إلى تدريب إضافي. راجع الفونيمات المحددة.',
    );
  }

  static List<PronunciationPhonemeMatch> _align(
    List<String> target,
    List<String> observed,
  ) {
    final rows = target.length + 1;
    final cols = observed.length + 1;
    final cost = List<List<int>>.generate(
      rows,
      (_) => List<int>.filled(cols, 0),
    );
    for (var i = 0; i < rows; i += 1) {
      cost[i][0] = i;
    }
    for (var j = 0; j < cols; j += 1) {
      cost[0][j] = j;
    }
    for (var i = 1; i < rows; i += 1) {
      for (var j = 1; j < cols; j += 1) {
        final substitution =
            cost[i - 1][j - 1] + (target[i - 1] == observed[j - 1] ? 0 : 1);
        final deletion = cost[i - 1][j] + 1;
        final insertion = cost[i][j - 1] + 1;
        var best = substitution;
        if (deletion < best) best = deletion;
        if (insertion < best) best = insertion;
        cost[i][j] = best;
      }
    }

    var i = target.length;
    var j = observed.length;
    final reversed = <PronunciationPhonemeMatch>[];
    while (i > 0) {
      if (j > 0) {
        final equal = target[i - 1] == observed[j - 1];
        final diagonal = cost[i - 1][j - 1] + (equal ? 0 : 1);
        if (cost[i][j] == diagonal) {
          reversed.add(
            PronunciationPhonemeMatch(
              target: target[i - 1],
              observed: observed[j - 1],
              matched: equal,
            ),
          );
          i -= 1;
          j -= 1;
          continue;
        }
      }
      if (cost[i][j] == cost[i - 1][j] + 1) {
        reversed.add(
          PronunciationPhonemeMatch(
            target: target[i - 1],
            observed: null,
            matched: false,
          ),
        );
        i -= 1;
      } else if (j > 0) {
        j -= 1;
      }
    }

    return reversed.reversed.toList(growable: false);
  }

  static double _textSimilarity(String target, String observed) {
    final left = _normalizeText(target);
    final right = _normalizeText(observed);
    if (left == right) return 1;
    if (left.isEmpty || right.isEmpty) return 0;

    final previous = List<int>.generate(right.length + 1, (index) => index);
    for (var i = 1; i <= left.length; i += 1) {
      final current = List<int>.filled(right.length + 1, 0);
      current[0] = i;
      for (var j = 1; j <= right.length; j += 1) {
        final substitution =
            previous[j - 1] + (left[i - 1] == right[j - 1] ? 0 : 1);
        final deletion = previous[j] + 1;
        final insertion = current[j - 1] + 1;
        var best = substitution;
        if (deletion < best) best = deletion;
        if (insertion < best) best = insertion;
        current[j] = best;
      }
      for (var j = 0; j < current.length; j += 1) {
        previous[j] = current[j];
      }
    }
    final longest = left.length > right.length ? left.length : right.length;
    return (1 - previous[right.length] / longest).clamp(0.0, 1.0).toDouble();
  }

  static String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[.,!?;:„“"…]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _unavailableMessage(String? reason) => switch (reason) {
        'microphone_permission_required' =>
          'إذن الميكروفون مطلوب قبل بدء تدريب النطق.',
        _ => 'التسجيل غير متاح حاليًا، لذلك لم يتم إنشاء تقييم نطق.',
      };
}
