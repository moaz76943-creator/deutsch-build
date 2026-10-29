import '../language/app_text_direction.dart';
import 'directional_text.dart';

abstract final class BidiBoundary {
  static const String lri = '\u2066';
  static const String rli = '\u2067';
  static const String fsi = '\u2068';
  static const String pdi = '\u2069';

  static String isolate(DirectionalText value) {
    final prefix = switch (value.direction) {
      AppTextDirection.ltr => lri,
      AppTextDirection.rtl => rli,
    };
    return prefix + value.text + pdi;
  }

  static String isolateUnknown(String text) => fsi + text + pdi;

  static String join(
    Iterable<DirectionalText> segments, {
    String separator = '',
  }) =>
      segments.map(isolate).join(separator);
}
