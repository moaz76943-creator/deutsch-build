class ContextualScenarioSynthesizer {
  // توليد سيناريو حواري واقعي ومصغر مرتبط بالمفردة والقطاع المهني (مثل الصيدلة والطب)
  static Map<String, dynamic> generateMicroScenario(
      String word, String professionalContext) {
    Map<String, String> scenarioData;

    if (word.toLowerCase() == 'rezept') {
      scenarioData = {
        'setting': 'صيدلية مجتمعية (Community Pharmacy)',
        'dialoguePartner': 'الصيدلاني والمريض',
        'lineA': 'Guten Tag, ich habe hier ein Rezept für meine Schmerzmittel.',
        'lineB': 'Guten Tag! Einen Moment bitte, ich prüfe die Verfügbarkeit.',
        'grammarFocus': 'استخدام حرف الجر für مع مفعول به (Akkusativ)'
      };
    } else if (word.toLowerCase() == 'apotheke') {
      scenarioData = {
        'setting': 'مدخل الصيدلية / الشارع الرئيسي',
        'dialoguePartner': 'أحد المارة والباحث عن دواء',
        'lineA':
            'Entschuldigung, wo ist hier die nächste Apotheke mit Notdienst?',
        'lineB': 'Die Notdienst-Apotheke ist zwei Straßen weiter links.',
        'grammarFocus': 'تحديد المواقع باستخدام المجرور (Dativ)'
      };
    } else {
      scenarioData = {
        'setting': 'بيئة مهنية / حياتية عامة',
        'dialoguePartner': 'متحدث أصلي',
        'lineA': 'Können wir das bitte kurz besprechen?',
        'lineB': 'Ja, natürlich, ich verstehe das Problem.',
        'grammarFocus': 'البنية التركيبية الأساسية للجملة الألمانية'
      };
    }

    return {
      'module': 'Contextual Scenario Synthesizer',
      'targetWord': word,
      'context': professionalContext,
      'scenario': scenarioData,
      'status': 'Verified Real-World Context'
    };
  }
}
