import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../services/user_vocabulary_service.dart';

class MicroContextStory {
  final String title;
  final String storyText;
  final Map<String, String> vocabularyTranslations;

  const MicroContextStory({
    required this.title,
    required this.storyText,
    required this.vocabularyTranslations,
  });
}

class MicroContextStoriesEngine {
  final UserVocabularyService _vocabularyService;

  MicroContextStoriesEngine(this._vocabularyService);

  Future<MicroContextStory?> generateStoryForToday() async {
    final entries = await _vocabularyService.getCustomEntries();
    if (entries.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Filter for vocabulary created today
    final todayVocab = entries.where((e) {
      final createdAt = e['created_at'] as String?;
      return createdAt != null && createdAt.startsWith(todayStr);
    }).toList();

    // Fallback to recent 3 if no vocab today
    final List<Map<String, dynamic>> selectedVocab = todayVocab.isNotEmpty
        ? todayVocab.take(3).toList()
        : entries.take(3).toList();

    if (selectedVocab.isEmpty) return null;

    final Map<String, String> translations = {};
    for (final v in selectedVocab) {
      translations[v['german_text'] as String] =
          v['arabic_translation'] as String;
    }

    final words = selectedVocab.map((e) => e['german_text'] as String).toList();

    String storyText;
    String title;

    if (words.length == 1) {
      title = "Eine kurze Geschichte über ${words[0]}";
      storyText =
          "Heute habe ich etwas Neues gelernt. Das Wort ist ${words[0]}. Es ist wichtig, ${words[0]} zu verstehen, um besser Deutsch zu sprechen.";
    } else if (words.length == 2) {
      title = "Die Geschichte von ${words[0]} und ${words[1]}";
      storyText =
          "Es war einmal ein Tag, an dem wir über ${words[0]} sprachen. Später lernten wir auch über ${words[1]}. Beide, ${words[0]} und ${words[1]}, sind sehr nützlich.";
    } else {
      title = "Ein Tag mit ${words[0]}, ${words[1]} und ${words[2]}";
      storyText =
          "Am Morgen dachte ich an ${words[0]}. Am Mittag benutzte ich ${words[1]}. Und am Abend war ${words[2]} sehr wichtig für mich. So war mein Tag.";
    }

    return MicroContextStory(
      title: title,
      storyText: storyText,
      vocabularyTranslations: translations,
    );
  }
}

class MicroContextStoriesView extends StatefulWidget {
  final MicroContextStoriesEngine engine;

  const MicroContextStoriesView({super.key, required this.engine});

  @override
  State<MicroContextStoriesView> createState() =>
      _MicroContextStoriesViewState();
}

class _MicroContextStoriesViewState extends State<MicroContextStoriesView> {
  MicroContextStory? _story;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    try {
      final story = await widget.engine.generateStoryForToday();
      if (mounted) {
        setState(() {
          _story = story;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showTranslationDrawer(String germanWord, String arabicTranslation) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                germanWord,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                arabicTranslation,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_story == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('قصص السياق الصغير')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'لا يوجد مفردات كافية لبناء قصة اليوم. قم بإضافة المزيد من المفردات في قسم المفردات الشخصية.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('قصة اليوم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _story!.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildInteractiveStoryText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveStoryText(BuildContext context) {
    // Split text keeping the delimiters using capture group
    final parts = _story!.storyText.split(RegExp(r'(\b)'));

    final List<TextSpan> spans = [];

    for (final part in parts) {
      String? translation;
      bool isVocabulary = false;

      final cleanWord = part.trim();
      if (cleanWord.isNotEmpty) {
        for (final entry in _story!.vocabularyTranslations.entries) {
          if (cleanWord.toLowerCase() == entry.key.toLowerCase()) {
            isVocabulary = true;
            translation = entry.value;
            break;
          }
        }
      }

      if (isVocabulary) {
        spans.add(
          TextSpan(
            text: part,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _showTranslationDrawer(cleanWord, translation!),
          ),
        );
      } else {
        spans.add(
          TextSpan(text: part, style: Theme.of(context).textTheme.bodyLarge),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}
