import 'package:meta/meta.dart';

/// CEFR proficency level speed profiles (syllables per second).
enum CefrPacingLevel {
  a1Beginner, // 2.4 syllables/sec - slow, deliberate, clear boundaries
  a2Elementary, // 3.2 syllables/sec - measured conversational pace
  b1Intermediate, // 4.0 syllables/sec - standard natural dialogue
  b2UpperIntermediate, // 4.8 syllables/sec - fluent native-like speed
  c1c2Mastery, // 5.4 syllables/sec - rapid authentic native stream
}

/// Token with calibrated speech duration and post-token pause.
@immutable
class PacedTokenUnit {
  final String textToken;
  final double durationSeconds;
  final double pauseAfterSeconds;

  const PacedTokenUnit({
    required this.textToken,
    required this.durationSeconds,
    required this.pauseAfterSeconds,
  });
}

/// Sovereign Voice Deep Core v2: Dynamic Speech Rate Pacer & Syntactic Pause Insertion Engine.
///
/// Modulates utterance delivery speed according to learner proficiency (Krashen i+1 comprehensible input),
/// inserting syntactically motivated cognitive pauses at commas, conjunctions, and sentence terminals.
@immutable
class DynamicSpeechRatePacer {
  const DynamicSpeechRatePacer();

  /// Calculates target syllables per second for a CEFR proficiency level.
  double getTargetSps(CefrPacingLevel level) {
    switch (level) {
      case CefrPacingLevel.a1Beginner:
        return 2.4;
      case CefrPacingLevel.a2Elementary:
        return 3.2;
      case CefrPacingLevel.b1Intermediate:
        return 4.0;
      case CefrPacingLevel.b2UpperIntermediate:
        return 4.8;
      case CefrPacingLevel.c1c2Mastery:
        return 5.4;
    }
  }

  /// Breaks text into paced token units with syntactic pause boundaries.
  List<PacedTokenUnit> paceText(String text, {CefrPacingLevel level = CefrPacingLevel.a1Beginner}) {
    if (text.trim().isEmpty) return const [];

    final double sps = getTargetSps(level);
    final rawTokens = text.trim().split(RegExp(r'\s+'));
    final pacedList = <PacedTokenUnit>[];

    for (final raw in rawTokens) {
      final int syllables = _estimateSyllables(raw);
      final double tokenDuration = (syllables / sps).clamp(0.12, 1.8);

      double pauseAfter = 0.05; // Default short intra-phrase gap
      if (raw.endsWith('.') || raw.endsWith('!') || raw.endsWith('?') || raw.endsWith('။')) {
        pauseAfter = (level == CefrPacingLevel.a1Beginner) ? 0.65 : 0.40; // Sentence terminal
      } else if (raw.endsWith(',') || raw.endsWith('،') || raw.endsWith(';')) {
        pauseAfter = (level == CefrPacingLevel.a1Beginner) ? 0.35 : 0.20; // Clause boundary
      }

      pacedList.add(PacedTokenUnit(
        textToken: raw,
        durationSeconds: tokenDuration,
        pauseAfterSeconds: pauseAfter,
      ));
    }

    return pacedList;
  }

  int _estimateSyllables(String word) {
    final clean = word.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z\u0600-\u06FF\u0400-\u04FF\u4E00-\u9FFF]'), '');
    if (clean.isEmpty) return 1;
    // Basic multi-script vowel estimation
    final int vowels = RegExp(r'[aeiouyáéíóúäöüɛɔаеёиоуыэюя\u064E\u064F\u0650]').allMatches(clean).length;
    return math.max(1, vowels);
  }
}
