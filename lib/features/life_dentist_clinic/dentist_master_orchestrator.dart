import 'dentist_models.dart';

final class DentistMasterOrchestrator {
  const DentistMasterOrchestrator();

  List<DentistCategory> get categories => DentistCategory.values;

  static const List<DentistPhrase> _items = <DentistPhrase>[
    DentistPhrase(
      id: 'check_regular',
      category: DentistCategory.checkup,
      german: 'Ich bin heute zur Kontrolluntersuchung hier.',
      arabic: 'أنا هنا اليوم لإجراء الفحص الدوري.',
      tags: <String>['Kontrolle', 'Kontrolluntersuchung', 'فحص'],
    ),
    DentistPhrase(
      id: 'check_sensitive',
      category: DentistCategory.checkup,
      german: 'Ein Zahn ist beim Kalten empfindlich.',
      arabic: 'أحد الأسنان حساس عند الأشياء الباردة.',
      tags: <String>['empfindlich', 'kalt', 'Zahn'],
    ),
    DentistPhrase(
      id: 'clean_tartar',
      category: DentistCategory.cleaning,
      german: 'Kann heute Zahnstein entfernt werden?',
      arabic: 'هل يمكن إزالة الجير اليوم؟',
      tags: <String>['Zahnstein', 'entfernen', 'تنظيف'],
    ),
    DentistPhrase(
      id: 'clean_professional',
      category: DentistCategory.cleaning,
      german: 'Ich möchte nach einer professionellen Zahnreinigung fragen.',
      arabic: 'أود الاستفسار عن تنظيف الأسنان الاحترافي.',
      tags: <String>['professionelle Zahnreinigung', 'PZR', 'تنظيف'],
    ),
    DentistPhrase(
      id: 'appointment_new',
      category: DentistCategory.appointment,
      german: 'Ich möchte einen Termin zur Kontrolle vereinbaren.',
      arabic: 'أود حجز موعد للفحص الدوري.',
      tags: <String>['Termin', 'vereinbaren', 'Kontrolle'],
    ),
    DentistPhrase(
      id: 'appointment_card',
      category: DentistCategory.appointment,
      german: 'Hier ist meine Gesundheitskarte.',
      arabic: 'هذه بطاقة التأمين الصحي الخاصة بي.',
      tags: <String>['Empfang', 'Gesundheitskarte'],
    ),
  ];

  List<DentistPhrase> get allItems =>
      List<DentistPhrase>.unmodifiable(_items);

  List<DentistPhrase> itemsFor(DentistCategory category) =>
      List<DentistPhrase>.unmodifiable(
        _items.where((item) => item.category == category),
      );

  List<DentistPhrase> search(
    String query, {
    DentistCategory? category,
  }) =>
      List<DentistPhrase>.unmodifiable(
        _items.where(
          (item) =>
              (category == null || item.category == category) &&
              item.matches(query),
        ),
      );
}
