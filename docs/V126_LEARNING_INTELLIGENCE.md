# V126 — Learning Intelligence 3.0

## الهدف
إضافة طبقة قرار موحدة فوق Adaptive Teacher وSRS وMistake Engine وSmart Mastery وContent Intelligence، مع الحفاظ على كل محرك متخصص مستقلًا.

## التغييرات
- `LearningIntelligence` يولّد `LearningDecision` لكل عنصر مرشح.
- القرار يوازن بين المراجعة المستحقة، الأخطاء الحديثة، الإتقان، قابلية الاسترجاع، ضغط المراجعة، وجاهزية المحتوى الجديد.
- تم تقليص نطاق الحسابات الثقيلة في `LearningEngine` إلى أفضل 120 مرشحًا بدل إعادة تحليل كامل الكتالوج في كل جلسة.
- تم الحفاظ على `AdaptiveFocus` و`Mastery.nextAction` كطبقات fallback وعدم كسر السلوك القديم.
- أضيفت 20 وحدة A2 جديدة بدون تغيير IDs القديمة.
- أضيف فعلان جديدان إلى فهرس التصريف: `überprüfen` و`annehmen`، ولكل منهما 9 صيغ تعليمية مع Perfekt وأمثلة عربية.
- أضيفت فحوص تكرار IDs والكلمات الألمانية وربط توسعة الأفعال.

## حدود التحقق
- اختبارات Python: 108 ناجحة.
- Quality Audit وSecurity Audit يجب أن يمرّا قبل التسليم.
- `compileall` يستخدم لفحص ملفات Python فقط؛ Dart/Flutter runtime غير متاح في بيئة التنفيذ الحالية.
- لم يتم بناء APK في هذه الدفعة.
