import '../domain/doctor_appointment_models.dart';

enum BookingStage {
  booking,
  reception,
  anamnesis,
  reschedule;

  String get german => switch (this) {
        BookingStage.booking => 'Termin buchen',
        BookingStage.reception => 'Empfang',
        BookingStage.anamnesis => 'Anamnesebogen',
        BookingStage.reschedule => 'Absagen / Verschieben',
      };

  String get arabic => switch (this) {
        BookingStage.booking => 'حجز الموعد',
        BookingStage.reception => 'الاستقبال',
        BookingStage.anamnesis => 'استمارة التاريخ المرضي',
        BookingStage.reschedule => 'الإلغاء أو التأجيل',
      };
}

final class BookingReceptionAgent {
  const BookingReceptionAgent();

  static const Map<BookingStage, List<DoctorHubPhrase>> _items =
      <BookingStage, List<DoctorHubPhrase>>{
    BookingStage.booking: <DoctorHubPhrase>[
      DoctorHubPhrase(
        id: 'book_phone',
        german: 'Guten Tag, ich möchte einen Termin vereinbaren.',
        arabic: 'مرحباً، أود حجز موعد.',
        tags: <String>['Termin', 'telefonisch', 'vereinbaren'],
      ),
      DoctorHubPhrase(
        id: 'book_free_slot',
        german: 'Gibt es diese Woche einen freien Termin?',
        arabic: 'هل يوجد موعد متاح هذا الأسبوع؟',
        tags: <String>['Termin', 'frei', 'Woche'],
      ),
      DoctorHubPhrase(
        id: 'book_doctolib',
        german: 'Ich habe den Termin online über Doctolib gebucht.',
        arabic: 'حجزت الموعد عبر الإنترنت من خلال Doctolib.',
        tags: <String>['Doctolib', 'online', 'gebucht'],
      ),
      DoctorHubPhrase(
        id: 'book_phone_option',
        german: 'Kann ich den Termin auch telefonisch buchen?',
        arabic: 'هل يمكنني حجز الموعد هاتفياً أيضاً؟',
        tags: <String>['telefonisch', 'Termin', 'buchen'],
      ),
    ],
    BookingStage.reception: <DoctorHubPhrase>[
      DoctorHubPhrase(
        id: 'reception_arrival',
        german: 'Guten Tag, ich habe um zehn Uhr einen Termin.',
        arabic: 'مرحباً، لدي موعد الساعة العاشرة.',
        tags: <String>['Empfang', 'Termin', 'Uhrzeit'],
      ),
      DoctorHubPhrase(
        id: 'reception_card',
        german: 'Hier ist meine Gesundheitskarte.',
        arabic: 'هذه بطاقة التأمين الصحي الخاصة بي.',
        tags: <String>['Empfang', 'Gesundheitskarte'],
      ),
      DoctorHubPhrase(
        id: 'reception_wait',
        german: 'Wo soll ich warten?',
        arabic: 'أين ينبغي أن أنتظر؟',
        tags: <String>['Empfang', 'Wartezimmer'],
      ),
    ],
    BookingStage.anamnesis: <DoctorHubPhrase>[
      DoctorHubPhrase(
        id: 'anamnesis_form',
        german: 'Soll ich den Anamnesebogen ausfüllen?',
        arabic: 'هل ينبغي أن أملأ استمارة التاريخ المرضي؟',
        tags: <String>['Anamnesebogen', 'Formular'],
      ),
      DoctorHubPhrase(
        id: 'anamnesis_fill',
        german: 'Ich fülle den Anamnesebogen jetzt aus.',
        arabic: 'سأملأ استمارة التاريخ المرضي الآن.',
        tags: <String>['Anamnesebogen', 'ausfüllen'],
      ),
      DoctorHubPhrase(
        id: 'anamnesis_help',
        german: 'Können Sie mir bei einer Frage im Formular helfen?',
        arabic: 'هل يمكنكم مساعدتي في سؤال داخل الاستمارة؟',
        tags: <String>['Formular', 'Frage', 'Hilfe'],
      ),
    ],
    BookingStage.reschedule: <DoctorHubPhrase>[
      DoctorHubPhrase(
        id: 'reschedule_cannot_attend',
        german: 'Ich kann den Termin leider nicht wahrnehmen.',
        arabic: 'للأسف لا أستطيع الحضور إلى الموعد.',
        tags: <String>['Termin', 'nicht wahrnehmen'],
      ),
      DoctorHubPhrase(
        id: 'reschedule_cancel',
        german: 'Ich möchte den Termin absagen.',
        arabic: 'أود إلغاء الموعد.',
        tags: <String>['Termin', 'absagen'],
      ),
      DoctorHubPhrase(
        id: 'reschedule_move',
        german: 'Können wir den Termin verschieben?',
        arabic: 'هل يمكننا تأجيل الموعد؟',
        tags: <String>['Termin', 'verschieben'],
      ),
      DoctorHubPhrase(
        id: 'reschedule_replacement',
        german: 'Haben Sie nächste Woche einen Ersatztermin?',
        arabic: 'هل لديكم موعد بديل الأسبوع القادم؟',
        tags: <String>['Ersatztermin', 'Woche'],
      ),
    ],
  };

  List<DoctorHubPhrase> get allItems => List<DoctorHubPhrase>.unmodifiable(
        <DoctorHubPhrase>[
          for (final stage in BookingStage.values) ..._items[stage]!,
        ],
      );

  List<DoctorHubPhrase> itemsFor(BookingStage stage) =>
      List<DoctorHubPhrase>.unmodifiable(_items[stage]!);

  List<DoctorHubPhrase> search(String query, {BookingStage? stage}) {
    final source = stage == null ? allItems : itemsFor(stage);
    return List<DoctorHubPhrase>.unmodifiable(
      source.where((item) => item.matches(query)),
    );
  }
}
