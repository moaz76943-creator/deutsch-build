import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class VisualVocabularyScreen extends StatelessWidget {
  const VisualVocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {"word": "der Apfel", "trans": "تفاحة", "icon": "🍎"},
      {"word": "das Buch", "trans": "كتاب", "icon": "📖"},
      {"word": "die Sonne", "trans": "شمس", "icon": "☀️"},
      {"word": "das Auto", "trans": "سيارة", "icon": "🚗"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفردات البصرية المباشرة'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return AppBaseGlassCard(
                  padding: const EdgeInsets.all(16),
<<<<<<< HEAD
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VisualVocabularyDetailScreen(item: item),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Hero(
                        tag: 'visual_vocab_${item['word']}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(item['icon']!,
                              style: const TextStyle(fontSize: 48)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(item['word']!,
                          style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(item['trans']!,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
=======
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(item['icon']!, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(item['word']!, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(item['trans']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
<<<<<<< HEAD

class VisualVocabularyDetailScreen extends StatelessWidget {
  final Map<String, String> item;

  const VisualVocabularyDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['word']!),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Center(
            child: AppBaseGlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'visual_vocab_${item['word']}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(item['icon']!,
                          style: const TextStyle(fontSize: 96)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(item['word']!,
                      style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item['trans']!,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
