enum ReflexiveCase { akkusativ, dativ }

enum ReflexiveType { trueReflexive, optionalReflexive, reciprocal }

extension ReflexiveCaseLabels on ReflexiveCase {
  String get labelDe => switch (this) {
        ReflexiveCase.akkusativ => 'Akkusativ',
        ReflexiveCase.dativ => 'Dativ',
      };

  String get labelAr => switch (this) {
        ReflexiveCase.akkusativ => 'حالة النصب · Akkusativ',
        ReflexiveCase.dativ => 'حالة الجر غير المباشر · Dativ',
      };
}

extension ReflexiveTypeLabels on ReflexiveType {
  String get labelAr => switch (this) {
        ReflexiveType.trueReflexive => 'فعل انعكاسي حتمي',
        ReflexiveType.optionalReflexive => 'استعمال انعكاسي اختياري',
        ReflexiveType.reciprocal => 'استعمال تبادلي بين أكثر من شخص',
      };
}

final class ReflexiveDrillItem {
  const ReflexiveDrillItem({
    required this.id,
    required this.infinitiveWithSich,
    required this.subjectPronoun,
    required this.reflexivePronoun,
    required this.reflexiveCase,
    required this.reflexiveType,
    required this.caseReasonAr,
    required this.contextSentence,
    required this.translationAr,
    required this.explanationAr,
    this.additionalObject,
  });

  final String id;
  final String infinitiveWithSich;
  final String subjectPronoun;
  final String reflexivePronoun;
  final ReflexiveCase reflexiveCase;
  final ReflexiveType reflexiveType;
  final String? additionalObject;
  final String caseReasonAr;
  final String contextSentence;
  final String translationAr;
  final String explanationAr;

  bool get hasAdditionalObject =>
      additionalObject != null && additionalObject!.trim().isNotEmpty;
}
