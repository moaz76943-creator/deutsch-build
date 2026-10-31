import 'package:flutter/foundation.dart';

import 'bulky_and_depot_sub_agent.dart';
import 'household_sorting_sub_agent.dart';
import 'waste_models.dart';

final class WasteMasterOrchestrator extends ChangeNotifier {
  WasteMasterOrchestrator({
    HouseholdSortingSubAgent householdSorting =
        const HouseholdSortingSubAgent(),
    BulkyAndDepotSubAgent bulkyAndDepot = const BulkyAndDepotSubAgent(),
  })  : _householdSorting = householdSorting,
        _bulkyAndDepot = bulkyAndDepot;

  final HouseholdSortingSubAgent _householdSorting;
  final BulkyAndDepotSubAgent _bulkyAndDepot;

  WasteCategory _category = WasteCategory.householdSortingPfand;
  String _query = '';
  String _lookupQuery = '';

  WasteCategory get category => _category;
  String get query => _query;
  String get lookupQuery => _lookupQuery;

  List<WastePhrase> get visiblePhrases {
    final source = switch (_category) {
      WasteCategory.householdSortingPfand => _householdSorting.phrases,
      WasteCategory.bulkyWasteDepot => _bulkyAndDepot.phrases,
    };

    return List<WastePhrase>.unmodifiable(
      source.where((phrase) => phrase.matches(_query)),
    );
  }

  WasteLookupResult get lookupResult {
    final needle = _lookupQuery.trim().toLowerCase();

    if (needle.isEmpty) {
      return const WasteLookupResult(
        routeDe: 'Gegenstand eingeben',
        routeAr: 'اكتب اسم الغرض',
        noteDe:
            'Die Schnellhilfe gibt eine sichere Orientierung und verweist bei örtlich unterschiedlichen Regeln auf die Kommune.',
        noteAr:
            'تعطي الأداة توجيهاً سريعاً، وتطلب الرجوع للبلدية عندما تختلف القواعد محلياً.',
        isKnown: false,
      );
    }

    if (_containsAny(needle, const <String>[
      'batterie',
      'batterien',
      'akku',
      'akkus',
    ])) {
      return const WasteLookupResult(
        routeDe: 'Sammelstelle / Rücknahmestelle',
        routeAr: 'نقطة تجميع أو استرجاع مخصصة',
        noteDe:
            'Batterien und Akkus getrennt sammeln und die lokalen Annahmehinweise beachten.',
        noteAr:
            'اجمع البطاريات بشكل منفصل واتبع تعليمات نقطة الاستلام المحلية.',
        isKnown: true,
      );
    }

    if (_containsAny(needle, const <String>[
      'zeitung',
      'papier',
      'karton',
      'pappe',
    ])) {
      return const WasteLookupResult(
        routeDe: 'Altpapier',
        routeAr: 'الورق والكرتون المخصصان لإعادة التدوير',
        noteDe:
            'Sauberes Papier und Karton nach den örtlichen Vorgaben zur Papiersammlung geben.',
        noteAr:
            'ضع الورق والكرتون النظيفين في مسار جمع الورق حسب تعليمات البلدية.',
        isKnown: true,
      );
    }

    if (_containsAny(needle, const <String>[
      'glas',
      'glasflasche',
      'marmeladenglas',
    ])) {
      return const WasteLookupResult(
        routeDe: 'Altglas nach Glasfarbe',
        routeAr: 'حاوية الزجاج حسب لون الزجاج',
        noteDe:
            'Pfand zuerst prüfen und anschließend Farbe sowie örtliche Einwurfzeiten beachten.',
        noteAr:
            'تحقق أولاً من وجود تأمين على العبوة ثم راعِ اللون وأوقات الإلقاء المحلية.',
        isKnown: true,
      );
    }

    if (_containsAny(needle, const <String>[
      'verpackung',
      'kunststoffverpackung',
      'dose',
      'konservendose',
    ])) {
      return const WasteLookupResult(
        routeDe: 'Gelber Sack / Gelbe Tonne',
        routeAr: 'الكيس الأصفر أو الحاوية الصفراء',
        noteDe:
            'Für leere Verkaufsverpackungen die Kennzeichnung und die lokalen Sammelregeln prüfen.',
        noteAr:
            'للعبوات الفارغة تحقق من العلامة ومن نظام الجمع المحلي.',
        isKnown: true,
      );
    }

    if (_containsAny(needle, const <String>[
      'bananenschale',
      'kaffeesatz',
      'bioabfall',
      'biomüll',
    ])) {
      return const WasteLookupResult(
        routeDe: 'Biotonne – lokale Vorgaben prüfen',
        routeAr: 'حاوية العضويات مع التحقق من القواعد المحلية',
        noteDe:
            'Welche Küchenabfälle angenommen werden, kann örtlich unterschiedlich geregelt sein.',
        noteAr:
            'قد تختلف أنواع مخلفات المطبخ المقبولة من بلدية إلى أخرى.',
        isKnown: true,
      );
    }

    if (_containsAny(needle, const <String>[
      'pfandflasche',
      'mehrwegflasche',
      'einwegpfand',
      'mehrwegpfand',
    ])) {
      return const WasteLookupResult(
        routeDe: 'Pfandrückgabe',
        routeAr: 'إرجاع العبوة واسترداد التأمين',
        noteDe:
            'Pfandkennzeichnung prüfen und die Flasche über eine passende Rücknahmestelle zurückgeben.',
        noteAr:
            'تحقق من علامة التأمين وأعد العبوة إلى نقطة استرجاع مناسبة.',
        isKnown: true,
      );
    }

    return const WasteLookupResult(
      routeDe: 'Lokale Abfallberatung prüfen',
      routeAr: 'تحقق من دليل النفايات المحلي',
      noteDe:
          'Bei unbekannten oder gemischten Stoffen nicht raten: kommunales Abfall-ABC oder Wertstoffhof fragen.',
      noteAr:
          'عند عدم معرفة المادة أو كونها مختلطة لا تخمّن؛ راجع دليل البلدية أو مركز التدوير.',
      isKnown: false,
    );
  }

  static bool _containsAny(String source, List<String> candidates) =>
      candidates.any(source.contains);

  void setCategory(WasteCategory value) {
    if (_category == value) return;
    _category = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  void setLookupQuery(String value) {
    if (_lookupQuery == value) return;
    _lookupQuery = value;
    notifyListeners();
  }
}
