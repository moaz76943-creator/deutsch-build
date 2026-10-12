import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/pack_manager.dart';

class SectionExplorerScreen extends StatefulWidget {
  final String currentLanguage;

  const SectionExplorerScreen({Key? key, this.currentLanguage = 'ar'}) : super(key: key);

  @override
  State<SectionExplorerScreen> createState() => _SectionExplorerScreenState();
}

class _SectionExplorerScreenState extends State<SectionExplorerScreen> {
  String selectedSection = 'HOME_KITCHEN';
  String selectedCefr = 'A1';
  bool isLoading = true;
  List<Map<String, dynamic>> items = [];

  final List<Map<String, String>> sections = [
    {'id': 'HOME_KITCHEN', 'title': 'المطبخ والأواني 🍳'},
    {'id': 'HOME_BATHROOM', 'title': 'الحمام والنظافة 🚿'},
    {'id': 'HOME_LIVING', 'title': 'غرفة المعيشة 🛋️'},
    {'id': 'PHARMA', 'title': 'الصيدلة والعلاج 💊'},
    {'id': 'EMERGENCY', 'title': 'طوارئ وإسعاف 🚨'},
  ];

  @override
  void initState() {
    super.initState();
    loadSectionData();
  }

  Future<void> loadSectionData() async {
    setState(() => isLoading = true);
    try {
      await PackManager.initLanguagePack(widget.currentLanguage);
      final data = await PackManager.getConceptsBySection(
        sectionId: selectedSection,
        cefr: selectedCefr,
      );
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void openQuizDialog(String conceptId, String word) async {
    final exercises = await PackManager.getExercises(conceptId);
    if (exercises.isEmpty || !mounted) return;

    final ex = exercises.first;
    final List distractors = jsonDecode(ex['distractors_json'] as String? ?? '[]');
    final List<String> options = [ex['correct_answer'] as String, ...distractors.map((e) => e.toString())]..shuffle();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ex['prompt'] as String? ?? 'اختر الإجابة الصحيحة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade50,
                  foregroundColor: Colors.black87,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  final isCorrect = opt == ex['correct_answer'];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isCorrect ? '✅ إجابة صحيحة ممتازة!' : '❌ إجابة خاطئة، الصحيح: ${ex['correct_answer']}'),
                      backgroundColor: isCorrect ? Colors.green : Colors.red,
                    ),
                  );
                },
                child: Text(opt, style: const TextStyle(fontSize: 16)),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستودع اللغوي التفاعلي'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // شريط اختيار القسم
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: sections.map((sec) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(sec['title']!),
                  selected: selectedSection == sec['id'],
                  onSelected: (val) {
                    if (val) {
                      setState(() => selectedSection = sec['id']!);
                      loadSectionData();
                    }
                  },
                ),
              )).toList(),
            ),
          ),

          // شريط اختيار المستوى CEFR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['A1', 'A2', 'B1', 'B2'].map((lvl) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FilterChip(
                  label: Text(lvl),
                  selected: selectedCefr == lvl,
                  onSelected: (val) {
                    if (val) {
                      setState(() => selectedCefr = lvl);
                      loadSectionData();
                    }
                  },
                ),
              )).toList(),
            ),
          ),

          const Divider(),

          // قائمة الكلمات والأفعال والجمل
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? const Center(child: Text('لا توجد مفردات مسجلة لهذا المستوى حالياً.'))
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final pos = item['part_of_speech'] ?? 'noun';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: pos == 'verb' ? Colors.orange.shade100 : (pos == 'phrase' ? Colors.purple.shade100 : Colors.blue.shade100),
                              child: Text(
                                pos == 'verb' ? 'فعل' : (pos == 'phrase' ? 'جملة' : 'اسم'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              item['word'] ?? '',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('المعرف: ${item['concept_id']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.quiz, color: Colors.indigo),
                              onPressed: () => openQuizDialog(item['concept_id'], item['word'] ?? ''),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
