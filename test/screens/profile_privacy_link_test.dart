import 'package:deutsch_bilarabi/core/privacy/microphone_disclosure.dart';
import 'package:deutsch_bilarabi/screens/profile_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Settings/About shows the privacy policy link', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileHubScreen())),
    );

    expect(find.text('حول التطبيق'), findsOneWidget);
    expect(find.text(kPrivacyPolicyUrl), findsOneWidget);
    expect(find.textContaining('الميكروفون'), findsOneWidget);
  });
}
