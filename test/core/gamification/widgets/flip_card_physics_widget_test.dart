import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/gamification/widgets/flip_card_physics_widget.dart';

void main() {
  group('FlipCardPhysicsWidget Tests', () {
    testWidgets('Renders front face initially and flips to back face on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardPhysicsWidget(
              front: Text('Front: Wort'),
              back: Text('Back: كلمة'),
            ),
          ),
        ),
      );

      expect(find.text('Front: Wort'), findsOneWidget);

      await tester.tap(find.byType(FlipCardPhysicsWidget));
      await tester.pumpAndSettle();

      expect(find.text('Back: كلمة'), findsOneWidget);
    });
  });
}
