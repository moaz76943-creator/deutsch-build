/// Biomechanical advice detailing physical organ movement for accurate pronunciation.
class ArticulationGuidance {
  final String phoneme;
  final String lipPosition;     // e.g. "مستديرة ومتقدمة للأمام"
  final String tonguePosition;  // e.g. "مرتفعة نحو الحنك الصلب"
  final String airflowType;     // e.g. "خروج الهواء رنيني من الأنف"
  final String practiceTip;

  const ArticulationGuidance({
    required this.phoneme,
    required this.lipPosition,
    required this.tonguePosition,
    required this.airflowType,
    required this.practiceTip,
  });
}

/// Provides physical organ movement tips for phonemes that fail GoP evaluation.
class VocalArticulationCoach {
  const VocalArticulationCoach();

  static const Map<String, ArticulationGuidance> _guidanceBank = {
    'øː': ArticulationGuidance(
      phoneme: 'ö (طويل)',
      lipPosition: 'استدر الشفتين بقوة للأمام كأنك تنطق (O)',
      tonguePosition: 'ثبت لسانك في موضع نطق حرف (E) دون تحريكه للخلف',
      airflowType: 'هواء مصوت مستمر من الحلق',
      practiceTip: 'انطق صوت (ee) ثم قم بتدوير شفتيك فقط للأمام دون تغيير مكان لسانك.',
    ),
    'yː': ArticulationGuidance(
      phoneme: 'ü (طويل)',
      lipPosition: 'شفتان مضمومتان ومستديرتان بإحكام مع فتحة ضيقة جداً',
      tonguePosition: 'طرف اللسان يلامس الأسنان السفلية ووسطه مرتفع',
      airflowType: 'هواء مصوت بضغط خفيف',
      practiceTip: 'انطق (i) كالمعتاد ثم زم شفتيك كما لو كنت ستصفر لتتحول إلى (ü).',
    ),
    'ç': ArticulationGuidance(
      phoneme: 'ch (Ich-Laut)',
      lipPosition: 'شفتان منفرجتان قليلاً في وضع شبه ابتسامة',
      tonguePosition: 'وسط اللسان يرتفع مقترباً من الحنك الصلب دون أن يلمسه',
      airflowType: 'احتكاك هوائي سلس وهامس (يشبه حفيف أوراق الشجر)',
      practiceTip: 'انطق (يا) بصوت هامس جداً دون تحريك الحبال الصوتية.',
    ),
    'χ': ArticulationGuidance(
      phoneme: 'ch (Ach-Laut)',
      lipPosition: 'مسترخية ومحايدة',
      tonguePosition: 'مؤخرة اللسان تقترب من الحنك الرخو بالقرب من اللهاة',
      airflowType: 'احتكاك خشن يشبه نطق حرف (الخاء) الخفيف',
      practiceTip: 'يظهر دائماً بعد الحركات الخلفية (a, o, u).',
    ),
  };

  /// Returns physical movement coaching guidance for a specific mispronounced phoneme.
  ArticulationGuidance? getGuidance(String phonemeIpa) {
    return _guidanceBank[phonemeIpa];
  }
}
