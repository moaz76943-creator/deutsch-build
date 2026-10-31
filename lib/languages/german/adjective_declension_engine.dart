import 'package:deutsch_bilarabi/models/linguistics/german_grammar_types.dart';

enum AdjectiveDeclensionType {
  /// Schwache Deklination: nach bestimmtem Artikel (der, die, das, dieser, jeder...)
  weak,

  /// Gemischte Deklination: nach unbestimmtem Artikel (ein, eine) oder Possessiv/kein
  mixed,

  /// Starke Deklination: ohne Artikel (Nullartikel)
  strong,
}

enum GrammaticalNumber {
  singular,
  plural,
}

class DeclinedAdjectiveResult {
  final String base;
  final String ending;
  final String declinedForm;
  final AdjectiveDeclensionType declensionType;
  final GermanCase grammaticalCase;
  final GermanGender gender;
  final GrammaticalNumber number;
  final String ruleExplanation;

  const DeclinedAdjectiveResult({
    required this.base,
    required this.ending,
    required this.declinedForm,
    required this.declensionType,
    required this.grammaticalCase,
    required this.gender,
    required this.number,
    required this.ruleExplanation,
  });
}

/// محرك تصريف الصفات الألمانية وفق القواعد المعيارية (Study 62)
/// يغطي التصريف الضعيف، المختلط، والقوي، مع مراعاة الحالات الخاصة للجذور.
class GermanAdjectiveDeclensionEngine {
  static const Set<String> _invariableAdjectives = {
    'rosa', 'lila', 'prima', 'klasse', 'super', 'orange', 'beige',
  };

  /// تصريف الصفة استناداً إلى النوع الإعرابي، الحالة، الجنس، والعدد
  static DeclinedAdjectiveResult decline({
    required String adjectiveBase,
    required AdjectiveDeclensionType declensionType,
    required GermanCase grammaticalCase,
    required GermanGender gender,
    GrammaticalNumber number = GrammaticalNumber.singular,
  }) {
    final normalized = adjectiveBase.trim().toLowerCase();

    // الصفات غير القابلة للتصريف
    if (_invariableAdjectives.contains(normalized)) {
      return DeclinedAdjectiveResult(
        base: adjectiveBase,
        ending: '',
        declinedForm: adjectiveBase,
        declensionType: declensionType,
        grammaticalCase: grammaticalCase,
        gender: gender,
        number: number,
        ruleExplanation: 'الصفة "$adjectiveBase" غير قابلة للتصريف وتبقى ثابتة.',
      );
    }

    final adjustedStem = _adjustStem(normalized);
    final ending = _determineEnding(
      declensionType: declensionType,
      grammaticalCase: grammaticalCase,
      gender: gender,
      number: number,
    );

    // إذا كان الجذر ينتهي بـ e والنهاية تبدأ بـ e، نمنع التكرار (مثل leise + e -> leise)
    final String finalForm;
    if (adjustedStem.endsWith('e') && ending.startsWith('e')) {
      finalForm = adjustedStem + ending.substring(1);
    } else {
      finalForm = adjustedStem + ending;
    }

    final explanation = _buildExplanation(
      declensionType: declensionType,
      grammaticalCase: grammaticalCase,
      gender: gender,
      number: number,
      ending: ending,
    );

    return DeclinedAdjectiveResult(
      base: adjectiveBase,
      ending: ending,
      declinedForm: finalForm,
      declensionType: declensionType,
      grammaticalCase: grammaticalCase,
      gender: gender,
      number: number,
      ruleExplanation: explanation,
    );
  }

  /// معالجة استثناءات جذور الصفات:
  /// - الصفات المنتهية بـ el تسقط الـ e: dunkel -> dunkl-
  /// - الصفات المنتهية بـ er بعد حرف علة تسقط الـ e: teuer -> teur-
  /// - hoch تتحول إلى hoh- عند التصريف
  static String _adjustStem(String stem) {
    if (stem == 'hoch') return 'hoh';
    if (stem.endsWith('el') && stem.length > 2) {
      return '${stem.substring(0, stem.length - 2)}l';
    }
    if (stem.endsWith('er') && stem.length > 3) {
      final preceding = stem[stem.length - 3];
      if ('aeiouäöü'.contains(preceding)) {
        return '${stem.substring(0, stem.length - 2)}r';
      }
    }
    return stem;
  }

