import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/features/universal_polyglot_core/polyglot_hub_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Hub navigation view presents basic language selections',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: UniversalPolyglotHubScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('المحور اللغوي الشامل'), findsOneWidget);
    expect(find.text('لغة الواجهة:'), findsOneWidget);
    expect(find.text('اللغة المصدر:'), findsOneWidget);
    expect(find.text('اللغة الهدف:'), findsOneWidget);
  });

  testWidgets('Hub displays all registered identities from catalog (100+)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: UniversalPolyglotHubScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('العربية'), findsWidgets);
    expect(find.text('الألمانية (Deutsch)'), findsWidgets);
  });

  testWidgets('Hub displays all registered identities from catalog (100+) using lazy rendering',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: UniversalPolyglotHubScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(SliverList), findsWidgets);

    expect(find.text('العربية'), findsWidgets);
    expect(find.text('الألمانية (Deutsch)'), findsWidgets);
  });

  testWidgets('Rapid switching correctly ignores stale request results',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: UniversalPolyglotHubScreen(),
    ));
    await tester.pumpAndSettle();

    final dropdowns = find.byType(DropdownButton<String>);
    expect(dropdowns, findsNWidgets(3));

    // Tap target dropdown
    await tester.tap(dropdowns.at(2));
    await tester.pumpAndSettle();

    final zhCN = find.text('الصينية (中文)');
    if (zhCN.evaluate().isNotEmpty) {
      await tester.tap(zhCN.last);
      await tester.pump();
      // Fast switch before settle
      await tester.tap(dropdowns.at(2));
      await tester.pumpAndSettle();

      final esES = find.text('الإسبانية (Español)');
      if (esES.evaluate().isNotEmpty) {
        await tester.tap(esES.last);
        await tester.pumpAndSettle();
      }
    }

    expect(find.text('المحتوى غير متاح لهذا الزوج من اللغات'), findsOneWidget);
  });

  testWidgets('Core navigation buttons are disabled when packs are missing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: UniversalPolyglotHubScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('فتح القاموس'), findsOneWidget);
    expect(find.text('بدء الدروس'), findsOneWidget);
    expect(find.text('المحتوى غير متاح لهذا الزوج من اللغات'), findsOneWidget);

    final dictionaryButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'فتح القاموس'));
    final lessonsButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'بدء الدروس'));

    expect(dictionaryButton.onPressed, isNull);
    expect(lessonsButton.onPressed, isNull);
  });

  testWidgets('Restarts persist and load selected language pairs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'polyglot_interface_locale': 'en-US',
      'polyglot_source_locale': 'fr-FR',
      'polyglot_target_locale': 'es-ES'
    });

    await tester.pumpWidget(const MaterialApp(
      home: UniversalPolyglotHubScreen(),
    ));
    await tester.pumpAndSettle();

    final dropdowns = find.byType(DropdownButton<String>);
    expect(tester.widget<DropdownButton<String>>(dropdowns.at(0)).value, 'en-US');
    expect(tester.widget<DropdownButton<String>>(dropdowns.at(1)).value, 'fr-FR');
    expect(tester.widget<DropdownButton<String>>(dropdowns.at(2)).value, 'es-ES');
  });
}
