enum PartizipKind { partizipI, partizipII }

enum PartizipAttributeScope { simple, extended }

extension PartizipKindLabels on PartizipKind {
  String get labelDe => switch (this) {
        PartizipKind.partizipI => 'Partizip I',
        PartizipKind.partizipII => 'Partizip II',
      };

  String get labelAr => switch (this) {
        PartizipKind.partizipI => 'اسم الفاعل الوصفي · حدث جارٍ أو فاعل نشط',
        PartizipKind.partizipII => 'وصف ناتج · حدث مكتمل أو معنى مبني للمجهول',
      };
}

extension PartizipAttributeScopeLabels on PartizipAttributeScope {
  String get labelAr => switch (this) {
        PartizipAttributeScope.simple => 'صفة مشتقة قصيرة',
        PartizipAttributeScope.extended => 'وصف موسّع قبل الاسم',
      };
}

final class PartizipExercise {
  const PartizipExercise({
    required this.id,
    required this.infinitive,
    required this.participle,
    required this.kind,
    required this.scope,
    required this.noun,
    required this.correctAttribute,
    required this.sourceSentenceDe,
    required this.translationAr,
    required this.explanationAr,
    required this.attributeTokens,
  });

  final String id;
  final String infinitive;
  final String participle;
  final PartizipKind kind;
  final PartizipAttributeScope scope;
  final String noun;
  final String correctAttribute;
  final String sourceSentenceDe;
  final String translationAr;
  final String explanationAr;
  final List<String> attributeTokens;
}
