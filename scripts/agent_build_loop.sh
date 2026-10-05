#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain
cd "$ROOT"

MAX_ATTEMPTS=${MAX_ATTEMPTS:-4}
AUTO_FIX_CMD="${AUTO_FIX_CMD:-}"
RUN_RUNTIME_PROBE="${RUN_RUNTIME_PROBE:-auto}"
AGENT_LOG_ROOT="${AGENT_LOG_ROOT:-$ROOT/build/agent-loop}"

[[ "$MAX_ATTEMPTS" =~ ^[0-9]+$ ]] || fatal "MAX_ATTEMPTS must be an integer"
if [[ "$MAX_ATTEMPTS" -lt 1 || "$MAX_ATTEMPTS" -gt 5 ]]; then
  fatal "MAX_ATTEMPTS must be between 1 and 5"
fi
case "$RUN_RUNTIME_PROBE" in 0|1|auto) ;; *) fatal "RUN_RUNTIME_PROBE must be 0, 1, or auto";; esac

command -v git >/dev/null 2>&1 || fatal "git is required"
command -v python3 >/dev/null 2>&1 || fatal "python3 is required"
[[ -z "$(git status --porcelain)" ]] || fatal "Agent loop requires a clean git worktree before it can mutate source"

SESSION_ID="$(date +%Y%m%d_%H%M%S)_$$"
SESSION_DIR="$AGENT_LOG_ROOT/$SESSION_ID"
mkdir -p "$SESSION_DIR"
START_HEAD="$(git rev-parse HEAD)"
START_BRANCH="$(git branch --show-current)"
[[ -n "$START_BRANCH" ]] || fatal "Agent loop requires a named Git branch"

worktree_fingerprint() {
  python3 - "$ROOT" <<'PY'
from hashlib import sha256
from pathlib import Path
import subprocess
import sys

root = Path(sys.argv[1])
h = sha256()
diff = subprocess.run(
    ["git", "diff", "--binary", "HEAD", "--", "."],
    cwd=root,
    check=True,
    capture_output=True,
).stdout
h.update(diff)
raw = subprocess.run(
    ["git", "ls-files", "--others", "--exclude-standard", "-z"],
    cwd=root,
    check=True,
    capture_output=True,
).stdout
for rel_raw in sorted(item for item in raw.split(b"\0") if item):
    rel = rel_raw.decode("utf-8", errors="surrogateescape")
    h.update(b"\0UNTRACKED\0" + rel_raw)
    path = root / rel
    if path.is_file():
        h.update(path.read_bytes())
print(h.hexdigest())
PY
}

json_value() {
  local file="$1" key="$2"
  python3 - "$file" "$key" <<'PY'
import json
import sys
with open(sys.argv[1], encoding='utf-8') as handle:
    value = json.load(handle)[sys.argv[2]]
if isinstance(value, bool):
    print('true' if value else 'false')
elif isinstance(value, list):
    print('\n'.join(str(item) for item in value))
else:
    print(value)
PY
}

write_prompt() {
  local diagnostic="$1" prompt="$2" attempt="$3" scopes="$4"
  cat > "$prompt" <<EOF
You are performing exactly one bounded repair pass for the DEUTSCH بالعربي Flutter repository.

Repository HEAD at loop start: $START_HEAD
Attempt: $attempt/$MAX_ATTEMPTS
Diagnostic JSON: $diagnostic
Allowed mutable scope for this failure:
$scopes

Mandatory constraints:
- Modify only the allowed mutable scope listed above.
- Never modify .github/, tests/, scripts/, tool/, CI/CD, release automation, or signing material.
- Never delete source files.
- Never run pub upgrade or change dependency versions unless the diagnostic explicitly authorizes dependency work; this loop does not authorize it.
- Preserve Offline-First and do not add INTERNET or other new Android permissions.
- Do not bypass compiler errors, disable tests, or weaken validation.
- When changing a Dart class or function, replace the complete affected block cleanly; do not leave duplicate definitions.
- Make one minimal root-cause fix, then exit. Do not commit, push, merge, or create a PR.

Read the diagnostic file, inspect the implicated source, make the minimal fix, and exit so the local loop can rebuild and verify it.
EOF
}

validate_agent_changes() {
  local scopes_file="$1"
  local status_line
  local path
  local allowed

  if git diff --name-status --diff-filter=D | grep -q '^D'; then
    fatal "AI repair attempted to delete a tracked file; automatic loop stopped"
  fi

  while IFS= read -r status_line; do
    [[ -n "$status_line" ]] || continue
    path="${status_line:3}"
    case "$path" in
      .github/*|tests/*|scripts/*|tool/*|codemagic.yaml|pubspec.lock)
        fatal "AI repair touched protected path: $path"
        ;;
    esac
    allowed=0
    while IFS= read -r scope; do
      [[ -n "$scope" ]] || continue
      if [[ "$scope" == */ && "$path" == "$scope"* ]]; then allowed=1; break; fi
      if [[ "$path" == "$scope" ]]; then allowed=1; break; fi
    done < "$scopes_file"
    [[ "$allowed" -eq 1 ]] || fatal "AI repair touched path outside diagnostic scope: $path"
  done < <(git status --porcelain)
}

run_runtime_probe_if_requested() {
  local attempt_dir="$1"
  local apk="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"
  case "$RUN_RUNTIME_PROBE" in
    0) return 0 ;;
    auto)
      if ! command -v adb >/dev/null 2>&1; then
        log SKIP "Runtime probe: adb unavailable"
        return 0
      fi
      set +e
      "$ROOT/scripts/runtime_probe.sh" "$apk" "$attempt_dir/runtime"
      local status=$?
      set -e
      if [[ "$status" -eq 2 ]]; then
        log SKIP "Runtime probe unavailable; build remains valid"
        return 0
      fi
      return "$status"
      ;;
    1)
      "$ROOT/scripts/runtime_probe.sh" "$apk" "$attempt_dir/runtime"
      ;;
  esac
}

