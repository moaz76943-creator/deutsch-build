# J005 Font Integration Requirement

To fully enable the multi-script typography engine introduced in J005, the following fonts must be registered in the application's `pubspec.yaml` file. We do not automatically modify `pubspec.yaml` to ensure build stability and compliance with architecture rules. (Note: Cairo is already present in assets/fonts/Cairo-Variable.ttf but should be registered if not already).

Please merge the following `fonts` configuration into the `flutter` section of your `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Variable.ttf
    - family: Noto Sans Hebrew
      fonts:
        - asset: assets/fonts/NotoSansHebrew-Regular.ttf
    - family: Noto Sans Devanagari
      fonts:
        - asset: assets/fonts/NotoSansDevanagari-Regular.ttf
    - family: Noto Sans Ethiopic
      fonts:
        - asset: assets/fonts/NotoSansEthiopic-Regular.ttf
    - family: Noto Sans Georgian
      fonts:
        - asset: assets/fonts/NotoSansGeorgian-Regular.ttf
    - family: Noto Sans Armenian
      fonts:
        - asset: assets/fonts/NotoSansArmenian-Regular.ttf
    - family: Noto Sans SC
      fonts:
        - asset: assets/fonts/NotoSansSC-Regular.ttf
    - family: Noto Sans JP
      fonts:
        - asset: assets/fonts/NotoSansJP-Regular.ttf
    - family: Noto Sans KR
      fonts:
        - asset: assets/fonts/NotoSansKR-Regular.ttf
```