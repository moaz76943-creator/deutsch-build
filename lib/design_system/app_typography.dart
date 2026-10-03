import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextDirection {
  static TextDirection forLanguageCode(String languageCode) {
    final code = languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;
    return switch (code) {
      'ar' || 'fa' || 'ur' => TextDirection.rtl,
      _ => TextDirection.ltr,
    };
  }
}

abstract final class AppTypography {
  static TextStyle get display => GoogleFonts.cairo(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        height: 1.18,
      );

  static TextStyle get title => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.3,
      );

  static TextStyle get body => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.55,
      );

  static TextStyle get label => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.35,
      );
}

class AppDirectionalText extends StatelessWidget {
  const AppDirectionalText(
    this.text, {
    required this.languageCode,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String text;
  final String languageCode;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppTextDirection.forLanguageCode(languageCode),
      child: Text(
        text,
        style: style ?? AppTypography.body,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
