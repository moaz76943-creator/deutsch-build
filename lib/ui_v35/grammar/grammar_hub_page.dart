import 'package:flutter/material.dart';

import '../../models/content.dart';
import '../../models/learner.dart';
import '../../services/grammar_hub_service.dart';
import '../../services/app_dependencies.dart';
import '../../core/text/directional_text.dart';
import '../shared/text/bidi_text.dart';
import 'grammar_topic_detail_page.dart';

class GrammarHubPage extends StatefulWidget {
  final AppDependencies<ContentItem> dependencies;
  final LearnerState? learnerState;
  const GrammarHubPage({
    Key? key,
    required this.dependencies,
    this.learnerState,
  }) : super(key: key);

  @override
  _GrammarHubPageState createState() => _GrammarHubPageState();
}

class _GrammarHubPageState extends State<GrammarHubPage> {
  String _selectedLevel = 'A1';
  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  List<GrammarTopic> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
    });
    final topics = await widget.dependencies.grammarHubService.getTopicsByLevel(
      _selectedLevel,
    );
    setState(() {
      _topics = topics;
      _isLoading = false;
    });
  }

  void _onLevelSelected(String level) {
    if (_selectedLevel != level) {
      setState(() {
        _selectedLevel = level;
      });
      _loadTopics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Hub', style: TextStyle(fontFamily: 'Inter')),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Level Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: _levels.map((level) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        level,
                        style: const TextStyle(fontFamily: 'Inter'),
                      ),
                      selected: _selectedLevel == level,
                      onSelected: (_) => _onLevelSelected(level),
                      backgroundColor: Colors.blueGrey.shade50,
                      selectedColor: Colors.blue.shade100,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            // Topics List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _topics.isEmpty
                      ? const Center(
                          child: Text('لا توجد مواضيع متاحة لهذا المستوى.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _topics.length,
                          itemBuilder: (context, index) {
                            final topic = _topics[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: topic.isMastered
                                  ? Colors.green.shade50
                                  : Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                title: BidiText(
                                  DirectionalText.german(
                                    topic.titleDe,
                                    semanticRole:
                                        LinguisticSemanticRole.grammarLabel,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                subtitle: BidiText(
                                  DirectionalText.arabic(
                                    topic.titleAr,
                                    semanticRole:
                                        LinguisticSemanticRole.translation,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                trailing: Icon(
                                  topic.isMastered
                                      ? Icons.check_circle
                                      : Icons.chevron_right,
                                  color: topic.isMastered
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          GrammarTopicDetailPage(
                                        topic: topic,
                                        dependencies: widget.dependencies,
                                        learnerState: widget.learnerState,
                                      ),
                                    ),
                                  );
                                  // Refresh topics to update mastery status
                                  _loadTopics();
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
