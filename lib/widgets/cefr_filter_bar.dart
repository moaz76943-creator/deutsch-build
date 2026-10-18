import 'package:flutter/material.dart';

import '../services/cefr_classifier.dart';
import '../services/vocabulary_filter_service.dart';

/// Compact, horizontally scrollable CEFR chips for a vocabulary browser.
///
/// The parent owns selection state and is responsible for calling
/// VocabularyFilterService.search when a chip changes. This widget does not
/// run SQL or filter a previously limited list in memory.
class CefrFilterBar extends StatelessWidget {
  const CefrFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final VocabularyCefrFilter selected;
  final ValueChanged<VocabularyCefrFilter> onChanged;
  final bool enabled;

  static const List<VocabularyCefrFilter> _filters = <VocabularyCefrFilter>[
    VocabularyCefrFilter.all,
    VocabularyCefrFilter.a1,
    VocabularyCefrFilter.a2,
    VocabularyCefrFilter.b1,
    VocabularyCefrFilter.b2,
    VocabularyCefrFilter.advanced,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final active = filter == selected;
          final accent = _color(filter, scheme);
          final shortLabel = _code(filter);
          final description = _description(filter);

          return ChoiceChip(
            selected: active,
            onSelected: enabled ? (_) => onChanged(filter) : null,
            showCheckmark: false,
            selectedColor: accent.withValues(alpha: 0.18),
            backgroundColor: scheme.surface,
            side: BorderSide(
              color: active ? accent : scheme.outlineVariant,
              width: active ? 1.5 : 1,
            ),
            shape: const StadiumBorder(),
            visualDensity: VisualDensity.compact,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    child: Text(
                      shortLabel,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                if (description.isNotEmpty) ...<Widget>[
                  const SizedBox(width: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  static String _code(VocabularyCefrFilter filter) => switch (filter) {
        VocabularyCefrFilter.all => 'All',
        VocabularyCefrFilter.a1 => 'A1',
        VocabularyCefrFilter.a2 => 'A2',
        VocabularyCefrFilter.b1 => 'B1',
        VocabularyCefrFilter.b2 => 'B2',
        VocabularyCefrFilter.advanced => 'C1/C2',
      };

  static String _description(VocabularyCefrFilter filter) => switch (filter) {
        VocabularyCefrFilter.all => '',
        VocabularyCefrFilter.a1 => '(Beginner)',
        VocabularyCefrFilter.a2 => '(Elementary)',
        VocabularyCefrFilter.b1 => '(Intermediate)',
        VocabularyCefrFilter.b2 => '',
        VocabularyCefrFilter.advanced => '(Advanced)',
      };

  static Color _color(
    VocabularyCefrFilter filter,
    ColorScheme scheme,
  ) =>
      switch (filter) {
        VocabularyCefrFilter.all => scheme.onSurfaceVariant,
        VocabularyCefrFilter.a1 => CefrClassifier.getLevelColor(CefrLevel.a1),
        VocabularyCefrFilter.a2 => CefrClassifier.getLevelColor(CefrLevel.a2),
        VocabularyCefrFilter.b1 => CefrClassifier.getLevelColor(CefrLevel.b1),
        VocabularyCefrFilter.b2 => CefrClassifier.getLevelColor(CefrLevel.b2),
        VocabularyCefrFilter.advanced =>
          CefrClassifier.getLevelColor(CefrLevel.c1),
      };
}
