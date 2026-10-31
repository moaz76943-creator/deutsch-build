import '../../features/pronunciation/domain/pronunciation_models.dart';

abstract final class GermanPronunciationCatalog {
  static const List<PronunciationContrast> contrasts = <PronunciationContrast>[
    PronunciationContrast(
      id: 'vowel_length_aa',
      kind: PronunciationContrastKind.vowelLength,
      leftToken: 'Staat',
      rightToken: 'Stadt',
      titleAr: 'طول حرف العلة: /aː/ مقابل /a/',
      coachingAr:
          'في Staat مدّ صوت a بوضوح. في Stadt يكون الصوت أقصر قبل الساكن الأخير.',
    ),
    PronunciationContrast(
      id: 'rounded_y_length',
      kind: PronunciationContrastKind.roundedVowel,
      leftToken: 'fühlen',
      rightToken: 'füllen',
      titleAr: 'ü الطويل والقصير: /yː/ مقابل /ʏ/',
      coachingAr:
          'دوّر الشفتين كما في u، لكن أبقِ اللسان في وضع أمامي قريب من i. fühlen أطول من füllen.',
    ),
    PronunciationContrast(
      id: 'front_rounding_oe',
      kind: PronunciationContrastKind.vowelFronting,
      leftToken: 'schon',
      rightToken: 'schön',
      titleAr: 'o مقابل ö: /oː/ و /øː/',
      coachingAr:
          'في schön حافظ على تدوير الشفتين مع تقديم اللسان للأمام. schon يبقى أكثر خلفية.',
    ),
    PronunciationContrast(
      id: 'ich_ach_fricative',
      kind: PronunciationContrastKind.ichAch,
      leftToken: 'nicht',
      rightToken: 'Buch',
      titleAr: 'ich-Laut /ç/ مقابل ach-Laut /x/',
      coachingAr:
          'في nicht يخرج الاحتكاك من موضع أمامي أعلى اللسان. في Buch ينتقل الاحتكاك إلى الخلف بعد صوت u.',
    ),
  ];
}
