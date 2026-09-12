#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$ROOT/toolchain.lock"
FLUTTER_VERSION="$FLUTTER_VERSION"
ANDROID_API="$ANDROID_COMPILE_SDK"
FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
ANDROID_BUILD_TOOLS_VERSION="$ANDROID_BUILD_TOOLS_VERSION"
CMDLINE_TOOLS_VERSION="$CMDLINE_TOOLS_VERSION"
CMDLINE_TOOLS_SHA256="$CMDLINE_TOOLS_SHA256"
MIN_FREE_MB="$((MIN_FREE_KB / 1024))"
LOG_FILE="${LOG_FILE:-$HOME/flutter_install.log}"

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
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
  log '[1/8] Checking architecture'
  ARCH="$(uname -m)"
  case "$ARCH" in
    aarch64|arm64) ARCH="aarch64" ;;
    x86_64|amd64) ARCH="x86_64" ;;
    *) fatal "Unsupported architecture: $(uname -m). Expected aarch64 or x86_64." ;;
  esac
  log "Architecture: $ARCH"
}

check_space() {
  log '[2/8] Checking free space'
  local available
  available="$(df -Pk "$HOME" | awk 'NR==2 {print $4}')"
  [[ "$available" =~ ^[0-9]+$ ]] || fatal "Could not determine free disk space for $HOME."
  local available_mb=$((available / 1024))
  log "Free space: ${available_mb} MiB; required safety margin: ${MIN_FREE_MB} MiB"
  (( available_mb >= MIN_FREE_MB )) || fatal "Insufficient free space. Need at least ${MIN_FREE_MB} MiB before large downloads."
}

check_network() {
  log '[3/8] Checking network'
  command -v curl >/dev/null 2>&1 || fatal "curl is required before network checks."
  local url
  for url in https://github.com https://storage.googleapis.com; do
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
  for cmd in curl git unzip tar gzip xz zip; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if ((${#missing[@]})); then
    log "Installing required utilities: ${missing[*]}"
    pkg install -y "${missing[@]}" || fatal "Failed to install required utilities: ${missing[*]}"
  fi
}

setup_java() {
  log "[4/8] Checking Java / OpenJDK ${JAVA_MAJOR}"
  local java_ok=false major=''
  if command -v java >/dev/null 2>&1; then
    java -version 2>&1 | head -1
    if command -v javac >/dev/null 2>&1; then javac -version 2>&1 | head -1; fi
    major="$(java -version 2>&1 | awk -F'[".]' '/version/ {print $2; exit}')"
    [[ "$major" == "$JAVA_MAJOR" ]] && java_ok=true
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
  candidate="$(find "$PREFIX/lib/jvm" -maxdepth 1 -mindepth 1 -type d -name "*${JAVA_MAJOR}*" -print -quit 2>/dev/null || true)"
  [[ -n "$candidate" ]] || candidate="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
  JAVA_HOME_DETECTED="$candidate"
  export JAVA_HOME="$JAVA_HOME_DETECTED"
  export PATH="$JAVA_HOME/bin:$PATH"
  command -v java >/dev/null 2>&1 || fatal "Java ${JAVA_MAJOR} bin directory is not usable: $JAVA_HOME/bin"
  command -v javac >/dev/null 2>&1 || fatal "Java ${JAVA_MAJOR} javac is not usable: $JAVA_HOME/bin/javac"
  major="$(java -version 2>&1 | awk -F'[".]' '/version/ {print $2; exit}')"
  [[ "$major" == "$JAVA_MAJOR" ]] || fatal "Java ${JAVA_MAJOR} was requested but the active java is not Java ${JAVA_MAJOR}."
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
  log '[5/8] Installing/checking Flutter'
  local flutter_bin="$FLUTTER_ROOT/bin/flutter"
  if [[ -x "$flutter_bin" ]]; then
    log "Existing Flutter found at $FLUTTER_ROOT; preserving it."
  else
    local archive suffix url
    if [[ "$ARCH" == "aarch64" ]]; then
      suffix="arm64"
      url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_arm64_${FLUTTER_VERSION}-stable.tar.xz"
    else
      suffix="x64"
      url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    fi
    archive="$HOME/.cache/flutter/flutter_linux_${suffix}_${FLUTTER_VERSION}-stable.tar.xz"
    mkdir -p "$HOME/.cache/flutter"
    download_resumable "$url" "$archive"
    xz -t "$archive" || fatal "Flutter archive failed xz integrity check: $archive"
    if [[ -e "$FLUTTER_ROOT" ]]; then
      fatal "Flutter path $FLUTTER_ROOT exists but is not a valid Flutter installation; refusing to overwrite it."
    fi
    # Extract directly into the parent only when the destination does not exist.
    # This avoids a staging move and never removes a pre-existing installation.
    tar -xJf "$archive" -C "$HOME"
    [[ -x "$FLUTTER_ROOT/bin/flutter" ]] || fatal "Flutter archive did not contain a usable flutter executable."
  fi
  export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$PATH"
  command -v flutter >/dev/null 2>&1 || fatal "Flutter is not on PATH."
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
  log '[6/8] Installing/checking Android SDK'
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

  if [[ "$ARCH" == "aarch64" ]] && ! command -v aapt2 >/dev/null 2>&1; then
    log "Installing required native ARM64 aapt2 for Termux Android builds"
    pkg install -y aapt2 || fatal "Could not install the Termux ARM64 aapt2 package."
  fi
  if [[ "$ARCH" == "aarch64" ]] && command -v aapt2 >/dev/null 2>&1; then
    log "ARM64 native aapt2 detected: $(command -v aapt2)"
  fi
  if ! command -v adb >/dev/null 2>&1; then
    if pkg install -y android-tools; then
      log "Termux android-tools installed for adb verification."
    else
      warn "android-tools/adb is optional for APK compilation and could not be installed."
    fi
  fi

  yes | sdkmanager --licenses >/dev/null || fatal "Android license acceptance failed."

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
  flutter config --android-sdk "$ANDROID_SDK_ROOT"
}

setup_environment() {
  log '[7/8] Configuring persistent environment'
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
  log '[8/8] Running final verification'
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
  check_space
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

main "$@"
