/// Task 1352: Validates Konjunktiv II (würde + Inf vs hätte/wäre)
class Konjunktiv2Validator {
  bool isSyntheticSubjunctive(String form) => form == 'hätte' || form == 'wäre' || form == 'könnte';
}
