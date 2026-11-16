1. **Update `scripts/test_build_pipeline.py`**:
   - In `test_redact_secrets`, change expected redacted strings from `<REDACTED>` to `[REDACTED]`.
   - In `test_run_with_retry_transient_error`, change the `run_with_retry` call to `with_retry`.
2. **Update `scripts/test_build_reliability.py`**:
   - Change `run_pub_get_with_retry` to `with_retry flutter pub get --enforce-lockfile` across the test methods to match the implementation in `common.sh`.
3. **Update `scripts/test_build_system.py`**:
   - Update variable names to match `common.sh` exports (`$ERR_COMP`, `$ERR_SIGN`, `$ERR_DEP`).
   - Update the expected exit codes (`ERR_COMP` to 12, `ERR_SIGN` to 13, `ERR_DEP` to 11).
4. **Update `scripts/test_pipeline.py`**:
   - In `test_with_retry`, add an output like `echo "network error"` to the mock `target.sh` so that it matches the transient error pattern in `common.sh`.
5. **Run all tests** to ensure they pass with these corrections.
6. **Pre-commit step**: Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done (by calling `pre_commit_instructions`).
7. **Submit the change**: Staging files, commit with `[skip ci]`, and push to `staging/v2-full-platform` without creating a PR.
