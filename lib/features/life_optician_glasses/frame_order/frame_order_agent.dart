import '../optician_models.dart';

final class FrameOrderAgent {
  const FrameOrderAgent();

  List<OpticianPhrase> get items => const <OpticianPhrase>[
        OpticianPhrase(
          id: 'fo_try_frame',
          category: OpticianCategory.glassesOrder,
          german: 'Kann ich diese Fassung in einer anderen Größe anprobieren?',
          arabic: 'هل يمكنني تجربة هذا الإطار بمقاس آخر؟',
          tags: <String>['Fassung', 'Größe', 'anprobieren', 'الإطار'],
        ),
        OpticianPhrase(
          id: 'fo_light_frame',
          category: OpticianCategory.glassesOrder,
          german: 'Ich suche eine leichte Fassung für den Alltag.',
          arabic: 'أبحث عن إطار خفيف للاستخدام اليومي.',
          tags: <String>['Fassung', 'leicht', 'Alltag'],
        ),
        OpticianPhrase(
          id: 'fo_lens_material',
          category: OpticianCategory.glassesOrder,
          german: 'Welche Brillengläser passen zu meinen Werten?',
          arabic: 'أي عدسات نظارة تناسب قياساتي؟',
          tags: <String>['Brillengläser', 'Gläser', 'Werte'],
        ),
        OpticianPhrase(
          id: 'fo_antireflex',
          category: OpticianCategory.glassesOrder,
          german: 'Was kostet eine Entspiegelung der Gläser?',
          arabic: 'كم تكلفة طبقة تقليل الانعكاس للعدسات؟',
          tags: <String>['Entspiegelung', 'Gläser', 'Preis'],
        ),
        OpticianPhrase(
          id: 'fo_thinner',
          category: OpticianCategory.glassesOrder,
          german: 'Gibt es für meine Stärke dünnere Gläser?',
          arabic: 'هل توجد عدسات أرق مناسبة لدرجتي؟',
          tags: <String>['dünnere Gläser', 'Stärke'],
        ),
        OpticianPhrase(
          id: 'fo_fit_bridge',
          category: OpticianCategory.glassesOrder,
          german: 'Die Brille rutscht an der Nase.',
          arabic: 'النظارة تنزلق على الأنف.',
          tags: <String>['anpassen', 'Nase', 'rutscht'],
        ),
        OpticianPhrase(
          id: 'fo_temple',
          category: OpticianCategory.glassesOrder,
          german: 'Können Sie die Bügel etwas nachstellen?',
          arabic: 'هل يمكنكم تعديل ذراعي النظارة قليلاً؟',
          tags: <String>['Bügel', 'nachstellen', 'Anpassung'],
        ),
        OpticianPhrase(
          id: 'fo_collection',
          category: OpticianCategory.glassesOrder,
          german: 'Wann kann ich die fertige Brille abholen?',
          arabic: 'متى يمكنني استلام النظارة الجاهزة؟',
          tags: <String>['abholen', 'fertige Brille', 'Abholung'],
        ),
        OpticianPhrase(
          id: 'fo_final_check',
          category: OpticianCategory.glassesOrder,
          german: 'Können wir den Sitz bei der Abholung noch einmal prüfen?',
          arabic: 'هل يمكننا فحص ملاءمة النظارة مرة أخرى عند الاستلام؟',
          tags: <String>['Sitz', 'Abholung', 'prüfen'],
        ),
      ];

  List<OpticianPhrase> search(String query) =>
      List<OpticianPhrase>.unmodifiable(
        items.where((item) => item.matches(query)),
      );
}
