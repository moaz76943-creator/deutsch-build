import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'package:deutsch_bilarabi/core/text/language_identity.dart';

void main() {
  testWidgets('Typography applies correct fallbacks and directionality', (WidgetTester tester) async {
    const arabicIdentity = LanguageIdentity(
      languageCode: 'ar',
      writingDirection: WritingDirection.rtl,
      typographyProfile: 'arabic',
      tokenizerProfile: 'default',
      normalizationProfile: 'default',
    );

    const georgianIdentity = LanguageIdentity(
      languageCode: 'ka',
      writingDirection: WritingDirection.ltr,
      typographyProfile: 'georgian',
      tokenizerProfile: 'default',
      normalizationProfile: 'default',
    );

    final arabicStyle = AppTypography.getSafeStyle(arabicIdentity);
    expect(arabicStyle.fontFamilyFallback, contains('NotoSansArabic'));
    expect(arabicStyle.height, 1.2);

    final georgianStyle = AppTypography.getSafeStyle(georgianIdentity);
    expect(georgianStyle.fontFamilyFallback, contains('NotoSansGeorgian'));

    const cairoIdentity = LanguageIdentity(
      languageCode: 'ar',
      writingDirection: WritingDirection.rtl,
      typographyProfile: 'cairo',
      tokenizerProfile: 'default',
      normalizationProfile: 'default',
    );
    final cairoStyle = AppTypography.getSafeStyle(cairoIdentity);
    expect(cairoStyle.fontFamily, 'Cairo');
    expect(cairoStyle.fontFamilyFallback, contains('NotoSansArabic'));
    expect(cairoStyle.height, 1.45);

    // Test Widget Rendering for RTL
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppTypography.buildBiDiText('مرحبا', arabicIdentity),
      ),
    ));

    final directionality = tester.widget<Directionality>(
      find.ancestor(of: find.text('مرحبا'), matching: find.byType(Directionality)).first
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });
}
