import 'dart:async';
import 'package:flutter/widgets.dart';

/// Platform bridge contract for native WindowManager FLAG_SECURE controls.
abstract class WindowSecurityBridge {
  Future<bool> setSecureFlag(bool enabled);
  Future<bool> isSecureFlagActive();
}

/// Protects private screens from screenshots, screen-recording, and task snapshots.
class AppCloakingGuard with WidgetsBindingObserver {
  final WindowSecurityBridge bridge;

  bool _isSecureEnabled = false;
  bool _isAppObfuscated = false;

  AppCloakingGuard({required this.bridge});

  bool get isSecureEnabled => _isSecureEnabled;
  bool get isAppObfuscated => _isAppObfuscated;

  /// Initializes lifecycle listener.
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Enables or disables FLAG_SECURE dynamically.
  Future<bool> toggleSecureMode(bool enable) async {
    final success = await bridge.setSecureFlag(enable);
    if (success) {
      _isSecureEnabled = enable;
    }
    return success;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // App moving to background: cloak UI thumbnail
        _isAppObfuscated = true;
        break;
      case AppLifecycleState.resumed:
        // App returning to foreground: restore normal UI
        _isAppObfuscated = false;
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
