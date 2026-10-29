import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/features/onboarding/fast_onboarding_screen.dart';
import 'package:deutsch_bilarabi/screens/main_shell_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: FastOnboardingScreen(),
    );
  }

  testWidgets('Fresh Install: shows dropdowns and user is not navigated away', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButton<String>), findsNWidgets(3));
    expect(find.byType(MainShellScreen), findsNothing);
  });

  testWidgets('Existing Learner: automatically navigates to MainShellScreen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'has_completed_onboarding': true});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(MainShellScreen), findsOneWidget);
  });

  testWidgets('Unsupported Pair: source and target are same, shows error and no navigation', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final dropdowns = find.byType(DropdownButton<String>);
    expect(dropdowns, findsNWidgets(3));

    await tester.tap(dropdowns.last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('العربية').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Source and target languages cannot be the same.'), findsOneWidget);
    expect(find.byType(MainShellScreen), findsNothing);
  });

  testWidgets('Missing Pack / Not Ready: shows error and no navigation', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final dropdowns = find.byType(DropdownButton<String>);

    await tester.tap(dropdowns.last);
    await tester.pumpAndSettle();

    // Selecting Spanish (es-ES) which is assetsReady but not productionReady according to matrix
    await tester.tap(find.text('الإسبانية (Español)').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Target language is not yet ready for production.'), findsOneWidget);
    expect(find.byType(MainShellScreen), findsNothing);
  });

  testWidgets('Cancelled Onboarding: UI remains and preferences not saved for completion', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButton<String>), findsNWidgets(3));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_completed_onboarding'), isNull);
  });
}
