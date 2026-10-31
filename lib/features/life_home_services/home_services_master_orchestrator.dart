import 'package:flutter/foundation.dart';

import 'craft_repair_sub_agent.dart';
import 'home_services_models.dart';
import 'locksmith_emergency_sub_agent.dart';

final class HomeServicesMasterOrchestrator extends ChangeNotifier {
  HomeServicesMasterOrchestrator({
    LocksmithEmergencySubAgent locksmith =
        const LocksmithEmergencySubAgent(),
    CraftRepairSubAgent craftRepair = const CraftRepairSubAgent(),
  })  : _locksmith = locksmith,
        _craftRepair = craftRepair;

  final LocksmithEmergencySubAgent _locksmith;
  final CraftRepairSubAgent _craftRepair;

  HomeServicesDomain _domain = HomeServicesDomain.locksmithEmergency;
  String _query = '';

  HomeServicesDomain get domain => _domain;
  String get query => _query;

  List<HomeServicePhrase> get visiblePhrases {
    final source = switch (_domain) {
      HomeServicesDomain.locksmithEmergency => _locksmith.phrases,
      HomeServicesDomain.urgentRepairs => _craftRepair.phrases,
    };

    return List<HomeServicePhrase>.unmodifiable(
      source.where((phrase) => phrase.matches(_query)),
    );
  }

  List<ConsumerProtectionWarning> get consumerWarnings =>
      _consumerWarnings;

  void setDomain(HomeServicesDomain value) {
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

  static const List<ConsumerProtectionWarning> _consumerWarnings =
      <ConsumerProtectionWarning>[
    ConsumerProtectionWarning(
      id: 'price-before-dispatch',
      german:
          'Vor der Anfahrt einen verbindlichen Festpreis inklusive Anfahrt '
          'und möglicher Zuschläge vereinbaren.',
      arabic:
          'اتفق قبل وصول الفني على السعر الثابت والملزم الذي يشمل أجرة الوصول وأي رسوم إضافية محتملة.',
    ),
    ConsumerProtectionWarning(
      id: 'identity-before-work',
      german:
          'Vor Arbeitsbeginn Ausweis oder Firmennachweis und Firmennamen prüfen.',
      arabic:
          'تحقق من هوية الفني أو إثبات الشركة واسمها قبل بدء العمل.',
    ),
    ConsumerProtectionWarning(
      id: 'approve-extra-work',
      german:
          'Zusätzliche Arbeiten oder Teile erst nach Erklärung und Preisangabe freigeben.',
      arabic:
          'لا توافق على أعمال أو قطع إضافية قبل شرحها وتحديد سعرها.',
    ),
    ConsumerProtectionWarning(
      id: 'request-invoice',
      german:
          'Eine vollständige Rechnung mit Firma, Leistung und Einzelbeträgen verlangen.',
      arabic:
          'اطلب فاتورة كاملة تتضمن الشركة والخدمة والمبالغ المفصلة.',
    ),
  ];
}
