import 'language_role.dart';

/// Universal capability vocabulary. Language-specific rules live behind these
/// declarations rather than in Shared Core.
enum LanguageCapability {
  learnerFacingLocalization,
  normalization,
  segmentation,
  grammar,
  morphology,
  vocabularyContent,
  writing,
  searchIndexing,
  textToSpeech,
  speechToText,
  pronunciation,
  conversation,
  assessment,
  offlineContent,
  pairIntelligence,
  scriptOrthography,
  transliteration,
  listening,
  speaking,
  lexicalEnrichment,
  levelMapping,
  providerDependentBehavior,
}

/// Explicit operational capability state.
///
/// Missing or unknown declarations are not encoded as an operational state.
/// They fail closed at the later Registry/consumer lookup boundary.
enum LanguageCapabilityState {
  supported,
  limited,
  unsupported,
  notApplicable,
  blocked,
  quarantined,
}

extension LanguageCapabilityStatePolicy on LanguageCapabilityState {
  /// Whether a caller requiring this capability may use it.
  ///
  /// LIMITED remains fail-closed unless that caller explicitly accepts the
  /// declared limitation. Every other non-supported state is fail-closed.
  bool allowsRequiredUse({bool acceptLimited = false}) {
    switch (this) {
      case LanguageCapabilityState.supported:
        return true;
      case LanguageCapabilityState.limited:
        return acceptLimited;
      case LanguageCapabilityState.unsupported:
      case LanguageCapabilityState.notApplicable:
      case LanguageCapabilityState.blocked:
      case LanguageCapabilityState.quarantined:
        return false;
    }
  }

  bool get isFailClosed => !allowsRequiredUse();
}

/// One role-scoped capability declaration bound to an exact snapshot.
final class LanguageCapabilityStatus {
  final LanguageRole role;
  final LanguageCapability capability;
  final LanguageCapabilityState state;
  final String snapshotVersion;
  final String snapshotHash;
  final String? limitation;
  final String? justification;

  LanguageCapabilityStatus({
    required this.role,
    required this.capability,
    required this.state,
    required this.snapshotVersion,
    required this.snapshotHash,
    this.limitation,
    this.justification,
  }) {
    _requireNonEmpty(snapshotVersion, 'snapshotVersion');
    _requireNonEmpty(snapshotHash, 'snapshotHash');
    if (state == LanguageCapabilityState.limited &&
        (limitation == null || limitation!.trim().isEmpty)) {
      throw ArgumentError('LIMITED capability state requires a limitation');
    }
    switch (state) {
      case LanguageCapabilityState.notApplicable:
        if (justification == null || justification!.trim().isEmpty) {
          throw ArgumentError(
            'NOT_APPLICABLE capability state requires a justification',
          );
        }
        break;
      default:
        break;
    }
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'role': role.wireName,
        'capability': capability.name,
        'state': state.name,
        'snapshotVersion': snapshotVersion,
        'snapshotHash': snapshotHash,
        'limitation': limitation,
        'justification': justification,
      };

  static void _requireNonEmpty(String value, String field) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
  }
}
