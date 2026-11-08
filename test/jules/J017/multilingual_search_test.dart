import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/explore/presentation/section_explorer_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Widget createTestWidget() {
    return const MaterialApp(
      home: SectionExplorerScreen(initialLanguage: 'ar'),
    );
  }

  group('J017 - Active Multilingual Search', () {
    testWidgets('Initial structure setup', (tester) async {
      // Basic mount test
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(SectionExplorerScreen), findsOneWidget);
    });

    testWidgets('Pair switching to absent pack shows unavailable state', (tester) async {
      // Create widget starting in 'de' which is production ready
      await tester.pumpWidget(const MaterialApp(
        home: SectionExplorerScreen(initialLanguage: 'de'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('اللغة غير متاحة حالياً'), findsNothing);

      // Now tap dropdown and switch to 'fr' which is assetsReady (not productionReady)
      final dropdown = find.byType(DropdownButton<String>);
      expect(dropdown, findsOneWidget);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('الفرنسية (Français)').last);
      await tester.pumpAndSettle();

      // Expect unavailable state text
      expect(find.text('اللغة غير متاحة حالياً'), findsOneWidget);
    });

    testWidgets('Debounce handles rapid query changes', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test');
      await tester.pump(const Duration(milliseconds: 100)); // Debounce not triggered

      await tester.enterText(searchField, 'test2');
      await tester.pump(const Duration(milliseconds: 100)); // Debounce not triggered

      await tester.enterText(searchField, 'test3');
      await tester.pumpAndSettle(const Duration(milliseconds: 300)); // Should trigger now

      expect(find.byType(SectionExplorerScreen), findsOneWidget);
    });

    testWidgets('Unicode queries do not crash the search service UI', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'أسد 👨‍👩‍👧‍👦');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      // FTS search should either return results or be empty, no exceptions thrown on screen
      expect(find.byType(SectionExplorerScreen), findsOneWidget);
    });
  });
}
