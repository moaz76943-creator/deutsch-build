enum SupportedExam {
  goethe,
  delf,
  dele,
  hsk,
  jlpt,
  cefrUniversal,
}

enum ExamPhase {
  foundationAcquisition,
  deepeningAndMockDrills,
  finalSprintTaper,
}

class ExamStandardMetadata {
  final SupportedExam exam;
  final String level;
  final int requiredVocabCount;
  final int recommendedHours;

  const ExamStandardMetadata({
    required this.exam,
    required this.level,
    required this.requiredVocabCount,
    required this.recommendedHours,
  });
}

class DailyStudyQuota {
  final int dayNumber;
  final ExamPhase phase;
  final int newVocabCount;
  final int reviewCardsCount;
  final int recommendedMinutes;
  final bool isMockExamDay;

  const DailyStudyQuota({
    required this.dayNumber,
    required this.phase,
    required this.newVocabCount,
    required this.reviewCardsCount,
    required this.recommendedMinutes,
    this.isMockExamDay = false,
  });
}

class ExamPrepPlan {
  final SupportedExam exam;
  final String level;
  final int daysRemaining;
  final int totalVocabRemaining;
  final double feasibilityScore;
  final bool requiresIntensivePacing;
  final List<DailyStudyQuota> dailySchedule;
  final List<int> mockExamDays;

  const ExamPrepPlan({
    required this.exam,
    required this.level,
    required this.daysRemaining,
    required this.totalVocabRemaining,
    required this.feasibilityScore,
    required this.requiresIntensivePacing,
    required this.dailySchedule,
    required this.mockExamDays,
  });

  Map<String, dynamic> toJson() => {
    'exam': exam.name,
    'level': level,
    'daysRemaining': daysRemaining,
    'totalVocabRemaining': totalVocabRemaining,
    'feasibilityScore': feasibilityScore,
    'requiresIntensivePacing': requiresIntensivePacing,
    'scheduleDaysCount': dailySchedule.length,
    'mockExamDays': mockExamDays,
  };
}

class ExamPrepStudyPlanGenerator {
  static const Map<String, ExamStandardMetadata> registry = {
    'goethe_a1': ExamStandardMetadata(exam: SupportedExam.goethe, level: 'A1', requiredVocabCount: 650, recommendedHours: 70),
    'goethe_b1': ExamStandardMetadata(exam: SupportedExam.goethe, level: 'B1', requiredVocabCount: 2400, recommendedHours: 240),
    'delf_a2': ExamStandardMetadata(exam: SupportedExam.delf, level: 'A2', requiredVocabCount: 1200, recommendedHours: 120),
    'dele_b2': ExamStandardMetadata(exam: SupportedExam.dele, level: 'B2', requiredVocabCount: 3500, recommendedHours: 350),
    'jlpt_n5': ExamStandardMetadata(exam: SupportedExam.jlpt, level: 'N5', requiredVocabCount: 800, recommendedHours: 100),
    'hsk_3': ExamStandardMetadata(exam: SupportedExam.hsk, level: 'HSK3', requiredVocabCount: 600, recommendedHours: 80),
  };

  const ExamPrepStudyPlanGenerator();

  ExamPrepPlan generatePlan({
    required SupportedExam exam,
    required String level,
    required DateTime targetExamDate,
    required DateTime currentDate,
    required int knownVocabCount,
    required int dailyAvailableMinutes,
  }) {
    final key = '${exam.name}_${level.toLowerCase()}';
    final metadata = registry[key] ?? ExamStandardMetadata(
      exam: exam,
      level: level,
      requiredVocabCount: 1000,
      recommendedHours: 100,
    );

    final int daysRemaining = targetExamDate.difference(currentDate).inDays;
    if (daysRemaining <= 0) {
      throw ArgumentError('Exam date must be strictly in the future.');
    }

    final int vocabNeeded = (metadata.requiredVocabCount - knownVocabCount).clamp(0, metadata.requiredVocabCount);
    final double totalAvailableHours = (daysRemaining * dailyAvailableMinutes) / 60.0;
    final double feasibility = (totalAvailableHours / metadata.recommendedHours).clamp(0.1, 1.0);
    final bool intensive = feasibility < 0.75;

    // Phase distribution: 50% Foundation, 35% Deepening, 15% Final Sprint Taper
    final int foundationDays = (daysRemaining * 0.50).floor();
    final int deepeningDays = (daysRemaining * 0.35).floor();
    final int taperDays = daysRemaining - foundationDays - deepeningDays;

    final List<DailyStudyQuota> schedule = [];
    final List<int> mocks = [];

    // Schedule mock exam every 14 days and one major mock 5 days before exam
    for (int day = 1; day <= daysRemaining; day++) {
      ExamPhase phase;
      int newVocab = 0;
      int reviews = 20;
      bool isMock = false;

      if (day <= foundationDays) {
        phase = ExamPhase.foundationAcquisition;
        newVocab = (vocabNeeded / (foundationDays + (deepeningDays * 0.5))).ceil();
      } else if (day <= foundationDays + deepeningDays) {
        phase = ExamPhase.deepeningAndMockDrills;
        newVocab = (vocabNeeded * 0.2 / deepeningDays).ceil();
        reviews = 40;
      } else {
        phase = ExamPhase.finalSprintTaper;
        newVocab = 0; // No new words in taper phase to prevent cognitive overload
        reviews = 50;
      }

      if (day % 14 == 0 || day == (daysRemaining - 5)) {
        isMock = true;
        mocks.add(day);
      }

      schedule.add(DailyStudyQuota(
        dayNumber: day,
        phase: phase,
        newVocabCount: newVocab,
        reviewCardsCount: reviews,
        recommendedMinutes: dailyAvailableMinutes,
        isMockExamDay: isMock,
      ));
    }

    return ExamPrepPlan(
      exam: exam,
      level: level,
      daysRemaining: daysRemaining,
      totalVocabRemaining: vocabNeeded,
      feasibilityScore: double.parse(feasibility.toStringAsFixed(2)),
      requiresIntensivePacing: intensive,
      dailySchedule: schedule,
      mockExamDays: mocks,
    );
  }
}
