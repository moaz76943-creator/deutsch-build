import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/design_system/multi_script_typography.dart';
import 'package:deutsch_bilarabi/design_system/app_typography.dart';
import 'package:deutsch_bilarabi/core/text/language_identity.dart';

void main() {
  testWidgets('MultiScriptTypography handles mixed script', (WidgetTester tester) async {
    const text = 'Hello مرحباً';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScriptAwareText(text),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.style?.fontFamilyFallback, contains('Cairo'));
  });

  testWidgets('MultiScriptTypography handles CJK SC', (WidgetTester tester) async {
    const text = 'Hello 世界';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScriptAwareText(text),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansSC'));
  });

  testWidgets('MultiScriptTypography handles Devanagari', (WidgetTester tester) async {
    const text = 'Hello नमस्ते';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScriptAwareText(text),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansDevanagari'));
  });

  testWidgets('MultiScriptTypography handles Georgian', (WidgetTester tester) async {
    const text = 'Hello გამარჯობა';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScriptAwareText(text),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansGeorgian'));
  });

  testWidgets('MultiScriptTypography handles Armenian', (WidgetTester tester) async {
    const text = 'Hello Բարեւ';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScriptAwareText(text),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.style?.fontFamilyFallback, contains('NotoSansArmenian'));
  });
}
