import 'package:flutter/material.dart';

import '../../models/content.dart';
import '../../models/learner.dart';
import '../../services/repository.dart';
import '../../services/search_index.dart';
import '../../language/language_text_normalizer.dart';
import '../../services/verb_index.dart';
import '../../services/word_profile_service.dart';
import '../../language/language_presentation.dart';
import '../../models/word_profile.dart';
import '../safe_ui.dart';

class OfflineLexiconHub extends StatefulWidget {
  final LearnerRepository repo;
  final List<ContentItem> corpus;
  final SearchIndex<ContentItem> searchIndex;
  final VerbIndex verbIndex;
  final LanguagePresentation presentation;
  final LanguageTextNormalizer textNormalizer;

  const OfflineLexiconHub({
    super.key,
    required this.repo,
    required this.corpus,
    required this.searchIndex,
    required this.verbIndex,
    required this.presentation,
    required this.textNormalizer,
  });

  @override
  State<OfflineLexiconHub> createState() => _OfflineLexiconHubState();
}

class _OfflineLexiconHubState extends State<OfflineLexiconHub> {
  String q = '';
  late final LearnerState state = widget.repo.load();
  late final Set<String> _learnedIds = state.learned;
  late final List<ContentItem> _learnedItems = widget.corpus
      .where((x) => _learnedIds.contains(x.id))
      .toList(growable: false);

  final Map<String, WordProfile<ContentItem>> _profiles =
      <String, WordProfile<ContentItem>>{};
  late final Map<String, List<Attempt>> _attemptsByItem = _groupAttempts(
    state.attempts,
  );

  static Map<String, List<Attempt>> _groupAttempts(List<Attempt> attempts) {
    final grouped = <String, List<Attempt>>{};
    for (final attempt in attempts) {
      (grouped[attempt.itemId] ??= <Attempt>[]).add(attempt);
    }
    return grouped;
  }

  final SafeTtsController _tts = SafeTtsController();

  Future<void> _speak(String text) => _tts.speak(text);

  WordProfile<ContentItem> _profileFor(ContentItem item) =>
      _profiles[item.id] ??= WordProfileService.build(
        item,
        state,
        searchIndex: widget.searchIndex,
        verbIndex: widget.verbIndex,
        textNormalizer: widget.textNormalizer,
        itemAttempts: _attemptsByItem[item.id] ?? const <Attempt>[],
      );

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.textNormalizer.answer(q);
    List<ContentItem> results;

    if (query.isEmpty) {
      results = _learnedItems;
    } else {
      final searchResults = widget.searchIndex
          .searchDetailed(query, limit: 200)
          .map((x) => x.item);
      results =
          searchResults.where((item) => _learnedIds.contains(item.id)).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('مكتبة المفردات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => q = v),
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'البحث في المفردات المكتسبة',
                hintText: 'ابحث بالألمانية أو العربية',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 48),
                          const SizedBox(height: 10),
                          Text(
                            _learnedItems.isEmpty
                                ? 'لم تكتسب أي مفردات بعد'
                                : 'لا توجد نتيجة مطابقة في مفرداتك المكتسبة',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_learnedItems.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            const Text(
                              'جرّب الكلمة الألمانية أو ترجمتها العربية.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: results.length,
                    itemBuilder: (c, i) {
                      final x = results[i];
                      return _LexiconWordCard(
                        item: x,
                        profile: _profileFor(x),
                        speak: _speak,
                        presentation: widget.presentation,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LexiconWordCard extends StatelessWidget {
  final ContentItem item;
  final WordProfile<ContentItem> profile;
  final Future<void> Function(String) speak;
  final LanguagePresentation presentation;

  const _LexiconWordCard({
    required this.item,
    required this.profile,
    required this.speak,
    required this.presentation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => speak(item.sourceText),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.sourceText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => speak(item.sourceText),
                    tooltip: 'استمع',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(item.translationText, style: const TextStyle(fontSize: 16)),
              const Divider(height: 20),
              Text(
                item.exampleText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 4),
              Text(item.exampleTranslationText),
              if (item.grammaticalMarker.isNotEmpty ||
                  item.pluralForm.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (item.grammaticalMarker.isNotEmpty)
                      Chip(
                        label: Text(
                          '${presentation.grammaticalMarkerLabel}: ${item.grammaticalMarker}',
                        ),
                      ),
                    if (item.pluralForm.isNotEmpty)
                      Chip(
                        label: Text(
                          '${presentation.pluralLabel}: ${item.pluralForm}',
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: profile.masteryPercent / 100,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                color: profile.masteryPercent >= 80
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                'إتقان: ${profile.masteryPercent}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
