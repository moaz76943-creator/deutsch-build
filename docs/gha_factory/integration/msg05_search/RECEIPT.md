# MSG05-SEARCH-20261013 — إيصال هندسي

الحالة: **IMPLEMENTED / BLOCKED_TOOLCHAIN / BLOCKED_VERIFICATION**.
هذا تغيير مستقل محدود في البحث، وليس إثبات اكتمال منصة الرسالة 05.

OWNER: Codex — session 01a1333d-88d8-771d-8094-d3d31a19a050.
CLAIM: private issue #64.
BRANCH: msg05/language-scoped-search-20261013.
TARGET: staging/v2-full-platform (توجيه المالك الحالي ينسخ محدد المستودع القديم في AGENTS).

## التغيير والدليل

عند وجود سجلات لغات مختلفة في نفس SQLite، كانت خدمة البحث تقرأها جميعًا ثم
توسمها بلغة الطلب. أُضيف شرط اللغة بمعامل SQL مربوط إلى استعلامات القائمة
الفارغة وFTS والبادئة والبحث البديل واقتراحات التصحيح. لا تغيير في قاعدة المتعلم.
عند رجوع unicode61 MATCH فارغًا، يستخدم البحث البديل الحالي المحدود بدل فقدان
البادئات الجزئية. لا ادعاء بتجزئة مثالية لـCJK أو تطبيع تركي لغوي كامل.

- RED: 11 اختبارات SQL مستخرجة من مصدر Dart القديم؛ 6 FAIL، exit 1.
- GREEN: نفس 11 اختبارًا على المصدر المعدل؛ كلها PASS، exit 0.
- Python py_compile: PASS، exit 0.
- Flutter: أضيفت 14 حالة مباشرة باستخدام sqflite_common_ffi ومخزن في الذاكرة.
  التنفيذ NOT_RUN: flutter غير متوفر، exit 127.
- البوابة المطلوبة: `dart analyze lib/ 2>&1 | grep "error •"`.
  PIPESTATUS: dart=127، grep=1. خلو خرج grep لا يثبت عدم أخطاء الترجمة.
- APK، الجهاز الفعلي، merged Android manifest: NOT_RUN.
- لا اعتماد على شبكة في الاختبارات؛ البيانات synthetic وليست حزمًا قابلة للنشر.

الأوامر المحدودة:

```bash
timeout 20s python3 -m unittest discover -s test/gha_factory/integration/msg05_search -p test_production_sql.py -v
timeout 10s python3 -m py_compile test/gha_factory/integration/msg05_search/test_production_sql.py
timeout 20s flutter test test/gha_factory/integration/msg05_search/language_scoped_search_test.dart
```

SQL replay يثبت predicates في SQLite؛ لا ينفذ Dart ولا ترتيب معاملات Dart ولا
compute ولا lifecycle. اختبار Flutter هو البوابة المتبقية لهذه الطبقات.
الـfixture يحتوي أعمدة البحث المستخدمة فقط، وليس إثبات مطابقة كاملة لمخطط v2.

## الحالة الحية المفحوصة

PRIVATE_LIVE_HEAD: 7a47673045ae9308fef60fece7070a07ebe18394

PUBLIC_LIVE_HEAD: f892ad9ff9b929e84a4573f82a20c3439f27af36

أُعيد جلب المرجعين بعد التنفيذ؛ لم يتغيرا. فُحصت 46 private PR و50 public PR
في لقطة الجرد. فُحصت أسماء الملفات في 41 private PR غير التابعة لـDependabot؛
الخمسة الباقية تحديثات dependencies/workflows خارج النطاق. تصحيح Claim الأول:
العدد 46 وليس 44. لم يظهر مالك لملف البحث أو مجلدي المهمة الجديدين.
قائمة Codex tasks روجعت؛ أرقام Jules في الفروع لا تثبت حالة تنفيذ العامل.
الحالة الدقيقة لعمال Jules خارج الأدلة المتاحة: UNKNOWN.

## المطلوب في Section 49

