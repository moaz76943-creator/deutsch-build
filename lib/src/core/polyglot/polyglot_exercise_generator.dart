import 'dart:collection';
import 'dart:math';
import 'polyglot_unified_core.dart';
import 'polyglot_srs_and_pack_loader.dart';

/// نوع التمرين التفاعلي المولد تلقائياً من أي وحدة معرفية
enum PolyglotExerciseType {
  contextualCloze,    // ملء الفراغ داخل الجملة السياقية الحية
  errorSpotter,       // كشف الخطأ الشائع مقابل الصياغة السليمة
  bilingualRecall,    // استرجاع التعبير المستهدف من الشرح العربي والسياق
}

/// تمرين تفاعلي موحد قابل للعرض مباشرة في واجهة Flutter (AMOLED 144Hz)
class PolyglotGeneratedExercise {
  final String exerciseId;
  final String unitId;
  final String languageCode;
  final CefrProficiencyLevel level;
  final PolyglotExerciseType type;
  final String promptText;
  final String arabicHint;
  final List<String> options;
  final int correctOptionIndex;
  final String fullReferenceSentence;
  final String arabicExplanation;

  const PolyglotGeneratedExercise({
    required this.exerciseId,
    required this.unitId,
    required this.languageCode,
    required this.level,
    required this.type,
    required this.promptText,
    required this.arabicHint,
    required this.options,
    required this.correctOptionIndex,
    required this.fullReferenceSentence,
    required this.arabicExplanation,
  });

  bool isAnswerCorrect(int selectedIndex) => selectedIndex == correctOptionIndex;

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'unitId': unitId,
        'languageCode': languageCode,
        'level': level.name.toUpperCase(),
        'type': type.name,
        'promptText': promptText,
        'arabicHint': arabicHint,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'fullReferenceSentence': fullReferenceSentence,
        'arabicExplanation': arabicExplanation,
      };
}

/// نتيجة جلسة تدريب تفاعلية مربوطة تلقائياً بمحرك التكرار المتباعد (SM-2)
class ExerciseSubmissionResult {
  final bool isCorrect;
  final String correctOption;
  final String arabicExplanation;
  final SrsReviewCardState updatedSrsCard;

  const ExerciseSubmissionResult({
    required this.isCorrect,
    required this.correctOption,
    required this.arabicExplanation,
    required this.updatedSrsCard,
  });
}

/// مولد التمارين التفاعلية الموحد لجميع اللغات والمستويات دون أي كود مكرر
class PolyglotExerciseGenerator {
  final PolyglotUnifiedRegistry registry;
  final PolyglotSrsScheduler srsScheduler;

  PolyglotExerciseGenerator({
    required this.registry,
    PolyglotSrsScheduler? srsScheduler,
  }) : srsScheduler = srsScheduler ?? PolyglotSrsScheduler();

  /// توليد حزمة تمارين ذكية بناءً على الوحدات المستحقة للمراجعة (SRS Due Queue)
  List<PolyglotGeneratedExercise> generateDueSession({
    String? languageCode,
    int limit = 10,
    int seed = 4987,
    DateTime? now,
  }) {
    final dueUnits = srsScheduler.getDueUnits(
      registry,
      languageCode: languageCode,
      limit: limit,
      now: now,
    );
    final rng = Random(seed);
    final exercises = <PolyglotGeneratedExercise>[];

    for (var i = 0; i < dueUnits.length; i++) {
      final unit = dueUnits[i];
      final type = PolyglotExerciseType.values[i % PolyglotExerciseType.values.length];
      exercises.add(_buildExerciseForUnit(unit, type, rng));
    }
    return UnmodifiableListView(exercises);
  }

