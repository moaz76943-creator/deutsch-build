import 'dart:math' as math;

import 'lost_found_models.dart';

final class TransitRecoverySubAgent {
  const TransitRecoverySubAgent();

  List<LostFoundItem> get items => _items;

  double finderRewardEuro({
    required double itemValueEuro,
    bool foundInPublicTransport = false,
  }) {
    if (!itemValueEuro.isFinite || itemValueEuro <= 0) return 0;

    final firstBand = math.min(itemValueEuro, 500.0) * 0.05;
    final excess = math.max(itemValueEuro - 500.0, 0.0) * 0.03;
    final ordinaryReward = firstBand + excess;

    if (!foundInPublicTransport) return ordinaryReward;
    if (itemValueEuro < 50) return 0;
    return ordinaryReward / 2;
  }

  static const List<LostFoundItem> _items = <LostFoundItem>[
    LostFoundItem(
      id: 'transit_db_fundservice',
      domain: LostFoundDomain.publicTransit,
      topic: LostFoundTopic.dbFundservice,
      titleDe: 'DB Fundservice: Verlust online melden',
      titleAr: 'خدمة مفقودات دويتشه بان',
      german:
          'Ich habe meinen Rucksack im Zug verloren. Wo kann ich beim DB Fundservice eine Verlustmeldung online erfassen?',
      arabic:
          'فقدت حقيبة ظهري في القطار. أين أستطيع تسجيل بلاغ فقدان إلكتروني لدى خدمة مفقودات دويتشه بان؟',
      contextDe:
          'Beim DB Fundservice sollte die Verlustmeldung möglichst früh und nur einmal erfasst werden. Beschreiben Sie den Gegenstand genau und prüfen Sie angezeigte Treffervorschläge.',
      contextAr:
          'توصي خدمة DB بتسجيل البلاغ مبكرًا وعدم إنشاء بلاغات مكررة، مع وصف الغرض بدقة ومراجعة النتائج المقترحة.',
      tags: <String>[
        'DB Fundservice',
        'Deutsche Bahn',
        'Zug',
        'Verlustmeldung',
        'verloren und gefunden',
        'القطار',
        'دويتشه بان',
        'بلاغ فقدان',
      ],
    ),
    LostFoundItem(
      id: 'transit_station_platform',
      domain: LostFoundDomain.publicTransit,
      topic: LostFoundTopic.stationRecovery,
      titleDe: 'Fundstelle im Bahnhof',
      titleAr: 'مكتب المفقودات في محطة القطار',
      german:
          'Ich habe meinen Schlüsselbund am Bahnsteig verloren. Ist er bei der Fundstelle im Bahnhof abgegeben worden?',
      arabic:
          'فقدت مجموعة مفاتيحي على رصيف المحطة. هل تم تسليمها إلى مكتب المفقودات في المحطة؟',
      contextDe:
          'Für Gegenstände aus Zug oder Bahnhof kann die Fundstelle im Bahnhof ein sinnvoller erster Kontakt sein. Prüfen Sie zusätzlich den zuständigen Online-Fundservice.',
      contextAr:
          'بالنسبة لما يُفقد في القطار أو المحطة، يمكن أن يكون مكتب المفقودات بالمحطة نقطة بداية مناسبة مع التحقق أيضًا من الخدمة الإلكترونية المختصة.',
      tags: <String>[
        'Bahnhof',
        'Bahnsteig',
        'Fundstelle',
        'Schlüssel',
        'محطة',
        'رصيف',
        'مفاتيح',
      ],
    ),
    LostFoundItem(
      id: 'transit_local_operator',
      domain: LostFoundDomain.publicTransit,
      topic: LostFoundTopic.localTransit,
      titleDe: 'Bus & Straßenbahn: Verkehrsbetriebe Fundstelle',
      titleAr: 'الحافلات والترام: مكتب مفقودات شركة النقل',
      german:
          'Ich habe etwas im Bus verloren. Welche Fundstelle Ihres Verkehrsbetriebs ist dafür zuständig?',
      arabic:
          'فقدت غرضًا في الحافلة. أي مكتب مفقودات تابع لشركة النقل مسؤول عن ذلك؟',
      contextDe:
          'Bei Bus und Straßenbahn richtet sich der Ablauf nach dem jeweiligen Verkehrsunternehmen. Fragen Sie nach Fundstelle, Verlustmeldung, Abholort und benötigtem Eigentumsnachweis.',
      contextAr:
          'في الحافلات والترام تختلف الإجراءات حسب شركة النقل؛ اسأل عن مكتب المفقودات وطريقة البلاغ ومكان الاستلام وإثبات الملكية.',
      tags: <String>[
        'Verkehrsbetriebe',
        'Fundstelle',
        'Bus',
        'Straßenbahn',
        'Tram',
        'ÖPNV',
        'حافلة',
        'ترام',
        'مواصلات عامة',
      ],
    ),
    LostFoundItem(
      id: 'transit_finder_reward',
      domain: LostFoundDomain.publicTransit,
      topic: LostFoundTopic.finderReward,
      titleDe: 'Gesetzlicher Finderlohn',
      titleAr: 'مكافأة العثور القانونية',
      german:
          'Wie wird der gesetzliche Finderlohn berechnet, wenn eine Sache im öffentlichen Verkehr gefunden wurde?',
      arabic:
          'كيف تُحسب مكافأة العثور القانونية إذا عُثر على الغرض في وسيلة نقل عام؟',
      contextDe:
          'Orientierung nach BGB: Bei gewöhnlichen Fundsachen beträgt der Finderlohn bis 500 Euro grundsätzlich 5 Prozent und vom Mehrwert 3 Prozent. Für Funde in öffentlichen Behörden oder Verkehrsanstalten gilt § 978 BGB: ab 50 Euro Sachwert grundsätzlich die Hälfte dieses Betrags. Sonderfälle und Anspruchsvoraussetzungen sind gesondert zu prüfen.',
      contextAr:
          'للاسترشاد وفق القانون المدني الألماني: في المفقودات العادية تكون النسبة أساسًا 5٪ حتى 500 يورو و3٪ لما يزيد. أما ما يُعثر عليه في جهة عامة أو منشأة نقل عام فتطبق القاعدة الخاصة في §978 BGB: من قيمة 50 يورو فأكثر تكون المكافأة أساسًا نصف المبلغ الناتج عن القاعدة العامة. تبقى الشروط والحالات الخاصة بحاجة للتحقق.',
      tags: <String>[
        'Finderlohn',
        '§ 971 BGB',
        '§ 978 BGB',
        '5 Prozent',
        '3 Prozent',
        '50 Euro',
        'مكافأة العثور',
        'قانون',
      ],
    ),
  ];
}
