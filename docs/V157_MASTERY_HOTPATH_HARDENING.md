# V157 — Mastery Hotpath Hardening

## الهدف
تقليل العمل المتكرر في حساب الإتقان ولوحة الإتقان دون تغيير معنى الدرجات الحالية.

## الإصلاحات
- `Mastery.forItemRows` يجمع المحاولات حسب المهارة مرة واحدة بدل تنفيذ `where(...).toList()` لكل مهارة.
- تمت إضافة `Mastery.retentionForCard` لاستخدام حساب الاحتفاظ المباشر عندما تكون لوحة الإتقان بحاجة إلى retention فقط.
- `MasteryDashboard` لم يعد يعيد بناء `MasteryEvidence` من قائمة محاولات فارغة لكل بطاقة مراجعة لحساب retention.
- بقي حساب `Mastery.forItemRows` الأساسي مرة واحدة لكل عنصر في لوحة الإتقان.

## التحقق
- V157 focused: 3/3 PASS
- Full Python regression: 69/69 PASS
- Accessibility audit: PASS, 0 warnings
- Architecture audit: PASS, 0 oversized files
- Quality audit: PASS, 14,793 entries / 14,793 unique IDs / 14,793 unique German entries
- Security audit: PASS
- Weakness gate: PASS; review queue 1,180; mutation NONE
- Flutter/Dart compiler and Android runtime: غير متحققين في هذه البيئة لعدم توفر Flutter SDK ومحاكي Android.
