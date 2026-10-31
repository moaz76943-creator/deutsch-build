# V268 — Partial Persisted-State Recovery

## الهدف
منع تلف مفتاح علوي واحد في JSON المخزن محليًا من إسقاط كامل `LearnerState` السليم المتبقي.

## المشكلة
كان `Map<String, dynamic>.from(decoded)` يمكن أن يرمي استثناءً إذا احتوى الـMap المفكوك على مفتاح غير نصي. وبسبب `catch` الخارجي كان ذلك يعيد حالة فارغة، ما قد يفقد الاستفادة من الحقول السليمة الموجودة في نفس السجل.

## الإصلاح
يُحوّل loader الـMap الجذري يدويًا إلى `Map<String, dynamic>`، مع الاحتفاظ بالمفاتيح النصية فقط قبل قراءة الحقول المعروفة. هذا تغيير محلي صغير ولا يغير صيغة البيانات الصحيحة.

## TDD
- RED: `tests/test_v268_partial_state_recovery.py` فشل 2/2 لأن التحويل typed كان ما يزال مباشرًا.
- GREEN: أضيفت فلترة المفاتيح النصية قبل التحويل.
- focused: 2 passed.

## التحقق
- Full regression: 263 passed.
- Privacy: PASS.
- Security: PASS.
- Quality: PASS — 14,813 entries.
- Accessibility: PASS — 0 warnings.
- Architecture: PASS.
- Weakness Gate: PASS.
- Content compiler/parity: 14,813 content rows; 11,718 verb rows; parity PASS.
- compileall: PASS.
- Bash syntax: PASS.

Flutter/Android/APK/AAB runtime build was not executed because the required Flutter/Android toolchain is unavailable in the current environment.
