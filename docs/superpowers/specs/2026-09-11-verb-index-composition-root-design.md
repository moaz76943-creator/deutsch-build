# VerbIndex Composition Root Isolation — V340

## Goal

إزالة وصول واجهات V35 المباشر إلى `VerbIndex.instance` وجعل `VerbIndex` dependency صريحًا يأتي من Composition Root.

## Architecture

- `main.dart` يكوّن `VerbIndex.instance` مرة واحدة ويضعه داخل `AppDependencies`.
- `VerbConjugationPage` و`VerbFavoritesPage` تستقبلان نفس `VerbIndex` صراحةً.
- لا يتم إنشاء `VerbIndex` أو الوصول إلى singleton داخليًا في `ui_v35`.
- منطق التصريف والمفضلة والـcached groups يبقى كما هو.

## Compatibility

يبقى singleton متاحًا في Composition Root وفي أي طبقات لم تُرحّل بعد.

## Verification

- V340 focused dependency-injection tests.
- Full pytest regression.
- Security, privacy, quality, accessibility, architecture, weakness gates.