| الحقل | الحالة / الدليل |
|---|---|
| PRIVATE_REPOSITORY_STATUS | فرع isolated، لا دمج؛ أغلب الأعمال Draft |
| PUBLIC_FACTORY_COMPATIBILITY | BLOCKED_DEPENDENCY؛ envelope بثلاثة أعضاء، json-gzip-v1، contract 1.0.0، mapping/schema 2.0.0 |
| FLUTTER_ARCHITECTURE_STATUS | مصدر قائم؛ ليست منظومة كاملة مُتحققًا منها |
| SHARED_CORE_STATUS | موجود؛ البحث المعدل IMPLEMENTED؛ تحقق Flutter معطل |
| LANGUAGE_INTELLIGENCE_STATUS | UNKNOWN للقبول الكامل؛ القواعد اللغوية لا تُختلق |
| DIRECTED_PAIR_INTELLIGENCE_STATUS | DirectedPairId وpairEpoch موجودان؛ end-to-end NOT_RUN |
| CANONICAL_LANGUAGE_COUNT | 100 في public registry |
| REGISTERED_LANGUAGES | public=100 unique، private catalog=100 unique؛ الهوية غير متطابقة |
| INSTALLED_VERIFIED_LANGUAGES | UNKNOWN؛ لا جهاز مستخدم مفحوص |
| PRODUCTION_READY_LANGUAGES | public manifest=0؛ readiness خاص hardcoded ليس دليل قبول |
| PACK_DISCOVERY_STATUS | BLOCKED_SOURCE؛ public packs=[] وlegal sources=[] |
| PACK_DOWNLOAD_STATUS | BLOCKED_DEPENDENCY؛ #55/#58/#28 يملكون الملف |
| PACK_RESUME_STATUS | NOT_RUN؛ يلزم تحقق source identity وContent-Range |
| PACK_SIGNATURE_STATUS | NOT_RUN؛ public candidate: Ed25519، domain DEUTSCH-SQLITE-V2-RC ثم NUL ثم SHA256 binary؛ لا دليل release signature متاح |
| PACK_SHA256_STATUS | تنفيذ قائم؛ مسار تنزيل كامل NOT_RUN |
| PACK_INSTALLATION_STATUS | NOT_RUN؛ #55 يحتوي تغييرًا غير مدمج |
| PACK_ROLLBACK_STATUS | NOT_RUN؛ لا ادعاء حفظ LKG بعد كل مرحلة |
| SQLITE_V2_CONSUMER_STATUS | جزئي في DatabaseService؛ التحقق الكامل NOT_RUN |
| FTS5_SEARCH_STATUS | SQL_REPLAY_PASS؛ FLUTTER_NOT_RUN |
| UNICODE_SEARCH_STATUS | SQL يحفظ الأشكال المختبرة؛ segmentation/case folding الشامل NOT_RUN |
| RTL_LTR_STATUS | NOT_RUN؛ #56/#51/#29 ملكيات قائمة |
| DYNAMIC_LOCALIZATION_STATUS | UNKNOWN؛ لم يثبت DynamicL10nEngine من الجرد الحالي |
| SRS_ENGINE_STATUS | NOT_RUN؛ #53/#22/#63 ملكيات قائمة |
| PAIR_ISOLATION_STATUS | NOT_RUN لمسار SRS؛ #60 مسؤول transactions |
| LEARNER_DATA_INTEGRITY | لا تغيير أو وصول لبيانات متعلم؛ اختبار تحديث pack الحقيقي NOT_RUN |
| FAVORITES_PRESERVATION | لم تُعدّل؛ اختبار preservation NOT_RUN |
| ENCRYPTION_STATUS | VaultCipher/AndroidKeystore قائم؛ device encryption NOT_RUN؛ لا ادعاء SQLCipher |
| PERSISTENT_CPU_WORKER_STATUS | المصدر الحي يستخدم compute لكل حساب؛ #52 Draft يقدم العامل الدائم |
| STARTUP_RELIABILITY_STATUS | StartupBoundary يحتوي timeout/generation/mounted؛ device test NOT_RUN |
| OFFLINE_MODE_STATUS | البحث محلي؛ إطلاق وتعلم التطبيق الكامل NOT_RUN |
| ASYNC_CANCELLATION_STATUS | NOT_RUN end-to-end؛ تغيير البحث لا يضيف generation للنوافذ |
| DART_ANALYZER_STATUS | ANALYZER_NOT_RUN / BLOCKED_TOOLCHAIN |
| DART_BLOCKING_ERRORS | UNKNOWN؛ dart exit 127 |
| FLUTTER_TEST_RESULTS | NOT_RUN؛ 14 حالة جديدة جاهزة للتنفيذ |
| ANDROID_BUILD_RESULTS | BUILD_NOT_RUN |
| REAL_DEVICE_RESULTS | DEVICE_TEST_NOT_RUN |
| TESTS_PASS | 11 production-SQL replay tests؛ Python compile |
| TESTS_FAIL | 6 من 11 في RED القديم فقط؛ GREEN الحالي صفر فشل |
| TESTS_NOT_RUN | Flutter/analyzer/APK/device وبقية تكامل المصفوفة |
| FILES_CHANGED | fts_search_service.dart؛ ملفا اختبار؛ receipt؛ sql_red.txt؛ sql_green.txt |
| PRS_OPENED | مسودة مستقلة لهذا الفرع؛ الرابط ورقمها في GitHub |
| PRS_MERGED | NONE |
| MERGE_SHAS | NONE |
| PRS_BLOCKED | PR هذه المهمة: BLOCKED_TOOLCHAIN/BLOCKED_VERIFICATION؛ بقية PRs لم تُدمج |
| PUBLIC_SOURCE_DEPENDENCIES | BLOCKED_SOURCE؛ legal/ledger/sources.json فارغ |
| SQLITE_RELEASE_DEPENDENCIES | BLOCKED_SOURCE؛ public packs=[] |
| PRIVATE_INTEGRATION_DEPENDENCIES | #54 catalog؛ #55/#58 downloader؛ #57 probes؛ #52 worker؛ #60 SRS |
| ACTUAL_GITHUB_RUN_IDS | NONE dispatched by this task |
| ACTUAL_BUILD_IDS | NONE |
| ACTUAL_CHECKPOINTS | issue #64، RED/GREEN logs، branch commit/PR evidence |
| ZERO_ADDITIONAL_BILLING_STATUS | لا hosted run أو خدمة مدفوعة؛ local stdlib فقط |
| PRIVACY_PERMISSION_STATUS | main manifest يسمح INTERNET/ACCESS_NETWORK_STATE؛ storage permissions removal؛ merged manifest NOT_RUN؛ لم تُعدّل صلاحيات |
| REMAINING_BLOCKERS | toolchain؛ source approvals/releases؛ draft ownership؛ canonical identity drift |
| REMAINING_ENGINEERING_WORK | تشغيل Flutter/gate؛ ربط باقي المصفوفة بالمالكين؛ تحقق packs حقيقية وجهاز |
| NEXT_SAFE_AUTONOMOUS_TASKS | المالك التالي يشغل tests على exact PR SHA ببيئة معتمدة؛ مراجعة #54 و#55 و#52 دون تجاوز gates |

