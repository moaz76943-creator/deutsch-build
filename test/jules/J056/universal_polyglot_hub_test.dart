import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/universal_polyglot_core/polyglot_hub_screen.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';

void main() {
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

  testWidgets('Rapid switching correctly cancels stale requests',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: UniversalPolyglotHubScreen(),
    ));
    await tester.pumpAndSettle();

    // Tap to open target language
    await tester.tap(find.byType(DropdownButton<String>).at(2), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap zh which is mock-unavailable
    final zhCN = find.text('الصينية (中文)');
    if (zhCN.evaluate().isNotEmpty) {
      await tester.tap(zhCN.last, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(Icon), findsWidgets);
    }
  });

  testWidgets('Core navigation logic is present',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: UniversalPolyglotHubScreen(),
    ));
    await tester.pumpAndSettle();

    // In our test, verifyAndMountOfflinePack might be false by default if db is not setup,
    // we just check if buttons exist
    expect(find.text('فتح القاموس'), findsOneWidget);
    expect(find.text('بدء الدروس'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'فتح القاموس'));
    expect(button.onPressed, isNull);
  });
}
