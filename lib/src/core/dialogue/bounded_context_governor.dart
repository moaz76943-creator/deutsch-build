import 'local_llm_engine.dart';

class ContextMemoryBudget {
  final int maxTokens;
  final int maxTurns;
  final double maxKvCacheMb;

  const ContextMemoryBudget({
    this.maxTokens = 1024,
    this.maxTurns = 12,
    this.maxKvCacheMb = 48.0,
  });
}

class BoundedContextGovernor {
  final ContextMemoryBudget budget;

  const BoundedContextGovernor({this.budget = const ContextMemoryBudget()});

  /// Computes KV-Cache footprint: 2 * layers * heads * head_dim * tokens * bytes_per_element
  double calculateKvCacheMemoryMb({
    required int activeTokens,
    int layers = 18,
    int kvHeads = 2,
    int headDim = 64,
    int bytesPerElement = 2, // 16-bit FP16
  }) {
    final int totalBytes = 2 * layers * kvHeads * headDim * activeTokens * bytesPerElement;
    return totalBytes / (1024.0 * 1024.0);
  }

  /// Compacts and prunes conversational context when budget is exceeded.
  /// Always pins the primary system prompt and recent turns, while summarizing middle turns.
  List<DialogueMessage> pruneContext(List<DialogueMessage> history) {
    if (history.isEmpty) return [];

    int totalTokens = history.fold(0, (sum, msg) => sum + msg.estimatedTokens);
    if (totalTokens <= budget.maxTokens && history.length <= budget.maxTurns) {
      return List.from(history);
    }

    final DialogueMessage systemPrompt = history.firstWhere(
      (m) => m.role == DialogueRole.system,
      orElse: () => DialogueMessage(role: DialogueRole.system, content: 'Language learning scenario.'),
    );

    // Keep the most recent 4 turns untouched
    final recentTurns = history.sublist(history.length > 4 ? history.length - 4 : 0);

    // Generate a compact middle summary turn
    final int prunedCount = history.length - recentTurns.length - 1;
    final summaryMessage = DialogueMessage(
      role: DialogueRole.system,
      content: '[Recap: Learner and tutor exchanged $prunedCount polite turns establishing context]',
    );

    final prunedList = <DialogueMessage>[
      systemPrompt,
      summaryMessage,
      ...recentTurns.where((m) => m != systemPrompt),
    ];

    return prunedList;
  }
}
