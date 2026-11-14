# Test Coverage Matrix — Constitutional Requirements

| Constitutional requirement | Test surface | Status | Evidence |
|---|---|---|---|
| 100 registered languages, Hebrew excluded | `content-factory/catalog/validate_registry.py` | PASS | exit 0, 100 langs, he/iw absent |
| Directed pair isolation (A→B != B→A) | `content-factory/standards/directed_pairs/*` | PARTIAL | standards exist; app-side pair tests not run (no Flutter SDK) |
| Offline boot (no INTERNET) | `tests/test_final_release_hardening_contract.py`, manifest | PASS (manifest) / test-rot | QAD-006 |
| SQLite + SRS + migrations + recovery | `tests/quality_gate/test_task6c_*`, `test/core/srs/*` | NOT_RUN (Dart) / FAIL (Python contract) | FileNotFound (learner_state_database.dart) |
| Pack download + SHA-256 | `tools/qa_audit/qa_audit_manifest_packs.py` | PASS (manifest) | 100/100 sha+size |
| 100 languages + bidi/scripts | registry + pack headers | PASS (registry) / W (content depth 0) | |
| Language/pair switching + stale results | Dart UI tests | NOT_RUN | no Flutter SDK |
| Audio/search/images/memory | Dart tests | NOT_RUN | no Flutter SDK |
| Android emulator/device | integration_test/ | NOT_RUN | no emulator/SDK |
| Performance/resources | `tests/test_v139_performance_static.py` etc. | PARTIAL | in 209 failures |
| Security review of integrated changes | `tests/quality_gate/test_security_audit_decision.py` | FAIL (fail-open) | QAD-005 |
| Regression tests for proven defects | `tools/qa_audit/regression_tests/` | PASS (reproduces) | exit 1 confirms defect |

## Summary
- Automated (Python, local): 1175 pass / 209 fail / 12 skip.
- Automated (Dart): NOT_RUN — no Flutter SDK in environment.
- Manual/static: registry PASS, manifest SHA PASS, 100 orphan false-metadata FAIL.
EOF
echo done