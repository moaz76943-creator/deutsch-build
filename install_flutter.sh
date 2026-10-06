#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$ROOT/toolchain.lock"
source "$ROOT/scripts/common.sh"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
FLUTTER_VERSION="$FLUTTER_VERSION"
ANDROID_API="$ANDROID_COMPILE_SDK"
FLUTTER_ROOT="${FLUTTER_ROOT:-$PREFIX/opt/flutter}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
ANDROID_BUILD_TOOLS_VERSION="$ANDROID_BUILD_TOOLS_VERSION"
CMDLINE_TOOLS_VERSION="$CMDLINE_TOOLS_VERSION"
CMDLINE_TOOLS_SHA256="$CMDLINE_TOOLS_SHA256"
LOG_FILE="${LOG_FILE:-$HOME/flutter_install.log}"
TERMUX_HOME="${HOME}"
ARCH=""
JAVA_HOME_DETECTED=""

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
fatal() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

on_error() {
  local line="$1" command="$2" code="$3"
  printf '\nERROR: installation stopped at line %s (exit %s)\nCommand: %s\nLog: %s\n' "$line" "$code" "$command" "$LOG_FILE" >&2
}
trap 'on_error "${LINENO}" "${BASH_COMMAND}" "$?"' ERR

check_architecture() {
  log '[1/7] Checking architecture'
  ARCH="$(uname -m)"
  case "$ARCH" in
    aarch64|arm64) ARCH="aarch64" ;;
    x86_64|amd64) ARCH="x86_64" ;;
    *) fatal "Unsupported architecture: $(uname -m). Expected aarch64 or x86_64." ;;
  esac
  log "Architecture: $ARCH"
}

check_network() {
  log '[2/7] Checking network'
  command -v curl >/dev/null 2>&1 || fatal "curl is required before network checks."
  local url
  for url in https://github.com https://api.github.com https://dl.google.com; do
    if ! curl -fsSIL --connect-timeout 10 --max-time 20 "$url" >/dev/null; then
      fatal "Network check failed for $url. No large download was started."
    fi
  done
}
setup_repositories() {
  log 'Refreshing Termux repositories'
  command -v pkg >/dev/null 2>&1 || fatal "Termux pkg command not found. This script is for Termux."
  local source_file="$PREFIX/etc/apt/sources.list"
  if [[ -f "$source_file" ]]; then
    log "Termux main repository: $(grep -E '^deb .*termux-main' "$source_file" | head -1 || echo 'not detected')"
  else
    warn "Termux main sources.list was not found at $source_file; pkg will use its configured repository state."
  fi
  if ! pkg update; then
    warn "pkg update failed. The repository/mirror may be unreachable or misconfigured."
    if command -v termux-change-repo >/dev/null 2>&1; then
      warn "termux-change-repo is available. Run it interactively to select a working main mirror, then rerun this script."
    else
      warn "termux-change-repo is not installed; install it only if you need interactive mirror repair."
    fi
    fatal "Cannot safely install required packages while Termux repositories are unavailable."
  fi
}

