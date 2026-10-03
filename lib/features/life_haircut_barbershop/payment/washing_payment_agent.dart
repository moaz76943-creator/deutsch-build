import '../styles/haircut_phrase.dart';
import 'washing_payment_content.dart';

final class WashingPaymentAgent {
  const WashingPaymentAgent();

  List<HaircutPhrase> get all => WashingPaymentContent.phrases;

  List<HaircutPhrase> search(
    String query, {
    HaircutLevel? level,
    HaircutTopic? topic,
  }) =>
      List<HaircutPhrase>.unmodifiable(
        all.where((phrase) {
          final levelMatches = level == null || phrase.level == level;
          final topicMatches = topic == null || phrase.topic == topic;
          return levelMatches && topicMatches && phrase.matches(query);
        }),
      );

  List<HaircutPhrase> get washingPhrases =>
      search('', topic: HaircutTopic.washing);

  List<HaircutPhrase> get carePhrases => search('', topic: HaircutTopic.care);

  List<HaircutPhrase> get paymentPhrases =>
      search('', topic: HaircutTopic.payment);

  List<HaircutPhrase> get quickPhrases => List<HaircutPhrase>.unmodifiable(
        all.where((phrase) => phrase.quick),
      );
}
