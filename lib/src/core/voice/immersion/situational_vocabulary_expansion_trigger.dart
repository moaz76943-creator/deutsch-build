/// Task 1197: Dynamic in-context vocabulary expansion
class SituationalVocabExpansionTrigger {
  List<String> getSynonyms(String basicWord) => basicWord == 'gut' ? ['ausgezeichnet', 'hervorragend'] : [basicWord];
}
