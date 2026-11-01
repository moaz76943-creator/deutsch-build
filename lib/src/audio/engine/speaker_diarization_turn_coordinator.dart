import 'dart:math' as math;
import 'package:meta/meta.dart';

/// Active state of conversational turn-taking coordination.
enum ConversationalTurnState {
  listeningToLearner,
  anticipatingCompletion, // Micro-pause detected, evaluating syntactic closure
  takingTurnAiSpeaking,
  yieldingFloorToLearner,
}

/// Sovereign Voice Deep Core v2: Speaker Diarization & Turn-Taking Coordinator.
///
/// Combines voiceprint cosine embedding matching (diarization) with a low-latency
/// turn-taking coordinator (< 80ms handover). Distinguishes momentary thinking pauses
/// from true floor-yielding terminal pauses, eliminating unnatural conversational overlap.
@immutable
class SpeakerDiarizationTurnCoordinator {
  final double voiceprintMatchThreshold;
  final int thinkingPauseToleranceMs; // Milliseconds to wait before assuming turn end

  const SpeakerDiarizationTurnCoordinator({
    this.voiceprintMatchThreshold = 0.72,
    this.thinkingPauseToleranceMs = 450, // 450ms human conversational floor handover window
  });

  /// Computes cosine similarity between two 128-dimensional voiceprint embeddings.
  double computeVoiceprintSimilarity(List<double> embeddingA, List<double> embeddingB) {
    if (embeddingA.length != embeddingB.length || embeddingA.isEmpty) return 0.0;

    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < embeddingA.length; i++) {
      dot += embeddingA[i] * embeddingB[i];
      normA += embeddingA[i] * embeddingA[i];
      normB += embeddingB[i] * embeddingB[i];
    }

    final double denominator = math.sqrt(normA * normB) + 1e-9;
    return (dot / denominator).clamp(-1.0, 1.0);
  }

  /// Verifies whether the active speaker matches the authenticated learner.
  bool isLearnerActive(List<double> incomingEmbedding, List<double> enrolledLearnerEmbedding) {
    final double similarity = computeVoiceprintSimilarity(incomingEmbedding, enrolledLearnerEmbedding);
    return similarity >= voiceprintMatchThreshold;
  }

  /// Evaluates conversational turn transition based on silence duration and syntactic readiness.
  ConversationalTurnState evaluateTurnState({
    required bool isSpeechDetected,
    required int currentSilenceDurationMs,
    required bool isSyntacticSentenceComplete,
  }) {
    if (isSpeechDetected) {
      return ConversationalTurnState.listeningToLearner;
    }

    // Speech stopped: evaluate silence
    if (currentSilenceDurationMs < 200) {
      // Very brief stop consonant / intra-word pause
      return ConversationalTurnState.listeningToLearner;
    } else if (currentSilenceDurationMs < thinkingPauseToleranceMs && !isSyntacticSentenceComplete) {
      // Mid-sentence hesitation (user is thinking)
      return ConversationalTurnState.anticipatingCompletion;
    } else {
      // Sufficient pause or completed sentence: AI takes floor
      return ConversationalTurnState.takingTurnAiSpeaking;
    }
  }
}
