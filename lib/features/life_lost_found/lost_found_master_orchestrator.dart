import 'package:flutter/foundation.dart';

import 'lost_found_models.dart';
import 'municipal_lost_property_sub_agent.dart';
import 'transit_recovery_sub_agent.dart';

final class LostFoundMasterOrchestrator extends ChangeNotifier {
  LostFoundMasterOrchestrator({
    MunicipalLostPropertySubAgent municipal =
        const MunicipalLostPropertySubAgent(),
    TransitRecoverySubAgent transit = const TransitRecoverySubAgent(),
  })  : _municipal = municipal,
        _transit = transit;

  final MunicipalLostPropertySubAgent _municipal;
  final TransitRecoverySubAgent _transit;

  LostFoundDomain _domain = LostFoundDomain.municipal;
  String _query = '';
  final Set<String> _completedActionIds = <String>{};

  LostFoundDomain get domain => _domain;
  String get query => _query;

  List<ImmediateLostAction> get immediateActions => _immediateActions;

  int get completedActionCount => _completedActionIds.length;

  bool get isImmediateChecklistComplete =>
      _completedActionIds.length == _immediateActions.length;

  List<LostFoundItem> get visibleItems {
    final source = switch (_domain) {
      LostFoundDomain.municipal => _municipal.items,
      LostFoundDomain.publicTransit => _transit.items,
    };

    return List<LostFoundItem>.unmodifiable(
      source.where((item) => item.matches(_query)),
    );
  }

  void switchDomain(LostFoundDomain value) {
    if (_domain == value) return;
    _domain = value;
    _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
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
        'Unknown immediate lost-item action.',
      );
    }

    final changed = complete
        ? _completedActionIds.add(normalizedId)
        : _completedActionIds.remove(normalizedId);

    if (changed) notifyListeners();
  }

  static const List<ImmediateLostAction> _immediateActions =
      <ImmediateLostAction>[
    ImmediateLostAction(
      id: 'record_where_when',
      titleDe: 'Verlustort und Zeit notieren',
      titleAr: 'دوّن مكان ووقت الفقد',
      detailAr:
          'اكتب الخط أو المحطة أو الشارع والوقت التقريبي فورًا قبل نسيان التفاصيل.',
    ),
    ImmediateLostAction(
      id: 'secure_sensitive_items',
      titleDe: 'Sensible Gegenstände sichern',
      titleAr: 'أمّن الأغراض الحساسة',
      detailAr:
          'إذا كان المفقود بطاقة أو هاتفًا أو مفتاحًا حساسًا، اتخذ إجراءات الحماية المناسبة فورًا.',
    ),
    ImmediateLostAction(
      id: 'collect_identifiers',
      titleDe: 'Merkmale sammeln',
      titleAr: 'اجمع العلامات المميزة',
      detailAr:
          'جهّز اللون والعلامة والرقم التسلسلي وصورة أو فاتورة إن كانت متوفرة.',
    ),
    ImmediateLostAction(
      id: 'submit_loss_report',
      titleDe: 'Verlustmeldung aufgeben',
      titleAr: 'قدّم بلاغ فقدان',
      detailAr:
          'استخدم الجهة المختصة: Fundbüro البلدي أو شركة النقل أو DB Fundservice بحسب مكان الفقد.',
    ),
    ImmediateLostAction(
      id: 'save_reference_and_proof',
      titleDe: 'Vorgangsnummer & Eigentumsnachweis sichern',
      titleAr: 'احفظ رقم المعاملة وإثبات الملكية',
      detailAr:
          'احتفظ برقم البلاغ وبأي إثبات يساعدك عند المطابقة أو الاستلام.',
    ),
  ];
}
