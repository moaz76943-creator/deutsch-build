/// Task 1318: CoNLL-U format serializer for Universal Dependencies treebanks
class ConlluFormatParser {
  String serializeToken(int id, String form, String lemma, String upos) => '$id\t$form\t$lemma\t$upos\t_\t_\t_\t_\t_\t_';
}
