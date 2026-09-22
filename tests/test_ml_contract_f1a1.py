from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
LANG = ROOT / "lib/language"


def _read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def _enum_body(text: str, enum_name: str) -> str:
    match = re.search(rf"enum {re.escape(enum_name)} \{{(.*?)\n\}}", text, re.S)
    assert match, f"missing enum: {enum_name}"
    return match.group(1)


def test_f1_a1_contract_files_exist_and_stay_additive():
    for path in (
        "language_identity.dart",
        "language_role.dart",
        "language_use_context.dart",
        "language_capability.dart",
        "language_role_status.dart",
    ):
        assert (LANG / path).exists(), f"missing F1-A1 contract file: {path}"

    pack = _read("lib/language/language_pack.dart")
    assert "LanguageIdentity get identity" in pack
    # F1-A1 is additive: source ownership is deliberately removed only in F1-A2.
    assert "String get sourceLocale" in pack


def test_identity_and_role_context_are_explicit_without_forcing_user_source_difference():
    identity = _read("lib/language/language_identity.dart")
    roles = _read("lib/language/language_role.dart")
    context = _read("lib/language/language_use_context.dart")

    for token in ("class LanguageIdentity", "languageId", "displayName", "primaryLocale"):
        assert token in identity
    for token in ("user", "source", "target"):
        assert token in roles
    for token in ("userLanguageId", "sourceLanguageId", "targetLanguageId"):
        assert token in context

    # USER == SOURCE is valid by construction; no inequality guard may be introduced.
    forbidden = (
        "userLanguageId != sourceLanguageId",
        "userLanguageId == sourceLanguageId ? throw",
        "sourceLanguageId == userLanguageId ? throw",
    )
    assert all(token not in context for token in forbidden)


def test_role_eligibility_is_separate_from_lifecycle_and_fails_closed():
    roles = _read("lib/language/language_role.dart")
    status = _read("lib/language/language_role_status.dart")

    for token in (
        "enum LanguageRoleEligibilityState",
        "class LanguageRoleEligibilityRecord",
        "eligible",
        "ineligible",
        "unknown",
        "bool get allowsRole",
        "bool get isFailClosed",
        "INELIGIBLE role requires an explicit reason",
    ):
        assert token in roles

    lifecycle = _enum_body(status, "LanguageRoleStatusState")
    for required in (
        "registered",
        "specified",
        "implemented",
        "tested",
        "verified",
        "productionReady",
        "blocked",
        "quarantined",
        "deprecated",
        "superseded",
    ):
        assert required in lifecycle
    assert "unsupported" not in lifecycle
    assert "unknown" not in lifecycle

    for guard in (
        "required LanguageRoleEligibilityRecord eligibility",
        "eligibility must match the record languageId and role",
        "if (!eligibility.allowsRole)",
        "role lifecycle/status requires explicit ELIGIBLE role",
        "'eligibility': eligibility.toMap()",
    ):
        assert guard in status


def test_capability_state_is_role_scoped_and_unknown_declaration_is_not_operational_state():
    capability = _read("lib/language/language_capability.dart")

    for token in (
        "enum LanguageCapability",
        "enum LanguageCapabilityState",
        "LanguageRole role",
        "learnerFacingLocalization",
        "supported",
        "limited",
        "unsupported",
        "notApplicable",
        "blocked",
        "quarantined",
    ):
        assert token in capability

    states = _enum_body(capability, "LanguageCapabilityState")
    assert "unknown" not in states

    for guard in (
        "Missing or unknown declarations are not encoded as an operational state.",
        "case LanguageCapabilityState.unsupported:",
        "case LanguageCapabilityState.notApplicable:",
        "case LanguageCapabilityState.blocked:",
        "case LanguageCapabilityState.quarantined:",
        "return false;",
    ):
        assert guard in capability


def test_not_applicable_capability_requires_explicit_justification():
    capability = _read("lib/language/language_capability.dart")

    for token in (
        "final String? justification;",
        "case LanguageCapabilityState.notApplicable:",
        "NOT_APPLICABLE capability state requires a justification",
        "'justification': justification",
    ):
        assert token in capability


def test_role_status_binds_exact_role_scoped_evidence_without_aggregate_readiness():
    status = _read("lib/language/language_role_status.dart")

    for token in (
        "class ArtifactEvidenceCoordinate",
        "class LanguageRoleEvidenceBinding",
        "class LanguageRoleStatusRecord",
        "languageId",
        "LanguageRole role",
        "universalContractVersion",
        "universalContractHash",
        "manifestStaticFingerprint",
        "capabilitySnapshotVersion",
        "capabilitySnapshotHash",
        "consumedArtifactCoordinates",
        "compatibilityPolicyVersion",
        "compatibilityPolicyHash",
        "readinessValidatorFingerprint",
        "readinessEvidenceRef",
    ):
        assert token in status

    # The record is per language + role. Deployment/aggregate authority belongs elsewhere.
    for forbidden in (
        "deploymentReady",
        "aggregateReadiness",
        "overallReadiness",
        "allRolesReady",
    ):
        assert forbidden not in status


def test_german_pack_exposes_stable_identity_and_preserves_legacy_parity():
    german = _read("lib/language/german/german_language_pack.dart")

    assert "LanguageIdentity get identity" in german
    for value in ("'de'", "'German'", "'de-DE'", "'ar'"):
        assert value in german

    # Existing observable getters remain for backwards compatibility in F1-A1.
    for getter in (
        "String get languageCode",
        "String get displayName",
        "String get targetLocale",
        "String get sourceLocale",
    ):
        assert getter in german
