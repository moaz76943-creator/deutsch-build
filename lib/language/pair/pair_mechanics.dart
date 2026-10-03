import 'dart:convert';

import '../language_capability.dart';
import '../language_role.dart';

/// Ordered identity for one directed source -> target language pair.
///
/// Direction is part of identity. This type does not register, synthesize, or
/// infer the reverse pair.
final class PairIdentity {
  final String sourceLanguageId;
  final String targetLanguageId;

  PairIdentity({
    required this.sourceLanguageId,
    required this.targetLanguageId,
  }) {
    _requireNonEmpty(sourceLanguageId, 'sourceLanguageId');
    _requireNonEmpty(targetLanguageId, 'targetLanguageId');
    if (sourceLanguageId == targetLanguageId) {
      throw ArgumentError(
        'directed pair requires distinct source and target languages',
      );
    }
  }

  /// Stable, direction-bound serialization with no separator ambiguity.
  String get stableId =>
      'pair-v1:${_hexUtf8(sourceLanguageId)}>${_hexUtf8(targetLanguageId)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PairIdentity &&
          other.sourceLanguageId == sourceLanguageId &&
          other.targetLanguageId == targetLanguageId;

  @override
  int get hashCode => Object.hash(sourceLanguageId, targetLanguageId);

  @override
  String toString() => stableId;
}

/// One pair endpoint validated against the F1-A1 role-eligibility contract.
final class PairEndpoint {
  final String languageId;
  final LanguageRole role;
  final LanguageRoleEligibilityRecord eligibility;

  PairEndpoint._({
    required this.languageId,
    required this.role,
    required this.eligibility,
  }) {
    _requireNonEmpty(languageId, 'languageId');
    if (eligibility.languageId != languageId || eligibility.role != role) {
      throw ArgumentError(
        'endpoint eligibility must match exact language and role',
      );
    }
    if (!eligibility.allowsRole) {
      throw StateError('pair endpoint requires explicit ELIGIBLE role');
    }
  }

  factory PairEndpoint.source({
    required String languageId,
    required LanguageRoleEligibilityRecord eligibility,
  }) {
    return PairEndpoint._(
      languageId: languageId,
      role: LanguageRole.source,
      eligibility: eligibility,
    );
  }

  factory PairEndpoint.target({
    required String languageId,
    required LanguageRoleEligibilityRecord eligibility,
  }) {
    return PairEndpoint._(
      languageId: languageId,
      role: LanguageRole.target,
      eligibility: eligibility,
    );
  }
}

/// Direction-bound reference only. It contains no linguistic override truth.
final class DirectedPairOverrideRef {
  final String overrideId;
  final PairIdentity pair;

  DirectedPairOverrideRef({required this.overrideId, required this.pair}) {
    _requireNonEmpty(overrideId, 'overrideId');
  }

  bool appliesTo(PairIdentity requestedPair) => pair == requestedPair;
}

/// One input explicitly declared by a registered pair mechanics rule.
final class PairRuleInputRequirement {
  final String inputKey;
  final LanguageRole role;
  final bool acceptsLimited;
  final bool acceptsNotApplicable;

  const PairRuleInputRequirement({
    required this.inputKey,
    required this.role,
    this.acceptsLimited = false,
    this.acceptsNotApplicable = false,
  })  : assert(inputKey != ''),
        assert(role != LanguageRole.user);
}

/// Mechanics-only rule metadata.
///
/// A rule without declared pair inputs cannot emit a linguistic candidate.
final class PairRule {
  final String ruleId;
  final String ruleVersion;
  final String candidateKind;
  final List<PairRuleInputRequirement> requiredInputs;

  PairRule({
    required this.ruleId,
    required this.ruleVersion,
    required this.candidateKind,
    required List<PairRuleInputRequirement> requiredInputs,
  }) : requiredInputs = List<PairRuleInputRequirement>.unmodifiable(
          requiredInputs,
        ) {
    _requireNonEmpty(ruleId, 'ruleId');
    _requireNonEmpty(ruleVersion, 'ruleVersion');
    _requireNonEmpty(candidateKind, 'candidateKind');

    final seen = <String>{};
    for (final requirement in this.requiredInputs) {
      _requireNonEmpty(requirement.inputKey, 'inputKey');
      if (requirement.role == LanguageRole.user) {
        throw ArgumentError('pair rules may require SOURCE/TARGET inputs only');
      }
      final key = '${requirement.role.wireName}|${requirement.inputKey}';
      if (!seen.add(key)) {
        throw ArgumentError('duplicate pair rule input requirement: $key');
      }
    }
  }
}

/// Synthetic/mechanics fact consumed only when a rule explicitly declares it.
///
/// [valueFingerprint] is an opaque already-derived fact coordinate/value hash.
/// Factory-3 does not interpret it as semantic or linguistic truth.
final class PairInputFact {
  final String languageId;
  final LanguageRole role;
  final String inputKey;
  final LanguageCapabilityState state;
  final String valueFingerprint;

  PairInputFact({
    required this.languageId,
    required this.role,
    required this.inputKey,
    required this.state,
    required this.valueFingerprint,
  }) {
    _requireNonEmpty(languageId, 'languageId');
    _requireNonEmpty(inputKey, 'inputKey');
    _requireNonEmpty(valueFingerprint, 'valueFingerprint');
  }
}

/// Candidate-only lifecycle. Verified/readiness states deliberately do not exist.
enum PairCandidateState { derivedCandidate, reviewNeeded, conflict }

/// Immutable mechanics candidate. No method can promote it to readiness.
final class PairCandidate {
  final String candidateId;
  final String fingerprint;
  final PairIdentity pair;
  final String ruleId;
  final String ruleVersion;
  final String candidateKind;
  final PairCandidateState state;
  final List<PairInputFact> declaredInputs;

