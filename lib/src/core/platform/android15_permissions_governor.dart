enum SovereignPermissionType {
  recordAudio,
  bluetoothConnect,
  postNotifications,
  mediaPlaybackForeground,
}

class PermissionRationaleDetail {
  final SovereignPermissionType type;
  final String androidManifestKey;
  final String userTitle;
  final String privacyGuaranteeExplanation;
  final bool isStrictlyOptional;

  const PermissionRationaleDetail({
    required this.type,
    required this.androidManifestKey,
    required this.userTitle,
    required this.privacyGuaranteeExplanation,
    required this.isStrictlyOptional,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'androidManifestKey': androidManifestKey,
    'userTitle': userTitle,
    'privacyGuaranteeExplanation': privacyGuaranteeExplanation,
    'isStrictlyOptional': isStrictlyOptional,
  };
}

class Android15PermissionsGovernor {
  final Map<SovereignPermissionType, bool> _permissionState = {};

  Android15PermissionsGovernor() {
    for (final p in SovereignPermissionType.values) {
      _permissionState[p] = false;
    }
  }

  /// Returns user-facing privacy explanation before triggering OS permission popup.
  PermissionRationaleDetail getRationale(SovereignPermissionType type) {
    switch (type) {
      case SovereignPermissionType.recordAudio:
        return const PermissionRationaleDetail(
          type: SovereignPermissionType.recordAudio,
          androidManifestKey: 'android.permission.RECORD_AUDIO',
          userTitle: 'Mikrofon für Aussprachetraining',
          privacyGuaranteeExplanation:
              '100% Offline: Deine Stimme wird ausschließlich lokal im flüchtigen Speicher verarbeitet und niemals gespeichert oder übertragen.',
          isStrictlyOptional: true, // If denied, user types via keyboard
        );

      case SovereignPermissionType.bluetoothConnect:
        return const PermissionRationaleDetail(
          type: SovereignPermissionType.bluetoothConnect,
          androidManifestKey: 'android.permission.BLUETOOTH_CONNECT',
          userTitle: 'Bluetooth für Kopfhörer & lokale Duelle',
          privacyGuaranteeExplanation:
              'Wird für kabellose Headsets mit extrem geringer Latenz und Offline-P2P-Duelle benötigt.',
          isStrictlyOptional: true,
        );

      case SovereignPermissionType.postNotifications:
        return const PermissionRationaleDetail(
          type: SovereignPermissionType.postNotifications,
          androidManifestKey: 'android.permission.POST_NOTIFICATIONS',
          userTitle: 'Lern-Erinnerungen',
          privacyGuaranteeExplanation:
              'Erinnert dich diskret an deine täglichen Wiederholungen ganz ohne externe Cloud-Dienste.',
          isStrictlyOptional: true,
        );

      case SovereignPermissionType.mediaPlaybackForeground:
        return const PermissionRationaleDetail(
          type: SovereignPermissionType.mediaPlaybackForeground,
          androidManifestKey: 'android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK',
          userTitle: 'Hintergrund-Audiowiedergabe',
          privacyGuaranteeExplanation:
              'Ermöglicht das Anhören von Dialogen und Geschichten bei gesperrtem Bildschirm.',
          isStrictlyOptional: false,
        );
    }
  }

  /// Sets permission status.
  void updatePermissionStatus(SovereignPermissionType type, bool isGranted) {
    _permissionState[type] = isGranted;
  }

  bool isGranted(SovereignPermissionType type) => _permissionState[type] ?? false;

  /// Graceful degradation strategy when permission is rejected by user.
  String resolveFallbackStrategy(SovereignPermissionType type) {
    switch (type) {
      case SovereignPermissionType.recordAudio:
        return 'FALLBACK_KEYBOARD_TEXT_INPUT: Switching seamlessly to on-screen keyboard input without interruption.';
      case SovereignPermissionType.bluetoothConnect:
        return 'FALLBACK_BUILTIN_SPEAKER: Audio routed through standard device speaker.';
      case SovereignPermissionType.postNotifications:
        return 'FALLBACK_SILENT_MODE: Study reminders disabled. Progress safely tracked on next app launch.';
      case SovereignPermissionType.mediaPlaybackForeground:
        return 'FALLBACK_ACTIVE_SCREEN_ONLY: Audio plays only while app remains in foreground.';
    }
  }
}
