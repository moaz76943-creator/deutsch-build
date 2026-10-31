import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/features/onboarding/fast_onboarding_screen.dart';
import 'package:deutsch_bilarabi/screens/main_shell_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Fresh install shows language selection', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FastOnboardingScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('I speak (Interface Language):'), findsOneWidget);
    expect(find.text('I want to learn:'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));

    // Start button should be disabled initially
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('Cannot select same language for source and target', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FastOnboardingScreen()));
    await tester.pumpAndSettle();

    // Select source
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    // Select target
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    // Start button should still be disabled
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
    expect(button.onPressed, isNull);
  });

  testWidgets('Valid selection navigates to main shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FastOnboardingScreen()));
    await tester.pumpAndSettle();

    // Select source
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    // Select target (de is production ready)
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch').last);
    await tester.pumpAndSettle();

    // Start button should be enabled
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
    expect(button.onPressed, isNotNull);

    // Tap start
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Should navigate to MainShellScreen
    expect(find.byType(MainShellScreen), findsOneWidget);
  });

  testWidgets('Unsupported target shows missing pack state', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FastOnboardingScreen()));
    await tester.pumpAndSettle();

    // Select source
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    // Select target (fr is NOT production ready)
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français').last);
    await tester.pumpAndSettle();

    // Tap start
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Should show missing pack message
    expect(find.text('Language pack unavailable.'), findsOneWidget);

    // Tap go back
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();

    // Should be back at selection screen
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('Existing learner skips selection', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_source': 'en',
      'onboarding_target': 'de',
    });

    await tester.pumpWidget(const MaterialApp(home: FastOnboardingScreen()));
    await tester.pumpAndSettle();

    // Should skip directly to MainShellScreen
    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
  });

  testWidgets('Cancelled onboarding (going back from missing pack) resets state', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FastOnboardingScreen()));
    await tester.pumpAndSettle();

    // Select source
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    // Select target (fr is NOT production ready)
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français').last);
    await tester.pumpAndSettle();

    // Tap start
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Should show missing pack message
    expect(find.text('Language pack unavailable.'), findsOneWidget);

    // Tap go back to cancel
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();

    // Should be back at selection screen with selections preserved
    expect(find.text('Welcome'), findsOneWidget);

    // Check if dropdowns still hold values (implicitly checked because the button should be enabled)
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
    expect(button.onPressed, isNotNull);
  });
}
