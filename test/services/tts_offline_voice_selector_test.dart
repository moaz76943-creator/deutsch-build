import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offline selector rejects network-required German voices', () {
    final voice = FlutterOfflineTtsEngine.selectOfflineVoice(
      <dynamic>[
        <String, Object>{
          'name': 'de-network',
          'locale': 'de-DE',
          'network_required': true,
        },
        <String, Object>{
          'name': 'de-local',
          'locale': 'de_DE',
          'network_required': false,
        },
      ],
      const <String>['de-DE'],
    );

    expect(voice?['name'], 'de-local');
    expect(voice?['locale'], 'de_DE');
  });

  test('offline selector rejects voices marked not installed', () {
    final voice = FlutterOfflineTtsEngine.selectOfflineVoice(
      <dynamic>[
        <String, Object>{
          'name': 'de-missing',
          'locale': 'de-DE',
          'network_required': false,
          'features': '[notInstalled]',
        },
      ],
      const <String>['de-DE'],
    );

    expect(voice, isNull);
  });
  test('offline selector rejects alternate network capability markers', () {
    final voice = FlutterOfflineTtsEngine.selectOfflineVoice(
      <dynamic>[
        <String, Object>{
          'name': 'de-network-camel',
          'locale': 'de-DE',
          'networkRequired': true,
        },
        <String, Object>{
          'name': 'de-feature-network',
          'locale': 'de-DE',
          'network_required': false,
          'features': '[networkTts]',
        },
        <String, Object>{
          'name': 'de-local',
          'locale': 'de-DE',
          'network_required': false,
          'features': '[embeddedTts]',
        },
      ],
      const <String>['de-DE'],
    );

    expect(voice?['name'], 'de-local');
  });

}
