/// Formatted grounded prompt ready for on-device SLM execution.
class GroundedRagPrompt {
  final String systemInstructions;
  final String assembledContext;
  final String learnerQuery;
  final int totalEstimatedTokens;

  const GroundedRagPrompt({
    required this.systemInstructions,
    required this.assembledContext,
    required this.learnerQuery,
    required this.totalEstimatedTokens,
  });
}

/// Dynamic assembler that injects verified local knowledge into bounded LLM prompt windows.
class OfflineRAGSynthesizer {
  final int maxContextTokenBudget;

  const OfflineRAGSynthesizer({this.maxContextTokenBudget = 384});

  /// Assembles verified context passages and learner state into a strict anti-hallucination prompt.
  GroundedRagPrompt buildPrompt({
    required String query,
    required List<String> retrievedPassages,
    required List<String> targetVocabulary,
    required String cefrTarget,
  }) {
    final contextBuffer = StringBuffer();
    contextBuffer.writeln('=== VERIFIED LOCAL CONTEXT ===');

    int tokenCount = 0;
    for (final passage in retrievedPassages) {
      final passageTokens = (passage.length / 4).ceil();
      if (tokenCount + passageTokens > maxContextTokenBudget) {
        break; // Guard against context overflow
      }
      contextBuffer.writeln('- $passage');
      tokenCount += passageTokens;
    }

    if (targetVocabulary.isNotEmpty) {
      contextBuffer.writeln('MANDATORY TARGET VOCABULARY: ${targetVocabulary.join(', ')}');
    }
    contextBuffer.writeln('TARGET CEFR LEVEL: $cefrTarget');

    const systemPrompt =
        'You are an offline Polyglot AI interlocutor. Ground all responses strictly on '
        'the verified local context provided. Do not hallucinate external facts. '
        'Encourage subconscious language acquisition.';

    final totalEstimate = ((systemPrompt.length + contextBuffer.length + query.length) / 4).ceil();

    return GroundedRagPrompt(
      systemInstructions: systemPrompt,
      assembledContext: contextBuffer.toString().trim(),
      learnerQuery: query,
      totalEstimatedTokens: totalEstimate,
    );
  }
}
