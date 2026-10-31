# Content Composition Root Isolation — V339

## Goal

إزالة وصول واجهات V35 المباشر إلى `ContentEngine.instance` وجعل corpus مصدر اعتماد صريحًا مركبًا مرة واحدة في Composition Root.

## Architecture

- `main.dart` هو Composition Root الذي يقرأ `ContentEngine.instance` مرة واحدة فقط ويحوّل المحتوى إلى قائمة ثابتة.
- `AppDependencies` يحمل `List<ContentItem> corpus` مع `SearchIndex` و`VerbIndex`.
- صفحات `ui_v35` تستقبل corpus صراحةً ولا تنشئ خدمات المحتوى أو الفهارس بنفسها.
- لا يتغير منطق المحتوى أو Learning Engine أو Assessment Engine؛ التغيير يخص dependency ownership فقط.

## Boundaries

`ContentEngine` يبقى مصدر تكوين مؤقتًا في Composition Root. لا يجوز لصفحات V35 الوصول إليه مباشرة.

`SearchIndex` و`VerbIndex` لا يتم إنشاؤهما داخل صفحات V35.

## Compatibility

تبقى طبقات التوافق القديمة خارج V35 إلى أن تكتمل مراحل migration اللاحقة.

## Verification

- V339 focused contract tests.
- Full pytest regression.
- Security, privacy, quality, accessibility, architecture, weakness gates.
