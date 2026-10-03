/// Independent language roles used by multilingual contracts.
///
/// A single language may occupy more than one role. In particular USER and
/// SOURCE may intentionally be the same language while their evidence remains
/// scoped to the distinct role.
enum LanguageRole {
  user,
  source,
  target;

  String get wireName {
    switch (this) {
      case LanguageRole.user:
        return 'USER_LANGUAGE';
      case LanguageRole.source:
        return 'SOURCE_LANGUAGE';
      case LanguageRole.target:
        return 'TARGET_LANGUAGE';
    }
  }
}

/// Technical eligibility for one language to occupy one role.
///
/// Eligibility is independent from lifecycle/readiness. UNKNOWN and INELIGIBLE
/// fail closed and cannot be used to construct a role lifecycle/status record.
enum LanguageRoleEligibilityState {
  eligible,
  ineligible,
  unknown;

  bool get allowsRole => this == LanguageRoleEligibilityState.eligible;

  bool get isFailClosed => !allowsRole;
}

/// Explicit eligibility declaration for exactly one language + role.
final class LanguageRoleEligibilityRecord {
  final String languageId;
  final LanguageRole role;
  final LanguageRoleEligibilityState state;
  final String? reason;

  LanguageRoleEligibilityRecord({
    required this.languageId,
    required this.role,
    required this.state,
    this.reason,
  }) {
    _requireNonEmpty(languageId, 'languageId');
    if (state == LanguageRoleEligibilityState.ineligible &&
        (reason == null || reason!.trim().isEmpty)) {
      throw ArgumentError('INELIGIBLE role requires an explicit reason');
    }
  }

  bool get allowsRole => state.allowsRole;

  bool get isFailClosed => state.isFailClosed;

  Map<String, Object?> toMap() => <String, Object?>{
        'languageId': languageId,
        'role': role.wireName,
        'state': state.name,
        'reason': reason,
      };
}

void _requireNonEmpty(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
}
