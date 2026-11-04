/// Task 1325: Circumfix and affix decomposer (ge-...-t / ge-...-en)
class CircumfixDecomposer {
  bool isPartizip2(String form) => form.startsWith('ge') && (form.endsWith('t') || form.endsWith('en'));
}
