import 'package:deutsch_bilarabi/screens/dictation_trainer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dictation releases its answer controller on screen removal',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DictationTrainerScreen()),
    );
    final controller = tester.widget<TextField>(find.byType(TextField)).controller;
    expect(controller, isNotNull);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    expect(() => controller!.addListener(() {}), throwsFlutterError);
  });
}
