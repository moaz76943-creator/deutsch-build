/// صوت النعت في التراكيب الألمانية المتقدمة C1
enum ParticipleVoice {
  /// النعت الفاعلي الحاضر (Partizip I): يدل على الفاعلية والاستمرارية
  activePresent,

  /// النعت المفعولي الماضي (Partizip II): يدل على المبني للمجهول أو الإنجاز
  passivePast,

  /// صيغة الإلزام والضرورة (Gerundivum / zu + Partizip I): يدل على ما يجب/يمكن فعله
  gerundiveObligation,
}

/// محرك تحويل النعوت الممتدة (Erweiterte Partizipialattribute) إلى جمل موصولة (Relativsätze)
///
/// يدعم معايير المستوى المتقدم C1 في اللغة الألمانية لتحويل التراكيب الصحفية والأكاديمية المعقدة
/// إلى جمل موصولة واضحة ومتكافئة دلالياً ونحوياً.
class ParticipialAttributeEngine {
  /// تحويل النعت الفاعلي الممتد إلى جملة موصولة متكافئة بدقة معايير C1
  ///
  /// - [article]: أداة التعريف (der, die, das)
  /// - [headNoun]: الاسم المنعوت (الموصوف)
  /// - [extensionPhrase]: شبه الجملة الممتدة (مثل: von den Forschern im Labor)
  /// - [participleLemma]: جذر الفعل أو صيغته التصريفية
  /// - [voice]: نوع الصوت والدلالة النحوية
  static String convertToRelativeClause({
    required String article,
    required String headNoun,
    required String extensionPhrase, // مثل: von den Forschern im Labor
    required String participleLemma,
    required ParticipleVoice voice,
  }) {
    final lowerArt = article.trim().toLowerCase();
    // تحديد ضمير الوصل المناسب لنوع الاسم وحالته
    final relPronoun = lowerArt == 'die' ? 'die' : (lowerArt == 'das' ? 'das' : 'der');

    final cleanExt = extensionPhrase.trim();
    final extPrefix = cleanExt.isNotEmpty ? '$cleanExt ' : '';

    switch (voice) {
      case ParticipleVoice.activePresent:
        // die im Labor forschenden Wissenschaftler -> die Wissenschaftler, die im Labor forschen
        final verb = participleLemma.endsWith('en') ? participleLemma : '${participleLemma}en';
        return '$article $headNoun, $relPronoun $extPrefix$verb';

      case ParticipleVoice.passivePast:
        // die von Forschern entwickelte Methode -> die Methode, die von Forschern entwickelt wurde
        return '$article $headNoun, $relPronoun $extPrefix$participleLemma wurde';

      case ParticipleVoice.gerundiveObligation:
        // die zu lösende Aufgabe -> die Aufgabe, die gelöst werden muss
        return '$article $headNoun, $relPronoun $extPrefix$participleLemma werden muss';
    }
  }
}
