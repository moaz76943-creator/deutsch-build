# V261 — ReviewCard Temporal Persistence Bounds

## الهدف

توحيد حدود التواريخ في حالة التعلم المحلية ومنع تخزين `lastReviewedAt` بقيمة تاريخية غير صالحة قبل سنة 2000.

## المشكلة

`ReviewCard.fromJson` كان يرفض `dueAt` الأقدم من 2000، لكنه كان يكتفي بتصحيح `lastReviewedAt` المستقبلية. هذا يترك حقلًا زمنيًا محفوظًا دون نفس الحد الأدنى الزمني المستخدم لبقية الحالة.

## التعديل

أصبح `lastReviewedAt` يُطبّع إلى `DateTime.now()` إذا كان:

- أبعد من يوم في المستقبل.
- أقدم من 2000.

لا يوجد تغيير في المحتوى التعليمي أو صيغة البيانات العامة، ولا توجد migration هدّامة.

## TDD

### RED

أُضيف الاختبار `tests/test_v261_review_card_temporal_bounds.py` وشغّل أولًا، وفشل لأن شرط `lastReviewedAt < 2000` لم يكن موجودًا.

### GREEN

أُضيف شرط الحد الأدنى فقط، ثم أُعيد تشغيل الاختبار نفسه ونجح.

### Regression

`pytest -q` → 253 passed.

## Verification

- Privacy audit: PASS
- Security audit: PASS
- Quality audit: PASS — 14,813 entries
- Accessibility audit: PASS — 0 warnings
- Architecture audit: PASS
- Weakness gate: PASS
- Build path compatibility: PASS
- CI secret hygiene: PASS
- Python compileall: PASS
- Bash syntax: PASS

Flutter/Android/APK/AAB runtime/build verification remains unavailable in the current environment because the required Flutter/Android toolchain is not installed.
