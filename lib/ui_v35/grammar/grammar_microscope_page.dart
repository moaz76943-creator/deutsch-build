import 'package:flutter/material.dart';

import '../../core/text/directional_text.dart';
import '../../models/content.dart';
import '../../models/learner.dart';
import '../../services/app_dependencies.dart';
import '../../services/grammar_microscope_service.dart';
import '../shared/text/bidi_text.dart';
import 'grammar_microscope_sections.dart';

class GrammarMicroscopePage extends StatefulWidget {
  const GrammarMicroscopePage({
    super.key,
    required this.topicId,
    required this.state,
    required this.dependencies,
  });

  final String topicId;
  final LearnerState state;
  final AppDependencies<ContentItem> dependencies;

  @override
  State<GrammarMicroscopePage> createState() =>
      _GrammarMicroscopePageState();
}

class _GrammarMicroscopePageState extends State<GrammarMicroscopePage> {
  late final Future<GrammarMicroscopeSnapshot?> _snapshot;

  @override
  void initState() {
    super.initState();
    _snapshot = GrammarMicroscopeService(
      widget.dependencies.grammarHubService,
    ).load(
      topicId: widget.topicId,
      state: widget.state,
      corpus: widget.dependencies.corpus,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('مجهر القواعد')),
    body: FutureBuilder<GrammarMicroscopeSnapshot?>(
      future: _snapshot,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (asyncSnapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('تعذر تحميل تفاصيل القاعدة بأمان.'),
            ),
          );
        }

        final snapshot = asyncSnapshot.data;
        if (snapshot == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('موضوع القاعدة غير متاح في المصدر النشط.'),
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              BidiText(
                DirectionalText.german(
                  snapshot.topic.titleDe,
                  semanticRole: LinguisticSemanticRole.grammarLabel,
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              BidiText(
                DirectionalText.arabic(
                  snapshot.topic.titleAr,
                  semanticRole: LinguisticSemanticRole.translation,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              BidiText(
                DirectionalText.arabic(
                  snapshot.topic.explanationMarkdown,
                  semanticRole: LinguisticSemanticRole.explanation,
                ),
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 20),
              GrammarMicroscopeEvidenceSection(snapshot: snapshot),
              const SizedBox(height: 20),
              GrammarMicroscopeRulesSection(snapshot: snapshot),
            ],
          ),
        );
      },
    ),
  );
}
