# V142 — Verb Catalog Cache Hardening

## الهدف
منع صفحة الأفعال من إعادة بناء فهارس كاملة للتصريفات في كل `build()`، وهي عملية كانت تمر على كامل كتالوج التصريفات مرتين وتعيد إنشاء `Map` جديدة عند كل إعادة بناء للواجهة.

## التغيير
- أضيفت فهارس المجموعة والتصريف إلى `VerbIndex` الموجود أصلًا.
- أصبح `VerbIndex.instance` lazy singleton، لذلك يُبنى الفهرس مرة واحدة عند الحاجة.
- أضيفت واجهات `groups` و`rowsFor()` و`infinitives` للقراءة من الفهرس المخبأ.
- `VerbPage` لم يعد يبني `byVerb` و`byGroup` داخل `build()`.
- بقيت البيانات Offline كما هي ولم يتغير مصدر المحتوى.

## التحقق
- V142 focused tests: 3 passed.
- Full regression suite: 221 passed, 0 failed.
- Accessibility audit: PASS, 0 warnings.
- Architecture audit: PASS, 0 oversized files.
- Quality audit: PASS — 14,793 entries / 14,793 unique IDs / 14,793 unique German entries.
- Security audit: PASS.
- Weakness gate: PASS — review-only queue, 1,180 candidates, no mutation.

## حدود التحقق
لم يتم تشغيل Flutter/Android runtime في هذه البيئة لأن Flutter SDK/emulator غير متاحين. لذلك لا يُستنتج من هذه النتائج وحدها غياب أخطاء runtime على جهاز Android.
