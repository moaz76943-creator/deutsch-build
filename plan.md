1. **Fix errors in python tests**:
   - `test_build_pipeline.py`: Fixed `run_with_retry` usage to `with_retry`.
   - `test_build_reliability.py`: Replace `run_pub_get_with_retry` with `with_retry flutter pub get --enforce-lockfile`.
   - `test_pipeline.py`: Fix expected exit code for signing error test (to 12) and simulated `with_retry` process failure (needs `temporary failure` string to properly trigger retries).
2. **Update shell scripts error codes**:
   - Update `scripts/common.sh` to match the expected failure codes in `test_build_system.py`
     - `ERR_ENV` = 10
     - `ERR_COMPILE` = 11
     - `ERR_SIGNING` = 12
     - `ERR_DEPENDENCY` = 13
     - `ERR_ARTIFACT` = 16
   - Add legacy variables mapping to new error names:
     - `ERR_COMP` = `ERR_COMPILE`
     - `ERR_DEP` = `ERR_DEPENDENCY`
     - `ERR_SIGN` = `ERR_SIGNING`
3. **Fix secret redaction in shell script**:
   - Update `redact_secrets` in `scripts/common.sh` to correctly match output and expectation in `test_build_pipeline.py`.
     - Output should have `<REDACTED>` and `<REDACTED_PEM>` instead of `[REDACTED]` and `[REDACTED_PEM]`.
4. **Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done.**
   - Run tests `bash -n scripts/build.sh`, `bash -n scripts/build_guard.sh`, `bash -n scripts/local-release.sh`, `bash -n scripts/termux_release.sh`, `bash -n scripts/signing_guard.sh`.
   - Run `python3 -m unittest discover -s scripts -p 'test_*.py' -v`.
   - Run `git diff --check`.
5. **Submit the PR**:
   - `git checkout -b staging/v2-full-platform` (or similar branch name for submission).
   - Commit with `git commit -a -m "Fix termux build and local quality pipeline [skip ci]"`
   - Create the PR: `gh pr create --title "Fix termux build and local quality pipeline" --body "Deterministic failure handling and robust preflight checks with correct error codes."`
