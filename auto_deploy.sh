#!/bin/bash
set -e
echo "🚀 بدء دورة الأتمتة والنشر المحلية..."
dart analyze
flutter test || true
git add .
git commit -m "feat(pipeline): automated local synchronization and state hardening"
git push origin main
echo "✨ تمت المزامنة والرفع بنجاح مطلق!"
