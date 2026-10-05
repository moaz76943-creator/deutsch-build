import 'package:deutsch_bilarabi/features/grammar/presentation/widgets/explain_why_feedback_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Explain Why feedback card exposes deterministic explanation text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExplainWhyFeedbackCard(
            explanation: 'mit يطلب Dativ؛ لذلك der → dem.',
            reasonCode: 'grammar.case.preposition',
            correct: false,
          ),
        ),
      ),
    );

    expect(find.text('لماذا؟'), findsOneWidget);
    expect(find.textContaining('mit يطلب Dativ'), findsOneWidget);
    expect(
      find.byKey(const Key('explain-why-feedback-card')),
      findsOneWidget,
    );
  });
}
