import 'package:flutter/material.dart';

import '../../core/curriculum/omni_directional_matrix.dart';
import 'phase6_l10n_controller.dart';

final class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({
    required this.controller,
    super.key,
  });

  final Phase6L10nController controller;

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

final class _LanguageSelectionScreenState
    extends State<LanguageSelectionScreen> {
  late String _uiLanguage;
  late String _sourceLanguage;
  late String _targetLanguage;

  Phase6L10nController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _uiLanguage = controller.snapshot.userLocale.languageCode;
    _sourceLanguage = controller.pair.source.id;
    _targetLanguage = controller.pair.target.id;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Directionality(
          textDirection: controller.textDirection,
          child: Scaffold(
            appBar: AppBar(
              title: Text(controller.text('language.screen.title')),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: <Widget>[
                  _LanguageField(
                    label: controller.text('language.ui'),
                    value: _uiLanguage,
                    languages: controller.languages,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _uiLanguage = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  _LanguageField(
                    label: controller.text('language.source'),
                    value: _sourceLanguage,
                    languages: controller.languages,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _sourceLanguage = value;
                        if (_targetLanguage == value) {
                          _targetLanguage = _firstDifferent(value);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _LanguageField(
                    label: controller.text('language.target'),
                    value: _targetLanguage,
                    languages: controller.languages
                        .where((item) => item.id != _sourceLanguage)
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _targetLanguage = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            controller.text(
                              'language.matrix',
                              arguments: <String, Object?>{
                                'source':
                                    controller.languageLabel(_sourceLanguage),
                                'target':
                                    controller.languageLabel(_targetLanguage),
                              },
                            ),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.text(
                              'language.directions',
                              arguments: <String, Object?>{
                                'count': controller.matrix.directedPairCount,
                                'languages': controller.matrix.languages.length,
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(controller.text('language.ui_fallback')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _apply,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(controller.text('language.apply')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _apply() {
    if (_sourceLanguage == _targetLanguage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.text('language.same_error'))),
      );
      return;
    }

    try {
      controller.requestSelection(
        userLanguageId: _uiLanguage,
        sourceLanguageId: _sourceLanguage,
        targetLanguageId: _targetLanguage,
      );
      Navigator.of(context).pop();
    } on Object catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.text(
              'language.apply_error',
              arguments: <String, Object?>{'error': error.toString()},
            ),
          ),
        ),
      );
    }
  }

  String _firstDifferent(String sourceId) =>
      controller.languages.firstWhere((item) => item.id != sourceId).id;
}

final class _LanguageField extends StatelessWidget {
  const _LanguageField({
    required this.label,
    required this.value,
    required this.languages,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<LearningLanguageIdentity> languages;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        isExpanded: true,
        items: <DropdownMenuItem<String>>[
          for (final language in languages)
            DropdownMenuItem<String>(
              value: language.id,
              child: Text(
                '${language.nativeName} · ${language.englishName}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: onChanged,
      );
}