  static String _determineEnding({
    required AdjectiveDeclensionType declensionType,
    required GermanCase grammaticalCase,
    required GermanGender gender,
    required GrammaticalNumber number,
  }) {
    if (number == GrammaticalNumber.plural) {
      return switch (declensionType) {
        AdjectiveDeclensionType.weak => 'en',
        AdjectiveDeclensionType.mixed => 'en',
        AdjectiveDeclensionType.strong => switch (grammaticalCase) {
          GermanCase.nominative => 'e',
          GermanCase.accusative => 'e',
          GermanCase.dative => 'en',
          GermanCase.genitive => 'er',
        },
      };
    }

    // Singular
    return switch (declensionType) {
      AdjectiveDeclensionType.weak => _weakSingularEnding(grammaticalCase, gender),
      AdjectiveDeclensionType.mixed => _mixedSingularEnding(grammaticalCase, gender),
      AdjectiveDeclensionType.strong => _strongSingularEnding(grammaticalCase, gender),
    };
  }

  static String _weakSingularEnding(GermanCase c, GermanGender g) {
    // القاعدة الذهبية للتصريف الضعيف: 5 نهايات فقط تأخذ -e، والباقي كله -en
    // النصب والرفع للمؤنث والمحايد، ورفع المذكر تأخذ -e
    if (c == GermanCase.nominative) return 'e';
    if (c == GermanCase.accusative && (g == GermanGender.feminine || g == GermanGender.neuter)) {
      return 'e';
    }
    return 'en';
  }

  static String _mixedSingularEnding(GermanCase c, GermanGender g) {
    // التصريف المختلط يأخذ نهايات قوية في الرفع (المذكر er، المحايد es) ونصب المحايد (es)، والباقي كالتصريف الضعيف
    return switch (c) {
      GermanCase.nominative => switch (g) {
        GermanGender.masculine => 'er',
        GermanGender.feminine => 'e',
        GermanGender.neuter => 'es',
        _ => 'e',
      },
      GermanCase.accusative => switch (g) {
        GermanGender.masculine => 'en',
        GermanGender.feminine => 'e',
        GermanGender.neuter => 'es',
        _ => 'e',
      },
      GermanCase.dative => 'en',
      GermanCase.genitive => 'en',
    };
  }

  static String _strongSingularEnding(GermanCase c, GermanGender g) {
    // التصريف القوي يعكس نهايات أداة التعريف (der -> er, die -> e, das -> es, dem -> em, den -> en, des -> en في المذكر والمحايد)
    return switch (c) {
      GermanCase.nominative => switch (g) {
        GermanGender.masculine => 'er',
        GermanGender.feminine => 'e',
        GermanGender.neuter => 'es',
        _ => 'e',
      },
      GermanCase.accusative => switch (g) {
        GermanGender.masculine => 'en',
        GermanGender.feminine => 'e',
        GermanGender.neuter => 'es',
        _ => 'e',
      },
      GermanCase.dative => switch (g) {
        GermanGender.masculine => 'em',
        GermanGender.feminine => 'er',
        GermanGender.neuter => 'em',
        _ => 'em',
      },
      GermanCase.genitive => switch (g) {
        GermanGender.masculine => 'en',
        GermanGender.feminine => 'er',
        GermanGender.neuter => 'en',
        _ => 'en',
      },
    };
  }

  static String _buildExplanation({
    required AdjectiveDeclensionType declensionType,
    required GermanCase grammaticalCase,
    required GermanGender gender,
    required GrammaticalNumber number,
    required String ending,
  }) {
    final typeName = switch (declensionType) {
      AdjectiveDeclensionType.weak => 'تصريف ضعيف (مع أداة معرفة)',
      AdjectiveDeclensionType.mixed => 'تصريف مختلط (مع أداة نكرة/ملكية)',
      AdjectiveDeclensionType.strong => 'تصريف قوي (بدون أداة)',
    };
    final caseName = switch (grammaticalCase) {
      GermanCase.nominative => 'الرفع (Nominativ)',
      GermanCase.accusative => 'النصب (Akkusativ)',
      GermanCase.dative => 'الجر (Dativ)',
      GermanCase.genitive => 'الإضافة (Genitiv)',
    };
    final genderName = switch (gender) {
      GermanGender.masculine => 'المذكر',
      GermanGender.feminine => 'المؤنث',
      GermanGender.neuter => 'المحايد',
      _ => 'عام',
    };
    final numberName = number == GrammaticalNumber.plural ? 'الجمع' : 'المفرد';

    return '$typeName في حالة $caseName لـ$genderName ($numberName) تأخذ النهاية "-$ending".';
  }
}
