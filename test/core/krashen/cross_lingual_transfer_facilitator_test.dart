import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/krashen/cross_lingual_transfer_facilitator.dart';

void main() {
  group('CrossLingualTransferFacilitator Suite', () {
    final facilitator = CrossLingualTransferFacilitator();

    setUpAll(() {
      // 1. Positive cognate: Arabic -> Turkish (كتاب -> kitap)
      facilitator.registerPair(const CrossLingualTransferPair(
        sourceLemma: 'كتاب',
        targetLemma: 'kitap',
        sourceLang: 'ar',
        targetLang: 'tr',
        type: CrossLingualTransferType.positiveCognateLoan,
        pedagogicalExplanationAr: 'الكلمة من أصل عربي دخلت التركية العثمانية بنفس المعنى تماماً.',
        exampleUsage: 'Bu kitap çok faydalı.',
      ));

      // 2. Positive loan: Arabic -> Swahili (وقت -> wakati)
      facilitator.registerPair(const CrossLingualTransferPair(
        sourceLemma: 'وقت',
        targetLemma: 'wakati',
        sourceLang: 'ar',
        targetLang: 'sw',
        type: CrossLingualTransferType.positiveCognateLoan,
        pedagogicalExplanationAr: 'مشتقة من العربية "وقت" بنفس المعنى الزمني في السواحيلية.',
        exampleUsage: 'Wakati mzuri wa kusoma.',
      ));

      // 3. Negative false friend: Turkish "hasta" (sick/patient) vs Spanish "hasta" (until)
      facilitator.registerPair(const CrossLingualTransferPair(
        sourceLemma: 'hasta',
        targetLemma: 'hasta',
        sourceLang: 'es',
        targetLang: 'tr',
        type: CrossLingualTransferType.negativeFalseFriend,
        pedagogicalExplanationAr: 'تشابه شكلي خادع: تعني في التركية مريض، بينما تعني في الإسبانية حتى.',
        exampleUsage: 'Bugün biraz hastayım.',
        warningCaution: 'احذر الخلط بين حرف الجر الإسباني والصفة التركية.',
      ));
    });

    test('Identifies positive loanword transfer from Arabic to Turkish for Arabic speaker', () {
      final matches = facilitator.analyzeTransfer(
        targetWord: 'kitap',
        targetLang: 'tr',
        learnerKnownLanguages: {'ar'},
      );

      expect(matches, isNotEmpty);
      expect(matches.first.isPositiveTransfer, isTrue);
      expect(matches.first.sourceLemma, equals('كتاب'));
    });

    test('Alerts Spanish speaker learning Turkish about false friend "hasta"', () {
      final matches = facilitator.analyzeTransfer(
        targetWord: 'hasta',
        targetLang: 'tr',
        learnerKnownLanguages: {'es'},
      );

      expect(matches, isNotEmpty);
      expect(matches.first.type, equals(CrossLingualTransferType.negativeFalseFriend));
      expect(matches.first.warningCaution, isNotNull);
    });
  });
}
