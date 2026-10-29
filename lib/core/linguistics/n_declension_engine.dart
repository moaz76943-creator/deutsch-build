enum GrammaticalCase { nominative, accusative, dative, genitive }

enum NDeclensionSubtype {
  standardN,      // تكتسب -n (مثل: Junge -> Jungen)
  standardEn,     // تكتسب -en (مثل: Student -> Studenten, Mensch -> Menschen)
  specialNs,      // تكتسب -ns في الإضافة (مثل: Name -> des Namens, Gedanke -> des Gedankens)
  irregularHerz,  // das Herz (الرفع والنصب Herz، والجر Herzen، والإضافة des Herzens)
}

class NDeclensionEntry {
  final String lemma;
  final NDeclensionSubtype subtype;
  final String article;

  const NDeclensionEntry(this.lemma, this.subtype, {this.article = 'der'});
}

/// Offline linguistic engine identifying and inflecting German weak masculine nouns (N-Deklination).
class NDeklinationEngine {
  static const Map<String, NDeclensionEntry> _registry = {
    // 1. منتهية بـ -e للأشخاص والحيوانات
    'junge': NDeclensionEntry('Junge', NDeclensionSubtype.standardN),
    'kollege': NDeclensionEntry('Kollege', NDeclensionSubtype.standardN),
    'kunde': NDeclensionEntry('Kunde', NDeclensionSubtype.standardN),
    'löwe': NDeclensionEntry('Löwe', NDeclensionSubtype.standardN),
    'experte': NDeclensionEntry('Experte', NDeclensionSubtype.standardN),

    // 2. نهايات أجنبية ولاتينية (-ent, -ist, -ant, -at)
    'student': NDeclensionEntry('Student', NDeclensionSubtype.standardEn),
    'polizist': NDeclensionEntry('Polizist', NDeclensionSubtype.standardEn),
    'praktikant': NDeclensionEntry('Praktikant', NDeclensionSubtype.standardEn),
    'diplomat': NDeclensionEntry('Diplomat', NDeclensionSubtype.standardEn),
    'tourist': NDeclensionEntry('Tourist', NDeclensionSubtype.standardEn),
    'mensch': NDeclensionEntry('Mensch', NDeclensionSubtype.standardEn),

    // 3. استثناءات الإضافة الخاصة (-ns)
    'name': NDeclensionEntry('Name', NDeclensionSubtype.specialNs),
    'gedanke': NDeclensionEntry('Gedanke', NDeclensionSubtype.specialNs),
    'glaube': NDeclensionEntry('Glaube', NDeclensionSubtype.specialNs),

    // 4. استثناء محايد فريد: das Herz
    'herz': NDeclensionEntry('Herz', NDeclensionSubtype.irregularHerz, article: 'das'),
  };

  bool isNDeclension(String noun) => _registry.containsKey(noun.toLowerCase().trim());

  /// تصريف الاسم في المفرد بناءً على حالته الإعرابية
  String inflectSingular(String noun, GrammaticalCase grammaticalCase) {
    final key = noun.toLowerCase().trim();
    final entry = _registry[key];
    if (entry == null) return noun;

    // استثناء خاص بـ das Herz
    if (entry.subtype == NDeclensionSubtype.irregularHerz) {
      if (grammaticalCase == GrammaticalCase.nominative || grammaticalCase == GrammaticalCase.accusative) {
        return 'Herz';
      }
      if (grammaticalCase == GrammaticalCase.dative) return 'Herzen';
      if (grammaticalCase == GrammaticalCase.genitive) return 'Herzens';
    }

    // الرفع المفرد لا يطرأ عليه تغيير
    if (grammaticalCase == GrammaticalCase.nominative) return entry.lemma;

    // حالة الإضافة (Genitiv) لمجموعة (-ns)
    if (grammaticalCase == GrammaticalCase.genitive && entry.subtype == NDeclensionSubtype.specialNs) {
      return '${entry.lemma}ns';
    }

    // بقية الحالات (Akkusativ, Dativ, Genitiv العام)
    return entry.subtype == NDeclensionSubtype.standardN
        ? '${entry.lemma}n'
        : '${entry.lemma}en';
  }

  /// كشف الأخطاء الشائعة للمتعلمين (مثل نسيان لاحقة النون في النصب أو الجر)
  String? validateLearnerUsage(String noun, GrammaticalCase grammaticalCase, String usedForm) {
    if (!isNDeclension(noun)) return null;
    final expected = inflectSingular(noun, grammaticalCase);
    if (expected.toLowerCase() != usedForm.toLowerCase()) {
      return 'خطأ إعرابي في N-Deklination: الاسم "$noun" في حالة ${grammaticalCase.name} يجب أن يأخذ اللاحقة ليصبح "$expected".';
    }
    return null;
  }
}
