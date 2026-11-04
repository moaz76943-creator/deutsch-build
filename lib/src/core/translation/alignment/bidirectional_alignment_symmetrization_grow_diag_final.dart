/// Task 1715: Och & Ney grow-diag-final-and alignment symmetrization heuristic
class AlignmentSymmetrizer {
  Set<String> symmetrize(Set<String> forward, Set<String> backward) => forward.intersection(backward);
}
