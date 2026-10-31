import 'package:flutter/foundation.dart';

import '../domain/email_builder_models.dart';
import '../domain/email_builder_repository.dart';

final class EmailBuilderNotifier extends ChangeNotifier {
  EmailBuilderNotifier(this._repository);

  final EmailBuilderRepository _repository;

  List<EmailScenario> _scenarios = const <EmailScenario>[];
  List<EmailTemplateBlock> _availableBlocks =
      const <EmailTemplateBlock>[];
  EmailScenario? _activeScenario;
  Map<LetterSection, EmailTemplateBlock> _selectedBlocks =
      <LetterSection, EmailTemplateBlock>{};
  Set<LetterSection> _registerMismatchSections = <LetterSection>{};
  Set<LetterSection> _invalidPhraseSections = <LetterSection>{};
  bool? _isStructureValid;
  bool _isLoading = false;
  int _generation = 0;

  List<EmailScenario> get scenarios =>
      List<EmailScenario>.unmodifiable(_scenarios);
  List<EmailTemplateBlock> get availableBlocks =>
      List<EmailTemplateBlock>.unmodifiable(_availableBlocks);
  EmailScenario? get activeScenario => _activeScenario;
  Map<LetterSection, EmailTemplateBlock> get selectedBlocks =>
      Map<LetterSection, EmailTemplateBlock>.unmodifiable(_selectedBlocks);
  Set<LetterSection> get registerMismatchSections =>
      Set<LetterSection>.unmodifiable(_registerMismatchSections);
  Set<LetterSection> get invalidPhraseSections =>
      Set<LetterSection>.unmodifiable(_invalidPhraseSections);
  bool? get isStructureValid => _isStructureValid;
  bool get isLoading => _isLoading;

  String get previewText {
    final paragraphs = <String>[];
    for (final section in LetterSection.values) {
      final block = _selectedBlocks[section];
      if (block != null) paragraphs.add(block.text);
    }
    return paragraphs.join('\n\n');
  }

  bool get isComplete =>
      _selectedBlocks.length == LetterSection.values.length;

  List<EmailTemplateBlock> blocksForSection(LetterSection section) =>
      List<EmailTemplateBlock>.unmodifiable(
        _availableBlocks.where((item) => item.section == section),
      );

  Future<void> load() async {
    final generation = ++_generation;
    _isLoading = true;
    notifyListeners();

    try {
      final loaded = await _repository.getScenarios();
      if (generation != _generation) return;
      _scenarios = List<EmailScenario>.unmodifiable(loaded);
      if (_activeScenario == null && _scenarios.isNotEmpty) {
        await _activateScenario(_scenarios.first, generation);
      }
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> selectScenario(String scenarioId) async {
    final scenario = _findScenario(scenarioId);
    if (scenario == null) {
      throw ArgumentError.value(
        scenarioId,
        'scenarioId',
        'unknown correspondence scenario',
      );
    }

    final generation = ++_generation;
    _isLoading = true;
    _activeScenario = scenario;
    _availableBlocks = const <EmailTemplateBlock>[];
    _selectedBlocks = <LetterSection, EmailTemplateBlock>{};
    _registerMismatchSections = <LetterSection>{};
    _invalidPhraseSections = <LetterSection>{};
    _isStructureValid = null;
    notifyListeners();

    try {
      await _activateScenario(scenario, generation);
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> selectSectionBlock(String blockId) async {
    final scenario = _activeScenario;
    final block = _findBlock(blockId);
    if (scenario == null || block == null) {
      throw ArgumentError.value(
        blockId,
        'blockId',
        'block is not available for the active scenario',
      );
    }

    _selectedBlocks = Map<LetterSection, EmailTemplateBlock>.from(
      _selectedBlocks,
    )..[block.section] = block;
    _isStructureValid = null;
    notifyListeners();

    final registerOk = await _repository.isRegisterAppropriate(
      scenarioId: scenario.id,
      block: block,
    );
    final phraseOk = await _repository.validatePhrase(
      scenarioId: scenario.id,
      blockId: block.id,
    );
    if (_activeScenario?.id != scenario.id ||
        _selectedBlocks[block.section]?.id != block.id) {
      return;
    }

    final registerMismatch =
        Set<LetterSection>.from(_registerMismatchSections);
    final phraseIssues = Set<LetterSection>.from(_invalidPhraseSections);

    if (registerOk) {
      registerMismatch.remove(block.section);
    } else {
      registerMismatch.add(block.section);
    }

    if (phraseOk) {
      phraseIssues.remove(block.section);
    } else {
      phraseIssues.add(block.section);
    }

    _registerMismatchSections = registerMismatch;
    _invalidPhraseSections = phraseIssues;
    notifyListeners();
  }

  Future<void> validateLetterStructure() async {
    final scenario = _activeScenario;
    if (scenario == null) {
      _isStructureValid = false;
      notifyListeners();
      return;
    }

    final ordered = _orderedSelectedBlocks();

    final fingerprint = _selectionFingerprint();
    final structurallyValid =
        await _repository.validateStructure(ordered);
    if (_activeScenario?.id != scenario.id ||
        fingerprint != _selectionFingerprint()) {
      return;
    }

    _isStructureValid = structurallyValid &&
        ordered.length == LetterSection.values.length &&
        _registerMismatchSections.isEmpty &&
        _invalidPhraseSections.isEmpty;
    notifyListeners();
  }

  void resetTemplate() {
    _generation++;
    _selectedBlocks = <LetterSection, EmailTemplateBlock>{};
    _registerMismatchSections = <LetterSection>{};
    _invalidPhraseSections = <LetterSection>{};
    _isStructureValid = null;
    notifyListeners();
  }

  List<EmailTemplateBlock> _orderedSelectedBlocks() {
    final ordered = <EmailTemplateBlock>[];
    for (final section in LetterSection.values) {
      final block = _selectedBlocks[section];
      if (block != null) ordered.add(block);
    }
    return ordered;
  }

  String _selectionFingerprint() {
    return LetterSection.values
        .map((section) => _selectedBlocks[section]?.id ?? '-')
        .join('|');
  }

  Future<void> _activateScenario(
    EmailScenario scenario,
    int generation,
  ) async {
    final blocks = await _repository.getBlocks(scenarioId: scenario.id);
    if (generation != _generation) return;
    _activeScenario = scenario;
    _availableBlocks = List<EmailTemplateBlock>.unmodifiable(blocks);
    _selectedBlocks = <LetterSection, EmailTemplateBlock>{};
    _registerMismatchSections = <LetterSection>{};
    _invalidPhraseSections = <LetterSection>{};
    _isStructureValid = null;
  }

  EmailScenario? _findScenario(String id) {
    for (final scenario in _scenarios) {
      if (scenario.id == id) return scenario;
    }
    return null;
  }

  EmailTemplateBlock? _findBlock(String id) {
    for (final block in _availableBlocks) {
      if (block.id == id) return block;
    }
    return null;
  }
}
