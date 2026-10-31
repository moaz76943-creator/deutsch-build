#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APK="${1:-$ROOT/build/app/outputs/flutter-apk/app-debug.apk}"
OUT_DIR="${2:-$ROOT/build/agent-loop/runtime}"
PACKAGE="com.deutschbilarabi.app"
PROBE_SECONDS="${RUNTIME_PROBE_SECONDS:-8}"
ADB_SERIAL="${ADB_SERIAL:-}"

log() { printf '[RUNTIME] %s\n' "$*"; }
fatal() { printf '[RUNTIME][ERROR] %s\n' "$*" >&2; exit 1; }
skip() { printf '[RUNTIME][SKIP] %s\n' "$*" >&2; exit 2; }

[[ -f "$APK" && -s "$APK" ]] || fatal "APK is missing or empty: $APK"
command -v adb >/dev/null 2>&1 || skip "adb is unavailable"
[[ "$PROBE_SECONDS" =~ ^[0-9]+$ ]] || fatal "RUNTIME_PROBE_SECONDS must be an integer"
mkdir -p "$OUT_DIR"

ADB=(adb)
if [[ -n "$ADB_SERIAL" ]]; then
  ADB+=( -s "$ADB_SERIAL" )
fi

if [[ -z "$ADB_SERIAL" ]]; then
  mapfile -t DEVICES < <(adb devices | awk 'NR>1 && $2=="device" {print $1}')
  [[ "${#DEVICES[@]}" -gt 0 ]] || skip "no authorized adb device is connected"
  [[ "${#DEVICES[@]}" -eq 1 ]] || skip "multiple adb devices are connected; set ADB_SERIAL"
  ADB=(adb -s "${DEVICES[0]}")
fi

LOG_FILE="$OUT_DIR/logcat.txt"
START_FILE="$OUT_DIR/start.txt"

log "Installing debug APK"
"${ADB[@]}" install -r -t "$APK" >/dev/null

COMPONENT="$(
  "${ADB[@]}" shell cmd package resolve-activity --brief \
    -a android.intent.action.MAIN \
    -c android.intent.category.LAUNCHER \
    "$PACKAGE" 2>/dev/null | tr -d '\r' | tail -n 1
)"
[[ "$COMPONENT" == */* ]] || fatal "launcher activity could not be resolved for $PACKAGE"

"${ADB[@]}" logcat -c
"${ADB[@]}" shell am force-stop "$PACKAGE"
log "Launching $COMPONENT"
"${ADB[@]}" shell am start -W -n "$COMPONENT" | tee "$START_FILE" >/dev/null

sleep "$PROBE_SECONDS"
PID="$("${ADB[@]}" shell pidof "$PACKAGE" 2>/dev/null | tr -d '\r' | awk '{print $1}')"
[[ -n "$PID" ]] || {
  "${ADB[@]}" logcat -d -v threadtime > "$LOG_FILE" || true
  fatal "application process is not alive after startup"
}

if "${ADB[@]}" logcat --help 2>&1 | grep -q -- '--pid'; then
  "${ADB[@]}" logcat -d --pid="$PID" -v threadtime > "$LOG_FILE" || true
else
  "${ADB[@]}" logcat -d -v threadtime > "$LOG_FILE" || true
fi

if grep -Eiq "FATAL EXCEPTION|Fatal signal|ANR in ${PACKAGE}|Process: ${PACKAGE}" "$LOG_FILE"; then
  fatal "runtime crash signature detected; log: $LOG_FILE"
fi

log "PASS package=$PACKAGE pid=$PID log=$LOG_FILE"
