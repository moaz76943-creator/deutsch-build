# V135 — app.dart Architecture Hardening

## الهدف
تقليل الاعتماد على `lib/ui_v35/app.dart` كملف واجهة ضخم مع الحفاظ على أسماء الـWidgets وسلوك التنقل والمنطق التعليمي.

## ما تم تنفيذه
- استخراج الصفحات منخفضة الترابط إلى `lib/ui_v35/pages/core_pages.dart`.
- استخراج حدود TTS الآمنة إلى `lib/ui_v35/safe_ui.dart` لتصبح طبقة مشتركة بدل ربطها بملف التطبيق الرئيسي.
- بقيت أسماء الـWidgets العامة وتواقيع constructors كما هي.
- لم يتغير منطق SRS أو محرك التعلم أو repository.
- أضيف اختبار معماري `test/v135_app_split_test.py` يمنع عودة الصفحات المستخرجة إلى `app.dart` ويراقب حجم الملف.
- حدّثت الاختبارات التاريخية التي كانت تعتمد على وجود الكود في `app.dart` فقط لتبحث أيضًا في الوحدات المستخرجة.

## القياسات
- `app.dart`: من 1280 إلى 1142 سطرًا.
- `core_pages.dart`: 165 سطرًا.
- `safe_ui.dart`: 22 سطرًا.
- `architecture_audit.py`: PASS.
- `weakness_gate.py`: PASS.
- Accessibility: PASS، تحذيرات 0.
- Quality: PASS.
- Security: PASS.
- Content Intelligence: PASS.
- Python tests: 181 passed.
- Python compilation: 52 files passed.
- ZIP integrity: PASS.

## نقاط الضعف المتبقية
ما زال `app.dart` أكبر من الهدف المعماري النهائي، كما أن `content_a1.dart` و`verb_conjugations.dart` كبيران جدًا. لن يتم تقسيمهما آليًا بلا اختبارات لأنهما يحملان بيانات ضخمة حساسة للتغيير.

## حدود التحقق
Flutter SDK غير متاح في بيئة التنفيذ الحالية؛ لذلك لم يتم الادعاء بإجراء `flutter analyze` أو `flutter test` أو Android emulator smoke tests. هذه الخطوة تحتاج بيئة Flutter/Android فعلية.
