import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';
import '../lib/features/onboarding/fast_onboarding_screen.dart';

void main() {
  testWidgets('Simulate app launch and onboarding tap', (WidgetTester tester) async {
    // تشغيل التطبيق في المحاكي البرمجي
    await tester.pumpWidget(const DeutschApp());
    expect(find.byType(FastOnboardingScreen), findsOneWidget);

    // محاكاة الضغط على زر ابدأ التعلم الآن
    final startButton = find.text('ابدأ التعلم الآن');
    if (startButton.evaluate().isNotEmpty) {
      await tester.tap(startButton);
      await tester.pumpAndSettle();
    }
  });
}
