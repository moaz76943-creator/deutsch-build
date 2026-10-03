import 'tailoring_models.dart';

abstract final class TailoringCatalog {
  static const List<TailoringDialogue> dialogues = <TailoringDialogue>[
    TailoringDialogue(
      id: 'shorten-trousers',
      service: TailoringService.trousersShortening,
      german: 'Ich möchte diese Hose kürzen lassen. Können Sie die Länge bitte anpassen?',
      arabic: 'أريد تقصير هذا البنطال. هل يمكنكم ضبط الطول؟',
      keywords: <String>{'Hose', 'kürzen', 'Länge', 'anpassen'},
    ),
    TailoringDialogue(
      id: 'adjust-jacket-sleeves',
      service: TailoringService.sleeveAdjustment,
      german: 'Die Ärmel der Jacke sind zu lang. Können Sie sie etwas kürzer anpassen?',
      arabic: 'أكمام السترة طويلة. هل يمكنكم تقصيرها قليلاً؟',
      keywords: <String>{'Ärmel', 'Jacke', 'kürzer', 'anpassen'},
    ),
    TailoringDialogue(
      id: 'replace-zipper',
      service: TailoringService.zipperRepair,
      german: 'Der Reißverschluss ist kaputt. Können Sie ihn reparieren oder ersetzen?',
      arabic: 'السحّاب تالف. هل يمكن إصلاحه أو استبداله؟',
      keywords: <String>{'Reißverschluss', 'kaputt', 'reparieren', 'ersetzen'},
    ),
    TailoringDialogue(
      id: 'repair-pocket',
      service: TailoringService.pocketRepair,
      german: 'Die Tasche innen ist eingerissen. Können Sie die Naht reparieren?',
      arabic: 'الجيب الداخلي ممزق. هل يمكنكم إصلاح الخياطة؟',
      keywords: <String>{'Tasche', 'Naht', 'eingerissen', 'reparieren'},
    ),
    TailoringDialogue(
      id: 'replace-button',
      service: TailoringService.buttonRepair,
      german: 'An diesem Hemd fehlt ein Knopf. Können Sie einen passenden Knopf annähen?',
      arabic: 'ينقص هذا القميص زر. هل يمكنكم تثبيت زر مناسب؟',
      keywords: <String>{'Hemd', 'Knopf', 'annähen', 'passen'},
    ),
  ];

  static const List<TailoringAgreement> agreements = <TailoringAgreement>[
    TailoringAgreement(
      service: TailoringService.trousersShortening,
      readyWhenDe: 'Wann kann ich die gekürzte Hose abholen?',
      readyWhenAr: 'متى يمكنني استلام البنطال بعد التقصير؟',
      costQuestionDe: 'Wie viel kostet das Kürzen einschließlich Arbeit?',
      costQuestionAr: 'كم تكلفة التقصير بما فيها أجرة العمل؟',
    ),
    TailoringAgreement(
      service: TailoringService.sleeveAdjustment,
      readyWhenDe: 'Wann ist die Jacke mit den angepassten Ärmeln fertig?',
      readyWhenAr: 'متى تصبح السترة جاهزة بعد تعديل الأكمام؟',
      costQuestionDe: 'Wie hoch sind die Kosten für die Ärmelanpassung?',
      costQuestionAr: 'ما تكلفة تعديل الأكمام؟',
    ),
    TailoringAgreement(
      service: TailoringService.zipperRepair,
      readyWhenDe: 'Wann kann ich das Kleidungsstück nach der Reparatur abholen?',
      readyWhenAr: 'متى يمكنني استلام قطعة الملابس بعد الإصلاح؟',
      costQuestionDe: 'Was kostet die Reparatur oder der Austausch des Reißverschlusses?',
      costQuestionAr: 'كم تكلفة إصلاح السحّاب أو استبداله؟',
    ),
  ];
}
