import '../language/app_text_direction.dart';
import 'locale_direction_provider.dart';

/// Framework-neutral locale value used by Core.
final class AppLocale {
  final String languageCode;
  final String? regionCode;
  final AppTextDirection direction;

  const AppLocale._({
    required this.languageCode,
    required this.regionCode,
    required this.direction,
  });

  factory AppLocale.parse(String languageTag) {
    final normalized = languageTag.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(languageTag, 'languageTag', 'must not be empty');
    }
    final parts = normalized.split(RegExp(r'[-_]'));
    final language = parts.first.toLowerCase();
    final region = parts.length > 1 && parts[1].isNotEmpty
        ? parts[1].toUpperCase()
        : null;
    return AppLocale._(
      languageCode: language,
      regionCode: region,
      direction: LocaleDirectionProvider.resolve(language),
    );
  }

  String get languageTag =>
      regionCode == null ? languageCode : '$languageCode-$regionCode';

  bool get isRtl => direction == AppTextDirection.rtl;
}

/// Read-only contract consumed by application/presentation composition.
abstract interface class LocaleProvider {
  AppLocale get userLocale;
  AppLocale get sourceLocale;
  AppLocale get targetLocale;
}
