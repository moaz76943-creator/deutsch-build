/// Phonetic contrast pair between Arabic and German phoneme inventories.
class ContrastivePhonemePair {
  final String germanPhonemeIpa;
  final String arabicApproximation;
  final String articulatoryGuidanceAr;
  final bool requiresSpecialTraining;

  const ContrastivePhonemePair({
    required this.germanPhonemeIpa,
    required this.arabicApproximation,
    required this.articulatoryGuidanceAr,
    required this.requiresSpecialTraining,
  });
}

/// Comprehensive deep localization profile for native Arabic speakers learning German.
class ArabicDeepLocalizationProfile {
  static const String localeCode = 'ar';
  static const String languageName = 'العربية (Arabic)';
  static const bool isRtl = true;
  static const String preferredFont = 'NotoNaskhArabic';

  static const List<ContrastivePhonemePair> contrastivePhonemes = [
    ContrastivePhonemePair(
      germanPhonemeIpa: '/p/',
      arabicApproximation: 'ب (شديدة الانفجار دون همس في الأصل)',
      articulatoryGuidanceAr: 'حبس الهواء خلف الشفتين ثم إطلاقه بدفعة هوائية قوية ومهموسة لتمييزها عن حرف الباء العربي المجهور /b/.',
      requiresSpecialTraining: true,
    ),
    ContrastivePhonemePair(
      germanPhonemeIpa: '/v/',
      arabicApproximation: 'ف (لكنها مجهورة باهتزاز الحبال الصوتية)',
      articulatoryGuidanceAr: 'وضع الأسنان العليا على الشفة السفلى مع تشغيل الأوتار الصوتية لتوليد صوت /v/ خلافاً للفاء العربية المهموسة /f/.',
      requiresSpecialTraining: true,
    ),
    ContrastivePhonemePair(
      germanPhonemeIpa: '/yː/ (ü)',
      arabicApproximation: 'بين الياء المضمومة والواو المكسورة',
      articulatoryGuidanceAr: 'نطق صوت الياء الممدودة /iː/ مع تدوير الشفتين بقوة للأمام كصوت الواو دون تحريك اللسان.',
      requiresSpecialTraining: true,
    ),
    ContrastivePhonemePair(
      germanPhonemeIpa: '/ç/ (ich-Laut)',
      arabicApproximation: 'شين رقيقة أو خاء ملساء جداً',
      articulatoryGuidanceAr: 'رفع وسط اللسان نحو الحنك الصلب وإمرار الهواء بنعومة، خلافاً للخاء العربية المفخخة /x/.',
      requiresSpecialTraining: true,
    ),
  ];

  /// Strips Arabic diacritics (Harakat) for resilient lexical root matching.
  static String normalizeArabicText(String input) {
    final diacriticsRegex = RegExp(r'[\u064B-\u065F\u0670]');
    return input.replaceAll(diacriticsRegex, '').replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
  }
}
