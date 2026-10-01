import 'package:flutter/material.dart';

import '../../services/repository.dart';
import '../../core/content_contract.dart';
import '../../services/app_dependencies.dart';

class ZenContextReader extends StatefulWidget {
  final LearnerRepository repo;
  final AppDependencies<LearningContent> dependencies;

  const ZenContextReader({
    super.key,
    required this.repo,
    required this.dependencies,
  });

  @override
  State<ZenContextReader> createState() => _ZenContextReaderState();
}

class _ZenContextReaderState extends State<ZenContextReader> {
  List<String> _paragraphs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMasteredVocabulary();
  }

  Future<void> _loadMasteredVocabulary() async {
    setState(() => _isLoading = true);

    try {
      final state = widget.repo.load();
      final learnedIds = state.learned;

      if (learnedIds.isEmpty) {
        setState(() {
          _paragraphs = [
            'Keine Vokabeln gemeistert.',
            'Bitte lernen Sie mehr Wörter, um Texte zu lesen.',
          ];
          _isLoading = false;
        });
        return;
      }

      final learnedContent = widget.dependencies.corpus
          .where((c) => learnedIds.contains(c.id))
          .toList();
      final sentences = learnedContent
          .map((c) => c.exampleText)
          .where((s) => s.isNotEmpty)
          .toList();

      if (sentences.isEmpty) {
        setState(() {
          _paragraphs = ['Nicht genug Vokabeln für einen Text.'];
          _isLoading = false;
        });
        return;
      }

      // Group sentences into short paragraphs for coherent contextual reading
      final paragraphs = <String>[];
      for (int i = 0; i < sentences.length; i += 3) {
        final end = (i + 3 < sentences.length) ? i + 3 : sentences.length;
        paragraphs.add(sentences.sublist(i, end).join(' '));
      }

      setState(() {
        _paragraphs = paragraphs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _paragraphs = ['Fehler beim Laden des Textes.'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Zen Kontext Leser'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView.builder(
                itemCount: _paragraphs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      _paragraphs[index],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
