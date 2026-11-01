import 'package:test/test.dart';
import 'package:deutsch_build/src/core/krashen/pragmatic_speech_act_classifier.dart';

void main() {
  group('PragmaticSpeechActClassifier Suite', () {
    const classifier = PragmaticSpeechActClassifier();

    test('Identifies polite request in Arabic with respectful register', () {
      final res = classifier.classifyUtterance(
        text: 'من فضلك، هل بالإمكان مساعدتي في إعراب هذه الجملة؟',
        languageCode: 'ar',
      );

      expect(res.primaryAct, equals(SpeechActCategory.politeRequest));
      expect(res.isPragmaticallyAppropriate, isTrue);
      expect(res.detectedIllocutionaryMarkers, contains('من فضلك'));
    });

    test('Identifies Turkish gratitude expression accurately', () {
      final res = classifier.classifyUtterance(
        text: 'Yardımlarınız için çok teşekkür ederim.',
        languageCode: 'tr',
      );

      expect(res.primaryAct, equals(SpeechActCategory.gratitudeAppreciation));
      expect(res.detectedIllocutionaryMarkers, contains('teşekkür ederim'));
    });
  });
}
