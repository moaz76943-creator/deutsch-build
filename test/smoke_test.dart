import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';
import '../lib/features/onboarding/fast_onboarding_screen.dart';

void main() {
  testWidgets('App Launch Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const DeutschApp());
    expect(find.byType(FastOnboardingScreen), findsOneWidget);
  });
}