ensure_required_commands() {
  local missing=()
  local cmd
  for cmd in curl git unzip tar gzip xz zip python; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if ((${#missing[@]})); then
    log "Installing required utilities: ${missing[*]}"
    pkg install -y "${missing[@]}" || fatal "Failed to install required utilities: ${missing[*]}"
  fi
}

setup_java() {
  log "[3/7] Checking supported Java (17/21); default OpenJDK ${JAVA_MAJOR}"
  local java_ok=false major=''
  if command -v java >/dev/null 2>&1; then
    java -version 2>&1 | head -1
    if command -v javac >/dev/null 2>&1; then javac -version 2>&1 | head -1; fi
    major="$(java -version 2>&1 | awk -F'[".]' '/version/ {print $2; exit}')"
    case "$major" in 17|21) if command -v javac >/dev/null 2>&1; then java_ok=true; fi ;; esac
  fi
  if [[ "$java_ok" != true ]]; then
    log "Java ${JAVA_MAJOR} not active; installing the pinned OpenJDK only if needed"
    pkg install -y "openjdk-${JAVA_MAJOR}" || fatal "Could not install openjdk-${JAVA_MAJOR}."
  fi
  command -v java >/dev/null 2>&1 || fatal "java is still unavailable after OpenJDK setup."
  command -v javac >/dev/null 2>&1 || fatal "javac is still unavailable after OpenJDK setup."
  java -version 2>&1 | head -1
  javac -version 2>&1 | head -1
  local candidate
  candidate="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
  JAVA_HOME_DETECTED="$candidate"
  export JAVA_HOME="$JAVA_HOME_DETECTED"
  export PATH="$JAVA_HOME/bin:$PATH"
  command -v java >/dev/null 2>&1 || fatal "Java ${JAVA_MAJOR} bin directory is not usable: $JAVA_HOME/bin"
  command -v javac >/dev/null 2>&1 || fatal "Java ${JAVA_MAJOR} javac is not usable: $JAVA_HOME/bin/javac"
  major="$(java -version 2>&1 | awk -F'[".]' '/version/ {print $2; exit}')"
  case "$major" in
    17|21) log "Using supported Java $major" ;;
    *) fatal "Supported Java majors are 17 and 21; active Java is $major." ;;
  esac
  log "JAVA_HOME=$JAVA_HOME"
}

download_resumable() {
  local url="$1" file="$2"
  mkdir -p "$(dirname "$file")"
  if [[ -s "$file" ]]; then
    log "Resuming/validating existing download: $file"
    if curl -fL --retry 3 --retry-delay 2 -C - -o "$file" "$url"; then
      :
    elif curl -fsSI --connect-timeout 10 --max-time 20 "$url" | grep -qi '^HTTP/.* 416'; then
      log "Server reports HTTP 416; treating existing non-empty file as already complete."
    else
      fatal "Download failed or could not be resumed: $url"
    fi
  else
    log "Downloading: $url"
    curl -fL --retry 3 --retry-delay 2 -C - -o "$file" "$url" || fatal "Download failed: $url"
  fi
  test -s "$file" || fatal "Downloaded file is empty: $file"
}


