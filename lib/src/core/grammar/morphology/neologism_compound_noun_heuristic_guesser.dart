/// Task 1337: Morphological guesser for unknown neologisms and compounds
class CompoundHeuristicGuesser {
  String guessGender(String compound) => compound.endsWith('ung') ? 'Fem' : (compound.endsWith('ling') ? 'Masc' : 'Neut');
}
