import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/life_haircut_barbershop/styles/appointment_style_agent.dart';
import 'package:deutsch_bilarabi/features/life_haircut_barbershop/styles/haircut_phrase.dart';

void main() {
  const agent = AppointmentStyleAgent();

  test('covers appointment, classic haircut and beard or moustache topics', () {
    expect(agent.appointmentPhrases, isNotEmpty);
    expect(agent.classicHaircutPhrases, isNotEmpty);
    expect(agent.beardMoustachePhrases, isNotEmpty);
  });

  test('supports Termin and Ohne Termin language', () {
    final text = agent.appointmentPhrases
        .map((phrase) => phrase.german)
        .join(' ')
        .toLowerCase();

    expect(text, contains('termin'));
    expect(text, contains('ohne termin'));
  });

  test('covers scissors, balanced haircut, beard and contours', () {
    final text = agent.all.map((phrase) => phrase.german).join(' ').toLowerCase();

    expect(text, contains('schere'));
    expect(text, contains('gleichmäßig'));
    expect(text, contains('bart'));
    expect(text, contains('konturen'));
    expect(text, contains('schnurrbart'));
  });

  test('search respects level and topic filters', () {
    final result = agent.search(
      'bitte',
      level: HaircutLevel.b1,
      topic: HaircutTopic.beardMoustache,
    );

    expect(result, isNotEmpty);
    expect(result.every((phrase) => phrase.level == HaircutLevel.b1), isTrue);
    expect(
      result.every((phrase) => phrase.topic == HaircutTopic.beardMoustache),
      isTrue,
    );
  });

  test('quick phrases stay practical and professional', () {
    expect(agent.quickPhrases, isNotEmpty);
    expect(agent.quickPhrases.every((phrase) => phrase.quick), isTrue);
  });
}
