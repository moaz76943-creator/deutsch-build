/// Task 1388: Remaps prepositions between German and Arabic (warten auf -> ينتظر)
class PrepositionRemappingTable {
  String getTargetConstruction(String deVerb) => deVerb == 'warten_auf' ? 'Direct_Object' : 'Prepositional';
}
