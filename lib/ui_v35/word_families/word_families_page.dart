import 'package:flutter/material.dart';

import '../../language/german/german_word_family_repository.dart';
import '../../models/content.dart';
import '../../models/linguistics/german_word_family.dart';
import 'word_family_card.dart';

class WordFamiliesPage extends StatefulWidget {
  const WordFamiliesPage({
    super.key,
    required this.repository,
    required this.corpus,
    required this.learnedIds,
  });

  final GermanWordFamilyRepository repository;
  final List<ContentItem> corpus;
  final Set<String> learnedIds;

  @override
  State<WordFamiliesPage> createState() => _WordFamiliesPageState();
}

class _WordFamiliesPageState extends State<WordFamiliesPage> {
  late Future<List<GermanWordFamily>> _families;

  @override
  void initState() {
    super.initState();
    _families = widget.repository.listFamilies(limit: 120);
  }

  void _reload() {
    setState(() {
      _families = widget.repository.listFamilies(limit: 120);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentById = <String, ContentItem>{
      for (final item in widget.corpus) item.id: item,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('عائلات الكلمات')),
      body: FutureBuilder<List<GermanWordFamily>>(
        future: _families,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.error_outline,
              title: 'تعذر فتح عائلات الكلمات',
              body: 'بقيت البيانات الأساسية آمنة. حاول إعادة فتح الصفحة.',
              action: _reload,
            );
          }

          final families = snapshot.data ?? const <GermanWordFamily>[];
          if (families.isEmpty) {
            return const _MessageState(
              icon: Icons.account_tree_outlined,
              title: 'لا توجد عائلات موثّقة في الحزمة الحالية',
              body: 'لن يخمّن التطبيق الاشتقاق من تشابه شكل الكلمات. '
                  'تظهر هنا فقط العلاقات الألمانية الصريحة المراجعة.',
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 2 : 1;
              final rowCount = (families.length + columns - 1) ~/ columns;
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: rowCount,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, rowIndex) {
                  final cards = <Widget>[];
                  for (var column = 0; column < columns; column++) {
                    if (column > 0) {
                      cards.add(const SizedBox(width: 12));
                    }
                    final familyIndex = rowIndex * columns + column;
                    cards.add(
                      Expanded(
                        child: familyIndex < families.length
                            ? WordFamilyCard(
                                family: families[familyIndex],
                                contentById: contentById,
                                learnedIds: widget.learnedIds,
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cards,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 46),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center),
              if (action != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: action,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ],
          ),
        ),
      );
}
