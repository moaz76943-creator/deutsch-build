import 'dart:math';

/// Representation of a decomposed German compound noun component.
class CompoundComponent {
  final String text;
  final String? article;
  final String? meaning;
  final bool isHead; // Grundwort (head noun determining gender)
  final bool isFugenelement;

  const CompoundComponent({
    required this.text,
    this.article,
    this.meaning,
    this.isHead = false,
    this.isFugenelement = false,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    if (article != null) 'article': article,
    if (meaning != null) 'meaning': meaning,
    'isHead': isHead,
    'isFugenelement': isFugenelement,
  };
}

/// Data payload for a Compound Decomposition exercise item.
class CompoundDecompositionItem {
  final String id;
  final String fullCompound; // e.g. "der Handschuh"
  final String compoundArticle; // "der"
  final String compoundLemma; // "Handschuh"
  final List<CompoundComponent> components; // ["Hand", "Schuh"]
  final String translationAr; // "القفاز"
  final String explanation;

  const CompoundDecompositionItem({
    required this.id,
    required this.fullCompound,
    required this.compoundArticle,
    required this.compoundLemma,
    required this.components,
    required this.translationAr,
    required this.explanation,
  });

  CompoundComponent get headComponent =>
      components.firstWhere((c) => c.isHead, orElse: () => components.last);
}

/// Exercise generated for the learner.
class CompoundDecompositionExercise {
  final String exerciseId;
  final String compoundLemma;
  final String questionPrompt;
  final List<String> targetComponents;
  final List<String> availableTokens;
  final String expectedArticle;
  final List<String> articleOptions;
  final String translationAr;
  final String explanation;

  const CompoundDecompositionExercise({
    required this.exerciseId,
    required this.compoundLemma,
    required this.questionPrompt,
    required this.targetComponents,
    required this.availableTokens,
    required this.expectedArticle,
    required this.articleOptions,
    required this.translationAr,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'compoundLemma': compoundLemma,
    'questionPrompt': questionPrompt,
    'targetComponents': targetComponents,
    'availableTokens': availableTokens,
    'expectedArticle': expectedArticle,
    'articleOptions': articleOptions,
    'translationAr': translationAr,
    'explanation': explanation,
  };
}

/// Validation result with pedagogical feedback.
class CompoundValidationResult {
  final bool isFullyCorrect;
  final bool isArticleCorrect;
  final bool isDecompositionCorrect;
  final String feedback;
  final String correctArticle;
  final List<String> correctComponents;

  const CompoundValidationResult({
    required this.isFullyCorrect,
    required this.isArticleCorrect,
    required this.isDecompositionCorrect,
    required this.feedback,
    required this.correctArticle,
    required this.correctComponents,
  });
}

/// Generator for interactive German Compound Word Decomposition exercises.
class CompoundDecompositionExerciseGenerator {
  final Random _random;

  CompoundDecompositionExerciseGenerator({Random? random})
      : _random = random ?? Random();

  /// Curated sovereign default bank of German compounds for offline drills.
  static const List<CompoundDecompositionItem> defaultBank = [
    CompoundDecompositionItem(
      id: 'comp_001',
      fullCompound: 'der Handschuh',
      compoundArticle: 'der',
      compoundLemma: 'Handschuh',
      components: [
        CompoundComponent(text: 'Hand', article: 'die', meaning: 'يد'),
        CompoundComponent(text: 'Schuh', article: 'der', meaning: 'حذاء', isHead: true),
      ],
      translationAr: 'قفاز',
      explanation: 'الكلمة مكونة من Hand + Schuh. أداة التعريف "der" تأتي دائماً من الكلمة الأخيرة (Schuh).',
    ),
    CompoundDecompositionItem(
      id: 'comp_002',
      fullCompound: 'der Kühlschrank',
      compoundArticle: 'der',
      compoundLemma: 'Kühlschrank',
      components: [
        CompoundComponent(text: 'kühl', meaning: 'بارد'),
        CompoundComponent(text: 'Schrank', article: 'der', meaning: 'خزانة', isHead: true),
      ],
      translationAr: 'ثلاجة',
      explanation: 'الكلمة مشتقة من الصفة kühl والاسم Schrank، وتأخذ أداة der من الكلمة الأخيرة.',
    ),
    CompoundDecompositionItem(
      id: 'comp_003',
      fullCompound: 'das Wörterbuch',
      compoundArticle: 'das',
      compoundLemma: 'Wörterbuch',
      components: [
        CompoundComponent(text: 'Wörter', article: 'die', meaning: 'كلمات'),
        CompoundComponent(text: 'Buch', article: 'das', meaning: 'كتاب', isHead: true),
      ],
      translationAr: 'قاموس / معجم',
      explanation: 'الكلمة مكونة من Wörter + Buch. تأخذ أداة das بناءً على الكلمة الأخيرة (das Buch).',
    ),
    CompoundDecompositionItem(
      id: 'comp_004',
      fullCompound: 'die Geburtstagskarte',
      compoundArticle: 'die',
      compoundLemma: 'Geburtstagskarte',
      components: [
        CompoundComponent(text: 'Geburt', article: 'die', meaning: 'ولادة'),
        CompoundComponent(text: 's', isFugenelement: true),
        CompoundComponent(text: 'Tag', article: 'der', meaning: 'يوم'),
        CompoundComponent(text: 's', isFugenelement: true),
        CompoundComponent(text: 'Karte', article: 'die', meaning: 'بطاقة', isHead: true),
      ],
      translationAr: 'بطاقة عيد ميلاد',
      explanation: 'تأخذ الكلمة أداة die لأن الكلمة الأخيرة هي die Karte، مع استخدام حروف الربط Fugenelement (-s-).',
    ),
    CompoundDecompositionItem(
      id: 'comp_005',
      fullCompound: 'das Flugzeug',
      compoundArticle: 'das',
      compoundLemma: 'Flugzeug',
      components: [
        CompoundComponent(text: 'Flug', article: 'der', meaning: 'طيران'),
        CompoundComponent(text: 'Zeug', article: 'das', meaning: 'أداة/عتاد', isHead: true),
      ],
      translationAr: 'طائرة',
      explanation: 'الكلمة مركبة من Flug و Zeug، وتأخذ جنس das من الكلمة الجذرية (das Zeug).',
    ),
  ];