setup_flutter() {
  log '[4/7] Installing/checking Flutter'
  [[ "$ARCH" == "aarch64" ]] || fatal "The pinned Termux Flutter host package supports aarch64 only; found $ARCH."

  local flutter_bin="$FLUTTER_ROOT/bin/flutter"
  if [[ -x "$flutter_bin" ]]; then
    export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$PATH"
    if flutter --version 2>&1 | head -1 | grep -Fq "Flutter $FLUTTER_VERSION"; then
      log "Compatible Termux Flutter already exists at $FLUTTER_ROOT; preserving it."
      flutter --version
      dart --version
      return
    fi
    fatal "Flutter exists at $FLUTTER_ROOT but does not report pinned version $FLUTTER_VERSION; refusing to overwrite it."
  fi

  local release_api metadata archive asset_url expected_digest
  release_api="https://api.github.com/repos/${TERMUX_FLUTTER_REPOSITORY}/releases/tags/${TERMUX_FLUTTER_RELEASE_TAG}"
  metadata="$HOME/.cache/flutter/${TERMUX_FLUTTER_RELEASE_TAG}.json"
  archive="$HOME/.cache/flutter/$TERMUX_FLUTTER_DEB"
  asset_url="https://github.com/${TERMUX_FLUTTER_REPOSITORY}/releases/download/${TERMUX_FLUTTER_RELEASE_TAG}/${TERMUX_FLUTTER_DEB}"
  mkdir -p "$HOME/.cache/flutter"

  if [[ -n "${TERMUX_FLUTTER_DEB_PATH:-}" ]]; then
    archive="$TERMUX_FLUTTER_DEB_PATH"
    expected_digest="${TERMUX_FLUTTER_DEB_SHA256:-}"
    [[ -f "$archive" && "$expected_digest" =~ ^[0-9a-fA-F]{64}$ ]] || fatal "A local native Flutter package requires its trusted SHA256."
    printf '%s  %s\n' "$expected_digest" "$archive" | sha256sum -c - || fatal "Local native Flutter package SHA256 mismatch."
  else
    log "Fetching immutable GitHub Release metadata: $TERMUX_FLUTTER_RELEASE_TAG"
    curl -fL --retry 3 --retry-delay 2 -o "$metadata" "$release_api" || fatal "Pinned Termux Flutter release is unavailable. Reuse the installed matching SDK, or supply a trusted TERMUX_FLUTTER_DEB_PATH and TERMUX_FLUTTER_DEB_SHA256; no unverified SDK will be installed."
    expected_digest="$(python - "$metadata" "$TERMUX_FLUTTER_DEB" <<'PY'
import json
import re
import sys

metadata_path, asset_name = sys.argv[1], sys.argv[2]
with open(metadata_path, encoding='utf-8') as handle:
    release = json.load(handle)

matches = [asset for asset in release.get('assets', []) if asset.get('name') == asset_name]
if len(matches) != 1:
    raise SystemExit(f'Expected exactly one release asset named {asset_name!r}; found {len(matches)}')

digest = matches[0].get('digest') or ''
if not re.fullmatch(r'sha256:[0-9a-fA-F]{64}', digest):
    raise SystemExit(f'Release asset {asset_name!r} does not expose a valid sha256 digest')

print(digest.split(':', 1)[1].lower())
PY
  )" || fatal "Could not resolve a trusted SHA-256 digest for $TERMUX_FLUTTER_DEB."

    if [[ -s "$archive" ]] && printf '%s  %s\n' "$expected_digest" "$archive" | sha256sum -c - >/dev/null 2>&1; then
      log "Verified cached Termux Flutter package: $archive"
    else
      download_resumable "$asset_url" "$archive"
    fi
    printf '%s  %s\n' "$expected_digest" "$archive" | sha256sum -c - || fatal "Termux Flutter package SHA-256 verification failed."

  fi

  log "Installing pinned Termux-native Flutter package: $TERMUX_FLUTTER_DEB"
  if ! dpkg -i "$archive"; then
    log "Resolving declared Termux package dependencies"
    apt --fix-broken install -y || fatal "Could not resolve Termux Flutter package dependencies."
    dpkg -i "$archive" || fatal "Termux Flutter package installation failed after dependency resolution."
  fi

  local post_install="$PREFIX/share/flutter/post_install.sh"
  [[ -f "$post_install" ]] || fatal "Termux Flutter post-install hook is missing: $post_install"
  bash "$post_install" || fatal "Termux Flutter post-install configuration failed."

  FLUTTER_ROOT="$PREFIX/opt/flutter"
  export FLUTTER_ROOT
  if [[ -f "$PREFIX/etc/profile.d/flutter.sh" ]]; then
    # shellcheck disable=SC1090
    source "$PREFIX/etc/profile.d/flutter.sh"
  fi
  export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$PATH"
  command -v flutter >/dev/null 2>&1 || fatal "Flutter is not on PATH after package installation."
  command -v dart >/dev/null 2>&1 || fatal "Dart is not on PATH after package installation."
  flutter --version 2>&1 | head -1 | grep -F "Flutter $FLUTTER_VERSION" >/dev/null || fatal "Installed Flutter does not match pinned version $FLUTTER_VERSION."
  dart --version 2>&1 | grep -F "$DART_VERSION" >/dev/null || fatal "Installed Dart does not match pinned version $DART_VERSION."
  flutter --version
  dart --version
}
discover_android_sdk() {
  if [[ -n "${ANDROID_SDK_ROOT:-}" && -d "$ANDROID_SDK_ROOT" ]]; then
    log "Using configured Android SDK: $ANDROID_SDK_ROOT"
    return
  fi
  local candidates=(
    "$HOME/Android/Sdk"
    "$HOME/Android/sdk"
    "$HOME/android-sdk"
    "$PREFIX/opt/android-sdk"
    "$PREFIX/share/android-sdk"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -d "$candidate/platform-tools" || -d "$candidate/cmdline-tools" || -x "$candidate/cmdline-tools/latest/bin/sdkmanager" ]]; then
      ANDROID_SDK_ROOT="$candidate"
      log "Discovered existing Android SDK: $ANDROID_SDK_ROOT"
      return
    fi
  done
  ANDROID_SDK_ROOT="$HOME/Android/Sdk"
  log "No reusable Android SDK found; using new path: $ANDROID_SDK_ROOT"
}

