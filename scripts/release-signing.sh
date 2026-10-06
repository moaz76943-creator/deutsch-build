#!/usr/bin/env bash
# Source this file; never trace signing credentials, even with bash -x.
set +x

prepare_release_signing() {
  # The Python helper validates the key and persists private credentials only
  # under ~/.gradle/gradle.properties (0600). It never prints secret exports.
  python3 "$ROOT/tool/release_signing.py" --prepare
}

check_release_signing() {
  python3 "$ROOT/tool/release_signing.py"
}
