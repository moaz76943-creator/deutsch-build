/// Task 1447: Four-domain holistic rubric scorer (Task, Coherence, Lexicon, Grammar)
class CefrWritingRubricCalibrator {
  double computeComposite(double task, double coherence, double lexicon, double grammar) => (task + coherence + lexicon + grammar) / 4.0;
}
