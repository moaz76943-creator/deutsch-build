import 'package:deutsch_bilarabi/models/linguistics/german_grammar_types.dart';

enum GenderRuleSource {
  documentedException,
  nominalizedInfinitive,
  suffixRule,
  semanticCategory,
  compoundHead,
  highFrequencyLexicon,
  unknown,
}

class GermanGenderResult {
  final String word;
  final GermanGender gender;
  final String definiteArticle;
  final GenderRuleSource ruleSource;
  final bool isDocumentedException;
  final String explanation;

  const GermanGenderResult({
    required this.word,
    required this.gender,
    required this.definiteArticle,
    required this.ruleSource,
    this.isDocumentedException = false,
    required this.explanation,
  });
}

/// محرك استنتاج وضبط جنس الأسماء الألمانية (der/die/das) - Topic 7
/// يطبق القواعد الصرفية والدلالية بدقة مع مراعاة كافة الاستثناءات الموثقة
class GermanGenderEngine {
  /// استثناءات معجمية موثقة ومعتمدة لغوياً لا تخضع للقواعد العامة
  static const Map<String, GermanGender> _documentedExceptions = {
    // أسماء تنتهي بـ -er لكنها محايدة وليست مذكرة
    'fenster': GermanGender.neuter,
    'zimmer': GermanGender.neuter,
    'wasser': GermanGender.neuter,
    'messer': GermanGender.neuter,
    'wetter': GermanGender.neuter,
    'feuer': GermanGender.neuter,
    'opfer': GermanGender.neuter,
    'theater': GermanGender.neuter,
    'muster': GermanGender.neuter,
    'kloster': GermanGender.neuter,

    // أسماء تنتهي بـ -er لكنها مؤنثة وليست مذكرة
    'mutter': GermanGender.feminine,
    'tochter': GermanGender.feminine,
    'schwester': GermanGender.feminine,
    'schulter': GermanGender.feminine,
    'feder': GermanGender.feminine,
    'ader': GermanGender.feminine,
    'butter': GermanGender.feminine,
    'leiter': GermanGender.feminine, // der Leiter (مدير) / die Leiter (سلم)

    // استثناءات اللواحق الأخرى
    'streik': GermanGender.masculine, // ينتهي بـ -ik لكنه مذكر
    'abteil': GermanGender.neuter,    // ينتهي بـ -teil
    'vorteil': GermanGender.masculine,
    'nachteil': GermanGender.masculine,
    'urteil': GermanGender.neuter,
    'reichtum': GermanGender.masculine, // ينتهي بـ -tum لكنه مذكر
    'irrtum': GermanGender.masculine,   // ينتهي بـ -tum لكنه مذكر

    // الأسماء المذكرة الضعيفة المنتهية بـ -e
    'junge': GermanGender.masculine,
    'löwe': GermanGender.masculine,
    'name': GermanGender.masculine,
    'gedanke': GermanGender.masculine,
    'buchstabe': GermanGender.masculine,
    'kollege': GermanGender.masculine,
    'experte': GermanGender.masculine,
    'kunde': GermanGender.masculine,
    'zeuge': GermanGender.masculine,

    // الكلمات الأساسية غير القياسية
    'mädchen': GermanGender.neuter, // لاحقة تصغير -chen تجعل الكلمة محايدة
    'sonne': GermanGender.feminine,  // الشمس في الألمانية مؤنثة
    'mond': GermanGender.masculine,   // القمر مذكر
    'stern': GermanGender.masculine,
    'erde': GermanGender.feminine,
    'zeit': GermanGender.feminine,
    'buch': GermanGender.neuter,
    'haus': GermanGender.neuter,
    'kind': GermanGender.neuter,
    'stadt': GermanGender.feminine,
    'land': GermanGender.neuter,
    'mensch': GermanGender.masculine,
    'leben': GermanGender.neuter,
    'herz': GermanGender.neuter,
    'auge': GermanGender.neuter,
    'ohr': GermanGender.neuter,
    'kopf': GermanGender.masculine,
    'hand': GermanGender.feminine,
    'fuß': GermanGender.masculine,
    'bein': GermanGender.neuter,
  };

  /// اللواحق الدالة قطعياً أو غالباً على التأنيث (die)
  static const List<String> _feminineSuffixes = [
    'ung', 'heit', 'keit', 'schaft', 'tät', 'ion', 'anz', 'enz',
    'ei', 'ur', 'ik', 'ade', 'age', 'ette', 'in', 'ie',
  ];

  /// اللواحق الدالة قطعياً أو غالباً على التذكير (der)
  static const List<String> _masculineSuffixes = [
    'ismus', 'or', 'ling', 'ant', 'ent', 'ist', 'eur', 'är',
  ];

  /// اللواحق الدالة قطعياً على المحايد (das)
  static const List<String> _neuterSuffixes = [
    'chen', 'lein', 'ment', 'um', 'tum', 'ma', 'ment',
  ];

