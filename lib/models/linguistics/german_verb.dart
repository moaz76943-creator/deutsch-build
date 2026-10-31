import 'german_grammar_types.dart';
import 'linguistic_concept.dart';
import 'verb_valency_frame.dart';

final class GermanVerbForm {
  const GermanVerbForm({
    required this.tense,
    required this.personKey,
    required this.form,
  });

  final String tense;
  final String personKey;
  final String form;
}

final class GermanVerb {
  const GermanVerb({
    required this.concept,
    required this.infinitive,
    required this.reflexivity,
    required this.auxiliary,
    this.separablePrefix,
    this.inseparablePrefix,
    this.participleII,
    this.preterite,
    this.imperative,
    this.valencyFrames = const <VerbValencyFrame>[],
    this.forms = const <GermanVerbForm>[],
  });

  final LinguisticConcept concept;
  final String infinitive;
  final String? separablePrefix;
  final String? inseparablePrefix;
  final GermanReflexivity reflexivity;
  final GermanAuxiliary auxiliary;
  final String? participleII;
  final String? preterite;
  final String? imperative;
  final List<VerbValencyFrame> valencyFrames;
  final List<GermanVerbForm> forms;

  bool get isSeparable =>
      separablePrefix != null && separablePrefix!.isNotEmpty;
}
