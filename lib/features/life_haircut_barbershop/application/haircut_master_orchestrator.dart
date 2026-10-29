import 'package:flutter/foundation.dart';

import '../domain/haircut_models.dart';
import '../payment/washing_payment_agent.dart';
import '../styles/appointment_style_agent.dart';
import '../styles/haircut_phrase.dart';

final class HaircutBarbershopModule {
  const HaircutBarbershopModule();

  static const String routeName = '/life/haircut-barbershop';

  HaircutMasterOrchestrator createOrchestrator() =>
      HaircutMasterOrchestrator(
        appointmentStyleAgent: const AppointmentStyleAgent(),
        washingPaymentAgent: const WashingPaymentAgent(),
      );
}

final class HaircutMasterOrchestrator extends ChangeNotifier {
  HaircutMasterOrchestrator({
    required AppointmentStyleAgent appointmentStyleAgent,
    required WashingPaymentAgent washingPaymentAgent,
  })  : _appointmentStyleAgent = appointmentStyleAgent,
        _washingPaymentAgent = washingPaymentAgent;

  final AppointmentStyleAgent _appointmentStyleAgent;
  final WashingPaymentAgent _washingPaymentAgent;

  String _query = '';
  HaircutLevel? _level;
  HaircutTopic? _topic;
  HaircutServiceKind? _selectedService;

  String get query => _query;
  HaircutLevel? get level => _level;
  HaircutTopic? get topic => _topic;
  HaircutServiceKind? get selectedService => _selectedService;

  List<HaircutServiceOption> get services => HaircutBarbershopCatalog.services;

  List<SalonOpeningHours> get openingHours =>
      HaircutBarbershopCatalog.sampleOpeningHours;

  List<HaircutPhrase> get results {
    final combined = <HaircutPhrase>[
      ..._appointmentStyleAgent.search(
        _query,
        level: _level,
        topic: _topic,
      ),
      ..._washingPaymentAgent.search(
        _query,
        level: _level,
        topic: _topic,
      ),
    ];
    return List<HaircutPhrase>.unmodifiable(combined);
  }

  List<HaircutPhrase> get quickPhrases => List<HaircutPhrase>.unmodifiable(
        <HaircutPhrase>[
          ..._appointmentStyleAgent.quickPhrases,
          ..._washingPaymentAgent.quickPhrases,
        ],
      );

  void setQuery(String value) {
    final next = value.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void setLevel(HaircutLevel? value) {
    if (_level == value) return;
    _level = value;
    notifyListeners();
  }

  void setTopic(HaircutTopic? value) {
    if (_topic == value) return;
    _topic = value;
    notifyListeners();
  }

  void selectService(HaircutServiceKind? value) {
    if (_selectedService == value) return;
    _selectedService = value;
    notifyListeners();
  }

  void resetFilters() {
    final changed = _query.isNotEmpty ||
        _level != null ||
        _topic != null ||
        _selectedService != null;
    _query = '';
    _level = null;
    _topic = null;
    _selectedService = null;
    if (changed) notifyListeners();
  }
}
