import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/pack_manager.dart';
import '../../../core/services/audio_tts_service.dart';

class SectionExplorerScreen extends StatefulWidget {
  final String initialLanguage;

  const SectionExplorerScreen({Key? key, this.initialLanguage = 'de'}) : super(key: key);

  @override
  State<SectionExplorerScreen> createState() => _SectionExplorerScreenState();
}

class _SectionExplorerScreenState extends State<SectionExplorerScreen> {
  late String currentLanguage;
  String selectedSection = 'HOME_KITCHEN';
  String selectedCefr = 'A1';
  bool isLoading = true;
  bool isSearching = false;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> searchResults = [];
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> availableLanguages = [
    {'code': 'de', 'name': 'الألمانية (Deutsch)'},
    {'code': 'ar', 'name': 'العربية (Arabic)'},
    {'code': 'en', 'name': 'الإنجليزية (English)'},
    {'code': 'fr', 'name': 'الفرنسية (Français)'},
    {'code': 'es', 'name': 'الإسبانية (Español)'},
    {'code': 'it', 'name': 'الإيطالية (Italiano)'},
    {'code': 'tr', 'name': 'التركية (Türkçe)'},
    {'code': 'pt', 'name': 'البرتغالية (Português)'},
    {'code': 'ru', 'name': 'الروسية (Русский)'},
    {'code': 'nl', 'name': 'الهولندية (Nederlands)'},
  ];

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
    currentLanguage = widget.initialLanguage;
    loadSectionData();
  }

  Future<void> loadSectionData() async {
    setState(() => isLoading = true);
    try {
      await PackManager.initLanguagePack(currentLanguage);
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

  Future<void> performInstantSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    setState(() => isSearching = true);
    final results = await PackManager.searchInstant(query.trim());
    setState(() {
      searchResults = results;
    });
  }

  void showLicenseDialog() async {
    final meta = await PackManager.getDatasetMetadata();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('المصادر والتراخيص المفتوحة ⚖️'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المصدر: ${meta['source'] ?? 'Kaikki / Wiktionary'}'),
            const SizedBox(height: 6),
            Text('الترخيص: ${meta['license'] ?? 'CC BY-SA 4.0 / GFDL 1.3'}'),
            const SizedBox(height: 6),
            Text('تاريخ البناء: ${meta['pipeline_build'] ?? '2026-10-12'}'),
            const SizedBox(height: 12),
            const Text(
              'المحتوى المعجمي مرخص بموجب رخصة المشاع الإبداعي النسبة-المشاركة بالمثل، مع الالتزام الكامل بشروط النسبة القانونية.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
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
                onPressed: () async {
                  Navigator.pop(ctx);
                  final isCorrect = opt == ex['correct_answer'];
                  await PackManager.recordQuizResult(conceptId: conceptId, isCorrect: isCorrect);
                  await loadSectionData();

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isCorrect ? '✅ إجابة صحيحة! تم تحديث جدول المراجعة.' : '❌ خطأ! الإجابة: ${ex['correct_answer']}'),
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
    final displayList = isSearching ? searchResults : items;

    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentLanguage,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            dropdownColor: Colors.indigo.shade800,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            onChanged: (newLang) {
              if (newLang != null && newLang != currentLanguage) {
                setState(() {
                  currentLanguage = newLang;
                  searchController.clear();
                  isSearching = false;
                });
                loadSectionData();
              }
            },
            items: availableLanguages.map((lang) {
              return DropdownMenuItem<String>(
                value: lang['code'],
                child: Text(lang['name']!),
              );
            }).toList(),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'التراخيص والمصادر',
            onPressed: showLicenseDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث اللحظي FTS5
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: TextField(
              controller: searchController,
              onChanged: performInstantSearch,
              decoration: InputDecoration(
                hintText: 'بحث فوري في المعجم (FTS5)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          performInstantSearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),

          if (!isSearching) ...[
            // شريط الأقسام
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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

            // شريط المستويات CEFR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
          ],

          const Divider(),

          // عرض النتائج والبطاقات
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                    ? Center(
                        child: Text(
                          isSearching
                              ? 'لم يتم العثور على نتائج مطابقة لـ "${searchController.text}"'
                              : 'لا توجد مفردات مسجلة لهذا المستوى حالياً.',
                        ),
                      )
                    : ListView.separated(
                        itemCount: displayList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = displayList[index];
                          final pos = item['part_of_speech'] ?? 'noun';
                          final word = item['word'] ?? item['display_text'] ?? '';
                          final boxLevel = item['box_level'] as int? ?? 0;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: pos == 'verb'
                                  ? Colors.orange.shade100
                                  : (pos == 'phrase' ? Colors.purple.shade100 : Colors.blue.shade100),
                              child: Text(
                                pos == 'verb' ? 'فعل' : (pos == 'phrase' ? 'جملة' : 'اسم'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              word,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              isSearching ? 'المعرف: ${item['concept_id']}' : 'المستوى في الذاكرة: صندوق $boxLevel',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.volume_up, color: Colors.blueGrey),
                                  tooltip: 'استماع للنطق',
                                  onPressed: () => AudioTtsService.speak(
                                    text: word,
                                    languageCode: currentLanguage,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.quiz, color: Colors.indigo),
                                  tooltip: 'بدء تمرين',
                                  onPressed: () => openQuizDialog(item['concept_id'], word),
                                ),
                              ],
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
