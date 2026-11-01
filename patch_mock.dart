import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void addMockMethodChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('com.deutschbilarabi.app/offline_voice_capability'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'getOfflineVoices') {
        return ['de-DE-local', 'ar-SA-local'];
      }
      return null;
    },
  );
}
