import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';

void main() {
  testWidgets('AppTypography applies fallback fonts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text(
                'مرحبا Hello שלום नमस्ते ሰላም გამარჯობა Բարեւ 你好',
                style: AppTypography.body,
              ),
            ],
          ),
        ),
      ),
    );

    final textFinder = find.text('مرحبا Hello שלום नमस्ते ሰላም გამარჯობა Բարեւ 你好');
    expect(textFinder, findsOneWidget);

    final Text textWidget = tester.widget(textFinder);
    expect(textWidget.style?.fontFamily, 'Cairo');
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansHebrew'));
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansDevanagari'));
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansEthiopic'));
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansGeorgian'));
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansArmenian'));
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansCJK'));
  });
}
