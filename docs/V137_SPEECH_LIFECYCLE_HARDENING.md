# V137 — Speech Lifecycle Hardening

## الهدف
تقليل مخاطر السباقات والأحداث المتأخرة بين `speech_to_text` وصفحات Flutter عند بدء الاستماع أو إيقافه أو مغادرة الصفحة.

## الإصلاحات
- `disposed` يمنع أي عملية جديدة بعد التخلص من الخدمة.
- `generation token` يبطل callbacks القديمة بعد `stop()` أو `dispose()`.
- قفل عمليات يمنع تداخل `initialize()` و`listen()`.
- `isListening` محمي من استثناءات المحرك.
- `dispose()` يبطل الجيل ويوقف المحرك مع امتصاص أخطاء Future.
- صفحات المحادثة والنطق تغلق دورة حياة `SpeechService` صراحةً.

## التحقق
- اختبار دورة حياة الصوت: PASS.
- الاختبار الكامل: **195 passed**.
- Accessibility: PASS، 0 warnings.
- Architecture: PASS، 0 ملفات متجاوزة للحد.
- Quality: PASS، 14,793 عنصرًا فريدًا.
- Security: PASS.
- Flutter/Android runtime غير متاح في بيئة العمل الحالية؛ لذلك لا يوجد ادعاء باختبار المحاكي أو خلو التشغيل من الأعطال.
