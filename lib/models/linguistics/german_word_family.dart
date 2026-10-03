import 'linguistic_concept.dart';

enum GermanWordFamilyRelationType {
  base,
  agentNoun,
  eventNoun,
  derivedNoun,
  derivedAdjective,
  prefixedVerb,
  compound,
  semanticRelative,
  historicalRelative,
  notPedagogicallyLinked,
  unknown;

  String get wireName => switch (this) {
        GermanWordFamilyRelationType.agentNoun => 'agent_noun',
        GermanWordFamilyRelationType.eventNoun => 'event_noun',
        GermanWordFamilyRelationType.derivedNoun => 'derived_noun',
        GermanWordFamilyRelationType.derivedAdjective => 'derived_adjective',
        GermanWordFamilyRelationType.prefixedVerb => 'prefixed_verb',
        GermanWordFamilyRelationType.semanticRelative => 'semantic_relative',
        GermanWordFamilyRelationType.historicalRelative =>
          'historical_relative',
        GermanWordFamilyRelationType.notPedagogicallyLinked =>
          'not_pedagogically_linked',
        _ => name,
      };

  static GermanWordFamilyRelationType fromWire(String? value) {
    final normalized = value?.trim().toLowerCase();
    return GermanWordFamilyRelationType.values.firstWhere(
      (item) => item.wireName == normalized,
      orElse: () => GermanWordFamilyRelationType.unknown,
    );
  }
}

enum GermanSemanticDistance {
  low,
  medium,
  high,
  unknown;

  String get wireName => name;

  static GermanSemanticDistance fromWire(String? value) {
    final normalized = value?.trim().toLowerCase();
    return GermanSemanticDistance.values.firstWhere(
      (item) => item.wireName == normalized,
      orElse: () => GermanSemanticDistance.unknown,
    );
  }
}

final class GermanWordFamilyMember {
  const GermanWordFamilyMember({
    required this.concept,
    required this.relationType,
    required this.semanticDistance,
    required this.pedagogicalLevel,
    required this.interferenceRisk,
    this.prefix,
    this.suffix,
  });

  final LinguisticConcept concept;
  final GermanWordFamilyRelationType relationType;
  final String? prefix;
  final String? suffix;
  final GermanSemanticDistance semanticDistance;
  final CefrLevel pedagogicalLevel;
  final bool interferenceRisk;

  bool get isBase => relationType == GermanWordFamilyRelationType.base;
}

final class GermanWordFamily {
  const GermanWordFamily({
    required this.familyId,
    required this.baseConceptId,
    required this.members,
  });

  final String familyId;
  final String baseConceptId;
  final List<GermanWordFamilyMember> members;

  GermanWordFamilyMember? get baseMember {
    for (final member in members) {
      if (member.concept.id == baseConceptId && member.isBase) {
        return member;
      }
    }
    return null;
  }

  bool get hasInterferenceRisk =>
      members.any((member) => member.interferenceRisk);
}
