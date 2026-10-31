import 'package:flutter/foundation.dart';

import '../domain/driving_models.dart';
import 'fahrschule_sub_agent.dart';
import 'vehicle_admin_sub_agent.dart';

final class DrivingMasterOrchestrator extends ChangeNotifier {
  DrivingMasterOrchestrator({
    this.fahrschule = const FahrschuleSubAgent(),
    this.vehicleAdmin = const VehicleAdminSubAgent(),
  });

  final FahrschuleSubAgent fahrschule;
  final VehicleAdminSubAgent vehicleAdmin;

  DrivingCategory _category = DrivingCategory.fahrschule;
  String _searchQuery = '';

  DrivingCategory get category => _category;
  String get searchQuery => _searchQuery;

  List<DrivingLearningItem> get activeItems => switch (_category) {
        DrivingCategory.fahrschule => fahrschule.items,
        DrivingCategory.vehicleAdmin => vehicleAdmin.items,
      };

  List<DrivingLearningItem> get visibleItems =>
      List<DrivingLearningItem>.unmodifiable(
        activeItems.where((item) => item.matches(_searchQuery)),
      );

  List<DrivingExamPrepItem> get quickExamPrep =>
      const <DrivingExamPrepItem>[
        DrivingExamPrepItem(
          id: 'prep_theory',
          focusDe: 'Theorieprüfung',
          german: 'Ich lese jede Frage und alle Antworten zuerst genau.',
          arabic: 'أقرأ كل سؤال وجميع الإجابات أولاً بدقة.',
        ),
        DrivingExamPrepItem(
          id: 'prep_practical',
          focusDe: 'Praktische Prüfung',
          german: 'Bitte fahren Sie rechts ran, sobald es sicher möglich ist.',
          arabic: 'من فضلك توقف إلى اليمين عندما يصبح ذلك آمناً.',
        ),
        DrivingExamPrepItem(
          id: 'prep_first_aid',
          focusDe: 'Erste-Hilfe-Nachweis',
          german: 'Ich habe die Bescheinigung vom Erste-Hilfe-Kurs dabei.',
          arabic: 'لدي شهادة دورة الإسعافات الأولية معي.',
        ),
      ];

  void switchCategory(DrivingCategory category) {
    if (_category == category) return;
    _category = category;
    _searchQuery = '';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }
}
