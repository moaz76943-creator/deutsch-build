enum InfinitiveTriggerCategory {
  verbTrigger,       // versuchen, hoffen, vorhaben, vergessen
  nounTrigger,       // Lust haben, Zeit haben, die Absicht haben
  impersonalAdj,     // es ist wichtig, es ist verboten, es ist schön
  prepositionalUmZu, // um ... zu (الغاية مع تطابق الفاعل)
  prepositionalOhne, // ohne ... zu (دون أن يفعل)
  prepositionalStatt,// anstatt ... zu (بدلاً من أن يفعل)
}

class InfinitiveValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String correctForm;

  const InfinitiveValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.correctForm,
  });
}

/// Offline syntax engine governing German infinitive constructions with and without 'zu'.
class InfinitivMitZuEngine {
  // الأفعال التي يحظر قطعياً استخدام 'zu' معها
  static const Set<String> _verbsBanningZu = {
    'können', 'müssen', 'dürfen', 'sollen', 'wollen', 'mögen', 'möchten',
    'sehen', 'hören', 'spüren', 'fühlen',
    'gehen', 'fahren', 'bleiben', 'lassen'
  };

  /// هل الفعل يحظر استخدام 'zu'؟ (أفعال المودال، الحواس، والحركة)
  bool bansZu(String mainVerb) => _verbsBanningZu.contains(mainVerb.toLowerCase().trim());

  /// تدقيق استخدام 'zu' مع الفعل المستهدف
  InfinitiveValidationResult auditUsage({
    required String mainVerb,
    required String dependentVerb,
    required bool learnerUsedZu,
    bool isSeparableDependent = false,
    String? separablePrefix,
  }) {
    final vMain = mainVerb.toLowerCase().trim();
    final vDep = dependentVerb.toLowerCase().trim();

    // 1. فحص الحظر القطعي مع أفعال الكيفية والحواس
    if (bansZu(vMain)) {
      if (learnerUsedZu) {
        return InfinitiveValidationResult(
          isValid: false,
          errorMessage: 'خطأ نحوي: أفعال الكيفية والمودال والحواس والحركة ($mainVerb) تأتي مع المصدر المجرد حصراً دون "zu".',
          correctForm: '$vMain $vDep',
        );
      }
      return InfinitiveValidationResult(isValid: true, correctForm: '$vMain $vDep');
    }

    // 2. التحقق من صياغة zu مع الأفعال المنفصلة (تدرج في الوسط: auf-zu-stehen)
    if (isSeparableDependent && separablePrefix != null) {
      final expectedSeparable = '${separablePrefix}zu$vDep';
      return InfinitiveValidationResult(
        isValid: learnerUsedZu,
        correctForm: expectedSeparable,
        errorMessage: learnerUsedZu ? null : 'خطأ: الأفعال القابلة للانفصال تدرج "zu" في وسطها ($expectedSeparable).',
      );
    }

    // 3. الأفعال القياسية: zu منفصلة قبل الفعل (zu lernen)
    final expectedStandard = 'zu $vDep';
    return InfinitiveValidationResult(
      isValid: learnerUsedZu,
      correctForm: expectedStandard,
      errorMessage: learnerUsedZu ? null : 'خطأ: هذا التركيب يتطلب أداة المصدر "zu" قبل الفعل ($expectedStandard).',
    );
  }

  /// التحقق من شرط استخدام (um ... zu): تطابق فاعل الجملة الرئيسية مع فاعل الغاية
  bool isValidUmZuSubject({required bool subjectsAreIdentical}) {
    // إذا اختلف الفاعلان، يحظر استخدام (um... zu) ويجب استخدام (damit)
    return subjectsAreIdentical;
  }
}
