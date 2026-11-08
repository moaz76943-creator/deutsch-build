import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/screens/verb_conjugation_screen.dart';

void main() {
  testWidgets('VerbConjugationScreen displays correct UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: VerbConjugationScreen(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(VerbConjugationScreen), findsOneWidget);
  });
}
