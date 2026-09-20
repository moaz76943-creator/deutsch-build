# DEUTSCH بالعربي — السجل التشغيلي

هذا المجلد هو سجل تشغيل المشروع المدعوم بالأدلة.

## الملفات

- PROJECT_INTENT.md — الهدف النهائي، الهدف الحالي، والخطة المعتمدة. لا تُستنتج تلقائيًا من الأحداث.
- runtime.json — الحالة التشغيلية التي تولدها الأتمتة من Git/CI.
- events.ndjson — سجل أحداث قابل للإضافة، وكل حدث يحمل مصدره ودليله.
- README.md — هذا الدليل.

## قاعدة الاستعادة عبر المحادثات

ابدأ من: PROJECT_INTENT.md ثم runtime.json ثم آخر الأحداث ثم آخر Verification/Checkpoint ثم GitHub الحالي ثم المهمة الحالية.

إذا كان reconciliation_required=true أو كانت هناك دلائل أحدث من آخر سجل، لا تُكمل على افتراضات قديمة. نفّذ RECONCILIATION أولًا.

## ما الذي لا تفعله الأتمتة

الأتمتة لا تستنتج الهدف أو الخطة من commit messages، ولا تحول نشاط GitHub إلى VERIFIED تلقائيًا. Evidence and verification remain separate.

## OpenCode

tool/project_record_event.py هو نقطة ربط محلية يمكن لـOpenCode أو عامل آخر استخدامها بعد إثبات دعم hook/runtime محليًا. وجود الملف لا يعني أن OpenCode يستدعيه حاليًا.

## Notion

صفحة Notion للسجل هي واجهة Cross-Chat وDecision Context. GitHub remains the code/evidence source. Direct automatic Notion writes require a deliberately configured integration/secret; this repository does not assume one exists.
