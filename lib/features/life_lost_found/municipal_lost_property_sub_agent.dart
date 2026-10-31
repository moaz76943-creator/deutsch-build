import 'lost_found_models.dart';

final class MunicipalLostPropertySubAgent {
  const MunicipalLostPropertySubAgent();

  List<LostFoundItem> get items => _items;

  static const List<LostFoundItem> _items = <LostFoundItem>[
    LostFoundItem(
      id: 'municipal_online_catalog',
      domain: LostFoundDomain.municipal,
      topic: LostFoundTopic.onlineCatalog,
      titleDe: 'Online-Fundservice prüfen',
      titleAr: 'البحث في خدمة المفقودات الإلكترونية',
      german:
          'Gibt es für Ihr Fundbüro einen Online-Fundservice, in dem ich nach meinem Gegenstand suchen kann?',
      arabic:
          'هل لدى مكتب المفقودات خدمة إلكترونية أستطيع البحث فيها عن غرضي؟',
      contextDe:
          'Viele Kommunen bieten digitale Such- oder Meldewege an. Prüfen Sie den aktuellen Dienst Ihrer Stadt.',
      contextAr:
          'تختلف البوابات من مدينة لأخرى؛ استخدم الموقع الرسمي لبلديتك للتحقق من البحث أو البلاغ الإلكتروني.',
      tags: <String>[
        'Online-Fundservice',
        'Fundbüro',
        'Fundkatalog',
        'online suchen',
        'بحث إلكتروني',
        'مفقودات',
      ],
    ),
    LostFoundItem(
      id: 'municipal_loss_report',
      domain: LostFoundDomain.municipal,
      topic: LostFoundTopic.lossReport,
      titleDe: 'Verlustmeldung genau beschreiben',
      titleAr: 'تقديم بلاغ فقدان بوصف دقيق',
      german:
          'Ich möchte eine Verlustmeldung aufgeben. Der Gegenstand ist schwarz, von der Marke Nova und trägt die Seriennummer A17-204.',
      arabic:
          'أود تقديم بلاغ فقدان. الغرض أسود، من علامة Nova، ويحمل الرقم التسلسلي A17-204.',
      contextDe:
          'Beschreiben Sie Gegenstand, Farbe, Marke, besondere Merkmale, Seriennummer sowie Verlustort und ungefähre Verlustzeit so genau wie möglich.',
      contextAr:
          'اذكر اللون والعلامة والسمات المميزة والرقم التسلسلي ومكان الفقد والوقت التقريبي كلما أمكن.',
      tags: <String>[
        'Verlustmeldung',
        'Gegenstand',
        'Farbe',
        'Marke',
        'Seriennummer',
        'Verlustort',
        'Verlustzeit',
        'بلاغ فقدان',
        'لون',
        'علامة',
        'رقم تسلسلي',
      ],
    ),
    LostFoundItem(
      id: 'municipal_ownership_fee',
      domain: LostFoundDomain.municipal,
      topic: LostFoundTopic.ownershipAndFees,
      titleDe: 'Eigentumsnachweis & Verwaltungsgebühr',
      titleAr: 'إثبات الملكية ورسوم الاستلام',
      german:
          'Welchen Eigentumsnachweis soll ich mitbringen, und fällt bei der Abholung eine Verwaltungsgebühr an?',
      arabic:
          'ما إثبات الملكية الذي يجب أن أحضره، وهل توجد رسوم إدارية عند الاستلام؟',
      contextDe:
          'Fragen Sie vor der Abholung nach akzeptierten Nachweisen und möglichen Gebühren, da kommunale Verfahren unterschiedlich sein können.',
      contextAr:
          'اسأل مسبقًا عن الإثبات المقبول وأي رسوم محتملة لأن إجراءات البلديات قد تختلف.',
      tags: <String>[
        'Eigentumsnachweis',
        'Verwaltungsgebühr',
        'Abholung',
        'Kaufbeleg',
        'Seriennummer',
        'إثبات الملكية',
        'رسوم إدارية',
        'استلام',
      ],
    ),
  ];
}
