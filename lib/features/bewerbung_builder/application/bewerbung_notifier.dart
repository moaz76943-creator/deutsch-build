import 'package:flutter/foundation.dart';

import '../domain/bewerbung_models.dart';
import '../domain/bewerbung_repository.dart';

final class BewerbungNotifier extends ChangeNotifier {
  BewerbungNotifier({
    required BewerbungRepository repository,
  }) : _repository = repository;

  final BewerbungRepository _repository;

  BewerbungDocumentType _documentType =
      BewerbungDocumentType.lebenslauf;
  CareerTrack _careerTrack = CareerTrack.general;
  List<BewerbungTemplate> _templates =
      const <BewerbungTemplate>[];
  BewerbungTemplate? _selectedTemplate;
  BewerbungProfile _profile = BewerbungProfile.empty;
  BewerbungPreview? _preview;
  List<String> _validationIssues = const <String>[];
  bool _isBusy = false;

  BewerbungDocumentType get documentType => _documentType;
  CareerTrack get careerTrack => _careerTrack;
  List<BewerbungTemplate> get templates => _templates;
  BewerbungTemplate? get selectedTemplate => _selectedTemplate;
  BewerbungProfile get profile => _profile;
  BewerbungPreview? get preview => _preview;
  List<String> get validationIssues => _validationIssues;
  bool get isBusy => _isBusy;

  Future<void> initialize() => _reloadTemplates();

  Future<void> selectDocumentType(
    BewerbungDocumentType value,
  ) async {
    if (_documentType == value && _templates.isNotEmpty) return;
    _documentType = value;
    _preview = null;
    _validationIssues = const <String>[];
    await _reloadTemplates();
  }

  Future<void> selectCareerTrack(CareerTrack value) async {
    if (_careerTrack == value && _templates.isNotEmpty) return;
    _careerTrack = value;
    _preview = null;
    _validationIssues = const <String>[];
    await _reloadTemplates();
  }

  void chooseTemplate(String templateId) {
    BewerbungTemplate? match;
    for (final template in _templates) {
      if (template.id == templateId.trim()) {
        match = template;
        break;
      }
    }
    if (match == null) return;
    if (_selectedTemplate?.id == match.id) return;

    _selectedTemplate = match;
    _preview = null;
    _validationIssues = const <String>[];
    notifyListeners();
  }

  void updateProfile(BewerbungProfile value) {
    _profile = value;
    _preview = null;
    _validationIssues = const <String>[];
    notifyListeners();
  }

  Future<void> buildPreview() async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      if (_templates.isEmpty) {
        await _loadTemplatesWithoutBusyToggle();
      }

      final template = _selectedTemplate;
      if (template == null) {
        _preview = null;
        _validationIssues = const <String>[
          'اختر قالبًا قبل إنشاء المعاينة.',
        ];
        return;
      }

      final issues = await _repository.validateProfile(_profile);
      _validationIssues = issues;
      if (issues.isNotEmpty) {
        _preview = null;
        return;
      }

      _preview = await _repository.buildPreview(
        template.id,
        _profile,
      );
    } finally {
      _setBusy(false);
    }
  }

  void reset() {
    _documentType = BewerbungDocumentType.lebenslauf;
    _careerTrack = CareerTrack.general;
    _templates = const <BewerbungTemplate>[];
    _selectedTemplate = null;
    _profile = BewerbungProfile.empty;
    _preview = null;
    _validationIssues = const <String>[];
    notifyListeners();
  }

  Future<void> _reloadTemplates() async {
    if (_isBusy) return;

    _setBusy(true);
    try {
      await _loadTemplatesWithoutBusyToggle();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _loadTemplatesWithoutBusyToggle() async {
    final loaded = await _repository.getTemplates(
      documentType: _documentType,
      careerTrack: _careerTrack,
    );
    _templates = loaded;
    _selectedTemplate = loaded.isEmpty ? null : loaded.first;
    _preview = null;
    _validationIssues = const <String>[];
  }

  void _setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }
}
