import 'package:deutsch_bilarabi/core/privacy/microphone_disclosure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(PronunciationSignalProbe.channelName);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('the system permission is not requested before consent',
      (tester) async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return true;
    });

    final probe = PronunciationSignalProbe();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => probe.requestPermission(context),
            child: const Text('train'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('train'));
    await tester.pumpAndSettle();

    expect(find.text(kMicrophoneDisclosureText), findsOneWidget);
    expect(calls, isEmpty);

    await tester.tap(find.text('رفض'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);

    await tester.tap(find.text('train'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('موافق'));
    await tester.pumpAndSettle();
    expect(calls, <String>['requestPermission']);
  });
}
