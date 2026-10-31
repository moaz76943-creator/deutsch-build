import 'package:flutter/foundation.dart';

import 'home_internet_sub_agent.dart';
import 'mobile_and_sim_sub_agent.dart';
import 'telecom_models.dart';

final class TelecomMasterOrchestrator extends ChangeNotifier {
  TelecomMasterOrchestrator({
    HomeInternetSubAgent homeInternet = const HomeInternetSubAgent(),
    MobileAndSimSubAgent mobileAndSim = const MobileAndSimSubAgent(),
  })  : _homeInternet = homeInternet,
        _mobileAndSim = mobileAndSim;

  final HomeInternetSubAgent _homeInternet;
  final MobileAndSimSubAgent _mobileAndSim;

  TelecomDomain _domain = TelecomDomain.homeInternet;
  String _query = '';
  bool _outageHelpExpanded = false;

  TelecomDomain get domain => _domain;
  String get query => _query;
  bool get outageHelpExpanded => _outageHelpExpanded;

  List<TelecomPhrase> get visiblePhrases {
    final source = switch (_domain) {
      TelecomDomain.homeInternet => _homeInternet.phrases,
      TelecomDomain.mobilePrepaid => _mobileAndSim.phrases,
    };

    return List<TelecomPhrase>.unmodifiable(
      source.where((phrase) => phrase.matches(_query)),
    );
  }

  List<NetworkOutageStep> get outageSteps => _outageSteps;

  NetworkOutagePrompt get outagePrompt => _outagePrompt;

  void setDomain(TelecomDomain value) {
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

  void expandOutageHelp() {
    if (_outageHelpExpanded) return;
    _outageHelpExpanded = true;
    notifyListeners();
  }

  void dismissOutageHelp() {
    if (!_outageHelpExpanded) return;
    _outageHelpExpanded = false;
    notifyListeners();
  }

  void toggleOutageHelp() {
    _outageHelpExpanded = !_outageHelpExpanded;
    notifyListeners();
  }

  static const List<NetworkOutageStep> _outageSteps = <NetworkOutageStep>[
    NetworkOutageStep(
      german:
          '1. Prüfen Sie Router, Stromversorgung und sichtbare Statusleuchten.',
      arabic:
          '1. تحقق من الراوتر ومصدر الكهرباء ومؤشرات الحالة الظاهرة.',
    ),
    NetworkOutageStep(
      german:
          '2. Prüfen Sie Kabel und Steckverbindungen, ohne Geräte zu öffnen.',
      arabic:
          '2. تحقق من الكابلات والتوصيلات الخارجية دون فتح الأجهزة.',
    ),
    NetworkOutageStep(
      german:
          '3. Notieren Sie Zeitpunkt, betroffene Geräte und die angezeigte Fehlermeldung.',
      arabic:
          '3. دوّن وقت المشكلة والأجهزة المتأثرة ورسالة الخطأ الظاهرة.',
    ),
    NetworkOutageStep(
      german:
          '4. Fragen Sie den Anbieter nach einer bekannten Störung und lassen Sie bei Bedarf eine Störungsmeldung aufnehmen.',
      arabic:
          '4. اسأل مزود الخدمة عن وجود عطل معروف، واطلب تسجيل بلاغ عطل عند الحاجة.',
    ),
  ];

  static const NetworkOutagePrompt _outagePrompt = NetworkOutagePrompt(
    german:
        'Seit wann besteht die Störung, und ist für meinen Anschluss bereits eine bekannte Netzstörung gemeldet?',
    arabic:
        'منذ متى يوجد العطل، وهل هناك عطل معروف ومُسجل حاليًا على خطي؟',
  );
}
