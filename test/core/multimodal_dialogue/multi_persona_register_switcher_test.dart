import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/multi_persona_register_switcher.dart';

void main() {
  group('MultiPersonaRegisterSwitcher Unit Tests (N077)', () {
    final switcher = MultiPersonaRegisterSwitcher();

    test('Switches between formal bureaucrat and casual Berlin peer', () {
      expect(switcher.activePersona.personaId, equals('official_clerk'));
      expect(switcher.activePersona.greetingPhrase, contains('Guten Tag'));

      switcher.switchPersona('berlin_peer');
      expect(switcher.activePersona.personaId, equals('berlin_peer'));
      expect(switcher.activePersona.greetingPhrase, contains('Na, alles fit'));
    });

    test('Switches to Bavarian cultural host persona', () {
      switcher.switchPersona('bavarian_host');
      expect(switcher.activePersona.regionalFlavor, contains('Bairisch'));
      expect(switcher.activePersona.greetingPhrase, contains('Grüß Gott'));
    });
  });
}
