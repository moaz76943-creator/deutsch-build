import 'package:flutter/material.dart';

import '../../models/grammar.dart';
import '../../data/canonical_grammar_catalog.dart';
import 'grammar_topic_detail_page.dart';

class GrammarHubPage extends StatefulWidget {
  const GrammarHubPage({Key? key}) : super(key: key);

  @override
  _GrammarHubPageState createState() => _GrammarHubPageState();
}

class _GrammarHubPageState extends State<GrammarHubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _levels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مركز القواعد',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _levels.map((level) => Tab(text: level)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _levels.map((level) {
          final topicsForLevel = CanonicalGrammarCatalog.allTopics
              .where((topic) => topic.level == level)
              .toList();
          return _buildTopicsList(topicsForLevel);
        }).toList(),
      ),
    );
  }

  Widget _buildTopicsList(List<GrammarTopic> topics) {
    if (topics.isEmpty) {
      return const Center(child: Text('لا توجد مواضيع في هذا المستوى حالياً.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      // Performance: bound pre-build area beyond viewport (default ~250 px).
      // Moderate value balances smoothness vs memory on card lists.
      cacheExtent: 300,
      // Avoid keeping all offscreen items alive; reduces memory for long grammar topic lists.
      addAutomaticKeepAlives: false,
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return RepaintBoundary(
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrammarTopicDetailPage(topic: topic),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            topic.level,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            topic.titleDe,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.titleAr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Tajawal',
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.summaryAr,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontFamily: 'Tajawal'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
