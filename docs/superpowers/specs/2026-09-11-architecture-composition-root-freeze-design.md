# Architecture Composition Root & Freeze Design — V341–V345

## Goal

إغلاق الاعتماديات العالمية المتبقية تدريجيًا، وجعل Composition Root المكان الوحيد لتركيب الخدمات والـcontent/index dependencies، ثم تثبيت قاعدة معمارية تمنع عودة الـcoupling.

## Architecture

`main.dart` هو Composition Root. ينشئ corpus وSearchIndex وVerbIndex ويضعها في `AppDependencies`. الواجهات والخدمات تستقبل الاعتماديات صراحةً. تبقى facades القديمة فقط للتوافق المؤقت، ولا تُستخدم من المسارات الحديثة.

## Phases

- V341: إزالة `ContentEngine.instance` و`VerbIndex.instance` من `lib/ui/app.dart` عبر `AppDependencies`.
- V342: إزالة fallback `ContentEngine.instance` من `MasteryDashboard` وجعل `corpus` dependency صريحة، مع تحديث جميع callers.
- V343: حصر إنشاء dependency graph في `main.dart` ومنع إنشاء services أو repositories داخل UI الحديثة.
- V344: global singleton audit وتصنيف كل نتيجة داخل lib/.
- V345: architecture baseline/freeze contract يمنع عودة global lookup إلى Core/V35/Services canonical.

## Non-goals

لا تغيير في المحتوى، scoring، SRS، Mastery algorithms، auth protocol، subscription semantics، network protocol، أو learner-data semantics.

## Verification

لكل مرحلة: TDD RED → minimal GREEN → full pytest → security/privacy/quality/accessibility/architecture/weakness gates. لا يتم ادعاء Flutter analyze/build لأن Flutter/Dart غير مثبتين في بيئة التنفيذ الحالية.
