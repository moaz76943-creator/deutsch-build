enum MistakeCategory {
  vocabulary,
  article,
  grammar,
  translation,
  wordOrder,
  writing,
  production,
  listening,
}

enum MistakeSource { practice, assessment, conversation, writing }

enum RepairMode { recognize, correct, produce }

class MistakeRecord {
  final String itemId, normalizedKey;
  final MistakeCategory category;
  final MistakeSource source;
  final int errorCount, attemptCount, correctiveStreak, severity;
  final DateTime? lastSeenAt;
  final double failureRate, recentFailureRate;
  final String diagnosis;
  const MistakeRecord({
    required this.itemId,
    required this.category,
    required this.source,
    required this.errorCount,
    required this.attemptCount,
    required this.correctiveStreak,
    required this.lastSeenAt,
    required this.severity,
    required this.normalizedKey,
    this.failureRate = 0,
    this.recentFailureRate = 0,
    this.diagnosis = 'مراجعة هذا الخطأ تحتاج إلى تدريب موجّه.',
  });
}

class RepairStep {
  final RepairMode mode;
  final String prompt, expected;
  final List<String> accepted;
  const RepairStep({
    required this.mode,
    required this.prompt,
    required this.expected,
    this.accepted = const [],
  });
}

class RepairDrill {
  final MistakeRecord mistake;
  final List<RepairStep> steps;
  const RepairDrill({required this.mistake, required this.steps});
}

class MistakeReport {
  final List<MistakeRecord> items;
  final String headline;
  const MistakeReport({required this.items, required this.headline});
}

String mistakeCategoryLabel(MistakeCategory x) =>
    const {
      MistakeCategory.vocabulary: 'مفردات',
      MistakeCategory.article: 'Artikel',
      MistakeCategory.grammar: 'قواعد',
      MistakeCategory.translation: 'ترجمة',
      MistakeCategory.wordOrder: 'ترتيب الجملة',
      MistakeCategory.writing: 'كتابة',
      MistakeCategory.production: 'إنتاج',
      MistakeCategory.listening: 'استماع',
    }[x] ??
    'تدريب';

bool repairStepAccepts(
  RepairStep step,
  String answer,
  String Function(String value) normalize,
) {
  final normalized = normalize(answer);
  if (normalized.isEmpty) return false;
  if (normalize(step.expected) == normalized) return true;
  return step.accepted.any((value) => normalize(value) == normalized);
}
