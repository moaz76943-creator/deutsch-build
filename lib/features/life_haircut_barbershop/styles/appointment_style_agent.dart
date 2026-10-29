import 'appointment_style_content.dart';
import 'haircut_phrase.dart';

final class AppointmentStyleAgent {
  const AppointmentStyleAgent();

  List<HaircutPhrase> get all => AppointmentStyleContent.phrases;

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

  List<HaircutPhrase> get quickPhrases => List<HaircutPhrase>.unmodifiable(
        all.where((phrase) => phrase.quick),
      );

  List<HaircutPhrase> get appointmentPhrases => search(
        '',
        topic: HaircutTopic.appointment,
      );

  List<HaircutPhrase> get classicHaircutPhrases => search(
        '',
        topic: HaircutTopic.haircut,
      );

  List<HaircutPhrase> get beardMoustachePhrases => search(
        '',
        topic: HaircutTopic.beardMoustache,
      );
}
