import 'package:flutter/material.dart';

import '../../../core/theme/adaptive_glass_surface.dart';
import '../domain/verb_conjugation_models.dart';

class VerbConjugationTable extends StatelessWidget {
  const VerbConjugationTable({
    super.key,
    required this.verb,
  });

  final VerbConjugation verb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final perfekt = verb.perfektSummary;

    return Semantics(
      container: true,
      label: verb.infinitive + ', ' + verb.meaning,
      child: AdaptiveGlassSurface(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                verb.infinitive,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                verb.meaning,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  if (verb.isSeparable)
                    const Chip(label: Text('trennbar')),
                  if (perfekt != null)
                    Chip(label: Text('Perfekt: ' + perfekt)),
                ],
              ),
              const SizedBox(height: 12),
              for (final tense in verb.tenses) ...<Widget>[
                Text(
                  tense.label,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Person')),
                      DataColumn(label: Text('Form')),
                    ],
                    rows: VerbPerson.values
                        .map(
                          (person) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(person.label)),
                              DataCell(Text(tense.formFor(person))),
                            ],
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
      ),
    );
  }
}
