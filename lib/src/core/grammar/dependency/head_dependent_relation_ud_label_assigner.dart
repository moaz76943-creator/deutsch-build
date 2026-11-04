/// Task 1363: Assigns Universal Dependencies relation labels (nsubj, obj, amod)
class UdRelationLabelAssigner {
  String assignRelation(String posHead, String posDep) => (posHead == 'VERB' && posDep == 'NOUN') ? 'nsubj' : 'amod';
}
