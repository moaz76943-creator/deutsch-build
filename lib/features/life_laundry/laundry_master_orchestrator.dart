import 'package:flutter/foundation.dart';

import 'dry_cleaning_sub_agent.dart';
import 'laundry_models.dart';
import 'self_service_laundromat_sub_agent.dart';

final class LaundryMasterOrchestrator extends ChangeNotifier {
  LaundryMasterOrchestrator({
    SelfServiceLaundromatSubAgent selfService =
        const SelfServiceLaundromatSubAgent(),
    DryCleaningSubAgent dryCleaning = const DryCleaningSubAgent(),
  })  : _selfService = selfService,
        _dryCleaning = dryCleaning;

  final SelfServiceLaundromatSubAgent _selfService;
  final DryCleaningSubAgent _dryCleaning;

  LaundryDomain _domain = LaundryDomain.selfServiceLaundromat;
  String _query = '';

  LaundryDomain get domain => _domain;
  String get query => _query;

  List<LaundryPhrase> get visiblePhrases {
    final source = switch (_domain) {
      LaundryDomain.selfServiceLaundromat => _selfService.phrases,
      LaundryDomain.professionalCleaning => _dryCleaning.phrases,
    };

    return List<LaundryPhrase>.unmodifiable(
      source.where((phrase) => phrase.matches(_query)),
    );
  }

  List<FabricCareSymbol> get fabricCareSymbols => _fabricCareSymbols;

  void setDomain(LaundryDomain value) {
    if (_domain == value) return;
    _domain = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  static const List<FabricCareSymbol> _fabricCareSymbols = <FabricCareSymbol>[
    FabricCareSymbol(
      id: 'wash-40',
      symbol: '40°',
      german: 'Waschbottich 40 °C: bei höchstens 40 °C waschen.',
      arabic: 'حوض غسيل 40°: الغسل بدرجة حرارة لا تتجاوز 40 مئوية.',
    ),
    FabricCareSymbol(
      id: 'no-bleach',
      symbol: '△×',
      german: 'Durchgestrichenes Dreieck: nicht bleichen.',
      arabic: 'مثلث مشطوب: لا تستخدم المبيّض.',
    ),
    FabricCareSymbol(
      id: 'tumble-low',
      symbol: '□○•',
      german: 'Trockner mit einem Punkt: schonend bei niedriger Temperatur.',
      arabic: 'رمز المجفف بنقطة واحدة: تجفيف لطيف بحرارة منخفضة.',
    ),
    FabricCareSymbol(
      id: 'iron-medium',
      symbol: 'Bügeleisen ••',
      german: 'Bügeleisen mit zwei Punkten: mit mittlerer Temperatur bügeln.',
      arabic: 'مكواة بنقطتين: الكيّ بدرجة حرارة متوسطة.',
    ),
    FabricCareSymbol(
      id: 'professional-clean-p',
      symbol: '○P',
      german:
          'Kreis mit P: professionelle Reinigung nach dem Pflegeetikett.',
      arabic: 'دائرة بداخلها P: تنظيف احترافي وفق تعليمات بطاقة العناية.',
    ),
    FabricCareSymbol(
      id: 'no-professional-clean',
      symbol: '○×',
      german: 'Durchgestrichener Kreis: nicht professionell chemisch reinigen.',
      arabic: 'دائرة مشطوبة: لا تستخدم التنظيف الكيميائي الاحترافي.',
    ),
  ];
}
