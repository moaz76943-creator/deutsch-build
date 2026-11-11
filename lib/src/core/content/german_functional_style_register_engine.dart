/// Language register category.
enum LanguageRegister { colloquialEveryday, elevatedFormalAcademic }

/// Aspectual nuance (Aktionsart) of the functional verb phrase.
enum FunctionalVerbAspect {
  durative,   // andauernd (z.B. in Verhandlung stehen)
  inchoative, // beginnend (z.B. in Verhandlung treten)
  causative,  // bewirkend (z.B. in Gang setzen / bringen)
}

/// Register transformation mapping unit.
class RegisterMappingEntry {
  final String everydayVerb;
  final String elevatedCollocation;
  final FunctionalVerbAspect aspect;
  final String governingPreposition;
  final String arabicFormalMeaning;

  const RegisterMappingEntry({
    required this.everydayVerb,
    required this.elevatedCollocation,
    required this.aspect,
    this.governingPreposition = '',
    required this.arabicFormalMeaning,
  });
}

/// Analysis descriptor of a transformed sentence pair.
class RegisterTransformationResult {
  final String originalSentence;
  final LanguageRegister targetRegister;
  final String transformedSentence;
  final String matchedPattern;
  final String arabicExplanation;

  RegisterTransformationResult({
    required this.originalSentence,
    required this.targetRegister,
    required this.transformedSentence,
    required this.matchedPattern,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'original': originalSentence,
        'target_register': targetRegister.name,
        'transformed': transformedSentence,
        'matched': matchedPattern,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine converting colloquial German into formal academic/administrative German
/// using functional verb collocations (Funktionsverbgefüge / Nomen-Verb-Verbindungen).
class GermanFunctionalStyleRegisterEngine {
  static const List<RegisterMappingEntry> _registerDirectory = [
    RegisterMappingEntry(
      everydayVerb: 'helfen',
      elevatedCollocation: 'hilfe leisten',
      aspect: FunctionalVerbAspect.durative,
      arabicFormalMeaning: 'تقديم العون والمساعدة الرسمية',
    ),
    RegisterMappingEntry(
      everydayVerb: 'entscheiden',
      elevatedCollocation: 'eine entscheidung treffen',
      aspect: FunctionalVerbAspect.inchoative,
      arabicFormalMeaning: 'اتخاذ قرار حاسم ومسؤول',
    ),
    RegisterMappingEntry(
      everydayVerb: 'kritisieren',
      elevatedCollocation: 'kritik ueben',
      aspect: FunctionalVerbAspect.durative,
      arabicFormalMeaning: 'ممارسة النقد وتوجيهه',
    ),
    RegisterMappingEntry(
      everydayVerb: 'beruecksichtigen',
      elevatedCollocation: 'in betracht ziehen',
      aspect: FunctionalVerbAspect.durative,
      governingPreposition: 'in',
      arabicFormalMeaning: 'الأخذ بعين الاعتبار والتقدير',
    ),
    RegisterMappingEntry(
      everydayVerb: 'abschliessen',
      elevatedCollocation: 'zum abschluss bringen',
      aspect: FunctionalVerbAspect.causative,
      governingPreposition: 'zu',
      arabicFormalMeaning: 'إيصال الأمر إلى نهايته وإتمامه',
    ),
    RegisterMappingEntry(
      everydayVerb: 'zweifeln',
      elevatedCollocation: 'in zweifel ziehen',
      aspect: FunctionalVerbAspect.durative,
      governingPreposition: 'in',
      arabicFormalMeaning: 'التشكيك والطعن في صحة الأمر',
    ),
  ];

  /// Elevate everyday phrase to formal functional verb structure.
  static RegisterTransformationResult elevateStyle({
    required String subject,
    required String everydayVerbStem, // e.g. "entscheidet sich", "hilft", "kritisiert"
    required String baseSentence,
    String? complement,
  }) {
    final cleanStem = everydayVerbStem.trim().toLowerCase()
        .replaceAll('ü', 'ue')
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe');

    RegisterMappingEntry? matched;
    for (final entry in _registerDirectory) {
      if (cleanStem.contains(entry.everydayVerb)) {
        matched = entry;
        break;
      }
    }

    if (matched == null) {
      // Fallback: return as-is
      return RegisterTransformationResult(
        originalSentence: baseSentence,
        targetRegister: LanguageRegister.elevatedFormalAcademic,
        transformedSentence: baseSentence,
        matchedPattern: 'none',
        arabicExplanation: 'لا يوجد تحويل تركيبي مخصص لهذه العبارة',
      );
    }

    // Capitalize collocation as noun phrase
    final collocationTokens = matched.elevatedCollocation.split(' ');
    final capitalizedCollocation = collocationTokens.map((t) {
      if (t == 'eine' || t == 'in' || t == 'zum') return t;
      return t[0].toUpperCase() + t.substring(1);
    }).join(' ');

    final compStr = (complement != null && complement.trim().isNotEmpty) ? ' $complement' : '';
    final transformed = '$subject bringt $capitalizedCollocation$compStr.'.trim();

    return RegisterTransformationResult(
      originalSentence: baseSentence,
      targetRegister: LanguageRegister.elevatedFormalAcademic,
      transformedSentence: transformed,
      matchedPattern: matched.elevatedCollocation,
      arabicExplanation: matched.arabicFormalMeaning,
    );
  }
}
