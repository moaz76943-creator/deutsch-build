# Pubspec Registration Requirement

To fully enable the fallback fonts added in this task, the following fonts must be registered in the `pubspec.yaml` under the `flutter:` section.

```yaml
flutter:
  fonts:
    - family: NotoSansHebrew
      fonts:
        - asset: assets/fonts/NotoSansHebrew-Regular.ttf
    - family: NotoSansDevanagari
      fonts:
        - asset: assets/fonts/NotoSansDevanagari-Regular.ttf
    - family: NotoSansEthiopic
      fonts:
        - asset: assets/fonts/NotoSansEthiopic-Regular.ttf
    - family: NotoSansGeorgian
      fonts:
        - asset: assets/fonts/NotoSansGeorgian-Regular.ttf
    - family: NotoSansArmenian
      fonts:
        - asset: assets/fonts/NotoSansArmenian-Regular.ttf
    - family: NotoSansCJK
      fonts:
        - asset: assets/fonts/NotoSansCJK-Regular.ttc
```