setup_android_sdk() {
  discover_android_sdk
  log '[5/7] Installing/checking Android SDK'
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
  export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"

  local sdkmanager="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
  if [[ ! -x "$sdkmanager" ]]; then
    local archive="$HOME/.cache/android/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"
    local url="https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"
    download_resumable "$url" "$archive"
    printf '%s  %s\n' "$CMDLINE_TOOLS_SHA256" "$archive" | sha256sum -c - || fatal "Android command-line tools SHA-256 verification failed."
    unzip -tq "$archive" >/dev/null || fatal "Android command-line tools archive is corrupt."
    local staging="$HOME/.cache/android/cmdline-tools-extract-${CMDLINE_TOOLS_VERSION}-$(date +%s)-$$"
    mkdir -p "$staging"
    unzip -q "$archive" -d "$staging"
    [[ -x "$staging/cmdline-tools/bin/sdkmanager" ]] || fatal "sdkmanager was not found in command-line tools archive."
    if [[ -e "$ANDROID_SDK_ROOT/cmdline-tools/latest" ]]; then
      fatal "Android cmdline-tools/latest already exists but sdkmanager was not detected there; refusing to overwrite it."
    fi
    mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools/latest"
    cp -a "$staging/cmdline-tools/." "$ANDROID_SDK_ROOT/cmdline-tools/latest/"
    [[ -x "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]] || fatal "Copied sdkmanager is not executable."
    log "Preserved extraction staging directory: $staging"
  fi

  export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
  command -v sdkmanager >/dev/null 2>&1 || fatal "sdkmanager is unavailable."

  if [[ "$ARCH" == "aarch64" ]]; then
    if ! command -v aapt >/dev/null 2>&1 || ! command -v aapt2 >/dev/null 2>&1; then
      log "Installing native Android packaging tools from the Termux aapt package"
      pkg install -y aapt || fatal "Could not install the Termux aapt package."
    fi
    command -v aapt >/dev/null 2>&1 || fatal "Native Termux aapt is unavailable."
    command -v aapt2 >/dev/null 2>&1 || fatal "Native Termux aapt2 is unavailable."
    aapt version
    aapt2 version
  fi
  if ! command -v adb >/dev/null 2>&1; then
    if pkg install -y android-tools; then
      log "Termux android-tools installed for adb verification."
    else
      warn "android-tools/adb is optional for APK compilation and could not be installed."
    fi
  fi

  # yes exits with SIGPIPE when sdkmanager finishes; inspect sdkmanager itself.
  local license_status
  set +e
  yes | sdkmanager --licenses >/dev/null
  license_status=${PIPESTATUS[1]}
  set -e
  [[ "$license_status" -eq 0 ]] || fatal "Android license acceptance failed."

  local missing_components=()
  [[ -d "$ANDROID_SDK_ROOT/platform-tools" ]] || missing_components+=("platform-tools")
  [[ -d "$ANDROID_SDK_ROOT/platforms/android-${ANDROID_API}" ]] || missing_components+=("platforms;android-${ANDROID_API}")
  [[ -d "$ANDROID_SDK_ROOT/build-tools/${ANDROID_BUILD_TOOLS_VERSION}" ]] || missing_components+=("build-tools;${ANDROID_BUILD_TOOLS_VERSION}")

  if ((${#missing_components[@]})); then
    log "Installing missing Android SDK components only: ${missing_components[*]}"
    sdkmanager "${missing_components[@]}" || fatal "Android SDK component installation failed."
  else
    log "All requested Android SDK components already exist; preserving them without reinstalling."
  fi
  sdkmanager --list >/dev/null || fatal "sdkmanager could not enumerate installed/available components."
  verify_aapt2_platform
  flutter config --android-sdk "$ANDROID_SDK_ROOT"
}

verify_aapt2_platform() {
  [[ "$ARCH" == "aarch64" ]] || return 0

  local platform_jar="$ANDROID_SDK_ROOT/platforms/android-${ANDROID_API}/android.jar"
  [[ -f "$platform_jar" ]] || fatal "Android API ${ANDROID_API} platform jar is missing: $platform_jar"

  local probe_dir probe_status
  probe_dir="$(mktemp -d)"
  cat > "$probe_dir/AndroidManifest.xml" <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.deutschbilarabi.toolchainprobe">
    <uses-sdk android:minSdkVersion="${ANDROID_MIN_SDK}" android:targetSdkVersion="${ANDROID_API}" />
    <application android:label="ToolchainProbe" />
</manifest>
EOF

  set +e
  aapt2 link \
    -I "$platform_jar" \
    --manifest "$probe_dir/AndroidManifest.xml" \
    --min-sdk-version "$ANDROID_MIN_SDK" \
    --target-sdk-version "$ANDROID_API" \
    -o "$probe_dir/api-${ANDROID_API}-probe.apk" >/dev/null 2>&1
  probe_status=$?
  set -e

  python3 - "$probe_dir" <<'PY'
from pathlib import Path
import shutil
import sys

shutil.rmtree(Path(sys.argv[1]), ignore_errors=True)
PY

  [[ "$probe_status" -eq 0 ]] || fatal "Native AAPT2 cannot link against Android API ${ANDROID_API}; refusing to start a long Flutter build."
  log "AAPT2 API ${ANDROID_API} preflight: PASS"
}

setup_environment() {
  log '[6/7] Configuring persistent environment'
  local rc="$HOME/.bashrc"
  touch "$rc"
  local marker='# Deutsch بالعربي Flutter/Android toolchain'
  if ! grep -Fq "$marker" "$rc"; then
    cat >> "$rc" <<EOF

$marker
export JAVA_HOME="$JAVA_HOME"
export FLUTTER_ROOT="$FLUTTER_ROOT"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export PATH="\$FLUTTER_ROOT/bin:\$FLUTTER_ROOT/bin/cache/dart-sdk/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH"
EOF
  fi
}

verify_flutter() {
  log '[7/7] Running final verification'
  command -v flutter >/dev/null 2>&1 || fatal "flutter command not found."
  command -v dart >/dev/null 2>&1 || fatal "dart command not found."
  java -version 2>&1 | head -1
  javac -version 2>&1 | head -1
  flutter --version
  dart --version
  if ! flutter doctor -v; then
    warn "flutter doctor reported errors/warnings. The summary below distinguishes environment availability from optional tooling."
  fi
}

verify_android() {
  command -v sdkmanager >/dev/null 2>&1 || fatal "sdkmanager command not found."
  test -d "$ANDROID_SDK_ROOT/platforms/android-${ANDROID_API}" || fatal "Android platform android-${ANDROID_API} is missing."
  test -d "$ANDROID_SDK_ROOT/platform-tools" || fatal "Android platform-tools are missing."
  if [[ "$ARCH" == "aarch64" ]] && ! command -v aapt2 >/dev/null 2>&1; then
    warn "No native ARM64 aapt2 detected. Android build script will not claim a successful APK build until it is available."
  fi
}

print_summary() {
  printf '\n================ TOOLCHAIN SUMMARY ================\n'
  printf 'Flutter version: '; flutter --version | head -1
  printf 'Dart version: '; dart --version 2>&1 | head -1
  printf 'Java version: '; java -version 2>&1 | head -1
  printf 'Android SDK: %s\n' "$ANDROID_SDK_ROOT"
  printf 'Android API: %s\n' "$ANDROID_API"
  printf 'Architecture: %s\n' "$ARCH"
  printf 'JAVA_HOME: %s\n' "$JAVA_HOME"
  printf 'Android licenses: verified via sdkmanager\n'
  printf 'Log: %s\n' "$LOG_FILE"
  printf '===================================================\n'
}

main() {
  exec > >(tee -a "$LOG_FILE") 2>&1
  check_architecture
  check_disk_space "$HOME"
  setup_repositories
  ensure_required_commands
  check_network
  setup_java
  setup_flutter
  setup_android_sdk
  setup_environment
  verify_flutter
  verify_android
  print_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
