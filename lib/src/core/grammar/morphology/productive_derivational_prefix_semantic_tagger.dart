/// Task 1334: Tags semantic shifts of verbal prefixes (ver-, zer-, ent-)
class PrefixSemanticTagger {
  String getPrefixMeaning(String prefix) => prefix == 'zer' ? 'DESTRUCTION' : (prefix == 'ver' ? 'CHANGE_OR_ERROR' : 'STANDARD');
}
