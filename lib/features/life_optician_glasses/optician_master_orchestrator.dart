import 'optician_models.dart';

final class OpticianMasterOrchestrator {
  const OpticianMasterOrchestrator();

  List<OpticianCategory> get categories => OpticianCategory.values;

  static const List<OpticianPhrase> _items = <OpticianPhrase>[
    OpticianPhrase(
      id: 'exam_request',
      category: OpticianCategory.visionExam,
      german: 'Ich möchte einen Sehtest machen lassen.',
      arabic: 'أود إجراء فحص للنظر.',
      tags: <String>['Sehtest', 'Sehschärfe', 'Optiker'],
    ),
    OpticianPhrase(
      id: 'exam_distance',
      category: OpticianCategory.visionExam,
      german: 'Ich sehe in der Ferne nicht mehr so scharf.',
      arabic: 'لم أعد أرى الأشياء البعيدة بوضوح كافٍ.',
      tags: <String>['Ferne', 'Sehschärfe'],
    ),
    OpticianPhrase(
      id: 'lens_values',
      category: OpticianCategory.lensMeasurements,
      german: 'Können Sie mir die gemessenen Glaswerte erklären?',
      arabic: 'هل يمكنكم شرح قياسات العدسات التي تم تحديدها؟',
      tags: <String>['Glaswerte', 'Dioptrien', 'قياسات', 'عدسات'],
    ),
    OpticianPhrase(
      id: 'pupil_distance',
      category: OpticianCategory.lensMeasurements,
      german: 'Wird auch die Pupillendistanz gemessen?',
      arabic: 'هل سيتم أيضاً قياس المسافة بين الحدقتين؟',
      tags: <String>['Pupillendistanz', 'PD', 'Messung'],
    ),
    OpticianPhrase(
      id: 'frame_try',
      category: OpticianCategory.glassesOrder,
      german: 'Ich möchte diese Fassung anprobieren.',
      arabic: 'أود تجربة هذا الإطار.',
      tags: <String>['Fassung', 'anprobieren', 'نظارة'],
    ),
    OpticianPhrase(
      id: 'order_ready',
      category: OpticianCategory.glassesOrder,
      german: 'Wann ist die fertige Brille abholbereit?',
      arabic: 'متى ستكون النظارة الجاهزة متاحة للاستلام؟',
      tags: <String>['Brille', 'Abholung', 'fertig'],
    ),
  ];

  List<OpticianPhrase> get allItems =>
      List<OpticianPhrase>.unmodifiable(_items);

  List<OpticianPhrase> itemsFor(OpticianCategory category) =>
      List<OpticianPhrase>.unmodifiable(
        _items.where((item) => item.category == category),
      );

  List<OpticianPhrase> search(
    String query, {
    OpticianCategory? category,
  }) =>
      List<OpticianPhrase>.unmodifiable(
        _items.where(
          (item) =>
              (category == null || item.category == category) &&
              item.matches(query),
        ),
      );
}
