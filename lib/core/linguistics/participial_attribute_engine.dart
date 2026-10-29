enum ParticipleType {
  partizip1Active,    // اسم الفاعل (Partizip I): تزامن ومبني للمعلوم (spielend -> spielt)
  partizip2Passive,   // اسم المفعول (Partizip II): أسبقية ومبني للمجهول (repariert -> wurde repariert)
  gerundivumObligatory, // صيغة الإمكانية والوجوب (zu + Partizip I): zu lösend -> muss/kann gelöst werden
}

class ParticipialTransformationResult {
  final String participialAttribute;
  final String equivalentRelativeClause;
  final ParticipleType type;
  final String arabicExplanation;

  const ParticipialTransformationResult({
    required this.participialAttribute,
    required this.equivalentRelativeClause,
    required this.type,
    required this.arabicExplanation,
  });
}

/// Offline engine modeling German participial attributes and resolving extended academic noun-phrase structures.
class ParticipialAttributeEngine {
  /// صياغة اسم الفاعل (Partizip I): Infinitiv + 'd' + لاحقة الإعراب
  String formPartizip1(String infinitiv, {String adjectiveEnding = 'e'}) {
    final clean = infinitiv.trim().toLowerCase();
    return '${clean}d$adjectiveEnding';
  }

  /// صياغة صيغة الإلزام والإمكانية (Gerundivum): zu + Infinitiv + 'd' + لاحقة الإعراب
  String formGerundivum(String infinitiv, {String adjectiveEnding = 'e'}) {
    final p1 = formPartizip1(infinitiv, adjectiveEnding: adjectiveEnding);
    return 'zu $p1';
  }

  /// التحويل التبادلي بين النعت الفعلي وجملة الوصل المكافئة
  ParticipialTransformationResult resolveAttribute({
    required String baseVerb,
    required String noun,
    required ParticipleType type,
    String? modifier, // مثال: 'im Garten', 'gestern'
  }) {
    final mod = modifier != null && modifier.isNotEmpty ? '$modifier ' : '';

    switch (type) {
      case ParticipleType.partizip1Active:
        final p1 = formPartizip1(baseVerb, adjectiveEnding: 'e');
        return ParticipialTransformationResult(
          participialAttribute: 'der $mod$p1 $noun',
          equivalentRelativeClause: 'der $noun, der $mod$baseVerb' 't',
          type: type,
          arabicExplanation: 'اسم الفاعل يفيد الاستمرارية والتزامن في الحاضر (المعلوم).',
        );

      case ParticipleType.partizip2Passive:
        return ParticipialTransformationResult(
          participialAttribute: 'das ${mod}beschlossene $noun',
          equivalentRelativeClause: 'das $noun, das ${mod}beschlossen wurde',
          type: type,
          arabicExplanation: 'اسم المفعول يفيد اكتمال الحدث في صيغة المبني للمجهول.',
        );

      case ParticipleType.gerundivumObligatory:
        final gerund = formGerundivum(baseVerb, adjectiveEnding: 'e');
        return ParticipialTransformationResult(
          participialAttribute: 'das $gerund $noun',
          equivalentRelativeClause: 'das $noun, das ${baseVerb}t werden muss / kann',
          type: type,
          arabicExplanation: 'صيغة Gerundivum (zu + Partizip I) تعادل جملة مبني للمجهول تفيد الوجوب أو الإمكانية.',
        );
    }
  }
}
