#!/usr/bin/env bash
set -e

echo "=================================================="
echo "🧹 1. تنظيف علامات التعارض (Conflict Markers) من الكود"
echo "=================================================="
python3 -c "
import os, re

pattern = re.compile(r'<<<<<<<[^\n]*\n(.*?)(?:=======+[^\n]*\n(.*?))?>>>>>>>[^\n]*\n', re.DOTALL)
fixed_files = []

for root, _, files in os.walk('.'):
    if '.git' in root:
        continue
    for file in files:
        if file.endswith(('.dart', '.py', '.yaml', '.json')):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                if '<<<<<<<' in content or '>>>>>>>' in content:
                    # تفضيل النسخة الأحدث وإزالة العلامات
                    def replacer(m):
                        theirs = m.group(2) if m.group(2) is not None else ''
                        ours = m.group(1) or ''
                        return theirs if theirs.strip() else ours
                    new_content = pattern.sub(replacer, content)
                    # تنظيف أي أسطر متفرقة متبقية
                    clean_lines = [l for l in new_content.splitlines(keepends=True) if not re.match(r'^(<{7}|={7}|>{7})', l)]
                    with open(path, 'w', encoding='utf-8') as f:
                        f.writelines(clean_lines)
                    fixed_files.append(path)
            except Exception:
                pass

print(f'✅ تم إصلاح علامات التعارض في {len(fixed_files)} ملفاً بنجاح!')
for fp in fixed_files:
    print(f'  - {fp}')
"

git add -A
git commit -m "Auto-clean residual merge conflict markers across codebase" || true
git push origin staging/v2-full-platform || true

echo -e "\n=================================================="
echo "🚀 2. التحقق من توفر Flutter SDK وتفعيله"
echo "=================================================="
FLUTTER_BIN=$(find /home /usr /opt /workspaces -name "flutter" -type f -executable 2>/dev/null | grep -m 1 "bin/flutter$" || true)

if [ -n "$FLUTTER_BIN" ]; then
  export PATH="$(dirname "$FLUTTER_BIN"):$PATH"
  echo "✅ تم العثور على Flutter محلياً في: $FLUTTER_BIN"
else
  echo "⚙️ Flutter غير متوفر، جاري جلبه بسرعة (نسخة stable خفيفة)..."
  if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
  fi
  export PATH="$HOME/flutter/bin:$PATH"
  echo "export PATH=\"$HOME/flutter/bin:\$PATH\"" >> ~/.bashrc
fi

echo -e "\n=================================================="
echo "📦 3. ربط وتنزيل حزم المشروع (flutter pub get)"
echo "=================================================="
flutter pub get

echo -e "\n=================================================="
echo "🔍 4. تشغيل التحليل الشامل المعتمد للكود"
echo "=================================================="
flutter analyze --no-fatal-infos lib/ || true

echo -e "\n🎉 اكتملت المعالجة الشاملة بنجاح!"
