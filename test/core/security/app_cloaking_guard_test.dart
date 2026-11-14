import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/security/app_cloaking_guard.dart';

class MockWindowSecurityBridge implements WindowSecurityBridge {
  bool flagSecure = false;

  @override
  Future<bool> setSecureFlag(bool enabled) async {
    flagSecure = enabled;
    return true;
  }

  @override
  Future<bool> isSecureFlagActive() async => flagSecure;
}

void main() {
  group('AppCloakingGuard Security Tests', () {
    late MockWindowSecurityBridge bridge;
    late AppCloakingGuard guard;

    setUp(() {
      bridge = MockWindowSecurityBridge();
      guard = AppCloakingGuard(bridge: bridge);
    });

    test('Enables FLAG_SECURE on demand', () async {
      expect(guard.isSecureEnabled, isFalse);

      final success = await guard.toggleSecureMode(true);
      expect(success, isTrue);
      expect(guard.isSecureEnabled, isTrue);
      expect(bridge.flagSecure, isTrue);
    });

    test('Obfuscates UI when app lifecycle transitions to paused/inactive', () {
      expect(guard.isAppObfuscated, isFalse);

      guard.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(guard.isAppObfuscated, isTrue);

      guard.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(guard.isAppObfuscated, isFalse);
    });
  });
}
