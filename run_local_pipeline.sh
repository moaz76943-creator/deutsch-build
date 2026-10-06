#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SCRIPT="$ROOT/build_deutsch.sh"
APK="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/sdcard/Download}"
DEST_APK="$DOWNLOAD_DIR/deutsch-bilarabi-debug.apk"

on_error() {
  local line="$1" command="$2" code="$3"
  printf '\n❌ توقفت العملية عند السطر %s (رمز الخروج: %s).\nالأمر: %s\n' \
    "$line" "$code" "$command" >&2
}
trap 'on_error "${LINENO}" "${BASH_COMMAND}" "$?"' ERR

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fatal() { printf '❌ خطأ: %s\n' "$*" >&2; exit 1; }

require_termux() {
  case "${PREFIX:-}" in
    /data/data/*/files/usr) ;;
    *) fatal "هذا السكريبت مخصص لبيئة Termux. PREFIX=${PREFIX:-<غير مضبوط>}" ;;
  esac
}

check_shared_storage() {
  [[ -d "$DOWNLOAD_DIR" ]] || fatal \
    "مجلد التنزيلات غير متاح: $DOWNLOAD_DIR. شغّل termux-setup-storage مرة واحدة وامنح Termux إذن الملفات."
  [[ -w "$DOWNLOAD_DIR" ]] || fatal \
    "لا توجد صلاحية كتابة إلى $DOWNLOAD_DIR. شغّل termux-setup-storage وتأكد من منح الإذن."
}

analyze_core() {
  command -v dart >/dev/null 2>&1 || fatal "أمر dart غير موجود في PATH. جهّز بيئة Flutter/Termux أولاً."

  log "🔎 فحص كود lib/ عبر dart analyze (الأخطاء فقط توقف العملية)..."
  local output status=0
  output="$(dart analyze lib/ 2>&1)" || status=$?
  printf '%s\n' "$output"

  if grep -Fq "error •" <<<"$output"; then
    printf '\nالأخطاء المانعة للبناء:\n' >&2
    grep -F "error •" <<<"$output" >&2 || true
    fatal "تم العثور على أخطاء Dart مانعة للبناء داخل lib/."
  fi

  case "$status" in
    0|2) ;;
    *) fatal "فشل dart analyze برمز خروج غير متوقع: $status" ;;
  esac

  log "✅ فحص Dart مكتمل: لا توجد أخطاء مانعة للبناء في lib/."
}

build_apk() {
  [[ -f "$BUILD_SCRIPT" ]] || fatal "سكريبت البناء غير موجود: $BUILD_SCRIPT"
  [[ -x "$BUILD_SCRIPT" ]] || fatal "سكريبت البناء غير تنفيذي: $BUILD_SCRIPT"

  log "🏗️ بدء البناء الفعلي عبر ./build_deutsch.sh ..."
  "$BUILD_SCRIPT"

  [[ -s "$APK" ]] || fatal "انتهى البناء دون العثور على APK صالح في: $APK"
  log "✅ تم إنشاء APK بنجاح."
}

copy_apk() {
  check_shared_storage

  log "📦 نسخ APK إلى مجلد Download المشترك..."
  cp -f -- "$APK" "$DEST_APK"

  [[ -s "$DEST_APK" ]] || fatal "فشل إنشاء نسخة APK صالحة في: $DEST_APK"
  cmp -s -- "$APK" "$DEST_APK" || fatal "نسخة APK في Download لا تطابق الملف الناتج من البناء."

  local sha size
  sha="$(sha256sum "$DEST_APK" | awk '{print $1}')"
  size="$(wc -c < "$DEST_APK" | tr -d ' ')"

  log "✅ تم نسخ APK والتحقق منه بنجاح."
  printf '\n🎉 اكتملت العملية المحلية بنجاح.\n'
  printf 'APK الجاهز للتثبيت: %s\n' "$DEST_APK"
  printf 'الحجم: %s بايت\n' "$size"
  printf 'SHA256: %s\n' "$sha"
}

main() {
  require_termux
  cd "$ROOT"
  analyze_core
  build_apk
  copy_apk
}

main "$@"