  PairCandidate._({
    required this.candidateId,
    required this.fingerprint,
    required this.pair,
    required this.ruleId,
    required this.ruleVersion,
    required this.candidateKind,
    required this.state,
    required List<PairInputFact> declaredInputs,
  }) : declaredInputs = List<PairInputFact>.unmodifiable(declaredInputs);
}

/// Fail-closed result for one direct rule evaluation.
final class PairEvaluation {
  final PairCandidate? candidate;
  final String? blockedReason;

  const PairEvaluation._({
    required this.candidate,
    required this.blockedReason,
  });

  bool get isBlocked => candidate == null;

  factory PairEvaluation.blocked(String reason) {
    _requireNonEmpty(reason, 'reason');
    return PairEvaluation._(candidate: null, blockedReason: reason);
  }

  factory PairEvaluation.candidate(PairCandidate candidate) {
    return PairEvaluation._(candidate: candidate, blockedReason: null);
  }
}

/// Factory-3 mechanics evaluator.
///
/// It has no resolver or bridge parameter, so it can consume only facts bound
/// directly to the declared SOURCE/TARGET endpoints. Extra languages and
/// undeclared product/runtime facts are ignored rather than used as pivots.
abstract final class PairMechanics {
  static PairEvaluation evaluate({
    required PairEndpoint source,
    required PairEndpoint target,
    required PairRule rule,
    required List<PairInputFact> facts,
  }) {
    if (source.role != LanguageRole.source) {
      return PairEvaluation.blocked('source endpoint is not SOURCE role');
    }
    if (target.role != LanguageRole.target) {
      return PairEvaluation.blocked('target endpoint is not TARGET role');
    }

    final pair = PairIdentity(
      sourceLanguageId: source.languageId,
      targetLanguageId: target.languageId,
    );

    if (rule.requiredInputs.isEmpty) {
      return PairEvaluation.blocked(
        'no declared pair inputs; non-pair differences cannot emit a candidate',
      );
    }

    final requirements = List<PairRuleInputRequirement>.from(
      rule.requiredInputs,
    )..sort((a, b) => _requirementKey(a).compareTo(_requirementKey(b)));

    final selected = <PairInputFact>[];

    for (final requirement in requirements) {
      final expectedLanguageId = switch (requirement.role) {
        LanguageRole.source => source.languageId,
        LanguageRole.target => target.languageId,
        LanguageRole.user => '',
      };

      final matches = facts
          .where(
            (fact) =>
                fact.languageId == expectedLanguageId &&
                fact.role == requirement.role &&
                fact.inputKey == requirement.inputKey,
          )
          .toList(growable: false);

      if (matches.isEmpty) {
        return PairEvaluation.blocked(
          'missing required input ${_requirementKey(requirement)}',
        );
      }
      if (matches.length != 1) {
        return PairEvaluation.blocked(
          'ambiguous required input ${_requirementKey(requirement)}',
        );
      }

      final fact = matches.single;
      if (!_allowsFact(requirement, fact.state)) {
        return PairEvaluation.blocked(
          'required input ${_requirementKey(requirement)} '
          'is fail closed in state ${fact.state.name}',
        );
      }
      selected.add(fact);
    }

    selected.sort((a, b) => _factKey(a).compareTo(_factKey(b)));

    final canonicalParts = <String>[
      'pair-mechanics-candidate-v1',
      pair.stableId,
      _lengthPrefixed(rule.ruleId),
      _lengthPrefixed(rule.ruleVersion),
      _lengthPrefixed(rule.candidateKind),
      for (final fact in selected)
        [
          _lengthPrefixed(fact.languageId),
          _lengthPrefixed(fact.role.wireName),
          _lengthPrefixed(fact.inputKey),
          _lengthPrefixed(fact.state.name),
          _lengthPrefixed(fact.valueFingerprint),
        ].join('|'),
    ];

    final fingerprint = 'hex-v1:${_hexUtf8(canonicalParts.join('\u001f'))}';
    final candidateId = [
      'pair-candidate-v1',
      _hexUtf8(pair.stableId),
      _hexUtf8(rule.ruleId),
      _hexUtf8(rule.ruleVersion),
      _hexUtf8(fingerprint),
    ].join(':');

    return PairEvaluation.candidate(
      PairCandidate._(
        candidateId: candidateId,
        fingerprint: fingerprint,
        pair: pair,
        ruleId: rule.ruleId,
        ruleVersion: rule.ruleVersion,
        candidateKind: rule.candidateKind,
        state: PairCandidateState.derivedCandidate,
        declaredInputs: selected,
      ),
    );
  }

  static bool _allowsFact(
    PairRuleInputRequirement requirement,
    LanguageCapabilityState state,
  ) {
    switch (state) {
      case LanguageCapabilityState.supported:
        return true;
      case LanguageCapabilityState.limited:
        return requirement.acceptsLimited;
      case LanguageCapabilityState.notApplicable:
        return requirement.acceptsNotApplicable;
      case LanguageCapabilityState.unsupported:
      case LanguageCapabilityState.blocked:
      case LanguageCapabilityState.quarantined:
        return false;
    }
  }

  static String _requirementKey(PairRuleInputRequirement requirement) =>
      '${requirement.role.wireName}|${requirement.inputKey}';

  static String _factKey(PairInputFact fact) =>
      '${fact.role.wireName}|${fact.inputKey}|${fact.languageId}';
}

String _lengthPrefixed(String value) {
  final bytes = utf8.encode(value);
  return '${bytes.length}:${_hexBytes(bytes)}';
}

String _hexUtf8(String value) => _hexBytes(utf8.encode(value));

String _hexBytes(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

void _requireNonEmpty(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
}
