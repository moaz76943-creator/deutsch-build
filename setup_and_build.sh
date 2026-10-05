#!/bin/bash
set -e

echo "=== [1/4] ضبط مسارات local.properties ==="
LOCAL_PROP="android/local.properties"
SDK_PATH="/data/data/com.termux/files/usr/opt/android-sdk"
NDK_PATH="$SDK_PATH/ndk/28.2.13676358"

mkdir -p android
grep -v "^sdk.dir=" "$LOCAL_PROP" 2>/dev/null | grep -v "^ndk.dir=" | grep -v "^flutter.sdk=" > "${LOCAL_PROP}.tmp" || true
echo "sdk.dir=$SDK_PATH" >> "${LOCAL_PROP}.tmp"
echo "ndk.dir=$NDK_PATH" >> "${LOCAL_PROP}.tmp"
FLUTTER_ROOT="$(flutter doctor -v | grep 'Flutter version' | sed -n 's/.*at //p')"
[ -n "$FLUTTER_ROOT" ] && echo "flutter.sdk=$FLUTTER_ROOT" >> "${LOCAL_PROP}.tmp"
mv "${LOCAL_PROP}.tmp" "$LOCAL_PROP"

echo "=== [2/4] تأمين روابط CMake و NDK ==="
if [ -d "$NDK_PATH" ]; then
    rm -rf "$SDK_PATH/ndk/27.0.12077973"
    ln -sf "$NDK_PATH" "$SDK_PATH/ndk/27.0.12077973"
fi
CMAKE_TARGET="$SDK_PATH/cmake/3.22.1/bin/cmake"
mkdir -p "$(dirname "$CMAKE_TARGET")"
rm -f "$CMAKE_TARGET"
ln -sf "$(command -v cmake)" "$CMAKE_TARGET"

echo "=== [3/4] إنشاء سكربت البناء الدائم (build_app.sh) ==="
cat << 'APP_EOF' > build_app.sh
#!/bin/bash
set -e
echo "-> معالجة الاستيرادات الزائدة وتحديث الأكواد..."
dart fix --apply
echo "-> تنظيف الكاش المؤقت المتضرر..."
rm -rf build/ android/.cxx/ android/app/.cxx/
echo "-> بدء تجميع ملف الـ APK..."
flutter build apk --debug
echo "-> اكتمل البناء بنجاح! مسار الملف:"
ls -lh build/app/outputs/flutter-apk/app-debug.apk
APP_EOF
chmod +x build_app.sh

echo "=== [4/4] تشغيل البناء الآن ==="
./build_app.sh
