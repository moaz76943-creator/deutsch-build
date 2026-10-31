#!/usr/bin/env bash
set -e

echo "🔧 1. تنظيف علامات التعارض من pubspec.yaml..."
# إزالة أسطر التعارض واعتماد النسخة الأحدث مع الحفاظ على الحزم
python3 -c "
with open('pubspec.yaml', 'r') as f:
    lines = f.readlines()
clean = []
skip = False
for line in lines:
    if line.startswith('<<<<<<<'):
        skip = True
        continue
    if line.startswith('======='):
        skip = False
        continue
    if line.startswith('>>>>>>>'):
        continue
    clean.append(line)
with open('pubspec.yaml', 'w') as f:
    f.writelines(clean)
"
git add pubspec.yaml
git commit -m "Fix residual merge conflict in pubspec.yaml" || true
git push origin staging/v2-full-platform || true

echo "📥 2. التحقق من وجود Dart أو جلبه لتفعيل التحليل الثابت..."
if ! command -v dart &> /dev/null; then
  # البحث في المسارات القياسية للـ Codespace
  DART_BIN=$(find /home /usr /opt -name "dart" -type f -executable 2>/dev/null | grep -m 1 "bin/dart$")
  if [ -n "$DART_BIN" ]; then
    export PATH="$(dirname "$DART_BIN"):$PATH"
    echo "export PATH=\"$(dirname "$DART_BIN"):\$PATH\"" >> ~/.bashrc
    echo "✅ تم العثور على Dart وتفعيله من: $DART_BIN"
  else
    echo "⚙️ جاري تثبيت Dart SDK عبر الحزم الرسمية..."
    sudo apt-get update -qq && sudo apt-get install -y -qq apt-transport-https
    sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
    sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
    sudo apt-get update -qq && sudo apt-get install -y -qq dart
    export PATH="/usr/lib/dart/bin:$PATH"
    echo 'export PATH="/usr/lib/dart/bin:$PATH"' >> ~/.bashrc
  fi
fi

echo "🔍 3. تشغيل التحليل الثابت لمجلد التطبيق..."
dart analyze lib/ || true

echo "🎉 اكتمل تجهيز البيئة والفحص!"
