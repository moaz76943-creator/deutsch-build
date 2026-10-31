# Vector Asset Integration Requirement

To fully render the WordBit Carousel with `.svg` vector illustrations based on lexical concept IDs, the project requires an external vector decoding adapter.

As per architecture and memory constraints, we are not automatically adding dependencies to `pubspec.yaml` without explicit architectural approval.

### Required Dependency
```yaml
dependencies:
  flutter_svg: ^2.0.10+1  # Or the latest compatible version
```

### Affected UI Component
- `lib/features/wordbit/ui/wordbit_carousel_screen.dart`

### Current Fallback Behavior
Currently, the UI uses standard `Image.asset` assuming `.png` files as placeholders. If the file is absent or unsupported, it falls back to a semantic error widget displaying text ("صورة غير متوفرة") and an `Icons.image_not_supported` icon.

Once `flutter_svg` is integrated by the human maintainers, you will need to replace `Image.asset` with `SvgPicture.asset` to render the authentic vector files correctly.