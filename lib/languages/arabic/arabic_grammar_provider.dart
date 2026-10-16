import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';

/// Arabic Grammar Rule Provider conforming to LanguageGrammarRuleProvider interface.
/// Implements Arabic-specific root-pattern morphology, tripartite case system (رفع، نصب، جر),
/// and tripartite grammatical number (مفرد، مثنى، جمع).
class ArabicGrammarProvider implements LanguageGrammarRuleProvider {
  static final ArabicGrammarProvider instance = ArabicGrammarProvider._internal();
  ArabicGrammarProvider._internal();

  @override
  String get languageCode => 'ar';

  @override
  GrammarCapabilityProfile get profile => const GrammarCapabilityProfile(
    supportedGenders: {
      GrammaticalGender.masculine,
      GrammaticalGender.feminine,
    },
    supportedCases: {
      GrammaticalCase.nominative, // المرفوع
      GrammaticalCase.accusative, // المنصوب
      GrammaticalCase.genitive,   // المجرور
    },
    supportedNumbers: {
      GrammaticalNumber.singular, // المفرد
      GrammaticalNumber.dual,     // المثنى
      GrammaticalNumber.plural,   // الجمع
    },
    morphologyType: MorphologyType.rootPattern, // أوزان الاشتقاق الجذرية
    supportsAgreement: true,                   // مطابقة النعت للمنعوت
  );

  @override
  VerifiedGrammarEvidence getVerifiedEvidence(String word) =>
      const VerifiedGrammarEvidence(
        isSupported: true,
        packRevision: '1.0.0',
      );

  @override
  GrammaticalGender determineGender(String word, {String? article}) {
    final trimmed = word.trim();
    if (trimmed.isEmpty) return GrammaticalGender.none;

    // علامات التأنيث اللفظية في العربية: التاء المربوطة، الألف المقصورة، الألف الممدودة
    if (trimmed.endsWith('ة') || trimmed.endsWith('ـة')) {
      return GrammaticalGender.feminine;
    }
    if (trimmed.endsWith('ى') && !trimmed.startsWith('ي')) {
      return GrammaticalGender.feminine;
    }
    if (trimmed.endsWith('اء') && trimmed.length > 3) {
      return GrammaticalGender.feminine;
    }

    // المؤنثات السماعية والبيولوجية الشائعة
    const feminineNouns = {
      'أم', 'أخت', 'بنت', 'شمس', 'أرض', 'عين', 'يد', 'رجل', 'نار', 'دار', 'نفس'
    };
    final stripped = trimmed.startsWith('ال') ? trimmed.substring(2) : trimmed;
    if (feminineNouns.contains(stripped)) {
      return GrammaticalGender.feminine;
    }

    return GrammaticalGender.masculine;
  }

  @override
  GrammaticalCategory determineCategory(String word, {String? article}) {
    final trimmed = word.trim();
    if (trimmed.isEmpty) return GrammaticalCategory.unknown;

    // أدوات وحروف المعاني
    const particles = {
      'في', 'من', 'إلى', 'على', 'عن', 'مع', 'حتى', 'ثم', 'أو', 'لا', 'لم', 'لن',
      'إن', 'أن', 'لكن', 'هل', 'ما', 'قد', 'سوف', 'لو', 'إذا', 'بل', 'غير', 'سوى'
    };
    if (particles.contains(trimmed)) {
      return GrammaticalCategory.particle;
    }

    // علامات الاسم: التعريف بـ "الـ"، التاء المربوطة، التنوين
    if (trimmed.startsWith('ال') || trimmed.endsWith('ة') || trimmed.endsWith('ـة')) {
      return GrammaticalCategory.noun;
    }
    if (article != null && (article == 'ال' || article == 'الـ')) {
      return GrammaticalCategory.noun;
    }

    // التنوين
    if (trimmed.endsWith('ً') || trimmed.endsWith('ٌ') || trimmed.endsWith('ٍ')) {
      return GrammaticalCategory.noun;
    }

    // علامات الفعل المضارع أو الماضي
    if (trimmed.length >= 3) {
      if (trimmed.endsWith('تَ') || trimmed.endsWith('تُ') || trimmed.endsWith('تِ') ||
          trimmed.endsWith('وا') || trimmed.endsWith('تما') || trimmed.endsWith('تم')) {
        return GrammaticalCategory.verb;
      }
    }

    return GrammaticalCategory.noun;
  }

  @override
  bool isValidArticle(String word, String article) {
    final cleanArticle = article.trim();
    // أداة التعريف الوحيدة في اللغة العربية هي "الـ"
    return cleanArticle == 'ال' || cleanArticle == 'الـ' || cleanArticle.isEmpty;
  }
}