log CHECK "Bounded local self-healing build loop"
log CHECK "HEAD $START_HEAD / max attempts $MAX_ATTEMPTS"

for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
  ATTEMPT_DIR="$SESSION_DIR/attempt_$attempt"
  mkdir -p "$ATTEMPT_DIR"
  BUILD_LOG="$ATTEMPT_DIR/build.log"
  DIAGNOSTIC="$ATTEMPT_DIR/diagnostic.json"
  PROMPT_FILE="$ATTEMPT_DIR/repair_prompt.txt"
  SCOPES_FILE="$ATTEMPT_DIR/allowed_scopes.txt"

  log BUILD "Attempt $attempt/$MAX_ATTEMPTS — Termux fast debug APK"
  set +e
  "$ROOT/build_deutsch.sh" --fast 2>&1 | tee "$BUILD_LOG"
  BUILD_STATUS=${PIPESTATUS[0]}
  set -e

  if [[ "$BUILD_STATUS" -eq 0 ]]; then
    set +e
    run_runtime_probe_if_requested "$ATTEMPT_DIR"
    RUNTIME_STATUS=$?
    set -e
    if [[ "$RUNTIME_STATUS" -eq 0 ]]; then
      printf 'status=PASS\nhead=%s\nattempt=%s\n' "$START_HEAD" "$attempt" > "$SESSION_DIR/result.txt"
      log OK "SELF-HEALING LOOP PASS"
      printf 'Logs: %s\nAPK: %s\n' "$SESSION_DIR" "$ROOT/build/app/outputs/flutter-apk/app-debug.apk"
      exit 0
    fi
    RUNTIME_LOG="$ATTEMPT_DIR/runtime/logcat.txt"
    if [[ -f "$RUNTIME_LOG" ]]; then
      BUILD_LOG="$RUNTIME_LOG"
    else
      printf 'Runtime probe failed with exit %s\n' "$RUNTIME_STATUS" >> "$BUILD_LOG"
    fi
  fi

  python3 "$ROOT/tool/error_classifier.py" --log "$BUILD_LOG" --output "$DIAGNOSTIC"
  CATEGORY="$(json_value "$DIAGNOSTIC" category)"
  AUTO_RETRY="$(json_value "$DIAGNOSTIC" auto_retry)"
  json_value "$DIAGNOSTIC" allowed_scopes > "$SCOPES_FILE"
  SCOPES="$(cat "$SCOPES_FILE")"
  log CHECK "Failure category: $CATEGORY"

  if [[ "$AUTO_RETRY" == "true" && "$attempt" -lt "$MAX_ATTEMPTS" ]]; then
    log WARN "Transient failure; retrying without source mutation"
    sleep 2
    continue
  fi

  if [[ -z "$SCOPES" ]]; then
    log ERROR "Automatic source mutation is not authorized for category: $CATEGORY"
    printf 'status=STOPPED\ncategory=%s\ndiagnostic=%s\n' "$CATEGORY" "$DIAGNOSTIC" > "$SESSION_DIR/result.txt"
    exit 20
  fi

  write_prompt "$DIAGNOSTIC" "$PROMPT_FILE" "$attempt" "$SCOPES"

  if [[ -z "$AUTO_FIX_CMD" ]]; then
    log ERROR "No AUTO_FIX_CMD is configured; diagnostic package is ready for an AI coding agent"
    printf 'Prompt: %s\nDiagnostic: %s\n' "$PROMPT_FILE" "$DIAGNOSTIC"
    printf 'status=NEEDS_AGENT\ncategory=%s\nprompt=%s\n' "$CATEGORY" "$PROMPT_FILE" > "$SESSION_DIR/result.txt"
    exit 21
  fi

  log CHECK "Running one bounded AI repair pass"
  BEFORE_STATUS="$ATTEMPT_DIR/git_status_before.txt"
  AFTER_STATUS="$ATTEMPT_DIR/git_status_after.txt"
  git status --porcelain > "$BEFORE_STATUS"
  BEFORE_FINGERPRINT="$(worktree_fingerprint)"

  export DEUTSCH_AGENT_PROMPT_FILE="$PROMPT_FILE"
  export DEUTSCH_AGENT_DIAGNOSTIC_FILE="$DIAGNOSTIC"
  export DEUTSCH_AGENT_ALLOWED_SCOPES_FILE="$SCOPES_FILE"
  export DEUTSCH_AGENT_ATTEMPT="$attempt"
  bash -lc "$AUTO_FIX_CMD"

  [[ "$(git rev-parse HEAD)" == "$START_HEAD" ]] || fatal "AI repair changed Git HEAD; commits are forbidden inside the loop"
  [[ "$(git branch --show-current)" == "$START_BRANCH" ]] || fatal "AI repair changed Git branch; branch switching is forbidden"
  git status --porcelain > "$AFTER_STATUS"
  AFTER_FINGERPRINT="$(worktree_fingerprint)"
  if [[ "$BEFORE_FINGERPRINT" == "$AFTER_FINGERPRINT" ]]; then
    fatal "AI repair command completed without producing a new project change"
  fi
  validate_agent_changes "$SCOPES_FILE"
  log OK "AI repair stayed inside allowed scope; rebuilding"
done

printf 'status=FAILED\nhead=%s\nmax_attempts=%s\n' "$START_HEAD" "$MAX_ATTEMPTS" > "$SESSION_DIR/result.txt"
fatal "Maximum repair attempts exhausted. Inspect $SESSION_DIR"
