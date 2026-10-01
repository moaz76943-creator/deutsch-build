import 'package:flutter/material.dart';

import '../../services/grammar_hub_service.dart';
import '../../services/app_dependencies.dart';
import 'grammar_quiz_page.dart';

class GrammarTopicDetailPage extends StatelessWidget {
  final GrammarTopic topic;
  final AppDependencies dependencies;

  const GrammarTopicDetailPage({
    Key? key,
    required this.topic,
    required this.dependencies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.titleDe, style: const TextStyle(fontFamily: 'Inter')),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                topic.titleAr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (topic.formulaPattern != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'القاعدة (الصيغة):',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        topic.formulaPattern!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'الشرح:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  topic.explanationMarkdown,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GrammarQuizPage(
                        topicId: topic.id,
                        dependencies: dependencies,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.quiz),
                label: const Text(
                  'Start Micro-Quiz',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.indigo.shade50,
                  foregroundColor: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
