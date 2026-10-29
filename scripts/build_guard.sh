#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain

check_version() {
  local label="$1" expected="$2" actual="$3"
<<<<<<< HEAD
<<<<<<< HEAD
  [[ "$actual" == *"$expected"* ]] || fatal --code "$ERR_ENV" "$label mismatch. Expected: $expected Found: $actual"
=======
  [[ "$actual" == *"$expected"* ]] || fatal "$ERR_ENV" "$label mismatch. Expected: $expected Found: $actual"
>>>>>>> pr-61
=======
  [[ "$actual" == *"$expected"* ]] || fatal "$label mismatch. Expected: $expected Found: $actual" "$EXIT_ENV"
>>>>>>> pr-188
  log OK "$label $expected"
}

log CHECK "Deutsch بالعربي Build Guard"
cd "$ROOT"

<<<<<<< HEAD
<<<<<<< HEAD
[[ "$(uname -m)" =~ ^(aarch64|arm64|x86_64|amd64)$ ]] || fatal --code "$ERR_ENV" "Unsupported architecture: $(uname -m)"
=======
[[ "$(uname -m)" =~ ^(aarch64|arm64|x86_64|amd64)$ ]] || fatal "$ERR_ENV" "Unsupported architecture: $(uname -m)"
>>>>>>> pr-61
=======
[[ "$(uname -m)" =~ ^(aarch64|arm64|x86_64|amd64)$ ]] || fatal "Unsupported architecture: $(uname -m)" "$EXIT_ENV"
>>>>>>> pr-188
ARCH="$(uname -m)"
log OK "Architecture $ARCH"

for required in pubspec.yaml pubspec.lock lib android android/app/build.gradle android/settings.gradle android/gradlew android/gradle/wrapper/gradle-wrapper.properties; do
<<<<<<< HEAD
<<<<<<< HEAD
  [[ -e "$required" ]] || fatal --code "$ERR_ENV" "Required project file/directory is missing: $required"
done

command -v flutter >/dev/null 2>&1 || fatal --code "$ERR_ENV" "Flutter is not in PATH"
command -v dart >/dev/null 2>&1 || fatal --code "$ERR_ENV" "Dart is not in PATH"
command -v java >/dev/null 2>&1 || fatal --code "$ERR_ENV" "Java is not in PATH"
command -v javac >/dev/null 2>&1 || fatal --code "$ERR_ENV" "A full JDK is required; javac is not in PATH (a Java runtime alone cannot build Android)"
=======
  [[ -e "$required" ]] || fatal "$ERR_ENV" "Required project file/directory is missing: $required"
done

command -v flutter >/dev/null 2>&1 || fatal "$ERR_ENV" "Flutter is not in PATH"
command -v dart >/dev/null 2>&1 || fatal "$ERR_ENV" "Dart is not in PATH"
command -v java >/dev/null 2>&1 || fatal "$ERR_ENV" "Java is not in PATH"
command -v javac >/dev/null 2>&1 || fatal "$ERR_ENV" "A full JDK is required; javac is not in PATH (a Java runtime alone cannot build Android)"
>>>>>>> pr-61
=======
  [[ -e "$required" ]] || fatal "Required project file/directory is missing: $required" "$EXIT_ENV"
done

