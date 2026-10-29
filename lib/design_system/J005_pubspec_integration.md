# J005 Font Integration Requirement

To fully enable the multi-script typography engine introduced in J005, the following fonts must be registered in the application's `pubspec.yaml` file. We do not automatically modify `pubspec.yaml` to ensure build stability and compliance with architecture rules. (Note: Cairo is already present in assets/fonts/Cairo-Variable.ttf but should be registered if not already).

Please merge the following `fonts` configuration into the `flutter` section of your `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Variable.ttf
    - family: NotoSansHebrew
      fonts:
        - asset: assets/fonts/NotoSansHebrew.ttf
    - family: NotoSansDevanagari
      fonts:
        - asset: assets/fonts/NotoSansDevanagari.ttf
    - family: NotoSansEthiopic
      fonts:
        - asset: assets/fonts/NotoSansEthiopic.ttf
    - family: NotoSansGeorgian
      fonts:
        - asset: assets/fonts/NotoSansGeorgian.ttf
    - family: NotoSansArmenian
      fonts:
        - asset: assets/fonts/NotoSansArmenian.ttf
    - family: NotoSansSC
      fonts:
        - asset: assets/fonts/NotoSansSC.ttf
    - family: NotoSansJP
      fonts:
        - asset: assets/fonts/NotoSansJP.ttf
    - family: NotoSansKR
      fonts:
        - asset: assets/fonts/NotoSansKR.ttf
```