## Handoff محدد

1. **#54 canonical catalog**: private-only IDs:
   `fil, he, jv, ny, om, st, su, ti, wo`.
   public-only IDs: `zh, or, as, ba, dv, fo, fy, gd, br`.
   لا تُعامل أية مساواة اسمية كـalias دون العقد. readiness الخاصة تعتبر de/ar/en
   productionReady بلا دليل مطابق للإصدارات العامة؛ #54 يملك إصلاحها.
2. **#55/#58 installer**: live downloader يتحقق من languageCode القديم بينما
   public DB يستخدم language_code؛ live schema يطلب lexemes بينما v2 يقدم view.
   يتجاهل public availability flags عبر legacy languages fallback. يلزم اختبار
   رفض legacy manifests، signature، cancellation أثناء activation، journal/LKG.
   هذا الملف بقي READ-ONLY.
3. **#30 DatabaseService**: verifyUniversalSchema الحي لا يجري في هذا method
   foreign_key_check أو فحص required indexes أو FTS SQL definition/row counts.
   فحص mounted integrity منفصل؛ لا تفترض اكتمال validation من اسم method.
4. **#52 worker**: compute الموجود ليس persistent worker؛ يلزم التحقق من PR
   نفسه قبل وصف المنظومة بالعامل الدائم.
5. **UI/search owner**: هذا الإصلاح يعزل SQL فقط؛ منع نتيجة طلب قديم من تحديث
   شاشة جديدة يحتاج epoch/generation في caller واختبار widget فعلي.
6. **language policy**: language_identity.dart الحي يمنع he/iw بينما directive
   تطلب عرض Hebrew؛ سجل التعارض ولا تدّعِ دعم جميع الهويات. لم يُغير هنا.
7. **size compatibility**: public release permits envelope 120 MiB، consumer
   caps 64 MiB. الحزم الصغيرة فقط ضمن التقاطع؛ لا ترفع حد ذاكرة الهاتف افتراضًا.

## بوابات الدمج

تشغيل الاختبارات المباشرة والـanalyzer على snapshot كامل معتمد؛ إعادة جلب target
HEAD ومراجعة الملكيات/checks؛ مراجعة غير ذاتية؛ ثم merge وفق حماية الفرع.
لا private Actions قبل التحقق من quota والفوترة. لا تدمج Draft تلقائيًا.
لا نقل private code إلى PUBLIC للتحقق. لا dependency upgrade أو CI mutation.
تبقى شروط Section 40 غير المثبتة NOT_RUN؛ لا official release أو PRODUCTION_READY.
