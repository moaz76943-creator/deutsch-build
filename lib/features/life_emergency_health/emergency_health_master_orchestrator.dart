import 'package:flutter/foundation.dart';

import 'emergency_health_models.dart';

final class EmergencyHealthMasterOrchestrator extends ChangeNotifier {
  EmergencyHealthMasterOrchestrator({
    List<EmergencyHealthContentSource> contentSources =
        const <EmergencyHealthContentSource>[],
  }) : _contentSources =
            List<EmergencyHealthContentSource>.unmodifiable(contentSources);

  final List<EmergencyHealthContentSource> _contentSources;

  EmergencyHealthDomain _domain = EmergencyHealthDomain.ambulance112;
  String _query = '';
  final Set<String> _completedActionIds = <String>{};

  EmergencyHealthDomain get domain => _domain;
  String get query => _query;
  List<EmergencyChecklistAction> get immediateActions => _immediateActions;
  int get completedActionCount => _completedActionIds.length;
  bool get isImmediateChecklistComplete =>
      _completedActionIds.length == _immediateActions.length;

  List<EmergencyPhrase> get visibleItems {
    final sourceItems = _contentSources
        .where((source) => source.domain == _domain)
        .expand((source) => source.items);

    return List<EmergencyPhrase>.unmodifiable(
      sourceItems.where((item) => item.matches(_query)),
    );
  }

  void switchDomain(EmergencyHealthDomain value) {
    if (_domain == value && _query.isEmpty) return;
    _domain = value;
    _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    final next = value.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  bool isActionComplete(String actionId) =>
      _completedActionIds.contains(actionId.trim());

  void setActionComplete(String actionId, bool complete) {
    final normalizedId = actionId.trim();
    if (!_immediateActions.any((action) => action.id == normalizedId)) {
      throw ArgumentError.value(
        actionId,
        'actionId',
        'Unknown emergency-health checklist action.',
      );
    }

    final changed = complete
        ? _completedActionIds.add(normalizedId)
        : _completedActionIds.remove(normalizedId);

    if (changed) notifyListeners();
  }

  static const List<EmergencyChecklistAction> _immediateActions =
      <EmergencyChecklistAction>[
    EmergencyChecklistAction(
      id: 'scene_safety',
      titleDe: 'Eigenschutz zuerst',
      titleAr: 'السلامة أولًا',
      detailAr:
          'ابتعد عن الخطر المباشر ولا تعرّض نفسك أو المصاب لخطر إضافي قبل طلب المساعدة.',
    ),
    EmergencyChecklistAction(
      id: 'choose_service',
      titleDe: '112 oder 116 117?',
      titleAr: 'اختر الجهة الصحيحة',
      detailAr:
          'في الخطر المهدد للحياة اتصل بـ112. للحاجة الطبية العاجلة غير المهددة للحياة خارج أوقات العيادات استخدم 116117.',
    ),
    EmergencyChecklistAction(
      id: 'exact_location',
      titleDe: 'Notfallort bereithalten',
      titleAr: 'جهّز الموقع الدقيق',
      detailAr:
          'حضّر الشارع والرقم والطابق أو علامة واضحة تساعد الطاقم على الوصول بسرعة.',
    ),
    EmergencyChecklistAction(
      id: 'describe_condition',
      titleDe: 'Zustand kurz beschreiben',
      titleAr: 'صف الحالة باختصار',
      detailAr:
          'اذكر ما حدث، عدد المصابين، الوعي والتنفس والنزيف أو الأعراض الشديدة بوضوح.',
    ),
    EmergencyChecklistAction(
      id: 'wait_questions',
      titleDe: 'Auf Rückfragen warten',
      titleAr: 'انتظر أسئلة الموظف',
      detailAr:
          'لا تغلق الاتصال من نفسك؛ أجب عن الأسئلة واتبع تعليمات مركز الاتصال.',
    ),
  ];
}