  /// استنتاج جنس الاسم مع الدليل والتعليل
  static GermanGenderResult resolveGender(String noun) {
    final trimmed = noun.trim();
    final lower = trimmed.toLowerCase();

    if (lower.isEmpty) {
      return const GermanGenderResult(
        word: '',
        gender: GermanGender.none,
        definiteArticle: '',
        ruleSource: GenderRuleSource.unknown,
        explanation: 'الكلمة فارغة.',
      );
    }

    // 1. فحص الاستثناءات الموثقة أولاً لمنع التضارب
    if (_documentedExceptions.containsKey(lower)) {
      final g = _documentedExceptions[lower]!;
      return GermanGenderResult(
        word: trimmed,
        gender: g,
        definiteArticle: _articleFor(g),
        ruleSource: GenderRuleSource.documentedException,
        isDocumentedException: true,
        explanation: 'الاسم "$trimmed" استثناء لغوي موثق يحفظ سماعاً: ${_articleFor(g)} $trimmed.',
      );
    }

    // 2. فحص المصادر المشتقة من الأفعال (Nominalisierte Verben) مثل das Essen, das Leben
    if (trimmed.length > 3 &&
        trimmed[0] == trimmed[0].toUpperCase() &&
        (lower.endsWith('en') || lower.endsWith('ern') || lower.endsWith('eln'))) {
      if (_isNominalizedInfinitive(lower)) {
        return GermanGenderResult(
          word: trimmed,
          gender: GermanGender.neuter,
          definiteArticle: 'das',
          ruleSource: GenderRuleSource.nominalizedInfinitive,
          explanation: 'المصادر المحولة لأسماء (Nominalisierte Verben) تأخذ دائماً أداة المحايد: das $trimmed.',
        );
      }
    }

    // 3. فحص لواحق التأنيث (die)
    for (final suffix in _feminineSuffixes) {
      if (lower.endsWith(suffix) && lower.length > suffix.length + 1) {
        return GermanGenderResult(
          word: trimmed,
          gender: GermanGender.feminine,
          definiteArticle: 'die',
          ruleSource: GenderRuleSource.suffixRule,
          explanation: 'الاسم ينتهي باللاحقة القياسية للمؤنث "-$suffix": die $trimmed.',
        );
      }
    }

    // 4. فحص لواحق المحايد (das) أولاً لتجنب التداخل مع -ent في -ment
    for (final suffix in _neuterSuffixes) {
      if (lower.endsWith(suffix) && lower.length > suffix.length + 1) {
        return GermanGenderResult(
          word: trimmed,
          gender: GermanGender.neuter,
          definiteArticle: 'das',
          ruleSource: GenderRuleSource.suffixRule,
          explanation: 'الاسم ينتهي باللاحقة القياسية للمحايد "-$suffix": das $trimmed.',
        );
      }
    }

    // 5. فحص لواحق التذكير (der)
    for (final suffix in _masculineSuffixes) {
      if (lower.endsWith(suffix) && lower.length > suffix.length + 1) {
        return GermanGenderResult(
          word: trimmed,
          gender: GermanGender.masculine,
          definiteArticle: 'der',
          ruleSource: GenderRuleSource.suffixRule,
          explanation: 'الاسم ينتهي باللاحقة القياسية للمذكر "-$suffix": der $trimmed.',
        );
      }
    }

    // 6. أسماء المهن والفاعلين المنتهية بـ -er المشتقة (der Lehrer, der Fahrer)
    if (lower.endsWith('er') && lower.length > 3) {
      return GermanGenderResult(
        word: trimmed,
        gender: GermanGender.masculine,
        definiteArticle: 'der',
        ruleSource: GenderRuleSource.suffixRule,
        explanation: 'اسم فاعل أو صفة تنتهي بـ "-er" تدل على مذكر: der $trimmed.',
      );
    }

    // 7. الأسماء المنتهية بـ -e غالبيتها مؤنثة (die Lampe, die Tasche, die Reise)
    if (lower.endsWith('e') && lower.length > 2) {
      return GermanGenderResult(
        word: trimmed,
        gender: GermanGender.feminine,
        definiteArticle: 'die',
        ruleSource: GenderRuleSource.suffixRule,
        explanation: 'الأسماء المنتهية بحرف "-e" مؤنثة في الغالبية العظمى (أكثر من 90%): die $trimmed.',
      );
    }

    return GermanGenderResult(
      word: trimmed,
      gender: GermanGender.none,
      definiteArticle: '',
      ruleSource: GenderRuleSource.unknown,
      explanation: 'الاسم "$trimmed" جذري غير مقيد بلاحقة صرفية؛ يجب استشارة القاموس.',
    );
  }

  static bool _isNominalizedInfinitive(String lower) {
    const commonInfinitives = {
      'essen', 'trinken', 'leben', 'lernen', 'schreiben', 'lesen',
      'schwimmen', 'fahren', 'reisen', 'schlafen', 'wissen', 'können',
    };
    return commonInfinitives.contains(lower);
  }

  static String _articleFor(GermanGender g) => switch (g) {
    GermanGender.masculine => 'der',
    GermanGender.feminine => 'die',
    GermanGender.neuter => 'das',
    _ => '',
  };
}
