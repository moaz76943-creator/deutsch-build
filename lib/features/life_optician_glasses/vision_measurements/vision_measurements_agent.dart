import '../optician_models.dart';

final class VisionMeasurementsAgent {
  const VisionMeasurementsAgent();

  List<OpticianPhrase> get items => const <OpticianPhrase>[
        OpticianPhrase(
          id: 'vm_visual_acuity',
          category: OpticianCategory.visionExam,
          german: 'Können wir zuerst meine Sehschärfe prüfen?',
          arabic: 'هل يمكننا أولاً فحص حدة النظر لدي؟',
          tags: <String>['Sehschärfe', 'Sehtest'],
        ),
        OpticianPhrase(
          id: 'vm_distance',
          category: OpticianCategory.visionExam,
          german: 'In der Ferne erkenne ich kleine Schrift schlechter.',
          arabic: 'أرى الكتابة الصغيرة من بعيد بشكل أسوأ.',
          tags: <String>['Ferne', 'Sehtest'],
        ),
        OpticianPhrase(
          id: 'vm_near',
          category: OpticianCategory.visionExam,
          german: 'Beim Lesen in der Nähe muss ich mich mehr anstrengen.',
          arabic: 'عند القراءة من قريب أحتاج إلى جهد أكبر.',
          tags: <String>['Nähe', 'Lesen', 'قريب'],
        ),
        OpticianPhrase(
          id: 'vm_diopters',
          category: OpticianCategory.lensMeasurements,
          german: 'Wie viele Dioptrien wurden rechts und links gemessen?',
          arabic: 'كم ديوبتر تم قياسه للعين اليمنى واليسرى؟',
          tags: <String>['Dioptrien', 'rechts', 'links'],
        ),
        OpticianPhrase(
          id: 'vm_cylinder',
          category: OpticianCategory.lensMeasurements,
          german: 'Stehen Zylinder und Achse auch auf meinen Werten?',
          arabic: 'هل قيمة الأسطوانة والمحور موجودتان أيضاً ضمن قياساتي؟',
          tags: <String>['Zylinder', 'Achse', 'Werte'],
        ),
        OpticianPhrase(
          id: 'vm_pd',
          category: OpticianCategory.lensMeasurements,
          german: 'Wie groß ist meine Pupillendistanz?',
          arabic: 'ما مقدار المسافة بين الحدقتين لدي؟',
          tags: <String>['Pupillendistanz', 'PD'],
        ),
        OpticianPhrase(
          id: 'vm_old_values',
          category: OpticianCategory.lensMeasurements,
          german: 'Können Sie die neuen Werte mit meiner alten Brille vergleichen?',
          arabic: 'هل يمكنكم مقارنة القياسات الجديدة بنظارتي القديمة؟',
          tags: <String>['Werte', 'alte Brille', 'Vergleich'],
        ),
        OpticianPhrase(
          id: 'vm_printout',
          category: OpticianCategory.lensMeasurements,
          german: 'Kann ich die gemessenen Werte schriftlich mitnehmen?',
          arabic: 'هل يمكنني أخذ القياسات مكتوبة معي؟',
          tags: <String>['Messwerte', 'schriftlich'],
        ),
      ];

  List<OpticianPhrase> search(String query) =>
      List<OpticianPhrase>.unmodifiable(
        items.where((item) => item.matches(query)),
      );
}
