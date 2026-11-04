/// Task 1652: Multi-finger tap gesture toggling grammatical gender visibility
class GenderFilterTapSelector {
  String getToggledGender(int fingerCount) => fingerCount == 1 ? 'Masc' : (fingerCount == 2 ? 'Fem' : 'Neut');
}
