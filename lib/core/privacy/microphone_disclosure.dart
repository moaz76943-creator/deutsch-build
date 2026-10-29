import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Public privacy policy. Shown from Settings/About and opened in the browser.
const String kPrivacyPolicyUrl =
    'https://moaz76943-creator.github.io/deutsch-bilarabi-privacy/privacy.html';

const String kMicrophoneDisclosureText =
    'يُستخدم الميكروفون فقط لتدريب النطق على هذا الجهاز. لا يُرفع التسجيل إلى خادم. يمكنك الرفض، ولن يظهر إذن النظام قبل موافقتك هنا.';

/// In-app explanation that must be accepted before the OS microphone dialog.
Future<bool> showMicrophoneDisclosure(BuildContext context) async {
  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('استخدام الميكروفون'),
        content: const Text(kMicrophoneDisclosureText),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('رفض'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('موافق'),
          ),
        ],
      );
    },
  );
  return accepted == true;
}

/// Dart gate for [AndroidPronunciationSignalProbe]. The OS permission request
/// runs only after [showMicrophoneDisclosure] returns true.
class PronunciationSignalProbe {
  PronunciationSignalProbe({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName =
      'com.deutschbilarabi.app/pronunciation_signal';

  final MethodChannel _channel;

  Future<bool> requestPermission(BuildContext context) async {
    final accepted = await showMicrophoneDisclosure(context);
    if (!accepted) return false;
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      return granted == true;
    } catch (_) {
      return false;
    }
  }
}
