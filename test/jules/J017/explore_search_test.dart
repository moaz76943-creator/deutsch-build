import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/features/explore/presentation/section_explorer_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('SectionExplorerScreen test with proper FTS5 interactions',
      (tester) async {
    // Basic test ensuring FTS UI hooks are functioning (e.g. scroll controller, list item)
    await tester.pumpWidget(const MaterialApp(
      home: SectionExplorerScreen(initialLanguage: 'de'),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);

    // Simulate user search in German
    await tester.enterText(find.byType(TextField), 'Test search');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.textContaining('Test search'), findsNothing);

    // Switch pair (language identity isolation)
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();

    await tester.tap(find.text('العربية (العربية)').last);
    await tester.pumpAndSettle();

    // Arabic RTL search query interaction
    await tester.enterText(find.byType(TextField), 'اختبار البحث');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  });
}
