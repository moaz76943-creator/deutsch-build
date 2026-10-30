enum IosAudioCategory {
  playAndRecord,
  playbackOnly,
  ambientSolely,
}

class IosPlatformCapabilities {
  final bool hasMetalSupport;
  final bool hasAppleNeuralEngine;
  final bool isSandboxEnforced;
  final String sovereignStoragePath;

  const IosPlatformCapabilities({
    required this.hasMetalSupport,
    required this.hasAppleNeuralEngine,
    required this.isSandboxEnforced,
    required this.sovereignStoragePath,
  });

  Map<String, dynamic> toJson() => {
    'hasMetalSupport': hasMetalSupport,
    'hasAppleNeuralEngine': hasAppleNeuralEngine,
    'isSandboxEnforced': isSandboxEnforced,
    'sovereignStoragePath': sovereignStoragePath,
  };
}

class IosMetalBridgeEngine {
  const IosMetalBridgeEngine();

  /// Configures native AVAudioSession properties for zero-latency duplex speech.
  Map<String, dynamic> configureAudioSession({
    IosAudioCategory category = IosAudioCategory.playAndRecord,
    bool allowBluetooth = true,
    bool defaultToSpeaker = true,
  }) {
    return {
      'category': category.name,
      'mode': 'voiceChat',
      'options': [
        if (allowBluetooth) 'allowBluetooth',
        if (allowBluetooth) 'allowBluetoothA2DP',
        if (defaultToSpeaker) 'defaultToSpeaker',
      ],
      'preferredSampleRate': 24000.0,
      'preferredIoBufferDuration': 0.005, // 5ms buffer for low latency
    };
  }

  /// Generates the mandatory iOS Info.plist privacy keys with educational sovereign justifications.
  Map<String, String> generatePrivacyEntitlements() {
    return {
      'NSMicrophoneUsageDescription':
          'Polyglot nutzt das Mikrofon ausschließlich für die lokale, ungespeicherte Ausspracheanalyse direkt auf Ihrem Gerät.',
      'NSSpeechRecognitionUsageDescription':
          'Die Spracherkennung erfolgt vollständig offline über integrierte neuronale Modelle ohne Internetübertragung.',
      'ITSAppUsesNonExemptEncryption': 'false',
    };
  }

  /// Resolves sandboxed sovereign app support directory.
  IosPlatformCapabilities resolveCapabilities({bool isSimulator = false}) {
    return IosPlatformCapabilities(
      hasMetalSupport: !isSimulator,
      hasAppleNeuralEngine: !isSimulator,
      isSandboxEnforced: true,
      sovereignStoragePath: '/var/mobile/Containers/Data/Application/Polyglot/Library/Application Support',
    );
  }
}
