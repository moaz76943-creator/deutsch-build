import 'haircut_phrase.dart';

abstract final class AppointmentStyleContent {
  static const List<HaircutPhrase> phrases = <HaircutPhrase>[
    HaircutPhrase(
      id: 'appointment_a1',
      topic: HaircutTopic.appointment,
      level: HaircutLevel.a1a2,
      german: 'Ich möchte gern einen Termin vereinbaren.',
      arabic: 'أود حجز موعد.',
      noteArabic: 'صيغة يومية مهذبة لحجز موعد مسبق.',
      quick: true,
    ),
    HaircutPhrase(
      id: 'walkin_a1',
      topic: HaircutTopic.appointment,
      level: HaircutLevel.a1a2,
      german: 'Geht es heute auch ohne Termin?',
      arabic: 'هل يمكن اليوم من دون موعد؟',
      noteArabic: 'للسؤال عن إمكانية الدخول المباشر.',
      quick: true,
    ),
    HaircutPhrase(
      id: 'time_b1',
      topic: HaircutTopic.appointment,
      level: HaircutLevel.b1,
      german: 'Hätten Sie am Nachmittag noch einen freien Termin?',
      arabic: 'هل لديكم موعد متاح بعد الظهر؟',
      noteArabic: 'Hätten Sie صيغة أكثر تهذيباً للسؤال عن وقت شاغر.',
    ),
    HaircutPhrase(
      id: 'reschedule_b2',
      topic: HaircutTopic.appointment,
      level: HaircutLevel.b2,
      german:
          'Könnten wir den Termin bitte auf einen späteren Zeitpunkt verschieben?',
      arabic: 'هل يمكننا تأجيل الموعد إلى وقت لاحق من فضلكم؟',
      noteArabic: 'صيغة مهنية لإعادة جدولة الموعد.',
    ),
    HaircutPhrase(
      id: 'shorten_a1',
      topic: HaircutTopic.haircut,
      level: HaircutLevel.a1a2,
      german: 'Bitte etwas kürzer, aber nicht zu kurz.',
      arabic: 'أقصر قليلاً من فضلك، لكن ليس قصيراً جداً.',
      noteArabic: 'وصف بسيط لقصة مرتبة بطول معتدل.',
      quick: true,
    ),
    HaircutPhrase(
      id: 'scissors_b1',
      topic: HaircutTopic.haircut,
      level: HaircutLevel.b1,
      german: 'Bitte die Spitzen sauber mit der Schere kürzen.',
      arabic: 'قصّر الأطراف بالمقص بشكل مرتب من فضلك.',
      noteArabic: 'Spitzen تعني أطراف الشعر، وmit der Schere بالمقص.',
    ),
    HaircutPhrase(
      id: 'balanced_b1',
      topic: HaircutTopic.haircut,
      level: HaircutLevel.b1,
      german: 'Ich hätte gern einen gleichmäßigen, gepflegten Schnitt.',
      arabic: 'أريد قصة متناسقة ومرتبة.',
      noteArabic: 'gleichmäßig متناسق، gepflegt مرتب ومعتنى به.',
    ),
    HaircutPhrase(
      id: 'natural_b2',
      topic: HaircutTopic.haircut,
      level: HaircutLevel.b2,
      german:
          'Die Form soll klassisch bleiben und an den Seiten gleichmäßig auslaufen.',
      arabic: 'أريد أن يبقى الشكل كلاسيكياً مع تدرج متناسق على الجانبين.',
      noteArabic: 'صيغة دقيقة لوصف نتيجة مرتبة وطبيعية.',
    ),
    HaircutPhrase(
      id: 'beard_a1',
      topic: HaircutTopic.beardMoustache,
      level: HaircutLevel.a1a2,
      german: 'Bitte den Bart nur etwas stutzen.',
      arabic: 'قصّر اللحية قليلاً فقط من فضلك.',
      noteArabic: 'stutzen يعني تقصير وتهذيب اللحية.',
      quick: true,
    ),
    HaircutPhrase(
      id: 'contours_b1',
      topic: HaircutTopic.beardMoustache,
      level: HaircutLevel.b1,
      german: 'Bitte die Konturen sauber schneiden.',
      arabic: 'رتّب حدود اللحية بشكل نظيف من فضلك.',
      noteArabic: 'Konturen هي الحواف أو الحدود الخارجية.',
    ),
    HaircutPhrase(
      id: 'moustache_b1',
      topic: HaircutTopic.beardMoustache,
      level: HaircutLevel.b1,
      german: 'Den Schnurrbart bitte gleichmäßig kürzen.',
      arabic: 'قصّر الشارب بشكل متناسق من فضلك.',
      noteArabic: 'gleichmäßig هنا تعني بطول متناسق.',
    ),
    HaircutPhrase(
      id: 'beard_b2',
      topic: HaircutTopic.beardMoustache,
      level: HaircutLevel.b2,
      german:
          'Bitte den Bart gepflegt formen und die Konturen natürlich halten.',
      arabic: 'نسّق اللحية بشكل مرتب وحافظ على حدود طبيعية.',
      noteArabic: 'صيغة متقدمة لوصف مظهر كلاسيكي غير مبالغ فيه.',
    ),
  ];
}
