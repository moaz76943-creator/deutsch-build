import 'package:flutter/material.dart';

import '../../models/grammar.dart';

class GrammarTopicDetailPage extends StatefulWidget {
  final GrammarTopic topic;

  const GrammarTopicDetailPage({Key? key, required this.topic})
      : super(key: key);

  @override
  _GrammarTopicDetailPageState createState() => _GrammarTopicDetailPageState();
}

class _GrammarTopicDetailPageState extends State<GrammarTopicDetailPage> {
  final Map<String, int?> _selectedAnswers = {};
  final Map<String, bool> _showExplanations = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topic.titleDe,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            ...widget.topic.rules
                .map((rule) => _buildRuleCard(context, rule))
                .toList(),
            if (widget.topic.miniChecks.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'اختبر فهمك',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
              ),
              const SizedBox(height: 16),
              ...widget.topic.miniChecks
                  .map((check) => _buildMiniCheck(context, check))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.topic.level,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.topic.titleAr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.topic.summaryAr,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontFamily: 'Tajawal'),
        ),
      ],
    );
  }

  Widget _buildRuleCard(BuildContext context, GrammarRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rule_outlined, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rule.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              rule.explanationAr,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontFamily: 'Tajawal'),
            ),
            if (rule.table.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSyntaxTable(context, rule.table),
            ],
            if (rule.examples.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'أمثلة:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 8),
              ...rule.examples
                  .map((ex) => _buildExampleRow(context, ex))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyntaxTable(BuildContext context, List<List<String>> table) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        children: table.map((row) {
          final isHeader = table.indexOf(row) == 0;
          return TableRow(
            decoration: isHeader
                ? BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  )
                : null,
            children: row.map((cell) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  cell,
                  style: TextStyle(
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Inter',
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExampleRow(BuildContext context, GrammarExample example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              example.german,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              example.arabic,
              style: const TextStyle(color: Colors.grey, fontFamily: 'Tajawal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCheck(BuildContext context, MiniCheckQuestion check) {
    final selectedOption = _selectedAnswers[check.id];
    final isAnswered = selectedOption != null;
    final isCorrect = isAnswered && selectedOption == check.correctAnswerIndex;
    final showExplanation = _showExplanations[check.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.3),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              check.questionText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            ...check.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value;

              Color? tileColor;
              if (isAnswered) {
                if (idx == check.correctAnswerIndex) {
                  tileColor = Colors.green.withValues(alpha: 0.2);
                } else if (idx == selectedOption) {
                  tileColor = Colors.red.withValues(alpha: 0.2);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: isAnswered
                      ? null
                      : () {
                          setState(() {
                            _selectedAnswers[check.id] = idx;
                            _showExplanations[check.id] = true;
                          });
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tileColor ?? Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAnswered && idx == selectedOption
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        if (isAnswered && idx == check.correctAnswerIndex)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          )
                        else if (isAnswered && idx == selectedOption)
                          const Icon(Icons.cancel, color: Colors.red, size: 20)
                        else
                          const Icon(Icons.radio_button_unchecked, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            if (showExplanation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect
                        ? Colors.green.withValues(alpha: 0.5)
                        : Colors.red.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isCorrect ? Icons.lightbulb_outline : Icons.info_outline,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        check.explanationAr,
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
