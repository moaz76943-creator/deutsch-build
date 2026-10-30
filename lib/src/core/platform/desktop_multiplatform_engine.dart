enum DesktopOsType {
  linux,
  macos,
  windows,
}

class DesktopWindowConfig {
  final double defaultWidth;
  final double defaultHeight;
  final double minWidth;
  final double minHeight;
  final bool rememberLastPosition;

  const DesktopWindowConfig({
    this.defaultWidth = 1100.0,
    this.defaultHeight = 750.0,
    this.minWidth = 800.0,
    this.minHeight = 600.0,
    this.rememberLastPosition = true,
  });

  Map<String, dynamic> toJson() => {
    'defaultWidth': defaultWidth,
    'defaultHeight': defaultHeight,
    'minWidth': minWidth,
    'minHeight': minHeight,
    'rememberLastPosition': rememberLastPosition,
  };
}

class DesktopMultiplatformEngine {
  const DesktopMultiplatformEngine();

  /// Resolves the standard sovereign offline storage path per desktop operating system.
  String resolveStoragePath(DesktopOsType os, {String homeDir = '/home/user'}) {
    switch (os) {
      case DesktopOsType.linux:
        return '$homeDir/.local/share/polyglot_sovereign';
      case DesktopOsType.macos:
        return '$homeDir/Library/Application Support/PolyglotSovereign';
      case DesktopOsType.windows:
        return 'C:\\Users\\user\\AppData\\Roaming\\PolyglotSovereign';
    }
  }

  /// Maps physical keyboard shortcut keycode to study action.
  String handleKeyboardShortcut(String keyLabel, {bool isControlPressed = false, bool isAltPressed = false}) {
    switch (keyLabel.toLowerCase()) {
      case ' ':
      case 'space':
        return 'ACTION_FLIP_FLASHCARD';
      case '1':
        return 'ACTION_FSRS_AGAIN';
      case '2':
        return 'ACTION_FSRS_HARD';
      case '3':
        return 'ACTION_FSRS_GOOD';
      case '4':
        return 'ACTION_FSRS_EASY';
      case 'enter':
        if (isControlPressed) {
          return 'ACTION_SUBMIT_DIALOGUE_TURN';
        }
        return 'ACTION_CONFIRM_SELECTION';
      default:
        return 'ACTION_NONE';
    }
  }

  /// Builds platform notification payload for study reminders without third-party push services.
  Map<String, String> buildLocalNotificationPayload({
    required String title,
    required String body,
    required DesktopOsType os,
  }) {
    return {
      'title': title,
      'body': body,
      'appId': 'com.deutsch.polyglot',
      'urgency': os == DesktopOsType.linux ? 'normal' : 'default',
    };
  }
}