  /// Generates a randomized decomposition exercise from an item or the default bank.
  CompoundDecompositionExercise generate({CompoundDecompositionItem? item, int distractorCount = 2}) {
    final targetItem = item ?? defaultBank[_random.nextInt(defaultBank.length)];
    final nonFugenComponents = targetItem.components
        .where((c) => !c.isFugenelement)
        .map((c) => c.text)
        .toList();

    // Pool distractors from other bank items
    final distractorPool = <String>{};
    for (final other in defaultBank) {
      if (other.id != targetItem.id) {
        for (final c in other.components) {
          if (!c.isFugenelement && !nonFugenComponents.contains(c.text)) {
            distractorPool.add(c.text);
          }
        }
      }
    }

    final distractors = distractorPool.toList()..shuffle(_random);
    final chosenDistractors = distractors.take(distractorCount).toList();

    final allTokens = [...nonFugenComponents, ...chosenDistractors]..shuffle(_random);

    return CompoundDecompositionExercise(
      exerciseId: 'comp_ex_${targetItem.id}_${_random.nextInt(10000)}',
      compoundLemma: targetItem.compoundLemma,
      questionPrompt: 'فكك الكلمة المركبة "${targetItem.compoundLemma}" وحدد أداة تعريفها الصحيحة:',
      targetComponents: nonFugenComponents,
      availableTokens: allTokens,
      expectedArticle: targetItem.compoundArticle,
      articleOptions: const ['der', 'die', 'das'],
      translationAr: targetItem.translationAr,
      explanation: targetItem.explanation,
    );
  }

  /// Validates learner's selected components order and chosen article.
  CompoundValidationResult validateAnswer({
    required CompoundDecompositionItem item,
    required List<String> submittedComponents,
    required String submittedArticle,
  }) {
    final expectedComponents = item.components
        .where((c) => !c.isFugenelement)
        .map((c) => c.text.toLowerCase().trim())
        .toList();

    final normalizedSubmitted = submittedComponents
        .map((c) => c.toLowerCase().trim())
        .toList();

    final isDecompositionCorrect =
        expectedComponents.length == normalizedSubmitted.length &&
        Iterable<int>.generate(expectedComponents.length).every(
          (i) => expectedComponents[i] == normalizedSubmitted[i],
        );

    final isArticleCorrect =
        item.compoundArticle.toLowerCase().trim() == submittedArticle.toLowerCase().trim();

    final isFullyCorrect = isDecompositionCorrect && isArticleCorrect;

    String feedback;
    if (isFullyCorrect) {
      feedback = 'رائع! الإجابة صحيحة تماماً. الأداة والترتيب دقيقان.';
    } else if (!isDecompositionCorrect && isArticleCorrect) {
      feedback = 'الأداة صحيحة، ولكن تفكيك عناصر الكلمة المركبة غير مطابق.';
    } else if (isDecompositionCorrect && !isArticleCorrect) {
      feedback = 'التفكيك صحيح، لكن انتبه: أداة التعريف تتحدد دائماً بالكلمة الأخيرة (${item.headComponent.text}).';
    } else {
      feedback = 'إجابة غير صحيحة. راجع أجزاء الكلمة وأداة التعريف الأخيرة.';
    }

    return CompoundValidationResult(
      isFullyCorrect: isFullyCorrect,
      isArticleCorrect: isArticleCorrect,
      isDecompositionCorrect: isDecompositionCorrect,
      feedback: feedback,
      correctArticle: item.compoundArticle,
      correctComponents: item.components.where((c) => !c.isFugenelement).map((c) => c.text).toList(),
    );
  }
}
