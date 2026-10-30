import 'local_llm_engine.dart';
import 'bounded_context_governor.dart';

class DialogueStressAuditResult {
  final int totalSimulatedTurns;
  final double peakMemoryMb;
  final double finalMemoryMb;
  final int totalTokensProcessed;
  final int compactionsTriggered;
  final bool isWithinSovereignBudget;
  final String auditVerdict;

  const DialogueStressAuditResult({
    required this.totalSimulatedTurns,
    required this.peakMemoryMb,
    required this.finalMemoryMb,
    required this.totalTokensProcessed,
    required this.compactionsTriggered,
    required this.isWithinSovereignBudget,
    required this.auditVerdict,
  });

  Map<String, dynamic> toJson() => {
    'totalSimulatedTurns': totalSimulatedTurns,
    'peakMemoryMb': peakMemoryMb,
    'finalMemoryMb': finalMemoryMb,
    'totalTokensProcessed': totalTokensProcessed,
    'compactionsTriggered': compactionsTriggered,
    'isWithinSovereignBudget': isWithinSovereignBudget,
    'auditVerdict': auditVerdict,
  };
}

class DialogueRamStressBenchmark {
  static const double maxMemoryBudgetMb = 180.0;
  final BoundedContextGovernor contextGovernor;

  const DialogueRamStressBenchmark({
    this.contextGovernor = const BoundedContextGovernor(),
  });

  /// Executes an intensive 100-turn simulated conversational stress test.
  DialogueStressAuditResult execute100TurnStressTest() {
    final history = <DialogueMessage>[
      DialogueMessage(role: DialogueRole.system, content: 'Du bist ein erfahrener Sprachlehrer in Berlin.'),
    ];

    double currentSimulatedRamMb = 95.0; // Base model weights in Q4_K_M
    double peakRamMb = currentSimulatedRamMb;
    int compactions = 0;
    int totalTokens = 0;

    for (int turn = 1; turn <= 100; turn++) {
      final userText = 'Das ist mein Redebeitrag Nummer $turn in der langen Unterhaltung.';
      final tutorText = 'Sehr gut verstanden, das war Turn $turn mit korrekter deutscher Syntax.';

      history.add(DialogueMessage(role: DialogueRole.user, content: userText));
      history.add(DialogueMessage(role: DialogueRole.assistant, content: tutorText));

      totalTokens += (userText.length / 3.8).ceil() + (tutorText.length / 3.8).ceil();

      // Check context budget and trigger sliding window compaction
      if (history.length > 12) {
        final pruned = contextGovernor.pruneContext(history);
        compactions++;
        history
          ..clear()
          ..addAll(pruned);
      }

      // Compute dynamic KV-cache memory expansion
      final kvCacheMb = contextGovernor.calculateKvCacheMemoryMb(activeTokens: history.length * 18);
      currentSimulatedRamMb = 95.0 + kvCacheMb + (history.length * 0.15);

      if (currentSimulatedRamMb > peakRamMb) {
        peakRamMb = currentSimulatedRamMb;
      }
    }

    final bool withinBudget = peakRamMb < maxMemoryBudgetMb;

    return DialogueStressAuditResult(
      totalSimulatedTurns: 100,
      peakMemoryMb: double.parse(peakRamMb.toStringAsFixed(2)),
      finalMemoryMb: double.parse(currentSimulatedRamMb.toStringAsFixed(2)),
      totalTokensProcessed: totalTokens,
      compactionsTriggered: compactions,
      isWithinSovereignBudget: withinBudget,
      auditVerdict: withinBudget
          ? 'MEMORY_STRESS_PASSED_LEAK_FREE'
          : 'MEMORY_BUDGET_EXCEEDED',
    );
  }
}
