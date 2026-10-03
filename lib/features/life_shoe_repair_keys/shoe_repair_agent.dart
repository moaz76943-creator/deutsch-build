import 'quick_service_master_hub.dart';

final class ShoeRepairAgent {
  const ShoeRepairAgent();

  static const List<QuickServicePhrase> entries = <QuickServicePhrase>[
    QuickServicePhrase(
      id: 'shoe-heel',
      category: QuickServiceCategory.shoeRepair,
      topicDe: 'Absatz reparieren',
      topicAr: 'تصليح كعب الحذاء',
      german:
          'Der Absatz dieses Schuhs ist beschädigt. Können Sie ihn reparieren und mir vorher den Preis nennen?',
      arabic:
          'كعب هذا الحذاء متضرر. هل يمكنكم إصلاحه وإخباري بالسعر مسبقاً؟',
      tags: <String>['Absatz', 'Schuh', 'reparieren', 'كعب', 'حذاء'],
    ),
    QuickServicePhrase(
      id: 'shoe-sole',
      category: QuickServiceCategory.shoeRepair,
      topicDe: 'Sohle erneuern',
      topicAr: 'تبديل النعل',
      german:
          'Die Sohle löst sich vorne. Ist Kleben ausreichend, oder empfehlen Sie eine neue Sohle?',
      arabic:
          'النعل ينفصل من الأمام. هل يكفي اللصق أم تنصحون بنعل جديد؟',
      tags: <String>['Sohle', 'kleben', 'erneuern', 'نعل', 'لصق'],
    ),
    QuickServicePhrase(
      id: 'shoe-zipper',
      category: QuickServiceCategory.shoeRepair,
      topicDe: 'Reißverschluss am Stiefel',
      topicAr: 'سحاب الحذاء الطويل',
      german:
          'Der Reißverschluss an diesem Stiefel klemmt. Können Sie ihn reparieren oder ersetzen?',
      arabic:
          'سحاب هذا الحذاء الطويل عالق. هل يمكن إصلاحه أو تبديله؟',
      tags: <String>['Reißverschluss', 'Stiefel', 'ersetzen', 'سحاب'],
    ),
    QuickServicePhrase(
      id: 'shoe-stitch',
      category: QuickServiceCategory.shoeRepair,
      topicDe: 'Naht nachnähen',
      topicAr: 'إعادة خياطة الحذاء',
      german:
          'An der Seite ist eine Naht aufgegangen. Können Sie diese Stelle sauber nachnähen?',
      arabic:
          'انفتحت الخياطة من الجانب. هل يمكنكم إعادة خياطة هذه المنطقة بشكل مرتب؟',
      tags: <String>['Naht', 'nähen', 'Seite', 'خياطة'],
    ),
    QuickServicePhrase(
      id: 'shoe-pickup',
      category: QuickServiceCategory.shoeRepair,
      topicDe: 'Abholtermin',
      topicAr: 'موعد الاستلام',
      german:
          'Wann kann ich die Schuhe abholen, und bekomme ich einen Abholschein?',
      arabic:
          'متى يمكنني استلام الأحذية، وهل سأحصل على إيصال استلام؟',
      tags: <String>['Abholung', 'Abholschein', 'Termin', 'استلام'],
    ),
  ];
}
