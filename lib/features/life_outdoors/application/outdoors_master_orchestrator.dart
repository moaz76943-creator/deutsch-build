import 'package:flutter/foundation.dart';

import '../domain/outdoors_models.dart';

final class OutdoorsMasterOrchestrator extends ChangeNotifier {
  OutdoorsMasterOrchestrator({
    this.familyStayAgent = const FamilyStaySubAgent(),
    this.natureTrailsAgent = const NatureTrailsSubAgent(),
  });

  final FamilyStaySubAgent familyStayAgent;
  final NatureTrailsSubAgent natureTrailsAgent;

  OutdoorsCategory _category = OutdoorsCategory.accommodation;
  String _searchQuery = '';

  OutdoorsCategory get category => _category;
  String get searchQuery => _searchQuery;
  List<TrailRule> get trailRules => natureTrailsAgent.trailRules;

  List<OutdoorsPhrase> get visiblePhrases {
    final source = switch (_category) {
      OutdoorsCategory.accommodation => familyStayAgent.phrases,
      OutdoorsCategory.natureHiking => natureTrailsAgent.phrases,
    };

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return List<OutdoorsPhrase>.unmodifiable(source);
    }

    return List<OutdoorsPhrase>.unmodifiable(
      source.where((item) => _matches(item, query)),
    );
  }

  void switchCategory(OutdoorsCategory category) {
    if (_category == category) return;
    _category = category;
    _searchQuery = '';
    notifyListeners();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  bool _matches(OutdoorsPhrase item, String query) {
    final searchable = <String>[
      item.titleDe,
      item.textDe,
      item.explanationAr,
      item.topic.germanLabel,
      item.topic.arabicLabel,
      ...item.tags,
    ].join(' ').toLowerCase();

    return searchable.contains(query);
  }
}

final class FamilyStaySubAgent {
  const FamilyStaySubAgent();

  List<OutdoorsPhrase> get phrases => _phrases;

  static const List<OutdoorsPhrase> _phrases = <OutdoorsPhrase>[
    OutdoorsPhrase(
      id: 'stay_booking',
      category: OutdoorsCategory.accommodation,
      topic: OutdoorsTopic.hostelBooking,
      titleDe: 'Jugendherberge buchen',
      textDe:
          'Guten Tag, ich möchte für meine Familie zwei Nächte in der '
          'Jugendherberge buchen.',
      explanationAr:
          'صياغة مهذبة وبسيطة لحجز إقامة عائلية في بيت شباب.',
      tags: <String>['Jugendherberge', 'Buchung', 'Familie', 'حجز'],
    ),
    OutdoorsPhrase(
      id: 'stay_family_room',
      category: OutdoorsCategory.accommodation,
      topic: OutdoorsTopic.familyRoom,
      titleDe: 'Familienzimmer anfragen',
      textDe: 'Haben Sie ein Familienzimmer für zwei Erwachsene und zwei Kinder?',
      explanationAr:
          'سؤال واضح عن توفر غرفة عائلية وعدد الأشخاص.',
      tags: <String>['Familienzimmer', 'Kinder', 'Zimmer', 'غرفة عائلية'],
    ),
    OutdoorsPhrase(
      id: 'stay_breakfast_time',
      category: OutdoorsCategory.accommodation,
      topic: OutdoorsTopic.breakfast,
      titleDe: 'Frühstückszeiten',
      textDe: 'Von wann bis wann gibt es Frühstück?',
      explanationAr:
          'للسؤال عن بداية ونهاية وقت الإفطار.',
      tags: <String>['Frühstück', 'Frühstückszeit', 'وقت الإفطار'],
    ),
    OutdoorsPhrase(
      id: 'stay_breakfast_included',
      category: OutdoorsCategory.accommodation,
      topic: OutdoorsTopic.breakfast,
      titleDe: 'Frühstück inklusive?',
      textDe: 'Ist das Frühstück im Übernachtungspreis enthalten?',
      explanationAr:
          'للتأكد إن كان الإفطار مشمولاً في سعر الإقامة.',
      tags: <String>['Frühstück', 'Preis', 'Übernachtung', 'إفطار'],
    ),
    OutdoorsPhrase(
      id: 'stay_house_rules',
      category: OutdoorsCategory.accommodation,
      topic: OutdoorsTopic.houseRules,
      titleDe: 'Hausordnung',
      textDe: 'Könnten Sie uns bitte die wichtigsten Regeln der Hausordnung erklären?',
      explanationAr:
          'لطلب توضيح أهم قواعد الإقامة بهدوء واحترام.',
      tags: <String>['Hausordnung', 'Regeln', 'Ruhezeit', 'قواعد'],
    ),
    OutdoorsPhrase(
      id: 'stay_check_in',
      category: OutdoorsCategory.accommodation,
      topic: OutdoorsTopic.checkInOut,
      titleDe: 'Check-in',
      textDe: 'Ab wann können wir einchecken?',
      explanationAr:
          'سؤال مباشر عن أول وقت متاح لتسجيل الدخول.',
      tags: <String>['Check-in', 'einchecken', 'Anreise', 'دخول'],
    ),
    OutdoorsPhrase(
      id: 'stay_check_out',
      category: OutdoorsCategory.accommodation,
      topic: OutdoorsTopic.checkInOut,
      titleDe: 'Check-out',
      textDe: 'Bis wann müssen wir das Zimmer am Abreisetag verlassen?',
      explanationAr:
          'للسؤال عن آخر موعد لمغادرة الغرفة يوم الرحيل.',
      tags: <String>['Check-out', 'Abreise', 'Zimmer', 'مغادرة'],
    ),
  ];
}

