import 'package:flutter/foundation.dart';

import 'auto_workshop_sub_agent.dart';
import 'car_service_models.dart';
import 'tuev_inspection_sub_agent.dart';

final class CarServiceMasterOrchestrator extends ChangeNotifier {
  CarServiceMasterOrchestrator({
    AutoWorkshopSubAgent workshopAgent = const AutoWorkshopSubAgent(),
    TuevInspectionSubAgent inspectionAgent = const TuevInspectionSubAgent(),
  })  : _workshopAgent = workshopAgent,
        _inspectionAgent = inspectionAgent;

  final AutoWorkshopSubAgent _workshopAgent;
  final TuevInspectionSubAgent _inspectionAgent;

  CarServiceMode _mode = CarServiceMode.all;
  String _query = '';
  bool _seasonalTireExpanded = false;

  CarServiceMode get mode => _mode;
  String get query => _query;
  bool get seasonalTireExpanded => _seasonalTireExpanded;

  String get seasonalTireGerman =>
      'O bis O ist eine Faustregel: Winterreifen von Oktober bis Ostern. '
      'Rechtlich gilt in Deutschland keine feste O-bis-O-Frist, sondern eine '
      'situative Winterreifenpflicht bei winterlichen Straßenverhältnissen. '
      'Geeignete Winter- oder Ganzjahresreifen brauchen das Alpine-Symbol.';

  String get seasonalTireArabic =>
      'قاعدة «من O إلى O» هي تذكير تقريبي: من أكتوبر إلى عيد الفصح. '
      'قانونيًا لا يوجد موعد ثابت بهذه الصيغة في ألمانيا؛ بل يعتمد وجوب '
      'الإطارات الشتوية على ظروف الطريق الشتوية. ويجب أن تحمل الإطارات '
      'المناسبة رمز Alpine.';

  String get seasonalTireSafetyGerman =>
      'Bei Glatteis, Schneeglätte, Schneematsch, Eis- oder Reifglätte '
      'muss die Bereifung zur Situation passen.';

  String get seasonalTireSafetyArabic =>
      'عند الجليد أو الثلج أو الوحل الثلجي أو الصقيع يجب استخدام إطارات '
      'مناسبة للظروف الشتوية.';

  List<CarServicePhrase> get allPhrases =>
      List<CarServicePhrase>.unmodifiable(<CarServicePhrase>[
        ..._workshopAgent.phrases,
        ..._inspectionAgent.phrases,
      ]);

  List<CarServicePhrase> get visiblePhrases {
    final normalizedQuery = _normalize(_query);

    final result = allPhrases.where((item) {
      final modeMatches = _mode == CarServiceMode.all || item.mode == _mode;
      final queryMatches = normalizedQuery.isEmpty ||
          _normalize(item.searchableText).contains(normalizedQuery);
      return modeMatches && queryMatches;
    }).toList(growable: false);

    return List<CarServicePhrase>.unmodifiable(result);
  }

  void setMode(CarServiceMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearFilters() {
    if (_mode == CarServiceMode.all && _query.isEmpty) return;
    _mode = CarServiceMode.all;
    _query = '';
    notifyListeners();
  }

  void toggleSeasonalTireDetails() {
    _seasonalTireExpanded = !_seasonalTireExpanded;
    notifyListeners();
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .replaceAll('ـ', '');
  }
}
