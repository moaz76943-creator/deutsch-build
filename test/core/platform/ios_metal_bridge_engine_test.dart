import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/platform/ios_metal_bridge_engine.dart';

void main() {
  group('IosMetalBridgeEngine Tests', () {
    const engine = IosMetalBridgeEngine();

    test('Audio session configures ultra-low 5ms buffer duration with speaker default', () {
      final config = engine.configureAudioSession(
        category: IosAudioCategory.playAndRecord,
        allowBluetooth: true,
        defaultToSpeaker: true,
      );

      expect(config['category'], equals('playAndRecord'));
      expect(config['mode'], equals('voiceChat'));
      expect((config['options'] as List).contains('defaultToSpeaker'), isTrue);
      expect((config['options'] as List).contains('allowBluetooth'), isTrue);
      expect(config['preferredIoBufferDuration'], equals(0.005));
    });

    test('Generates strict German offline privacy entitlements for iOS App Store review', () {
      final keys = engine.generatePrivacyEntitlements();

      expect(keys.containsKey('NSMicrophoneUsageDescription'), isTrue);
      expect(keys['NSMicrophoneUsageDescription'], contains('lokale, ungespeicherte Ausspracheanalyse'));
      expect(keys['NSSpeechRecognitionUsageDescription'], contains('vollständig offline'));
      expect(keys['ITSAppUsesNonExemptEncryption'], equals('false'));
    });

    test('Platform capabilities verify Metal and sandboxed storage envelope', () {
      final caps = engine.resolveCapabilities(isSimulator: false);

      expect(caps.hasMetalSupport, isTrue);
      expect(caps.hasAppleNeuralEngine, isTrue);
      expect(caps.isSandboxEnforced, isTrue);
      expect(caps.sovereignStoragePath, contains('Application Support'));
    });
  });
}
