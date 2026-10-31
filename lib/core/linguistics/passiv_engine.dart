enum PassivType {
  vorgangspassiv,    // المبني للمجهول الحدثي: werden + Partizip II
  zustandspassiv,     // المبني للمجهول الوصفي (النتيجة): sein + Partizip II
  rezipientenpassiv,  // مبني للمجهول للمتلقي: bekommen / erhalten + Partizip II
}

enum PassiversatzCategory {
  seinZuInfinitiv,    // sein + zu + Infinitiv (يعادل: muss / kann gemacht werden)
  sichLassen,         // sich lassen + Infinitiv (يعادل: kann gemacht werden)
  adjectiveBarLich,   // صفات الإمكانية المنتهية بـ -bar / -lich (machbar / lesbar)
}

class PassiversatzMapping {
  final String passiveOriginal;
  final PassiversatzCategory category;
  final String equivalentConstruction;
  final String modalEquivalent;
  final String arabicGloss;

  const PassiversatzMapping({
    required this.passiveOriginal,
    required this.category,
    required this.equivalentConstruction,
    required this.modalEquivalent,
    required this.arabicGloss,
  });
}

/// Offline linguistic engine transforming active to passive and resolving Passiversatz forms.
class PassivAndPassiversatzEngine {
  /// صياغة المبني للمجهول الحدثي بالحاضر
  String buildVorgangspassivPresent({
    required String subject,
    required String partizipIi,
    bool isPlural = false,
    String? agentVonDativ, // الفاعل الأصلي: von + Dativ
  }) {
    final werdenForm = isPlural ? 'werden' : 'wird';
    if (agentVonDativ != null && agentVonDativ.isNotEmpty) {
      return '$subject $werdenForm von $agentVonDativ $partizipIi';
    }
    return '$subject $werdenForm $partizipIi';
  }

  /// صياغة المبني للمجهول الوصفي (النتيجة القائمة)
  String buildZustandspassivPresent({
    required String subject,
    required String partizipIi,
    bool isPlural = false,
  }) {
    final seinForm = isPlural ? 'sind' : 'ist';
    return '$subject $seinForm $partizipIi';
  }

  /// مطابقة وتحويل بدائل المبني للمجهول (Passiversatz) لمستويات B2-C1
  PassiversatzMapping resolvePassiversatz(String actionRoot, String nounSubject) {
    return PassiversatzMapping(
      passiveOriginal: '$nounSubject kann gelöst werden',
      category: PassiversatzCategory.sichLassen,
      equivalentConstruction: '$nounSubject lässt sich $actionRoot',
      modalEquivalent: '$nounSubject kann / muss $actionRoot werden',
      arabicGloss: 'يمكن حل / إنجاز $nounSubject',
    );
  }

  /// تحديد حرف الجر الدال على الفاعل: von للأشخاص والمؤسسات، durch للوسائل والأسباب
  String selectAgentPreposition({required bool isPersonOrInstitution}) {
    return isPersonOrInstitution ? 'von' : 'durch';
  }
}
