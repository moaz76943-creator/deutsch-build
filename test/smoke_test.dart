import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/main.dart';
import 'package:deutsch_bilarabi/features/onboarding/fast_onboarding_screen.dart';

void main() {
  testWidgets('App Launch Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const DeutschApp());
    expect(find.byType(FastOnboardingScreen), findsOneWidget);
  });
}