command -v flutter >/dev/null 2>&1 || fatal "Flutter is not in PATH" "$EXIT_ENV"
command -v dart >/dev/null 2>&1 || fatal "Dart is not in PATH" "$EXIT_ENV"
command -v java >/dev/null 2>&1 || fatal "Java is not in PATH" "$EXIT_ENV"
command -v javac >/dev/null 2>&1 || fatal "A full JDK is required; javac is not in PATH (a Java runtime alone cannot build Android)" "$EXIT_ENV"
>>>>>>> pr-188
FLUTTER_BIN="$(readlink -f "$(command -v flutter)")"
DART_BIN="$(readlink -f "$(command -v dart)")"
FLUTTER_ROOT="$(cd "$(dirname "$FLUTTER_BIN")/.." && pwd)"
DART_ROOT="$(cd "$(dirname "$DART_BIN")/.." && pwd)"
<<<<<<< HEAD
<<<<<<< HEAD
case "$DART_ROOT" in "$FLUTTER_ROOT"|"$FLUTTER_ROOT"/*) ;; *) fatal --code "$ERR_ENV" "Dart is not from the selected Flutter toolchain: $DART_ROOT";; esac
[[ ":$PATH:" == *":$(dirname "$(command -v flutter)"):"* ]] || fatal --code "$ERR_ENV" "Flutter bin directory is not present in PATH"
=======
case "$DART_ROOT" in "$FLUTTER_ROOT"|"$FLUTTER_ROOT"/*) ;; *) fatal "$ERR_ENV" "Dart is not from the selected Flutter toolchain: $DART_ROOT";; esac
[[ ":$PATH:" == *":$(dirname "$(command -v flutter)"):"* ]] || fatal "$ERR_ENV" "Flutter bin directory is not present in PATH"
>>>>>>> pr-61
=======
case "$DART_ROOT" in "$FLUTTER_ROOT"|"$FLUTTER_ROOT"/*) ;; *) fatal "Dart is not from the selected Flutter toolchain: $DART_ROOT" "$EXIT_ENV";; esac
[[ ":$PATH:" == *":$(dirname "$(command -v flutter)"):"* ]] || fatal "Flutter bin directory is not present in PATH" "$EXIT_ENV"
>>>>>>> pr-188
check_version "Flutter" "$FLUTTER_VERSION" "$(flutter --version | head -1)"
check_version "Dart" "$DART_VERSION" "$(dart --version 2>&1 | head -1)"
JAVA_VERSION="$(java -version 2>&1 | awk -F'[\".]' '/version/ {print $2; exit}')"
case "$JAVA_VERSION" in
  17|21) log OK "Java $JAVA_VERSION (validated)" ;;
  *) log WARN "Java $JAVA_VERSION is outside the validated majors 17/21; continuing so Gradle can perform the definitive compatibility check." ;;
esac

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "$ANDROID_SDK_ROOT" ]]; then
  for candidate in "$HOME/Android/Sdk" "$HOME/Android/sdk" "$HOME/android-sdk" "${PREFIX:-}/opt/android-sdk" "${PREFIX:-}/share/android-sdk"; do
    if [[ -d "$candidate/platform-tools" || -d "$candidate/platforms" || -d "$candidate/build-tools" ]]; then
      ANDROID_SDK_ROOT="$candidate"
      break
    fi
  done
fi
<<<<<<< HEAD
<<<<<<< HEAD
[[ -n "$ANDROID_SDK_ROOT" && -d "$ANDROID_SDK_ROOT" ]] || fatal --code "$ERR_ENV" "Android SDK was not found. Set ANDROID_SDK_ROOT."
export ANDROID_SDK_ROOT ANDROID_HOME="$ANDROID_SDK_ROOT"
[[ -d "$ANDROID_SDK_ROOT/platforms/android-${ANDROID_COMPILE_SDK}" ]] || fatal --code "$ERR_ENV" "Android platform android-${ANDROID_COMPILE_SDK} is missing."
[[ -d "$ANDROID_SDK_ROOT/build-tools/${ANDROID_BUILD_TOOLS_VERSION}" ]] || fatal --code "$ERR_ENV" "Android Build Tools ${ANDROID_BUILD_TOOLS_VERSION} are missing."
=======
[[ -n "$ANDROID_SDK_ROOT" && -d "$ANDROID_SDK_ROOT" ]] || fatal "$ERR_ENV" "Android SDK was not found. Set ANDROID_SDK_ROOT."
export ANDROID_SDK_ROOT ANDROID_HOME="$ANDROID_SDK_ROOT"
[[ -d "$ANDROID_SDK_ROOT/platforms/android-${ANDROID_COMPILE_SDK}" ]] || fatal "$ERR_ENV" "Android platform android-${ANDROID_COMPILE_SDK} is missing."
[[ -d "$ANDROID_SDK_ROOT/build-tools/${ANDROID_BUILD_TOOLS_VERSION}" ]] || fatal "$ERR_ENV" "Android Build Tools ${ANDROID_BUILD_TOOLS_VERSION} are missing."
>>>>>>> pr-61
=======
[[ -n "$ANDROID_SDK_ROOT" && -d "$ANDROID_SDK_ROOT" ]] || fatal "Android SDK was not found. Set ANDROID_SDK_ROOT." "$EXIT_ENV"
export ANDROID_SDK_ROOT ANDROID_HOME="$ANDROID_SDK_ROOT"
[[ -d "$ANDROID_SDK_ROOT/platforms/android-${ANDROID_COMPILE_SDK}" ]] || fatal "Android platform android-${ANDROID_COMPILE_SDK} is missing." "$EXIT_ENV"
[[ -d "$ANDROID_SDK_ROOT/build-tools/${ANDROID_BUILD_TOOLS_VERSION}" ]] || fatal "Android Build Tools ${ANDROID_BUILD_TOOLS_VERSION} are missing." "$EXIT_ENV"
>>>>>>> pr-188
log OK "Android SDK ${ANDROID_COMPILE_SDK} / Build Tools ${ANDROID_BUILD_TOOLS_VERSION}"

if [[ -d "$ANDROID_SDK_ROOT/ndk/$ANDROID_NDK_VERSION" ]]; then
  log OK "NDK $ANDROID_NDK_VERSION"
elif is_termux; then
  log OK "Termux packages prebuilt JNI libraries; no Google host NDK/CMake execution required"
elif grep -Eq '^[[:space:]]*ndkVersion[[:space:]=]' android/app/build.gradle; then
<<<<<<< HEAD
<<<<<<< HEAD
  fatal --code "$ERR_ENV" "Project declares an NDK but required $ANDROID_NDK_VERSION is missing."
=======
  fatal "$ERR_ENV" "Project declares an NDK but required $ANDROID_NDK_VERSION is missing."
>>>>>>> pr-61
=======
  fatal "Project declares an NDK but required $ANDROID_NDK_VERSION is missing." "$EXIT_ENV"
>>>>>>> pr-188
else
  log WARN "NDK reference $ANDROID_NDK_VERSION recorded; current app has no explicit NDK requirement."
fi

<<<<<<< HEAD
<<<<<<< HEAD
[[ -x android/gradlew ]] || fatal --code "$ERR_ENV" "android/gradlew is missing or not executable"
[[ -f android/gradle/wrapper/gradle-wrapper.jar ]] || fatal --code "$ERR_ENV" "Gradle Wrapper JAR is missing: android/gradle/wrapper/gradle-wrapper.jar"
python3 "$ROOT/tool/gradle_wrapper_integrity.py" || fatal --code "$ERR_ENV" "Gradle wrapper integrity check failed"
WRAPPER_URL="$(sed -nE 's/^distributionUrl=.*gradle-([0-9.]+)-all\.zip$/\1/p' android/gradle/wrapper/gradle-wrapper.properties)"
[[ "$WRAPPER_URL" == "$GRADLE_VERSION" ]] || fatal --code "$ERR_ENV" "Gradle Wrapper mismatch. Expected $GRADLE_VERSION Found $WRAPPER_URL"
grep -F "distributionSha256Sum=" android/gradle/wrapper/gradle-wrapper.properties >/dev/null || fatal --code "$ERR_ENV" "Gradle Wrapper SHA-256 pin is missing"
log OK "Gradle Wrapper $GRADLE_VERSION"
grep -F "version \"$AGP_VERSION\"" android/settings.gradle >/dev/null || fatal --code "$ERR_ENV" "AGP $AGP_VERSION is not pinned in settings.gradle"
grep -F "version \"$KOTLIN_VERSION\"" android/settings.gradle >/dev/null || fatal --code "$ERR_ENV" "Kotlin $KOTLIN_VERSION is not pinned in settings.gradle"
grep -F "compileSdk $ANDROID_COMPILE_SDK" android/app/build.gradle >/dev/null || fatal --code "$ERR_ENV" "compileSdk contract mismatch"
grep -F "targetSdk $ANDROID_TARGET_SDK" android/app/build.gradle >/dev/null || fatal --code "$ERR_ENV" "targetSdk contract mismatch"
grep -F "minSdkVersion flutter.minSdkVersion" android/app/build.gradle >/dev/null || fatal --code "$ERR_ENV" "minSdk contract mismatch"
log OK "AGP $AGP_VERSION / Kotlin $KOTLIN_VERSION / Android targets"

if is_termux && [[ "$ARCH" =~ ^(aarch64|arm64)$ ]]; then
  command -v aapt2 >/dev/null 2>&1 || fatal --code "$ERR_ENV" "Termux ARM64 build requires native aapt2 in PATH"
=======
[[ -x android/gradlew ]] || fatal "$ERR_ENV" "android/gradlew is missing or not executable"
[[ -f android/gradle/wrapper/gradle-wrapper.jar ]] || fatal "$ERR_ENV" "Gradle Wrapper JAR is missing: android/gradle/wrapper/gradle-wrapper.jar"
python3 "$ROOT/tool/gradle_wrapper_integrity.py"
WRAPPER_URL="$(sed -nE 's/^distributionUrl=.*gradle-([0-9.]+)-all\.zip$/\1/p' android/gradle/wrapper/gradle-wrapper.properties)"
[[ "$WRAPPER_URL" == "$GRADLE_VERSION" ]] || fatal "$ERR_ENV" "Gradle Wrapper mismatch. Expected $GRADLE_VERSION Found $WRAPPER_URL"
grep -F "distributionSha256Sum=" android/gradle/wrapper/gradle-wrapper.properties >/dev/null || fatal "$ERR_ENV" "Gradle Wrapper SHA-256 pin is missing"
log OK "Gradle Wrapper $GRADLE_VERSION"
grep -F "version \"$AGP_VERSION\"" android/settings.gradle >/dev/null || fatal "$ERR_ENV" "AGP $AGP_VERSION is not pinned in settings.gradle"
grep -F "version \"$KOTLIN_VERSION\"" android/settings.gradle >/dev/null || fatal "$ERR_ENV" "Kotlin $KOTLIN_VERSION is not pinned in settings.gradle"
grep -F "compileSdk $ANDROID_COMPILE_SDK" android/app/build.gradle >/dev/null || fatal "$ERR_ENV" "compileSdk contract mismatch"
grep -F "targetSdk $ANDROID_TARGET_SDK" android/app/build.gradle >/dev/null || fatal "$ERR_ENV" "targetSdk contract mismatch"
grep -F "minSdkVersion flutter.minSdkVersion" android/app/build.gradle >/dev/null || fatal "$ERR_ENV" "minSdk contract mismatch"
log OK "AGP $AGP_VERSION / Kotlin $KOTLIN_VERSION / Android targets"

if is_termux && [[ "$ARCH" =~ ^(aarch64|arm64)$ ]]; then
  command -v aapt2 >/dev/null 2>&1 || fatal "$ERR_ENV" "Termux ARM64 build requires native aapt2 in PATH"
>>>>>>> pr-61
=======
[[ -x android/gradlew ]] || fatal "android/gradlew is missing or not executable" "$EXIT_ENV"
[[ -f android/gradle/wrapper/gradle-wrapper.jar ]] || fatal "Gradle Wrapper JAR is missing: android/gradle/wrapper/gradle-wrapper.jar" "$EXIT_ENV"
python3 "$ROOT/tool/gradle_wrapper_integrity.py" || fatal "Gradle Wrapper integrity check failed" "$EXIT_ENV"
WRAPPER_URL="$(sed -nE 's/^distributionUrl=.*gradle-([0-9.]+)-all\.zip$/\1/p' android/gradle/wrapper/gradle-wrapper.properties)"
[[ "$WRAPPER_URL" == "$GRADLE_VERSION" ]] || fatal "Gradle Wrapper mismatch. Expected $GRADLE_VERSION Found $WRAPPER_URL" "$EXIT_ENV"
grep -F "distributionSha256Sum=" android/gradle/wrapper/gradle-wrapper.properties >/dev/null || fatal "Gradle Wrapper SHA-256 pin is missing" "$EXIT_ENV"
log OK "Gradle Wrapper $GRADLE_VERSION"
grep -F "version \"$AGP_VERSION\"" android/settings.gradle >/dev/null || fatal "AGP $AGP_VERSION is not pinned in settings.gradle" "$EXIT_ENV"
grep -F "version \"$KOTLIN_VERSION\"" android/settings.gradle >/dev/null || fatal "Kotlin $KOTLIN_VERSION is not pinned in settings.gradle" "$EXIT_ENV"
grep -F "compileSdk $ANDROID_COMPILE_SDK" android/app/build.gradle >/dev/null || fatal "compileSdk contract mismatch" "$EXIT_ENV"
grep -F "targetSdk $ANDROID_TARGET_SDK" android/app/build.gradle >/dev/null || fatal "targetSdk contract mismatch" "$EXIT_ENV"
grep -F "minSdkVersion flutter.minSdkVersion" android/app/build.gradle >/dev/null || fatal "minSdk contract mismatch" "$EXIT_ENV"
log OK "AGP $AGP_VERSION / Kotlin $KOTLIN_VERSION / Android targets"

if is_termux && [[ "$ARCH" =~ ^(aarch64|arm64)$ ]]; then
  command -v aapt2 >/dev/null 2>&1 || fatal "Termux ARM64 build requires native aapt2 in PATH" "$EXIT_ENV"
>>>>>>> pr-188
fi

check_disk_space "$ROOT"
check_disk_space "$HOME"
log OK "Build Guard passed"
