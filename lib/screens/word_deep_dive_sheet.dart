import 'package:flutter/material.dart';
import '../widgets/lexicon_rich_details.dart';

class AppTypography {
  static const TextStyle h1 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A));
  static const TextStyle h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B));
  static const TextStyle h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155));
  static const TextStyle body = TextStyle(fontSize: 14, color: Color(0xFF475569));
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569));
  static const TextStyle caption = TextStyle(fontSize: 12, color: Color(0xFF64748B));
  static const TextStyle label = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B));
}

class AppGradients {
  static const LinearGradient blueCard = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ArticleBadge extends StatelessWidget {
  final String? article;
  final String? label;
  final String? text;
  final Color? color;

  const ArticleBadge({
    super.key,
    this.article,
    this.label,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final display = article ?? label ?? text ?? '';
    if (display.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF4F46E5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        display,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class WordDeepDiveSheet extends StatelessWidget {
  final Map<String, dynamic>? wordData;
  final String? word;
  final String? article;
  final String? meaning;
  final String? example;
  final String? exampleMeaning;
  final dynamic item;

  const WordDeepDiveSheet({
    super.key,
    this.wordData,
    this.word,
    this.article,
    this.meaning,
    this.example,
    this.exampleMeaning,
    this.item,
  });

  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? wordData,
    String? word,
    String? article,
    String? meaning,
    String? example,
    String? exampleMeaning,
    dynamic item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WordDeepDiveSheet(
        wordData: wordData,
        word: word,
        article: article,
        meaning: meaning,
        example: example,
        exampleMeaning: exampleMeaning,
        item: item,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawItem = item is Map
        ? (item as Map).map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
    final data = <String, dynamic>{
      ...rawItem,
      ...?wordData,
      if (word != null) 'word': word,
      if (article != null) 'article': article,
      if (meaning != null) 'meaning': meaning,
      if (example != null) 'example': example,
      if (exampleMeaning != null) 'exampleMeaning': exampleMeaning,
    };
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LexiconRichDetails(entry: data),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
