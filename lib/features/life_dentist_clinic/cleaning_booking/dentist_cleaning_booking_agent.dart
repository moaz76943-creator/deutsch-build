import '../dentist_models.dart';

final class DentistCleaningBookingAgent {
  const DentistCleaningBookingAgent();

  List<DentistPhrase> get items => const <DentistPhrase>[
        DentistPhrase(
          id: 'dcb_tartar',
          category: DentistCategory.cleaning,
          german: 'Kann der Zahnstein heute entfernt werden?',
          arabic: 'هل يمكن إزالة الجير اليوم؟',
          tags: <String>['Zahnstein', 'entfernen', 'تنظيف'],
        ),
        DentistPhrase(
          id: 'dcb_pzr',
          category: DentistCategory.cleaning,
          german:
              'Ich möchte einen Termin für eine professionelle Zahnreinigung vereinbaren.',
          arabic: 'أود حجز موعد لتنظيف الأسنان الاحترافي.',
          tags: <String>['professionelle Zahnreinigung', 'PZR', 'Termin'],
        ),
        DentistPhrase(
          id: 'dcb_clean_duration',
          category: DentistCategory.cleaning,
          german: 'Wie lange dauert die Zahnreinigung ungefähr?',
          arabic: 'كم يستغرق تنظيف الأسنان تقريباً؟',
          tags: <String>['Zahnreinigung', 'Dauer'],
        ),
        DentistPhrase(
          id: 'dcb_clean_cost',
          category: DentistCategory.cleaning,
          german: 'Welche Kosten entstehen für die Zahnreinigung?',
          arabic: 'ما التكاليف المترتبة على تنظيف الأسنان؟',
          tags: <String>['Kosten', 'Zahnreinigung'],
        ),
        DentistPhrase(
          id: 'dcb_booking',
          category: DentistCategory.appointment,
          german: 'Haben Sie nächste Woche einen freien Termin?',
          arabic: 'هل لديكم موعد متاح الأسبوع القادم؟',
          tags: <String>['Termin', 'frei', 'موعد'],
        ),
        DentistPhrase(
          id: 'dcb_reception',
          category: DentistCategory.appointment,
          german: 'Guten Tag, ich habe um neun Uhr einen Termin.',
          arabic: 'مرحباً، لدي موعد الساعة التاسعة.',
          tags: <String>['Empfang', 'Termin', 'Uhrzeit'],
        ),
        DentistPhrase(
          id: 'dcb_card',
          category: DentistCategory.appointment,
          german: 'Soll ich meine Gesundheitskarte hier abgeben?',
          arabic: 'هل أسلّم بطاقة التأمين الصحي هنا؟',
          tags: <String>['Gesundheitskarte', 'Empfang'],
        ),
        DentistPhrase(
          id: 'dcb_move',
          category: DentistCategory.appointment,
          german: 'Ich muss meinen Termin leider verschieben.',
          arabic: 'للأسف يجب أن أؤجل موعدي.',
          tags: <String>['Termin', 'verschieben', 'موعد'],
        ),
        DentistPhrase(
          id: 'dcb_cancel',
          category: DentistCategory.appointment,
          german: 'Ich möchte den Termin rechtzeitig absagen.',
          arabic: 'أود إلغاء الموعد في الوقت المناسب.',
          tags: <String>['Termin', 'absagen'],
        ),
      ];

  List<DentistPhrase> search(String query) =>
      List<DentistPhrase>.unmodifiable(
        items.where((item) => item.matches(query)),
      );
}