final class NatureTrailsSubAgent {
  const NatureTrailsSubAgent();

  List<OutdoorsPhrase> get phrases => _phrases;
  List<TrailRule> get trailRules => _trailRules;

  static const List<OutdoorsPhrase> _phrases = <OutdoorsPhrase>[
    OutdoorsPhrase(
      id: 'trail_marker',
      category: OutdoorsCategory.natureHiking,
      topic: OutdoorsTopic.trailMarkers,
      titleDe: 'Wegmarkierung verstehen',
      textDe: 'Welche Wegmarkierung führt zum Aussichtspunkt?',
      explanationAr:
          'للسؤال عن علامة المسار الصحيحة المؤدية إلى نقطة مشاهدة.',
      tags: <String>['Wegmarkierung', 'Wanderweg', 'Aussichtspunkt', 'مسار'],
    ),
    OutdoorsPhrase(
      id: 'trail_marker_follow',
      category: OutdoorsCategory.natureHiking,
      topic: OutdoorsTopic.trailMarkers,
      titleDe: 'Markiertem Weg folgen',
      textDe: 'Wir bleiben auf dem markierten Wanderweg.',
      explanationAr:
          'تأكيد الالتزام بالمسار المحدد وعدم الخروج عنه.',
      tags: <String>['markierter Weg', 'Wanderweg', 'Wegmarkierung', 'علامة'],
    ),
    OutdoorsPhrase(
      id: 'trail_etiquette',
      category: OutdoorsCategory.natureHiking,
      topic: OutdoorsTopic.trailEtiquette,
      titleDe: 'Wanderregeln beachten',
      textDe: 'Wir nehmen Rücksicht auf andere und hinterlassen keinen Müll.',
      explanationAr:
          'قاعدة أساسية للمشي: احترام الآخرين وعدم ترك النفايات.',
      tags: <String>['Wanderregeln', 'Müll', 'Rücksicht', 'آداب المسار'],
    ),
    OutdoorsPhrase(
      id: 'trail_quiet',
      category: OutdoorsCategory.natureHiking,
      topic: OutdoorsTopic.trailEtiquette,
      titleDe: 'Rücksicht in der Natur',
      textDe: 'Wir vermeiden unnötigen Lärm und stören keine Tiere.',
      explanationAr:
          'للتذكير بالهدوء وعدم إزعاج الحيوانات في الطبيعة.',
      tags: <String>['Wanderregeln', 'Lärm', 'Tiere', 'هدوء'],
    ),
    OutdoorsPhrase(
      id: 'trail_grill_area',
      category: OutdoorsCategory.natureHiking,
      topic: OutdoorsTopic.barbecueArea,
      titleDe: 'Ausgewiesener Grillplatz',
      textDe: 'Darf man hier nur auf dem ausgewiesenen Grillplatz grillen?',
      explanationAr:
          'للتأكد أن الشواء مسموح فقط في المكان المخصص رسمياً.',
      tags: <String>['Grillplatz', 'grillen', 'ausgewiesen', 'شواء'],
    ),
    OutdoorsPhrase(
      id: 'trail_grill_fire',
      category: OutdoorsCategory.natureHiking,
      topic: OutdoorsTopic.barbecueArea,
      titleDe: 'Feuer vollständig löschen',
      textDe: 'Nach dem Grillen löschen wir das Feuer vollständig.',
      explanationAr:
          'تذكير بإطفاء النار بالكامل بعد استخدام منطقة الشواء.',
      tags: <String>['Grillplatz', 'Feuer', 'grillen', 'نار'],
    ),
    OutdoorsPhrase(
      id: 'trail_reserve',
      category: OutdoorsCategory.natureHiking,
      topic: OutdoorsTopic.natureReserve,
      titleDe: 'Naturschutzgebiet',
      textDe:
          'Im Naturschutzgebiet bleiben wir auf den erlaubten Wegen und '
          'pflücken keine Pflanzen.',
      explanationAr:
          'في المحمية الطبيعية نلتزم بالمسارات المسموحة ولا نقطف النباتات.',
      tags: <String>['Naturschutzgebiet', 'Pflanzen', 'Wege', 'محمية'],
    ),
    OutdoorsPhrase(
      id: 'trail_reserve_sign',
      category: OutdoorsCategory.natureHiking,
      topic: OutdoorsTopic.natureReserve,
      titleDe: 'Hinweisschilder beachten',
      textDe: 'Welche Regeln gelten in diesem Naturschutzgebiet?',
      explanationAr:
          'سؤال عام لفهم التعليمات الخاصة بالمحمية الطبيعية.',
      tags: <String>['Naturschutzgebiet', 'Regeln', 'Schild', 'حماية الطبيعة'],
    ),
  ];

  static const List<TrailRule> _trailRules = <TrailRule>[
    TrailRule(
      id: 'stay_on_paths',
      german: 'Auf den markierten Wegen bleiben.',
      arabic: 'ابقَ على المسارات المحددة.',
    ),
    TrailRule(
      id: 'take_litter',
      german: 'Keinen Müll hinterlassen; Abfälle wieder mitnehmen.',
      arabic: 'لا تترك نفايات وخذ مخلفاتك معك.',
    ),
    TrailRule(
      id: 'respect_quiet',
      german: 'Tiere nicht stören und unnötigen Lärm vermeiden.',
      arabic: 'لا تزعج الحيوانات وتجنب الضوضاء غير الضرورية.',
    ),
    TrailRule(
      id: 'grill_only_designated',
      german: 'Nur auf ausgewiesenen Grillplätzen grillen, wenn es erlaubt ist.',
      arabic: 'اشوِ فقط في الأماكن المخصصة عندما يكون ذلك مسموحاً.',
    ),
    TrailRule(
      id: 'reserve_rules',
      german: 'Im Naturschutzgebiet Schilder und örtliche Regeln beachten.',
      arabic: 'في المحمية الطبيعية اتبع اللوحات والتعليمات المحلية.',
    ),
  ];
}
