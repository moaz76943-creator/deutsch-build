<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/widgets/app_directional_text.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';
import 'package:deutsch_bilarabi/core/design/bidi_text_isolator.dart';

class AccessibleMultilingualText extends StatelessWidget {
  final String text;
  final String locale;
  final TextStyle? style;
  final String? semanticLabel;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AccessibleMultilingualText(
    this.text, {
    super.key,
    required this.locale,
    this.style,
    this.semanticLabel,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final direction = LanguageBiDiHelper.getDirection(locale);
    final isRtl = direction == TextDirection.rtl;
    final lineHeight = LanguageBiDiHelper.getLineHeight(locale);

    // Protect text selection, URLs and embedded punctuation using isolation markers.
    final isolatedText = BiDiTextIsolator.wrapDirectional(text, isRtl: isRtl);

    final defaultStyle = style ?? const TextStyle();
    final combinedStyle = defaultStyle.copyWith(
      height: defaultStyle.height ?? lineHeight,
    );

    return Semantics(
      label: semanticLabel ?? text,
      textDirection: direction,
      child: ExcludeSemantics(
        child: AppDirectionalText(
          isolatedText,
          style: combinedStyle,
          forceDirection: direction,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
=======
import 'dart:ui' show LocaleStringAttribute, TextRange;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// One accessible phrase with locale-marked announcement and visible text.
/// OS voice choice also depends on installed TalkBack/VoiceOver voices.
class AccessibleMultilingualText extends StatelessWidget {
  const AccessibleMultilingualText({
    super.key,
    required this.text,
    required this.languageTag,
    this.style,
    this.textAlign,
    this.textDirection,
  });

  final String text;
  final String languageTag;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  static const _rtlLanguages = <String>{
    'ar', 'fa', 'he', 'ur', 'ps', 'dv', 'sd', 'ug', 'yi',
  };

  /// Flutter Locale supports language, optional script, and region subtags.
  /// Unsupported BCP-47 extensions degrade to device-voice semantics rather
  /// than passing a false language hint to assistive technologies.
  static Locale? parseLanguageTag(String tag) {
    final normalized = tag.trim().replaceAll('_', '-');
    if (!RegExp(r'^[A-Za-z]{2,3}(?:-[A-Za-z]{4})?(?:-(?:[A-Za-z]{2}|[0-9]{3}))?$')
        .hasMatch(normalized)) {
      return null;
    }
    final parts = normalized.split('-');
    final language = parts.first.toLowerCase();
    String? script;
    String? region;
    for (final part in parts.skip(1)) {
      if (part.length == 4) {
        script = part[0].toUpperCase() + part.substring(1).toLowerCase();
      } else {
        region = part.toUpperCase();
      }
    }
    return Locale.fromSubtags(
      languageCode: language,
      scriptCode: script,
      countryCode: region,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final locale = parseLanguageTag(languageTag);
    final language = locale?.languageCode ?? '';
    final direction = textDirection ??
        (_rtlLanguages.contains(language) ? TextDirection.rtl : TextDirection.ltr);
    final label = AttributedString(
      text,
      attributes: locale == null
          ? const <StringAttribute>[]
          : <StringAttribute>[
              LocaleStringAttribute(
                range: TextRange(start: 0, end: text.length),
                locale: locale,
              ),
            ],
    );

    return Semantics(
      container: true,
      textDirection: direction,
      attributedLabel: label,
      // No duplicate value: Android reads value + label together.
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(text: text, locale: locale, style: style),
          textDirection: direction,
          textAlign: textAlign,
>>>>>>> pr-179
        ),
      ),
    );
  }
}
