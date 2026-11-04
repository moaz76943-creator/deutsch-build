import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/core/krashen/pragmatic_speech_act_classifier.dart';

void main() {
  group('PragmaticSpeechActClassifier Suite', () {
    const classifier = PragmaticSpeechActClassifier();

    test(
        'unsupported language never borrows Arabic markers or certifies advice',
        () {
      final result =
          classifier.classifyUtterance(text: 'شكراً', languageCode: 'de');
      expect(result.detectedIllocutionaryMarkers, isEmpty);
      expect(result.confidenceScore, 0);
      expect(result.isPragmaticallyAppropriate, isFalse);
    });

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
