# Pubspec Integration Requirements

To enable the multi-script fallback fonts in the Flutter application, add the following `fonts` configuration to your `pubspec.yaml` under the `flutter:` section.

```yaml
flutter:
  fonts:
    - family: Noto Sans Arabic
      fonts:
        - asset: assets/fonts/NotoSansArabic-Regular.ttf
    - family: Noto Sans Hebrew
      fonts:
        - asset: assets/fonts/NotoSansHebrew-Regular.ttf
    - family: Noto Sans Devanagari
      fonts:
        - asset: assets/fonts/NotoSansDevanagari-Regular.ttf
    - family: Noto Sans Ethiopic
      fonts:
        - asset: assets/fonts/NotoSansEthiopic-Regular.ttf
    - family: Noto Sans SC
      fonts:
        - asset: assets/fonts/NotoSansSC-Regular.otf
    - family: Noto Sans Georgian
      fonts:
        - asset: assets/fonts/NotoSansGeorgian-Regular.ttf
    - family: Noto Sans Armenian
      fonts:
        - asset: assets/fonts/NotoSansArmenian-Regular.ttf
```

**Do NOT load all 100 language font families into pubspec.yaml.**
We rely on Flutter's `fontFamilyFallback` property in `AppTypography` which lazily loads these registered fallback families to support our 100-language catalog. Eagerly declaring or loading every single script's font would needlessly consume memory and break device resource bounds.
