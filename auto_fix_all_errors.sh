#!/usr/bin/env bash
# Fail closed. The previous script overwrote lib/services/language_pack_manager.dart
# with a short stub, patched SRS methods to return null, committed everything,
# and pushed staging. That replaces real features and can drop learner-facing behavior.
set -euo pipefail

echo "auto_fix_all_errors.sh refuses to edit the tree."
echo "Fix the failing source and its test. Do not stub LanguagePackManager or SRS."
exit 1
