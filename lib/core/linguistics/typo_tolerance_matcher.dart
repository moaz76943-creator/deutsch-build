import 'dart:math';

enum TypoMatchStatus {
  exactMatch,
  minorTypo,          // خطأ طباعي طفيف (مسافة 1)
  acceptableTypo,     // خطأ طباعي مقبول (مسافة 2)
  umlautAlternative,  // كتابة الإمالة بصيغة بديلة (ae -> ä, oe -> ö, ue -> ü, ss -> ß)
  noMatch,
}

class TypoMatchResult {
  final TypoMatchStatus status;
  final int distance;
  final String normalizedInput;
  final String normalizedExpected;
  final String feedback;

  const TypoMatchResult({
    required this.status,
    required this.distance,
    required this.normalizedInput,
    required this.normalizedExpected,
    required this.feedback,
  });

  bool get isAccepted =>
      status == TypoMatchStatus.exactMatch ||
      status == TypoMatchStatus.minorTypo ||
      status == TypoMatchStatus.acceptableTypo ||
      status == TypoMatchStatus.umlautAlternative;
}

/// خوارزمية قياس المسافة الإملائية والتسامح مع الأخطاء الطباعية (Study 14)
/// تطبق Damerau-Levenshtein لحساب الإدراج، الحذف، الاستبدال، والقلب المتجاور (Transposition).
class TypoToleranceMatcher {
  static final RegExp _arabicDiacritics = RegExp(r'[\u064B-\u065F\u0670]');

  /// حساب مسافة Damerau-Levenshtein بين نصين
  static int damerauLevenshtein(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    if (s1 == s2) return 0;
    if (len1 == 0) return len2;
    if (len2 == 0) return len1;

    // مصفوفة المسافات
    final matrix = List.generate(
      len1 + 1,
      (_) => List<int>.filled(len2 + 1, 0),
    );

    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;

        var minDistance = min(
          matrix[i - 1][j] + 1,      // حذف
          min(
            matrix[i][j - 1] + 1,      // إدراج
            matrix[i - 1][j - 1] + cost, // استبدال
          ),
        );

        // فحص قلب الحرفين المتجاورين (Transposition)
        if (i > 1 &&
            j > 1 &&
            s1[i - 1] == s2[j - 2] &&
            s1[i - 2] == s2[j - 1]) {
          minDistance = min(minDistance, matrix[i - 2][j - 2] + cost);
        }

        matrix[i][j] = minDistance;
      }
    }

    return matrix[len1][len2];
  }

  /// تقييم إجابة المتعلم ومقارنتها بالإجابة الصحيحة مع تسامح ذكي
  static TypoMatchResult evaluateAnswer({
    required String learnerInput,
    required String expectedTarget,
    int maxAllowedDistance = 2,
    bool isGerman = true,
  }) {
    final cleanInput = _cleanText(learnerInput);
    final cleanExpected = _cleanText(expectedTarget);

    if (cleanInput == cleanExpected) {
      return TypoMatchResult(
        status: TypoMatchStatus.exactMatch,
        distance: 0,
        normalizedInput: cleanInput,
        normalizedExpected: cleanExpected,
        feedback: 'إجابة نموذجية ومطابقة تماماً!',
      );
    }

    // فحص بدائل الإمالة الألمانية (ae/oe/ue/ss)
    if (isGerman) {
      final expandedExpected = _expandUmlauts(cleanExpected);
      final expandedInput = _expandUmlauts(cleanInput);
      if (expandedInput == expandedExpected) {
        return TypoMatchResult(
          status: TypoMatchStatus.umlautAlternative,
          distance: 1,
          normalizedInput: cleanInput,
          normalizedExpected: cleanExpected,
          feedback: 'صحيح! يُفضل استخدام حروف الإمالة الأصلية (ä, ö, ü, ß) بدلاً من (ae, oe, ue, ss).',
        );
      }
    }

    final distance = damerauLevenshtein(cleanInput, cleanExpected);

    if (distance == 1) {
      return TypoMatchResult(
        status: TypoMatchStatus.minorTypo,
        distance: distance,
        normalizedInput: cleanInput,
        normalizedExpected: cleanExpected,
        feedback: 'إجابة صحيحة تقريباً! لديك خطأ طباعي طفيف في حرف واحد.',
      );
    }

    if (distance <= maxAllowedDistance && cleanExpected.length >= 5) {
      return TypoMatchResult(
        status: TypoMatchStatus.acceptableTypo,
        distance: distance,
        normalizedInput: cleanInput,
        normalizedExpected: cleanExpected,
        feedback: 'إجابة مقبولة مع خطأ إملائي بسيط. الإملاء الدقيق هو: "$expectedTarget".',
      );
    }

    return TypoMatchResult(
      status: TypoMatchStatus.noMatch,
      distance: distance,
      normalizedInput: cleanInput,
      normalizedExpected: cleanExpected,
      feedback: 'إجابة غير صحيحة. الإجابة الصحيحة هي: "$expectedTarget".',
    );
  }

  static String _cleanText(String text) {
    return text.trim().toLowerCase().replaceAll(_arabicDiacritics, '');
  }

  static String _expandUmlauts(String text) {
    return text
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss');
  }
}
