import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/main.dart';
import 'package:deutsch_bilarabi/core/bootstrap/startup_boundary.dart';
import 'package:deutsch_bilarabi/features/onboarding/fast_onboarding_screen.dart';

void main() {
  testWidgets('App Launch Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const DeutschApp());
    expect(find.byType(StartupBoundary), findsOneWidget);
    // Keep first-run onboarding and returning-learner routing behind the
    // resilient startup boundary. The section explorer is a feature, not a
    // replacement for the application shell or saved learner progress.
    final boundary =
        tester.widget<StartupBoundary>(find.byType(StartupBoundary));
    expect(boundary.child, isA<FastOnboardingScreen>());
    // Let the boot timeout and stability window fire so no timer outlives the test.
    await tester.pump(const Duration(seconds: 25));
    await tester.pumpWidget(const SizedBox());
  });
}