  PolyglotGeneratedExercise _buildExerciseForUnit(
    PolyglotLearningUnit unit,
    PolyglotExerciseType type,
    Random rng,
  ) {
    final siblingPool = registry
        .queryUnits(languageCode: unit.languageCode)
        .where((u) => u.id != unit.id)
        .toList(growable: false);

    switch (type) {
      case PolyglotExerciseType.contextualCloze:
        final maskTarget = _pickMaskSegment(unit);
        final maskedSentence = maskTarget != null
            ? unit.contextualSentence.replaceFirst(maskTarget, '______')
            : '${unit.contextualSentence} [______]';
        final correct = maskTarget ?? unit.targetExpression;
        final distractors = _collectDistractors(
          correct: correct,
          siblingPool: siblingPool,
          preferPitfall: unit.commonPitfall,
          rng: rng,
        );
        final options = [correct, ...distractors]..shuffle(rng);
        return PolyglotGeneratedExercise(
          exerciseId: 'ex_cloze_${unit.id}',
          unitId: unit.id,
          languageCode: unit.languageCode,
          level: unit.level,
          type: type,
          promptText: maskedSentence,
          arabicHint: 'أكمل الفراغ بالصيغة الدقيقة في السياق: ${unit.title}',
          options: UnmodifiableListView(options),
          correctOptionIndex: options.indexOf(correct),
          fullReferenceSentence: unit.contextualSentence,
          arabicExplanation: unit.arabicExplanation,
        );

      case PolyglotExerciseType.errorSpotter:
        final correct = unit.contextualSentence;
        final pitfallOption = unit.commonPitfall.trim().isEmpty || unit.commonPitfall == '—'
            ? '${unit.targetExpression} (صياغة حرفية غير دقيقة)'
            : unit.commonPitfall;
        final options = [correct, pitfallOption]..shuffle(rng);
        return PolyglotGeneratedExercise(
          exerciseId: 'ex_err_${unit.id}',
          unitId: unit.id,
          languageCode: unit.languageCode,
          level: unit.level,
          type: type,
          promptText: 'اختر الصياغة السليمة وتجنب الفخ الشائع في: ${unit.title}',
          arabicHint: 'انتبه لقاعدة: ${unit.targetExpression}',
          options: UnmodifiableListView(options),
          correctOptionIndex: options.indexOf(correct),
          fullReferenceSentence: unit.contextualSentence,
          arabicExplanation: unit.arabicExplanation,
        );

      case PolyglotExerciseType.bilingualRecall:
        final correct = unit.targetExpression;
        final distractors = _collectDistractors(
          correct: correct,
          siblingPool: siblingPool,
          preferPitfall: null,
          rng: rng,
        );
        final options = [correct, ...distractors]..shuffle(rng);
        return PolyglotGeneratedExercise(
          exerciseId: 'ex_recall_${unit.id}',
          unitId: unit.id,
          languageCode: unit.languageCode,
          level: unit.level,
          type: type,
          promptText: unit.arabicExplanation,
          arabicHint: 'اختر التعبير المطابق للمستوى (${unit.level.name.toUpperCase()})',
          options: UnmodifiableListView(options),
          correctOptionIndex: options.indexOf(correct),
          fullReferenceSentence: unit.contextualSentence,
          arabicExplanation: unit.arabicExplanation,
        );
    }
  }

  String? _pickMaskSegment(PolyglotLearningUnit unit) {
    final candidates = unit.targetExpression
        .split('/')
        .map((s) => s.trim())
        .where((s) => s.length >= 3 && !s.contains('[') && !s.contains('...'));
    for (final c in candidates) {
      if (unit.contextualSentence.contains(c)) {
        return c;
      }
    }
    return null;
  }

  List<String> _collectDistractors({
    required String correct,
    required List<PolyglotLearningUnit> siblingPool,
    required String? preferPitfall,
    required Random rng,
  }) {
    final result = <String>[];
    if (preferPitfall != null &&
        preferPitfall.trim().isNotEmpty &&
        preferPitfall != '—' &&
        preferPitfall != correct) {
      result.add(preferPitfall);
    }
    final shuffled = List<PolyglotLearningUnit>.from(siblingPool)..shuffle(rng);
    for (final s in shuffled) {
      if (result.length >= 3) break;
      if (s.targetExpression != correct && !result.contains(s.targetExpression)) {
        result.add(s.targetExpression);
      }
    }
    while (result.length < 3) {
      result.add('صياغة بديلة غير مطابقة (${result.length + 1})');
    }
    return result.take(3).toList(growable: false);
  }

  /// تصحيح إجابة المتعلم وتحديث جدول التكرار المتباعد (SM-2) فوراً
  ExerciseSubmissionResult submitAnswer(
    PolyglotGeneratedExercise exercise,
    int selectedOptionIndex, {
    DateTime? now,
  }) {
    final isCorrect = exercise.isAnswerCorrect(selectedOptionIndex);
    final quality = isCorrect ? 5 : 2;
    final updatedCard = srsScheduler.recordReview(
      exercise.unitId,
      quality,
      now: now,
    );
    return ExerciseSubmissionResult(
      isCorrect: isCorrect,
      correctOption: exercise.options[exercise.correctOptionIndex],
      arabicExplanation: exercise.arabicExplanation,
      updatedSrsCard: updatedCard,
    );
  }
}
