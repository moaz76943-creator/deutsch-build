import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../application/verb_drill_notifier.dart';
import '../../domain/verb_conjugation_factory.dart';
import '../../domain/verb_models.dart';
import '../../domain/verb_repository.dart';
import '../widgets/rapid_conjugation_drill_widget.dart';

class VerbConjugationScreen extends StatefulWidget {
  const VerbConjugationScreen({required this.repository, super.key});

  final VerbRepository repository;

  @override
  State<VerbConjugationScreen> createState() => _VerbConjugationScreenState();
}

class _VerbConjugationScreenState extends State<VerbConjugationScreen> {
  late final VerbDrillNotifier _drillNotifier;
  late final List<VerbItem> _verbs;
  late VerbItem _selectedVerb;
  VerbTense _selectedTense = VerbTense.praesens;

  @override
  void initState() {
    super.initState();
    _verbs = widget.repository.commonVerbs;
    if (_verbs.isEmpty) {
      throw StateError('VerbConjugationScreen requires a non-empty repository');
    }
    _selectedVerb = _verbs.first;
    _drillNotifier = VerbDrillNotifier(widget.repository);
  }

  @override
  void dispose() {
    _drillNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('تصريف الأفعال · Verb Arena')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
            children: [
              _VerbSelectorCard(
                verbs: _verbs,
                selected: _selectedVerb,
                onChanged: (verb) => setState(() => _selectedVerb = verb),
              ),
              const SizedBox(height: 14),
              _TenseSelector(
                selected: _selectedTense,
                onChanged: (tense) => setState(() => _selectedTense = tense),
              ),
              const SizedBox(height: 14),
              _ConjugationTableCard(
                verb: _selectedVerb,
                tense: _selectedTense,
              ),
              const SizedBox(height: 18),
              RapidConjugationDrillWidget(notifier: _drillNotifier),
            ],
          ),
        ),
      );
}

class _VerbSelectorCard extends StatelessWidget {
  const _VerbSelectorCard({
    required this.verbs,
    required this.selected,
    required this.onChanged,
  });

  final List<VerbItem> verbs;
  final VerbItem selected;
  final ValueChanged<VerbItem> onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'جدول التصريف الكامل',
                    style: AppTypography.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VerbItem>(
              initialValue: selected,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'الفعل',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final verb in verbs)
                  DropdownMenuItem<VerbItem>(
                    value: verb,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            verb.infinitive,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(verb.meaningAr, style: AppTypography.body),
                      ],
                    ),
                  ),
              ],
              onChanged: (verb) {
                if (verb != null) onChanged(verb);
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: _VerbKindBadge(kind: selected.kind),
            ),
          ],
        ),
      );
}

class _VerbKindBadge extends StatelessWidget {
  const _VerbKindBadge({required this.kind});

  final VerbKind kind;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (kind) {
      VerbKind.regular => ('منتظم · regelmäßig', AppColors.mastery),
      VerbKind.irregular => ('شاذ · unregelmäßig', AppColors.tertiary),
      VerbKind.separable => ('منفصل · trennbar', AppColors.achievement),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: AppTypography.label.copyWith(color: color),
        ),
      ),
    );
  }
}

class _TenseSelector extends StatelessWidget {
  const _TenseSelector({
    required this.selected,
    required this.onChanged,
  });

  final VerbTense selected;
  final ValueChanged<VerbTense> onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tense in VerbTense.values)
              ChoiceChip(
                label: Text(
                  tense.label,
                  textDirection: TextDirection.ltr,
                ),
                selected: tense == selected,
                selectedColor: AppColors.primary.withAlpha(34),
                side: BorderSide(
                  color: tense == selected
                      ? AppColors.primary
                      : Theme.of(context).dividerColor,
                ),
                onSelected: (_) => onChanged(tense),
              ),
          ],
        ),
      );
}

class _ConjugationTableCard extends StatelessWidget {
  const _ConjugationTableCard({
    required this.verb,
    required this.tense,
  });

  final VerbItem verb;
  final VerbTense tense;

  @override
  Widget build(BuildContext context) {
    final table = verb.tableFor(tense);
    return AppGlassCard(
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${verb.infinitive} · ${tense.label}',
                  textDirection: TextDirection.ltr,
                  style: AppTypography.title,
                ),
              ),
              if (tense == VerbTense.perfekt)
                Text(
                  '${table.auxiliary?.infinitive ?? ''} + ${table.participle ?? ''}',
                  textDirection: TextDirection.ltr,
                  style: AppTypography.label.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final pronoun in GermanPronoun.values) ...[
            _ConjugationRow(
              pronoun: pronoun,
              segments: VerbConjugationFactory.emphasisFor(
                verb: verb,
                tense: tense,
                pronoun: pronoun,
              ),
            ),
            if (pronoun != GermanPronoun.values.last)
              const Divider(height: 18),
          ],
          if (tense == VerbTense.praesens &&
              verb.presentEmphasisTokens.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.achievement,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'اللون البنفسجي يبرز تغيّر حرف العلة أو الـ Umlaut.',
                    style: AppTypography.label,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ConjugationRow extends StatelessWidget {
  const _ConjugationRow({
    required this.pronoun,
    required this.segments,
  });

  final GermanPronoun pronoun;
  final List<VerbTextSegment> segments;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              pronoun.label,
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              textDirection: TextDirection.ltr,
              text: TextSpan(
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                children: [
                  for (final segment in segments)
                    TextSpan(
                      text: segment.text,
                      style: segment.emphasized
                          ? const TextStyle(
                              color: AppColors.achievement,
                              fontWeight: FontWeight.w900,
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ],
      );
}
