import 'german_grammar_types.dart';
import 'german_noun_forms.dart';
import 'linguistic_concept.dart';

final class GermanNoun {
  const GermanNoun({
    required this.concept,
    required this.gender,
    required this.declensionClass,
    required this.caseForms,
    this.plural,
  });

  final LinguisticConcept concept;
  final GermanGender gender;
  final String? plural;
  final GermanNounDeclensionClass declensionClass;
  final GermanNounCaseForms caseForms;
}
