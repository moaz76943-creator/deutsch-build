import 'package:flutter/foundation.dart';

import '../life_diy/diy_models.dart';
import 'hardware_store_models.dart';
import 'services/cutting_rental_sub_agent.dart';
import 'tools/tools_materials_sub_agent.dart';

final class HardwareStoreMasterOrchestrator extends ChangeNotifier {
  HardwareStoreMasterOrchestrator({
    ToolsMaterialsSubAgent toolsMaterials = const ToolsMaterialsSubAgent(),
    CuttingRentalSubAgent cuttingRental = const CuttingRentalSubAgent(),
  })  : _toolsMaterials = toolsMaterials,
        _cuttingRental = cuttingRental;

  final ToolsMaterialsSubAgent _toolsMaterials;
  final CuttingRentalSubAgent _cuttingRental;

  HardwareStoreSection _section = HardwareStoreSection.toolsMaterials;
  String _query = '';

  HardwareStoreSection get section => _section;
  String get query => _query;

  List<DiyPhrase> get visiblePhrases => switch (_section) {
        HardwareStoreSection.toolsMaterials => _toolsMaterials.search(_query),
        HardwareStoreSection.cuttingRental => _cuttingRental.search(_query),
      };

  List<HardwareStoreCatalogItem> get catalogItems =>
      List<HardwareStoreCatalogItem>.unmodifiable(_catalogItems);

  void setSection(HardwareStoreSection value) {
    if (_section == value) return;
    _section = value;
    _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    final normalized = value.trim();
    if (_query == normalized) return;
    _query = normalized;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  static const List<HardwareStoreCatalogItem> _catalogItems =
      <HardwareStoreCatalogItem>[
    HardwareStoreCatalogItem(
      id: 'catalog-screws',
      kind: HardwareStoreItemKind.tool,
      nameDe: 'Schrauben, Nägel & Dübel',
      nameAr: 'براغي ومسامير وقطع تثبيت',
      noteDe: 'Maße, Material und Untergrund vor dem Kauf klären.',
      noteAr: 'طابق المقاس والمادة ونوع السطح قبل الشراء.',
    ),
    HardwareStoreCatalogItem(
      id: 'catalog-drill-bits',
      kind: HardwareStoreItemKind.tool,
      nameDe: 'Bohrer & Bits',
      nameAr: 'رؤوس مثقاب ولقم',
      noteDe: 'Den Bohrer passend zum Werkstoff auswählen.',
      noteAr: 'اختر رأس المثقاب حسب المادة المراد العمل عليها.',
    ),
    HardwareStoreCatalogItem(
      id: 'catalog-paint',
      kind: HardwareStoreItemKind.material,
      nameDe: 'Farben & Klebstoffe',
      nameAr: 'دهانات ومواد لاصقة',
      noteDe: 'Einsatzbereich und Herstellerangaben vergleichen.',
      noteAr: 'قارن مجال الاستخدام وتعليمات الشركة المصنّعة.',
    ),
    HardwareStoreCatalogItem(
      id: 'catalog-plumbing',
      kind: HardwareStoreItemKind.material,
      nameDe: 'Sanitär- & Elektrobedarf',
      nameAr: 'مستلزمات سباكة وكهرباء بسيطة',
      noteDe: 'Fertige, passend gekennzeichnete Produkte auswählen.',
      noteAr: 'اختر منتجات جاهزة ومطابقة للمواصفات المطلوبة.',
    ),
    HardwareStoreCatalogItem(
      id: 'catalog-cutting',
      kind: HardwareStoreItemKind.cuttingService,
      nameDe: 'Holzzuschnitt nach Maß',
      nameAr: 'قص الخشب حسب المقاس',
      noteDe: 'Endmaß, Einheit und Toleranz vor dem Auftrag bestätigen.',
      noteAr: 'أكد المقاس والوحدة وسماحية القص قبل تنفيذ الطلب.',
    ),
    HardwareStoreCatalogItem(
      id: 'catalog-rental',
      kind: HardwareStoreItemKind.rentalService,
      nameDe: 'Mietgeräte & Zubehör',
      nameAr: 'معدات مستأجرة وملحقاتها',
      noteDe: 'Einweisung, Zubehör, Kaution und Rückgabe gemeinsam prüfen.',
      noteAr: 'تحقق من الإرشادات والملحقات والوديعة وشروط الإرجاع.',
    ),
  ];
}
